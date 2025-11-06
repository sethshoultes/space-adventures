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

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Space Adventures AI Service",
    description="AI-powered content generation service",
    version="0.1.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Health check endpoint
@app.get("/health")
async def health_check() -> Dict[str, Any]:
    """
    AI Service health check.
    Returns service status and available AI providers.
    """
    # Check which AI providers are configured
    providers_status = {
        "claude": bool(os.getenv("ANTHROPIC_API_KEY")),
        "openai": bool(os.getenv("OPENAI_API_KEY")),
        "ollama": bool(os.getenv("OLLAMA_BASE_URL"))
    }

    return {
        "status": "healthy",
        "service": "ai-service",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "0.1.0",
        "providers": providers_status,
        "cache_enabled": os.getenv("CACHE_ENABLED", "true") == "true"
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


# API Endpoints will be added in separate router files
# These are placeholders showing the structure

@app.get("/api/missions/health")
async def missions_health():
    """Mission generation endpoint health check."""
    return {
        "endpoint": "missions",
        "status": "ready",
        "description": "Mission generation endpoint"
    }


@app.get("/api/chat/health")
async def chat_health():
    """Chat system endpoint health check."""
    return {
        "endpoint": "chat",
        "status": "ready",
        "description": "AI chat and conversation endpoint"
    }


@app.get("/api/dialogue/health")
async def dialogue_health():
    """Dialogue generation endpoint health check."""
    return {
        "endpoint": "dialogue",
        "status": "ready",
        "description": "NPC dialogue generation endpoint"
    }


@app.get("/api/encounters/health")
async def encounters_health():
    """Encounter generation endpoint health check."""
    return {
        "endpoint": "encounters",
        "status": "ready",
        "description": "Space encounter generation endpoint"
    }


# Placeholder for future AI generation endpoints
# These will be implemented in Phase 1, Week 2

"""
TODO Phase 1, Week 2:
- Implement AI provider clients (Claude, OpenAI, Ollama)
- Create prompt templates
- Implement mission generation endpoint
- Implement chat endpoint
- Implement dialogue generation
- Add Redis caching
- Add response validation
"""

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", "8001")),
        log_level=os.getenv("LOG_LEVEL", "info")
    )
