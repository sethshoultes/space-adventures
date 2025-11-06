"""
Multi-Provider AI Client.

Routes AI generation requests to the appropriate provider based on task type.
"""

import os
import logging
from typing import Optional, Dict, Any
from enum import Enum
from .providers.base import AIProvider, AIProviderConfig
from .providers.claude import ClaudeProvider
from .providers.openai_provider import OpenAIProvider
from .providers.ollama import OllamaProvider

logger = logging.getLogger(__name__)


class AITaskType(str, Enum):
    """Types of AI generation tasks."""
    STORY_MISSION = "story_mission"      # High-quality story content
    RANDOM_MISSION = "random_mission"    # Random encounters, minor missions
    NPC_DIALOGUE = "npc_dialogue"        # NPC conversations
    CHAT = "chat"                        # Player chat messages
    SHIP_DOCS = "ship_docs"              # Ship documentation
    UI_TEXT = "ui_text"                  # UI text generation


class MultiProviderAIClient:
    """
    Multi-provider AI client with intelligent routing.

    Routes different task types to optimal providers:
    - Claude: Story missions, critical narrative
    - OpenAI: Random content, NPC dialogue
    - Ollama: Ship docs, UI text (local, free)
    """

    def __init__(self):
        """Initialize all available providers."""
        self.providers: Dict[str, AIProvider] = {}

        # Get provider assignments from environment
        self.provider_routing = {
            AITaskType.STORY_MISSION: os.getenv("AI_PROVIDER_STORY", "ollama"),
            AITaskType.RANDOM_MISSION: os.getenv("AI_PROVIDER_RANDOM", "ollama"),
            AITaskType.NPC_DIALOGUE: os.getenv("AI_PROVIDER_RANDOM", "ollama"),
            AITaskType.CHAT: os.getenv("AI_PROVIDER_RANDOM", "ollama"),
            AITaskType.SHIP_DOCS: os.getenv("AI_PROVIDER_QUICK", "ollama"),
            AITaskType.UI_TEXT: os.getenv("AI_PROVIDER_QUICK", "ollama"),
        }

        # Initialize providers
        self._initialize_providers()

        logger.info(f"AI Client initialized with routing: {self.provider_routing}")

    def _initialize_providers(self):
        """Initialize all configured AI providers."""
        # Claude provider
        if os.getenv("ANTHROPIC_API_KEY"):
            try:
                claude_config = AIProviderConfig(
                    model=os.getenv("CLAUDE_MODEL", "claude-3-5-sonnet-20241022"),
                    temperature=float(os.getenv("TEMPERATURE", "0.8")),
                    max_tokens=int(os.getenv("MAX_TOKENS", "1500"))
                )
                self.providers["claude"] = ClaudeProvider(claude_config)
                logger.info("Claude provider initialized")
            except Exception as e:
                logger.error(f"Failed to initialize Claude provider: {e}")

        # OpenAI provider
        if os.getenv("OPENAI_API_KEY"):
            try:
                openai_config = AIProviderConfig(
                    model=os.getenv("OPENAI_MODEL", "gpt-3.5-turbo"),
                    temperature=float(os.getenv("TEMPERATURE", "0.8")),
                    max_tokens=int(os.getenv("MAX_TOKENS", "1500"))
                )
                self.providers["openai"] = OpenAIProvider(openai_config)
                logger.info("OpenAI provider initialized")
            except Exception as e:
                logger.error(f"Failed to initialize OpenAI provider: {e}")

        # Ollama provider (always try to initialize)
        try:
            ollama_config = AIProviderConfig(
                model=os.getenv("OLLAMA_MODEL", "llama3.2:3b"),
                temperature=float(os.getenv("TEMPERATURE", "0.8")),
                max_tokens=int(os.getenv("MAX_TOKENS", "1500"))
            )
            self.providers["ollama"] = OllamaProvider(ollama_config)
            logger.info("Ollama provider initialized")
        except Exception as e:
            logger.error(f"Failed to initialize Ollama provider: {e}")

        if not self.providers:
            logger.warning(
                "No AI providers initialized! "
                "Set ANTHROPIC_API_KEY, OPENAI_API_KEY, or run Ollama locally."
            )

    def _get_provider_for_task(self, task_type: AITaskType) -> AIProvider:
        """
        Get the appropriate provider for a task type.

        Args:
            task_type: Type of AI generation task

        Returns:
            AI provider instance

        Raises:
            ValueError: If no suitable provider is available
        """
        # Get configured provider for this task type
        provider_name = self.provider_routing.get(task_type, "ollama")

        # Get provider instance
        provider = self.providers.get(provider_name)

        if provider:
            return provider

        # Fallback: try to use any available provider
        if self.providers:
            fallback_provider = list(self.providers.values())[0]
            logger.warning(
                f"Preferred provider '{provider_name}' not available for {task_type}. "
                f"Using fallback: {fallback_provider.get_provider_name()}"
            )
            return fallback_provider

        # No providers available
        raise ValueError(
            "No AI providers available. "
            "Please configure at least one provider (Claude, OpenAI, or Ollama)."
        )

    async def generate(
        self,
        task_type: AITaskType,
        prompt: str,
        system: Optional[str] = None,
        **kwargs
    ) -> str:
        """
        Generate AI content using the appropriate provider.

        Args:
            task_type: Type of content to generate
            prompt: User prompt
            system: Optional system instructions
            **kwargs: Additional provider-specific parameters

        Returns:
            Generated text

        Raises:
            ValueError: If no providers available
            Exception: If generation fails
        """
        # Get provider for this task
        provider = self._get_provider_for_task(task_type)

        # Log the generation attempt
        logger.info(
            f"Generating {task_type.value} using {provider.get_provider_name()}"
        )

        # Generate content
        try:
            result = await provider.generate(prompt, system, **kwargs)
            logger.info(f"Successfully generated {len(result)} characters")
            return result
        except Exception as e:
            logger.error(f"Generation failed with {provider.get_provider_name()}: {e}")
            raise

    async def health_check(self) -> Dict[str, bool]:
        """
        Check health of all providers.

        Returns:
            Dictionary of provider names to health status
        """
        health_status = {}

        for name, provider in self.providers.items():
            try:
                is_healthy = await provider.health_check()
                health_status[name] = is_healthy
            except Exception as e:
                logger.error(f"Health check failed for {name}: {e}")
                health_status[name] = False

        return health_status

    def get_available_providers(self) -> list[str]:
        """Get list of available provider names."""
        return list(self.providers.keys())


# Global client instance
_ai_client: Optional[MultiProviderAIClient] = None


def get_ai_client() -> MultiProviderAIClient:
    """Get or create global AI client instance."""
    global _ai_client
    if _ai_client is None:
        _ai_client = MultiProviderAIClient()
    return _ai_client
