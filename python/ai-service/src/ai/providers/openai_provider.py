"""
OpenAI GPT Provider.

Uses OpenAI for random content and NPC dialogue.
Best for: Random encounters, minor missions, NPC conversations.
"""

import os
import logging
from typing import Optional
from openai import AsyncOpenAI
from .base import AIProvider, AIProviderConfig

logger = logging.getLogger(__name__)


class OpenAIProvider(AIProvider):
    """
    OpenAI GPT provider.

    Recommended model: gpt-3.5-turbo (cost-effective) or gpt-4
    """

    def __init__(self, config: AIProviderConfig):
        """Initialize OpenAI provider."""
        super().__init__(config)

        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            logger.warning("OPENAI_API_KEY not set. OpenAI provider will fail.")
            self.client = None
        else:
            self.client = AsyncOpenAI(api_key=api_key)

        logger.info(f"OpenAI provider initialized with model: {config.model}")

    async def generate(
        self,
        prompt: str,
        system: Optional[str] = None,
        **kwargs
    ) -> str:
        """
        Generate text using OpenAI.

        Args:
            prompt: User prompt
            system: Optional system instructions
            **kwargs: Additional parameters

        Returns:
            Generated text

        Raises:
            ValueError: If client not initialized
            Exception: If API call fails
        """
        if not self.client:
            raise ValueError("OpenAI client not initialized. Check OPENAI_API_KEY.")

        try:
            # Build messages
            messages = []
            if system:
                messages.append({"role": "system", "content": system})
            messages.append({"role": "user", "content": prompt})

            # Create completion
            response = await self.client.chat.completions.create(
                model=self.config.model,
                messages=messages,
                temperature=self.config.temperature,
                max_tokens=self.config.max_tokens,
                top_p=self.config.top_p,
                **kwargs
            )

            # Extract text from response
            generated_text = response.choices[0].message.content

            logger.info(
                f"OpenAI generated {len(generated_text)} characters "
                f"(tokens: {response.usage.completion_tokens})"
            )

            return generated_text

        except Exception as e:
            logger.error(f"OpenAI generation failed: {e}")
            raise

    async def health_check(self) -> bool:
        """
        Check if OpenAI is available.

        Returns:
            True if API key is set and client initialized
        """
        if not self.client:
            return False

        try:
            # Try a minimal API call
            response = await self.client.chat.completions.create(
                model=self.config.model,
                messages=[{"role": "user", "content": "test"}],
                max_tokens=5
            )
            return True
        except Exception as e:
            logger.error(f"OpenAI health check failed: {e}")
            return False
