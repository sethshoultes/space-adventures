# Godot Game Development Lessons

**Lessons learned while building the Godot frontend for Space Adventures.**

---

## 2024-11-05: Autoload Singletons - Keep Data and Logic Separate

**Context:** Designing the 5 core autoload singletons (GameState, SaveManager, ServiceManager, AIService, EventBus).

**Problem:** Initial design had GameState handling both data storage AND game logic (calculating power, managing upgrades, etc.), violating Single Responsibility Principle.

**Solution:** Separate data from logic across multiple singletons:

**GameState (Data Only):**
```gdscript
# autoload/game_state.gd
extends Node

var player: Dictionary = {
    "name": "Player",
    "level": 1,
    "xp": 0
}

var ship: Dictionary = {
    "name": "Unnamed Vessel",
    "systems": {},
    "hull_hp": 0,
    "power_available": 0
}

# NO logic methods here, just data storage
func to_dict() -> Dictionary:
    return {"player": player, "ship": ship}
```

**SaveManager (Persistence Logic):**
```gdscript
# autoload/save_manager.gd
extends Node

func save_game(slot: int) -> bool:
    var data = GameState.to_dict()
    var path = get_save_path(slot)
    # Save logic here
```

**Why This Matters:**
- Single Responsibility Principle (GameState = data, SaveManager = persistence)
- Easier to test (mock GameState without affecting logic)
- Clear separation of concerns
- Other scripts know where to find data (GameState) vs functionality (managers)

**Pattern to Follow:**
- **GameState** = Dictionary with nested data, no logic
- **Managers** = Logic and operations on GameState data
- **EventBus** = Communication between managers

**Resources:**
- SOLID principles in GDScript
- Godot singleton patterns: https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

**Related Patterns:** SOLID principles, event-driven architecture

---

## 2024-11-05: EventBus Pattern - Decoupling Components

**Context:** Building Workshop UI that needs to update when ship systems change. Initially used direct references between components.

**Problem:** Direct references create tight coupling. If Workshop needs system status, and Mission Manager updates systems, they both need to know about each other. Hard to maintain and extend.

**Solution:** EventBus singleton with signals for decoupled communication:

```gdscript
# autoload/event_bus.gd
extends Node

# Ship systems
signal system_upgraded(system_name: String, new_level: int)
signal system_damaged(system_name: String, damage: int)
signal hull_repaired(amount: int)

# Missions
signal mission_started(mission_id: String)
signal mission_completed(mission_id: String, rewards: Dictionary)

# Player
signal xp_gained(amount: int)
signal level_up(new_level: int)

# Resources
signal resources_changed(new_amount: int, delta: int)
```

**Usage:**
```gdscript
# In system upgrade logic
EventBus.system_upgraded.emit("hull", 2)

# In Workshop UI (listens for changes)
func _ready():
    EventBus.system_upgraded.connect(_on_system_upgraded)

func _on_system_upgraded(system_name: String, new_level: int):
    update_ui_for_system(system_name, new_level)
```

**Why This Matters:**
- Components don't need references to each other
- Easy to add new listeners without modifying emitters
- Clear communication contracts (signals document what events exist)
- Easier testing (mock EventBus for isolated tests)

**Best Practices:**
- Group related signals (ship, player, missions, etc.)
- Use descriptive signal names (past tense: `system_upgraded` not `upgrade_system`)
- Include relevant data in signal parameters
- Document signals at top of EventBus script

**Gotchas:**
- Don't forget to disconnect signals in `_exit_tree()` (memory leaks)
- Too many signals can be overwhelming (group by category)
- Signals fire immediately (not deferred unless explicitly done)

**Resources:**
- Godot signals: https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html

**Related Patterns:** Observer pattern, publish-subscribe, event-driven architecture

---

## 2024-11-05: HTTPRequest for Async API Calls

**Context:** Godot needs to call Python AI service without blocking game thread.

**Problem:** If HTTP request blocks main thread, entire game freezes during AI generation (1-3 seconds minimum, up to 60s for Ollama). Unacceptable user experience.

