# Python Services

**Purpose:** Backend microservices for Space Adventures
**Parent:** [../CLAUDE.md](../CLAUDE.md)
**Design Docs:** [Technical Architecture](../docs/technical-architecture.md)

## Overview

This directory contains all Python-based backend services for Space Adventures. The architecture uses independent microservices that communicate via HTTP REST APIs.

All services are built with **FastAPI** and follow the same patterns for consistency.

## Services Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GODOT GAME CLIENT                        │
└───────────────────────────┬─────────────────────────────────┘
                            │ HTTP Clients
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Gateway    │    │     AI       │    │   Whisper    │
│   Service    │───▶│   Service    │    │   Service    │
│  Port 8000   │    │  Port 8001   │    │  Port 8002   │
└──────┬───────┘    └──────┬───────┘    └──────────────┘
       │                   │
       ▼                   ▼
┌──────────────────────────────────────┐
│         Support Services             │
│  ┌─────────┐  ┌─────────┐          │
│  │ Redis   │  │ SQLite  │          │
│  │  6379   │  │  Local  │          │
│  └─────────┘  └─────────┘          │
└──────────────────────────────────────┘
```

## Directory Structure

```
python/
├── CLAUDE.md                    # This file
├── gateway/                     # Gateway Service (Port 8000)
│   ├── CLAUDE.md               # Gateway documentation
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── .env.example
│   ├── main.py                 # FastAPI app
│   ├── src/
│   │   └── api/                # API routes
│   └── tests/
├── ai-service/                  # AI Service (Port 8001)
│   ├── CLAUDE.md               # AI service documentation
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── .env.example
│   ├── main.py                 # FastAPI app
│   ├── src/
│   │   ├── api/                # API endpoints (missions, chat, dialogue)
│   │   ├── ai/                 # AI provider clients
│   │   │   └── providers/      # Claude, OpenAI, Ollama
│   │   ├── models/             # Pydantic models
│   │   ├── cache/              # Redis caching
│   │   └── utils/              # Utilities
│   └── tests/
├── whisper-service/             # Whisper Service (Port 8002)
│   ├── CLAUDE.md               # Whisper documentation
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── .env.example
│   ├── main.py                 # FastAPI app
│   ├── src/
│   │   └── api/                # Transcription endpoints
│   └── tests/
└── shared/                      # Shared code
    ├── __init__.py
    ├── models/                  # Shared Pydantic models
    │   ├── response.py         # StandardResponse, ErrorResponse
    │   └── __init__.py
    └── utils/                   # Shared utilities
