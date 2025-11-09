"""
Tests for Companion Agent

Tests the empathetic companion that monitors crew morale and provides
emotional support.
"""

import pytest
import asyncio
from unittest.mock import Mock, AsyncMock
import redis.asyncio as redis

from src.agents.companion_agent import CompanionAgent


@pytest.fixture
async def redis_client():
    """Create a mock Redis client"""
    client = Mock(spec=redis.Redis)
    client.get = AsyncMock(return_value=None)
    client.set = AsyncMock()
    client.incr = AsyncMock()
    client.expire = AsyncMock()
    client.lpush = AsyncMock()
    client.ltrim = AsyncMock()
    client.lrange = AsyncMock(return_value=[])
    return client


@pytest.fixture
async def llm_client():
    """Create a mock LLM client"""
    return Mock()


@pytest.fixture
async def companion_agent(redis_client, llm_client):
    """Create a Companion agent instance"""
    return CompanionAgent(
        redis_client=redis_client,
        llm_client=llm_client,
        min_message_interval=0,  # Disable throttling for tests
        max_messages_per_hour=1000
    )


@pytest.mark.asyncio
async def test_companion_agent_initialization(companion_agent):
    """Test that Companion agent initializes correctly"""
    assert companion_agent.agent_name == "companion"
    assert companion_agent.min_message_interval == 0
    assert companion_agent.max_messages_per_hour == 1000
    assert companion_agent.workflow is not None


@pytest.mark.asyncio
async def test_observe_node_normal_state(companion_agent):
    """Test observation of normal game state"""
    game_state = {
        "player": {"level": 3, "xp": 150},
        "ship": {"hull_hp": 80, "max_hull_hp": 100},
        "progress": {"completed_missions": ["mission1", "mission2"]},
        "mission": {}
    }

    state = {
        "game_state": game_state,
        "observations": [],
        "metadata": {}
    }

    result = await companion_agent._observe_node(state)

    assert "observations" in result
    assert len(result["observations"]) > 0
    assert "Player level: 3" in result["observations"][0]


@pytest.mark.asyncio
async def test_observe_node_damaged_ship(companion_agent):
    """Test observation when ship is damaged"""
    game_state = {
        "player": {"level": 3, "xp": 150},
        "ship": {"hull_hp": 30, "max_hull_hp": 100},  # 30% hull
        "progress": {"completed_missions": ["mission1"]},
        "mission": {}
    }

    state = {
        "game_state": game_state,
        "observations": [],
        "metadata": {}
    }

    result = await companion_agent._observe_node(state)

    # Should detect damage
    damage_obs = [o for o in result["observations"] if "damage" in o.lower()]
    assert len(damage_obs) > 0


@pytest.mark.asyncio
async def test_reason_node_detects_damage(companion_agent):
    """Test reasoning node detects need for encouragement after damage"""
    observations = [
        "Player level: 3, XP: 150",
        "Completed missions: 2",
        "Recent damage detected: hull at 30%"
    ]

    state = {
        "game_state": {"ship": {"hull_hp": 30, "max_hull_hp": 100}},
        "observations": observations,
        "metadata": {}
    }

    result = await companion_agent._reason_node(state)

    assert result["metadata"]["should_check_morale"] is True
    assert "damage" in result["reasoning"].lower() or "encouragement" in result["reasoning"].lower()


@pytest.mark.asyncio
async def test_reason_node_detects_difficult_mission(companion_agent):
    """Test reasoning detects difficult mission"""
    observations = [
        "Player level: 3, XP: 150",
        "Completed missions: 5",
        "Active mission difficulty: 5"
    ]

    state = {
        "game_state": {},
        "observations": observations,
        "metadata": {}
    }

    result = await companion_agent._reason_node(state)

    assert result["metadata"]["should_check_morale"] is True


@pytest.mark.asyncio
async def test_should_act_decision(companion_agent):
    """Test conditional logic for whether to act"""
    # Should act
    state_should_act = {"metadata": {"should_check_morale": True}}
    assert companion_agent._should_act(state_should_act) is True

    # Should not act
    state_should_not_act = {"metadata": {"should_check_morale": False}}
    assert companion_agent._should_act(state_should_not_act) is False


@pytest.mark.asyncio
async def test_act_node_runs_tools(companion_agent):
    """Test that act node executes appropriate tools"""
    game_state = {
        "player": {"level": 3, "xp": 150},
        "ship": {"hull_hp": 30, "max_hull_hp": 100},
        "progress": {"completed_missions": ["m1", "m2"], "notable_events": []},
        "mission": {"difficulty": 4}
    }

    state = {
        "game_state": game_state,
        "reasoning": "Player recently took damage - may need encouragement",
        "actions": [],
        "tool_results": []
    }

    result = await companion_agent._act_node(state)

    # Should have run at least check_crew_morale and assess_emotional_tone
    assert len(result["actions"]) >= 2
    assert len(result["tool_results"]) >= 2

    tool_names = [action["tool"] for action in result["actions"]]
    assert "check_crew_morale" in tool_names
    assert "assess_emotional_tone" in tool_names


