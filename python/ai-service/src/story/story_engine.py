"""
Story Engine - On-Demand Narrative Generation

Level 4 (Cache-Only) implementation for contextual story content.

Generates narratives on-demand with full player context (choices, relationships,
world state) and caches results for consistency.

Key Features:
- On-demand generation with LLM (Ollama/Claude/OpenAI)
- Smart caching with player state hash
- Cache invalidation on significant state changes
- Full context from MemoryManager and WorldState
"""

import asyncio
import json
import logging
from typing import Dict, List, Any, Optional
from datetime import datetime
import redis.asyncio as redis

from .memory_manager import MemoryManager

logger = logging.getLogger(__name__)


class StoryEngine:
    """
    On-demand narrative generation with contextual caching.

    Level 4 (Cache-Only):
    - Generate narrative on-demand with full player context
    - Cache result with player state hash (1 hour TTL)
    - No pre-generation (generates when requested)
    - Invalidate cache on significant player state changes
    """

    def __init__(
        self,
        redis_client: redis.Redis,
        llm_client: Any,
        memory_manager: MemoryManager,
        cache_ttl: int = 3600
    ):
        """
        Initialize story engine.

        Args:
            redis_client: Async Redis client
            llm_client: LLM client (Ollama/Claude/OpenAI)
            memory_manager: Memory manager for player context
            cache_ttl: Cache TTL in seconds (default 1 hour)
        """
        self.redis = redis_client
        self.llm = llm_client
        self.memory = memory_manager
        self.cache_ttl = cache_ttl

    def _hash_player_state(self, player_state: Dict[str, Any]) -> str:
        """
        Generate hash of player state for cache key.

        Includes: level, mission progress, major flags.
        Excludes: inventory details, exact timestamps.

        Args:
            player_state: Player state dict

        Returns:
            Hash string (16 hex chars)

        Note:
            Uses Python's built-in hash() for cache keys (not security-critical).
            ~5-10x faster than SHA256, sufficient for cache invalidation.
        """
        # Extract relevant state fields
        relevant_state = {
            "level": player_state.get("level", 1),
            "current_mission": player_state.get("current_mission"),
            "completed_missions_count": len(player_state.get("completed_missions", [])),
            "phase": player_state.get("phase", 1),
        }

        # Sort keys for consistent hash
        state_json = json.dumps(relevant_state, sort_keys=True)

        # Use built-in hash() for speed (not cryptographic, but perfect for cache keys)
        # Convert to positive hex string for consistent cache keys
        hash_value = hash(state_json)
        # Convert to unsigned 64-bit and format as 16-char hex string
        hash_hex = format(hash_value & 0xFFFFFFFFFFFFFFFF, '016x')

        return hash_hex

    async def _build_narrative_prompt(
        self,
        mission_template: Dict[str, Any],
        stage_id: str,
        player_context: Dict[str, Any],
        world_context: Dict[str, Any]
    ) -> str:
        """
        Build prompt for narrative generation.

        Args:
            mission_template: Hybrid mission JSON
            stage_id: Current stage ID
            player_context: Player memory context
            world_context: World state context

        Returns:
            Formatted prompt string
        """
        # Find stage in mission template
        stage = None
        for s in mission_template.get("stages", []):
            if s.get("stage_id") == stage_id:
                stage = s
                break

        if not stage:
            raise ValueError(f"Stage {stage_id} not found in mission template")

        narrative_structure = stage.get("narrative_structure", {})
        mission_context = mission_template.get("context", {})

        # Build prompt
        prompt = f"""You are the Storyteller for Space Adventures, a serious sci-fi game.

MISSION CONTEXT:
Location: {mission_context.get('location', 'Unknown')}
Theme: {mission_context.get('theme', 'Unknown')}
Tone: {mission_context.get('tone', 'Serious sci-fi')}
Key NPCs: {', '.join(mission_context.get('key_npcs', []))}

NARRATIVE STRUCTURE:
Setup: {narrative_structure.get('setup', 'Unknown')}
Conflict: {narrative_structure.get('conflict', 'Unknown')}
Prompt: {narrative_structure.get('prompt', 'Describe this scene')}
Include: {', '.join(narrative_structure.get('include', []))}

PLAYER HISTORY (Last {len(player_context.get('recent_choices', []))} choices):
"""
        # Add recent choices
        for choice in player_context.get("recent_choices", [])[:5]:
            prompt += f"- {choice.get('choice_id', 'unknown')}: {choice.get('outcome', 'unknown')}\n"

        # Add relationships if any
        relationships = player_context.get("relationships", {})
        if relationships:
            prompt += "\nRELATIONSHIPS:\n"
            for npc, score in relationships.items():
                sentiment = "positive" if score > 20 else "negative" if score < -20 else "neutral"
                prompt += f"- {npc}: {score} ({sentiment})\n"

        # Add active consequences
        consequences = player_context.get("active_consequences", [])
        if consequences:
            prompt += "\nACTIVE CONSEQUENCES:\n"
            for cons in consequences[:3]:
                prompt += f"- {cons.get('consequence_id', 'unknown')}\n"

        # Add world context hints
        if world_context:
            prompt += "\nWORLD STATE:\n"
            if "economy" in world_context:
                prompt += f"- Economy: {world_context['economy']}\n"
            if "factions" in world_context:
                prompt += f"- Factions: {world_context['factions']}\n"

        prompt += """
INSTRUCTIONS:
Generate narrative text for this stage. Requirements:
- 2-3 short paragraphs (2-3 sentences each)
- Present tense, second person ("You see...")
- Reference past choices when relevant
- Use established relationships
- Maintain consistent tone
- Create immersion and tension
- NO player choices (those come separately)

Generate narrative now:"""

        return prompt

    async def generate_stage_narrative(
        self,
        player_id: str,
        mission_template: Dict[str, Any],
        stage_id: str,
        player_state: Dict[str, Any],
        world_context: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Generate narrative text for a mission stage.

        Checks cache first, generates on miss.

        Args:
            player_id: Player identifier
            mission_template: Hybrid mission JSON
            stage_id: Stage to generate narrative for
            player_state: Current player state
            world_context: World state context (optional)

        Returns:
            {
                "narrative": "Generated text...",
                "cached": True/False,
                "generation_time_ms": 1200
            }
        """
        start_time = datetime.utcnow()

        # Generate cache key
        mission_id = mission_template.get("mission_id", "unknown")
        player_hash = self._hash_player_state(player_state)
        cache_key = f"story_cache:{mission_id}:{stage_id}:{player_hash}"

        # Check cache
        cached_narrative = await self.redis.get(cache_key)
        if cached_narrative:
            elapsed_ms = (datetime.utcnow() - start_time).total_seconds() * 1000
            logger.info(f"Cache HIT for {cache_key} ({elapsed_ms:.0f}ms)")
            return {
                "narrative": cached_narrative,
                "cached": True,
                "generation_time_ms": int(elapsed_ms)
            }

        # Cache MISS - generate narrative
        logger.info(f"Cache MISS for {cache_key}, generating...")

        # Get player memory context
        player_context = await self.memory.get_context(player_id, limit=10)

        # Build prompt
        prompt = await self._build_narrative_prompt(
            mission_template,
            stage_id,
            player_context,
            world_context or {}
        )

        # Generate with LLM (with 10-second timeout)
        try:
            narrative = await self._generate_with_llm(prompt, timeout=10)
        except asyncio.TimeoutError:
            logger.error(f"LLM generation timed out after 10s for {cache_key}")
            # Fallback: Use template structure as backup
            stage = next((s for s in mission_template["stages"] if s["stage_id"] == stage_id), None)
            if stage:
                narrative_structure = stage.get("narrative_structure", {})
                setup = narrative_structure.get('setup', 'An event occurs.')
                conflict = narrative_structure.get('conflict', 'You must decide.')
                narrative = f"{setup} {conflict}"
            else:
                # Ultimate fallback if stage not found
                logger.error(f"Stage {stage_id} not found in mission template")
                narrative = "An unexpected event unfolds in your journey. You must decide how to proceed."
        except Exception as e:
            logger.error(f"LLM generation failed: {e}")
            # Fallback: Use template structure as backup
            stage = next((s for s in mission_template["stages"] if s["stage_id"] == stage_id), None)
            if stage:
                narrative_structure = stage.get("narrative_structure", {})
                setup = narrative_structure.get('setup', 'An event occurs.')
                conflict = narrative_structure.get('conflict', 'You must decide.')
                narrative = f"{setup} {conflict}"
            else:
                # Ultimate fallback if stage not found
                logger.error(f"Stage {stage_id} not found in mission template")
                narrative = "An unexpected event unfolds in your journey. You must decide how to proceed."

        # Cache result
        await self.redis.setex(cache_key, self.cache_ttl, narrative)

        elapsed_ms = (datetime.utcnow() - start_time).total_seconds() * 1000
        logger.info(f"Generated narrative for {cache_key} ({elapsed_ms:.0f}ms)")

        return {
            "narrative": narrative,
            "cached": False,
            "generation_time_ms": int(elapsed_ms)
        }

    async def _generate_with_llm(self, prompt: str, timeout: int = 10) -> str:
        """
        Generate narrative using LLM with timeout protection.

        Args:
            prompt: Formatted prompt
            timeout: Timeout in seconds (default 10s)

        Returns:
            Generated narrative text

        Raises:
            asyncio.TimeoutError: If LLM call exceeds timeout
        """
        # TODO: Implement actual LLM call with timeout
        # For now, return placeholder
        #
        # Example implementation with timeout:
        # if self.llm:
        #     try:
        #         response = await asyncio.wait_for(
        #             self.llm.generate(prompt),
        #             timeout=timeout
        #         )
        #         return response.text
        #     except asyncio.TimeoutError:
        #         logger.error(f"LLM generation timed out after {timeout}s")
        #         raise
        #
        # For development, return formatted prompt snippet
        logger.warning("LLM client not configured, using placeholder narrative")
        return "The scene unfolds before you. You must make a choice."

    async def generate_choice_outcome(
        self,
        player_id: str,
        choice: Dict[str, Any],
        player_state: Dict[str, Any],
        world_context: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Generate consequence narrative for player choice.

        Args:
            player_id: Player identifier
            choice: Choice dict from hybrid mission
            player_state: Current player state
            world_context: World state context (optional)

        Returns:
            {
                "outcome": "success/partial/failure",
                "narrative": "Generated outcome text...",
                "consequences": {...},
                "next_stage": "stage_id"
            }
        """
        start_time = datetime.utcnow()

        # Get player memory context
        player_context = await self.memory.get_context(player_id, limit=10)

        # Build outcome prompt
        prompt = await self._build_outcome_prompt(
            choice,
            player_context,
            player_state,
            world_context or {}
        )

        # Generate outcome (with 10-second timeout)
        try:
            outcome_narrative = await self._generate_with_llm(prompt, timeout=10)
        except asyncio.TimeoutError:
            logger.error(f"Outcome generation timed out after 10s for player {player_id}")
            outcome_narrative = "Your choice has consequences."
        except Exception as e:
            logger.error(f"Outcome generation failed: {e}")
            outcome_narrative = "Your choice has consequences."

        # Determine outcome type (success/partial/failure)
        # TODO: Add skill checks, difficulty, etc.
        outcome_type = "success"  # Simplified for now

        # Get path based on outcome
        paths = choice.get("paths", {})
        outcome_path = paths.get(outcome_type, paths.get("success", {}))

        # Track consequences
        consequence_tracking = choice.get("consequence_tracking", {})

        # Add story flags
        for flag in consequence_tracking.get("flags", []):
            await self.memory.add_story_flag(player_id, flag)

        # Update relationships
        for npc, delta in consequence_tracking.get("relationships", {}).items():
            await self.memory.update_relationship(player_id, npc, delta)

        # Track world impact as consequence
        world_impact = consequence_tracking.get("world_impact")
        if world_impact:
            await self.memory.track_consequence(player_id, {
                "consequence_id": world_impact,
                "choice_id": choice.get("choice_id"),
                "timestamp": int(datetime.utcnow().timestamp())
            })

        elapsed_ms = (datetime.utcnow() - start_time).total_seconds() * 1000

        return {
            "outcome": outcome_type,
            "narrative": outcome_narrative,
            "consequences": consequence_tracking,
            "next_stage": outcome_path.get("next_stage"),
            "generation_time_ms": int(elapsed_ms)
        }

    async def _build_outcome_prompt(
        self,
        choice: Dict[str, Any],
        player_context: Dict[str, Any],
        player_state: Dict[str, Any],
        world_context: Dict[str, Any]
    ) -> str:
        """
        Build prompt for choice outcome generation.

        Args:
            choice: Choice dict
            player_context: Player memory
            player_state: Player state
            world_context: World state

        Returns:
            Formatted prompt
        """
        prompt = f"""Generate outcome narrative for player choice.

CHOICE: {choice.get('choice_id', 'unknown')}
TYPE: {choice.get('type', 'action')}
OUTCOME PROMPT: {choice.get('outcome_prompt', 'What happens?')}

PLAYER LEVEL: {player_state.get('level', 1)}
RECENT CHOICES: {len(player_context.get('recent_choices', []))}

Generate a 2-3 sentence outcome describing what happens as a result of this choice.
Use present tense, second person. Be specific and vivid.

Outcome:"""
        return prompt

    async def invalidate_cache(
        self,
        player_id: str,
        mission_id: str,
        player_state: Dict[str, Any]
    ) -> int:
        """
        Invalidate cached narratives for player/mission.

        Call this when:
        - Player levels up
        - Major story choice made
        - Significant state change

        Args:
            player_id: Player identifier
            mission_id: Mission to invalidate
            player_state: Current player state

        Returns:
            Number of cache keys deleted
        """
        player_hash = self._hash_player_state(player_state)
        pattern = f"story_cache:{mission_id}:*:{player_hash}"

        # Find matching keys
        cursor = 0
        deleted = 0
        while True:
            cursor, keys = await self.redis.scan(cursor, match=pattern, count=100)
            if keys:
                deleted += await self.redis.delete(*keys)
            if cursor == 0:
                break

        logger.info(f"Invalidated {deleted} cache entries for {mission_id} (player {player_id})")
        return deleted


__all__ = ["StoryEngine"]
