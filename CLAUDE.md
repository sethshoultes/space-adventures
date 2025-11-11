# CLAUDE.md

**Primary guidance for AI agents (Claude Code, etc.) working on this project.**

## 🤖 AI Agent as Primary Developer

**This project uses AI agents to perform ~99% of development work.**

**CRITICAL FILES (Read These First):**
- `/STATUS.md` - Current task and context (read every session)
- `/AI-AGENT-GUIDE.md` - Complete development workflow and authority levels
- `/ROADMAP.md` - Milestone checklist (your task list)
- `/DECISIONS.md` - Don't re-decide things
- `/JOURNAL.md` - Document learnings

**Quick Start Each Session:**
1. Read STATUS.md
2. Check ROADMAP.md for current checklist item
3. Read relevant directory CLAUDE.md
4. Implement → Test → Update STATUS → Commit

---

## Project Status

**Current Milestone:** Milestone 1 - Proof of Concept (92% complete)
**Current Task:** Testing phase - Full game playthrough validation
**Next Phase:** Milestone 1 completion → Milestone 2 planning

**Foundation Complete:**
- ✅ Microservices architecture (Gateway, AI Service, Whisper, Redis)
- ✅ Godot foundation (10 autoload singletons, 3,600+ lines)
- ✅ Comprehensive documentation (70+ files organized)
- ✅ AI-agent workflow established (STATUS, ROADMAP, AI-AGENT-GUIDE)
- ✅ Advanced features (Magentic UI, Story Engine, Hybrid Economy)

**Ready for:** Final testing and Milestone 1 validation

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

---

## 🎯 Project Philosophy

**This is a hobby/learning project, not a commercial product.**

**What this means for AI agents:**

✅ **Prioritize:**
- Learning opportunities over perfect solutions
- Working code over perfect architecture
- Progress over perfection
- Simple solutions over complex ones
- Documenting discoveries in JOURNAL.md

⚠️ **Remember:**
- No deadlines, build when user is motivated
- Milestones not timelines
- Rough edges are acceptable
- Experimentation encouraged
- User makes game design decisions (balance, content)
- You make implementation decisions (code, patterns)

**Success Criteria:**
- ✅ Developer learned new skills
- ✅ Code works (even if rough)
- ✅ Progress documented
- ✅ Something playable exists

Not required:
- Professional polish
- Complete feature set
- Thousands of users
- Perfect code

**Decision Authority:** See `/AI-AGENT-GUIDE.md` for complete 3-tier authority levels (✅ Autonomous / ⚠️ Propose / 🛑 Ask)

---

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

**Communication:** Godot → Gateway (17010) with automatic fallback to direct services (17011-17014)

### Key Singletons (Autoload in Godot)

When implementing, these are the 10 core autoload scripts:
- `ServiceManager`: HTTP client, health checks, gateway fallback routing
- `GameState`: Global game state (player, ship, inventory, progress, economy)
- `SaveManager`: Save/load to JSON files (5 slots + autosave)
- `EventBus`: Decoupled event system (55+ signals)
- `AIService`: AI content generation client (legacy)
- `StoryService`: Dynamic story engine client (Memory Manager, World State)
- `MissionManager`: Mission flow, rewards, progression
- `AIPersonalityManager`: Multi-AI personality system (4 personalities)
- `AdaptiveLayoutManager`: Context-aware UI layout calculations
- `PartRegistry`: Data-driven parts/systems/economy (720+ lines)

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

**This project uses a milestone-based approach, not timeline-based development.**

### Current Development Process

1. **Check Project Status**
   - Read `/STATUS.md` for current task and progress (updated every session)
   - Check `/ROADMAP.md` for milestone checklist items
   - Review `/AI-AGENT-GUIDE.md` for development authority levels
   - Read relevant directory `CLAUDE.md` for context

2. **Implement Features**
   - Work through ROADMAP.md checklist items in order
   - Follow patterns established in existing code
   - Make autonomous decisions within authority level
   - Document major decisions in `/DECISIONS.md`
   - Update STATUS.md as you progress

3. **Test & Document**
   - Test implementation manually in Godot
   - Update relevant documentation files
   - Commit with detailed messages explaining what/why
   - Mark checklist items complete in ROADMAP.md
   - Document learnings in `/JOURNAL.md`

### Milestone-Based Development

