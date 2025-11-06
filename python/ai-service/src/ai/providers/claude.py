"""
Claude (Anthropic) AI Provider.

Uses Claude for high-quality story content and critical narrative.
Best for: Story missions, ethical dilemmas, character development.
"""

import os
import logging
from typing import Optional
from anthropic import AsyncAnthropic
from .base import AIProvider, AIProviderConfig

logger = logging.getLogger(__name__)


class ClaudeProvider(AIProvider):
    """
    Claude AI provider using Anthropic's API.

    Recommended model: claude-3-5-sonnet-20241022
    """

    def __init__(self, config: AIProviderConfig):
        """Initialize Claude provider."""
        super().__init__(config)

        api_key = os.getenv("ANTHROPIC_API_KEY")
        if not api_key:
            logger.warning("ANTHROPIC_API_KEY not set. Claude provider will fail.")
            self.client = None
        else:
            self.client = AsyncAnthropic(api_key=api_key)

        logger.info(f"Claude provider initialized with model: {config.model}")

    async def generate(
        self,
        prompt: str,
        system: Optional[str] = None,
        **kwargs
    ) -> str:
        """
        Generate text using Claude.

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
            raise ValueError("Claude client not initialized. Check ANTHROPIC_API_KEY.")

        try:
            # Build messages
            messages = [{"role": "user", "content": prompt}]

            # Create message with Claude
            response = await self.client.messages.create(
                model=self.config.model,
                max_tokens=self.config.max_tokens,
                temperature=self.config.temperature,
                system=system or "",
                messages=messages,
                **kwargs
            )

            # Extract text from response
            generated_text = response.content[0].text

            logger.info(
                f"Claude generated {len(generated_text)} characters "
                f"(tokens: {response.usage.output_tokens})"
            )

            return generated_text

        except Exception as e:
            logger.error(f"Claude generation failed: {e}")
            raise

    async def health_check(self) -> bool:
        """
        Check if Claude is available.

        Returns:
            True if API key is set and client initialized
        """
        if not self.client:
            return False

        try:
            # Try a minimal API call
            response = await self.client.messages.create(
                model=self.config.model,
                max_tokens=10,
                messages=[{"role": "user", "content": "test"}]
            )
            return True
        except Exception as e:
            logger.error(f"Claude health check failed: {e}")
            return False