```

## Service Responsibilities

### Gateway Service (Port 8000)
**Purpose:** Single entry point for all backend services

**Routes:**
- `/health` - Health check
- `/health/all` - Aggregate health of all services
- `/api/v1/ai/*` → Routes to AI Service
- `/api/v1/whisper/*` → Routes to Whisper Service

**Key Features:**
- Request routing
- CORS handling
- Future: Authentication, rate limiting, logging

### AI Service (Port 8001)
**Purpose:** AI-powered content generation

**Endpoints:**
- `/api/missions/generate` - Generate missions
- `/api/chat/message` - Process chat messages
- `/api/dialogue/generate` - Generate NPC dialogue
- `/api/encounters/generate` - Generate space encounters

**AI Providers:**
- **Claude** (Anthropic) - Story missions, critical narrative
- **OpenAI GPT-3.5/4** - Random content, NPC dialogue
- **Ollama** - Local, free content (ship docs, UI text)

**Dependencies:**
- Redis (caching)
- SQLite (conversation history per save)

### Whisper Service (Port 8002) - Optional
**Purpose:** Voice-to-text transcription

**Endpoints:**
- `/api/transcribe` - Transcribe audio file
- `/api/models` - List available Whisper models

**Features:**
- Supports WAV, MP3, OGG, FLAC, M4A
- 90+ languages supported
- Local processing (privacy-first)
- Optional service (graceful degradation)

### Shared Package
**Purpose:** Common code used by all services

**Contents:**
- `models/response.py` - Standard API response formats
- `utils/` - Shared utility functions
- Future: Authentication, logging, validation

## Development Guidelines

### Starting Services

**All services (without Whisper):**
```bash
docker-compose up -d
```

**With voice transcription:**
```bash
docker-compose --profile voice up -d
```

**With debug tools (Redis Commander):**
```bash
docker-compose --profile debug up -d
```

**Individual service:**
```bash
cd python/[service-name]
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your settings
uvicorn main:app --reload --port [PORT]
```

### Adding New Service

1. Create service directory: `python/[service-name]/`
2. Create standard files:
   - `main.py` - FastAPI app
   - `Dockerfile` - Container definition
   - `requirements.txt` - Dependencies
   - `.env.example` - Environment template
   - `CLAUDE.md` - Service documentation
3. Add service to `docker-compose.yml`
4. Update gateway routing if needed
5. Document in this file

### Testing

**Unit Tests:**
```bash
cd python/[service-name]
pytest tests/ -v
```

**Integration Tests:**
```bash
pytest tests/ -v --integration
```

**Manual API Testing:**
```bash
# Health check
curl http://localhost:8000/health

# Test AI service through gateway
curl -X POST http://localhost:8000/api/v1/ai/missions/generate \
  -H "Content-Type: application/json" \
  -d @test_request.json
```

## Configuration

### Environment Variables

Each service has its own `.env` file (copy from `.env.example`):

**Gateway:**
- `AI_SERVICE_URL` - AI service URL
- `WHISPER_SERVICE_URL` - Whisper service URL
- `PORT` - Service port

**AI Service:**
- `AI_PROVIDER_STORY` - Provider for story content
- `AI_PROVIDER_QUICK` - Provider for quick content
- `ANTHROPIC_API_KEY` - Claude API key
- `OPENAI_API_KEY` - OpenAI API key
- `OLLAMA_BASE_URL` - Ollama URL (local)
- `REDIS_HOST` - Redis host
- `CACHE_ENABLED` - Enable caching

**Whisper Service:**
- `WHISPER_MODEL` - Model size (tiny/base/small/medium/large)
- `DEVICE` - cpu or cuda
- `MAX_FILE_SIZE_MB` - Max audio file size

## Common Tasks

### Check Service Health
```bash
# All services
curl http://localhost:8000/health/all

# Individual services
curl http://localhost:8000/health  # Gateway
curl http://localhost:8001/health  # AI Service
curl http://localhost:8002/health  # Whisper Service
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f gateway
docker-compose logs -f ai-service
```

### Restart Service
```bash
docker-compose restart gateway
docker-compose restart ai-service
```

### Clear Redis Cache
```bash
docker-compose exec redis redis-cli
> FLUSHALL
> exit
```

## Troubleshooting

### Services Won't Start

**Check Docker:**
```bash
docker-compose ps
docker-compose logs [service-name]
```

**Check ports available:**
```bash
lsof -i :8000  # Gateway
lsof -i :8001  # AI Service
lsof -i :8002  # Whisper
lsof -i :6379  # Redis
```

### AI Service Errors

**Check API keys:**
```bash
docker-compose exec ai-service env | grep API_KEY
```

**Check Ollama running (if using):**
```bash
curl http://localhost:11434/api/tags
```

### Whisper Service Errors

**Check model loaded:**
```bash
docker-compose exec whisper-service python -c "import whisper; print(whisper.available_models())"
```

## Design Reference

See:
- [Technical Architecture](../docs/technical-architecture.md)
- [AI Integration](../docs/ai-integration.md)
- [AI Chat & Storytelling](../docs/ai-chat-storytelling-system.md)
- [Whisper Voice Transcription](../docs/whisper-voice-transcription.md)
- [CI/CD & Deployment](../docs/ci-cd-deployment.md)

## Next Steps

**Current Phase:** Phase 1, Week 1 ✅ Complete

**Week 2 (AI Service Core):**
- Implement AI provider clients
- Create prompt templates
- Implement content generation endpoints
- Add Redis caching
- Write integration tests

See [Development Organization](../docs/development-organization.md) for full roadmap.

---

## 🤖 For AI Agents

**Context:** You (AI agent) will perform ~99% of implementation work on these backend services.

### Quick Start
1. **Read:** [/AI-AGENT-GUIDE.md](../AI-AGENT-GUIDE.md) - Complete workflow guide
2. **Check:** [/STATUS.md](../STATUS.md) - Current task and context
3. **Reference:** [/ROADMAP.md](../ROADMAP.md) - Implementation checklist

### Decision Authority for Python Services

**✅ Decide Autonomously:**
- API endpoint implementation details
- Pydantic model structure
- Error handling strategies
- Code organization within services
- Testing strategies
- Performance optimizations
- Logging and debugging code
- Docker configuration tweaks

**⚠️ Propose First:**
- New API endpoints
- Changes to service boundaries
- New dependencies/packages
- Changes to Docker Compose structure
- Database schema changes (Redis, SQLite)

**🛑 Always Ask:**
- AI provider selection/changes
- Breaking API changes
- Changes affecting Godot integration
- Cost implications (API calls, resources)
- Architectural changes (new services, removing services)

### Common Tasks

**Adding New API Endpoint:**
1. Create route in `src/api/[module].py`
2. Define Pydantic request/response models in `src/models/`
3. Implement business logic
4. Add error handling
5. Write tests in `tests/test_[module].py`
6. Update service's CLAUDE.md with endpoint documentation

**Implementing AI Feature:**
1. Read [AI Integration docs](../docs/05-ai-content/ai-integration.md)
2. Choose appropriate provider (or use existing)
3. Create prompt template in `src/ai/prompts.py`
4. Implement generation logic with caching
5. Add Pydantic validation
6. Test with multiple providers
7. Document lessons in [/docs/03-learnings/ai-integration-lessons.md](../docs/03-learnings/ai-integration-lessons.md)

**Testing Services:**
1. Write unit tests (mock dependencies)
2. Write integration tests (test with real services)
3. Manual testing with curl/Postman
4. Update [TESTING-GUIDE.md](../docs/01-user-guides/testing/TESTING-GUIDE.md) if new patterns

### Code Style
- Follow PEP 8 (use black for formatting)
- Type hints on all functions
- Pydantic models for all API contracts
- Async/await for I/O operations
- Docstrings for complex functions
- See [Architecture Lessons](../docs/03-learnings/architecture-lessons.md)

### When You Complete Work
1. Update [/STATUS.md](../STATUS.md) with progress
2. Check off items in [/ROADMAP.md](../ROADMAP.md)
3. Document discoveries in [/docs/03-learnings/](../docs/03-learnings/)
4. Commit with detailed message (see [AI-AGENT-GUIDE.md](../AI-AGENT-GUIDE.md#commit-strategy))

### Related Context Files
- Service-specific: `gateway/CLAUDE.md`, `ai-service/CLAUDE.md`, etc.
- Architecture: [/docs/02-developer-guides/architecture/CLAUDE.md](../docs/02-developer-guides/architecture/CLAUDE.md)
- Integration: [/docs/02-developer-guides/architecture/INTEGRATION-GUIDE.md](../docs/02-developer-guides/architecture/INTEGRATION-GUIDE.md)

---

## Change Log

### 2025-11-05
- Created microservices architecture
- Implemented Gateway Service skeleton
- Implemented AI Service skeleton
- Implemented Whisper Service skeleton
- Set up Docker Compose configuration
- Created shared utilities package
