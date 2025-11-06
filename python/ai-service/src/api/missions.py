"""
Missions API Endpoints.

Handles mission generation using AI providers.
"""

import logging
import time
import json
import re
from fastapi import APIRouter, HTTPException
from typing import Dict, Any

from ..models.mission import (
    MissionRequest,
    MissionResponse,
    Mission,
    MissionStage,
    Choice,
    Consequence
)
from ..ai.client import get_ai_client, AITaskType
from ..ai.prompts import format_mission_prompt
from ..cache import get_cache

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/missions", tags=["missions"])


def parse_mission_from_text(text: str, request: MissionRequest) -> Mission:
    """
    Parse AI-generated mission text into structured Mission object.

    Args:
        text: Raw AI-generated mission text
        request: Original mission request

    Returns:
        Structured Mission object

    Note: This is a simplified parser. In production, you'd want
    to either use structured output from the AI (JSON mode) or
    more sophisticated parsing.
    """
    # For now, create a basic mission structure
    # In Week 2 Day 3-4, we'll improve this with better parsing
    # or prompt engineering to get JSON directly

    import uuid

    mission_id = f"mission_{uuid.uuid4().hex[:8]}"

    # Extract title (look for "TITLE:" or first line)
    title_match = re.search(r'TITLE:\s*(.+)', text, re.IGNORECASE)
    if title_match:
        title = title_match.group(1).strip()
    else:
        # Use first non-empty line
        lines = [l.strip() for l in text.split('\n') if l.strip()]
        title = lines[0] if lines else "Untitled Mission"

    # Extract description
    desc_match = re.search(r'DESCRIPTION:\s*(.+?)(?=STAGES:|Stage|$)', text, re.DOTALL | re.IGNORECASE)
    if desc_match:
        description = desc_match.group(1).strip()
    else:
        description = "A mission awaits..."

    # For MVP, create a simple single-stage mission
    # Full parsing will be implemented in Day 3-4
    stage = MissionStage(
        stage_id="stage_1",
        description=description[:200],  # First 200 chars
        choices=[
            Choice(
                choice_id="choice_1",
                text="Investigate the situation",
                requirements={},
                consequence=Consequence(
                    description="You proceed with caution.",
                    xp_bonus=50
                )
            ),
            Choice(
                choice_id="choice_2",
                text="Request more information",
                requirements={},
                consequence=Consequence(
                    description="You gather more intel.",
                    xp_bonus=25
                )
            )
        ]
    )

    # Determine XP based on difficulty
    xp_rewards = {
        "easy": 50,
        "medium": 100,
        "hard": 200,
        "extreme": 400
    }
    xp = xp_rewards.get(request.difficulty.lower(), 100)

    mission = Mission(
        mission_id=mission_id,
        title=title[:100],  # Limit length
        type=request.mission_type or "general",
        location=request.location or "Unknown Location",
        description=description,
        difficulty=request.difficulty,
        stages=[stage],
        rewards={
            "xp": xp,
            "items": []
        }
    )

    return mission


@router.post("/generate", response_model=MissionResponse)
async def generate_mission(request: MissionRequest) -> MissionResponse:
    """
    Generate a new mission using AI.

    This endpoint:
    1. Checks cache for existing mission
    2. Formats prompt with game state context
    3. Calls appropriate AI provider
    4. Parses response into Mission structure
    5. Caches result
    6. Returns structured mission

    Args:
        request: Mission generation request with game state and requirements

    Returns:
        MissionResponse with generated mission
    """
    start_time = time.time()

    try:
        # Get AI client and cache
        ai_client = get_ai_client()
        cache = get_cache()

        # Build prompt using game state
        prompt = format_mission_prompt(
            level=request.game_state.player.level,
            rank=request.game_state.player.rank,
            skills=request.game_state.player.skills,
            ship_class=request.game_state.ship.ship_class,
            operational_systems=request.game_state.get_operational_systems(),
            completed_missions_count=request.game_state.get_completed_missions_count(),
            mission_type=request.mission_type or "general",
            difficulty=request.difficulty,
            location=request.location or "Old Earth Ruins"
        )

        # Check cache
        cache_key_params = {
            "difficulty": request.difficulty,
            "mission_type": request.mission_type,
            "player_level": request.game_state.player.level
        }

        cached_text = await cache.get(prompt, **cache_key_params)

        if cached_text:
            logger.info("Cache hit for mission generation")
            mission = parse_mission_from_text(cached_text, request)

            return MissionResponse(
                success=True,
                mission=mission,
                cached=True,
                generation_time_ms=round((time.time() - start_time) * 1000, 2)
            )

        # Generate using AI
        logger.info(
            f"Generating {request.difficulty} {request.mission_type or 'general'} "
            f"mission for level {request.game_state.player.level} player"
        )

        # Use story mission task type for high-quality generation
        ai_response = await ai_client.generate(
            task_type=AITaskType.STORY_MISSION,
            prompt=prompt,
            system="You are a creative sci-fi storytelling AI. Generate engaging, "
                   "well-structured missions in the style of Star Trek: TNG."
        )

        # Cache the response
        await cache.set(prompt, ai_response, **cache_key_params)

        # Parse into Mission structure
        mission = parse_mission_from_text(ai_response, request)

        generation_time = round((time.time() - start_time) * 1000, 2)

        logger.info(
            f"Mission generated: '{mission.title}' in {generation_time}ms"
        )

        return MissionResponse(
            success=True,
            mission=mission,
            cached=False,
            generation_time_ms=generation_time
        )

    except ValueError as e:
        # No AI providers available
        logger.error(f"Mission generation failed: {e}")
        return MissionResponse(
            success=False,
            error=str(e),
            generation_time_ms=round((time.time() - start_time) * 1000, 2)
        )

    except Exception as e:
        logger.error(f"Unexpected error in mission generation: {e}", exc_info=True)
        return MissionResponse(
            success=False,
            error=f"Internal error: {str(e)}",
            generation_time_ms=round((time.time() - start_time) * 1000, 2)
        )


@router.get("/health")
async def missions_health():
    """Health check for missions endpoint."""
    return {
        "endpoint": "missions",
        "status": "operational",
        "description": "Mission generation endpoint with AI integration"
    }
