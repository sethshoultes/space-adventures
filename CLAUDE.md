# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Status

**Current Phase:** Design Complete - Ready for Implementation
**Next Phase:** Phase 1, Week 1 - Foundation & Core Services

This repository contains complete design documentation for **Space Adventures**, a narrative-driven space adventure game. No implementation code exists yet - this is intentional.

## 🚀 IMPORTANT: Start Here for Development

**For AI-Assisted Development:**
1. **Read:** [docs/development-organization.md](docs/development-organization.md) - Master development plan
2. **Understand:** Microservices architecture and phase-based development
3. **Follow:** Embedded CLAUDE.md system for directory-level guidance
4. **Reference:** [docs/claude-md-templates.md](docs/claude-md-templates.md) for documentation patterns

**Development Approach:**
- **Microservices Architecture** - Independent services (Gateway, AI, Whisper, Image)
- **Phase-Based Development** - 5 phases, each 3-4 weeks
- **Embedded Documentation** - CLAUDE.md in every directory
- **AI-Assisted Workflow** - Claude Code as primary development partner
- **SOLID Principles** - Clean, maintainable, scalable code

## Project Overview

A serious sci-fi choose-your-own-adventure game inspired by Star Trek: TNG where players:
1. Scavenge post-exodus Earth for ship parts (Phase 1 - MVP)
2. Build a starship system by system (10 core systems)
3. Launch into space and explore the galaxy (Phase 2 - Post-MVP)
4. Experience AI-powered dynamic narrative using ChatGPT or Ollama

**Tech Stack:** Godot 4.2+ (game) + Python 3.10+ FastAPI (AI service)

## Architecture

### Dual-System Design

```
GODOT (Game Logic)          PYTHON (AI Service)
├─ GDScript                 ├─ FastAPI server
├─ Game scenes (.tscn)      ├─ LangChain (OpenAI/Ollama)
├─ Save/load (JSON)         ├─ Pydantic models
└─ HTTP client          →   └─ SQLite cache
                        ↑
                    REST API
```

**Communication:** Godot makes HTTP requests to Python service at `http://localhost:8000/api/*`

### Key Singletons (Autoload in Godot)

When implementing, these are the core autoload scripts:
- `GameState`: Global game state (player, ship, inventory, progress)
- `SaveManager`: Save/load to JSON files in `godot/saves/`
- `AIService`: HTTP client for AI content generation
- `EventBus`: Decoupled event system

### Data Flow

1. Player makes choice in Godot UI
2. If AI needed: Godot → HTTP POST → Python service
3. Python generates content via LangChain
4. Response cached in SQLite
5. JSON returned to Godot
6. Godot updates GameState and UI
7. Periodically save to `godot/saves/save_slot_N.json`

## Development Commands

### Python AI Service

```bash
# Setup (first time)
cd python
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
cp .env.example .env
# Edit .env with AI provider settings

# Run server
python src/main.py
# Server runs at http://localhost:8000

# Run tests
pytest tests/
pytest tests/test_specific.py::test_function  # Single test

# Code formatting
black src/
flake8 src/
```

### Godot

```bash
# Open project
godot godot/project.godot

# Run from command line
godot godot/project.godot --headless  # Test mode
```

**In Godot Editor:**
- F5: Run game
- F6: Run current scene
- Ctrl+S: Save scene/script

### Both Systems

```bash
# Start both systems for development:
# Terminal 1:
cd python && source venv/bin/activate && python src/main.py

# Terminal 2:
godot godot/project.godot
# Then press F5 in Godot
```

## Critical Design Documents

Read these before implementing:

1. **[docs/mvp-roadmap.md](docs/mvp-roadmap.md)** - Week-by-week implementation plan
   - Start here for what to build next
   - Contains daily task breakdowns
   - Includes test plans and deliverables

2. **[docs/technical-architecture.md](docs/technical-architecture.md)** - Code structure
   - Complete file structure
   - Data model schemas (Python Pydantic + GDScript equivalents)
   - API endpoint specifications
   - Save file format

3. **[docs/ship-systems.md](docs/ship-systems.md)** - The 10 core systems
   - Level 0-5 specs for each system
   - Power consumption mechanics
   - System interactions and synergies

