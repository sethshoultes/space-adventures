"""
Unit tests for StoryEngine

Tests on-demand narrative generation:
- Player state hashing (same state = same hash, different state = different hash)
- Cache hit scenario (same request returns cached narrative)
- Cache miss scenario (new request generates narrative)
- Cache invalidation
- Narrative prompt building (includes player context, relationships, world state)
- Choice outcome generation
- Consequence tracking integration
"""

import pytest
import pytest_asyncio
import json
from datetime import datetime
from unittest.mock import AsyncMock, MagicMock, patch
from fakeredis import FakeAsyncRedis
from src.story.story_engine import StoryEngine
from src.story.memory_manager import MemoryManager


@pytest_asyncio.fixture
async def redis_client():
    """Create fake Redis client for testing."""
    return FakeAsyncRedis(decode_responses=True)


@pytest_asyncio.fixture
async def mock_llm_client():
    """Create mock LLM client."""
    mock = AsyncMock()
    mock.generate = AsyncMock(return_value="Generated narrative text.")
    return mock


@pytest_asyncio.fixture
async def memory_manager(redis_client):
    """Create MemoryManager instance with fake Redis."""
    return MemoryManager(redis_client)


@pytest_asyncio.fixture
async def story_engine(redis_client, mock_llm_client, memory_manager):
    """Create StoryEngine instance with fake Redis and mock LLM."""
    return StoryEngine(
        redis_client=redis_client,
        llm_client=mock_llm_client,
        memory_manager=memory_manager,
        cache_ttl=3600
    )


@pytest.fixture
def sample_mission_template():
    """Sample hybrid mission template."""
    return {
        "mission_id": "tutorial_mission",
        "title": "First Steps",
        "type": "tutorial",
        "context": {
            "location": "Abandoned Shipyard",
            "theme": "Exploration",
            "tone": "Serious sci-fi",
            "key_npcs": ["Mechanic", "Trader"]
        },
        "stages": [
            {
                "stage_id": "stage_1",
                "narrative_structure": {
                    "setup": "You arrive at the abandoned shipyard.",
                    "conflict": "The main entrance is sealed.",
                    "prompt": "Describe finding an alternative way in.",
                    "include": ["environmental details", "tension"]
                },
                "choices": []
            },
            {
                "stage_id": "stage_2",
                "narrative_structure": {
                    "setup": "Inside the shipyard, equipment lies scattered.",
                    "conflict": "You hear footsteps approaching.",
                    "prompt": "Describe the encounter.",
                    "include": ["NPC introduction", "atmosphere"]
                },
                "choices": []
            }
        ]
    }


@pytest.fixture
def sample_player_state():
    """Sample player state."""
    return {
        "level": 5,
        "current_mission": "tutorial_mission",
        "completed_missions": ["intro", "first_salvage"],
        "phase": 1
    }


class TestPlayerStateHashing:
    """Test player state hashing for cache keys."""

    @pytest.mark.asyncio
    async def test_same_state_same_hash(self, story_engine, sample_player_state):
        """Test that identical player states produce identical hashes."""
        hash1 = story_engine._hash_player_state(sample_player_state)
        hash2 = story_engine._hash_player_state(sample_player_state)

        assert hash1 == hash2
        assert len(hash1) == 16  # First 16 chars of SHA256

    @pytest.mark.asyncio
    async def test_different_state_different_hash(self, story_engine, sample_player_state):
        """Test that different player states produce different hashes."""
        hash1 = story_engine._hash_player_state(sample_player_state)

        # Modify state
        modified_state = sample_player_state.copy()
        modified_state["level"] = 10
        hash2 = story_engine._hash_player_state(modified_state)

        assert hash1 != hash2

    @pytest.mark.asyncio
    async def test_hash_ignores_irrelevant_fields(self, story_engine, sample_player_state):
        """Test that hash ignores fields not used for cache key."""
        hash1 = story_engine._hash_player_state(sample_player_state)

        # Add irrelevant fields
        state_with_extra = sample_player_state.copy()
        state_with_extra["inventory"] = ["item1", "item2", "item3"]
        state_with_extra["timestamp"] = int(datetime.utcnow().timestamp())
        hash2 = story_engine._hash_player_state(state_with_extra)

        # Should be same because inventory and timestamp aren't used for hash
        assert hash1 == hash2

    @pytest.mark.asyncio
    async def test_hash_respects_mission_count(self, story_engine, sample_player_state):
        """Test that hash changes when mission count changes."""
        hash1 = story_engine._hash_player_state(sample_player_state)

        # Add completed mission
        modified_state = sample_player_state.copy()
        modified_state["completed_missions"] = ["intro", "first_salvage", "new_mission"]
        hash2 = story_engine._hash_player_state(modified_state)

        assert hash1 != hash2


