"""
Conversation Persistence using Redis

Stores conversation history in Redis for fast access and persistence.
"""

import json
import logging
from typing import List, Dict, Any, Optional
from datetime import datetime
import redis
import os

logger = logging.getLogger(__name__)


class ConversationStore:
    """
    Redis-based conversation storage

    Stores conversations using Redis data structures:
    - Hashes for conversation metadata
    - Lists for message history
    - Sorted Sets for conversation indexes
    """

    def __init__(
        self,
        redis_host: str = "localhost",
        redis_port: int = 6379,
        redis_db: int = 0,
        redis_password: Optional[str] = None
    ):
        """
        Initialize conversation store

        Args:
            redis_host: Redis host
            redis_port: Redis port
            redis_db: Redis database number
            redis_password: Optional Redis password
        """
        self.redis_client = redis.Redis(
            host=redis_host,
            port=redis_port,
            db=redis_db,
            password=redis_password,
            decode_responses=True
        )

        # Test connection
        try:
            self.redis_client.ping()
            logger.info(f"Connected to Redis at {redis_host}:{redis_port}")
        except redis.ConnectionError as e:
            logger.error(f"Failed to connect to Redis: {e}")
            raise

    def _conversation_key(self, conversation_id: str, agent: str) -> str:
        """Get Redis key for conversation metadata"""
        return f"conversation:{conversation_id}:{agent}"

    def _messages_key(self, conversation_id: str, agent: str) -> str:
        """Get Redis key for conversation messages"""
        return f"messages:{conversation_id}:{agent}"

    def _conversations_index_key(self, agent: Optional[str] = None) -> str:
        """Get Redis key for conversation index"""
        if agent:
            return f"conversations:index:{agent}"
        return "conversations:index:all"

    def create_conversation(
        self,
        conversation_id: str,
        agent: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> bool:
        """
        Create a new conversation

        Args:
            conversation_id: Unique conversation identifier
            agent: Agent name
            metadata: Optional metadata (game state, etc.)

        Returns:
            True if created, False if already exists
        """
        key = self._conversation_key(conversation_id, agent)

        # Check if exists
        if self.redis_client.exists(key):
            return False

        # Create conversation metadata
        now = datetime.utcnow().isoformat()
        conv_data = {
            "conversation_id": conversation_id,
            "agent": agent,
            "created_at": now,
            "updated_at": now,
            "metadata": json.dumps(metadata) if metadata else "{}"
        }

        # Store metadata
        self.redis_client.hset(key, mapping=conv_data)

        # Add to indexes (sorted by timestamp)
        timestamp = datetime.utcnow().timestamp()
        self.redis_client.zadd(
            self._conversations_index_key(agent),
            {conversation_id: timestamp}
        )
        self.redis_client.zadd(
            self._conversations_index_key(),
            {f"{conversation_id}:{agent}": timestamp}
        )

        logger.info(f"Created conversation {conversation_id} for {agent}")
        return True

    def add_message(
        self,
        conversation_id: str,
        agent: str,
        role: str,
        content: str,
        function_call: Optional[Dict[str, Any]] = None
    ):
        """
        Add a message to a conversation

        Args:
            conversation_id: Conversation identifier
            agent: Agent name
            role: Message role (user, assistant, system)
            content: Message content
            function_call: Optional function call data
        """
        # Ensure conversation exists
        self.create_conversation(conversation_id, agent)

        # Create message
        message = {
            "role": role,
            "content": content,
            "timestamp": datetime.utcnow().isoformat()
        }

        if function_call:
            message["function_call"] = function_call

        # Add to messages list
        messages_key = self._messages_key(conversation_id, agent)
        self.redis_client.rpush(messages_key, json.dumps(message))

        # Update conversation timestamp
        conv_key = self._conversation_key(conversation_id, agent)
        self.redis_client.hset(
            conv_key,
            "updated_at",
            datetime.utcnow().isoformat()
        )

        # Update index timestamp
        timestamp = datetime.utcnow().timestamp()
        self.redis_client.zadd(
            self._conversations_index_key(agent),
            {conversation_id: timestamp}
        )

    def get_messages(
        self,
        conversation_id: str,
        agent: str,
        limit: Optional[int] = None
    ) -> List[Dict[str, Any]]:
        """
        Get messages from a conversation

        Args:
            conversation_id: Conversation identifier
            agent: Agent name
            limit: Optional limit on number of messages

        Returns:
            List of message dictionaries
        """
        messages_key = self._messages_key(conversation_id, agent)

        # Get messages (limit from end if specified)
        if limit:
            # Get last N messages
            raw_messages = self.redis_client.lrange(messages_key, -limit, -1)
        else:
            # Get all messages
            raw_messages = self.redis_client.lrange(messages_key, 0, -1)

        # Parse JSON messages
        messages = []
        for raw_msg in raw_messages:
            try:
                messages.append(json.loads(raw_msg))
            except json.JSONDecodeError as e:
                logger.warning(f"Failed to parse message: {e}")

        return messages

    def get_conversation_history(
        self,
        conversation_id: str,
        agent: str
    ) -> List[Dict[str, str]]:
        """
        Get conversation history in format expected by orchestrator

        Args:
            conversation_id: Conversation identifier
            agent: Agent name

        Returns:
            List of messages with role and content
        """
        messages = self.get_messages(conversation_id, agent)

        # Convert to orchestrator format (just role and content)
        return [
            {"role": msg["role"], "content": msg["content"]}
            for msg in messages
        ]

    def list_conversations(
        self,
        agent: Optional[str] = None,
        limit: int = 100
    ) -> List[Dict[str, Any]]:
        """
        List conversations sorted by most recent

        Args:
            agent: Optional agent filter
            limit: Maximum number of conversations to return

        Returns:
            List of conversation info
        """
        index_key = self._conversations_index_key(agent)

        # Get conversation IDs sorted by timestamp (most recent first)
        # ZREVRANGE returns in descending order (newest first)
        conv_ids = self.redis_client.zrevrange(index_key, 0, limit - 1)

        conversations = []
        for conv_id_str in conv_ids:
            # Handle both formats: "conv_id" or "conv_id:agent"
            if ":" in conv_id_str:
                conv_id, conv_agent = conv_id_str.rsplit(":", 1)
            else:
                conv_id = conv_id_str
                conv_agent = agent

            # Get conversation metadata
            conv_key = self._conversation_key(conv_id, conv_agent)
            conv_data = self.redis_client.hgetall(conv_key)

            if conv_data:
                conv_info = {
                    "conversation_id": conv_data.get("conversation_id", conv_id),
                    "agent": conv_data.get("agent", conv_agent),
                    "created_at": conv_data.get("created_at"),
                    "updated_at": conv_data.get("updated_at")
                }

                # Parse metadata if present
                if conv_data.get("metadata"):
                    try:
                        conv_info["metadata"] = json.loads(conv_data["metadata"])
                    except json.JSONDecodeError:
                        pass

                conversations.append(conv_info)

        return conversations

    def delete_conversation(
        self,
        conversation_id: str,
        agent: Optional[str] = None
    ):
        """
        Delete a conversation and all its messages

        Args:
            conversation_id: Conversation identifier
            agent: Optional agent filter (if None, deletes for all agents)
        """
        if agent:
            # Delete specific agent conversation
            conv_key = self._conversation_key(conversation_id, agent)
            messages_key = self._messages_key(conversation_id, agent)

            self.redis_client.delete(conv_key)
            self.redis_client.delete(messages_key)

            # Remove from indexes
            self.redis_client.zrem(
                self._conversations_index_key(agent),
                conversation_id
            )
            self.redis_client.zrem(
                self._conversations_index_key(),
                f"{conversation_id}:{agent}"
            )

            logger.info(f"Deleted conversation {conversation_id} for {agent}")
        else:
            # Delete conversation for all agents
            # This requires scanning for all agent keys
            pattern = f"conversation:{conversation_id}:*"
            for key in self.redis_client.scan_iter(match=pattern):
                # Extract agent from key
                parts = key.split(":")
                if len(parts) >= 3:
                    conv_agent = parts[2]
                    self.delete_conversation(conversation_id, conv_agent)

    def clear_all_conversations(self):
        """Delete all conversations (use with caution!)"""
        # Delete all conversation-related keys
        for pattern in [
            "conversation:*",
            "messages:*",
            "conversations:index:*"
        ]:
            for key in self.redis_client.scan_iter(match=pattern):
                self.redis_client.delete(key)

        logger.warning("Cleared all conversations")

    def get_conversation_stats(
        self,
        conversation_id: str,
        agent: str
    ) -> Dict[str, Any]:
        """
        Get statistics about a conversation

        Args:
            conversation_id: Conversation identifier
            agent: Agent name

        Returns:
            Dictionary with conversation statistics
        """
        conv_key = self._conversation_key(conversation_id, agent)
        messages_key = self._messages_key(conversation_id, agent)

        # Get metadata
        conv_data = self.redis_client.hgetall(conv_key)
        if not conv_data:
            return {}

        # Get message count
        message_count = self.redis_client.llen(messages_key)

        # Get messages for role breakdown
        messages = self.get_messages(conversation_id, agent)
        role_counts = {}
        for msg in messages:
            role = msg.get("role", "unknown")
            role_counts[role] = role_counts.get(role, 0) + 1

        return {
            "conversation_id": conversation_id,
            "agent": agent,
            "created_at": conv_data.get("created_at"),
            "updated_at": conv_data.get("updated_at"),
            "message_count": message_count,
            "role_counts": role_counts
        }

    def health_check(self) -> Dict[str, Any]:
        """
        Check Redis connection health

        Returns:
            Health check results
        """
        try:
            self.redis_client.ping()
            return {
                "status": "healthy",
                "connected": True
            }
        except Exception as e:
            return {
                "status": "unhealthy",
                "connected": False,
                "error": str(e)
            }


# Global conversation store instance
_store: Optional[ConversationStore] = None


def get_conversation_store() -> ConversationStore:
    """
    Get or create global conversation store

    Returns:
        ConversationStore instance
    """
    global _store
    if _store is None:
        # Get Redis config from environment
        redis_host = os.getenv("REDIS_HOST", "localhost")
        redis_port = int(os.getenv("REDIS_PORT", "6379"))
        redis_db = int(os.getenv("REDIS_DB", "0"))
        redis_password = os.getenv("REDIS_PASSWORD")

        _store = ConversationStore(
            redis_host=redis_host,
            redis_port=redis_port,
            redis_db=redis_db,
            redis_password=redis_password
        )
    return _store


def reset_conversation_store():
    """Reset global conversation store (for testing)"""
    global _store
    _store = None
