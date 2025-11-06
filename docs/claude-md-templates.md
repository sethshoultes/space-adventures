# CLAUDE.md Template System

**Purpose:** Templates and examples for embedded directory documentation
**Last Updated:** November 5, 2025

---

## Overview

Every significant directory in the project should have a `CLAUDE.md` file that provides context and guidance for both AI assistants (like Claude Code) and human developers.

### Why CLAUDE.md?

1. **AI Context** - Claude Code reads these to understand directory purpose before making changes
2. **Developer Onboarding** - New developers (or returning developers) quickly understand each area
3. **Living Documentation** - Updated as code evolves, always accurate
4. **Embedded Knowledge** - Design decisions recorded where they're relevant
5. **Pattern Enforcement** - Establishes conventions and patterns

### Placement Rules

**Create CLAUDE.md when:**
- Directory contains 3+ files
- Directory represents a logical subsystem
- Directory has specific patterns/conventions
- Directory requires special knowledge

**Don't create CLAUDE.md for:**
- Empty directories
- Single-file directories
- Pure data directories (like `assets/fonts/`)

---

## Master Template

```markdown
# [Directory Name]

**Purpose:** [One-sentence description of this directory's purpose]
**Parent:** [Link to parent CLAUDE.md - ../CLAUDE.md]
**Design Docs:** [Links to relevant docs/ files]

## Overview

[2-3 paragraphs explaining:]
- What this directory contains
- Why it exists
- How it fits into the larger system
- Key responsibilities

## Structure

```
directory/
├── file1.ext       # Short description
├── file2.ext       # Short description
├── subdirectory/   # Short description
│   └── CLAUDE.md   # Links to subdirectory guide
└── README.md       # User-facing docs (if applicable)
```

## Key Files

### file1.ext
**Purpose:** What this file does
**Type:** [Class/Module/Script/Config/Data]
**Used By:** What depends on this file
**Dependencies:** What this file depends on

**Important Functions/Classes:**
- `function_name(param: type) -> type` - What it does, when to use it
- `ClassName` - Purpose, key methods, usage pattern

**Example Usage:**
```[language]
# Concrete example of using this file
```

### file2.ext
[Same structure as file1.ext]

## Development Guidelines

### Adding New Files

**When to add:**
- [Specific trigger/need]

**Naming Conventions:**
- [Pattern to follow]
- Example: `system_name_system.gd` for ship systems

**Required Documentation:**
- [ ] File-level docstring/comment
- [ ] Function/class documentation
- [ ] Update this CLAUDE.md

### Code Patterns

**Pattern 1: [Pattern Name]**
```[language]
# Standard pattern code example
```

**When to Use:** [Explanation]

**Pattern 2: [Pattern Name]**
```[language]
# Another pattern example
```

**When to Use:** [Explanation]

### Testing

**Test Files:** [Location of tests]
**Required Coverage:** [Percentage or description]

**How to Test:**
```bash
# Commands to run tests
```

**What to Test:**
- [ ] Happy path scenarios
- [ ] Error cases
- [ ] Edge cases
- [ ] Integration points

## Dependencies

### Internal Dependencies
- `[path/to/file.ext]` - Why we depend on this
- `[path/to/other.ext]` - Why we depend on this

### External Dependencies
- `[package-name]` - What it provides, version requirements
- `[library-name]` - Purpose, documentation link

## Design Reference

Detailed design in:
- [docs/specific-design-doc.md](../../docs/specific-design-doc.md#relevant-section)
- [docs/another-doc.md](../../docs/another-doc.md)

**Key Design Decisions:**
1. **Decision 1:** Why we chose this approach
2. **Decision 2:** Trade-offs considered

## Common Tasks

### Task 1: [Common Task Name]

**When:** [When you need to do this]

**Steps:**
```bash
# Commands or code to perform task
```

**Expected Result:** [What should happen]

### Task 2: [Another Common Task]

**When:** [When you need to do this]

**Steps:**
```[language]
// Code example
```

**Expected Result:** [What should happen]

## Troubleshooting

### Issue: [Common Problem 1]
**Symptoms:** How you know this is the problem
**Cause:** Why this happens
**Solution:**
```bash
# Commands to fix
```

### Issue: [Common Problem 2]
**Symptoms:** [Description]
**Cause:** [Explanation]
**Solution:** [Steps to resolve]

## Next Steps

[What to implement next in this area]

**Current Status:** [Brief status]

**Planned:**
- [ ] Feature 1 (see Phase X, Week Y)
- [ ] Feature 2 (backlog)

## Change Log

### 2025-11-05
- Created directory and initial structure
- Implemented [feature/system]

### 2025-11-10
- Added [new file]
- Refactored [component]
```

