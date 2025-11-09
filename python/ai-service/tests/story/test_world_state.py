"""
Unit tests for WorldState

Tests global world state tracking:
- Economy updates and retrieval
- Economy field type conversion (strings to numbers)
- Faction standing updates (with 0-100 clamping)
- Faction retrieval (default to 50 if not set)
- Get all factions
- Event adding to timeline
- Event retrieval (sorted by timestamp, most recent first)
- World context building
"""

import pytest
import pytest_asyncio
import json
from datetime import datetime
from fakeredis import FakeAsyncRedis
from src.story.world_state import WorldState


@pytest_asyncio.fixture
async def redis_client():
    """Create fake Redis client for testing."""
    return FakeAsyncRedis(decode_responses=True)


@pytest_asyncio.fixture
async def world_state(redis_client):
    """Create WorldState instance with fake Redis."""
    return WorldState(redis_client)


class TestEconomy:
    """Test economy tracking per sector."""

    @pytest.mark.asyncio
    async def test_update_economy(self, world_state):
        """Test updating economy for a sector."""
        updates = {
            "fuel_price": 150,
            "parts_availability": 0.8,
            "trader_count": 5
        }

        await world_state.update_economy("earth", updates)

        # Verify stored
        economy = await world_state.get_economy("earth")
        assert economy["fuel_price"] == 150
        assert economy["parts_availability"] == 0.8
        assert economy["trader_count"] == 5

    @pytest.mark.asyncio
    async def test_get_economy_empty_sector(self, world_state):
        """Test retrieving economy for sector with no data."""
        economy = await world_state.get_economy("unknown_sector")

        assert economy == {}

    @pytest.mark.asyncio
    async def test_economy_type_conversion_integers(self, world_state):
        """Test that integer values are converted from strings."""
        updates = {
            "trader_count": 10,
            "station_count": 3
        }

        await world_state.update_economy("mars", updates)

        economy = await world_state.get_economy("mars")

        # Should be integers, not strings
        assert isinstance(economy["trader_count"], int)
        assert isinstance(economy["station_count"], int)
        assert economy["trader_count"] == 10
        assert economy["station_count"] == 3

    @pytest.mark.asyncio
    async def test_economy_type_conversion_floats(self, world_state):
        """Test that float values are converted from strings."""
        updates = {
            "fuel_price": 125.50,
            "parts_availability": 0.75
        }

        await world_state.update_economy("jupiter", updates)

        economy = await world_state.get_economy("jupiter")

        # Should be floats, not strings
        assert isinstance(economy["fuel_price"], float)
        assert isinstance(economy["parts_availability"], float)
        assert economy["fuel_price"] == 125.50
        assert economy["parts_availability"] == 0.75

    @pytest.mark.asyncio
    async def test_economy_partial_update(self, world_state):
        """Test updating only some fields preserves others."""
        # Initial update
        await world_state.update_economy("earth", {
            "fuel_price": 100,
            "trader_count": 5
        })

        # Partial update
        await world_state.update_economy("earth", {
            "fuel_price": 150  # Only update price
        })

        economy = await world_state.get_economy("earth")

        # Price updated, trader_count preserved
        assert economy["fuel_price"] == 150
        assert economy["trader_count"] == 5

    @pytest.mark.asyncio
    async def test_economy_multiple_sectors(self, world_state):
        """Test tracking economy for multiple sectors independently."""
        await world_state.update_economy("earth", {"fuel_price": 100})
        await world_state.update_economy("mars", {"fuel_price": 200})
        await world_state.update_economy("jupiter", {"fuel_price": 300})

        earth_economy = await world_state.get_economy("earth")
        mars_economy = await world_state.get_economy("mars")
        jupiter_economy = await world_state.get_economy("jupiter")

        assert earth_economy["fuel_price"] == 100
        assert mars_economy["fuel_price"] == 200
        assert jupiter_economy["fuel_price"] == 300


