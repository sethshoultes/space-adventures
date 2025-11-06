# Godot Game Client

**Purpose:** Game client built with Godot Engine 4.2+
**Parent:** [../CLAUDE.md](../CLAUDE.md)
**Design Docs:** [Technical Architecture](../docs/technical-architecture.md), [Game Design Document](../docs/game-design-document.md)

## Overview

The Godot game client handles all player-facing functionality: UI, game logic, input handling, and rendering. It communicates with backend services via HTTP REST APIs for AI-generated content, voice transcription, and other features.

The client uses a singleton (autoload) pattern for global systems and follows scene-based organization for UI components.

**Engine:** Godot 4.2+
**Language:** GDScript
**Resolution:** 1920x1080 (windowed/fullscreen)

## Project Structure

```
godot/
├── CLAUDE.md                # This file
├── project.godot            # Godot project configuration
├── icon.svg                 # Project icon
├── .gitignore              # Git ignore for Godot files
├── scenes/                  # All game scenes (.tscn files)
│   ├── main_menu.tscn      # Main menu (future)
│   ├── workshop.tscn       # Phase 1 workshop hub (future)
│   ├── mission_select.tscn # Mission selection (future)
│   └── mission_play.tscn   # Mission gameplay (future)
├── scripts/                 # All GDScript code
│   ├── autoload/           # Singleton scripts (always loaded)
│   │   ├── game_state.gd   # Global game state
│   │   ├── save_manager.gd # Save/load system
│   │   ├── service_manager.gd # Backend service connections
│   │   ├── ai_service.gd   # HTTP client for AI service
│   │   └── event_bus.gd    # Decoupled event system
│   ├── systems/            # Ship system classes (future)
│   │   └── ship_system.gd  # Base class for all ship systems
│   ├── ui/                 # UI component scripts (future)
│   └── utils/              # Utility functions (future)
├── assets/                  # Game assets
│   ├── data/               # JSON data files
│   │   └── missions/       # Mission JSON files (future)
│   ├── sprites/            # Images (future)
│   └── fonts/              # Typography (future)
└── saves/                   # Player save files (gitignored)
    └── .gitkeep
```

## Key Singletons (Autoload)

Registered in `project.godot` under `[autoload]` section. These are global and always available.

### GameState
**File:** `scripts/autoload/game_state.gd`
**Purpose:** Global game state - player, ship, inventory, progress

**Structure:**
```gdscript
var player = {
    "name": "Player",
    "level": 1,
    "xp": 0,
    "rank": "Cadet",
    "skills": {"engineering": 0, "diplomacy": 0, "combat": 0, "science": 0}
}

var ship = {
    "name": "Unnamed Vessel",
    "ship_class": "None",
    "systems": {}, # 10 ship systems
    "hull_hp": 0,
    "max_hull_hp": 0,
    "power_available": 0,
    "power_total": 0
}

var inventory = []  # Player + ship storage
var progress = {
    "phase": 1,  # 1=Earthbound, 2=Space
    "completed_missions": [],
    "discovered_locations": [],
    "major_choices": []
}
```

### SaveManager
**File:** `scripts/autoload/save_manager.gd`
**Purpose:** Save and load game state to JSON files

**Methods:**
- `save_game(slot: int)` - Save current game to slot
- `load_game(slot: int) -> bool` - Load game from slot
- `delete_save(slot: int)` - Delete save file
- `get_save_info(slot: int) -> Dictionary` - Get save metadata

### ServiceManager
**File:** `scripts/autoload/service_manager.gd`
**Purpose:** Manage backend service connections and availability

**Methods:**
- `check_all_services() -> Dictionary` - Health check all services
- `is_service_available(service: String) -> bool` - Check if service is up
- `get_service_url(service: String) -> String` - Get service base URL

**Service Names:**
- `"gateway"` - http://localhost:8000
- `"ai"` - http://localhost:8001
- `"whisper"` - http://localhost:8002

### AIService
**File:** `scripts/autoload/ai_service.gd`
**Purpose:** HTTP client for AI service (through gateway)

**Methods:**
```gdscript
func generate_mission(difficulty: String, mission_type: String = "") -> Dictionary
func chat_message(message: String, ai_personality: String = "atlas") -> Dictionary
func check_spontaneous_event() -> Dictionary
```

**Returns:** Dictionary with `success: bool`, `data: Variant`, `error: String`

### EventBus
**File:** `scripts/autoload/event_bus.gd`
**Purpose:** Decoupled event system for inter-component communication

**Signals:**
```gdscript
signal mission_completed(mission_id: String, rewards: Dictionary)
signal system_installed(system_name: String, level: int)
signal ship_class_changed(old_class: String, new_class: String)
signal xp_gained(amount: int)
signal level_up(new_level: int)
signal chat_message_received(ai_name: String, message: String)
```

## Development Guidelines

### GDScript Style

