# 00-getting-started - AI Agent Context

**Purpose:** Setup and installation guides for getting the development environment running.

## Directory Contents

### Key Files
1. **DEVELOPER-SETUP.md** (755 lines) - Complete setup guide
   - Prerequisites and installation
   - Quick start (< 5 minutes)
   - Development workflow
   - Common tasks
   - Troubleshooting

## When to Use This Directory

**Use this documentation when:**
- Setting up the project for the first time
- Onboarding new developers
- Troubleshooting installation issues
- Verifying prerequisites
- Configuring development environment

## Common Tasks

### Task: Set up development environment
1. Read DEVELOPER-SETUP.md sections 1-3
2. Install prerequisites (Godot, Docker, Python)
3. Clone repository
4. Start Docker services: `docker compose up -d`
5. Open Godot project

### Task: Troubleshoot installation
1. Check DEVELOPER-SETUP.md troubleshooting section
2. Verify Docker: `docker ps`
3. Check service logs: `docker compose logs`
4. Verify ports: `../06-technical-reference/PORT-MAPPING.md`

### Task: Configure environment
1. Copy `.env.example` to `.env`
2. Set AI_PROVIDER (ollama or openai)
3. Configure API keys if using OpenAI
4. Verify Ollama running if using local AI

## Relationships

**Prerequisites for:**
- All development tasks
- Testing procedures
- Running the game

**Related Documentation:**
- **Testing:** `../01-user-guides/testing/TESTING-GUIDE.md`
- **Architecture:** `../02-developer-guides/architecture/technical-architecture.md`
- **Ports:** `../06-technical-reference/PORT-MAPPING.md`

## Key Concepts

### NCC-1701 Port System
All services use Star Trek-themed ports (17010-17099):
- Gateway: 17010
- AI Service: 17011
- Whisper: 17012
- Redis: 17014

### Docker Compose Stack
```
gateway (17010) → Entry point
ai-service (17011) → Content generation
redis (17014) → Caching
whisper (17012) → Voice transcription (optional)
```

### Godot Project Structure
```
godot/
├── project.godot
├── scenes/ - Game screens
├── scripts/
│   └── autoload/ - Global singletons
└── saves/ - Player save files
```

## AI Agent Instructions

**When a developer asks about setup:**
1. Direct them to DEVELOPER-SETUP.md
2. Verify they have prerequisites
3. Walk through quick start
4. Test with main menu scene

**When troubleshooting:**
1. Check Docker is running
2. Verify services are healthy: `docker compose ps`
3. Check logs for specific service
4. Verify ports are not in use

**When working on setup improvements:**
1. Update DEVELOPER-SETUP.md
2. Test installation steps from scratch
3. Update troubleshooting section
4. Verify all commands work

## Dependencies

**External:**
- Godot Engine 4.2+
- Docker Desktop / Docker Engine
- Python 3.10+
- Git

**Optional:**
- Ollama (for local AI)
- OpenAI API key (for cloud AI)

**Internal:**
- Backend services must be running
- Ports 17010-17099 available
- Redis container accessible

## Quick Reference

**Start everything:**
```bash
docker compose up -d
godot godot/project.godot  # Press F5
```

**Stop everything:**
```bash
docker compose down
```

**Check service health:**
```bash
curl http://localhost:17010/health
curl http://localhost:17011/health
```

**View logs:**
```bash
docker compose logs -f gateway
docker compose logs -f ai-service
```

---

**Parent Context:** [../CLAUDE.md](../CLAUDE.md)
**Directory Index:** [README.md](./README.md)