4. **[docs/ship-classification-system.md](docs/ship-classification-system.md)** - Ship classes
   - 10 ship classes (Scout, Courier, Frigate, Science Vessel, Destroyer, Cruiser, Heavy Cruiser, Explorer, Dreadnought, Support Vessel)
   - Classification requirements based on system configuration
   - Class bonuses and special abilities
   - Recognition system and player goals

5. **[docs/mission-framework.md](docs/mission-framework.md)** - Mission system
   - Mission JSON schema
   - 6 mission types (salvage, exploration, trade, rescue, combat, story)
   - Example fully-specified missions

6. **[docs/ai-integration.md](docs/ai-integration.md)** - AI implementation
   - Complete prompt templates
   - Context management strategies
   - Caching and validation

## Game Data Structures

### GameState (GDScript Dictionary)

```gdscript
{
  "player": {
    "name": "Player",
    "level": 1,
    "xp": 0,
    "skills": {"engineering": 0, "diplomacy": 0, "combat": 0, "science": 0}
  },
  "ship": {
    "name": "Unnamed Vessel",
    "systems": {
      "hull": {"level": 0, "health": 100, "active": false, "installed_part": null},
      # ... 9 more systems
    },
    "hull_hp": 0,
    "max_hull_hp": 0,
    "power_available": 0,
    "power_total": 0
  },
  "inventory": [],  # Array of item dictionaries
  "progress": {
    "phase": 1,  # 1=Earthbound, 2=Space
    "completed_missions": [],
    "discovered_locations": [],
    "major_choices": []
  }
}
```

### Mission JSON Schema

Missions are stored in `godot/assets/data/missions/*.json`:

```json
{
  "mission_id": "unique_id",
  "title": "Mission Title",
  "type": "salvage|exploration|trade|rescue|combat|story",
  "location": "Location Name",
  "description": "Brief overview",
  "difficulty": 1-5,
  "stages": [
    {
      "stage_id": "stage_1",
      "description": "What's happening",
      "choices": [
        {
          "choice_id": "choice_1",
          "text": "Player choice text",
          "requirements": {"skill": "engineering", "skill_level": 3},
          "consequences": {
            "success": {"next_stage": "stage_2", "xp_bonus": 25},
            "failure": {"next_stage": "stage_fail"}
          }
        }
      ]
    }
  ],
  "rewards": {"xp": 100, "items": ["item_id"]}
}
```

## Implementation Guidelines

### When Implementing Godot Code

**Naming Conventions:**
- snake_case for variables/functions: `ship_health`, `calculate_damage()`
- PascalCase for classes: `ShipSystem`, `MissionManager`
- SCREAMING_CASE for constants: `MAX_LEVEL`, `DEFAULT_POWER`

**Type Hints:**
```gdscript
var health: int = 100
var name: String = "Ship"
var items: Array = []

func calculate_damage(amount: int) -> int:
    return amount * 2
```

**Autoload Scripts:** Register in Project Settings > Autoload
- GameState → `res://scripts/autoload/game_state.gd`
- SaveManager → `res://scripts/autoload/save_manager.gd`
- AIService → `res://scripts/autoload/ai_service.gd`

### When Implementing Python Code

**Follow these patterns:**

```python
# Use Pydantic for all data models
from pydantic import BaseModel, Field

class GameState(BaseModel):
    version: str = "1.0.0"
    player: Player
    ship: Ship
    # ...

# All API endpoints return structured JSON
@router.post("/generate", response_model=MissionResponse)
async def generate_mission(request: MissionRequest):
    # Validate, generate, cache, return
    pass
```

**AI Generation Pattern:**
1. Build context from GameState
2. Format prompt template
3. Call LLM via LangChain
4. Validate response against Pydantic schema
5. Cache result in SQLite
6. Return to Godot

### Save System

**Location:** `godot/saves/save_slot_N.json`

**Format:** JSON with versioning for future migrations

**When to Save:**
- Player triggers manual save (S key)
- After mission completion
- Before major story events
- On game exit

**Save Manager Must:**
- Validate save file version
- Handle corrupted saves gracefully
- Support multiple save slots (3 minimum)
- Include timestamp and playtime

## The 10 Ship Systems

