# Space Adventures - Developer Setup Guide

**Version:** Phase 1, Week 4
**Date:** 2025-11-06
**Status:** Foundation Complete

## Quick Start

Get the game running in under 5 minutes:

```bash
# 1. Clone repository
git clone <repository-url>
cd space-adventures

# 2. Start backend services
docker compose up -d

# 3. Verify services
curl http://localhost:17010/health/all

# 4. Open Godot
godot godot/project.godot
# Press F5 to run

# Done! Test scene should open automatically.
```

## Prerequisites

### Required Software

| Software | Version | Purpose | Download |
|----------|---------|---------|----------|
| **Godot Engine** | 4.2+ | Game client | https://godotengine.org/download |
| **Docker Desktop** | Latest | Backend services | https://www.docker.com/products/docker-desktop |
| **Git** | 2.x+ | Version control | https://git-scm.com/downloads |
| **Python** | 3.10+ | Local testing (optional) | https://www.python.org/downloads/ |

### Optional (for AI Features)

| Software | Purpose | Download |
|----------|---------|----------|
| **Ollama** | Local AI (free) | https://ollama.ai |
| **Claude API Key** | Cloud AI (paid) | https://console.anthropic.com/ |
| **OpenAI API Key** | Cloud AI (paid) | https://platform.openai.com/ |

### System Requirements

**Minimum:**
- CPU: 2 cores
- RAM: 4 GB
- Disk: 2 GB free
- OS: macOS 10.15+, Windows 10+, Linux (Ubuntu 20.04+)

**Recommended:**
- CPU: 4+ cores
- RAM: 8+ GB
- Disk: 5 GB free
- GPU: Optional (for faster AI with Ollama)

## Installation Steps

### 1. Install Godot Engine

**macOS:**
```bash
brew install godot
```

**Linux:**
```bash
# Download from godotengine.org
# or use Snap
snap install godot
```

**Windows:**
- Download from https://godotengine.org/download
- Extract and add to PATH

**Verify:**
```bash
godot --version
# Should show: 4.x.x
```

### 2. Install Docker Desktop

**macOS:**
```bash
brew install --cask docker
```

**Linux:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

**Windows:**
- Download from https://www.docker.com/products/docker-desktop
- Run installer

**Verify:**
```bash
docker --version
docker compose version
```

### 3. Clone Repository

```bash
git clone <repository-url>
cd space-adventures
```

### 4. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env for AI providers (optional)
nano .env

# Or use defaults (Ollama)
```

**Minimal .env:**
```bash
# Use defaults - Ollama for local AI
AI_PROVIDER_STORY=ollama
AI_PROVIDER_RANDOM=ollama
AI_PROVIDER_QUICK=ollama

OLLAMA_BASE_URL=http://host.docker.internal:11434
OLLAMA_MODEL=llama3.2:3b
```

**With Claude API:**
```bash
AI_PROVIDER_STORY=claude
AI_PROVIDER_RANDOM=ollama
ANTHROPIC_API_KEY=sk-ant-your-key-here
CLAUDE_MODEL=claude-3-5-sonnet-20241022
```

### 5. Start Backend Services

```bash
# Start all services
docker compose up -d

# Check status
docker compose ps

# Should show:
# space-adventures-gateway   Up (healthy)
# space-adventures-ai        Up (healthy)
# space-adventures-redis     Up (healthy)
```

**First time takes 2-3 minutes** to download images and build.

### 6. Verify Services

```bash
# Test Gateway
curl http://localhost:17010/health

# Expected:
# {"status":"healthy","service":"gateway",...}

# Test all services
curl http://localhost:17010/health/all

# Expected:
# {"status":"degraded","services":{...}}
# (degraded is OK - Whisper is optional)
```

### 7. Install Ollama (Optional but Recommended)

**For local, free AI generation:**

**macOS:**
```bash
brew install ollama

# Pull model
ollama pull llama3.2:3b

# Start server
ollama serve
```

**Linux:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2:3b
ollama serve
```

**Windows:**
- Download from https://ollama.ai
- Run installer
- Open Ollama app
- Run in terminal:
```cmd
ollama pull llama3.2:3b
```

**Verify:**
```bash
curl http://localhost:11434/api/tags
# Should list llama3.2:3b
```

### 8. Open Godot Project

```bash
# From command line
godot godot/project.godot

# Or: Open Godot → Import Project → Select godot/project.godot
```

### 9. Run Test Scene

**In Godot Editor:**
1. Press **F5** (or click Run Project button)
2. Test scene opens automatically
3. Try the test buttons:
   - Test Service Connection
   - Test AI Chat (requires Ollama/Claude/OpenAI)
   - Test Mission Generation
   - Test Dialogue Generation
   - Test Save/Load

**Success Indicators:**
- ✅ All 5 singletons load without errors
- ✅ Gateway and AI show "OK" status
- ✅ Test buttons work without crashes
- ✅ Output log shows no red errors

## Development Workflow

### Daily Workflow

