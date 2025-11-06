"""
Gateway Service - API Gateway for Space Adventures

This service acts as the single entry point for all backend services.
It routes requests to appropriate services and provides:
- Request routing
- Health check aggregation
- CORS handling
- Future: Authentication, rate limiting, logging
"""

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import httpx
import os
from dotenv import load_dotenv
from datetime import datetime
from typing import Dict, Any
import logging

# Import custom middleware
from src.middleware import RequestLoggingMiddleware, service_registry

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
    title="Space Adventures Gateway",
    description="API Gateway for Space Adventures backend services",
    version="0.1.0"
)

# Add custom middleware (order matters!)
app.add_middleware(RequestLoggingMiddleware)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Service URLs from environment
AI_SERVICE_URL = os.getenv("AI_SERVICE_URL", "http://localhost:8001")
WHISPER_SERVICE_URL = os.getenv("WHISPER_SERVICE_URL", "http://localhost:8002")
IMAGE_SERVICE_URL = os.getenv("IMAGE_SERVICE_URL", "http://localhost:8003")

SERVICE_TIMEOUT = int(os.getenv("SERVICE_TIMEOUT", "30"))

# Register services with service registry
service_registry.register_service("ai-service", AI_SERVICE_URL)
service_registry.register_service("whisper-service", WHISPER_SERVICE_URL)
service_registry.register_service("image-service", IMAGE_SERVICE_URL)


# Health check endpoint
@app.get("/health")
async def health_check() -> Dict[str, Any]:
    """
    Gateway health check.
    Returns health status of gateway and downstream services.
    """
    return {
        "status": "healthy",
        "service": "gateway",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "0.1.0"
    }


@app.get("/health/all")
async def health_check_all() -> Dict[str, Any]:
    """
    Aggregate health check for all services.
    Checks gateway + all downstream services.
    """
    services_status = {
        "gateway": {"status": "healthy", "url": "local"}
    }

    # Check AI Service
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(f"{AI_SERVICE_URL}/health")
            if response.status_code == 200:
                services_status["ai-service"] = {
                    "status": "healthy",
                    "url": AI_SERVICE_URL
                }
            else:
                services_status["ai-service"] = {
                    "status": "unhealthy",
                    "url": AI_SERVICE_URL,
                    "error": f"Status code: {response.status_code}"
                }
    except Exception as e:
        services_status["ai-service"] = {
            "status": "unreachable",
            "url": AI_SERVICE_URL,
            "error": str(e)
        }

    # Check Whisper Service
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(f"{WHISPER_SERVICE_URL}/health")
            if response.status_code == 200:
                services_status["whisper-service"] = {
                    "status": "healthy",
                    "url": WHISPER_SERVICE_URL
                }
            else:
                services_status["whisper-service"] = {
                    "status": "unhealthy",
                    "url": WHISPER_SERVICE_URL,
                    "error": f"Status code: {response.status_code}"
                }
    except Exception as e:
        services_status["whisper-service"] = {
            "status": "unreachable",
            "url": WHISPER_SERVICE_URL,
            "error": str(e)
        }

    # Determine overall health
    all_healthy = all(
        svc.get("status") == "healthy"
        for svc in services_status.values()
    )

    return {
        "status": "healthy" if all_healthy else "degraded",
        "timestamp": datetime.utcnow().isoformat(),
        "services": services_status
    }


# AI Service routes
@app.api_route("/api/v1/ai/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def proxy_ai_service(request: Request, path: str):
    """
    Proxy requests to AI Service.
    Forwards all requests to /api/v1/ai/* to the AI service.
    """
    try:
        # Build target URL
        target_url = f"{AI_SERVICE_URL}/api/{path}"

        # Get request body if present
        body = await request.body()

        # Forward request
        async with httpx.AsyncClient(timeout=SERVICE_TIMEOUT) as client:
            response = await client.request(
                method=request.method,
                url=target_url,
                content=body,
                headers=dict(request.headers),
                params=request.query_params
            )

            # Return response
            return JSONResponse(
                content=response.json(),
                status_code=response.status_code
            )

    except httpx.TimeoutException:
        logger.error(f"Timeout calling AI service: {path}")
        raise HTTPException(
            status_code=504,
            detail="AI service timeout"
        )
    except Exception as e:
        logger.error(f"Error proxying to AI service: {e}")
        raise HTTPException(
            status_code=502,
            detail=f"AI service error: {str(e)}"
        )


# Whisper Service routes
@app.api_route("/api/v1/whisper/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def proxy_whisper_service(request: Request, path: str):
    """
    Proxy requests to Whisper Service.
    Forwards all requests to /api/v1/whisper/* to the Whisper service.
    """
    try:
        # Build target URL
        target_url = f"{WHISPER_SERVICE_URL}/api/{path}"

        # Get request body if present
        body = await request.body()

        # Forward request
        async with httpx.AsyncClient(timeout=SERVICE_TIMEOUT) as client:
            response = await client.request(
                method=request.method,
                url=target_url,
                content=body,
                headers=dict(request.headers),
                params=request.query_params
            )

            # Return response
            return JSONResponse(
                content=response.json(),
                status_code=response.status_code
            )

    except httpx.TimeoutException:
        logger.error(f"Timeout calling Whisper service: {path}")
        raise HTTPException(
            status_code=504,
            detail="Whisper service timeout"
        )
    except Exception as e:
        logger.error(f"Error proxying to Whisper service: {e}")
        raise HTTPException(
            status_code=502,
            detail=f"Whisper service error: {str(e)}"
        )


# Root endpoint
@app.get("/")
async def root():
    """Root endpoint with service information."""
    return {
        "service": "Space Adventures Gateway",
        "version": "0.1.0",
        "status": "operational",
        "docs": "/docs",
        "health": "/health"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", "8000")),
        log_level=os.getenv("LOG_LEVEL", "info")
    )
