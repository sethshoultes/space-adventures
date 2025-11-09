"""
Unit tests for MissionPool

Tests lazy queue for generic side missions:
- Get mission from full queue (queue hit)
- Get mission from empty queue (queue miss, generates)
- Lazy queue filling (reactive when below threshold)
- Queue doesn't overfill (respects max size)
- Count available missions
- Clear queue
- Different difficulties
- Mission template generation
"""

import pytest
import pytest_asyncio
import json
from unittest.mock import AsyncMock
from fakeredis import FakeAsyncRedis
from src.story.mission_pool import MissionPool


@pytest_asyncio.fixture
async def redis_client():
    """Create fake Redis client for testing."""
    return FakeAsyncRedis(decode_responses=True)


@pytest_asyncio.fixture
async def mock_llm_client():
    """Create mock LLM client."""
    mock = AsyncMock()
    mock.generate = AsyncMock(return_value="Generated mission content.")
    return mock


@pytest_asyncio.fixture
async def mission_pool(redis_client, mock_llm_client):
    """Create MissionPool instance with fake Redis."""
    return MissionPool(
        redis_client=redis_client,
        llm_client=mock_llm_client,
        queue_size=3,
        min_threshold=2
    )


class TestQueueBehavior:
    """Test basic queue hit/miss behavior."""

    @pytest.mark.asyncio
    async def test_queue_miss_generates_mission(self, mission_pool):
        """Test that empty queue generates mission on demand."""
        result = await mission_pool.get_mission(difficulty="medium")

        assert result["source"] == "generated"
        assert result["queue_count"] == 0
        assert "mission" in result
        assert result["mission"]["difficulty"] == "medium"

    @pytest.mark.asyncio
    async def test_queue_hit_returns_cached(self, mission_pool, redis_client):
        """Test that full queue returns cached mission."""
        # Pre-fill queue manually
        mission = {
            "mission_id": "cached_mission",
            "title": "Cached Mission",
            "difficulty": "medium"
        }
        await redis_client.rpush("mission_pool:medium", json.dumps(mission))

        # Get mission
        result = await mission_pool.get_mission(difficulty="medium")

        assert result["source"] == "queue"
        assert result["mission"]["mission_id"] == "cached_mission"

    @pytest.mark.asyncio
    async def test_queue_miss_fills_queue(self, mission_pool, redis_client):
        """Test that queue miss triggers background fill."""
        # Get mission from empty queue
        await mission_pool.get_mission(difficulty="medium")

        # Queue should be filled after
        queue_length = await redis_client.llen("mission_pool:medium")

        # Should have filled to queue_size (3)
        assert queue_length == 3

    @pytest.mark.asyncio
    async def test_sequential_requests_use_queue(self, mission_pool):
        """Test that sequential requests use queue after initial fill."""
        # First request (miss, fills queue)
        result1 = await mission_pool.get_mission(difficulty="medium")
        assert result1["source"] == "generated"

        # Second request (hit from queue)
        result2 = await mission_pool.get_mission(difficulty="medium")
        assert result2["source"] == "queue"

        # Third request (hit from queue)
        result3 = await mission_pool.get_mission(difficulty="medium")
        assert result3["source"] == "queue"