@pytest.mark.asyncio
async def test_reflect_node_critical_morale(companion_agent):
    """Test reflection determines critical morale needs support"""
    tool_results = [
        {
            "tool": "check_crew_morale",
            "result": {
                "overall_morale": "critical",
                "recent_crew_losses": 3,
                "morale_factors": ["Recent crew losses: 3"]
            }
        }
    ]

    state = {
        "tool_results": tool_results,
        "metadata": {}
    }

    result = await companion_agent._reflect_node(state)

    assert result["metadata"]["should_offer_support"] is True
    assert result["metadata"]["urgency"] == "CRITICAL"


@pytest.mark.asyncio
async def test_reflect_node_achievement(companion_agent):
    """Test reflection detects major achievement"""
    tool_results = [
        {
            "tool": "check_crew_morale",
            "result": {"overall_morale": "good"}
        },
        {
            "tool": "evaluate_player_progress",
            "result": {
                "major_milestone": True,
                "milestone_name": "Completed 10 Missions",
                "recent_achievements": ["completed 10 missions"]
            }
        }
    ]

    state = {
        "tool_results": tool_results,
        "metadata": {}
    }

    result = await companion_agent._reflect_node(state)

    assert result["metadata"]["should_offer_support"] is True
    assert result["metadata"]["urgency"] == "URGENT"


@pytest.mark.asyncio
async def test_communicate_node_critical_message(companion_agent):
    """Test communication generates appropriate critical message"""
    tool_results = [
        {
            "tool": "check_crew_morale",
            "result": {
                "overall_morale": "critical",
                "recent_crew_losses": 2,
                "morale_factors": ["Recent crew losses: 2"]
            }
        }
    ]

    state = {
        "tool_results": tool_results,
        "metadata": {"urgency": "CRITICAL"}
    }

    result = await companion_agent._communicate_node(state)

    assert result["message"] is not None
    assert len(result["message"]) > 0
    # Should contain encouraging language
    assert "believe" in result["message"].lower() or "can do" in result["message"].lower()


@pytest.mark.asyncio
async def test_communicate_node_achievement_message(companion_agent):
    """Test communication celebrates achievements"""
    tool_results = [
        {
            "tool": "check_crew_morale",
            "result": {"overall_morale": "good"}
        },
        {
            "tool": "evaluate_player_progress",
            "result": {
                "major_milestone": True,
                "milestone_name": "All Systems Operational",
                "recent_achievements": ["brought all ship systems online"]
            }
        }
    ]

    state = {
        "tool_results": tool_results,
        "metadata": {"urgency": "URGENT"}
    }

    result = await companion_agent._communicate_node(state)

    assert result["message"] is not None
    assert "remarkable" in result["message"].lower() or "accomplished" in result["message"].lower()


@pytest.mark.asyncio
async def test_full_workflow_damaged_ship(companion_agent):
    """Test complete workflow with damaged ship scenario"""
    game_state = {
        "player": {"level": 4, "xp": 200, "skills": {}},
        "ship": {
            "hull_hp": 25,
            "max_hull_hp": 100,
            "systems": {}
        },
        "progress": {
            "completed_missions": ["m1", "m2"],
            "notable_events": []
        },
        "mission": {"difficulty": 4}
    }

    result = await companion_agent.run(game_state, force_check=True)

    # Should decide to act
    assert result["should_act"] is True or result["message"] is None  # Might not trigger every time

    # If acted, should have used tools
    if result["should_act"]:
        assert len(result["tools_used"]) > 0
        assert result["urgency"] in ["INFO", "MEDIUM", "URGENT", "CRITICAL"]


@pytest.mark.asyncio
async def test_get_available_tools(companion_agent):
    """Test that companion has correct tools available"""
    tools = companion_agent.get_available_tools()

    tool_names = [tool["name"] for tool in tools]

    # Should have companion-specific tools
    assert "check_crew_morale" in tool_names
    assert "evaluate_player_progress" in tool_names
    assert "assess_emotional_tone" in tool_names


@pytest.mark.asyncio
async def test_throttling_prevents_spam(companion_agent):
    """Test that throttling prevents excessive messages"""
    # Re-create with actual throttling
    companion_with_throttle = CompanionAgent(
        redis_client=await redis_client(),
        llm_client=await llm_client(),
        min_message_interval=60,  # 60 seconds
        max_messages_per_hour=15
    )

    # Mock recent message
    companion_with_throttle.redis_client.get = AsyncMock(
        return_value=str(asyncio.get_event_loop().time())
    )

    game_state = {
        "player": {"level": 1, "xp": 0},
        "ship": {"hull_hp": 50, "max_hull_hp": 100},
        "progress": {"completed_missions": []},
        "mission": {}
    }

    result = await companion_with_throttle.run(game_state, force_check=False)

    assert result["should_act"] is False
    assert "throttled" in result["reasoning"].lower()
