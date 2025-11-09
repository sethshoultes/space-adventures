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
        Generate simple mission template.

        Args:
            mission_type: salvage/exploration/trade
            difficulty: easy/medium/hard/extreme

        Returns:
            Mission dict
        """
        # For now, return template-based missions
        # TODO: Enhance with LLM generation

        timestamp = int(datetime.utcnow().timestamp())

        if mission_type == "salvage":
            return {
                "mission_id": f"salvage_{timestamp}",
                "title": "Salvage Operation",
                "type": "salvage",
                "difficulty": difficulty,
                "description": "Recover valuable parts from a derelict ship.",
                "location": "Debris Field",
                "rewards": {
                    "credits": self._calculate_reward(difficulty),
                    "items": ["salvaged_parts"]
                }
            }
        elif mission_type == "exploration":
            return {
                "mission_id": f"exploration_{timestamp}",
                "title": "Survey Mission",
                "type": "exploration",
                "difficulty": difficulty,
                "description": "Map an uncharted sector for navigation data.",
                "location": "Unknown Sector",
                "rewards": {
                    "credits": self._calculate_reward(difficulty),
                    "items": ["nav_data"]
                }
            }
        else:  # trade
            return {
                "mission_id": f"trade_{timestamp}",
                "title": "Cargo Run",
                "type": "trade",
                "difficulty": difficulty,
                "description": "Transport cargo between stations.",
                "location": "Trade Route",
                "rewards": {
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
