"""
Agent Memory Management

Redis-backed memory system for AI agents to maintain context and avoid repetition.
"""

import json
import logging
from typing import Dict, List, Any, Optional
from datetime import datetime, timedelta
import redis.asyncio as redis

logger = logging.getLogger(__name__)


class AgentMemory:
    """
    Redis-backed memory system for AI agents.

    Stores:
    - Last observations (game state snapshots)
    - Recent actions taken
    - Conversation context
    - Message timestamps for throttling
    """

    def __init__(
        self,
        agent_name: str,
        redis_client: redis.Redis,
        observation_ttl: int = 3600,
        max_observations: int = 10
    ):
        """
        Initialize agent memory

        Args:
            agent_name: Unique agent identifier
            redis_client: Redis client instance
            observation_ttl: Time-to-live for observations (seconds)
            max_observations: Maximum observations to store
        """
        self.agent_name = agent_name
        self.redis_client = redis_client
        self.observation_ttl = observation_ttl
        self.max_observations = max_observations

    def _make_key(self, key_type: str) -> str:
        """Generate Redis key for agent data"""
        return f"{self.agent_name}:{key_type}"

    async def store_observation(self, observation: str, metadata: Optional[Dict[str, Any]] = None) -> None:
        """
        Store an observation in memory

        Args:
            observation: Text description of what was observed
            metadata: Optional metadata about the observation
        """
        try:
            timestamp = datetime.now().isoformat()
            obs_data = {
                "timestamp": timestamp,
                "observation": observation,
                "metadata": metadata or {}
            }

            key = self._make_key("observations")

            # Add to list (newest first)
            await self.redis_client.lpush(key, json.dumps(obs_data))

            # Trim to max size
            await self.redis_client.ltrim(key, 0, self.max_observations - 1)

            # Set TTL
            await self.redis_client.expire(key, self.observation_ttl)

            logger.debug(f"[{self.agent_name}] Stored observation: {observation[:50]}...")

        except Exception as e:
            logger.error(f"[{self.agent_name}] Failed to store observation: {e}")

    async def get_recent_observations(self, limit: int = 5) -> List[Dict[str, Any]]:
        """
        Get recent observations from memory

        Args:
            limit: Number of observations to retrieve

        Returns:
            List of observation dictionaries (newest first)
        """
        try:
            key = self._make_key("observations")

            # Get observations from Redis
            raw_observations = await self.redis_client.lrange(key, 0, limit - 1)

            # Parse JSON
            observations = []
            for raw in raw_observations:
                try:
                    # Handle bytes or string
                    if isinstance(raw, bytes):
                        raw = raw.decode('utf-8')

                    obs = json.loads(raw)
                    observations.append(obs)
                except json.JSONDecodeError as e:
                    logger.warning(f"[{self.agent_name}] Failed to parse observation: {e}")
                    continue

            return observations

        except Exception as e:
            logger.error(f"[{self.agent_name}] Failed to retrieve observations: {e}")
            return []

    async def store_action(self, action: Dict[str, Any]) -> None:
        """
        Store an action taken by the agent

        Args:
            action: Dictionary describing the action
        """
        try:
            timestamp = datetime.now().isoformat()
            action_data = {
                "timestamp": timestamp,
                **action
            }

            key = self._make_key("actions")

            # Add to list (newest first)
            await self.redis_client.lpush(key, json.dumps(action_data))

            # Trim to max size
            await self.redis_client.ltrim(key, 0, self.max_observations - 1)

            # Set TTL
            await self.redis_client.expire(key, self.observation_ttl)

            logger.debug(f"[{self.agent_name}] Stored action: {action.get('type', 'unknown')}")

        except Exception as e:
            logger.error(f"[{self.agent_name}] Failed to store action: {e}")

    async def get_recent_actions(self, limit: int = 5) -> List[Dict[str, Any]]:
        """
        Get recent actions from memory

        Args:
            limit: Number of actions to retrieve

        Returns:
            List of action dictionaries (newest first)
        """
        try:
            key = self._make_key("actions")

            # Get actions from Redis
            raw_actions = await self.redis_client.lrange(key, 0, limit - 1)

            # Parse JSON
            actions = []
            for raw in raw_actions:
                try:
                    # Handle bytes or string
                    if isinstance(raw, bytes):
                        raw = raw.decode('utf-8')

                    action = json.loads(raw)
                    actions.append(action)
                except json.JSONDecodeError as e:
                    logger.warning(f"[{self.agent_name}] Failed to parse action: {e}")
                    continue

            return actions

        except Exception as e:
            logger.error(f"[{self.agent_name}] Failed to retrieve actions: {e}")
            return []

    async def update_context(self, context: str) -> None:
        """
        Update conversation context

        Args:
            context: Current conversation context
        """
        try:
            key = self._make_key("conversation_context")

            await self.redis_client.set(key, context)
            await self.redis_client.expire(key, self.observation_ttl)

            logger.debug(f"[{self.agent_name}] Updated conversation context")

        except Exception as e:
            logger.error(f"[{self.agent_name}] Failed to update context: {e}")

    async def get_context(self) -> Optional[str]:
        """
        Get current conversation context

        Returns:
            Context string or None
        """
        try:
            key = self._make_key("conversation_context")
            context = await self.redis_client.get(key)

            if context:
                # Handle bytes or string
                if isinstance(context, bytes):
                    context = context.decode('utf-8')
                return context

            return None

        except Exception as e:
            logger.error(f"[{self.agent_name}] Failed to retrieve context: {e}")
            return None

    async def record_message_sent(self) -> None:
        """
        Record that a message was sent (for throttling)
        """
        try:
            now = datetime.now().timestamp()

            # Update last message time
            time_key = self._make_key("last_message_time")
            await self.redis_client.set(time_key, str(now))

            # Increment hourly counter
            count_key = self._make_key("messages_last_hour")
            await self.redis_client.incr(count_key)
            await self.redis_client.expire(count_key, 3600)  # 1 hour

            logger.debug(f"[{self.agent_name}] Recorded message sent at {now}")

        except Exception as e:
            logger.error(f"[{self.agent_name}] Failed to record message: {e}")

    async def check_throttle(
        self,
        min_interval_seconds: int = 60,
        max_per_hour: int = 30
    ) -> bool:
        """
        Check if agent is allowed to send a message

        Args:
            min_interval_seconds: Minimum seconds between messages
            max_per_hour: Maximum messages per hour

        Returns:
            True if allowed to send, False if throttled
        """
        try:
            # Check minimum interval
            time_key = self._make_key("last_message_time")
            last_msg_time = await self.redis_client.get(time_key)

            if last_msg_time:
                # Handle bytes or string
                if isinstance(last_msg_time, bytes):
                    last_msg_time = last_msg_time.decode('utf-8')

                time_since_last = datetime.now().timestamp() - float(last_msg_time)

                if time_since_last < min_interval_seconds:
                    logger.debug(
                        f"[{self.agent_name}] Throttled: "
                        f"{time_since_last:.0f}s < {min_interval_seconds}s"
                    )
                    return False

            # Check hourly rate limit
            count_key = self._make_key("messages_last_hour")
            msg_count = await self.redis_client.get(count_key)

            if msg_count:
                # Handle bytes or string
                if isinstance(msg_count, bytes):
                    msg_count = msg_count.decode('utf-8')

                if int(msg_count) >= max_per_hour:
                    logger.debug(
                        f"[{self.agent_name}] Throttled: "
                        f"{msg_count} >= {max_per_hour} messages/hour"
                    )
                    return False

            return True

        except Exception as e:
            logger.error(f"[{self.agent_name}] Error checking throttle: {e}")
            # Fail open - allow message if throttle check fails
            return True

    async def get_last_message_content(self) -> Optional[str]:
        """
        Get content of the last message sent

        Returns:
            Last message content or None
        """
        try:
            key = self._make_key("last_message_content")
            content = await self.redis_client.get(key)

            if content:
                # Handle bytes or string
                if isinstance(content, bytes):
                    content = content.decode('utf-8')
                return content

            return None

        except Exception as e:
            logger.error(f"[{self.agent_name}] Failed to retrieve last message: {e}")
            return None

    async def store_message_content(self, content: str) -> None:
        """
        Store the content of a message sent

        Args:
            content: Message content
        """
        try:
            key = self._make_key("last_message_content")
            await self.redis_client.set(key, content)
            await self.redis_client.expire(key, self.observation_ttl)

            logger.debug(f"[{self.agent_name}] Stored message content")

        except Exception as e:
            logger.error(f"[{self.agent_name}] Failed to store message content: {e}")

    async def clear_all(self) -> None:
        """
        Clear all memory for this agent
        """
        try:
            keys_to_delete = [
                self._make_key("observations"),
                self._make_key("actions"),
                self._make_key("conversation_context"),
                self._make_key("last_message_time"),
                self._make_key("messages_last_hour"),
                self._make_key("last_message_content")
            ]

            deleted = 0
            for key in keys_to_delete:
                result = await self.redis_client.delete(key)
                if result:
                    deleted += 1

            logger.info(f"[{self.agent_name}] Cleared {deleted} memory keys")

        except Exception as e:
            logger.error(f"[{self.agent_name}] Failed to clear memory: {e}")

    async def get_stats(self) -> Dict[str, Any]:
        """
        Get memory statistics

        Returns:
            Dictionary with memory stats
        """
        try:
            observations = await self.get_recent_observations(limit=100)
            actions = await self.get_recent_actions(limit=100)

            time_key = self._make_key("last_message_time")
            last_msg_time = await self.redis_client.get(time_key)

            count_key = self._make_key("messages_last_hour")
            msg_count = await self.redis_client.get(count_key)

            stats = {
                "agent_name": self.agent_name,
                "observations_count": len(observations),
                "actions_count": len(actions),
                "messages_last_hour": int(msg_count) if msg_count else 0,
                "last_message_time": float(last_msg_time) if last_msg_time else None,
                "has_context": await self.get_context() is not None
            }

            if stats["last_message_time"]:
                time_since = datetime.now().timestamp() - stats["last_message_time"]
                stats["seconds_since_last_message"] = round(time_since, 1)

            return stats

        except Exception as e:
            logger.error(f"[{self.agent_name}] Failed to get stats: {e}")
            return {"error": str(e)}
