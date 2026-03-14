"""Space Adventures - FastAPI Server

Web game backend with Claude Agent SDK game master.
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events."""
    # TODO: Initialize database, redis, agent SDK
    yield
    # TODO: Cleanup connections


app = FastAPI(
    title="Space Adventures",
    description="AI-powered sci-fi adventure game",
    version="2.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
from .api.game import router as game_router  # noqa: E402
from .api.ws import router as ws_router  # noqa: E402

app.include_router(game_router, prefix="/api/game", tags=["game"])
app.include_router(ws_router, prefix="/ws", tags=["websocket"])


@app.get("/health")
async def health():
    return {"status": "ok", "version": "2.0.0"}
