"""
Mission Queue Manager using Redis.

Implements smart mission pre-generation and queueing:
- Pre-generate missions during downtime
- Store in Redis for instant retrieval
- Track generation statistics
- Automatic queue replenishment
"""

import os
import logging
import json
import asyncio
from typing import Optional, Dict, Any, List
import redis.asyncio as redis
from datetime import timedelta

logger = logging.getLogger(__name__)


class MissionQueue:
    """
    Redis-backed mission queue for AI-first architecture.

    Maintains a queue of pre-generated missions for instant retrieval.
    """

    def __init__(self):
        """Initialize mission queue."""
        self.enabled = os.getenv("MISSION_QUEUE_ENABLED", "true").lower() == "true"

        if not self.enabled:
            logger.info("Mission queue disabled")
            self.client = None
            return

        # Connect to Redis
        redis_host = os.getenv("REDIS_HOST", "localhost")
        redis_port = int(os.getenv("REDIS_PORT", "17014"))
        redis_db = int(os.getenv("REDIS_DB", "0"))

        try:
            self.client = redis.Redis(
                host=redis_host,
                port=redis_port,
                db=redis_db,
                decode_responses=True
            )

            # Queue configuration
            self.queue_key_prefix = "mission_queue"
            self.max_queue_size = int(os.getenv("MISSION_QUEUE_SIZE", "10"))
            self.mission_ttl = timedelta(hours=int(os.getenv("MISSION_TTL_HOURS", "24")))

            logger.info(
                f"Mission queue initialized (max size: {self.max_queue_size}, "
                f"TTL: {self.mission_ttl.total_seconds() / 3600}h)"
            )

        except Exception as e:
            logger.error(f"Failed to initialize mission queue: {e}")
            self.enabled = False
            self.client = None

    def _get_queue_key(self, difficulty: str, mission_type: str) -> str:
        """
        Get Redis key for specific mission queue.

        Args:
            difficulty: Mission difficulty (easy, medium, hard, extreme)
            mission_type: Mission type (salvage, exploration, etc.)

        Returns:
            Redis key for the queue
        """
        return f"{self.queue_key_prefix}:{difficulty}:{mission_type}"

    async def push_mission(
        self,
        mission: Dict[str, Any],
        difficulty: str,
        mission_type: str
    ) -> bool:
        """
        Add a pre-generated mission to the queue.

        Args:
            mission: Mission data (dict)
            difficulty: Mission difficulty
            mission_type: Mission type

        Returns:
            True if added, False otherwise
        """
        if not self.enabled or not self.client:
            return False

        try:
            queue_key = self._get_queue_key(difficulty, mission_type)

            # Check queue size
            current_size = await self.client.llen(queue_key)
            if current_size >= self.max_queue_size:
                logger.debug(
                    f"Queue full for {difficulty}/{mission_type} "
                    f"({current_size}/{self.max_queue_size})"
                )
                return False

            # Serialize mission
            mission_json = json.dumps(mission)

            # Add to queue (right side = newest)
            await self.client.rpush(queue_key, mission_json)

            # Set TTL on queue
            await self.client.expire(queue_key, self.mission_ttl)

            logger.info(
                f"Added mission to queue {difficulty}/{mission_type} "
                f"(size: {current_size + 1}/{self.max_queue_size})"
            )

            return True

        except Exception as e:
            logger.error(f"Failed to push mission to queue: {e}")
            return False

    async def pop_mission(
        self,
        difficulty: str,
        mission_type: str
    ) -> Optional[Dict[str, Any]]:
        """
        Get a pre-generated mission from the queue.

        Args:
            difficulty: Mission difficulty
            mission_type: Mission type

        Returns:
            Mission data or None if queue empty
        """
        if not self.enabled or not self.client:
            return None

        try:
            queue_key = self._get_queue_key(difficulty, mission_type)

            # Get from queue (left side = oldest)
            mission_json = await self.client.lpop(queue_key)

            if not mission_json:
                logger.debug(f"Queue empty for {difficulty}/{mission_type}")
                return None

            mission = json.loads(mission_json)

            remaining = await self.client.llen(queue_key)
            logger.info(
                f"Retrieved mission from queue {difficulty}/{mission_type} "
                f"(remaining: {remaining})"
            )

            return mission

        except Exception as e:
            logger.error(f"Failed to pop mission from queue: {e}")
            return None

    async def get_queue_size(
        self,
        difficulty: str,
        mission_type: str
    ) -> int:
        """
        Get current size of mission queue.

        Args:
            difficulty: Mission difficulty
            mission_type: Mission type

        Returns:
            Number of missions in queue
        """
        if not self.enabled or not self.client:
            return 0

        try:
            queue_key = self._get_queue_key(difficulty, mission_type)
            size = await self.client.llen(queue_key)
            return size

        except Exception as e:
            logger.error(f"Failed to get queue size: {e}")
            return 0

    async def get_all_queue_stats(self) -> Dict[str, int]:
        """
        Get statistics for all mission queues.

        Returns:
            Dictionary of queue keys and their sizes
        """
        if not self.enabled or not self.client:
            return {}

        try:
            stats = {}

            # Find all queue keys
            cursor = 0
            while True:
                cursor, keys = await self.client.scan(
                    cursor,
                    match=f"{self.queue_key_prefix}:*",
                    count=100
                )

                for key in keys:
                    size = await self.client.llen(key)
                    # Extract difficulty/type from key
                    parts = key.split(":")
                    if len(parts) >= 3:
                        queue_name = f"{parts[1]}/{parts[2]}"
                        stats[queue_name] = size

                if cursor == 0:
                    break

            return stats

        except Exception as e:
            logger.error(f"Failed to get queue stats: {e}")
            return {}

    async def needs_replenishment(
        self,
        difficulty: str,
        mission_type: str,
        threshold: float = 0.3
    ) -> bool:
        """
        Check if queue needs replenishment.

        Args:
            difficulty: Mission difficulty
            mission_type: Mission type
            threshold: Replenish when below this percentage (0.0-1.0)

        Returns:
            True if queue should be replenished
        """
        current_size = await self.get_queue_size(difficulty, mission_type)
        min_size = int(self.max_queue_size * threshold)

        return current_size < min_size

    async def clear_queue(
        self,
        difficulty: Optional[str] = None,
        mission_type: Optional[str] = None
    ):
        """
        Clear mission queue(s).

        Args:
            difficulty: Specific difficulty (or all if None)
            mission_type: Specific type (or all if None)
        """
        if not self.enabled or not self.client:
            return

        try:
            if difficulty and mission_type:
                # Clear specific queue
                queue_key = self._get_queue_key(difficulty, mission_type)
                await self.client.delete(queue_key)
                logger.info(f"Cleared queue {difficulty}/{mission_type}")
            else:
                # Clear all queues
                cursor = 0
                deleted_count = 0

                while True:
                    cursor, keys = await self.client.scan(
                        cursor,
                        match=f"{self.queue_key_prefix}:*",
                        count=100
                    )

                    if keys:
                        deleted = await self.client.delete(*keys)
                        deleted_count += deleted

                    if cursor == 0:
                        break

                logger.info(f"Cleared {deleted_count} mission queues")

        except Exception as e:
            logger.error(f"Failed to clear queue: {e}")


# Global mission queue instance
_mission_queue: Optional[MissionQueue] = None


def get_mission_queue() -> MissionQueue:
    """Get or create global mission queue instance."""
    global _mission_queue
    if _mission_queue is None:
        _mission_queue = MissionQueue()
    return _mission_queue