---

## Example: Root CLAUDE.md

```markdown
# Space Adventures

**Purpose:** Root project documentation for AI-assisted development
**Parent:** N/A (Root)
**Design Docs:** [docs/README.md](docs/README.md)

## Overview

Space Adventures is a narrative-driven space adventure game where players build a starship from salvaged parts and explore the cosmos. The game uses a microservices architecture with Godot as the game client and multiple Python services providing AI-powered content generation, voice transcription, and other features.

This is a hobby project designed for solo development with AI assistance (Claude Code). All development follows SOLID principles and uses documentation-driven development.

## Project Structure

```
space-adventures/
├── CLAUDE.md                    # This file
├── README.md                    # User-facing project overview
├── LICENSE                      # MIT License
├── .gitignore                   # Git ignore rules
├── docker-compose.yml           # Main compose file
├── docker-compose.dev.yml       # Development environment
├── docker-compose.prod.yml      # Production environment
├── docs/                        # Design documentation (read-only reference)
│   ├── CLAUDE.md               # Documentation organization
│   ├── development-organization.md
│   └── [14 design documents]
├── godot/                       # Game client (Godot 4.2+)
│   └── CLAUDE.md               # Godot project guide
├── python/                      # Backend services
│   ├── gateway/                # API Gateway (port 8000)
│   ├── ai-service/             # AI Service (port 8001)
│   ├── whisper-service/        # Voice transcription (port 8002)
│   └── shared/                 # Shared utilities
└── tools/                       # Development utilities
    └── CLAUDE.md               # Tools documentation
```

## Quick Start

### For Developers

**First Time Setup:**
```bash
# 1. Clone and setup
git clone [repo-url]
cd space-adventures

# 2. Start services
docker-compose up -d

# 3. Open Godot
godot godot/project.godot
```

**Daily Development:**
1. Review current phase in `docs/development-organization.md`
2. Read relevant CLAUDE.md files
3. Implement features following patterns
4. Update CLAUDE.md if structure changes
5. Commit with descriptive messages

### For Claude Code

**When Starting Work:**
1. Read this CLAUDE.md
2. Read `docs/development-organization.md` for current phase
3. Read relevant directory CLAUDE.md files
4. Review design docs as needed
5. Propose implementation approach
6. Wait for approval, then proceed

## Development Philosophy

**Core Principles:**
- **Documentation-Driven:** Write design docs first, code follows
- **Incremental:** Build one feature at a time, test thoroughly
- **SOLID:** Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **DRY:** Don't Repeat Yourself - single source of truth
- **KISS:** Keep It Simple, Stupid - simplest solution that works
- **YAGNI:** You Aren't Gonna Need It - build only what's needed now

**Architecture:**
- **Microservices:** Independent, testable, deployable services
- **Service Independence:** Graceful degradation if services fail
- **Local-First:** All services run on localhost
- **Optional Features:** Players install only what they want

## Key Technologies

**Game Client:**
- Godot Engine 4.2+ (GDScript)
- 2D graphics, scene management
- SQLite (per-save game state)

**Backend Services:**
- Python 3.10+ with FastAPI
- LangChain (multi-provider AI)
- PostgreSQL (global settings)
- Redis (caching)
- OpenAI Whisper (voice transcription)

**Infrastructure:**
- Docker & Docker Compose
- GitHub Actions (CI/CD)
- Git (version control)

## Current Phase

**Phase:** [Current phase number and name]
**Week:** [Current week]
**Status:** [Brief status]

**Active Tasks:**
- [ ] Task 1 (see development-organization.md)
- [ ] Task 2
- [ ] Task 3

## Common Commands

### Start Development Environment
```bash
docker-compose -f docker-compose.dev.yml up -d
```

### Run Tests
```bash
# Python services
cd python/[service-name]
pytest tests/