class TestLazyQueueFilling:
    """Test reactive queue filling behavior."""

    @pytest.mark.asyncio
    async def test_queue_refills_below_threshold(self, mission_pool, redis_client):
        """Test that queue refills when it drops below threshold."""
        # Pre-fill with 2 missions (at threshold)
        for i in range(2):
            mission = {"mission_id": f"mission_{i}", "difficulty": "easy"}
            await redis_client.rpush("mission_pool:easy", json.dumps(mission))

        # Get one mission (drops below threshold)
        await mission_pool.get_mission(difficulty="easy")

        # Queue should refill to queue_size (3)
        queue_length = await redis_client.llen("mission_pool:easy")
        assert queue_length == 3

    @pytest.mark.asyncio
    async def test_queue_doesnt_overfill(self, mission_pool, redis_client):
        """Test that queue respects max size."""
        # Pre-fill queue to max
        for i in range(3):
            mission = {"mission_id": f"mission_{i}", "difficulty": "hard"}
            await redis_client.rpush("mission_pool:hard", json.dumps(mission))

        # Get mission (pops one, leaving 2, which is at threshold so no refill yet)
        await mission_pool.get_mission(difficulty="hard")

        # Queue should have 2 remaining (at threshold)
        queue_length = await redis_client.llen("mission_pool:hard")
        assert queue_length == 2

        # Get another mission (now below threshold, triggers refill to 3)
        await mission_pool.get_mission(difficulty="hard")

        # Queue should now refill to exactly queue_size (3), not more
        queue_length = await redis_client.llen("mission_pool:hard")
        assert queue_length == 3

    @pytest.mark.asyncio
    async def test_fill_generates_correct_count(self, mission_pool, redis_client):
        """Test that fill generates exactly the right number of missions."""
        # Start with 1 mission (need 2 more to reach queue_size of 3)
        mission = {"mission_id": "existing", "difficulty": "medium"}
        await redis_client.rpush("mission_pool:medium", json.dumps(mission))

        # Trigger fill
        generated = await mission_pool._fill_queue_if_low("medium")

        # Should generate 2 missions
        assert generated == 2

        # Queue should now have 3 total
        queue_length = await redis_client.llen("mission_pool:medium")
        assert queue_length == 3

    @pytest.mark.asyncio
    async def test_no_fill_when_queue_full(self, mission_pool, redis_client):
        """Test that full queue doesn't trigger fill."""
        # Fill queue to max
        for i in range(3):
            mission = {"mission_id": f"mission_{i}", "difficulty": "extreme"}
            await redis_client.rpush("mission_pool:extreme", json.dumps(mission))

        # Try to fill
        generated = await mission_pool._fill_queue_if_low("extreme")

        # Should generate 0 missions
        assert generated == 0


class TestDifficulties:
    """Test different difficulty levels."""

    @pytest.mark.asyncio
    async def test_different_difficulties_separate_queues(self, mission_pool):
        """Test that each difficulty has its own queue."""
        # Get missions for different difficulties
        easy_result = await mission_pool.get_mission(difficulty="easy")
        hard_result = await mission_pool.get_mission(difficulty="hard")

        assert easy_result["mission"]["difficulty"] == "easy"
        assert hard_result["mission"]["difficulty"] == "hard"

    @pytest.mark.asyncio
    async def test_invalid_difficulty_defaults_to_medium(self, mission_pool):
        """Test that invalid difficulty defaults to medium."""
        result = await mission_pool.get_mission(difficulty="invalid")

        assert result["mission"]["difficulty"] == "medium"

    @pytest.mark.asyncio
    async def test_all_difficulty_levels(self, mission_pool):
        """Test that all difficulty levels work."""
        difficulties = ["easy", "medium", "hard", "extreme"]

        for difficulty in difficulties:
            result = await mission_pool.get_mission(difficulty=difficulty)
            assert result["mission"]["difficulty"] == difficulty


