"""
Unit tests for MemoryManager

Tests player story memory tracking:
- Choice recording (FIFO, max 100)
- Relationship tracking (-100 to +100)
- Consequence tracking and resolution
- Story state and flags
- Context building
"""

import pytest
import json
from datetime import datetime
from fakeredis import FakeAsyncRedis
from src.story.memory_manager import MemoryManager


@pytest.fixture
async def redis_client():
    """Create fake Redis client for testing."""
    return FakeAsyncRedis(decode_responses=True)


@pytest.fixture
async def memory_manager(redis_client):
    """Create MemoryManager instance with fake Redis."""
    return MemoryManager(redis_client)


class TestChoiceTracking:
    """Test player choice recording and retrieval."""

    @pytest.mark.asyncio
    async def test_add_single_choice(self, memory_manager):
        """Test adding a single choice."""
        choice = {
            "choice_id": "investigate",
            "mission_id": "tutorial",
            "stage_id": "stage_1",
            "outcome": "success"
        }

        await memory_manager.add_choice("player_1", choice)

        # Retrieve and verify
        choices = await memory_manager.get_choices("player_1", limit=1)
        assert len(choices) == 1
        assert choices[0]["choice_id"] == "investigate"
        assert "timestamp" in choices[0]  # Auto-added

    @pytest.mark.asyncio
    async def test_choice_ordering(self, memory_manager):
        """Test choices are returned in reverse chronological order."""
        # Add 3 choices
        for i in range(3):
            choice = {"choice_id": f"choice_{i}", "mission_id": "test"}
            await memory_manager.add_choice("player_1", choice)

        # Retrieve
        choices = await memory_manager.get_choices("player_1", limit=3)

        # Most recent first
        assert choices[0]["choice_id"] == "choice_2"
        assert choices[1]["choice_id"] == "choice_1"
        assert choices[2]["choice_id"] == "choice_0"

    @pytest.mark.asyncio
    async def test_choice_fifo_limit(self, memory_manager):
        """Test FIFO behavior at max 100 choices."""
        # Add 105 choices
        for i in range(105):
            choice = {"choice_id": f"choice_{i}", "mission_id": "test"}
            await memory_manager.add_choice("player_1", choice)

        # Should only keep last 100
        choices = await memory_manager.get_choices("player_1", limit=150)
        assert len(choices) == 100

        # Oldest should be choice_5, newest should be choice_104
        assert choices[-1]["choice_id"] == "choice_5"  # Oldest kept
        assert choices[0]["choice_id"] == "choice_104"  # Newest


class TestRelationships:
    """Test NPC/faction relationship tracking."""

    @pytest.mark.asyncio
    async def test_update_relationship_from_zero(self, memory_manager):
        """Test relationship starting from 0."""
        score = await memory_manager.update_relationship("player_1", "mechanic", 15)
        assert score == 15

    @pytest.mark.asyncio
    async def test_update_relationship_cumulative(self, memory_manager):
        """Test cumulative relationship updates."""
        await memory_manager.update_relationship("player_1", "mechanic", 10)
        await memory_manager.update_relationship("player_1", "mechanic", 5)
        score = await memory_manager.update_relationship("player_1", "mechanic", -3)

        assert score == 12  # 10 + 5 - 3

    @pytest.mark.asyncio
    async def test_relationship_clamping_positive(self, memory_manager):
        """Test relationship clamping at +100."""
        score = await memory_manager.update_relationship("player_1", "ally", 150)
        assert score == 100  # Clamped

    @pytest.mark.asyncio
    async def test_relationship_clamping_negative(self, memory_manager):
        """Test relationship clamping at -100."""
        score = await memory_manager.update_relationship("player_1", "enemy", -150)
        assert score == -100  # Clamped

    @pytest.mark.asyncio
    async def test_get_all_relationships(self, memory_manager):
        """Test retrieving all relationships."""
        await memory_manager.update_relationship("player_1", "mechanic", 15)
        await memory_manager.update_relationship("player_1", "trader", -30)
        await memory_manager.update_relationship("player_1", "companion", 50)

        relationships = await memory_manager.get_relationships("player_1")

        assert len(relationships) == 3
        assert relationships["mechanic"] == 15
        assert relationships["trader"] == -30
        assert relationships["companion"] == 50