All systems have levels 0-5. MVP implements levels 0-3.

1. **Hull** - Ship integrity, HP
2. **Power Core** - Energy generation for all systems
3. **Propulsion** - Sub-light engines, maneuverability
4. **Warp Drive** - FTL travel (required to leave Earth)
5. **Life Support** - Crew survival, capacity
6. **Computer Core** - AI assistance, automation
7. **Sensors** - Detection, scanning range
8. **Shields** - Damage mitigation
9. **Weapons** - Combat capability
10. **Communications** - Long-range comms, translation

**Phase 1 Unlock Requirement:** All 10 systems at Level 1 minimum.

## MVP Scope (6 Weeks)

**What's In:**
- All 10 systems (levels 0-3)
- 15+ missions (10 scripted + 5 AI-generated)
- Workshop hub UI
- Save/load system
- AI integration (OpenAI + Ollama)
- 4-6 hours gameplay

**What's Deferred:**
- Phase 2 (space exploration)
- Advanced graphics
- Sound/music
- Systems beyond Level 3
- Combat mechanics

## Development Workflow

### Week 1: Foundation
- Create Godot project structure
- Implement GameState and SaveManager
- Set up Python FastAPI skeleton
- Test Godot ↔ Python communication

### Week 2: Ship Systems
- Implement all 10 ship system classes
- Create workshop UI
- Implement inventory system

### Week 3: Mission System
- Build mission framework
- Create mission UI (select, play, complete)
- Write first 5 scripted missions

### Week 4: AI Integration
- Implement Python AI service
- Create prompt templates
- Test mission generation
- Add caching

### Week 5: Content & Polish
- Write remaining scripted missions
- Implement remaining systems
- Visual polish
- Tutorial mission

### Week 6: Testing & Finalization
- Full playthrough testing
- Bug fixes
- Balance tuning
- Documentation

## Testing Strategy

**Python:**
- Unit tests for all API endpoints
- Test AI prompt generation
- Test cache system
- Mock LLM responses for tests

**Godot:**
- Manual playtesting
- Test all mission paths
- Test save/load at various states
- Try to break progression

**Integration:**
- Test Godot → Python → Godot flow
- Test with both OpenAI and Ollama
- Test error handling (AI service down, etc.)

## Software Design Principles

This project follows industry-standard design principles. **Apply these rigorously:**

### SOLID Principles

#### Single Responsibility Principle (SRP)
**Each class/module has ONE reason to change.**

**Good:**
```gdscript
# ship_system.gd - Only handles ship system state
class_name ShipSystem
var level: int
var health: int
func take_damage(amount: int): ...

# power_calculator.gd - Only calculates power
class_name PowerCalculator
static func calculate_total_power(systems: Dictionary) -> int: ...
```

**Bad:**
```gdscript
# ship_system.gd doing too much
class_name ShipSystem
var level: int
func take_damage(amount: int): ...
func save_to_file(path: String): ...  # ❌ Should be in SaveManager
func render_ui(): ...  # ❌ Should be in UI class
```

**In This Project:**
- `GameState` = data only, no logic
- `SaveManager` = save/load only
- `AIService` = HTTP client only
- `MissionManager` = mission flow only
- Each ship system = its own file

#### Open/Closed Principle (OCP)
**Open for extension, closed for modification.**

**Use inheritance for ship systems:**
```gdscript
# Base class (closed for modification)
class_name ShipSystem
var level: int
var health: int
func get_power_cost() -> int:
    return 0  # Override in subclass

# Extend, don't modify (open for extension)
class_name WarpSystem extends ShipSystem
func get_power_cost() -> int:
    return [20, 30, 50, 80, 120][level]
```

**New mission types:** Add new mission class, don't modify base mission code.

#### Liskov Substitution Principle (LSP)
**Subclasses must be substitutable for base classes.**

```gdscript
# Any ShipSystem subclass works in this function
func install_system(system: ShipSystem) -> void:
    system.health = 100
    system.active = true
    # Works for HullSystem, PowerSystem, WarpSystem, etc.
```

**Don't violate:**
```gdscript
class_name BrokenSystem extends ShipSystem
func take_damage(amount: int):
    # ❌ Violates LSP if base class expects this to work
    push_error("This system can't take damage!")
```