# All services
./tools/run-all-tests.sh
```

### Check Service Health
```bash
curl http://localhost:8000/health  # Gateway
curl http://localhost:8001/health  # AI Service
curl http://localhost:8002/health  # Whisper Service
```

### Stop All Services
```bash
docker-compose down
```

## Design Documentation

All design docs are in `docs/`:

**Core Design:**
- [Game Design Document](docs/game-design-document.md)
- [Technical Architecture](docs/technical-architecture.md)
- [Development Organization](docs/development-organization.md)
- [MVP Roadmap](docs/mvp-roadmap.md)

**Game Systems:**
- [Ship Systems](docs/ship-systems.md)
- [Ship Classification](docs/ship-classification-system.md)
- [Player Progression](docs/player-progression-system.md)
- [Mission Framework](docs/mission-framework.md)

**AI & Content:**
- [AI Chat & Storytelling](docs/ai-chat-storytelling-system.md)
- [Whisper Voice Transcription](docs/whisper-voice-transcription.md)
- [AI Integration](docs/ai-integration.md)
- [Settings System](docs/settings-system.md)

**See [docs/README.md](docs/README.md) for complete list.**

## Contributing

This is a solo project with AI assistance, but contributions are welcome!

**Process:**
1. Read design documentation
2. Create feature branch
3. Follow existing patterns (check CLAUDE.md files)
4. Write tests
5. Update CLAUDE.md if needed
6. Submit PR with description

## Troubleshooting

### Services Won't Start
**Check:**
```bash
docker-compose ps              # Check status
docker-compose logs [service]  # Check logs
```

### Godot Can't Connect to Services
**Verify services are running:**
```bash
curl http://localhost:8000/health
```

### Tests Failing
**Run individually to isolate:**
```bash
pytest tests/test_specific.py -v
```

## Next Steps

See [docs/development-organization.md](docs/development-organization.md) for:
- Current phase plan
- Week-by-week breakdown
- Daily task lists
- Implementation guidelines

## Change Log

### 2025-11-05
- Created project structure
- Completed all design documentation (14 documents)
- Set up CLAUDE.md system
- Ready for Phase 1 implementation
```

---

## Example: godot/CLAUDE.md