```bash
# 1. Start Docker services
docker compose up -d

# 2. Start Ollama (if using)
ollama serve

# 3. Open Godot
godot godot/project.godot

# 4. Make changes
# Edit scripts, scenes, etc.

# 5. Test frequently (F5 in Godot)

# 6. Commit changes
git add .
git commit -m "feat: your change description"

# 7. Stop services when done
docker compose down
```

### Project Structure

```
space-adventures/
├── docs/               # Documentation
│   ├── CLAUDE.md       # Main project guide
│   ├── TESTING-GUIDE.md
│   ├── INTEGRATION-GUIDE.md
│   └── DEVELOPER-SETUP.md (this file)
│
├── python/             # Backend microservices
│   ├── gateway/        # API Gateway (17010)
│   ├── ai-service/     # AI content generation (17011)
│   └── whisper-service/# Voice transcription (17012)
│
├── godot/              # Godot game client
│   ├── project.godot   # Project config
│   ├── scenes/         # Game scenes (.tscn)
│   ├── scripts/        # GDScript code
│   │   ├── autoload/   # Singletons
│   │   ├── ui/         # UI controllers
│   │   └── systems/    # Ship system classes
│   └── assets/         # Game assets
│
├── docker-compose.yml  # Service orchestration
├── .env.example        # Environment template
└── .gitignore
```

### Making Changes

**Backend (Python):**
```bash
# Navigate to service
cd python/ai-service

# Create virtual environment (first time)
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate (Windows)

# Install dependencies
pip install -r requirements.txt

# Make changes to Python files

# Test locally
python main.py

# Or run in Docker
docker compose up -d --build ai-service
```

**Frontend (Godot):**
```bash
# Open Godot project
godot godot/project.godot

# Make changes to:
# - Scripts: godot/scripts/
# - Scenes: godot/scenes/
# - Assets: godot/assets/

# Test: Press F5

# Debug: Check Output tab (bottom panel) for errors
```

### Running Tests

**Backend Tests:**
```bash
cd python/ai-service
source venv/bin/activate
pytest tests/

# Specific test
pytest tests/test_missions.py::test_generate_mission

# With coverage
pytest --cov=src tests/
```

**Godot Tests:**
- Manual testing via test scene (F5)
- Check Output tab for errors
- Verify all test buttons work

### Debugging

**Godot Debugging:**
```gdscript
# Add print statements
print("Debug:", variable_name)
print("Dict:", JSON.stringify(my_dict))

# Check Output tab in Godot (bottom panel)
# Red = errors, Yellow = warnings
```

**Backend Debugging:**
```bash
# View logs
docker compose logs gateway
docker compose logs ai-service

# Follow logs
docker compose logs -f ai-service

# Check specific container
docker compose exec ai-service /bin/bash
```

**Network Debugging:**
```bash
# Test endpoints
curl http://localhost:17010/health
curl http://localhost:17011/health

# Check ports
netstat -an | grep 17010
lsof -i :17010

# Check Docker network
docker network ls
docker network inspect space-adventures-net
```

## Common Development Tasks

### Task 1: Add New Ship System

```gdscript
# 1. Create script
# godot/scripts/systems/warp_system.gd

extends ShipSystem
class_name WarpSystem

func get_power_cost() -> int:
    return [0, 20, 30, 50, 80, 120][level]

# 2. Register in GameState
# godot/scripts/autoload/game_state.gd
ship.systems["warp"] = _create_system("warp", 0)

# 3. Add event to EventBus
# godot/scripts/autoload/event_bus.gd
signal warp_drive_engaged()

# 4. Test in test scene
```

### Task 2: Add New Mission Type

```python
# 1. Add to mission types enum
# python/ai-service/src/models/mission.py

class MissionType(str, Enum):
    SALVAGE = "salvage"
    COMBAT = "combat"
    NEW_TYPE = "new_type"  # Add here

# 2. Create prompt template
# python/ai-service/src/ai/prompts.py

NEW_TYPE_MISSION_PROMPT = """..."""

# 3. Update mission generator
# python/ai-service/src/api/missions.py

if mission_type == "new_type":
    prompt = format_new_type_prompt(...)

# 4. Rebuild service
docker compose up -d --build ai-service

# 5. Test in Godot
AIService.generate_mission("medium", "new_type")
```

### Task 3: Add New AI Personality

```python
# 1. Add personality to models
# python/ai-service/src/models/chat.py

class AIPersonality(str, Enum):
    ATLAS = "atlas"
    NEW_AI = "new_ai"  # Add here

# 2. Create system prompt
# python/ai-service/src/ai/prompts.py

AI_PERSONALITY_SYSTEMS["new_ai"] = """
You are a new AI personality...
"""

# 3. Add name mapping
# python/ai-service/src/api/chat.py

AI_PERSONALITY_NAMES["new_ai"] = "NEW AI NAME"

# 4. Rebuild and test
docker compose up -d --build ai-service

# 5. Use in Godot
AIService.chat_message("Hello", "new_ai")
```

### Task 4: Add New Scene