**Milestone 1: Proof of Concept** (Current - 92% complete)
- ✅ Foundation: Microservices architecture (Gateway, AI Service, Whisper, Redis)
- ✅ Godot Singletons: 10 autoloads (3,600+ lines of GDScript)
- ✅ Core Systems: Hull, Power Core, Propulsion (Level 0-5)
- ✅ Content: Tutorial mission "The Inheritance" with ATLAS AI
- ✅ UI: Workshop, Mission system with scrolling log, Main menu
- ✅ Economy: Hybrid credits + parts system with PartRegistry
- ✅ Advanced: Magentic UI, Dynamic Story Engine, Mission Pool
- ⏳ Testing: Full game playthrough validation

**Milestone 2: Expand Content** (Future - after M1 validation)
- Add more systems (Warp, Life Support)
- Add more missions (salvage, exploration, story)
- Expand AI personalities
- UI improvements

**Milestone 3: Share It** (Future - public release)
- All 10 systems complete
- 10+ missions
- Polish and deployment preparation

See `/ROADMAP.md` for complete milestone checklists and `/STATUS.md` for current status.

### Key Development Files

- **/STATUS.md** - Current task, progress, blockers (read every session)
- **/ROADMAP.md** - Milestone checklists (your task list)
- **/AI-AGENT-GUIDE.md** - Decision authority levels, workflow patterns
- **/DECISIONS.md** - Record of major decisions (don't re-decide things)
- **/JOURNAL.md** - Learning documentation (document discoveries)
- **/docs/CLAUDE.md** - Master documentation context
- **Directory CLAUDE.md files** - Context for each directory

### For AI Agents

**Start each session:**
1. Read STATUS.md
2. Check ROADMAP.md for current checklist item
3. Read relevant directory CLAUDE.md for context
4. Implement → Test → Update STATUS → Commit
5. Check off ROADMAP.md items as complete

**Development Philosophy:**
- **Milestones not timelines** - Build when motivated, no deadlines
- **Progress over perfection** - Working code beats perfect plans
- **Learning over shipping** - This is a hobby/learning project
- **Test as you go** - Manual testing after each feature
- **Document decisions** - Future you will thank present you

**This is a hobby project:** Take breaks, pivot if not fun, celebrate progress.

## Testing Strategy

**For hobby project: Manual testing is primary approach**

**Python Services:**
- Test API endpoints via curl/Postman
- Verify AI prompt generation
- Test Redis cache system
- Check service health endpoints
- Test gateway fallback routing

**Godot Manual Testing:**
- Launch game and navigate all screens
- Test complete mission playthrough
- Test all mission paths and choices
- Test save/load at various game states
- Test upgrade system with economy
- Test inventory management (weight limits, capacity)
- Test skill point allocation
- Verify Magentic UI layout (AI panel side-by-side)
- Test manual scroll pacing (click/wheel/keyboard)
- Test ATLAS AI interjections
- Try to break progression (edge cases)

**Integration Testing:**
- Test Godot → Gateway → AI Service flow
- Test automatic service fallback
- Test error handling (services down, network errors)
- Test save file migration (old saves load correctly)
- Test complete game loop: Workshop → Mission → Rewards → Workshop

**Current Testing Focus (Milestone 1):**
See ROADMAP.md Integration Testing section for complete checklist

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

## File Structure (Current Implementation)

**Actual structure as implemented:**

```
godot/
├── project.godot              # Godot project config
├── scenes/
│   ├── main_menu.tscn         # DALL-E background with framed panel
│   ├── workshop.tscn          # Phase 1 hub with economy UI
│   ├── mission_selection.tscn # Mission list with Random Mission button
│   ├── mission.tscn           # Scrolling narrative log + Magentic UI
│   └── components/
│       └── ai_panel.tscn      # Reusable AI interjection widget
├── scripts/
│   ├── autoload/              # 10 Singleton scripts (3,600+ lines)
│   │   ├── service_manager.gd       # HTTP client, health checks
│   │   ├── game_state.gd            # Player, ship, inventory, economy
│   │   ├── save_manager.gd          # 5 slots + autosave
│   │   ├── event_bus.gd             # 55+ signals
│   │   ├── ai_service.gd            # Legacy AI client
│   │   ├── story_service.gd         # Story Engine client
│   │   ├── mission_manager.gd       # Mission flow, rewards
│   │   ├── ai_personality_manager.gd # 4 AI personalities
│   │   ├── adaptive_layout_manager.gd # UI layout logic
│   │   └── part_registry.gd         # 720+ lines, 30+ methods
│   ├── systems/               # Ship system classes
│   │   ├── ship_system.gd     # Base class
│   │   ├── hull_system.gd     # Level 0-5
│   │   ├── power_system.gd    # Level 0-5
│   │   └── propulsion_system.gd # Level 0-5
│   └── ui/                    # UI controllers
│       ├── main_menu.gd
│       ├── workshop.gd
│       ├── mission_selection.gd
│       └── mission.gd
├── assets/
│   ├── data/
│   │   ├── parts/             # 5 JSON files (39 parts defined)
│   │   ├── systems/           # ship_systems.json
│   │   ├── economy/           # economy_config.json
│   │   └── missions/          # Tutorial + hybrid missions
│   └── graphics/
│       └── main_menu_bg.png   # DALL-E space background
└── saves/                     # Save slots (JSON format)

python/
├── gateway/                   # Port 17010
│   ├── main.py
│   └── routes/
├── ai-service/                # Port 17011
│   ├── main.py
│   ├── api/
│   │   ├── chat.py            # /api/chat/*
│   │   ├── missions.py        # /api/missions/*
│   │   ├── dialogue.py        # /api/dialogue/*
│   │   └── story.py           # /api/story/* (Story Engine)
│   ├── services/
│   │   ├── memory_manager.py  # Player choice tracking
│   │   └── world_state.py     # Economy, factions, events
│   └── models/
├── whisper-service/           # Port 17012 (optional)
│   └── main.py
├── shared/                    # Shared models
│   └── models/
└── requirements.txt

reports/                       # Implementation history
├── achievements/
├── ai-orchestrator/
├── autonomous-agents/
├── economy/
├── phase-completions/
├── story-engine/
└── systems/

docs/                          # Design documentation (70+ files)
├── 00-getting-started/
├── 01-user-guides/
├── 02-developer-guides/
├── 03-game-design/
├── 04-ui-graphics/
├── 05-ai-content/
├── 06-technical-reference/
└── 07-ai-agent-templates/
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

**Project Status: Milestone 1 at 92% - Testing Phase**

### For AI Agents Starting a Session

**CRITICAL - Read These First:**
1. **/STATUS.md** - Current task and progress (updated every session)
2. **/ROADMAP.md** - Milestone 1 checklist (see Integration Testing section)
3. **/AI-AGENT-GUIDE.md** - Development workflow and authority levels

**Current Focus:**
- Testing complete game loop (Workshop → Mission → Rewards → Workshop)
- Validating Magentic UI, Story Engine, and Economy systems
- Bug fixes as discovered
- Milestone 1 completion validation

**Reference Documentation:**
- [docs/development-organization.md](docs/02-developer-guides/project-management/development-organization.md) - Master development plan
- [docs/CLAUDE.md](docs/CLAUDE.md) - Master documentation context
- Directory CLAUDE.md files - Context for each area

### If Starting Fresh (New AI Agent)

1. **Understand Current State:**
   - Read STATUS.md completely
   - Review ROADMAP.md Milestone 1 section
   - Check recent git commits for context

2. **Understand Architecture:**
   - [docs/02-developer-guides/architecture/technical-architecture.md](docs/02-developer-guides/architecture/technical-architecture.md)
   - [docs/02-developer-guides/architecture/INTEGRATION-GUIDE.md](docs/02-developer-guides/architecture/INTEGRATION-GUIDE.md)
   - [docs/02-developer-guides/architecture/magentic-ui-architecture.md](docs/02-developer-guides/architecture/magentic-ui-architecture.md)

3. **Follow Development Process:**
   - Milestone-based (not timeline-based)
   - Test as you go (manual testing)
   - Update STATUS.md every session
   - Document decisions in DECISIONS.md
   - Commit with detailed messages

### Current Development Priorities

**Priority 1: Testing (Current)**
- Complete game playthrough testing
- Validate all systems work together
- Fix bugs discovered during testing

**Priority 2: Milestone 1 Validation**
- Determine if game loop is fun
- Make "Is it fun?" decision
- Either continue to Milestone 2 or pivot

**Priority 3: Future (After M1)**
- Only proceed if Milestone 1 is validated as fun
- See ROADMAP.md for Milestone 2 checklist

## Advanced Systems Implemented

### Magentic UI System (Microsoft-Inspired)

**Multi-AI adaptive interface with context-aware layouts**

**Components:**
- **AIPersonalityManager** (350+ lines): Manages 4 AI personalities
  - ATLAS: Ship AI (blue theme) - strategic guidance
  - Companion: Emotional support (orange theme)
  - MENTOR: Career advisor (purple theme)
  - CHIEF: Engineering expert (yellow theme)
- **AdaptiveLayoutManager** (200+ lines): Calculates optimal UI layouts
  - 5 UI states: NARRATIVE_FOCUS, AI_INTERJECTION, MULTI_AI_DISCUSSION, PLAYER_AI_CHAT, COMBAT_COMPRESSED
- **AIPanel Component** (150+ lines): Reusable AI interjection widget

**Features:**
- Context-aware AI interjections during missions
- Adaptive two-panel layout (narrative compresses, AI panel slides in)
- Smooth 0.4s transitions
- Signal-based decoupled architecture
- Ready for multi-AI discussions

**Docs:** [docs/02-developer-guides/architecture/magentic-ui-architecture.md](docs/02-developer-guides/architecture/magentic-ui-architecture.md)

### Dynamic Story Engine

**AI-powered contextual narrative generation with memory**

**Components:**
- **Memory Manager**: Tracks last 100 player choices, NPC relationships, consequences
- **World State**: Economy state, faction reputation, major events timeline
- **Mission Pool**: Generates random hybrid missions on demand
- **Hybrid Mission Format**: Static structure + AI-generated narrative text

**API Endpoints:**
- POST /api/story/generate_narrative - Generate contextual stage descriptions
- POST /api/story/generate_outcome - Generate consequence text
- GET /api/story/mission_pool - Get random mission
- GET /api/story/memory/{player_id} - Retrieve player memory
- GET /api/story/world_context - Get world state

**Features:**
- Context-aware narrative generation
- Player choice tracking
- Relationship system (NPCs, factions)
- Graceful fallback to static content
- 1-hour cache TTL (Redis)

**Docs:**
- [docs/05-ai-content/dynamic-story-engine.md](docs/05-ai-content/dynamic-story-engine.md)
- [docs/06-technical-reference/MEMORY-MANAGER-REFERENCE.md](docs/06-technical-reference/MEMORY-MANAGER-REFERENCE.md)

### Hybrid Economy System

**Two-currency model: Credits (earned) + Parts (discovered)**

**Components:**
- **PartRegistry Singleton** (720+ lines, 30+ methods): Data-driven parts/systems/economy
- **39 Parts Defined**: 5 systems × 3 rarity tiers (common/uncommon/rare)
- **JSON Data Files**: parts/*.json, systems/ship_systems.json, economy/economy_config.json
- **Story-Driven Unlocks**: Parts discovered through mission rewards

**Features:**
- Credits system (add, spend, can_afford validation)
- Skill points allocation (4 skills: engineering, diplomacy, combat, science)
- Enhanced inventory (stacking, weight limits, capacity)
- XP/leveling with PartRegistry integration
- Ship upgrades consume credits + parts (no more free upgrades)
- Transaction rollback on failure
- O(1) lookup performance

**UI Integration:**
- Player status panel (credits, level, XP bar, skill points button)
- Upgrade cost display with resource validation
- Inventory popup (800x600) - shows parts, rarity, weight, quantity
- Skill allocation popup (600x500)
- Real-time updates via EventBus (55+ signals)

**Docs:**
- [docs/02-developer-guides/systems/PART-REGISTRY-ARCHITECTURE.md](docs/02-developer-guides/systems/PART-REGISTRY-ARCHITECTURE.md)
- [docs/06-technical-reference/PART-REGISTRY-API-REFERENCE.md](docs/06-technical-reference/PART-REGISTRY-API-REFERENCE.md)

### Advanced Networking

**Gateway fallback with concurrency control and retry logic**

**Features:**
- Primary: Gateway (17010) → Routes to services
- Fallback: Direct connection to services (17011-17014)
- Automatic failover on gateway errors
- Concurrency control (max 2 concurrent requests)
- Request queue with priority handling
- Exponential backoff retry (3 attempts: 1s, 2s, 4s)
- Service health checking
- Error handling and graceful degradation

**Ports (NCC-1701 System):**
- 17010: Gateway
- 17011: AI Service
- 17012: Whisper (optional)
- 17014: Redis

**Implementation:** `godot/scripts/autoload/service_manager.gd` and `godot/scripts/autoload/story_service.gd`

## Reference Links

- [Godot 4.2 Docs](https://docs.godotengine.org/en/stable/)
- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [LangChain Docs](https://python.langchain.com/)
- [Pydantic Docs](https://docs.pydantic.dev/)

---

**Remember:** This is a hobby/learning project. Milestones not timelines. Progress over perfection. Test thoroughly at each milestone. The "Is it fun?" decision matters more than feature count.
