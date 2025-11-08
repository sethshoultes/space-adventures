"""
Unit tests for AI Orchestrator

Tests the core orchestration logic including:
- Agent chat functionality
- Function calling
- Agent handoffs
- Routing logic
"""

import pytest
from src.orchestrator import AIOrchestrator, OrchestratorConfig
from src.orchestrator.agents import AgentType


@pytest.fixture
def config():
    """Test configuration using Ollama for all agents"""
    return OrchestratorConfig(
        ollama_base_url="http://localhost:11434",
        ollama_model_atlas="llama3.2:3b",
        ollama_model_companion="llama3.2:3b",
        provider_atlas="ollama",
        provider_storyteller="ollama",
        provider_tactical="ollama",
        provider_companion="ollama",
        temperature_atlas=0.7,
        temperature_storyteller=0.9,
        temperature_tactical=0.6,
        temperature_companion=0.8,
        max_tokens=500,
        timeout=30
    )


@pytest.fixture
def orchestrator(config):
    """Create orchestrator instance for testing"""
    return AIOrchestrator(config=config)


@pytest.fixture
def mock_game_state():
    """Mock game state for testing"""
    return {
        "ship": {
            "name": "USS Test Ship",
            "systems": {
                "hull": {"level": 2, "health": 85},
                "power": {"level": 2, "health": 100}
            },
            "power_available": 25,
            "power_total": 50
        },
        "player": {
            "name": "Test Captain",
            "level": 3,
            "credits": 1500
        }
    }


class TestOrchestratorBasics:
    """Test basic orchestrator functionality"""

    def test_orchestrator_initialization(self, orchestrator):
        """Test orchestrator initializes correctly"""
        assert orchestrator is not None
        assert len(orchestrator.conversation_history) == 4
        assert AgentType.ATLAS in orchestrator.conversation_history

    def test_get_available_agents(self, orchestrator):
        """Test getting list of available agents"""
        agents = orchestrator.get_available_agents()
        assert len(agents) == 4
        agent_names = [a["name"] for a in agents]
        assert AgentType.ATLAS in agent_names
        assert AgentType.STORYTELLER in agent_names

    def test_invalid_agent_name(self, orchestrator):
        """Test handling of invalid agent name"""

        @pytest.mark.asyncio
        async def test():
            result = await orchestrator.chat("invalid_agent", "test message")
            assert result["success"] is False
            assert "error" in result

        import asyncio
        asyncio.run(test())

    def test_clear_history(self, orchestrator):
        """Test clearing conversation history"""
        # Add some mock history
        orchestrator.conversation_history[AgentType.ATLAS] = [
            {"role": "user", "content": "test"}
        ]

        # Clear specific agent
        orchestrator.clear_history("atlas")
        assert len(orchestrator.conversation_history[AgentType.ATLAS]) == 0

        # Add history again
        orchestrator.conversation_history[AgentType.ATLAS] = [
            {"role": "user", "content": "test"}
        ]
        orchestrator.conversation_history[AgentType.COMPANION] = [
            {"role": "user", "content": "test"}
        ]

        # Clear all
        orchestrator.clear_history()
        assert len(orchestrator.conversation_history[AgentType.ATLAS]) == 0
        assert len(orchestrator.conversation_history[AgentType.COMPANION]) == 0


class TestConfiguration:
    """Test configuration functionality"""

    def test_config_from_env(self, monkeypatch):
        """Test creating config from environment variables"""
        monkeypatch.setenv("PROVIDER_ATLAS", "ollama")
        monkeypatch.setenv("TEMPERATURE_ATLAS", "0.8")
        monkeypatch.setenv("MAX_TOKENS", "1000")

        config = OrchestratorConfig.from_env()
        assert config.provider_atlas == "ollama"
        assert config.temperature_atlas == 0.8
        assert config.max_tokens == 1000

    def test_get_model_for_agent(self, config):
        """Test getting model string for each agent"""
        atlas_model = config.get_model_for_agent("atlas")
        assert "ollama" in atlas_model.lower()

        companion_model = config.get_model_for_agent("companion")
        assert "ollama" in companion_model.lower()

    def test_get_temperature(self, config):
        """Test getting temperature for each agent"""
        assert config.get_temperature("atlas") == 0.7
        assert config.get_temperature("storyteller") == 0.9
        assert config.get_temperature("tactical") == 0.6
        assert config.get_temperature("companion") == 0.8


class TestFunctions:
    """Test function calling functionality"""

    @pytest.mark.asyncio
    async def test_get_ship_status_mock(self):
        """Test get_ship_status with mock data"""
        from src.orchestrator.functions import get_ship_status

        result = await get_ship_status()
        assert result["success"] is True
        assert "data" in result
        assert "ship_name" in result["data"]

    @pytest.mark.asyncio
    async def test_get_power_budget_mock(self):
        """Test get_power_budget with mock data"""
        from src.orchestrator.functions import get_power_budget

        result = await get_power_budget()
        assert result["success"] is True
        assert "data" in result
        assert "available" in result["data"]
        assert "total" in result["data"]

    @pytest.mark.asyncio
    async def test_upgrade_system_mock(self):
        """Test upgrade_system with mock data"""
        from src.orchestrator.functions import upgrade_system

        result = await upgrade_system("hull")
        assert result["success"] is True
        assert "data" in result

    @pytest.mark.asyncio
    async def test_execute_function_unknown(self):
        """Test executing unknown function"""
        from src.orchestrator.functions import execute_function

        result = await execute_function("unknown_function", {})
        assert result["success"] is False
        assert "error" in result

    def test_get_functions_for_agent(self):
        """Test getting functions for agents"""
        from src.orchestrator.functions import get_functions_for_agent

        # ATLAS should get functions
        atlas_functions = get_functions_for_agent("atlas")
        assert atlas_functions is not None
        assert len(atlas_functions) > 0

        # Other agents should not
        storyteller_functions = get_functions_for_agent("storyteller")
        assert storyteller_functions is None


class TestAgents:
    """Test agent functionality"""

    def test_agent_prompts_exist(self):
        """Test that all agents have system prompts"""
        from src.orchestrator.agents import SYSTEM_PROMPTS, AgentType

        for agent in AgentType:
            assert agent in SYSTEM_PROMPTS
            assert len(SYSTEM_PROMPTS[agent]) > 0

    def test_is_valid_agent(self):
        """Test agent validation"""
        from src.orchestrator.agents import is_valid_agent

        assert is_valid_agent("atlas") is True
        assert is_valid_agent("ATLAS") is True
        assert is_valid_agent("storyteller") is True
        assert is_valid_agent("invalid") is False


# Skip integration tests if Ollama not running
@pytest.mark.integration
@pytest.mark.asyncio
class TestIntegration:
    """Integration tests (require Ollama running)"""

    async def test_atlas_chat(self, orchestrator):
        """Test chatting with ATLAS"""
        result = await orchestrator.chat(
            "atlas",
            "What is the current ship status?",
            include_functions=True
        )

        assert result["success"] is True
        assert result["agent"] == "atlas"
        assert "response" in result or "function_call" in result

    async def test_routing(self, orchestrator):
        """Test intelligent routing"""
        # Test routing to ATLAS
        result = await orchestrator.route_message("Check ship status")
        assert result["success"] is True

        # Test routing to Companion
        result = await orchestrator.route_message("How are you doing today?")
        assert result["success"] is True


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