class TestCaching:
    """Test narrative caching behavior."""

    @pytest.mark.asyncio
    async def test_cache_miss_generates_narrative(
        self,
        story_engine,
        sample_mission_template,
        sample_player_state
    ):
        """Test that cache miss triggers narrative generation."""
        result = await story_engine.generate_stage_narrative(
            player_id="player_1",
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_state=sample_player_state,
            world_context={}
        )

        assert result["cached"] is False
        assert "narrative" in result
        assert result["generation_time_ms"] >= 0

    @pytest.mark.asyncio
    async def test_cache_hit_returns_cached_narrative(
        self,
        story_engine,
        sample_mission_template,
        sample_player_state
    ):
        """Test that same request returns cached narrative."""
        # First request (cache miss)
        result1 = await story_engine.generate_stage_narrative(
            player_id="player_1",
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_state=sample_player_state,
            world_context={}
        )

        # Second request (cache hit)
        result2 = await story_engine.generate_stage_narrative(
            player_id="player_1",
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_state=sample_player_state,
            world_context={}
        )

        assert result1["cached"] is False
        assert result2["cached"] is True
        assert result1["narrative"] == result2["narrative"]

    @pytest.mark.asyncio
    async def test_different_stage_not_cached(
        self,
        story_engine,
        sample_mission_template,
        sample_player_state
    ):
        """Test that different stages have separate cache entries."""
        # Request stage 1
        result1 = await story_engine.generate_stage_narrative(
            player_id="player_1",
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_state=sample_player_state,
            world_context={}
        )

        # Request stage 2 (different stage)
        result2 = await story_engine.generate_stage_narrative(
            player_id="player_1",
            mission_template=sample_mission_template,
            stage_id="stage_2",
            player_state=sample_player_state,
            world_context={}
        )

        # Both should be cache misses
        assert result1["cached"] is False
        assert result2["cached"] is False

    @pytest.mark.asyncio
    async def test_different_player_state_not_cached(
        self,
        story_engine,
        sample_mission_template,
        sample_player_state
    ):
        """Test that different player states have separate cache entries."""
        # Request with level 5
        result1 = await story_engine.generate_stage_narrative(
            player_id="player_1",
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_state=sample_player_state,
            world_context={}
        )

        # Request with level 10 (different state)
        modified_state = sample_player_state.copy()
        modified_state["level"] = 10
        result2 = await story_engine.generate_stage_narrative(
            player_id="player_1",
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_state=modified_state,
            world_context={}
        )

        # Both should be cache misses
        assert result1["cached"] is False
        assert result2["cached"] is False


