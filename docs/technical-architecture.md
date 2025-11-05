# Space Adventures - Technical Architecture

**Version:** 1.0
**Date:** November 5, 2025
**Purpose:** Implementation blueprint for development

---

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Technology Stack](#technology-stack)
3. [Project Structure](#project-structure)
4. [Data Models](#data-models)
5. [AI Service Architecture](#ai-service-architecture)
6. [Godot Integration](#godot-integration)
7. [Save System](#save-system)
8. [Development Workflow](#development-workflow)

---

## Architecture Overview

### System Design

```
┌─────────────────────────────────────────────────────┐
│                  GODOT ENGINE                       │
│  ┌───────────────────────────────────────────┐     │
│  │  Game Scenes (UI, Ship View, Missions)    │     │
│  └───────────────┬───────────────────────────┘     │
│                  │                                   │
│  ┌───────────────▼───────────────────────────┐     │
│  │    Game State Manager (GDScript)          │     │
│  │  - Ship systems, Inventory, Progress      │     │
│  └───────────────┬───────────────────────────┘     │
│                  │                                   │
│  ┌───────────────▼───────────────────────────┐     │
│  │    Save/Load System (JSON)                │     │
│  └───────────────┬───────────────────────────┘     │
└──────────────────┼───────────────────────────────┘
                   │ HTTP REST API
                   │
┌──────────────────▼───────────────────────────────┐
│           PYTHON AI SERVICE                       │
│  ┌─────────────────────────────────────────┐     │
│  │  FastAPI Server                         │     │
│  │  - /generate-mission                    │     │
│  │  - /generate-encounter                  │     │
│  │  - /generate-dialogue                   │     │
│  │  - /health                              │     │
│  └─────────────────┬───────────────────────┘     │
│                    │                               │
│  ┌─────────────────▼───────────────────────┐     │
│  │  LangChain Integration                  │     │
│  │  - OpenAI / Ollama support              │     │
│  │  - Prompt templates                     │     │
│  │  - Context management                   │     │
│  └─────────────────┬───────────────────────┘     │
│                    │                               │
│  ┌─────────────────▼───────────────────────┐     │
│  │  Response Cache (SQLite)                │     │
│  └─────────────────────────────────────────┘     │
└───────────────────────────────────────────────────┘
```

### Communication Flow

1. **Game Start:** Godot loads game state from save file
2. **Player Action:** Player makes a choice in Godot UI
3. **AI Request:** Godot sends HTTP request to Python service
4. **AI Processing:** Python service generates content via OpenAI/Ollama
5. **Response:** Python returns structured JSON to Godot
6. **Update:** Godot updates game state and UI
7. **Save:** Periodically save game state to file

### Containerized Architecture (Docker)

```
┌─────────────────────────────────────────────────────┐
│              DOCKER COMPOSE STACK                   │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌───────────────────┐  ┌───────────────────┐     │
│  │  Python FastAPI   │  │     Redis         │     │
│  │  AI Service       │←→│  Cache & Session  │     │
│  │  Port: 8000       │  │  Port: 6379       │     │
│  └───────────────────┘  └───────────────────┘     │
│           ↑                       ↑                │
│           │                       │                │
│           └───────────────────────┘                │
│                   Docker Network                   │
└─────────────────────────────────────────────────────┘
           ↑
           │ HTTP
           │
┌──────────┴──────────┐
│   GODOT (Native)    │
│   Game Client       │
│   localhost:8000    │
└─────────────────────┘
```

---

## Technology Stack

### Godot Engine (v4.2+)
**Why:**
- Excellent UI system
- Cross-platform
- Built-in scene management
- Easy 2D graphics
- HTTP request support

**Languages:** GDScript (primary), Python bridge (for AI)

### Python Backend (v3.10+)
**Components:**
- **FastAPI**: REST API server
- **LangChain**: AI integration framework
- **Pydantic**: Data validation
- **SQLite**: Response caching
- **python-dotenv**: Environment config

**Why:**
- Best AI library ecosystem
- OpenAI and Ollama support via LangChain
- Fast development
- Easy testing

### Additional Libraries
- **httpx**: Async HTTP client
- **rich**: CLI formatting (for dev tools)
- **pytest**: Testing framework

### Docker & Containerization
- **Docker**: Container runtime
- **Docker Compose**: Multi-container orchestration
- **Redis**: In-memory data store for caching

**Why:**
- Consistent development environment
- Easy deployment
- Isolated services
- Simple scaling
- Redis for fast caching (vs SQLite)

---

## Docker Configuration

### docker-compose.yml

```yaml
version: '3.8'

services:
  # Python AI Service
  ai-service:
    build:
      context: ./python
      dockerfile: Dockerfile
    container_name: space-adventures-ai
    ports:
      - "8000:8000"
    environment:
      - AI_PROVIDER=${AI_PROVIDER:-ollama}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - OLLAMA_BASE_URL=${OLLAMA_BASE_URL:-http://host.docker.internal:11434}
      - OLLAMA_MODEL=${OLLAMA_MODEL:-llama2}
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - API_HOST=0.0.0.0
      - API_PORT=8000
    volumes:
      - ./python:/app
      - ./generated_images:/app/generated_images
    depends_on:
      - redis
    networks:
      - space-adventures-network
    restart: unless-stopped

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: space-adventures-redis
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    command: redis-server --appendonly yes
    networks:
      - space-adventures-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3

  # Optional: Redis Commander (GUI for Redis)
  redis-commander:
    image: rediscommander/redis-commander:latest
    container_name: space-adventures-redis-ui
    environment:
      - REDIS_HOSTS=local:redis:6379
    ports:
      - "8081:8081"
    depends_on:
      - redis
    networks:
      - space-adventures-network
    restart: unless-stopped

networks:
  space-adventures-network:
    driver: bridge

volumes:
  redis-data:
    driver: local
```

### Python Dockerfile

```dockerfile
# python/Dockerfile

FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (for layer caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create directories for generated content
RUN mkdir -p /app/generated_images/cache

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the application
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
```

### .dockerignore

```
# python/.dockerignore

__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/
.venv
pip-log.txt
.pytest_cache/
.coverage
htmlcov/
*.egg-info/
dist/
build/

.env
*.env
!.env.example

# Generated content (mount as volume instead)
generated_images/cache/*
!generated_images/cache/.gitkeep

# Tests
tests/
.pytest_cache/

# Development
.vscode/
.idea/
*.swp
*.swo
*~
```

### Development Commands

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f ai-service

# Stop all services
docker-compose down

# Rebuild after code changes
docker-compose up -d --build

# Access Redis CLI
docker-compose exec redis redis-cli

# View Redis data (Web UI)
# Open http://localhost:8081 in browser

# Stop and remove volumes (clear cache)
docker-compose down -v
```

---

## Redis Caching System

### Redis Configuration

```python
# python/src/cache/redis_cache.py

import redis
from redis import asyncio as aioredis
import json
import hashlib
from typing import Optional, Any
from datetime import timedelta
import logging

logger = logging.getLogger(__name__)

class RedisCache:
    def __init__(
        self,
        host: str = "redis",
        port: int = 6379,
        db: int = 0,
        default_ttl: int = 86400  # 24 hours
    ):
        self.host = host
        self.port = port
        self.db = db
        self.default_ttl = default_ttl
        self.redis: Optional[aioredis.Redis] = None

    async def connect(self):
        """Establish Redis connection"""
        try:
            self.redis = await aioredis.from_url(
                f"redis://{self.host}:{self.port}/{self.db}",
                encoding="utf-8",
                decode_responses=True
            )
            # Test connection
            await self.redis.ping()
            logger.info(f"Connected to Redis at {self.host}:{self.port}")
        except Exception as e:
            logger.error(f"Failed to connect to Redis: {e}")
            raise

    async def disconnect(self):
        """Close Redis connection"""
        if self.redis:
            await self.redis.close()

    def _generate_key(self, prefix: str, data: dict) -> str:
        """Generate cache key from data"""
        data_str = json.dumps(data, sort_keys=True)
        hash_value = hashlib.md5(data_str.encode()).hexdigest()
        return f"{prefix}:{hash_value}"

    async def get(self, key: str) -> Optional[Any]:
        """Get value from cache"""
        try:
            value = await self.redis.get(key)
            if value:
                return json.loads(value)
            return None
        except Exception as e:
            logger.error(f"Redis GET error: {e}")
            return None

    async def set(
        self,
        key: str,
        value: Any,
        ttl: Optional[int] = None
    ) -> bool:
        """Set value in cache with TTL"""
        try:
            value_json = json.dumps(value)
            ttl = ttl or self.default_ttl
            await self.redis.setex(key, ttl, value_json)
            return True
        except Exception as e:
            logger.error(f"Redis SET error: {e}")
            return False

    async def delete(self, key: str) -> bool:
        """Delete key from cache"""
        try:
            await self.redis.delete(key)
            return True
        except Exception as e:
            logger.error(f"Redis DELETE error: {e}")
            return False

    async def exists(self, key: str) -> bool:
        """Check if key exists"""
        try:
            return await self.redis.exists(key) > 0
        except Exception as e:
            logger.error(f"Redis EXISTS error: {e}")
            return False

    async def get_or_set(
        self,
        key: str,
        factory_func,
        ttl: Optional[int] = None
    ) -> Any:
        """Get from cache or compute and store"""
        # Try to get from cache
        value = await self.get(key)
        if value is not None:
            return value

        # Cache miss - compute value
        value = await factory_func()

        # Store in cache
        await self.set(key, value, ttl)

        return value

    async def clear_pattern(self, pattern: str) -> int:
        """Clear all keys matching pattern"""
        try:
            keys = []
            async for key in self.redis.scan_iter(match=pattern):
                keys.append(key)

            if keys:
                return await self.redis.delete(*keys)
            return 0
        except Exception as e:
            logger.error(f"Redis CLEAR error: {e}")
            return 0

    async def get_stats(self) -> dict:
        """Get cache statistics"""
        try:
            info = await self.redis.info("stats")
            return {
                "total_connections": info.get("total_connections_received", 0),
                "total_commands": info.get("total_commands_processed", 0),
                "keyspace_hits": info.get("keyspace_hits", 0),
                "keyspace_misses": info.get("keyspace_misses", 0),
                "used_memory_human": info.get("used_memory_human", "0"),
            }
        except Exception as e:
            logger.error(f"Redis STATS error: {e}")
            return {}

# Global cache instance
cache = RedisCache()
```

### Cache Integration

```python
# python/src/main.py

from fastapi import FastAPI
from contextlib import asynccontextmanager
from src.cache.redis_cache import cache

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Connect to Redis
    await cache.connect()
    yield
    # Shutdown: Close Redis connection
    await cache.disconnect()

app = FastAPI(lifespan=lifespan)

@app.get("/health")
async def health():
    redis_healthy = await cache.redis.ping() if cache.redis else False
    return {
        "status": "healthy" if redis_healthy else "degraded",
        "redis": "connected" if redis_healthy else "disconnected"
    }

@app.get("/cache/stats")
async def cache_stats():
    """Get cache statistics"""
    stats = await cache.get_stats()
    return {"cache_stats": stats}
```

### Caching AI Responses

```python
# python/src/api/missions.py

from src.cache.redis_cache import cache

@router.post("/generate")
async def generate_mission(request: MissionGenerationRequest):
    """Generate mission with Redis caching"""

    # Generate cache key
    cache_key = cache._generate_key("mission", {
        "difficulty": request.difficulty,
        "reward_type": request.required_reward_type,
        "player_level": request.game_state.player.level
    })

    # Try to get from cache
    async def generate_new_mission():
        # ... AI generation logic ...
        return mission_data

    # Get from cache or generate new
    mission = await cache.get_or_set(
        cache_key,
        generate_new_mission,
        ttl=172800  # 48 hours
    )

    return {"mission": mission, "cached": await cache.exists(cache_key)}
```

### Cache Management Endpoints

```python
# python/src/api/cache.py

from fastapi import APIRouter, HTTPException
from src.cache.redis_cache import cache

router = APIRouter()

@router.delete("/cache/clear")
async def clear_cache(pattern: str = "*"):
    """Clear cache by pattern"""
    count = await cache.clear_pattern(pattern)
    return {"cleared_keys": count}

@router.get("/cache/stats")
async def get_cache_stats():
    """Get cache statistics"""
    stats = await cache.get_stats()
    return stats

@router.get("/cache/key/{key}")
async def get_cache_key(key: str):
    """Get specific cache key"""
    value = await cache.get(key)
    if value is None:
        raise HTTPException(status_code=404, detail="Key not found")
    return {"key": key, "value": value}

@router.delete("/cache/key/{key}")
async def delete_cache_key(key: str):
    """Delete specific cache key"""
    success = await cache.delete(key)
    if not success:
        raise HTTPException(status_code=404, detail="Key not found")
    return {"deleted": key}
```

---

## Project Structure

```
space-adventures/
├── README.md
├── .env.example                    # Environment variables template
├── .gitignore
│
├── docs/                           # All design documents
│   ├── game-design-document.md
│   ├── technical-architecture.md
│   ├── ship-systems.md
│   ├── mission-framework.md
│   ├── ai-integration.md
│   └── mvp-roadmap.md
│
├── godot/                          # Godot project
│   ├── project.godot               # Godot project file
│   ├── icon.svg
│   │
│   ├── scenes/                     # Game scenes
│   │   ├── main_menu.tscn
│   │   ├── workshop.tscn           # Phase 1 hub
│   │   ├── ship_dashboard.tscn     # Phase 2 main view
│   │   ├── mission_select.tscn
│   │   ├── mission_play.tscn
│   │   ├── ship_schematic.tscn
│   │   └── encounter.tscn
│   │
│   ├── scripts/                    # GDScript files
│   │   ├── autoload/               # Singleton scripts
│   │   │   ├── game_state.gd       # Global game state
│   │   │   ├── ai_service.gd       # AI API client
│   │   │   ├── save_manager.gd     # Save/load system
│   │   │   └── event_bus.gd        # Event system
│   │   │
│   │   ├── ui/                     # UI controllers
│   │   │   ├── workshop_ui.gd
│   │   │   ├── ship_dashboard_ui.gd
│   │   │   ├── mission_ui.gd
│   │   │   └── schematic_view.gd
│   │   │
│   │   ├── systems/                # Ship system logic
│   │   │   ├── ship_system.gd      # Base class
│   │   │   ├── hull_system.gd
│   │   │   ├── power_system.gd
│   │   │   ├── propulsion_system.gd
│   │   │   └── ... (other systems)
│   │   │
│   │   ├── missions/               # Mission logic
│   │   │   ├── mission.gd          # Base mission class
│   │   │   ├── mission_manager.gd
│   │   │   └── scripted_missions/  # Pre-written missions
│   │   │
│   │   └── encounters/             # Space encounter logic
│   │       ├── encounter.gd
│   │       └── encounter_manager.gd
│   │
│   ├── assets/                     # Game assets
│   │   ├── sprites/                # 2D images
│   │   │   ├── ships/
│   │   │   ├── items/
│   │   │   └── icons/
│   │   ├── fonts/                  # Typography
│   │   ├── audio/                  # Sound effects (future)
│   │   └── data/                   # Static game data
│   │       ├── ship_parts.json     # All ship parts/upgrades
│   │       ├── locations.json      # Earth locations
│   │       └── star_systems.json   # Space locations
│   │
│   └── saves/                      # Save game files
│       └── .gitkeep
│
├── python/                         # Python AI service
│   ├── requirements.txt
│   ├── .env                        # Environment variables (not in git)
│   │
│   ├── src/
│   │   ├── __init__.py
│   │   ├── main.py                 # FastAPI app entry
│   │   │
│   │   ├── api/                    # API endpoints
│   │   │   ├── __init__.py
│   │   │   ├── missions.py         # Mission generation
│   │   │   ├── encounters.py       # Encounter generation
│   │   │   └── dialogue.py         # NPC dialogue
│   │   │
│   │   ├── ai/                     # AI integration
│   │   │   ├── __init__.py
│   │   │   ├── client.py           # LangChain setup
│   │   │   ├── prompts.py          # Prompt templates
│   │   │   └── context.py          # Context management
│   │   │
│   │   ├── models/                 # Pydantic models
│   │   │   ├── __init__.py
│   │   │   ├── game_state.py       # Game state schema
│   │   │   ├── mission.py          # Mission schema
│   │   │   ├── encounter.py        # Encounter schema
│   │   │   └── ship.py             # Ship schema
│   │   │
│   │   ├── cache/                  # Response caching
│   │   │   ├── __init__.py
│   │   │   └── sqlite_cache.py
│   │   │
│   │   └── utils/                  # Utilities
│   │       ├── __init__.py
│   │       └── config.py           # Configuration
│   │
│   ├── tests/                      # Unit tests
│   │   ├── __init__.py
│   │   ├── test_api.py
│   │   └── test_ai.py
│   │
│   └── scripts/                    # Dev tools
│       ├── start_server.py
│       └── test_generation.py
│
├── tools/                          # Development utilities
│   ├── ship_part_generator.py      # Generate ship_parts.json
│   └── mission_validator.py        # Validate mission files
│
└── .vscode/                        # VSCode settings (optional)
    ├── settings.json
    └── launch.json
```

---

## Data Models

### Core Data Schemas

#### **GameState** (Python/Godot compatible)

```python
# Python (Pydantic)
class GameState(BaseModel):
    version: str = "1.0.0"
    player: Player
    ship: Ship
    inventory: List[Item]
    progress: Progress
    current_location: str
    timestamp: datetime

class Player(BaseModel):
    name: str
    level: int = 1
    xp: int = 0
    skills: Dict[str, int]  # {"engineering": 5, "diplomacy": 3, ...}

class Ship(BaseModel):
    name: str = "Unnamed Vessel"
    systems: Dict[str, ShipSystem]  # {"hull": ShipSystem(...), ...}
    hull_hp: int
    max_hull_hp: int
    power_available: int
    power_total: int

class ShipSystem(BaseModel):
    system_type: str  # "hull", "power", "warp", etc.
    level: int  # 0-5
    installed_part: Optional[str]  # Part ID
    health: int  # 0-100
    active: bool

class Item(BaseModel):
    id: str
    name: str
    type: str  # "ship_part", "resource", "quest_item"
    rarity: str  # "common", "uncommon", "rare", "epic", "legendary"
    system_type: Optional[str]  # Which system it upgrades
    level: int  # What level it provides
    description: str

class Progress(BaseModel):
    phase: int  # 1 = Earthbound, 2 = Space
    completed_missions: List[str]
    discovered_locations: List[str]
    met_characters: List[str]
    major_choices: List[Choice]

class Choice(BaseModel):
    id: str
    description: str
    timestamp: datetime
    consequences: List[str]
```

#### **GDScript Equivalent**

```gdscript
# game_state.gd (Autoload singleton)
extends Node

var game_version: String = "1.0.0"

var player: Dictionary = {
    "name": "Player",
    "level": 1,
    "xp": 0,
    "skills": {"engineering": 0, "diplomacy": 0, "combat": 0, "science": 0}
}

var ship: Dictionary = {
    "name": "Unnamed Vessel",
    "systems": {},  # Will contain ShipSystem objects
    "hull_hp": 0,
    "max_hull_hp": 0,
    "power_available": 0,
    "power_total": 0
}

var inventory: Array = []  # Array of Item dictionaries
var progress: Dictionary = {
    "phase": 1,
    "completed_missions": [],
    "discovered_locations": [],
    "met_characters": [],
    "major_choices": []
}

var current_location: String = "workshop"

func _ready():
    initialize_ship_systems()

func initialize_ship_systems():
    var system_types = ["hull", "power", "propulsion", "warp", "life_support",
                        "computer", "sensors", "shields", "weapons", "communications"]
    for sys_type in system_types:
        ship.systems[sys_type] = {
            "type": sys_type,
            "level": 0,
            "installed_part": null,
            "health": 100,
            "active": false
        }
```

---

## AI Service Architecture

### FastAPI Server Structure

#### **main.py**

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.api import missions, encounters, dialogue
from src.utils.config import settings

app = FastAPI(
    title="Space Adventures AI Service",
    version="1.0.0"
)

# Allow Godot to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict this
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(missions.router, prefix="/api/missions", tags=["missions"])
app.include_router(encounters.router, prefix="/api/encounters", tags=["encounters"])
app.include_router(dialogue.router, prefix="/api/dialogue", tags=["dialogue"])

@app.get("/")
async def root():
    return {"status": "online", "service": "Space Adventures AI"}

@app.get("/health")
async def health():
    return {"status": "healthy"}
```

#### **API Endpoints**

##### **POST /api/missions/generate**

Request:
```json
{
  "game_state": {
    "player": {"level": 3, "skills": {...}},
    "ship": {"systems": {...}},
    "progress": {"completed_missions": [...]}
  },
  "difficulty": "medium",
  "required_reward_type": "warp_drive"
}
```

Response:
```json
{
  "mission_id": "mission_generated_12345",
  "title": "Echoes in Hangar 7",
  "location": "Kennedy Spaceport",
  "description": "Sensors indicate movement in the abandoned hangar...",
  "difficulty": 2,
  "objective": "Retrieve the warp coil without alerting security drones",
  "reward": {
    "item_id": "warp_coil_rare",
    "xp": 150
  },
  "narrative": {
    "intro": "You approach the rusted gates...",
    "stages": [
      {
        "description": "The hangar bay is dark...",
        "choices": [
          {"id": "hack", "text": "Hack the security terminal", "requires": {"engineering": 3}},
          {"id": "stealth", "text": "Sneak past the drones", "requires": {}},
          {"id": "force", "text": "Disable the drones by force", "requires": {"combat": 2}}
        ]
      }
    ]
  }
}
```

##### **POST /api/encounters/generate**

Request:
```json
{
  "game_state": {...},
  "location": "Rigel System",
  "encounter_type": "exploration"
}
```

Response:
```json
{
  "encounter_id": "enc_rigel_12345",
  "type": "exploration",
  "title": "Quantum Anomaly Detected",
  "description": "Your sensors pick up something impossible - a spatial rift...",
  "choices": [
    {
      "id": "investigate",
      "text": "Move closer to investigate",
      "requirements": {"sensors": 3},
      "consequences": {"type": "skill_check", "skill": "science", "dc": 12}
    },
    {
      "id": "scan_distance",
      "text": "Scan from a safe distance",
      "requirements": {},
      "consequences": {"type": "safe", "reward": "data"}
    },
    {
      "id": "leave",
      "text": "Mark location and continue journey",
      "requirements": {},
      "consequences": {"type": "neutral"}
    }
  ]
}
```

##### **POST /api/dialogue/generate**

Request:
```json
{
  "game_state": {...},
  "character_id": "alien_ambassador",
  "context": "First contact with the Zenari species",
  "player_input": "We come in peace. What brings you to this sector?"
}
```

Response:
```json
{
  "character": "alien_ambassador",
  "dialogue": "Peace... an interesting concept. We Zenari measure intentions through action, not words. Your vessel - primitive yet functional. Tell me, do you seek knowledge or conquest?",
  "emotional_tone": "curious_suspicious",
  "choices": [
    {"id": "knowledge", "text": "We seek to learn about the universe and its inhabitants."},
    {"id": "honest", "text": "We seek survival and a place to call home."},
    {"id": "evasive", "text": "We seek what all travelers seek - opportunity."}
  ]
}
```

---

## Godot Integration

### AI Service Client (GDScript)

#### **autoload/ai_service.gd**

```gdscript
extends Node

const API_BASE_URL = "http://localhost:8000/api"

var http_client = HTTPRequest.new()

func _ready():
    add_child(http_client)
    http_client.request_completed.connect(_on_request_completed)

# Generate a mission
func generate_mission(difficulty: String, reward_type: String) -> Dictionary:
    var request_data = {
        "game_state": _get_game_state_dict(),
        "difficulty": difficulty,
        "required_reward_type": reward_type
    }

    var result = await _post_request("/missions/generate", request_data)
    return result

# Generate encounter
func generate_encounter(location: String, encounter_type: String) -> Dictionary:
    var request_data = {
        "game_state": _get_game_state_dict(),
        "location": location,
        "encounter_type": encounter_type
    }

    var result = await _post_request("/encounters/generate", request_data)
    return result

# Generate dialogue
func generate_dialogue(character_id: String, context: String, player_input: String) -> Dictionary:
    var request_data = {
        "game_state": _get_game_state_dict(),
        "character_id": character_id,
        "context": context,
        "player_input": player_input
    }

    var result = await _post_request("/dialogue/generate", request_data)
    return result

# Internal helper for POST requests
func _post_request(endpoint: String, data: Dictionary) -> Dictionary:
    var url = API_BASE_URL + endpoint
    var headers = ["Content-Type: application/json"]
    var json_data = JSON.stringify(data)

    var error = http_client.request(url, headers, HTTPClient.METHOD_POST, json_data)

    if error != OK:
        push_error("Failed to send request: " + str(error))
        return {"error": "Request failed"}

    # Wait for response
    var response = await http_client.request_completed
    var result_code = response[1]
    var body = response[3]

    if result_code == 200:
        var json = JSON.new()
        var parse_result = json.parse(body.get_string_from_utf8())
        if parse_result == OK:
            return json.data
        else:
            push_error("Failed to parse JSON response")
            return {"error": "Parse failed"}
    else:
        push_error("HTTP error: " + str(result_code))
        return {"error": "HTTP " + str(result_code)}

func _on_request_completed(result, response_code, headers, body):
    pass  # Handled by awaits

# Convert current game state to dictionary for API
func _get_game_state_dict() -> Dictionary:
    return {
        "player": GameState.player.duplicate(),
        "ship": GameState.ship.duplicate(),
        "inventory": GameState.inventory.duplicate(),
        "progress": GameState.progress.duplicate(),
        "current_location": GameState.current_location
    }
```

---

## Save System

### Save File Format (JSON)

**Location:** `godot/saves/save_slot_1.json`

```json
{
  "version": "1.0.0",
  "timestamp": "2025-11-05T14:32:15Z",
  "playtime_seconds": 7200,
  "player": {
    "name": "Commander Smith",
    "level": 5,
    "xp": 1250,
    "skills": {
      "engineering": 7,
      "diplomacy": 4,
      "combat": 5,
      "science": 6
    }
  },
  "ship": {
    "name": "Endeavour",
    "systems": {
      "hull": {"level": 2, "installed_part": "reinforced_hull_uncommon", "health": 85, "active": true},
      "power": {"level": 3, "installed_part": "fusion_reactor_rare", "health": 100, "active": true}
    },
    "hull_hp": 170,
    "max_hull_hp": 200
  },
  "inventory": [
    {"id": "warp_coil_rare", "name": "Rare Warp Coil", "type": "ship_part", "rarity": "rare"}
  ],
  "progress": {
    "phase": 1,
    "completed_missions": ["mission_001", "mission_002"],
    "discovered_locations": ["workshop", "kennedy_spaceport"],
    "major_choices": [
      {"id": "choice_001", "description": "Helped the scavenger", "timestamp": "2025-11-05T12:15:00Z"}
    ]
  },
  "current_location": "workshop"
}
```

### Save Manager (GDScript)

#### **autoload/save_manager.gd**

```gdscript
extends Node

const SAVE_DIR = "user://saves/"
const SAVE_FILE_PREFIX = "save_slot_"

func _ready():
    # Ensure save directory exists
    var dir = DirAccess.open("user://")
    if not dir.dir_exists("saves"):
        dir.make_dir("saves")

func save_game(slot: int = 1) -> bool:
    var save_path = SAVE_DIR + SAVE_FILE_PREFIX + str(slot) + ".json"

    var save_data = {
        "version": GameState.game_version,
        "timestamp": Time.get_datetime_string_from_system(),
        "playtime_seconds": 0,  # TODO: Track playtime
        "player": GameState.player.duplicate(true),
        "ship": GameState.ship.duplicate(true),
        "inventory": GameState.inventory.duplicate(true),
        "progress": GameState.progress.duplicate(true),
        "current_location": GameState.current_location
    }

    var file = FileAccess.open(save_path, FileAccess.WRITE)
    if file == null:
        push_error("Failed to open save file for writing: " + save_path)
        return false

    var json_string = JSON.stringify(save_data, "\t")  # Pretty print
    file.store_string(json_string)
    file.close()

    print("Game saved to slot ", slot)
    return true

func load_game(slot: int = 1) -> bool:
    var save_path = SAVE_DIR + SAVE_FILE_PREFIX + str(slot) + ".json"

    if not FileAccess.file_exists(save_path):
        push_error("Save file does not exist: " + save_path)
        return false

    var file = FileAccess.open(save_path, FileAccess.READ)
    if file == null:
        push_error("Failed to open save file for reading: " + save_path)
        return false

    var json_string = file.get_as_text()
    file.close()

    var json = JSON.new()
    var parse_result = json.parse(json_string)

    if parse_result != OK:
        push_error("Failed to parse save file JSON")
        return false

    var save_data = json.data

    # Version check
    if save_data.get("version", "") != GameState.game_version:
        push_warning("Save file version mismatch. Migration may be needed.")

    # Load data into GameState
    GameState.player = save_data.get("player", {})
    GameState.ship = save_data.get("ship", {})
    GameState.inventory = save_data.get("inventory", [])
    GameState.progress = save_data.get("progress", {})
    GameState.current_location = save_data.get("current_location", "workshop")

    print("Game loaded from slot ", slot)
    return true

func get_save_info(slot: int) -> Dictionary:
    """Get metadata about a save file without fully loading it"""
    var save_path = SAVE_DIR + SAVE_FILE_PREFIX + str(slot) + ".json"

    if not FileAccess.file_exists(save_path):
        return {"exists": false}

    var file = FileAccess.open(save_path, FileAccess.READ)
    if file == null:
        return {"exists": false}

    var json_string = file.get_as_text()
    file.close()

    var json = JSON.new()
    var parse_result = json.parse(json_string)

    if parse_result != OK:
        return {"exists": true, "valid": false}

    var data = json.data
    return {
        "exists": true,
        "valid": true,
        "player_name": data.get("player", {}).get("name", "Unknown"),
        "timestamp": data.get("timestamp", ""),
        "phase": data.get("progress", {}).get("phase", 1),
        "player_level": data.get("player", {}).get("level", 1)
    }
```

---

## Development Workflow

### Phase 1: Setup (Week 1)
1. Initialize Godot project
2. Create Python virtual environment
3. Set up FastAPI skeleton
4. Implement basic AI service connection
5. Create GameState singleton
6. Implement save/load system

### Phase 2: Core Systems (Weeks 2-3)
1. Ship system classes
2. Inventory system
3. Mission framework
4. Basic UI layouts

### Phase 3: Content (Weeks 4-5)
1. Ship parts database
2. Scripted missions
3. AI prompt templates
4. Test encounters

### Phase 4: Polish (Week 6)
1. Graphics and visual polish
2. Bug fixes
3. Balance tuning
4. Playtesting

### Testing Strategy
- **Unit Tests:** Python AI service (pytest)
- **Integration Tests:** API endpoints
- **Manual Tests:** Godot gameplay
- **AI Tests:** Prompt quality and consistency

### Git Workflow
```bash
# Feature branches
git checkout -b feature/ship-systems
git checkout -b feature/ai-integration
git checkout -b feature/mission-framework

# Regular commits
git commit -m "feat: Add hull system implementation"
git commit -m "fix: Save file JSON parsing error"
git commit -m "docs: Update ship systems specification"
```

---

## Configuration Management

### Environment Variables (.env)

```bash
# AI Service Configuration
OPENAI_API_KEY=sk-your-key-here
OLLAMA_BASE_URL=http://localhost:11434

# AI Provider: "openai" or "ollama"
AI_PROVIDER=ollama

# Model Selection
OPENAI_MODEL=gpt-4
OLLAMA_MODEL=llama2

# Service Configuration
API_HOST=0.0.0.0
API_PORT=8000
DEBUG=true

# Cache Settings
CACHE_ENABLED=true
CACHE_TTL_SECONDS=3600
```

### Godot Project Settings

```
[autoload]
GameState="*res://scripts/autoload/game_state.gd"
SaveManager="*res://scripts/autoload/save_manager.gd"
AIService="*res://scripts/autoload/ai_service.gd"
EventBus="*res://scripts/autoload/event_bus.gd"

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"

[rendering]
textures/canvas_textures/default_texture_filter=0  # Pixel perfect
```

---

## Performance Considerations

### AI Response Times
- **OpenAI**: ~2-5 seconds
- **Ollama (local)**: ~5-15 seconds depending on model/hardware
- **Mitigation**: Show loading indicator, cache responses

### Memory Management
- **Godot**: Keep unused scenes freed
- **Python**: Limit cache size, cleanup old entries

### Save File Size
- **Target**: <1 MB per save
- **Strategy**: Only save essential data, compress if needed

---

## Security Considerations

### API Keys
- Never commit .env to git
- Use environment variables
- Rotate keys periodically

### Save File Validation
- Check version compatibility
- Validate data types
- Handle corrupted files gracefully

### User Input
- Sanitize player names
- Limit text input lengths
- Validate all data from saves

---

**Document Status:** Draft v1.0
**Last Updated:** November 5, 2025