```markdown
# Godot Game Client

**Purpose:** Game client built with Godot Engine 4.2+
**Parent:** [../CLAUDE.md](../CLAUDE.md)
**Design Docs:** [Technical Architecture](../docs/technical-architecture.md#godot-integration)

## Overview

The Godot game client handles all player-facing functionality: UI, game logic, input handling, and rendering. It communicates with backend services via HTTP REST APIs for AI-generated content.

The client uses a singleton (autoload) pattern for global systems and follows scene-based organization for UI components.

## Structure

```
godot/
├── CLAUDE.md           # This file
├── project.godot       # Godot project configuration
├── export_presets.cfg  # Export settings for builds
├── scenes/             # All game scenes (.tscn files)
│   └── CLAUDE.md
├── scripts/            # All GDScript code
│   ├── CLAUDE.md
│   ├── autoload/       # Singleton scripts (always loaded)
│   ├── systems/        # Ship system classes
│   ├── ui/             # UI component scripts
│   └── utils/          # Utility functions
├── assets/             # Game assets
│   ├── data/           # JSON data files
│   ├── sprites/        # Images
│   ├── fonts/          # Typography
│   └── sounds/         # Audio (future)
└── saves/              # Player save files (gitignored)
```

## Key Singletons (Autoload)

### GameState (scripts/autoload/game_state.gd)
**Purpose:** Global game state - player, ship, inventory, progress
**Type:** Singleton (always loaded)
**Access:** `GameState.player`, `GameState.ship`, etc.

**Key Properties:**
```gdscript
var player: Dictionary  # Player stats, level, XP, skills
var ship: Dictionary    # Ship systems, power, hull HP
var inventory: Array    # All items (player + ship storage)
var progress: Dictionary # Completed missions, locations, choices
```

**Key Methods:**
- `reset_game()` - Start new game
- `to_dict() -> Dictionary` - Serialize for saving
- `from_dict(data: Dictionary)` - Load from save

### SaveManager (scripts/autoload/save_manager.gd)
**Purpose:** Save and load game state
**Format:** JSON files in `saves/save_slot_N.json`

**Key Methods:**
- `save_game(slot: int)` - Save current game
- `load_game(slot: int) -> bool` - Load game from slot
- `delete_save(slot: int)` - Delete save file
- `get_save_info(slot: int) -> Dictionary` - Get save metadata

### ServiceManager (scripts/autoload/service_manager.gd)
**Purpose:** Manage backend service connections
**Responsibilities:**
- Check service health on startup
- Track which services are available
- Provide service status to UI

**Key Methods:**
- `check_all_services() -> Dictionary` - Health check all services
- `is_service_available(service: String) -> bool` - Check if service is up
- `get_service_url(service: String) -> String` - Get service base URL

### AIService (scripts/autoload/ai_service.gd)
**Purpose:** HTTP client for AI service
**Endpoints Used:**
- `/api/missions/generate` - Generate mission
- `/api/chat/message` - Send chat message
- `/api/chat/spontaneous` - Get spontaneous event

**Key Methods:**
```gdscript
func generate_mission(difficulty: String, reward_type: String = "") -> Dictionary
func chat_message(message: String, ai_personality: String) -> Dictionary
func check_spontaneous_event() -> Dictionary
```

### EventBus (scripts/autoload/event_bus.gd)
**Purpose:** Decoupled event system for inter-component communication

**Signals:**
```gdscript
signal mission_completed(mission_id: String, rewards: Dictionary)
signal system_installed(system_name: String, level: int)
signal ship_class_changed(old_class: String, new_class: String)
signal xp_gained(amount: int)
signal level_up(new_level: int)
```

## Development Guidelines

### Adding New Scenes

**Location:** `scenes/`
**Naming:** `snake_case_scene.tscn`

**Requirements:**
- Attach script if needed
- Use scene's own folder for complex scenes
- Update `scenes/CLAUDE.md` with description

### Adding New Scripts

**Location:** Appropriate subdirectory in `scripts/`
**Naming:** `snake_case_script.gd`

**Pattern:**
```gdscript
extends [BaseClass]
class_name [ClassName]  # If reusable

## Documentation comment
## Explain purpose and usage

# Constants
const MAX_VALUE = 100

# Exported variables (editor-configurable)
@export var property_name: int = 10

# Public variables
var public_var: String = ""

# Private variables (prefix with _)
var _private_var: bool = false

func _ready():
    # Initialization
    pass

func public_function(param: int) -> int:
    """Function documentation"""
    return param * 2

func _private_function():
    # Helper function
    pass
```

### GDScript Style Guide

**Naming:**
- `snake_case` for variables and functions
- `PascalCase` for classes
- `SCREAMING_CASE` for constants

**Type Hints:** Always use
```gdscript
var health: int = 100
var name: String = "Player"

func calculate(amount: int) -> float:
    return amount * 1.5