**Naming Conventions:**
- `snake_case` for variables and functions
- `PascalCase` for classes
- `SCREAMING_CASE` for constants
- Private members prefix with `_`

**Type Hints (always use):**
```gdscript
var health: int = 100
var name: String = "Player"
var items: Array = []

func calculate_damage(amount: int) -> int:
    return amount * 2
```

**Indentation:** Tabs (Godot standard)

**Example Structure:**
```gdscript
extends Node
class_name MyClass

## Documentation comment
## Explain purpose and usage

# Constants
const MAX_VALUE: int = 100

# Exported variables (editor-configurable)
@export var property_name: int = 10

# Public variables
var public_var: String = ""

# Private variables
var _private_var: bool = false

# Lifecycle methods
func _ready() -> void:
    # Initialization
    pass

func _process(delta: float) -> void:
    # Per-frame update
    pass

# Public methods
func public_function(param: int) -> int:
    """Function documentation"""
    return param * 2

# Private methods
func _private_function() -> void:
    # Helper function
    pass
```

### Service Integration

**Checking Service Availability:**
```gdscript
if ServiceManager.is_service_available("ai"):
    var result = await AIService.generate_mission("medium")
    if result.success:
        display_mission(result.data)
    else:
        show_error(result.error)
else:
    # Fallback: use static content
    var mission = load_static_mission()
    display_mission(mission)
```

**Error Handling:**
```gdscript
var result = await AIService.chat_message(message, "atlas")
if result.has("error") or not result.success:
    show_error_dialog("AI service unavailable")
else:
    display_ai_response(result.data.message)
```

### Adding New Scene

1. Create scene in `scenes/`
2. Build scene hierarchy
3. Save as `scenes/my_scene.tscn`
4. Attach script: `scripts/ui/my_scene.gd`
5. Implement scene logic

### Adding New Autoload

1. Create script in `scripts/autoload/`
2. Implement singleton pattern
3. Register in `project.godot`:
```ini
[autoload]
MyService="*res://scripts/autoload/my_service.gd"
```

## Input Actions

Defined in `project.godot`:

- `save_game` - S key - Manual save
- `open_chat` - C key - Open AI chat overlay
- `voice_input` - V key - Push-to-talk voice input
- Standard UI navigation (arrow keys, enter, escape)

## Common Tasks

### Run Game
```bash
# From command line
godot godot/project.godot

# In Godot Editor
# F5 - Run project
# F6 - Run current scene
# Ctrl+S - Save scene/script
```

### Test Scene Individually
```bash
# Open scene in editor, press F6
```

### Check for Errors
```bash
# Look in Godot console (bottom panel)
# Red = Errors (must fix)
# Yellow = Warnings (should fix)
```

### Debug Print
```gdscript
print("Debug message")
print("Value:", my_variable)
push_warning("Warning message")
push_error("Error message")
```

## Service Communication Flow

```
User Input
    ↓
Godot Scene
    ↓
ServiceManager.check_service("ai")
    ↓
AIService.generate_mission()
    ↓
HTTP Request → Gateway (8000) → AI Service (8001)
    ↓
Response (JSON)
    ↓
Parse result
    ↓
Update GameState
    ↓
Emit EventBus signal
    ↓
UI updates
    ↓
Optional: SaveManager.save_game()
```

## Testing

**Manual Testing:**
1. Open scene in editor (double-click .tscn)
2. Press F6 to run current scene
3. Press F5 to run full game
4. Check console for errors

**Test Checklist:**
- [ ] All UI elements clickable
- [ ] Scene transitions work
- [ ] Save/load functional
- [ ] Service communication works
- [ ] No console errors/warnings
- [ ] Inputs responsive

## Troubleshooting

### Scene Won't Load
- Check file path correct
- Check dependencies loaded
- Look for errors in console

### Script Errors
- Red errors in console - syntax errors
- Check type hints match
- Check function signatures

### Service Connection Fails
```bash
# Check services running
docker-compose ps

# Test service directly
curl http://localhost:8000/health
```

### Save File Issues
- Check `saves/` directory exists
- Check file permissions
- Look for JSON parse errors in console

## Design Reference

See:
- [Game Design Document](../docs/game-design-document.md)
- [Technical Architecture](../docs/technical-architecture.md)
- [Ship Systems](../docs/ship-systems.md)
- [Mission Framework](../docs/mission-framework.md)
- [Player Progression](../docs/player-progression-system.md)

## Next Steps

**Current:** Phase 1, Week 1 ✅ Complete

**Week 3 (Godot Foundation):**
- Implement autoload singletons
- Create main menu scene
- Implement ServiceManager
- Implement GameState
- Implement SaveManager
- Basic UI theme

See [Development Organization](../docs/development-organization.md) for full plan.

## Change Log

### 2025-11-05
- Created Godot project structure
- Initialized project.godot with autoload configuration
- Set up directory structure
- Created .gitignore for Godot files