class TestCacheInvalidation:
    """Test cache invalidation."""

    @pytest.mark.asyncio
    async def test_invalidate_cache(
        self,
        story_engine,
        sample_mission_template,
        sample_player_state
    ):
        """Test cache invalidation for mission."""
        # Generate and cache narrative
        await story_engine.generate_stage_narrative(
            player_id="player_1",
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_state=sample_player_state,
            world_context={}
        )

        # Invalidate cache
        deleted = await story_engine.invalidate_cache(
            player_id="player_1",
            mission_id="tutorial_mission",
            player_state=sample_player_state
        )

        assert deleted > 0

    @pytest.mark.asyncio
    async def test_after_invalidation_cache_miss(
        self,
        story_engine,
        sample_mission_template,
        sample_player_state
    ):
        """Test that requests after invalidation are cache misses."""
        # Generate and cache narrative
        await story_engine.generate_stage_narrative(
            player_id="player_1",
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_state=sample_player_state,
            world_context={}
        )

        # Invalidate
        await story_engine.invalidate_cache(
            player_id="player_1",
            mission_id="tutorial_mission",
            player_state=sample_player_state
        )

        # Request again (should be cache miss)
        result = await story_engine.generate_stage_narrative(
            player_id="player_1",
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_state=sample_player_state,
            world_context={}
        )

        assert result["cached"] is False


class TestNarrativePromptBuilding:
    """Test narrative prompt construction."""

    @pytest.mark.asyncio
    async def test_prompt_includes_mission_context(
        self,
        story_engine,
        sample_mission_template
    ):
        """Test that prompt includes mission context fields."""
        prompt = await story_engine._build_narrative_prompt(
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_context={},
            world_context={}
        )

        # Should include mission context
        assert "Abandoned Shipyard" in prompt
        assert "Exploration" in prompt
        assert "Mechanic" in prompt
        assert "Trader" in prompt

    @pytest.mark.asyncio
    async def test_prompt_includes_narrative_structure(
        self,
        story_engine,
        sample_mission_template
    ):
        """Test that prompt includes narrative structure."""
        prompt = await story_engine._build_narrative_prompt(
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_context={},
            world_context={}
        )

        # Should include narrative structure
        assert "You arrive at the abandoned shipyard" in prompt
        assert "The main entrance is sealed" in prompt
        assert "Describe finding an alternative way in" in prompt

    @pytest.mark.asyncio
    async def test_prompt_includes_player_choices(
        self,
        story_engine,
        sample_mission_template
    ):
        """Test that prompt includes player choice history."""
        player_context = {
            "recent_choices": [
                {"choice_id": "investigate", "outcome": "success"},
                {"choice_id": "negotiate", "outcome": "partial"}
            ],
            "relationships": {},
            "active_consequences": []
        }

        prompt = await story_engine._build_narrative_prompt(
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_context=player_context,
            world_context={}
        )

        # Should include choices
        assert "investigate" in prompt
        assert "negotiate" in prompt

    @pytest.mark.asyncio
    async def test_prompt_includes_relationships(
        self,
        story_engine,
        sample_mission_template
    ):
        """Test that prompt includes relationship information."""
        player_context = {
            "recent_choices": [],
            "relationships": {
                "mechanic": 50,
                "trader": -30
            },
            "active_consequences": []
        }

        prompt = await story_engine._build_narrative_prompt(
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_context=player_context,
            world_context={}
        )

        # Should include relationships
        assert "mechanic" in prompt
        assert "trader" in prompt
        assert "50" in prompt or "positive" in prompt
        assert "-30" in prompt or "negative" in prompt

    @pytest.mark.asyncio
    async def test_prompt_includes_consequences(
        self,
        story_engine,
        sample_mission_template
    ):
        """Test that prompt includes active consequences."""
        player_context = {
            "recent_choices": [],
            "relationships": {},
            "active_consequences": [
                {"consequence_id": "shipyard_damage", "mission_id": "prev"}
            ]
        }

        prompt = await story_engine._build_narrative_prompt(
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_context=player_context,
            world_context={}
        )

        # Should include consequences
        assert "shipyard_damage" in prompt

    @pytest.mark.asyncio
    async def test_prompt_includes_world_context(
        self,
        story_engine,
        sample_mission_template
    ):
        """Test that prompt includes world state context."""
        world_context = {
            "economy": {"fuel_price": 150, "parts_availability": 0.8},
            "factions": {"traders_guild": 75, "scavengers": 30}
        }

        prompt = await story_engine._build_narrative_prompt(
            mission_template=sample_mission_template,
            stage_id="stage_1",
            player_context={},
            world_context=world_context
        )

        # Should include world state
        assert "economy" in prompt.lower() or "Economy" in prompt
        assert "factions" in prompt.lower() or "Factions" in prompt