```

**Indentation:** Tabs (Godot standard)

## Testing

**Manual Testing:**
1. Open scene in editor
2. Press F6 to run current scene
3. Press F5 to run full game

**Test Checklist:**
- [ ] All UI elements clickable
- [ ] All scenes transition correctly
- [ ] Save/load works
- [ ] Service communication works
- [ ] No console errors

## Service Integration

**Checking Service Availability:**
```gdscript
if ServiceManager.is_service_available("ai"):
    var result = await AIService.generate_mission("medium")
else:
    # Fallback: use static content
    var result = load_static_mission()
```

**Error Handling:**
```gdscript
var result = await AIService.chat_message(message, "atlas")
if result.has("error"):
    show_error_dialog(result.error)
else:
    display_ai_response(result.text)
```

## Common Tasks

### Create New Scene with Script

1. Right-click `scenes/` → New Scene
2. Build scene hierarchy
3. Save as `scenes/my_scene.tscn`
4. Attach script: `scripts/ui/my_scene.gd`
5. Update `scenes/CLAUDE.md`

### Add New Ship System

See [scripts/systems/CLAUDE.md](scripts/systems/CLAUDE.md)

### Add New UI Component

See [scripts/ui/CLAUDE.md](scripts/ui/CLAUDE.md)

## Troubleshooting

### Scene Won't Load
**Check:**
- File path correct?
- Scene file corrupted? (check Git)
- Dependencies loaded?

### Script Errors
**Check console for:**
- Syntax errors (red)
- Runtime errors (red)
- Warnings (yellow - fix these!)

### Service Connection Fails
**Verify:**
```bash
# Services running?
docker-compose ps

# Health check
curl http://localhost:8000/health
```

## Next Steps

**Current Phase:** [Phase number]

**Upcoming:**
- [ ] Implement X (see Phase Y, Week Z)
- [ ] Add Y feature

**Backlog:**
- Advanced graphics
- Sound effects
- Achievements

## Design Reference

See:
- [Technical Architecture](../docs/technical-architecture.md#godot-integration)
- [Game Design Document](../docs/game-design-document.md)
- [UI/UX Design](../docs/game-design-document.md#uiux-design)
```

---

## Example: python/ai-service/CLAUDE.md

```markdown
# AI Service

**Purpose:** AI-powered content generation service (missions, dialogue, chat)
**Parent:** [../CLAUDE.md](../CLAUDE.md)
**Design Docs:** [AI Integration](../../docs/ai-integration.md)

## Overview

The AI Service is a Python FastAPI application that generates game content using multiple AI providers (Claude, OpenAI, Ollama). It routes different tasks to the optimal provider based on complexity and cost.

**Port:** 8001
**Base URL:** http://localhost:8001

## Structure

```
ai-service/
├── CLAUDE.md                # This file
├── Dockerfile              # Container definition
├── requirements.txt        # Python dependencies
├── .env.example           # Environment template
├── main.py                # FastAPI entry point
├── src/
│   ├── api/               # API endpoints
│   │   ├── missions.py    # Mission generation
│   │   ├── chat.py        # Chat system
│   │   └── dialogue.py    # NPC dialogue
│   ├── ai/                # AI integration
│   │   ├── client.py      # Multi-provider client
│   │   ├── prompts.py     # Prompt templates
│   │   └── providers/     # Provider implementations
│   │       ├── claude.py
│   │       ├── openai.py
│   │       └── ollama.py
│   ├── models/            # Pydantic data models
│   │   ├── game_state.py
│   │   ├── mission.py
│   │   └── chat.py
│   ├── cache/             # Response caching
│   │   └── redis_cache.py
│   └── utils/             # Utilities
│       ├── config.py      # Settings management
│       └── validation.py  # Response validation
└── tests/                 # Unit and integration tests
    ├── test_missions.py
    ├── test_chat.py
    └── test_providers.py
