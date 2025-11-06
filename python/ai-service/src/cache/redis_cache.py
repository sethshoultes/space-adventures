"""
Redis caching for AI responses.

Caches AI-generated content to reduce costs and improve response times.
"""

import os
import logging
import hashlib
import json
from typing import Optional, Any
import redis.asyncio as redis
from datetime import timedelta

logger = logging.getLogger(__name__)


class RedisCache:
    """
    Redis-based caching for AI responses.

    Caches responses based on prompt hash to avoid regenerating
    identical content.
    """

    def __init__(self):
        """Initialize Redis connection."""
        self.enabled = os.getenv("CACHE_ENABLED", "true").lower() == "true"

        if not self.enabled:
            logger.info("Redis caching disabled")
            self.client = None
            return

        # Connect to Redis
        redis_host = os.getenv("REDIS_HOST", "localhost")
        redis_port = int(os.getenv("REDIS_PORT", "6379"))
        redis_db = int(os.getenv("REDIS_DB", "0"))

        try:
            self.client = redis.Redis(
                host=redis_host,
                port=redis_port,
                db=redis_db,
                decode_responses=True
            )

            # Default TTL from environment (hours)
            ttl_hours = int(os.getenv("CACHE_TTL_HOURS", "24"))
            self.default_ttl = timedelta(hours=ttl_hours)

            logger.info(
                f"Redis cache initialized at {redis_host}:{redis_port} "
                f"(TTL: {ttl_hours}h)"
            )
        except Exception as e:
            logger.error(f"Failed to initialize Redis: {e}")
            self.enabled = False
            self.client = None

    def _generate_cache_key(
        self,
        prompt: str,
        system: Optional[str] = None,
        **kwargs
    ) -> str:
        """
        Generate cache key from prompt and parameters.

        Args:
            prompt: User prompt
            system: System message
            **kwargs: Additional parameters

        Returns:
            Cache key (hash of inputs)
        """
        # Combine all inputs
        cache_input = {
            "prompt": prompt,
            "system": system or "",
            **kwargs
        }

        # Serialize and hash
        input_json = json.dumps(cache_input, sort_keys=True)
        hash_obj = hashlib.sha256(input_json.encode())
        cache_key = f"ai_response:{hash_obj.hexdigest()}"

        return cache_key

    async def get(
        self,
        prompt: str,
        system: Optional[str] = None,
        **kwargs
    ) -> Optional[str]:
        """
        Get cached response if available.

        Args:
            prompt: User prompt
            system: System message
            **kwargs: Additional parameters

        Returns:
            Cached response or None if not found
        """
        if not self.enabled or not self.client:
            return None

        try:
            cache_key = self._generate_cache_key(prompt, system, **kwargs)
            cached_value = await self.client.get(cache_key)

            if cached_value:
                logger.info(f"Cache hit for key: {cache_key[:16]}...")
                return cached_value
            else:
                logger.debug(f"Cache miss for key: {cache_key[:16]}...")
                return None

        except Exception as e:
            logger.error(f"Cache get error: {e}")
            return None

    async def set(
        self,
        prompt: str,
        response: str,
        system: Optional[str] = None,
        ttl: Optional[timedelta] = None,
        **kwargs
    ) -> bool:
        """
        Cache an AI response.

        Args:
            prompt: User prompt
            response: AI-generated response
            system: System message
            ttl: Time to live (default: 24 hours)
            **kwargs: Additional parameters

        Returns:
            True if cached successfully, False otherwise
        """
        if not self.enabled or not self.client:
            return False

        try:
            cache_key = self._generate_cache_key(prompt, system, **kwargs)
            cache_ttl = ttl or self.default_ttl

            await self.client.setex(
                cache_key,
                cache_ttl,
                response
            )

            logger.info(f"Cached response for key: {cache_key[:16]}... (TTL: {cache_ttl})")
            return True

        except Exception as e:
            logger.error(f"Cache set error: {e}")
            return False

    async def delete(
        self,
        prompt: str,
        system: Optional[str] = None,
        **kwargs
    ) -> bool:
        """
        Delete cached response.

        Args:
            prompt: User prompt
            system: System message
            **kwargs: Additional parameters

        Returns:
            True if deleted, False otherwise
        """
        if not self.enabled or not self.client:
            return False

        try:
            cache_key = self._generate_cache_key(prompt, system, **kwargs)
            deleted = await self.client.delete(cache_key)

            if deleted:
                logger.info(f"Deleted cache key: {cache_key[:16]}...")
                return True
            else:
                return False

        except Exception as e:
            logger.error(f"Cache delete error: {e}")
            return False

    async def clear_all(self) -> bool:
        """
        Clear all cached AI responses.

        Returns:
            True if cleared, False otherwise
        """
        if not self.enabled or not self.client:
            return False

        try:
            # Find all AI response keys
            cursor = 0
            deleted_count = 0

            while True:
                cursor, keys = await self.client.scan(
                    cursor,
                    match="ai_response:*",
                    count=100
                )

                if keys:
                    deleted = await self.client.delete(*keys)
                    deleted_count += deleted

                if cursor == 0:
                    break

            logger.info(f"Cleared {deleted_count} cached AI responses")
            return True

        except Exception as e:
            logger.error(f"Cache clear error: {e}")
            return False

    async def get_stats(self) -> dict:
        """
        Get cache statistics.

        Returns:
            Dictionary with cache stats
        """
        if not self.enabled or not self.client:
            return {"enabled": False}

        try:
            # Count cached responses
            cursor = 0
            key_count = 0

            while True:
                cursor, keys = await self.client.scan(
                    cursor,
                    match="ai_response:*",
                    count=100
                )
                key_count += len(keys)

                if cursor == 0:
                    break

            # Get Redis info
            info = await self.client.info("memory")

            return {
                "enabled": True,
                "cached_responses": key_count,
                "memory_used_mb": round(info.get("used_memory", 0) / 1024 / 1024, 2),
                "ttl_hours": self.default_ttl.total_seconds() / 3600
            }

        except Exception as e:
            logger.error(f"Failed to get cache stats: {e}")
            return {"enabled": True, "error": str(e)}


# Global cache instance
_cache: Optional[RedisCache] = None


def get_cache() -> RedisCache:
    """Get or create global cache instance."""
    global _cache
    if _cache is None:
        _cache = RedisCache()
    return _cache
