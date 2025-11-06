"""
Ollama Provider - Local AI.

Uses Ollama for local, free AI generation.
Best for: Ship documentation, UI text, item descriptions.
Requires Ollama running locally.
"""

import os
import logging
from typing import Optional
import httpx
from .base import AIProvider, AIProviderConfig

logger = logging.getLogger(__name__)


class OllamaProvider(AIProvider):
    """
    Ollama provider for local AI generation.

    Recommended model: llama3.2:3b (fast, good quality)
    Requires: Ollama installed and running (ollama.ai)
    """

    def __init__(self, config: AIProviderConfig):
        """Initialize Ollama provider."""
        super().__init__(config)

        self.base_url = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
        self.generate_url = f"{self.base_url}/api/generate"

        logger.info(
            f"Ollama provider initialized with model: {config.model} "
            f"at {self.base_url}"
        )

    async def generate(
        self,
        prompt: str,
        system: Optional[str] = None,
        **kwargs
    ) -> str:
        """
        Generate text using Ollama.

        Args:
            prompt: User prompt
            system: Optional system instructions
            **kwargs: Additional parameters

        Returns:
            Generated text

        Raises:
            Exception: If Ollama is not reachable or generation fails
        """
        try:
            # Build full prompt with system message if provided
            full_prompt = prompt
            if system:
                full_prompt = f"{system}\n\n{prompt}"

            # Prepare request
            payload = {
                "model": self.config.model,
                "prompt": full_prompt,
                "temperature": self.config.temperature,
                "stream": False,  # Get complete response
                "options": {
                    "num_predict": self.config.max_tokens,
                    "top_p": self.config.top_p
                }
            }

            # Call Ollama API
            async with httpx.AsyncClient(timeout=120.0) as client:
                response = await client.post(self.generate_url, json=payload)
                response.raise_for_status()

                result = response.json()
                generated_text = result.get("response", "")

                logger.info(
                    f"Ollama generated {len(generated_text)} characters "
                    f"(model: {self.config.model})"
                )

                return generated_text

        except httpx.ConnectError:
            logger.error(
                f"Cannot connect to Ollama at {self.base_url}. "
                "Is Ollama running? Install from https://ollama.ai"
            )
            raise Exception(
                "Ollama not available. Please start Ollama or use a different AI provider."
            )
        except Exception as e:
            logger.error(f"Ollama generation failed: {e}")
            raise

    async def health_check(self) -> bool:
        """
        Check if Ollama is available.

        Returns:
            True if Ollama is reachable and model is available
        """
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                # Check if Ollama is running
                response = await client.get(f"{self.base_url}/api/tags")
                response.raise_for_status()

                # Check if model is available
                models = response.json().get("models", [])
                model_names = [m.get("name") for m in models]

                if self.config.model in model_names:
                    return True
                else:
                    logger.warning(
                        f"Ollama model '{self.config.model}' not found. "
                        f"Available models: {model_names}. "
                        f"Pull with: ollama pull {self.config.model}"
                    )
                    return False

        except Exception as e:
            logger.error(f"Ollama health check failed: {e}")
            return False