```

## Key Files

### main.py
**Purpose:** FastAPI application entry point

**Key Components:**
```python
from fastapi import FastAPI
from src.api import missions, chat, dialogue

app = FastAPI(title="Space Adventures AI Service")

# Register routers
app.include_router(missions.router, prefix="/api/missions")
app.include_router(chat.router, prefix="/api/chat")
app.include_router(dialogue.router, prefix="/api/dialogue")

# Health check
@app.get("/health")
async def health():
    return {"status": "healthy", "service": "ai-service"}
```

### src/ai/client.py
**Purpose:** Multi-provider AI client with routing logic

**Provider Routing:**
- **Claude:** Story missions, critical narrative, ethical dilemmas
- **OpenAI GPT-3.5:** Random encounters, minor missions, NPC dialogue
- **Ollama:** Ship docs, UI text, item descriptions (free, local)

**Key Class:**
```python
class MultiProviderAIClient:
    def __init__(self, settings: Dict):
        self.clients = {}  # Provider clients
        self._initialize_clients()

    async def generate(self, task_type: AITaskType, prompt: str) -> str:
        provider = self._route_task(task_type)
        return await self._generate_with_provider(provider, prompt)
```

### src/ai/prompts.py
**Purpose:** Prompt templates for all content types

**Example Template:**
```python
MISSION_PROMPT_TEMPLATE = """
You are a creative sci-fi storytelling AI for "Space Adventures", a game inspired by Star Trek: TNG.

PLAYER CONTEXT:
- Level: {level}
- Skills: {skills}
- Ship Systems: {systems}
- Completed Missions: {completed_count}

MISSION REQUIREMENTS:
- Type: {mission_type}
- Difficulty: {difficulty}
- Required Reward: {reward_type}

Generate a mission following this JSON schema:
{schema}

Focus on:
- Serious sci-fi tone
- Meaningful choices
- Ethical dilemmas
- Consequences matter

OUTPUT ONLY VALID JSON.
"""
```

## API Endpoints

### POST /api/missions/generate

**Purpose:** Generate a new mission

**Request Body:**
```json
{
  "game_state": {
    "player": {"level": 3, "skills": {...}},
    "ship": {"systems": {...}},
    "progress": {"completed_missions": [...]}
  },
  "difficulty": "medium",
  "mission_type": "salvage",
  "required_reward_type": "warp_drive"
}
```

**Response:**
```json
{
  "mission_id": "mission_uuid",
  "title": "The Forgotten Shipyard",
  "type": "salvage",
  "location": "Old Europa Station",
  "description": "...",
  "stages": [...],
  "rewards": {...}
}
```

**Implementation:**
```python
@router.post("/generate", response_model=MissionResponse)
async def generate_mission(request: MissionRequest):
    # 1. Build context
    context = build_mission_context(request.game_state)

    # 2. Select prompt template
    prompt = MISSION_PROMPTS[request.mission_type].format(**context)

    # 3. Generate with AI
    ai_client = get_ai_client()
    response = await ai_client.generate(AITaskType.STORY_MISSION, prompt)

    # 4. Validate response
    mission = validate_mission(response)

    # 5. Cache result
    cache_mission(mission)

    return mission
```

### POST /api/chat/message

**Purpose:** Process chat message from player

**Request:**
```json
{
  "message": "What's our fuel status?",
  "session_id": "uuid",
  "game_state": {...},
  "conversation_context": [...]
}
```

**Response:**
```json
{
  "ai_personality": "atlas",
  "ai_name": "ATLAS",
  "message": "Current fuel reserves: 65%. Sufficient for 3 more jumps.",
  "actions": null,
  "command_executed": "fuel_status"
}
```

## Development Guidelines

### Adding New Endpoint

1. Create function in appropriate router file (`src/api/`)
2. Define Pydantic request/response models
3. Implement business logic
4. Add caching if expensive operation
5. Write unit tests
6. Update this CLAUDE.md

### Adding New AI Provider

1. Create file in `src/ai/providers/[provider].py`
2. Implement provider interface:
```python
class NewProvider:
    async def generate(self, prompt: str, **kwargs) -> str:
        # Implementation
        pass
