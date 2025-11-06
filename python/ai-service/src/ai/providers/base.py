"""
Base provider interface for AI services.

All AI providers must implement this interface for consistent usage.
"""

from abc import ABC, abstractmethod
from typing import Dict, Any, Optional
from pydantic import BaseModel


class AIProviderConfig(BaseModel):
    """Configuration for AI provider."""
    model: str
    temperature: float = 0.8
    max_tokens: int = 1500
    top_p: float = 1.0


class AIProvider(ABC):
    """
    Abstract base class for AI providers.

    All providers (Claude, OpenAI, Ollama) must implement this interface.
    """

    def __init__(self, config: AIProviderConfig):
        """Initialize provider with configuration."""
        self.config = config

    @abstractmethod
    async def generate(
        self,
        prompt: str,
        system: Optional[str] = None,
        **kwargs
    ) -> str:
        """
        Generate text from prompt.

        Args:
            prompt: User prompt/message
            system: Optional system message/instructions
            **kwargs: Additional provider-specific parameters

        Returns:
            Generated text response

        Raises:
            Exception: If generation fails
        """
        pass

    @abstractmethod
    async def health_check(self) -> bool:
        """
        Check if provider is available and configured correctly.

        Returns:
            True if provider is healthy, False otherwise
        """
        pass

    def get_provider_name(self) -> str:
        """Get provider name."""
        return self.__class__.__name__