#### Interface Segregation Principle (ISP)
**Don't force classes to depend on methods they don't use.**

**Good:** Separate interfaces (GDScript uses duck typing, but concept applies)
```gdscript
# Upgradeable interface
class_name Upgradeable
func can_upgrade() -> bool: return true
func upgrade(): pass

# Damageable interface
class_name Damageable
func take_damage(amount: int): pass
func repair(amount: int): pass
```

**Bad:** Fat interface
```gdscript
# ❌ Forces all systems to implement combat methods even if non-combat
class_name ShipSystem
func fire_weapons(): pass  # Only WeaponSystem needs this
func scan(): pass  # Only SensorSystem needs this
```

#### Dependency Inversion Principle (DIP)
**Depend on abstractions, not concretions.**

**Good:**
```python
# Python AI service - depend on interface
class AIProvider(ABC):
    @abstractmethod
    async def generate(self, prompt: str) -> str:
        pass

class OpenAIProvider(AIProvider):
    async def generate(self, prompt: str) -> str:
        # OpenAI implementation

class OllamaProvider(AIProvider):
    async def generate(self, prompt: str) -> str:
        # Ollama implementation

# Client depends on abstraction
class ContentGenerator:
    def __init__(self, provider: AIProvider):
        self.provider = provider  # Can be either, doesn't care
```

**Bad:**
```python
# ❌ Directly depends on OpenAI
class ContentGenerator:
    def __init__(self):
        self.client = OpenAI(api_key=...)  # Tightly coupled
```

### DRY (Don't Repeat Yourself)

**Every piece of knowledge should have a single, authoritative representation.**

**Good:**
```gdscript
# Centralized in one place
const SYSTEM_NAMES = ["hull", "power", "propulsion", "warp", ...]

func initialize_systems():
    for sys_name in SYSTEM_NAMES:
        ship.systems[sys_name] = create_system(sys_name)
```

**Bad:**
```gdscript
# ❌ Repeated everywhere
func save_game():
    save_hull()
    save_power()
    save_propulsion()
    save_warp()
    # ... 6 more times

func load_game():
    load_hull()
    load_power()
    # ... repeated logic
```

**In This Project:**
- System power costs → single table in `ship-systems.md`, one calculation function
- Mission schema validation → one Pydantic model
- Save format → one schema, used by both save and load
- AI prompts → templates in `ai/prompts.py`, not hardcoded in endpoints

### YAGNI (You Aren't Gonna Need It)

**Don't implement features until they're actually needed.**

**MVP Scope - Build ONLY these:**
- ✅ 10 systems with levels 0-3 (not 0-5)
- ✅ Phase 1 missions (not Phase 2)
- ✅ Basic UI (not fancy graphics)
- ✅ Save/load (not cloud sync)

**Don't Build Yet:**
- ❌ Combat mechanics (Phase 2)
- ❌ Crew management (not in MVP)
- ❌ Multiplayer (not planned)
- ❌ Mobile controls (desktop only)
- ❌ Advanced animations (MVP is functional)

**Example:**
```gdscript
# ✅ YAGNI - simple, does what's needed now
func save_game(slot: int):
    var data = GameState.to_dict()
    save_json(data, get_save_path(slot))

# ❌ YAGNI violation - too complex for MVP
func save_game(slot: int, cloud: bool = false, compress: bool = false,
               encrypt: bool = false, backup: bool = false):
    # ... 200 lines of features we don't need yet
```

### KISS (Keep It Simple, Stupid)

**Simplest solution that works is best.**

**Good:**
```python
# Simple, clear, works
def calculate_mission_xp(difficulty: int) -> int:
    return 50 + (difficulty * 30)
```

**Bad:**
```python
# ❌ Over-engineered for a simple calculation
class XPCalculationStrategy(ABC):
    @abstractmethod
    def calculate(self, mission: Mission) -> int: pass

class DifficultyBasedXPStrategy(XPCalculationStrategy):
    def __init__(self, base: int, multiplier: float, curve: Callable):
        self.base = base
        self.multiplier = multiplier
        self.curve = curve
    def calculate(self, mission: Mission) -> int:
        return self.curve(self.base + mission.difficulty * self.multiplier)

# Overkill for "50 + difficulty * 30"
```