```
3. Register in `src/ai/client.py`
4. Add configuration to `.env.example`
5. Update routing logic if needed
6. Write integration tests

### Prompt Engineering

**Best Practices:**
1. Clear context (who, what, why)
2. Structured output (JSON schema)
3. Examples (few-shot learning)
4. Constraints (tone, length, format)
5. Validation (Pydantic models)

**Template Structure:**
```python
PROMPT = """
[Role/Context]

[User Data]

[Task Description]

[Output Format]

[Constraints]

[Example]
"""
```

## Testing

### Unit Tests
```bash
pytest tests/test_missions.py -v
```

### Integration Tests
```bash
pytest tests/ -v --integration
```

### Manual API Testing
```bash
curl -X POST http://localhost:8001/api/missions/generate \
  -H "Content-Type: application/json" \
  -d @tests/fixtures/mission_request.json
```

## Configuration

### Environment Variables (.env)

```ini
# AI Providers
AI_PROVIDER_STORY=claude
AI_PROVIDER_QUICK=ollama
AI_PROVIDER_RANDOM=openai

# API Keys
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
OLLAMA_BASE_URL=http://localhost:11434

# Models
CLAUDE_MODEL=claude-3-5-sonnet-20241022
OPENAI_MODEL=gpt-3.5-turbo
OLLAMA_MODEL=llama3.2:3b

# Cache
REDIS_URL=redis://localhost:6379
CACHE_TTL_HOURS=24

# Settings
TEMPERATURE=0.8
MAX_TOKENS=1500
```

## Dependencies

### Internal
- `python/shared/` - Shared utilities

### External
- `fastapi` - Web framework
- `langchain` - AI integration
- `anthropic` - Claude client
- `openai` - OpenAI client
- `redis` - Caching
- `pydantic` - Data validation

## Common Tasks

### Start Service (Development)
```bash
cd python/ai-service
source venv/bin/activate
uvicorn main:app --reload --port 8001
```

### Start Service (Docker)
```bash
docker-compose up ai-service
```

### View Logs
```bash
docker-compose logs -f ai-service
```

### Clear Cache
```bash
# Connect to Redis
docker-compose exec redis redis-cli

# Clear all keys
FLUSHALL
```

## Troubleshooting

### Service Won't Start
**Check:**
- Python version (3.10+)?
- Dependencies installed?
- .env file exists?
- API keys valid?

### AI Generation Fails
**Check:**
- Provider API key valid?
- Provider service reachable?
- Ollama running (if using)?
- Response validation passing?

### Slow Response Times
**Check:**
- Redis cache working?
- Network latency to AI provider?
- Prompt too long?
- Model selection appropriate?

## Performance

**Target Response Times:**
- Mission generation: < 5 seconds
- Chat message: < 3 seconds
- Cached response: < 100ms

**Optimization:**
- Cache all expensive AI calls
- Use faster models for simple tasks
- Batch requests when possible
- Monitor and alert on slow responses

## Next Steps

**Current:** [Phase/Week]

**Planned:**
- [ ] Add image generation integration
- [ ] Implement response streaming
- [ ] Add more AI providers (Gemini, etc.)

## Design Reference

See:
- [AI Integration](../../docs/ai-integration.md)
- [AI Chat & Storytelling](../../docs/ai-chat-storytelling-system.md)
- [Technical Architecture](../../docs/technical-architecture.md)

## Change Log

### 2025-11-XX
- Created service structure
- Implemented mission generation
- Added chat system
```

---

## Usage Guidelines

### For Claude Code

**When working in a directory:**

