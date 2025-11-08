"""
Orchestrator Configuration

Provider and model configuration for AI agents.
"""

import os
from typing import Dict, Optional
from pydantic import BaseModel
from enum import Enum


class ProviderType(str, Enum):
    """Supported AI providers"""
    OLLAMA = "ollama"
    ANTHROPIC = "anthropic"
    OPENAI = "openai"


class OrchestratorConfig(BaseModel):
    """Configuration for AI Orchestrator"""

    # API Keys
    anthropic_api_key: Optional[str] = None
    openai_api_key: Optional[str] = None

    # Ollama Configuration
    ollama_base_url: str = "http://localhost:11434"
    ollama_model_atlas: str = "llama3.2:3b"
    ollama_model_companion: str = "llama3.2:3b"

    # Provider Selection per Agent
    provider_atlas: ProviderType = ProviderType.OLLAMA
    provider_storyteller: ProviderType = ProviderType.ANTHROPIC
    provider_tactical: ProviderType = ProviderType.OPENAI
    provider_companion: ProviderType = ProviderType.OLLAMA

    # Temperature Settings (0.0-1.0)
    temperature_atlas: float = 0.7
    temperature_storyteller: float = 0.9
    temperature_tactical: float = 0.6
    temperature_companion: float = 0.8

    # Response Configuration
    max_tokens: int = 2000
    timeout: int = 60  # seconds

    # Feature Flags
    enable_function_calling: bool = True
    enable_streaming: bool = True
    enable_caching: bool = True

    @classmethod
    def from_env(cls) -> "OrchestratorConfig":
        """Create configuration from environment variables"""
        return cls(
            # API Keys
            anthropic_api_key=os.getenv("ANTHROPIC_API_KEY"),
            openai_api_key=os.getenv("OPENAI_API_KEY"),

            # Ollama
            ollama_base_url=os.getenv("OLLAMA_BASE_URL", "http://localhost:11434"),
            ollama_model_atlas=os.getenv("OLLAMA_MODEL_ATLAS", "llama3.2:3b"),
            ollama_model_companion=os.getenv("OLLAMA_MODEL_COMPANION", "llama3.2:3b"),

            # Provider Selection
            provider_atlas=ProviderType(os.getenv("PROVIDER_ATLAS", "ollama")),
            provider_storyteller=ProviderType(os.getenv("PROVIDER_STORYTELLER", "anthropic")),
            provider_tactical=ProviderType(os.getenv("PROVIDER_TACTICAL", "openai")),
            provider_companion=ProviderType(os.getenv("PROVIDER_COMPANION", "ollama")),

            # Temperature
            temperature_atlas=float(os.getenv("TEMPERATURE_ATLAS", "0.7")),
            temperature_storyteller=float(os.getenv("TEMPERATURE_STORYTELLER", "0.9")),
            temperature_tactical=float(os.getenv("TEMPERATURE_TACTICAL", "0.6")),
            temperature_companion=float(os.getenv("TEMPERATURE_COMPANION", "0.8")),

            # Response Config
            max_tokens=int(os.getenv("MAX_TOKENS", "2000")),
            timeout=int(os.getenv("AI_TIMEOUT", "60")),

            # Feature Flags
            enable_function_calling=os.getenv("ENABLE_FUNCTION_CALLING", "true").lower() == "true",
            enable_streaming=os.getenv("ENABLE_STREAMING", "true").lower() == "true",
            enable_caching=os.getenv("CACHE_ENABLED", "true").lower() == "true",
        )

    def get_model_for_agent(self, agent_name: str) -> str:
        """
        Get LiteLLM model string for an agent

        Args:
            agent_name: Name of the agent (atlas, storyteller, tactical, companion)

        Returns:
            LiteLLM model identifier string
        """
        provider_map = {
            "atlas": self.provider_atlas,
            "storyteller": self.provider_storyteller,
            "tactical": self.provider_tactical,
            "companion": self.provider_companion
        }

        provider = provider_map.get(agent_name.lower(), ProviderType.OLLAMA)

        if provider == ProviderType.OLLAMA:
            model_name = (
                self.ollama_model_atlas
                if agent_name.lower() == "atlas"
                else self.ollama_model_companion
            )
            return f"ollama/{model_name}"
        elif provider == ProviderType.ANTHROPIC:
            return "claude-3-5-sonnet-20240620"
        elif provider == ProviderType.OPENAI:
            return "gpt-3.5-turbo"
        else:
            raise ValueError(f"Unknown provider: {provider}")

    def get_temperature(self, agent_name: str) -> float:
        """Get temperature setting for an agent"""
        temp_map = {
            "atlas": self.temperature_atlas,
            "storyteller": self.temperature_storyteller,
            "tactical": self.temperature_tactical,
            "companion": self.temperature_companion
        }
        return temp_map.get(agent_name.lower(), 0.7)

    def get_api_base(self, agent_name: str) -> Optional[str]:
        """Get API base URL for an agent (Ollama only)"""
        provider_map = {
            "atlas": self.provider_atlas,
            "storyteller": self.provider_storyteller,
            "tactical": self.provider_tactical,
            "companion": self.provider_companion
        }

        provider = provider_map.get(agent_name.lower(), ProviderType.OLLAMA)

        if provider == ProviderType.OLLAMA:
            return self.ollama_base_url
        return None


# Global config instance
_config: Optional[OrchestratorConfig] = None


def get_config() -> OrchestratorConfig:
    """Get or create global orchestrator configuration"""
    global _config
    if _config is None:
        _config = OrchestratorConfig.from_env()
    return _config


def reset_config():
    """Reset global configuration (for testing)"""
    global _config
    _config = None
