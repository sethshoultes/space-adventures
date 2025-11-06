"""
Chat API Endpoints.

Handles chat conversations with AI personalities.
"""

import logging
import time
import random
from fastapi import APIRouter
from typing import Dict

from ..models.chat import (
    ChatRequest,
    ChatResponse,
    SpontaneousEventRequest,
    SpontaneousEventResponse
)
from ..ai.client import get_ai_client, AITaskType
from ..ai.prompts import get_ai_personality_system
from ..cache import get_cache

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/chat", tags=["chat"])


# AI personality display names
AI_PERSONALITY_NAMES: Dict[str, str] = {
    "atlas": "ATLAS",
    "companion": "Companion",
    "mentor": "MENTOR",
    "engineer": "CHIEF"
}


@router.post("/message", response_model=ChatResponse)
async def chat_message(request: ChatRequest) -> ChatResponse:
    """
    Process a chat message from the player.

    This endpoint:
    1. Gets the appropriate AI personality system message
    2. Builds conversation context from history
    3. Calls AI provider with chat task type
    4. Returns AI response with personality info

    Args:
        request: Chat request with message and context

    Returns:
        ChatResponse with AI's reply
    """
    start_time = time.time()

    try:
        # Get AI client
        ai_client = get_ai_client()

        # Get personality system message
        system_message = get_ai_personality_system(request.ai_personality)
        ai_name = AI_PERSONALITY_NAMES.get(request.ai_personality, "AI")

        # Build context string from conversation history
        context_str = ""
        if request.conversation_context:
            context_str = "\n\nRecent conversation:\n"
            for msg in request.conversation_context[-5:]:  # Last 5 messages
                role_name = "Player" if msg.role == "user" else ai_name
                context_str += f"{role_name}: {msg.content}\n"

        # Add current game state context
        game_context = f"""

Current Game State:
- Player: Level {request.game_state.player.level}, Rank {request.game_state.player.rank}
- Ship: {request.game_state.ship.ship_class}
- Operational Systems: {', '.join(request.game_state.get_operational_systems()) or 'None'}
- Phase: {'Earthbound' if request.game_state.progress.phase == 1 else 'Space'}
"""

        # Build full prompt
        full_prompt = f"{context_str}{game_context}\n\nPlayer: {request.message}\n\n{ai_name}:"

        # Generate response
        logger.info(
            f"Processing chat message from {request.session_id} "
            f"(personality: {request.ai_personality})"
        )

        ai_response = await ai_client.generate(
            task_type=AITaskType.CHAT,
            prompt=full_prompt,
            system=system_message
        )

        # Clean up response (remove any prefix like "ATLAS:" if AI added it)
        ai_response = ai_response.strip()
        for name in AI_PERSONALITY_NAMES.values():
            if ai_response.startswith(f"{name}:"):
                ai_response = ai_response[len(name) + 1:].strip()
                break

        # Simple command detection (basic implementation)
        # TODO Week 3: Implement proper command parsing
        command_executed = None
        if any(word in request.message.lower() for word in ["fuel", "status", "systems", "shields"]):
            command_executed = "status_query"

        generation_time = round((time.time() - start_time) * 1000, 2)

        logger.info(
            f"Chat response generated ({len(ai_response)} chars) in {generation_time}ms"
        )

        return ChatResponse(
            success=True,
            ai_personality=request.ai_personality,
            ai_name=ai_name,
            message=ai_response,
            command_executed=command_executed,
            cached=False,
            generation_time_ms=generation_time
        )

    except Exception as e:
        logger.error(f"Chat message processing failed: {e}", exc_info=True)
        return ChatResponse(
            success=False,
            ai_personality=request.ai_personality,
            ai_name=AI_PERSONALITY_NAMES.get(request.ai_personality, "AI"),
            message="",
            error=str(e),
            generation_time_ms=round((time.time() - start_time) * 1000, 2)
        )


@router.post("/spontaneous", response_model=SpontaneousEventResponse)
async def spontaneous_event(request: SpontaneousEventRequest) -> SpontaneousEventResponse:
    """
    Generate a spontaneous AI event/comment.

    These are periodic, contextual comments from the AI that add
    immersion without interrupting gameplay.

    Args:
        request: Spontaneous event request with context

    Returns:
        SpontaneousEventResponse with whether to trigger and message
    """
    try:
        ai_name = AI_PERSONALITY_NAMES.get(request.ai_personality, "AI")

        # Decide whether to trigger based on time and random chance
        # More likely if more time has passed
        trigger_chance = min(0.3, request.time_elapsed_minutes * 0.05)
        should_trigger = random.random() < trigger_chance

        if not should_trigger:
            return SpontaneousEventResponse(
                success=True,
                should_trigger=False,
                ai_personality=request.ai_personality,
                ai_name=ai_name
            )

        # Generate a brief comment
        ai_client = get_ai_client()
        system_message = get_ai_personality_system(request.ai_personality)

        prompt = f"""Generate a very brief (1-2 sentence) spontaneous comment or observation.

Recent action: {request.recent_action or 'None'}
Time elapsed: {request.time_elapsed_minutes} minutes
Ship status: {request.game_state.ship.ship_class}

Make it contextual, supportive, or informative. Keep it short and non-intrusive.

Comment:"""

        ai_response = await ai_client.generate(
            task_type=AITaskType.CHAT,
            prompt=prompt,
            system=system_message
        )

        # Determine event type based on content
        event_type = "ambient"
        if any(word in ai_response.lower() for word in ["warning", "alert", "danger"]):
            event_type = "warning"
        elif any(word in ai_response.lower() for word in ["good", "well done", "excellent"]):
            event_type = "support"

        return SpontaneousEventResponse(
            success=True,
            should_trigger=True,
            ai_personality=request.ai_personality,
            ai_name=ai_name,
            message=ai_response.strip(),
            event_type=event_type
        )

    except Exception as e:
        logger.error(f"Spontaneous event generation failed: {e}", exc_info=True)
        return SpontaneousEventResponse(
            success=False,
            should_trigger=False,
            ai_personality=request.ai_personality,
            ai_name=AI_PERSONALITY_NAMES.get(request.ai_personality, "AI"),
            error=str(e)
        )


@router.get("/personalities")
async def list_personalities():
    """List available AI personalities."""
    return {
        "personalities": [
            {
                "id": "atlas",
                "name": "ATLAS",
                "description": "Tactical and strategic AI advisor"
            },
            {
                "id": "companion",
                "name": "Companion",
                "description": "Supportive and curious companion"
            },
            {
                "id": "mentor",
                "name": "MENTOR",
                "description": "Educational AI with scientific knowledge"
            },
            {
                "id": "engineer",
                "name": "CHIEF",
                "description": "Engineering specialist AI"
            }
        ]
    }


@router.get("/health")
async def chat_health():
    """Health check for chat endpoint."""
    return {
        "endpoint": "chat",
        "status": "operational",
        "description": "Chat system with AI personalities"
    }