class TestConsequences:
    """Test consequence tracking and resolution."""

    @pytest.mark.asyncio
    async def test_track_consequence(self, memory_manager):
        """Test tracking a consequence."""
        consequence = {
            "consequence_id": "shipyard_collapse",
            "mission_id": "tutorial",
            "can_callback_after": 3
        }

        await memory_manager.track_consequence("player_1", consequence)

        # Verify tracked
        active = await memory_manager.get_active_consequences("player_1")
        assert len(active) == 1
        assert active[0]["consequence_id"] == "shipyard_collapse"
        assert active[0]["resolved"] is False

    @pytest.mark.asyncio
    async def test_resolve_consequence(self, memory_manager):
        """Test resolving a consequence."""
        consequence = {
            "consequence_id": "shipyard_collapse",
            "mission_id": "tutorial"
        }

        await memory_manager.track_consequence("player_1", consequence)

        # Resolve it
        resolved = await memory_manager.resolve_consequence("player_1", "shipyard_collapse")
        assert resolved is True

        # Should no longer be active
        active = await memory_manager.get_active_consequences("player_1")
        assert len(active) == 0

    @pytest.mark.asyncio
    async def test_resolve_nonexistent_consequence(self, memory_manager):
        """Test resolving consequence that doesn't exist."""
        resolved = await memory_manager.resolve_consequence("player_1", "fake_id")
        assert resolved is False


class TestStoryState:
    """Test story state and flags."""

    @pytest.mark.asyncio
    async def test_update_story_state(self, memory_manager):
        """Test updating story state fields."""
        await memory_manager.update_story_state(
            "player_1",
            current_mission="tutorial",
            story_arc="main"
        )

        state = await memory_manager.get_story_state("player_1")
        assert state["current_mission"] == "tutorial"
        assert state["story_arc"] == "main"

    @pytest.mark.asyncio
    async def test_add_story_flag(self, memory_manager):
        """Test adding story flag."""
        await memory_manager.add_story_flag("player_1", "cautious_explorer")

        has_flag = await memory_manager.has_story_flag("player_1", "cautious_explorer")
        assert has_flag is True

    @pytest.mark.asyncio
    async def test_duplicate_flag_not_added(self, memory_manager):
        """Test adding same flag twice doesn't duplicate."""
        await memory_manager.add_story_flag("player_1", "cautious")
        await memory_manager.add_story_flag("player_1", "cautious")

        # Get flags from state
        state = await memory_manager.get_story_state("player_1")
        flags = json.loads(state.get("flags", "[]"))

        assert flags.count("cautious") == 1

    @pytest.mark.asyncio
    async def test_has_flag_nonexistent(self, memory_manager):
        """Test checking for flag that doesn't exist."""
        has_flag = await memory_manager.has_story_flag("player_1", "nonexistent")
        assert has_flag is False


class TestContextBuilding:
    """Test comprehensive context building."""

    @pytest.mark.asyncio
    async def test_get_context_complete(self, memory_manager):
        """Test building complete context with all data."""
        # Add choices
        for i in range(3):
            await memory_manager.add_choice("player_1", {
                "choice_id": f"choice_{i}",
                "mission_id": "test"
            })

        # Add relationships
        await memory_manager.update_relationship("player_1", "mechanic", 15)
        await memory_manager.update_relationship("player_1", "trader", -20)

        # Add consequence
        await memory_manager.track_consequence("player_1", {
            "consequence_id": "collapse_risk",
            "mission_id": "tutorial"
        })

        # Update story state
        await memory_manager.update_story_state(
            "player_1",
            current_mission="tutorial",
            story_arc="main"
        )

        # Build context
        context = await memory_manager.get_context("player_1", limit=3)

        # Verify all components
        assert len(context["recent_choices"]) == 3
        assert len(context["relationships"]) == 2
        assert len(context["active_consequences"]) == 1
        assert context["story_state"]["current_mission"] == "tutorial"

    @pytest.mark.asyncio
    async def test_get_context_empty_player(self, memory_manager):
        """Test context for player with no data."""
        context = await memory_manager.get_context("new_player")

        assert context["recent_choices"] == []
        assert context["relationships"] == {}
        assert context["active_consequences"] == []
        assert context["story_state"] == {}


# Run tests with: pytest tests/story/test_memory_manager.py -v