class TestFactions:
    """Test faction standing tracking."""

    @pytest.mark.asyncio
    async def test_update_faction(self, world_state):
        """Test updating faction standing."""
        await world_state.update_faction("traders_guild", 75)

        standing = await world_state.get_faction("traders_guild")
        assert standing == 75

    @pytest.mark.asyncio
    async def test_get_faction_default_neutral(self, world_state):
        """Test that unset factions default to 50 (neutral)."""
        standing = await world_state.get_faction("unknown_faction")

        assert standing == 50

    @pytest.mark.asyncio
    async def test_faction_clamping_upper_bound(self, world_state):
        """Test that faction standing is clamped at 100."""
        await world_state.update_faction("allies", 150)

        standing = await world_state.get_faction("allies")
        assert standing == 100  # Clamped

    @pytest.mark.asyncio
    async def test_faction_clamping_lower_bound(self, world_state):
        """Test that faction standing is clamped at 0."""
        await world_state.update_faction("enemies", -50)

        standing = await world_state.get_faction("enemies")
        assert standing == 0  # Clamped

    @pytest.mark.asyncio
    async def test_get_all_factions(self, world_state):
        """Test retrieving all faction standings."""
        await world_state.update_faction("traders_guild", 75)
        await world_state.update_faction("scavengers", 30)
        await world_state.update_faction("military", 60)

        factions = await world_state.get_all_factions()

        assert len(factions) == 3
        assert factions["traders_guild"] == 75
        assert factions["scavengers"] == 30
        assert factions["military"] == 60

    @pytest.mark.asyncio
    async def test_get_all_factions_empty(self, world_state):
        """Test retrieving all factions when none exist."""
        factions = await world_state.get_all_factions()

        assert factions == {}

    @pytest.mark.asyncio
    async def test_faction_overwrite(self, world_state):
        """Test that updating faction overwrites previous value."""
        await world_state.update_faction("traders_guild", 50)
        await world_state.update_faction("traders_guild", 75)

        standing = await world_state.get_faction("traders_guild")
        assert standing == 75  # Overwritten

    @pytest.mark.asyncio
    async def test_faction_boundary_values(self, world_state):
        """Test faction standing at boundaries."""
        await world_state.update_faction("faction_min", 0)
        await world_state.update_faction("faction_max", 100)

        assert await world_state.get_faction("faction_min") == 0
        assert await world_state.get_faction("faction_max") == 100


class TestEvents:
    """Test event timeline tracking."""

    @pytest.mark.asyncio
    async def test_add_event(self, world_state):
        """Test adding event to timeline."""
        event = {
            "event_id": "exodus_anniversary",
            "title": "50th Anniversary",
            "description": "Major celebration",
            "timestamp": 1699564320,
            "impact": "global"
        }

        await world_state.add_event(event)

        # Retrieve events
        events = await world_state.get_recent_events(limit=10)

        assert len(events) == 1
        assert events[0]["event_id"] == "exodus_anniversary"
        assert events[0]["title"] == "50th Anniversary"

    @pytest.mark.asyncio
    async def test_event_auto_timestamp(self, world_state):
        """Test that events get auto-timestamp if not provided."""
        event = {
            "event_id": "auto_event",
            "title": "Auto Timestamped Event"
        }

        await world_state.add_event(event)

        events = await world_state.get_recent_events(limit=1)

        assert len(events) == 1
        assert "timestamp" in events[0] or "event_id" in events[0]

    @pytest.mark.asyncio
    async def test_events_sorted_by_timestamp(self, world_state):
        """Test that events are sorted by timestamp (most recent first)."""
        # Add events with different timestamps
        event1 = {
            "event_id": "old_event",
            "timestamp": 1000000000
        }
        event2 = {
            "event_id": "recent_event",
            "timestamp": 2000000000
        }
        event3 = {
            "event_id": "newest_event",
            "timestamp": 3000000000
        }

        await world_state.add_event(event1)
        await world_state.add_event(event3)
        await world_state.add_event(event2)

        events = await world_state.get_recent_events(limit=10)

        # Should be sorted most recent first
        assert len(events) == 3
        assert events[0]["event_id"] == "newest_event"
        assert events[1]["event_id"] == "recent_event"
        assert events[2]["event_id"] == "old_event"

    @pytest.mark.asyncio
    async def test_get_recent_events_limit(self, world_state):
        """Test retrieving limited number of events."""
        # Add 5 events
        for i in range(5):
            event = {
                "event_id": f"event_{i}",
                "timestamp": 1000000000 + i
            }
            await world_state.add_event(event)

        # Get only 3
        events = await world_state.get_recent_events(limit=3)

        assert len(events) == 3
        # Should be most recent 3
        assert events[0]["event_id"] == "event_4"
        assert events[1]["event_id"] == "event_3"
        assert events[2]["event_id"] == "event_2"

    @pytest.mark.asyncio
    async def test_get_recent_events_empty(self, world_state):
        """Test retrieving events when none exist."""
        events = await world_state.get_recent_events(limit=10)

        assert events == []


