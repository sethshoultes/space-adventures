"""
Enhanced Missions API with Queue Integration.

AI-First Features:
- Instant mission delivery from pre-generated queue
- Fallback to on-demand generation
- Queue statistics and monitoring
"""

import logging
import time
from fastapi import APIRouter, HTTPException
from typing import Dict, Any

from ..models.mission import MissionRequest, MissionResponse, Mission
from ..api.missions import parse_mission_from_text  # Reuse existing parser
from ..ai.client import get_ai_client, AITaskType
from ..ai.prompts import format_mission_prompt
from ..cache import get_cache
from ..background import get_mission_queue, pregenerate_missions

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/missions", tags=["missions"])


@router.post("/generate", response_model=MissionResponse)
async def generate_mission_enhanced(request: MissionRequest) -> MissionResponse:
    """
    Generate a mission using AI-first queue system.

    Flow:
    1. Check pre-generated mission queue
    2. If available, return instantly (< 10ms)
    3. If not, generate on-demand (fall back to original behavior)
    4. Trigger background replenishment

    Args:
        request: Mission generation request

    Returns:
        MissionResponse with generated or queued mission
    """
    start_time = time.time()

    try:
        mission_queue = get_mission_queue()

        difficulty = request.difficulty
        mission_type = request.mission_type or "general"

        # Try to get pre-generated mission from queue
        queued_mission_data = await mission_queue.pop_mission(
            difficulty,
            mission_type
        )

        if queued_mission_data:
            # SUCCESS: Instant delivery from queue
            logger.info(
                f"Delivering pre-generated {difficulty}/{mission_type} mission "
                f"from queue"
            )

            # Parse the pre-generated mission
            # (In production, you'd have full Mission objects in queue)
            mission = parse_mission_from_text(
                queued_mission_data.get("raw_content", ""),
                request
            )

            generation_time = round((time.time() - start_time) * 1000, 2)

            # Check if queue needs replenishment (async, don't wait)
            queue_size = await mission_queue.get_queue_size(difficulty, mission_type)
            if queue_size < 3:
                # Trigger background replenishment
                logger.info(f"Queue low ({queue_size}), triggering replenishment")
                # In production, you'd use background task or message queue
                # For now, just log

            return MissionResponse(
                success=True,
                mission=mission,
                cached=True,  # Treat queued missions as "cached"
                generation_time_ms=generation_time,
                source="queue"  # Custom field to indicate source
            )

        # FALLBACK: Queue empty, generate on-demand
        logger.info(
            f"Queue empty for {difficulty}/{mission_type}, generating on-demand"
        )

        # Use original generation logic
        ai_client = get_ai_client()
        cache = get_cache()

        prompt = format_mission_prompt(
            level=request.game_state.player.level,
            rank=request.game_state.player.rank,
            skills=request.game_state.player.skills,
            ship_class=request.game_state.ship.ship_class,
            operational_systems=request.game_state.get_operational_systems(),
            completed_missions_count=request.game_state.get_completed_missions_count(),
            mission_type=mission_type,
            difficulty=difficulty,
            location=request.location or "Old Earth Ruins"
        )

        # Check cache
        cache_key_params = {
            "difficulty": difficulty,
            "mission_type": mission_type,
            "player_level": request.game_state.player.level
        }

        cached_text = await cache.get(prompt, **cache_key_params)

        if cached_text:
            mission = parse_mission_from_text(cached_text, request)
            return MissionResponse(
                success=True,
                mission=mission,
                cached=True,
                generation_time_ms=round((time.time() - start_time) * 1000, 2),
                source="cache"
            )

        # Generate using AI
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
            f"Mission generated on-demand: '{mission.title}' in {generation_time}ms"
        )

        return MissionResponse(
            success=True,
            mission=mission,
            cached=False,
            generation_time_ms=generation_time,
            source="ai_generated"
        )

    except Exception as e:
        logger.error(f"Mission generation failed: {e}", exc_info=True)
        return MissionResponse(
            success=False,
            error=str(e),
            generation_time_ms=round((time.time() - start_time) * 1000, 2)
        )


@router.get("/queue/stats")
async def get_queue_stats():
    """
    Get mission queue statistics.

    Returns:
        Queue sizes for all mission types/difficulties
    """
    mission_queue = get_mission_queue()

    if not mission_queue.enabled:
        return {
            "enabled": False,
            "message": "Mission queue disabled"
        }

    stats = await mission_queue.get_all_queue_stats()

    return {
        "enabled": True,
        "queues": stats,
        "total_missions": sum(stats.values())
    }


@router.post("/queue/replenish")
async def trigger_replenishment(count: int = 5):
    """
    Manually trigger mission queue replenishment.

    Args:
        count: Number of missions to generate per queue

    Returns:
        Status message
    """
    logger.info(f"Manual replenishment triggered (count: {count})")

    # Trigger background task
    # In production, this would queue a background job
    # For now, we'll run it directly (might be slow)

    try:
        await pregenerate_missions(count=count)

        return {
            "success": True,
            "message": f"Generated up to {count} missions per queue"
        }

    except Exception as e:
        logger.error(f"Replenishment failed: {e}")
        return {
            "success": False,
            "error": str(e)
        }


@router.delete("/queue/clear")
async def clear_queue(
    difficulty: str = None,
    mission_type: str = None
):
    """
    Clear mission queue(s).

    Args:
        difficulty: Optional specific difficulty
        mission_type: Optional specific type

    Returns:
        Status message
    """
    mission_queue = get_mission_queue()

    await mission_queue.clear_queue(difficulty, mission_type)

    return {
        "success": True,
        "message": f"Cleared queue(s)"
    }
