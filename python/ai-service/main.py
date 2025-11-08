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
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger

# Import API routers
from src.api import missions_router, chat_router, dialogue_router, orchestrator_router
from src.ai.client import get_ai_client

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO").upper(),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize APScheduler for background jobs
scheduler = AsyncIOScheduler()


# Background job functions
async def cleanup_old_memories():
    """
    Background job: Clean up old agent memories from Redis
    Runs every 5 minutes
    """
    try:
        logger.info("Running memory cleanup job...")
        # TODO: Implement Redis memory cleanup
        # - Remove observations older than 1 hour
        # - Clear expired conversation contexts
        # - Cleanup old action logs
        logger.debug("Memory cleanup completed")
    except Exception as e:
        logger.error(f"Error in memory cleanup job: {e}", exc_info=True)


async def health_check_job():
    """
    Background job: Health check for all services
    Runs every 1 minute
    """
    try:
        logger.debug("Running health check job...")
        # Check AI providers are available
        ai_client = get_ai_client()
        providers_health = await ai_client.health_check()

        # Log any unhealthy providers
        for provider, status in providers_health.items():
            if status != "healthy":
                logger.warning(f"Provider {provider} is {status}")

    except Exception as e:
        logger.error(f"Error in health check job: {e}", exc_info=True)

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
app.include_router(orchestrator_router)  # Multi-agent orchestration


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

    # Get scheduler status
    scheduler_status = "running" if scheduler.running else "stopped"
    scheduled_jobs = [
        {"id": job.id, "name": job.name, "next_run": job.next_run_time.isoformat() if job.next_run_time else None}
        for job in scheduler.get_jobs()
    ]

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
        "orchestrator_enabled": True,
        "scheduler": {
            "status": scheduler_status,
            "jobs": scheduled_jobs
        },
        "endpoints": {
            "missions": "/api/missions/generate",
            "chat": "/api/chat/message",
            "dialogue": "/api/dialogue/generate",
            "orchestrator": {
                "chat": "/api/orchestrator/chat",
                "route": "/api/orchestrator/route",
                "agents": "/api/orchestrator/agents",
                "health": "/api/orchestrator/health",
                "agent_loop": "/api/orchestrator/agent_loop"
            }
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
            "encounters": "/api/encounters/*",
            "orchestrator": "/api/orchestrator/*"
        }
    }


# Startup event
@app.on_event("startup")
async def startup_event():
    """Initialize AI client and background scheduler on startup."""
    logger.info("Starting AI Service...")
    try:
        ai_client = get_ai_client()
        available = ai_client.get_available_providers()
        logger.info(f"AI Service started with providers: {available}")

        # Start background scheduler
        logger.info("Starting background scheduler...")

        # Add memory cleanup job (every 5 minutes)
        scheduler.add_job(
            cleanup_old_memories,
            trigger=IntervalTrigger(minutes=5),
            id="memory_cleanup",
            name="Clean up old agent memories",
            replace_existing=True
        )

        # Add health check job (every 1 minute)
        scheduler.add_job(
            health_check_job,
            trigger=IntervalTrigger(minutes=1),
            id="health_check",
            name="Service health check",
            replace_existing=True
        )

        # Start scheduler
        scheduler.start()
        logger.info("Background scheduler started with jobs: memory_cleanup, health_check")

    except Exception as e:
        logger.error(f"Error during startup: {e}", exc_info=True)


# Shutdown event
@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown."""
    logger.info("Shutting down AI Service...")

    # Stop background scheduler
    if scheduler.running:
        scheduler.shutdown()
        logger.info("Background scheduler stopped")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", "17011")),
        log_level=os.getenv("LOG_LEVEL", "info")
    )