1. **Read CLAUDE.md first**
   ```
   User: "Add a new ship system for shields"

   Claude:
   1. Read godot/scripts/systems/CLAUDE.md
   2. Understand the ShipSystem base class pattern
   3. See how other systems are implemented
   4. Create shield_system.gd following the pattern
   5. Update CLAUDE.md with new system info
   ```

2. **Follow established patterns**
   - Don't invent new patterns if one exists
   - Ask before deviating from patterns

3. **Update CLAUDE.md when:**
   - Adding new files
   - Changing directory structure
   - Establishing new patterns
   - Solving common problems

4. **Link to design docs**
   - Always reference relevant design documentation
   - Help future developers understand "why"

### For Human Developers

**When exploring codebase:**
1. Start at root CLAUDE.md
2. Navigate through directory tree via CLAUDE.md links
3. Understand each area before diving into code

**When adding features:**
1. Read relevant CLAUDE.md files
2. Follow established patterns
3. Update CLAUDE.md with your additions
4. Link to design decisions

---

## Maintenance

### Keeping CLAUDE.md Files Fresh

**During Development:**
- Update immediately when adding/removing files
- Document new patterns as they emerge
- Record solutions to problems

**During Code Review:**
- Check if CLAUDE.md needs updating
- Verify new files are documented
- Ensure patterns are consistent

**Quarterly Review:**
- Read through all CLAUDE.md files
- Remove outdated information
- Update based on lessons learned
- Refine patterns and conventions

### Signs CLAUDE.md Needs Updating

- ❌ Mentions files that don't exist
- ❌ Doesn't mention new files
- ❌ Patterns don't match current code
- ❌ Troubleshooting section outdated
- ❌ Links broken
- ❌ Phase info outdated

---

## Complete CLAUDE.md Hierarchy

After Phase 1 implementation, the project should have:

```
space-adventures/
├── CLAUDE.md                              # Project root
├── docs/
│   └── CLAUDE.md                          # Documentation organization
├── godot/
│   ├── CLAUDE.md                          # Godot overview
│   ├── scenes/
│   │   └── CLAUDE.md                      # Scene organization
│   ├── scripts/
│   │   ├── CLAUDE.md                      # Script organization
│   │   ├── autoload/
│   │   │   └── CLAUDE.md                  # Singleton guide
│   │   ├── systems/
│   │   │   └── CLAUDE.md                  # Ship systems guide
│   │   ├── ui/
│   │   │   └── CLAUDE.md                  # UI components guide
│   │   └── utils/
│   │       └── CLAUDE.md                  # Utilities guide
│   └── assets/
│       └── CLAUDE.md                      # Asset organization
├── python/
│   ├── CLAUDE.md                          # Python services overview
│   ├── gateway/
│   │   └── CLAUDE.md                      # Gateway service
│   ├── ai-service/
│   │   └── CLAUDE.md                      # AI service
│   ├── whisper-service/
│   │   └── CLAUDE.md                      # Whisper service
│   └── shared/
│       └── CLAUDE.md                      # Shared utilities
└── tools/
    └── CLAUDE.md                          # Development tools
```

**Total:** ~15-20 CLAUDE.md files

---

## Benefits of This System

**For AI Assistants:**
✅ Context-aware - Understands each directory's purpose
✅ Pattern-following - Maintains consistency
✅ Self-documenting - Updates docs as it works
✅ Design-aligned - Links to authoritative design docs

**For Human Developers:**
✅ Quick orientation - Understand any directory in 2 minutes
✅ Onboarding - New developers get up to speed fast
✅ Maintainability - Code stays organized
✅ Knowledge retention - Design decisions preserved

**For Project:**
✅ Living documentation - Always accurate
✅ Consistent patterns - Easier to maintain
✅ Lower cognitive load - Less to remember
✅ Better collaboration - Clear conventions

---

**Document Status:** Complete
**Related Documents:**
- [Development Organization](development-organization.md) - Overall development plan
- [Technical Architecture](technical-architecture.md) - System architecture

**Last Updated:** November 5, 2025
