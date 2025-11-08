"""
AI Service - Content Generation Service for Space Adventures

This service handles all AI-powered content generation:
- Mission generation (story missions, random encounters)
- NPC dialogue generation
- Chat system with multiple AI personalities
- Command parsing
- Spontaneous events

Supports multiple AI providers:
- Claude (Anthropic) - For story content and critical narrative
- OpenAI GPT-3.5/4 - For random content and dialogue
- Ollama - For local, free content generation
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import os
from dotenv import load_dotenv
from datetime import datetime
import logging
from typing import Dict, Any

# Import API routers
from src.api import missions_router, chat_router, dialogue_router
from src.ai.client import get_ai_client

# Import background task system
from src.background import (
    get_scheduler,
    get_mission_queue,
    pregenerate_missions,
    generate_daily_events,
    cleanup_old_cache,
    refresh_galaxy_state,
    replenish_all_queues
)

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO").upper(),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Space Adventures AI Service",
    description="AI-powered content generation service",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API routers
app.include_router(missions_router)
app.include_router(chat_router)
app.include_router(dialogue_router)


# Health check endpoint
@app.get("/health")
async def health_check() -> Dict[str, Any]:
    """
    AI Service health check.
    Returns service status and available AI providers.
    """
    # Get AI client to check providers
    try:
        ai_client = get_ai_client()
        available_providers = ai_client.get_available_providers()
        providers_health = await ai_client.health_check()
    except Exception as e:
        logger.error(f"Error checking AI providers: {e}")
        available_providers = []
        providers_health = {}

    return {
        "status": "healthy",
        "service": "ai-service",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "0.1.0",
        "providers": {
            "available": available_providers,
            "health": providers_health
        },
        "cache_enabled": os.getenv("CACHE_ENABLED", "true") == "true",
        "endpoints": {
            "missions": "/api/missions/generate",
            "chat": "/api/chat/message",
            "dialogue": "/api/dialogue/generate"
        }
    }


@app.get("/")
async def root():
    """Root endpoint with service information."""
    return {
        "service": "Space Adventures AI Service",
        "version": "0.1.0",
        "status": "operational",
        "docs": "/docs",
        "health": "/health",
        "endpoints": {
            "missions": "/api/missions/*",
            "chat": "/api/chat/*",
            "dialogue": "/api/dialogue/*",
            "encounters": "/api/encounters/*"
        }
    }


# Startup event
@app.on_event("startup")
async def startup_event():
    """Initialize AI client and background tasks on startup."""
    logger.info("Starting AI Service...")

    # Initialize AI client
    try:
        ai_client = get_ai_client()
        available = ai_client.get_available_providers()
        logger.info(f"AI Service started with providers: {available}")
    except Exception as e:
        logger.error(f"Error initializing AI client: {e}")

    # Initialize and start background scheduler
    try:
        scheduler = get_scheduler()

        if scheduler.enabled:
            logger.info("Configuring AI-first background tasks...")

            # INTERVAL TASKS (periodic)
            # Pre-generate missions every 30 minutes
            scheduler.add_interval_task(
                replenish_all_queues,
                minutes=30,
                task_id="mission_replenishment"
            )

            # CRON TASKS (scheduled)
            # Daily events at 3 AM
            scheduler.add_cron_task(
                generate_daily_events,
                hour=3,
                minute=0,
                task_id="daily_events"
            )

            # Cache cleanup at 2 AM daily
            scheduler.add_cron_task(
                cleanup_old_cache,
                hour=2,
                minute=0,
                task_id="cache_cleanup"
            )

            # Weekly galaxy refresh on Mondays at 2 AM
            scheduler.add_cron_task(
                refresh_galaxy_state,
                hour=2,
                minute=0,
                day_of_week='mon',
                task_id="weekly_galaxy_refresh"
            )

            # Start the scheduler
            scheduler.start()

            # Optionally: Pre-generate some missions on startup
            startup_pregenerate = os.getenv("STARTUP_PREGENERATE", "false").lower() == "true"
            if startup_pregenerate:
                logger.info("Pre-generating initial missions...")
                await pregenerate_missions(count=2)

            logger.info("Background tasks configured and started")
        else:
            logger.info("Background tasks disabled")

    except Exception as e:
        logger.error(f"Error initializing background tasks: {e}")


# Shutdown event
@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown."""
    logger.info("Shutting down AI Service...")

    # Shutdown background scheduler
    try:
        scheduler = get_scheduler()
        scheduler.shutdown()
        logger.info("Background tasks shutdown complete")
    except Exception as e:
        logger.error(f"Error shutting down background tasks: {e}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", "17011")),
        log_level=os.getenv("LOG_LEVEL", "info")
    )
