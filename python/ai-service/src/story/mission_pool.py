"""
Mission Pool - Lazy Queue for Generic Side Missions

Level 3 (Lazy Queue) implementation for reusable side content.

Maintains a small queue (2-3 missions) per difficulty, filled reactively
when queue runs low. No scheduled pre-generation - only generates when needed.

Use Cases:
- Generic salvage missions
- Simple exploration encounters
- Basic trade runs
- Filler content between story missions
"""

import json
import logging
from typing import Dict, List, Any, Optional
from datetime import datetime
import redis.asyncio as redis

logger = logging.getLogger(__name__)


class MissionPool:
    """
    Lazy queue for generic side missions (Level 3).

    Behavior:
    - Keep 2-3 missions per difficulty in queue
    - Generate reactively when queue runs low (<2)
    - No scheduled tasks (fill only when requested)
    - Simple mission templates (no player context)
    - 24 hour TTL (missions can expire)
    """

    def __init__(
        self,
        redis_client: redis.Redis,
        llm_client: Any,
        queue_size: int = 3,
        min_threshold: int = 2
    ):
        """
        Initialize mission pool.

        Args:
            redis_client: Async Redis client
            llm_client: LLM client for generation
            queue_size: Max missions per queue (default 3)
            min_threshold: Minimum before refilling (default 2)
        """
        self.redis = redis_client
        self.llm = llm_client
        self.queue_size = queue_size
        self.min_threshold = min_threshold
        self.difficulties = ["easy", "medium", "hard", "extreme"]
        self.ttl = 24 * 3600  # 24 hours

    async def get_mission(
        self,
        difficulty: str = "medium"
    ) -> Dict[str, Any]:
        """
        Get mission from queue (generates if empty).

        Args:
            difficulty: Mission difficulty

        Returns:
            {
                "mission": {...},
                "source": "queue" or "generated",
                "queue_count": 2
            }
        """
        # Validate difficulty
        if difficulty not in self.difficulties:
            difficulty = "medium"

        key = f"mission_pool:{difficulty}"

        # Try to pop from queue
        mission_json = await self.redis.lpop(key)

        if mission_json:
            # Queue hit
            mission = json.loads(mission_json)
            queue_count = await self.redis.llen(key)

            logger.info(f"Queue HIT for {difficulty} mission ({queue_count} remaining)")

            # Refill if low
            if queue_count < self.min_threshold:
                await self._fill_queue_if_low(difficulty)

            return {
                "mission": mission,
                "source": "queue",
                "queue_count": queue_count
            }
        else:
            # Queue miss - generate immediately
            logger.info(f"Queue MISS for {difficulty} mission, generating...")

            mission = await self._generate_generic_mission(difficulty)

            # Also fill queue for next time
            await self._fill_queue_if_low(difficulty)

            return {
                "mission": mission,
                "source": "generated",
                "queue_count": 0
            }

    async def _fill_queue_if_low(
        self,
        difficulty: str
    ) -> int:
        """
        Reactively fill queue if below threshold.

        Args:
            difficulty: Mission difficulty

        Returns:
            Number of missions generated
        """
        key = f"mission_pool:{difficulty}"

        # Check current count
        current_count = await self.redis.llen(key)

        if current_count >= self.queue_size:
            logger.debug(f"Queue for {difficulty} is full ({current_count}/{self.queue_size})")
            return 0

        # Generate missions to fill queue
        to_generate = self.queue_size - current_count
        logger.info(f"Filling queue for {difficulty}: generating {to_generate} missions")

        generated = 0
        for _ in range(to_generate):
            mission = await self._generate_generic_mission(difficulty)
            mission_json = json.dumps(mission)

            # Add to queue (right side = newest)
            await self.redis.rpush(key, mission_json)
            generated += 1

        # Set TTL on queue
        await self.redis.expire(key, self.ttl)

        logger.info(f"Generated {generated} missions for {difficulty} queue")
        return generated

    async def _generate_generic_mission(
        self,
        difficulty: str
    ) -> Dict[str, Any]:
        """
        Generate simple generic mission.

        Args:
            difficulty: Mission difficulty

        Returns:
            Mission dict (simple template)
        """
        # Mission types for generic content
        mission_types = ["salvage", "exploration", "trade"]
        import random
        mission_type = random.choice(mission_types)

        # Simple template generation (no player context)
        # TODO: Replace with LLM generation
        mission = await self._generate_simple_template(mission_type, difficulty)

        return mission

    async def _generate_simple_template(
        self,
        mission_type: str,
        difficulty: str
    ) -> Dict[str, Any]:
        """
        Generate full hybrid mission with AI.

        Args:
            mission_type: salvage/exploration/trade
            difficulty: easy/medium/hard/extreme

        Returns:
            Full hybrid mission dict with stages, choices, narrative_structure
        """
        timestamp = int(datetime.utcnow().timestamp())
        mission_id = f"{mission_type}_{timestamp}"

        # Generate mission using AI
        if self.llm:
            try:
                mission = await self._generate_mission_with_ai(
                    mission_id, mission_type, difficulty
                )
                return mission
            except Exception as e:
                logger.error(f"AI generation failed: {e}, falling back to template")

        # Fallback: Generate template-based hybrid mission
        return self._create_template_hybrid_mission(mission_id, mission_type, difficulty)

    async def _generate_mission_with_ai(
        self,
        mission_id: str,
        mission_type: str,
        difficulty: str
    ) -> Dict[str, Any]:
        """
        Generate full hybrid mission using AI.

        Args:
            mission_id: Unique mission ID
            mission_type: salvage/exploration/trade
            difficulty: easy/medium/hard/extreme

        Returns:
            Full hybrid mission dict
        """
        from ..ai.client import AITaskType
        import asyncio

        # Build AI prompt for mission generation
        prompt = f"""Generate a {difficulty} difficulty {mission_type} mission for Space Adventures.

MISSION TYPE: {mission_type}
DIFFICULTY: {difficulty}

REQUIREMENTS:
1. Create 3-5 stages with branching narrative
2. Each stage has 2-3 meaningful choices
3. Choices have success/failure outcomes
4. Include narrative_structure for each stage (setup, conflict, tone, prompt)
5. Include outcome_prompt for each choice
6. Set appropriate context (location, theme, tone, key NPCs)

TONE: Serious sci-fi, Star Trek TNG style (ethical dilemmas, exploration themes)

CONSTRAINTS:
- Each stage: 2-3 sentences of narrative
- Choices: Clear player agency, visible consequences
- Outcomes: Success/partial success/failure paths
- Rewards: {self._calculate_reward(difficulty)} credits + relevant items

Generate a complete hybrid mission JSON following this format:
{{
  "mission_id": "{mission_id}",
  "title": "Mission Title",
  "type": "{mission_type}",
  "difficulty": "{difficulty}",
  "description": "Brief mission overview",
  "context": {{
    "location": "Specific location",
    "theme": "Mission theme",
    "tone": "Serious sci-fi",
    "key_npcs": [
      {{"id": "npc1", "name": "NPC Name", "role": "Their role", "personality": "Brief description"}}
    ]
  }},
  "stages": [
    {{
      "stage_id": "arrival",
      "title": "Stage Title",
      "narrative_structure": {{
        "setup": "What's happening",
        "conflict": "The challenge",
        "tone": "Emotional tone",
        "prompt": "AI generation instructions",
        "include": ["Key elements to include"],
        "exclude": ["Things to avoid"]
      }},
      "choices": [
        {{
          "choice_id": "choice1",
          "text": "Player choice text",
          "type": "action/dialogue/technical",
          "outcome_prompt": {{
            "success": {{
              "setup": "What happens on success",
              "key_elements": ["Important story beats"],
              "tone": "Emotional response",
              "length": "2-3 sentences"
            }},
            "failure": {{
              "setup": "What happens on failure",
              "key_elements": ["Story beats"],
              "tone": "Tone",
              "length": "2-3 sentences"
            }}
          }},
          "paths": {{
            "success": {{"next_stage": "stage2"}},
            "failure": {{"next_stage": "stage2_alt"}}
          }},
          "consequence_tracking": {{
            "flags": ["mission_flag"],
            "relationships": {{"npc1": 10}},
            "world_impact": "impact_id"
          }}
        }}
      ]
    }}
  ],
  "rewards": {{
    "xp": 100,
    "credits": {self._calculate_reward(difficulty)},
    "items": ["relevant_item"]
  }}
}}

Generate complete mission now:"""

        try:
            response = await asyncio.wait_for(
                self.llm.generate(
                    task_type=AITaskType.RANDOM_MISSION,
                    prompt=prompt,
                    system="You are a mission designer for Space Adventures. Generate complete hybrid missions in JSON format."
                ),
                timeout=30  # 30 second timeout for mission generation
            )

            # Parse JSON response
            import json
            mission = json.loads(response)

            # Validate has required fields
            if not all(k in mission for k in ["mission_id", "title", "stages", "context"]):
                raise ValueError("Mission missing required fields")

            logger.info(f"Generated AI mission: {mission['title']} ({len(mission['stages'])} stages)")
            return mission

        except asyncio.TimeoutError:
            logger.error("Mission generation timed out after 30s")
            raise
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse mission JSON: {e}")
            raise
        except Exception as e:
            logger.error(f"Mission generation failed: {e}")
            raise

    def _create_template_hybrid_mission(
        self,
        mission_id: str,
        mission_type: str,
        difficulty: str
    ) -> Dict[str, Any]:
        """
        Create template-based hybrid mission as fallback.

        Args:
            mission_id: Unique mission ID
            mission_type: salvage/exploration/trade
            difficulty: easy/medium/hard/extreme

        Returns:
            Basic hybrid mission dict
        """
        # Create basic hybrid mission structure
        if mission_type == "salvage":
            return {
                "mission_id": mission_id,
                "title": "Salvage Operation",
                "type": "salvage",
                "difficulty": difficulty,
                "description": "Recover valuable parts from a derelict ship.",
                "context": {
                    "location": "Debris Field Alpha-7",
                    "theme": "Resource recovery",
                    "tone": "Serious, cautious",
                    "key_npcs": [
                        {
                            "id": "salvage_lead",
                            "name": "Maya Chen",
                            "role": "Salvage Team Leader",
                            "personality": "Pragmatic, risk-averse"
                        }
                    ]
                },
                "stages": [
                    {
                        "stage_id": "arrival",
                        "title": "Approach the Derelict",
                        "narrative_structure": {
                            "setup": "You approach a derelict ship floating in the debris field",
                            "conflict": "The ship's systems are unstable",
                            "tone": "Tense, cautious",
                            "prompt": "Describe approaching the damaged ship in the debris field",
                            "include": ["Visual damage", "Hazards", "Salvage potential"],
                            "exclude": ["Combat", "Aliens"]
                        },
                        "choices": [
                            {
                                "choice_id": "careful_approach",
                                "text": "Approach carefully, scan for hazards",
                                "type": "technical",
                                "outcome_prompt": {
                                    "success": {
                                        "setup": "Your careful scan reveals safe entry points",
                                        "key_elements": ["Safe docking", "Valuable parts identified"],
                                        "tone": "Relieved, professional",
                                        "length": "2-3 sentences"
                                    }
                                },
                                "paths": {
                                    "success": {"next_stage": "salvage_complete"}
                                },
                                "consequence_tracking": {
                                    "flags": ["careful_approach"],
                                    "relationships": {"salvage_lead": 5}
                                }
                            },
                            {
                                "choice_id": "quick_approach",
                                "text": "Move quickly before other salvagers arrive",
                                "type": "action",
                                "outcome_prompt": {
                                    "success": {
                                        "setup": "You reach the ship first and secure valuable parts",
                                        "key_elements": ["Quick salvage", "Risk paid off"],
                                        "tone": "Triumphant",
                                        "length": "2-3 sentences"
                                    }
                                },
                                "paths": {
                                    "success": {"next_stage": "salvage_complete"}
                                },
                                "consequence_tracking": {
                                    "flags": ["risky_approach"],
                                    "relationships": {"salvage_lead": -5}
                                }
                            }
                        ]
                    },
                    {
                        "stage_id": "salvage_complete",
                        "title": "Mission Complete",
                        "narrative_structure": {
                            "setup": "You've recovered valuable parts from the derelict",
                            "conflict": "None",
                            "tone": "Satisfied, accomplished",
                            "prompt": "Describe completing the salvage operation",
                            "include": ["Parts recovered", "Team satisfaction"],
                            "exclude": []
                        },
                        "choices": []
                    }
                ],
                "rewards": {
                    "xp": 50,
                    "credits": self._calculate_reward(difficulty),
                    "items": ["salvaged_parts"]
                }
            }
        elif mission_type == "exploration":
            return {
                "mission_id": mission_id,
                "title": "Survey Mission",
                "type": "exploration",
                "difficulty": difficulty,
                "description": "Map an uncharted sector for navigation data.",
                "context": {
                    "location": "Sector Unknown-42",
                    "theme": "Exploration",
                    "tone": "Wonder, scientific",
                    "key_npcs": [
                        {
                            "id": "science_officer",
                            "name": "Dr. James Park",
                            "role": "Science Officer",
                            "personality": "Curious, thorough"
                        }
                    ]
                },
                "stages": [
                    {
                        "stage_id": "survey",
                        "title": "Begin Survey",
                        "narrative_structure": {
                            "setup": "You enter an uncharted sector",
                            "conflict": "Unknown phenomena detected",
                            "tone": "Curious, alert",
                            "prompt": "Describe discovering something unexpected in the sector",
                            "include": ["Sensor readings", "Unknown phenomenon"],
                            "exclude": ["Combat", "Aliens"]
                        },
                        "choices": [
                            {
                                "choice_id": "investigate",
                                "text": "Investigate the phenomenon",
                                "type": "action",
                                "outcome_prompt": {
                                    "success": {
                                        "setup": "Your investigation reveals valuable scientific data",
                                        "key_elements": ["Discovery", "Scientific value"],
                                        "tone": "Excited, satisfied",
                                        "length": "2-3 sentences"
                                    }
                                },
                                "paths": {
                                    "success": {"next_stage": "mission_complete"}
                                },
                                "consequence_tracking": {
                                    "flags": ["thorough_survey"],
                                    "relationships": {"science_officer": 10}
                                }
                            }
                        ]
                    },
                    {
                        "stage_id": "mission_complete",
                        "title": "Survey Complete",
                        "narrative_structure": {
                            "setup": "Your survey is complete with valuable data",
                            "conflict": "None",
                            "tone": "Accomplished",
                            "prompt": "Describe completing the survey mission",
                            "include": ["Data collected", "Scientific achievement"],
                            "exclude": []
                        },
                        "choices": []
                    }
                ],
                "rewards": {
                    "xp": 50,
                    "credits": self._calculate_reward(difficulty),
                    "items": ["nav_data"]
                }
            }
        else:  # trade
            return {
                "mission_id": mission_id,
                "title": "Cargo Run",
                "type": "trade",
                "difficulty": difficulty,
                "description": "Transport cargo between stations.",
                "context": {
                    "location": "Trade Route Epsilon",
                    "theme": "Commerce",
                    "tone": "Business, pragmatic",
                    "key_npcs": [
                        {
                            "id": "merchant",
                            "name": "Captain Torres",
                            "role": "Merchant",
                            "personality": "Shrewd, business-minded"
                        }
                    ]
                },
                "stages": [
                    {
                        "stage_id": "delivery",
                        "title": "Deliver Cargo",
                        "narrative_structure": {
                            "setup": "You transport valuable cargo",
                            "conflict": "Tight deadline",
                            "tone": "Tense, time-pressure",
                            "prompt": "Describe making the cargo delivery",
                            "include": ["Cargo value", "Time pressure"],
                            "exclude": ["Combat", "Pirates"]
                        },
                        "choices": [
                            {
                                "choice_id": "deliver",
                                "text": "Complete the delivery",
                                "type": "action",
                                "outcome_prompt": {
                                    "success": {
                                        "setup": "You deliver the cargo on time",
                                        "key_elements": ["Successful delivery", "Payment received"],
                                        "tone": "Satisfied, professional",
                                        "length": "2-3 sentences"
                                    }
                                },
                                "paths": {
                                    "success": {"next_stage": "mission_complete"}
                                },
                                "consequence_tracking": {
                                    "flags": ["reliable_trader"],
                                    "relationships": {"merchant": 10}
                                }
                            }
                        ]
                    },
                    {
                        "stage_id": "mission_complete",
                        "title": "Delivery Complete",
                        "narrative_structure": {
                            "setup": "Cargo delivered successfully",
                            "conflict": "None",
                            "tone": "Professional, satisfied",
                            "prompt": "Describe completing the trade run",
                            "include": ["Payment", "Reputation boost"],
                            "exclude": []
                        },
                        "choices": []
                    }
                ],
                "rewards": {
                    "xp": 50,
                    "credits": self._calculate_reward(difficulty)
                }
            }

    def _calculate_reward(self, difficulty: str) -> int:
        """Calculate credit reward based on difficulty."""
        rewards = {
            "easy": 100,
            "medium": 250,
            "hard": 500,
            "extreme": 1000
        }
        return rewards.get(difficulty, 250)

    async def count_available(
        self,
        difficulty: Optional[str] = None
    ) -> Dict[str, int]:
        """
        Count missions in queue(s).

        Args:
            difficulty: Specific difficulty, or None for all

        Returns:
            Dict mapping difficulty to count
        """
        if difficulty:
            key = f"mission_pool:{difficulty}"
            count = await self.redis.llen(key)
            return {difficulty: count}
        else:
            # Count all queues
            counts = {}
            for diff in self.difficulties:
                key = f"mission_pool:{diff}"
                counts[diff] = await self.redis.llen(key)
            return counts

    async def clear_queue(
        self,
        difficulty: Optional[str] = None
    ) -> int:
        """
        Clear mission queue(s).

        Args:
            difficulty: Specific difficulty, or None for all

        Returns:
            Number of missions deleted
        """
        deleted = 0

        if difficulty:
            key = f"mission_pool:{difficulty}"
            deleted = await self.redis.delete(key)
            logger.info(f"Cleared {difficulty} queue ({deleted} missions)")
        else:
            for diff in self.difficulties:
                key = f"mission_pool:{diff}"
                deleted += await self.redis.delete(key)
            logger.info(f"Cleared all queues ({deleted} missions)")

        return deleted


__all__ = ["MissionPool"]