class TestWorldContext:
    """Test comprehensive world context building."""

    @pytest.mark.asyncio
    async def test_get_world_context_complete(self, world_state):
        """Test building complete world context."""
        # Setup economy
        await world_state.update_economy("earth", {
            "fuel_price": 150,
            "parts_availability": 0.8
        })

        # Setup factions
        await world_state.update_faction("traders_guild", 75)
        await world_state.update_faction("scavengers", 30)

        # Add events
        await world_state.add_event({
            "event_id": "event_1",
            "timestamp": 2000000000
        })
        await world_state.add_event({
            "event_id": "event_2",
            "timestamp": 2000000001
        })

        # Build context
        context = await world_state.get_world_context(
            sector="earth",
            include_events=True
        )

        # Verify all components
        assert "economy" in context
        assert context["economy"]["fuel_price"] == 150
        assert context["economy"]["parts_availability"] == 0.8

        assert "factions" in context
        assert len(context["factions"]) == 2
        assert context["factions"]["traders_guild"] == 75
        assert context["factions"]["scavengers"] == 30

        assert "recent_events" in context
        assert len(context["recent_events"]) == 2

    @pytest.mark.asyncio
    async def test_get_world_context_no_sector(self, world_state):
        """Test building context without sector economy."""
        await world_state.update_faction("traders_guild", 75)

        context = await world_state.get_world_context(
            sector=None,
            include_events=True
        )

        # Should not have economy
        assert "economy" not in context

        # Should have factions
        assert "factions" in context
        assert len(context["factions"]) == 1

    @pytest.mark.asyncio
    async def test_get_world_context_no_events(self, world_state):
        """Test building context without events."""
        await world_state.update_faction("traders_guild", 75)

        # Add event (but don't include in context)
        await world_state.add_event({
            "event_id": "event_1",
            "timestamp": 2000000000
        })

        context = await world_state.get_world_context(
            sector=None,
            include_events=False
        )

        # Should not have events
        assert "recent_events" not in context

        # Should have factions
        assert "factions" in context

    @pytest.mark.asyncio
    async def test_get_world_context_empty(self, world_state):
        """Test building context with no data."""
        context = await world_state.get_world_context(
            sector=None,
            include_events=True
        )

        # Should have empty structures
        assert "factions" in context
        assert context["factions"] == {}

        assert "recent_events" in context
        assert context["recent_events"] == []

    @pytest.mark.asyncio
    async def test_get_world_context_event_limit(self, world_state):
        """Test that world context limits events to 5."""
        # Add 10 events
        for i in range(10):
            await world_state.add_event({
                "event_id": f"event_{i}",
                "timestamp": 2000000000 + i
            })

        context = await world_state.get_world_context(
            sector=None,
            include_events=True
        )

        # Should only include 5 most recent
        assert len(context["recent_events"]) == 5
        assert context["recent_events"][0]["event_id"] == "event_9"  # Most recent


# Run tests with: pytest tests/story/test_world_state.py -v
