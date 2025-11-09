"""
Memory Manager - Player Story State Tracking

Tracks player choices, relationships, consequences, and story arcs in Redis.
This provides context for contextual narrative generation.

Redis Schema:
- player_choices:{player_id} - List (FIFO, max 100 choices)
- player_relationships:{player_id} - Hash (NPC name → score -100 to +100)
- player_consequences:{player_id} - List (unresolved consequences for callbacks)
- player_story:{player_id} - Hash (current mission, story arc, flags)
"""

import json
import logging
from typing import Dict, List, Any, Optional
from datetime import datetime
import redis.asyncio as redis

logger = logging.getLogger(__name__)


class MemoryManager:
    """
    Manages player story memory in Redis.

    Tracks:
    - Last 100 player choices (FIFO)
    - NPC/faction relationships (-100 to +100)
    - Unresolved consequences (for future callbacks)
    - Story state (current mission, arc, flags)
    """

    def __init__(self, redis_client: redis.Redis):
        """
        Initialize memory manager.

        Args:
            redis_client: Async Redis client
        """
        self.redis = redis_client
        self.max_choices = 100  # Keep last 100 choices

    async def add_choice(
        self,
        player_id: str,
        choice: Dict[str, Any]
    ) -> None:
        """
        Record player choice (maintains FIFO list of last 100).

        Args:
            player_id: Player identifier
            choice: Choice data
                {
                    "choice_id": "investigate",
                    "mission_id": "tutorial_shipyard",
                    "stage_id": "stage_1",
                    "timestamp": 1699564320,
                    "outcome": "success",
                    "consequences": {...}
                }
        """
        key = f"player_choices:{player_id}"

        # Add timestamp if not present
        if "timestamp" not in choice:
            choice["timestamp"] = int(datetime.utcnow().timestamp())

        # Push to list (right side = newest)
        await self.redis.rpush(key, json.dumps(choice))

        # Trim to max size (keep last 100)
        await self.redis.ltrim(key, -self.max_choices, -1)

        logger.debug(f"Recorded choice for player {player_id}: {choice['choice_id']}")

    async def get_choices(
        self,
        player_id: str,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """
        Get recent player choices.

        Args:
            player_id: Player identifier
            limit: Number of recent choices to return (default 10)

        Returns:
            List of choice dicts (most recent first)
        """
        key = f"player_choices:{player_id}"

        # Get last N choices
        choices_json = await self.redis.lrange(key, -limit, -1)

        # Parse JSON and reverse (most recent first)
        choices = [json.loads(c) for c in choices_json]
        choices.reverse()

        logger.debug(f"Retrieved {len(choices)} choices for player {player_id}")
        return choices

    async def update_relationship(
        self,
        player_id: str,
        character: str,
        delta: int
    ) -> int:
        """
        Update relationship score with NPC/faction.

        Args:
            player_id: Player identifier
            character: NPC or faction name
            delta: Change in relationship (-100 to +100)

        Returns:
            New relationship score (clamped to -100 to +100)
        """
        key = f"player_relationships:{player_id}"

        # Get current score (default 0)
        current = await self.redis.hget(key, character)
        current_score = int(current) if current else 0

        # Calculate new score (clamped)
        new_score = max(-100, min(100, current_score + delta))

        # Update in Redis
        await self.redis.hset(key, character, new_score)

        logger.debug(
            f"Updated relationship {character} for player {player_id}: "
            f"{current_score} → {new_score} (delta: {delta:+d})"
        )

        return new_score

    async def get_relationships(
        self,
        player_id: str
    ) -> Dict[str, int]:
        """
        Get all relationship scores for player.

        Args:
            player_id: Player identifier

        Returns:
            Dict mapping character names to scores
        """
        key = f"player_relationships:{player_id}"

        relationships_raw = await self.redis.hgetall(key)

        # Convert to int scores
        relationships = {
            name: int(score)
            for name, score in relationships_raw.items()
        }

        logger.debug(f"Retrieved {len(relationships)} relationships for player {player_id}")
        return relationships

    async def track_consequence(
        self,
        player_id: str,
        consequence: Dict[str, Any]
    ) -> None:
        """
        Track consequence for future callback.

        Args:
            player_id: Player identifier
            consequence: Consequence data
                {
                    "consequence_id": "shipyard_collapse_risk",
                    "mission_id": "tutorial_shipyard",
                    "timestamp": 1699564320,
                    "can_callback_after": 3,  # missions
                    "resolved": false
                }
        """
        key = f"player_consequences:{player_id}"

        # Add timestamp if not present
        if "timestamp" not in consequence:
            consequence["timestamp"] = int(datetime.utcnow().timestamp())

        # Default to unresolved
        if "resolved" not in consequence:
            consequence["resolved"] = False

        # Add to list
        await self.redis.rpush(key, json.dumps(consequence))

        logger.debug(
            f"Tracked consequence for player {player_id}: "
            f"{consequence.get('consequence_id', 'unknown')}"
        )

    async def get_active_consequences(
        self,
        player_id: str
    ) -> List[Dict[str, Any]]:
        """
        Get unresolved consequences.

        Args:
            player_id: Player identifier

        Returns:
            List of unresolved consequence dicts
        """
        key = f"player_consequences:{player_id}"

        # Get all consequences
        consequences_json = await self.redis.lrange(key, 0, -1)

        # Parse and filter for unresolved
        consequences = [json.loads(c) for c in consequences_json]
        active = [c for c in consequences if not c.get("resolved", False)]

        logger.debug(f"Retrieved {len(active)} active consequences for player {player_id}")
        return active

    async def resolve_consequence(
        self,
        player_id: str,
        consequence_id: str
    ) -> bool:
        """
        Mark consequence as resolved.

        Args:
            player_id: Player identifier
            consequence_id: Consequence to resolve

        Returns:
            True if found and resolved, False if not found
        """
        key = f"player_consequences:{player_id}"

        # Get all consequences
        consequences_json = await self.redis.lrange(key, 0, -1)
        if not consequences_json:
            logger.warning(f"No consequences found for player {player_id}")
            return False

        consequences = [json.loads(c) for c in consequences_json]

        # Find and mark as resolved
        found = False
        for consequence in consequences:
            if consequence.get("consequence_id") == consequence_id:
                consequence["resolved"] = True
                found = True
                break

        if found:
            # Use pipeline for atomic batch operation (more efficient than individual commands)
            pipe = self.redis.pipeline()
            pipe.delete(key)
            for consequence in consequences:
                pipe.rpush(key, json.dumps(consequence))
            await pipe.execute()

            logger.debug(f"Resolved consequence {consequence_id} for player {player_id}")
        else:
            logger.warning(f"Consequence {consequence_id} not found for player {player_id}")

        return found

    async def update_story_state(
        self,
        player_id: str,
        **kwargs: Any
    ) -> None:
        """
        Update player story state fields.

        Args:
            player_id: Player identifier
            **kwargs: Fields to update (current_mission, story_arc, etc.)
        """
        key = f"player_story:{player_id}"

        if kwargs:
            # Convert all values to strings for Redis hash
            fields = {k: str(v) for k, v in kwargs.items()}
            await self.redis.hset(key, mapping=fields)

            logger.debug(f"Updated story state for player {player_id}: {list(kwargs.keys())}")

    async def get_story_state(
        self,
        player_id: str
    ) -> Dict[str, str]:
        """
        Get player story state.

        Args:
            player_id: Player identifier

        Returns:
            Dict of story state fields
        """
        key = f"player_story:{player_id}"

        state = await self.redis.hgetall(key)

        logger.debug(f"Retrieved story state for player {player_id}")
        return state

    async def add_story_flag(
        self,
        player_id: str,
        flag: str
    ) -> None:
        """
        Add story flag to player.

        Args:
            player_id: Player identifier
            flag: Flag to add (e.g., "cautious_explorer")
        """
        key = f"player_story:{player_id}"

        # Get existing flags
        flags_json = await self.redis.hget(key, "flags")
        flags = json.loads(flags_json) if flags_json else []

        # Add if not present
        if flag not in flags:
            flags.append(flag)
            await self.redis.hset(key, "flags", json.dumps(flags))
            logger.debug(f"Added flag '{flag}' for player {player_id}")

    async def has_story_flag(
        self,
        player_id: str,
        flag: str
    ) -> bool:
        """
        Check if player has story flag.

        Args:
            player_id: Player identifier
            flag: Flag to check

        Returns:
            True if player has flag
        """
        key = f"player_story:{player_id}"

        flags_json = await self.redis.hget(key, "flags")
        flags = json.loads(flags_json) if flags_json else []

        return flag in flags

    async def get_context(
        self,
        player_id: str,
        limit: int = 10
    ) -> Dict[str, Any]:
        """
        Build comprehensive context for narrative generation.

        Includes:
        - Recent choices (last N)
        - All relationships
        - Active consequences
        - Story state

        Args:
            player_id: Player identifier
            limit: Number of recent choices to include

        Returns:
            Context dict with all player memory data
        """
        context = {
            "recent_choices": await self.get_choices(player_id, limit),
            "relationships": await self.get_relationships(player_id),
            "active_consequences": await self.get_active_consequences(player_id),
            "story_state": await self.get_story_state(player_id)
        }

        logger.info(
            f"Built context for player {player_id}: "
            f"{len(context['recent_choices'])} choices, "
            f"{len(context['relationships'])} relationships, "
            f"{len(context['active_consequences'])} consequences"
        )

        return context


__all__ = ["MemoryManager"]