class TestChoiceOutcomeGeneration:
    """Test choice outcome generation."""

    @pytest.mark.asyncio
    async def test_generate_choice_outcome(
        self,
        story_engine,
        memory_manager,
        sample_player_state
    ):
        """Test generating outcome for a choice."""
        choice = {
            "choice_id": "investigate_door",
            "type": "action",
            "outcome_prompt": "What happens when you investigate?",
            "paths": {
                "success": {"next_stage": "stage_2"},
                "failure": {"next_stage": "stage_fail"}
            },
            "consequence_tracking": {
                "flags": ["investigated_door"],
                "relationships": {"mechanic": 10},
                "world_impact": "door_opened"
            }
        }

        result = await story_engine.generate_choice_outcome(
            player_id="player_1",
            choice=choice,
            player_state=sample_player_state,
            world_context={}
        )

        assert "outcome" in result
        assert "narrative" in result
        assert "consequences" in result
        assert "next_stage" in result
        assert result["generation_time_ms"] >= 0

    @pytest.mark.asyncio
    async def test_outcome_tracks_flags(
        self,
        story_engine,
        memory_manager,
        sample_player_state
    ):
        """Test that outcome tracking adds story flags."""
        choice = {
            "choice_id": "test_choice",
            "type": "action",
            "paths": {"success": {"next_stage": "next"}},
            "consequence_tracking": {
                "flags": ["flag_1", "flag_2"]
            }
        }

        await story_engine.generate_choice_outcome(
            player_id="player_1",
            choice=choice,
            player_state=sample_player_state,
            world_context={}
        )

        # Check flags were added
        has_flag1 = await memory_manager.has_story_flag("player_1", "flag_1")
        has_flag2 = await memory_manager.has_story_flag("player_1", "flag_2")

        assert has_flag1 is True
        assert has_flag2 is True

    @pytest.mark.asyncio
    async def test_outcome_updates_relationships(
        self,
        story_engine,
        memory_manager,
        sample_player_state
    ):
        """Test that outcome tracking updates relationships."""
        choice = {
            "choice_id": "test_choice",
            "type": "action",
            "paths": {"success": {"next_stage": "next"}},
            "consequence_tracking": {
                "relationships": {
                    "mechanic": 15,
                    "trader": -10
                }
            }
        }

        await story_engine.generate_choice_outcome(
            player_id="player_1",
            choice=choice,
            player_state=sample_player_state,
            world_context={}
        )

        # Check relationships were updated
        relationships = await memory_manager.get_relationships("player_1")

        assert relationships["mechanic"] == 15
        assert relationships["trader"] == -10

    @pytest.mark.asyncio
    async def test_outcome_tracks_world_impact(
        self,
        story_engine,
        memory_manager,
        sample_player_state
    ):
        """Test that outcome tracking creates consequence for world impact."""
        choice = {
            "choice_id": "test_choice",
            "type": "action",
            "paths": {"success": {"next_stage": "next"}},
            "consequence_tracking": {
                "world_impact": "major_event_occurred"
            }
        }

        await story_engine.generate_choice_outcome(
            player_id="player_1",
            choice=choice,
            player_state=sample_player_state,
            world_context={}
        )

        # Check consequence was tracked
        consequences = await memory_manager.get_active_consequences("player_1")

        assert len(consequences) == 1
        assert consequences[0]["consequence_id"] == "major_event_occurred"


# Run tests with: pytest tests/story/test_story_engine.py -v