**In This Project:**
- JSON for saves (not custom binary format)
- HTTP REST for Godot ↔ Python (not gRPC or WebSockets)
- Dictionary for GameState (not complex class hierarchy)
- Linear XP progression (not complex formulas)

### Clean Code Principles

#### Meaningful Names
```gdscript
# ✅ Good - intent is clear
var player_experience_points: int
func calculate_total_power_consumption() -> int

# ❌ Bad - cryptic
var xp: int
var pwr: int
func calc() -> int
```

#### Small Functions
**Functions should do ONE thing and do it well.**

```gdscript
# ✅ Good - each function has one job
func advance_mission():
    var choice = get_player_choice()
    var result = process_choice(choice)
    update_game_state(result)
    show_result_to_player(result)

# ❌ Bad - doing too much
func advance_mission():
    # 200 lines doing everything
```

**Target: 10-20 lines per function, max 50 lines**

#### Minimize Function Arguments
```gdscript
# ✅ Good - 0-2 arguments
func install_part(part_id: String):
    var part = get_part(part_id)
    var system = get_system_for_part(part)
    system.install(part)

# ❌ Bad - too many arguments
func install_part(part_id: String, system_name: String, level: int,
                  rarity: String, stats: Dictionary, player_level: int):
```

**Max 3 arguments. If more needed, use an object/dictionary.**

#### No Side Effects
```gdscript
# ✅ Good - pure function, no side effects
func calculate_damage(base: int, armor: int) -> int:
    return max(0, base - armor)

# ❌ Bad - unexpected side effect
func calculate_damage(base: int, armor: int) -> int:
    GameState.damage_dealt += base  # ❌ Hidden side effect
    save_game()  # ❌ Unexpected!
    return max(0, base - armor)
```

**Functions should be predictable. Side effects should be obvious from the name.**

#### Error Handling
```gdscript
# ✅ Good - explicit error handling
func load_game(slot: int) -> bool:
    if not FileAccess.file_exists(get_save_path(slot)):
        push_error("Save file does not exist")
        return false

    var file = FileAccess.open(get_save_path(slot), FileAccess.READ)
    if file == null:
        push_error("Failed to open save file")
        return false

    return true

# ❌ Bad - silent failure
func load_game(slot: int):
    var file = FileAccess.open(get_save_path(slot), FileAccess.READ)
    # What if file is null? Game crashes later
```

#### Comments Explain WHY, Not WHAT
```gdscript
# ✅ Good - explains reasoning
# Cache AI responses for 24h to reduce costs and improve performance
CACHE_TTL = 86400

# Use exponential XP curve to maintain challenge in late game
func calculate_next_level_xp(current_level: int) -> int:
    return 200 * pow(2, current_level - 1)

# ❌ Bad - stating the obvious
# Set cache TTL to 86400
CACHE_TTL = 86400

# Multiply 200 by 2 to the power of current level minus 1
func calculate_next_level_xp(current_level: int) -> int:
    return 200 * pow(2, current_level - 1)
```

## Design Patterns to Use

### Singleton Pattern (Godot Autoload)
```gdscript
# Use for: GameState, SaveManager, AIService
# Don't use for: Everything else
```

### Factory Pattern (Ship Systems)
```gdscript
func create_system(type: String) -> ShipSystem:
    match type:
        "hull": return HullSystem.new()
        "power": return PowerSystem.new()
        "warp": return WarpSystem.new()
```

### Strategy Pattern (AI Providers)
```python
# Different AI providers, same interface
provider = OpenAIProvider() if use_openai else OllamaProvider()
result = await provider.generate(prompt)
```

### Observer Pattern (Event Bus)
```gdscript
# Decouple components
EventBus.emit_signal("mission_completed", mission_id)
# Multiple listeners can respond without tight coupling
```

## Game Design Principles

**60/40 Content Rule:**
- 60% pre-written scripted content (story missions, key moments)
- 40% AI-generated content (random missions, encounters)
- Why: Ensures quality while adding variety

**Meaningful Choices:**
- Every mission has 2-5 choices
- At least one choice requires skills/systems
- Choices have visible consequences
- No obvious "right" answer in moral dilemmas

