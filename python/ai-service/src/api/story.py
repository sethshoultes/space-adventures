"""
Story API Router

Endpoints for dynamic narrative generation and story state management.

Endpoints:
- POST /api/story/generate_narrative - Generate narrative for mission stage
- POST /api/story/generate_outcome - Generate choice outcome
- GET /api/story/memory/{player_id} - Get player memory context
- GET /api/story/mission_pool - Get generic side mission
- GET /api/story/world_context - Get world state context
- DELETE /api/story/invalidate_cache - Invalidate narrative cache
"""

import logging
from fastapi import APIRouter, HTTPException, status
from typing import Dict, Any, Optional
from pydantic import BaseModel, Field

from ..story import MemoryManager, StoryEngine, WorldState, MissionPool
from ..ai.client import get_ai_client
import redis.asyncio as redis
import os

logger = logging.getLogger(__name__)

# Create router
router = APIRouter(
    prefix="/api/story",
    tags=["story"],
    responses={
        500: {"description": "Internal server error"},
        400: {"description": "Bad request"}
    }
)


# Pydantic Models

class GenerateNarrativeRequest(BaseModel):
    """Request to generate narrative for a mission stage."""
    player_id: str = Field(..., description="Player identifier")
    mission_template: Dict[str, Any] = Field(..., description="Hybrid mission JSON")
    stage_id: str = Field(..., description="Stage ID to generate narrative for")
    player_state: Dict[str, Any] = Field(..., description="Current player state")
    world_context: Optional[Dict[str, Any]] = Field(None, description="World state context")


class GenerateNarrativeResponse(BaseModel):
    """Response with generated narrative."""
    success: bool
    narrative: str
    cached: bool
    generation_time_ms: int


class GenerateOutcomeRequest(BaseModel):
    """Request to generate choice outcome."""
    player_id: str = Field(..., description="Player identifier")
    choice: Dict[str, Any] = Field(..., description="Choice dict from hybrid mission")
    player_state: Dict[str, Any] = Field(..., description="Current player state")
    world_context: Optional[Dict[str, Any]] = Field(None, description="World state context")


class GenerateOutcomeResponse(BaseModel):
    """Response with choice outcome."""
    success: bool
    outcome: str
    narrative: str
    consequences: Dict[str, Any]
    next_stage: Optional[str]
    generation_time_ms: int


class MemoryContextResponse(BaseModel):
    """Response with player memory context."""
    success: bool
    recent_choices: list
    relationships: Dict[str, int]
    active_consequences: list
    story_state: Dict[str, str]


class MissionPoolRequest(BaseModel):
    """Request for mission from pool."""
    difficulty: str = Field("medium", description="Mission difficulty")


class MissionPoolResponse(BaseModel):
    """Response with mission from pool."""
    success: bool
    mission: Dict[str, Any]
    source: str
    queue_count: int


class WorldContextResponse(BaseModel):
    """Response with world context."""
    success: bool
    context: Dict[str, Any]


class InvalidateCacheRequest(BaseModel):
    """Request to invalidate cache."""
    player_id: str
    mission_id: str
    player_state: Dict[str, Any]


class InvalidateCacheResponse(BaseModel):
    """Response from cache invalidation."""
    success: bool
    deleted_count: int


# Initialize story engine components
# These will be initialized on app startup

# Global connection pool (created once on startup, reused across requests)
_redis_pool = None


def get_redis_pool():
    """Get or create Redis connection pool."""
    global _redis_pool

    if _redis_pool is None:
        redis_host = os.getenv("REDIS_HOST", "localhost")
        redis_port = int(os.getenv("REDIS_PORT", "6379"))
        redis_db = int(os.getenv("REDIS_DB", "0"))

        # Create connection pool with limits
        _redis_pool = redis.ConnectionPool(
            host=redis_host,
            port=redis_port,
            db=redis_db,
            decode_responses=True,
            max_connections=20,  # Max concurrent connections
            socket_connect_timeout=5,  # 5 second timeout
            socket_keepalive=True
        )
        logger.info(f"Created Redis connection pool: {redis_host}:{redis_port}/{redis_db}")

    return _redis_pool


def get_redis_client():
    """Get Redis client from connection pool."""
    pool = get_redis_pool()
    return redis.Redis(connection_pool=pool)


async def get_story_components():
    """Get story engine component instances."""
    redis_client = get_redis_client()
    llm_client = get_ai_client()  # Get global AI client instance

    memory_manager = MemoryManager(redis_client)
    story_engine = StoryEngine(redis_client, llm_client, memory_manager)
    world_state = WorldState(redis_client)
    mission_pool = MissionPool(redis_client, llm_client)

    return memory_manager, story_engine, world_state, mission_pool


# API Endpoints