class TestMissionGeneration:
    """Test mission template generation."""

    @pytest.mark.asyncio
    async def test_generated_mission_has_required_fields(self, mission_pool):
        """Test that generated missions have all required fields."""
        result = await mission_pool.get_mission(difficulty="medium")
        mission = result["mission"]

        # Required fields
        assert "mission_id" in mission
        assert "title" in mission
        assert "type" in mission
        assert "difficulty" in mission
        assert "description" in mission
        assert "location" in mission
        assert "rewards" in mission

    @pytest.mark.asyncio
    async def test_salvage_mission_template(self, mission_pool):
        """Test salvage mission template structure."""
        # Generate multiple missions until we get a salvage
        for _ in range(10):
            result = await mission_pool.get_mission(difficulty="easy")
            mission = result["mission"]

            if mission["type"] == "salvage":
                assert mission["title"] == "Salvage Operation"
                assert mission["location"] == "Debris Field"
                assert "items" in mission["rewards"]
                break

    @pytest.mark.asyncio
    async def test_exploration_mission_template(self, mission_pool):
        """Test exploration mission template structure."""
        # Generate multiple missions until we get exploration
        for _ in range(10):
            result = await mission_pool.get_mission(difficulty="medium")
            mission = result["mission"]

            if mission["type"] == "exploration":
                assert mission["title"] == "Survey Mission"
                assert mission["location"] == "Unknown Sector"
                assert "nav_data" in mission["rewards"].get("items", [])
                break

    @pytest.mark.asyncio
    async def test_trade_mission_template(self, mission_pool):
        """Test trade mission template structure."""
        # Generate multiple missions until we get trade
        for _ in range(10):
            result = await mission_pool.get_mission(difficulty="hard")
            mission = result["mission"]

            if mission["type"] == "trade":
                assert mission["title"] == "Cargo Run"
                assert mission["location"] == "Trade Route"
                assert "credits" in mission["rewards"]
                break

    @pytest.mark.asyncio
    async def test_reward_scaling_by_difficulty(self, mission_pool):
        """Test that rewards scale with difficulty."""
        easy_result = await mission_pool.get_mission(difficulty="easy")
        extreme_result = await mission_pool.get_mission(difficulty="extreme")

        easy_reward = easy_result["mission"]["rewards"]["credits"]
        extreme_reward = extreme_result["mission"]["rewards"]["credits"]

        # Extreme should have higher reward than easy
        assert extreme_reward > easy_reward

    @pytest.mark.asyncio
    async def test_mission_ids_unique(self, mission_pool):
        """Test that generated missions have unique IDs when generated separately."""
        # Clear queue to ensure fresh generation
        await mission_pool.clear_queue(difficulty="medium")

        # Generate first batch (will fill queue)
        result1 = await mission_pool.get_mission(difficulty="medium")

        # Clear queue again to force new generation
        await mission_pool.clear_queue(difficulty="medium")

        # Generate second batch
        result2 = await mission_pool.get_mission(difficulty="medium")

        mission1_id = result1["mission"]["mission_id"]
        mission2_id = result2["mission"]["mission_id"]

        # IDs should be different (timestamp-based) since generated at different times
        assert mission1_id != mission2_id


class TestCountAndClear:
    """Test counting and clearing queues."""

    @pytest.mark.asyncio
    async def test_count_available_single_difficulty(self, mission_pool, redis_client):
        """Test counting missions in single difficulty queue."""
        # Add 2 missions
        for i in range(2):
            mission = {"mission_id": f"mission_{i}", "difficulty": "medium"}
            await redis_client.rpush("mission_pool:medium", json.dumps(mission))

        counts = await mission_pool.count_available(difficulty="medium")

        assert counts["medium"] == 2

    @pytest.mark.asyncio
    async def test_count_available_all_difficulties(self, mission_pool, redis_client):
        """Test counting missions across all difficulties."""
        # Add missions to different queues
        await redis_client.rpush("mission_pool:easy", json.dumps({"id": "1"}))
        await redis_client.rpush("mission_pool:easy", json.dumps({"id": "2"}))
        await redis_client.rpush("mission_pool:medium", json.dumps({"id": "3"}))
        await redis_client.rpush("mission_pool:hard", json.dumps({"id": "4"}))
        await redis_client.rpush("mission_pool:hard", json.dumps({"id": "5"}))
        await redis_client.rpush("mission_pool:hard", json.dumps({"id": "6"}))

        counts = await mission_pool.count_available()

        assert counts["easy"] == 2
        assert counts["medium"] == 1
        assert counts["hard"] == 3
        assert counts["extreme"] == 0

    @pytest.mark.asyncio
    async def test_count_available_empty_queues(self, mission_pool):
        """Test counting when all queues are empty."""
        counts = await mission_pool.count_available()

        assert counts["easy"] == 0
        assert counts["medium"] == 0
        assert counts["hard"] == 0
        assert counts["extreme"] == 0

    @pytest.mark.asyncio
    async def test_clear_queue_single_difficulty(self, mission_pool, redis_client):
        """Test clearing single difficulty queue."""
        # Add 3 missions
        for i in range(3):
            mission = {"mission_id": f"mission_{i}", "difficulty": "easy"}
            await redis_client.rpush("mission_pool:easy", json.dumps(mission))

        # Clear
        deleted = await mission_pool.clear_queue(difficulty="easy")

        assert deleted == 1  # Redis delete returns 1 if key existed

        # Verify empty
        queue_length = await redis_client.llen("mission_pool:easy")
        assert queue_length == 0

    @pytest.mark.asyncio
    async def test_clear_queue_all_difficulties(self, mission_pool, redis_client):
        """Test clearing all difficulty queues."""
        # Add missions to multiple queues
        await redis_client.rpush("mission_pool:easy", json.dumps({"id": "1"}))
        await redis_client.rpush("mission_pool:medium", json.dumps({"id": "2"}))
        await redis_client.rpush("mission_pool:hard", json.dumps({"id": "3"}))

        # Clear all
        deleted = await mission_pool.clear_queue()

        # At least 3 keys deleted (one per queue that had data)
        assert deleted >= 3

        # Verify all empty
        counts = await mission_pool.count_available()
        assert all(count == 0 for count in counts.values())

    @pytest.mark.asyncio
    async def test_clear_empty_queue(self, mission_pool):
        """Test clearing already empty queue."""
        deleted = await mission_pool.clear_queue(difficulty="medium")

        # Should return 0 (no key existed)
        assert deleted == 0