**Progressive Unlock:**
- Systems unlock gradually via missions
- Missions unlock based on player level and completed missions
- Phase 2 unlocks when all systems reach Level 1

**Star Trek TNG Tone:**
- Serious but hopeful sci-fi
- Ethical dilemmas (no easy answers)
- Wonder of exploration
- Consequences matter
- Character-driven moments

## File Structure That Must Exist

When implementation begins, create this structure:

```
godot/
├── project.godot              # Godot project config
├── scenes/
│   ├── main_menu.tscn
│   ├── workshop.tscn          # Phase 1 hub
│   ├── mission_select.tscn
│   ├── mission_play.tscn
│   └── ship_schematic.tscn
├── scripts/
│   ├── autoload/              # Singleton scripts
│   │   ├── game_state.gd
│   │   ├── save_manager.gd
│   │   ├── ai_service.gd
│   │   └── event_bus.gd
│   ├── systems/               # Ship system classes
│   │   └── ship_system.gd     # Base class
│   └── ui/                    # UI controllers
├── assets/
│   ├── data/
│   │   ├── ship_parts.json
│   │   └── missions/          # Mission JSON files
│   └── sprites/
└── saves/                     # Save game files

python/
├── src/
│   ├── main.py                # FastAPI entry point
│   ├── api/
│   │   ├── missions.py        # /api/missions/*
│   │   ├── encounters.py      # /api/encounters/*
│   │   └── dialogue.py        # /api/dialogue/*
│   ├── ai/
│   │   ├── client.py          # LangChain setup
│   │   └── prompts.py         # Prompt templates
│   ├── models/
│   │   ├── game_state.py
│   │   ├── mission.py
│   │   └── ship.py
│   └── cache/
│       └── sqlite_cache.py
├── tests/
└── requirements.txt
```

## Environment Configuration

**python/.env** must contain:
```
AI_PROVIDER=ollama              # or "openai"
OPENAI_API_KEY=sk-...          # if using OpenAI
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama2
TEMPERATURE=0.8
API_HOST=0.0.0.0
API_PORT=8000
CACHE_ENABLED=true
```

## Common Pitfalls to Avoid

1. **Don't generate content synchronously in Godot** - Always use async HTTP requests with loading indicators
2. **Don't trust AI output without validation** - Always validate against Pydantic schema, have fallbacks
3. **Don't forget to cache** - AI calls are expensive (OpenAI) or slow (Ollama)
4. **Don't hardcode system interdependencies** - Use the power system calculations from ship-systems.md
5. **Don't skip save validation** - Future updates need save file migration support
6. **Don't create circular dependencies** - GameState should be pure data, logic goes in managers

## Next Steps for Implementation

**📖 READ FIRST:** [docs/development-organization.md](docs/development-organization.md)

This document provides the complete development system including:
- ✅ Microservices architecture (Gateway, AI, Whisper, Image services)
- ✅ Phase-based development (Phases 1-5 with week-by-week breakdowns)
- ✅ Embedded CLAUDE.md system (directory-level guidance)
- ✅ AI-assisted development workflow
- ✅ Quality assurance and testing strategy
- ✅ Launch and maintenance plans

**If starting Phase 1, Week 1, Day 1:**

1. Read [docs/development-organization.md](docs/development-organization.md) - Sections 1-3
2. Read [docs/claude-md-templates.md](docs/claude-md-templates.md) - Understand CLAUDE.md system
3. Follow Phase 1, Week 1 checklist from development-organization.md
4. Create directory structure with CLAUDE.md files
5. Begin Gateway Service implementation

**If continuing development:**
- Check current phase/week in development-organization.md
- Read relevant CLAUDE.md files for context
- Follow established patterns
- Update CLAUDE.md files as you work
- Commit with descriptive messages

## Reference Links

- [Godot 4.2 Docs](https://docs.godotengine.org/en/stable/)
- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [LangChain Docs](https://python.langchain.com/)
- [Pydantic Docs](https://docs.pydantic.dev/)

---

**Remember:** This is a hobby project focused on narrative and meaningful choices. Prioritize gameplay over graphics. Ship a playable MVP before adding polish. The design is complete - now execute!
