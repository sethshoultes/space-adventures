"""Space Adventures — FastAPI Server

Web game backend with Claude-powered Game Master.
"""

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .state.database import GameDatabase
from .memory.manager import MemoryManager
from .game_master.agent import GameMasterAgent
from .api import game as game_api
from .api import ws as ws_api

logging.basicConfig(
    level=logging.DEBUG if settings.debug else logging.INFO,
    format="%(asctime)s %(name)s %(levelname)s %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events."""
    logger.info("Starting Space Adventures server...")

    # Initialize database
    db = GameDatabase(settings.database_path)
    await db.connect()
    logger.info("Database connected: %s", settings.database_path)

    # Initialize memory manager
    memory = MemoryManager(settings.memory_dir)
    logger.info("Memory manager initialized: %s", settings.memory_dir)

    # Initialize Game Master agent
    agent = GameMasterAgent(memory)
    logger.info("Game Master agent initialized (model: %s)", settings.claude_model)

    # Wire dependencies into route modules
    game_api.db = db
    game_api.agent = agent
    ws_api.db = db
    ws_api.agent = agent

    yield

    # Cleanup
    await db.close()
    logger.info("Server shutdown complete.")


app = FastAPI(
    title="Space Adventures",
    description="AI-powered sci-fi adventure game with Claude Game Master",
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
app.include_router(game_api.router, prefix="/api/game", tags=["game"])
app.include_router(ws_api.router, prefix="/ws", tags=["websocket"])


@app.get("/health")
async def health():
    return {"status": "ok", "version": "2.0.0", "model": settings.claude_model}