```bash
# 1. Create scene in Godot
# File → New Scene → Control
# Save as: godot/scenes/new_scene.tscn

# 2. Create script
# godot/scripts/ui/new_scene.gd

extends Control

func _ready():
    print("New scene loaded")

# 3. Attach script to root node

# 4. Add to scene transitions
# In another scene:
get_tree().change_scene_to_file("res://scenes/new_scene.tscn")

# 5. Test (F5)
```

## Troubleshooting

### Issue: Docker Services Won't Start

**Symptoms:** `docker compose up -d` fails

**Solutions:**
```bash
# Check Docker is running
docker ps

# Restart Docker Desktop
# macOS: Quit Docker Desktop, restart
# Linux: sudo systemctl restart docker

# Remove old containers
docker compose down
docker compose rm -f

# Rebuild
docker compose up -d --build

# Check logs
docker compose logs
```

### Issue: Port Already in Use

**Symptoms:** "Address already in use: 17010"

**Solutions:**
```bash
# Find what's using the port
lsof -i :17010          # macOS/Linux
netstat -an | grep 17010 # Windows

# Kill the process
kill -9 <PID>

# Or change port in .env
echo "GATEWAY_PORT=27010" >> .env
docker compose down && docker compose up -d
```

### Issue: Godot Scripts Have Errors

**Symptoms:** Red errors in Output tab

**Solutions:**
```bash
# Check syntax
# Look for:
# - Missing semicolons
# - Type mismatches
# - Undefined variables

# Verify nodes exist
# @onready var my_node = $Path/To/Node
# Make sure path matches scene tree

# Check autoload singletons
# Project → Project Settings → Autoload
# Verify all 5 singletons listed
```

### Issue: AI Requests Fail

**Symptoms:** "AI service unavailable"

**Solutions:**
```bash
# Check AI service
docker compose logs ai-service

# If using Ollama
ollama list  # Verify model downloaded
ollama serve # Ensure server running

# If using Claude/OpenAI
# Check .env has valid API key
cat .env | grep API_KEY

# Test directly
curl -X POST http://localhost:17011/api/chat/message \
  -H "Content-Type: application/json" \
  -d '{"session_id":"test","message":"hello","ai_personality":"atlas"}'
```

### Issue: Save Files Not Working

**Symptoms:** "Save failed" or "Load failed"

**Solutions:**
```bash
# Check save directory exists
# macOS
ls ~/Library/Application\ Support/Godot/app_userdata/Space\ Adventures/saves/

# Linux
ls ~/.local/share/godot/app_userdata/Space\ Adventures/saves/

# Windows
dir %APPDATA%\Godot\app_userdata\Space Adventures\saves\

# Create if missing
mkdir -p <path above>/saves

# Check permissions
chmod 755 <saves directory>

# Verify in Godot
# In test scene, click "Test Save/Load"
# Check Output log for details
```

## Useful Commands

### Docker

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# Restart single service
docker compose restart ai-service

# Rebuild service
docker compose up -d --build ai-service

# View logs
docker compose logs -f ai-service

# Enter container
docker compose exec ai-service /bin/bash

# Check resource usage
docker stats
```

### Git

```bash
# Check status
git status

# Create branch
git checkout -b feature/my-feature

# Commit changes
git add .
git commit -m "feat: my change"

# Push
git push origin feature/my-feature

# Update from main
git fetch origin
git merge origin/main
```

### Godot

```bash
# Run project
godot godot/project.godot

# Run specific scene
godot godot/project.godot res://scenes/main_menu.tscn

# Export project
godot --export "Linux/X11" game.x86_64

# Headless mode (testing)
godot godot/project.godot --headless
```

## IDE Setup

### VS Code (Recommended for Python)

**Extensions:**
- Python
- Pylance
- Docker
- GitLens

**Settings:**
```json
{
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true,
  "python.formatting.provider": "black",
  "editor.formatOnSave": true
}
```

### Godot (Built-in Editor)

**Settings:**
- Editor → Editor Settings → Text Editor → Theme: Adaptive
- Editor → Editor Settings → Text Editor → Font Size: 16
- Editor → Editor Settings → Text Editor → Show Line Numbers: On

### VS Code with Godot Support

**Extension:** godot-tools

**Features:**
- GDScript syntax highlighting
- Code completion
- Debugging support

## Resources

### Documentation

- [Main Guide](../CLAUDE.md)
- [Testing Guide](TESTING-GUIDE.md)
- [Integration Guide](INTEGRATION-GUIDE.md)
- [Godot Guide](../godot/CLAUDE.md)

### External Links

- [Godot Docs](https://docs.godotengine.org/)
- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Ollama Models](https://ollama.ai/library)

### Support

- **Project Issues:** GitHub Issues
- **Godot Questions:** https://godotengine.org/community
- **Docker Questions:** https://forums.docker.com/

## Next Steps

After setup is complete:

1. ✅ Run test scene and verify all tests pass
2. ✅ Read [INTEGRATION-GUIDE.md](INTEGRATION-GUIDE.md)
3. ✅ Review [godot/CLAUDE.md](../godot/CLAUDE.md) for Godot specifics
4. ✅ Check [docs/development-organization.md](development-organization.md) for roadmap
5. ✅ Start development!

**Happy Coding! 🚀**
