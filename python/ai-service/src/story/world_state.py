"""
World State Manager - Global Game State Tracking

Manages global world state that evolves based on player actions:
- Economy per sector (prices, availability)
- Faction reputation and standings
- Event timeline (major world events)

Used for contextual narrative generation.
"""

import json
import logging
from typing import Dict, List, Any, Optional
from datetime import datetime
import redis.asyncio as redis

logger = logging.getLogger(__name__)


class WorldState:
    """
    Manages global world state for narrative context.

    Tracks:
    - Economy per sector (fuel prices, parts availability, trader count)
    - Faction standings (player-independent global reputation)
    - Event timeline (major world events with timestamps)
    """

    def __init__(self, redis_client: redis.Redis):
        """
        Initialize world state manager.

        Args:
            redis_client: Async Redis client
        """
        self.redis = redis_client

    async def update_economy(
        self,
        sector: str,
        updates: Dict[str, Any]
    ) -> None:
        """
        Update economy for a sector.

        Args:
            sector: Sector name (e.g., "earth", "mars_orbit")
            updates: Dict of economic values to update
                {
                    "fuel_price": 150,
                    "parts_availability": 0.8,
                    "trader_count": 5
                }
        """
        key = f"world_economy:{sector}"

        # Update fields
        if updates:
            await self.redis.hset(key, mapping={k: str(v) for k, v in updates.items()})
            logger.debug(f"Updated economy for {sector}: {list(updates.keys())}")

        # Set TTL (7 days - economy changes slowly)
        await self.redis.expire(key, 7 * 24 * 3600)

    async def get_economy(
        self,
        sector: str
    ) -> Dict[str, Any]:
        """
        Get economy state for a sector.

        Args:
            sector: Sector name

        Returns:
            Dict of economic values (empty if not set)
        """
        key = f"world_economy:{sector}"
        economy_raw = await self.redis.hgetall(key)

        # Convert string values to appropriate types
        economy = {}
        for field, value in economy_raw.items():
            # Try to convert to number
            try:
                economy[field] = float(value) if '.' in value else int(value)
            except ValueError:
                economy[field] = value

        logger.debug(f"Retrieved economy for {sector}: {len(economy)} fields")
        return economy

    async def update_faction(
        self,
        faction: str,
        standing: int
    ) -> None:
        """
        Update global faction standing.

        This is different from player relationships - this is the faction's
        overall power/influence in the world.

        Args:
            faction: Faction name
            standing: Power/influence level (0-100)
        """
        key = "world_factions"

        # Clamp to 0-100
        standing = max(0, min(100, standing))

        await self.redis.hset(key, faction, standing)
        logger.debug(f"Updated faction {faction} standing to {standing}")

    async def get_faction(
        self,
        faction: str
    ) -> int:
        """
        Get global faction standing.

        Args:
            faction: Faction name

        Returns:
            Standing (0-100), or 50 if not set
        """
        key = "world_factions"
        standing = await self.redis.hget(key, faction)

        return int(standing) if standing else 50  # Default to neutral

    async def get_all_factions(self) -> Dict[str, int]:
        """
        Get all faction standings.

        Returns:
            Dict mapping faction names to standings
        """
        key = "world_factions"
        factions_raw = await self.redis.hgetall(key)

        factions = {name: int(standing) for name, standing in factions_raw.items()}
        logger.debug(f"Retrieved {len(factions)} faction standings")
        return factions

    async def add_event(
        self,
        event: Dict[str, Any]
    ) -> None:
        """
        Add event to global timeline.

        Args:
            event: Event data
                {
                    "event_id": "earth_exodus_anniversary",
                    "title": "50th Anniversary of Exodus",
                    "description": "...",
                    "timestamp": 1699564320,
                    "impact": "global"
                }
        """
        key = "world_events"

        # Use timestamp as score for sorted set
        timestamp = event.get("timestamp", int(datetime.utcnow().timestamp()))

        # Store event as JSON
        event_json = json.dumps(event)

        await self.redis.zadd(key, {event_json: timestamp})

        # Set TTL on events (30 days)
        await self.redis.expire(key, 30 * 24 * 3600)

        logger.debug(f"Added event: {event.get('event_id', 'unknown')}")

    async def get_recent_events(
        self,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """
        Get recent world events.

        Args:
            limit: Max number of events to return

        Returns:
            List of event dicts (most recent first)
        """
        key = "world_events"

        # Get most recent events (highest scores)
        events_json = await self.redis.zrevrange(key, 0, limit - 1)

        # Parse JSON
        events = [json.loads(e) for e in events_json]

        logger.debug(f"Retrieved {len(events)} recent events")
        return events

    async def get_world_context(
        self,
        sector: Optional[str] = None,
        include_events: bool = True
    ) -> Dict[str, Any]:
        """
        Build comprehensive world context for narrative generation.

        Args:
            sector: Specific sector to include economy for (optional)
            include_events: Include recent events (default True)

        Returns:
            {
                "economy": {...},  # If sector specified
                "factions": {...},
                "recent_events": [...]  # If include_events True
            }
        """
        context = {}

        # Add economy if sector specified
        if sector:
            context["economy"] = await self.get_economy(sector)

        # Add all factions
        context["factions"] = await self.get_all_factions()

        # Add recent events
        if include_events:
            context["recent_events"] = await self.get_recent_events(limit=5)

        logger.info(
            f"Built world context: "
            f"economy={'yes' if sector else 'no'}, "
            f"{len(context['factions'])} factions, "
            f"{len(context.get('recent_events', []))} events"
        )

        return context


__all__ = ["WorldState"]
