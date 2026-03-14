"""Game Master Agent — Claude API integration with tool use.

The Game Master is the AI dungeon master that drives the narrative,
manages game state, and responds to player actions using Claude
as the reasoning engine with tools for game mechanics.

Uses the Anthropic Python SDK with tool_use for the agent loop.
Degrades gracefully if ANTHROPIC_API_KEY is not set.
"""

from __future__ import annotations

import json
import logging
from typing import Any, AsyncIterator

from ..config import settings
from ..memory.manager import MemoryManager
from ..state.models import GameSession
from .prompts import GAME_MASTER_SYSTEM_PROMPT, build_turn_context
from .tools import TOOL_DEFINITIONS, TOOL_HANDLERS

logger = logging.getLogger(__name__)

_NO_KEY_RESPONSE = (
    "⚠️ **Game Master Offline** — No `ANTHROPIC_API_KEY` configured.\n\n"
    "To enable the AI Game Master, create a `server/.env` file with:\n\n"
    "```\nSA_ANTHROPIC_API_KEY=sk-ant-...\n```\n\n"
    "Get an API key at https://console.anthropic.com/\n\n"
    "The game server is running and all endpoints work — "
    "only the AI narrative generation requires the key."
)


class GameMasterAgent:
    """Claude-powered Game Master with tool use for game mechanics."""

    def __init__(self, memory: MemoryManager):
        self.memory = memory
        self.model = settings.claude_model
        self.max_tool_rounds = 10
        self._api_available = bool(settings.anthropic_api_key)
        self.client = None

        if self._api_available:
            import anthropic
            self.client = anthropic.AsyncAnthropic(api_key=settings.anthropic_api_key)
            logger.info("Anthropic API client initialized")
        else:
            logger.warning(
                "ANTHROPIC_API_KEY not set — Game Master will return placeholder responses. "
                "Set SA_ANTHROPIC_API_KEY in server/.env to enable AI."
            )

    async def process_turn(
        self,
        session: GameSession,
        player_message: str,
    ) -> str:
        """Process a player message and return the Game Master's response.

        Returns a placeholder if no API key is configured.
        """
        session.touch()

        if not self._api_available or self.client is None:
            return _NO_KEY_RESPONSE

        # Build context
        memory_context = self.memory.load_session_context()
        turn_context = build_turn_context(session, memory_context)

        # Build conversation messages
        messages = self._build_messages(session, player_message, turn_context)

        # Agent loop: send → tool calls → send results → repeat
        for _round in range(self.max_tool_rounds):
            response = await self.client.messages.create(
                model=self.model,
                max_tokens=2048,
                system=GAME_MASTER_SYSTEM_PROMPT,
                tools=TOOL_DEFINITIONS,
                messages=messages,
            )

            # Check if we got a final text response (no tool use)
            if response.stop_reason == "end_turn":
                return self._extract_text(response)

            # Process tool calls
            if response.stop_reason == "tool_use":
                messages.append({"role": "assistant", "content": response.content})
                tool_results = []
                for block in response.content:
                    if block.type == "tool_use":
                        result = self._execute_tool(session, block.name, block.input)
                        tool_results.append({
                            "type": "tool_result",
                            "tool_use_id": block.id,
                            "content": json.dumps(result, default=str),
                        })
                messages.append({"role": "user", "content": tool_results})
            else:
                return self._extract_text(response)

        logger.warning("Hit max tool rounds (%d) for session %s", self.max_tool_rounds, session.session_id)
        return "The Game Master pauses thoughtfully... *[Please try again.]*"

    async def process_turn_streaming(
        self,
        session: GameSession,
        player_message: str,
    ) -> AsyncIterator[str]:
        """Process a turn with streaming text output.

        Yields text chunks as they arrive. Tool calls are handled internally.
        Falls back to non-streaming placeholder if no API key.
        """
        session.touch()

        if not self._api_available or self.client is None:
            yield _NO_KEY_RESPONSE
            return

        memory_context = self.memory.load_session_context()
        turn_context = build_turn_context(session, memory_context)
        messages = self._build_messages(session, player_message, turn_context)

        for _round in range(self.max_tool_rounds):
            response = await self.client.messages.create(
                model=self.model,
                max_tokens=2048,
                system=GAME_MASTER_SYSTEM_PROMPT,
                tools=TOOL_DEFINITIONS,
                messages=messages,
            )

            if response.stop_reason == "tool_use":
                messages.append({"role": "assistant", "content": response.content})
                tool_results = []
                for block in response.content:
                    if block.type == "tool_use":
                        result = self._execute_tool(session, block.name, block.input)
                        tool_results.append({
                            "type": "tool_result",
                            "tool_use_id": block.id,
                            "content": json.dumps(result, default=str),
                        })
                messages.append({"role": "user", "content": tool_results})
                continue

            # Final response — stream it
            async with self.client.messages.stream(
                model=self.model,
                max_tokens=2048,
                system=GAME_MASTER_SYSTEM_PROMPT,
                messages=messages,
            ) as stream:
                async for text in stream.text_stream:
                    yield text
            return

        yield "The Game Master pauses thoughtfully... *[Please try again.]*"

    def _build_messages(
        self,
        session: GameSession,
        player_message: str,
        turn_context: str,
    ) -> list[dict]:
        """Build the messages array for the API call."""
        messages: list[dict] = []

        # Recent conversation history (last 20 entries)
        history = session.conversation_history[-20:]
        for entry in history:
            messages.append({"role": entry["role"], "content": entry["content"]})

        # Current player message with context
        content = player_message
        if turn_context:
            content = f"[GAME CONTEXT]\n{turn_context}\n[END CONTEXT]\n\n{player_message}"

        messages.append({"role": "user", "content": content})
        return messages

    def _execute_tool(self, session: GameSession, tool_name: str, tool_input: dict) -> dict:
        """Execute a tool and return the result dict."""
        handler = TOOL_HANDLERS.get(tool_name)
        if not handler:
            return {"error": f"Unknown tool: {tool_name}"}

        try:
            if tool_name in ("search_memory", "write_memory"):
                tool_input["memory"] = self.memory
            return handler(session, **tool_input)
        except Exception as e:
            logger.exception("Tool %s failed", tool_name)
            return {"error": str(e)}

    def _extract_text(self, response) -> str:
        """Extract text content from a Claude response."""
        texts = []
        for block in response.content:
            if hasattr(block, "text"):
                texts.append(block.text)
        return "\n".join(texts) if texts else ""

    def save_to_history(self, session: GameSession, player_msg: str, gm_response: str) -> None:
        """Save the turn to conversation history for context continuity."""
        session.conversation_history.append({"role": "user", "content": player_msg})
        session.conversation_history.append({"role": "assistant", "content": gm_response})
        if len(session.conversation_history) > 40:
            session.conversation_history = session.conversation_history[-40:]