@router.post("/generate_narrative", response_model=GenerateNarrativeResponse)
async def generate_narrative(request: GenerateNarrativeRequest) -> GenerateNarrativeResponse:
    """
    Generate narrative text for a mission stage.

    Uses StoryEngine to generate contextual narrative based on:
    - Mission template structure
    - Player history (last 10 choices)
    - Relationships with NPCs
    - Active consequences
    - World state

    Returns cached result if player state hasn't changed.
    """
    try:
        _, story_engine, world_state, _ = await get_story_components()

        # Get world context if not provided
        if not request.world_context:
            sector = request.mission_template.get("context", {}).get("location")
            request.world_context = await world_state.get_world_context(sector=sector)

        # Generate narrative
        result = await story_engine.generate_stage_narrative(
            request.player_id,
            request.mission_template,
            request.stage_id,
            request.player_state,
            request.world_context
        )

        return GenerateNarrativeResponse(
            success=True,
            **result
        )

    except Exception as e:
        logger.error(f"Error generating narrative: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Narrative generation failed: {str(e)}"
        )


@router.post("/generate_outcome", response_model=GenerateOutcomeResponse)
async def generate_outcome(request: GenerateOutcomeRequest) -> GenerateOutcomeResponse:
    """
    Generate outcome narrative for player choice.

    Determines consequence of choice and generates descriptive narrative.
    Updates player memory with:
    - Story flags
    - Relationship changes
    - World impact consequences
    """
    try:
        _, story_engine, world_state, _ = await get_story_components()

        # Get world context if not provided
        if not request.world_context:
            request.world_context = await world_state.get_world_context()

        # Generate outcome
        result = await story_engine.generate_choice_outcome(
            request.player_id,
            request.choice,
            request.player_state,
            request.world_context
        )

        return GenerateOutcomeResponse(
            success=True,
            **result
        )

    except Exception as e:
        logger.error(f"Error generating outcome: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Outcome generation failed: {str(e)}"
        )


@router.get("/memory/{player_id}", response_model=MemoryContextResponse)
async def get_memory_context(player_id: str, limit: int = 10) -> MemoryContextResponse:
    """
    Get player memory context.

    Returns:
    - Recent choices (last N)
    - All relationship scores
    - Active consequences
    - Story state (current mission, arc, flags)
    """
    try:
        memory_manager, _, _, _ = await get_story_components()

        context = await memory_manager.get_context(player_id, limit=limit)

        return MemoryContextResponse(
            success=True,
            **context
        )

    except Exception as e:
        logger.error(f"Error getting memory context: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Memory retrieval failed: {str(e)}"
        )


@router.get("/mission_pool", response_model=MissionPoolResponse)
async def get_pool_mission(difficulty: str = "medium") -> MissionPoolResponse:
    """
    Get generic side mission from pool.

    Returns mission from lazy queue (Level 3).
    Automatically refills queue when running low.

    Difficulties: easy, medium, hard, extreme
    """
    try:
        _, _, _, mission_pool = await get_story_components()

        result = await mission_pool.get_mission(difficulty)

        return MissionPoolResponse(
            success=True,
            **result
        )

    except Exception as e:
        logger.error(f"Error getting pool mission: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Mission pool error: {str(e)}"
        )


@router.get("/world_context", response_model=WorldContextResponse)
async def get_world_context_endpoint(
    sector: Optional[str] = None,
    include_events: bool = True
) -> WorldContextResponse:
    """
    Get world state context.

    Includes:
    - Economy (if sector specified)
    - All faction standings
    - Recent events (last 5, if include_events=true)
    """
    try:
        _, _, world_state, _ = await get_story_components()

        context = await world_state.get_world_context(
            sector=sector,
            include_events=include_events
        )

        return WorldContextResponse(
            success=True,
            context=context
        )

    except Exception as e:
        logger.error(f"Error getting world context: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"World context error: {str(e)}"
        )


@router.delete("/invalidate_cache", response_model=InvalidateCacheResponse)
async def invalidate_cache(request: InvalidateCacheRequest) -> InvalidateCacheResponse:
    """
    Invalidate cached narratives for player/mission.

    Call this when:
    - Player levels up
    - Major story choice made
    - Significant state change

    This forces fresh narrative generation on next request.
    """
    try:
        _, story_engine, _, _ = await get_story_components()

        deleted = await story_engine.invalidate_cache(
            request.player_id,
            request.mission_id,
            request.player_state
        )

        return InvalidateCacheResponse(
            success=True,
            deleted_count=deleted
        )

    except Exception as e:
        logger.error(f"Error invalidating cache: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Cache invalidation failed: {str(e)}"
        )


async def cleanup_redis_pool():
    """Cleanup Redis connection pool on shutdown."""
    global _redis_pool

    if _redis_pool is not None:
        logger.info("Closing Redis connection pool...")
        await _redis_pool.disconnect()
        _redis_pool = None
        logger.info("Redis connection pool closed")


# Export router and cleanup function
__all__ = ["router", "cleanup_redis_pool"]
