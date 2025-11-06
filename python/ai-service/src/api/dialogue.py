"""
Dialogue API Endpoints.

Handles NPC dialogue generation.
"""

import logging
import time
from fastapi import APIRouter

from ..models.dialogue import DialogueRequest, DialogueResponse
from ..ai.client import get_ai_client, AITaskType
from ..ai.prompts import format_npc_dialogue_prompt
from ..cache import get_cache

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/dialogue", tags=["dialogue"])


@router.post("/generate", response_model=DialogueResponse)
async def generate_dialogue(request: DialogueRequest) -> DialogueResponse:
    """
    Generate NPC dialogue.

    This endpoint:
    1. Checks cache for similar dialogue
    2. Formats prompt with NPC context
    3. Calls AI provider
    4. Returns NPC's response

    Args:
        request: Dialogue request with NPC and player context

    Returns:
        DialogueResponse with NPC's dialogue
    """
    start_time = time.time()

    try:
        # Get AI client and cache
        ai_client = get_ai_client()
        cache = get_cache()

        # Build prompt
        prompt = format_npc_dialogue_prompt(
            npc_name=request.npc_name,
            npc_role=request.npc_role,
            location=request.location,
            context=request.context,
            player_message=request.player_message
        )

        # Check cache
        cache_params = {
            "npc": request.npc_name,
            "location": request.location
        }
        cached_dialogue = await cache.get(prompt, **cache_params)

        if cached_dialogue:
            logger.info(f"Cache hit for NPC dialogue: {request.npc_name}")
            return DialogueResponse(
                success=True,
                npc_name=request.npc_name,
                npc_dialogue=cached_dialogue,
                cached=True,
                generation_time_ms=round((time.time() - start_time) * 1000, 2)
            )

        # Generate dialogue
        logger.info(
            f"Generating dialogue for {request.npc_name} ({request.npc_role}) "
            f"at {request.location}"
        )

        ai_response = await ai_client.generate(
            task_type=AITaskType.NPC_DIALOGUE,
            prompt=prompt,
            system="You are generating dialogue for an NPC in a Star Trek-inspired game. "
                   "Keep responses natural, in-character, and 2-4 sentences long."
        )

        # Cache the response
        await cache.set(prompt, ai_response, **cache_params)

        generation_time = round((time.time() - start_time) * 1000, 2)

        logger.info(f"Dialogue generated in {generation_time}ms")

        return DialogueResponse(
            success=True,
            npc_name=request.npc_name,
            npc_dialogue=ai_response.strip(),
            cached=False,
            generation_time_ms=generation_time
        )

    except Exception as e:
        logger.error(f"Dialogue generation failed: {e}", exc_info=True)
        return DialogueResponse(
            success=False,
            npc_name=request.npc_name,
            npc_dialogue="",
            error=str(e),
            generation_time_ms=round((time.time() - start_time) * 1000, 2)
        )


@router.get("/health")
async def dialogue_health():
    """Health check for dialogue endpoint."""
    return {
        "endpoint": "dialogue",
        "status": "operational",
        "description": "NPC dialogue generation endpoint"
    }
