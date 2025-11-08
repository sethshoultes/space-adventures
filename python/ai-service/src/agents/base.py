"""
Base Agent Class

Abstract base class for autonomous AI agents using LangGraph.
"""

from abc import ABC, abstractmethod
from typing import Dict, List, Optional, Any
from datetime import datetime
import redis.asyncio as redis
import json


class BaseAgent(ABC):
    """
    Base class for autonomous AI agents.

    All agents follow the ReAct pattern:
    1. Observe - Analyze current game state
    2. Reason - Decide if action is needed
    3. Act - Execute tools if necessary
    4. Reflect - Determine importance
    5. Communicate - Generate message or stay silent
    """

    def __init__(
        self,
        agent_name: str,
        redis_client: redis.Redis,
        min_message_interval: int = 60,
        max_messages_per_hour: int = 30
    ):
        """
        Initialize base agent

        Args:
            agent_name: Name of the agent (e.g., "atlas")
            redis_client: Redis client for memory storage
            min_message_interval: Minimum seconds between messages
            max_messages_per_hour: Maximum messages per hour
        """
        self.agent_name = agent_name
        self.redis_client = redis_client
        self.min_message_interval = min_message_interval
        self.max_messages_per_hour = max_messages_per_hour

    async def check_throttle(self) -> bool:
        """
        Check if agent is allowed to send a message

        Returns:
            True if allowed, False if throttled
        """
        # Check minimum interval
        last_msg_time = await self.redis_client.get(f"{self.agent_name}:last_message_time")
        if last_msg_time:
            time_since_last = datetime.now().timestamp() - float(last_msg_time)
            if time_since_last < self.min_message_interval:
                return False

        # Check hourly rate limit
        msg_count = await self.redis_client.get(f"{self.agent_name}:messages_last_hour")
        if msg_count and int(msg_count) >= self.max_messages_per_hour:
            return False

        return True

    async def record_message(self) -> None:
        """Record that a message was sent (for throttling)"""
        now = datetime.now().timestamp()

        # Update last message time
        await self.redis_client.set(
            f"{self.agent_name}:last_message_time",
            str(now)
        )

        # Increment hourly counter
        key = f"{self.agent_name}:messages_last_hour"
        await self.redis_client.incr(key)
        await self.redis_client.expire(key, 3600)  # Expire after 1 hour

    async def store_observation(self, observation: str) -> None:
        """
        Store an observation in memory

        Args:
            observation: Text description of observation
        """
        key = f"{self.agent_name}:observations"
        await self.redis_client.lpush(key, observation)
        await self.redis_client.ltrim(key, 0, 9)  # Keep last 10
        await self.redis_client.expire(key, 3600)  # 1 hour TTL

    async def get_recent_observations(self, limit: int = 5) -> List[str]:
        """
        Get recent observations from memory

        Args:
            limit: Number of observations to retrieve

        Returns:
            List of observation strings
        """
        key = f"{self.agent_name}:observations"
        observations = await self.redis_client.lrange(key, 0, limit - 1)
        return [obs.decode('utf-8') if isinstance(obs, bytes) else obs for obs in observations]

    async def store_action(self, action: Dict[str, Any]) -> None:
        """
        Store an action taken

        Args:
            action: Dictionary describing the action
        """
        key = f"{self.agent_name}:actions"
        await self.redis_client.lpush(key, json.dumps(action))
        await self.redis_client.ltrim(key, 0, 9)  # Keep last 10
        await self.redis_client.expire(key, 3600)  # 1 hour TTL

    async def get_recent_actions(self, limit: int = 5) -> List[Dict[str, Any]]:
        """
        Get recent actions from memory

        Args:
            limit: Number of actions to retrieve

        Returns:
            List of action dictionaries
        """
        key = f"{self.agent_name}:actions"
        actions = await self.redis_client.lrange(key, 0, limit - 1)
        return [
            json.loads(action.decode('utf-8') if isinstance(action, bytes) else action)
            for action in actions
        ]

    @abstractmethod
    async def run(self, game_state: Dict[str, Any], force_check: bool = False) -> Dict[str, Any]:
        """
        Main entry point - run the agent's ReAct loop

        Args:
            game_state: Current game state dictionary
            force_check: If True, bypass throttling (for testing)

        Returns:
            Dictionary with:
            - should_act: bool - Whether agent decided to act
            - message: str | None - Generated message (if any)
            - urgency: str - Urgency level (INFO, MEDIUM, URGENT, CRITICAL)
            - tools_used: List[str] - Tools that were executed
            - reasoning: str - Why agent acted or stayed silent
            - next_check_in: int - Recommended seconds until next check
        """
        pass

    @abstractmethod
    def get_available_tools(self) -> List[Dict[str, Any]]:
        """
        Get list of tools available to this agent

        Returns:
            List of tool definitions (function schemas)
        """
        pass