class TestQueueConsistency:
    """Test queue consistency and FIFO behavior."""

    @pytest.mark.asyncio
    async def test_fifo_order(self, mission_pool, redis_client):
        """Test that queue returns missions in FIFO order."""
        # Manually add missions with identifiable IDs
        missions = [
            {"mission_id": "first", "difficulty": "medium"},
            {"mission_id": "second", "difficulty": "medium"},
            {"mission_id": "third", "difficulty": "medium"}
        ]

        for mission in missions:
            await redis_client.rpush("mission_pool:medium", json.dumps(mission))

        # Get missions in order
        result1 = await mission_pool.get_mission(difficulty="medium")
        result2 = await mission_pool.get_mission(difficulty="medium")
        result3 = await mission_pool.get_mission(difficulty="medium")

        # Should return in FIFO order
        assert result1["mission"]["mission_id"] == "first"
        assert result2["mission"]["mission_id"] == "second"
        assert result3["mission"]["mission_id"] == "third"

    @pytest.mark.asyncio
    async def test_queue_count_decreases_on_get(self, mission_pool, redis_client):
        """Test that queue count decreases when missions are retrieved."""
        # Fill queue
        for i in range(3):
            mission = {"mission_id": f"mission_{i}", "difficulty": "hard"}
            await redis_client.rpush("mission_pool:hard", json.dumps(mission))

        # Get mission
        result = await mission_pool.get_mission(difficulty="hard")

        # Queue count should reflect remaining missions
        assert result["queue_count"] < 3

    @pytest.mark.asyncio
    async def test_multiple_gets_drain_queue(self, mission_pool, redis_client):
        """Test that multiple gets properly drain the queue."""
        # Fill queue with 3 missions
        for i in range(3):
            mission = {"mission_id": f"mission_{i}", "difficulty": "easy"}
            await redis_client.rpush("mission_pool:easy", json.dumps(mission))

        # Get all 3
        result1 = await mission_pool.get_mission(difficulty="easy")
        result2 = await mission_pool.get_mission(difficulty="easy")
        result3 = await mission_pool.get_mission(difficulty="easy")

        # All should be queue hits
        assert result1["source"] == "queue"
        assert result2["source"] == "queue"
        assert result3["source"] == "queue"

        # Fourth should be miss (queue drained, refilled)
        result4 = await mission_pool.get_mission(difficulty="easy")

        # Might be queue hit if refill happened, or generated
        # Either way, queue should be refilled
        final_count = await redis_client.llen("mission_pool:easy")
        assert final_count > 0


# Run tests with: pytest tests/story/test_mission_pool.py -v