**Solution:** Use HTTPRequest node with signal-based async pattern:

```gdscript
# autoload/ai_service.gd
extends Node

var http: HTTPRequest

func _ready():
    http = HTTPRequest.new()
    add_child(http)
    http.request_completed.connect(_on_request_completed)

func generate_mission(difficulty: int, mission_type: String) -> void:
    var url = "http://localhost:17011/api/missions/generate"
    var body = JSON.stringify({
        "difficulty": difficulty,
        "mission_type": mission_type,
        "player_level": GameState.player.level
    })
    var headers = ["Content-Type: application/json"]

    # Show loading indicator
    EventBus.loading_started.emit("Generating mission...")

    # Non-blocking request
    var error = http.request(url, headers, HTTPClient.METHOD_POST, body)
    if error != OK:
        push_error("HTTP request failed: " + str(error))

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
    EventBus.loading_finished.emit()

    if response_code != 200:
        push_error("Server returned error: " + str(response_code))
        EventBus.mission_generation_failed.emit()
        return

    var json = JSON.parse_string(body.get_string_from_utf8())
    if json == null:
        push_error("Failed to parse response JSON")
        return

    # Emit success with data
    EventBus.mission_generated.emit(json)
```

**Why This Matters:**
- Game stays responsive during slow operations
- User sees loading indicator (not frozen screen)
- Error handling without crashing game
- Professional UX (async is expected for network operations)

**Best Practices:**
- Always show loading indicator during requests
- Handle all error cases (network failure, non-200 response, invalid JSON)
- Use EventBus to notify when request completes
- Timeout long requests (set on HTTPRequest node)

**Gotchas:**
- `request_completed` signal fires even on failure (check response_code)
- JSON parsing can fail (always null-check)
- Don't forget to show/hide loading indicators
- HTTPRequest nodes should be added as children (add_child)

**Resources:**
- Godot HTTPRequest: https://docs.godotengine.org/en/stable/classes/class_httprequest.html
- JSON in Godot: https://docs.godotengine.org/en/stable/classes/class_json.html

**Related Patterns:** Async programming, loading state management, error handling

---

## Template for New Lessons

```markdown
## [Date]: [Lesson Title]

**Context:** [What were you building?]

**Problem:** [What challenge did you face?]

**Solution:** [How did you solve it?]

**Code Example:**
```gdscript
# Show the pattern with actual code
```

**Why This Matters:** [Why should future-you care?]

**Best Practices:** [Tips for using this pattern correctly]

**Gotchas:** [Things that might trip you up]

**Resources:** [Links to Godot docs, tutorials, etc.]

**Related Patterns:** [Cross-references]
```

---

## Topics to Document (As We Learn)

**Autoload & Singletons:**
- [ ] Initialization order of autoload scripts
- [ ] When to use autoload vs scene-based managers
- [ ] Memory management with singletons
- [ ] Testing strategies for autoloaded scripts

**Signals & Events:**
- [ ] When to use signals vs direct method calls
- [ ] Signal parameter best practices
- [ ] Memory leaks with signal connections
- [ ] Signal performance considerations

**Save/Load System:**
- [ ] JSON vs binary save formats
- [ ] Save file versioning and migration
- [ ] Handling corrupted saves
- [ ] Auto-save strategies

**UI Patterns:**
- [ ] UI update patterns (polling vs event-driven)
- [ ] Loading indicators and progress bars
- [ ] Error message display strategies
- [ ] Accessibility considerations

**Performance:**
- [ ] When to use @onready vs _ready()
- [ ] Node pooling for repeated instantiation
- [ ] Signal vs method call performance
- [ ] Type hints impact on performance

**GDScript Patterns:**
- [ ] Type hint best practices
- [ ] Error handling patterns (push_error vs exceptions)
- [ ] Dictionary vs custom classes (when to use each)
- [ ] Static typing for performance

---

**AI Agent:** Add lessons here as you discover Godot patterns and anti-patterns. Focus on problems specific to this game's architecture.
