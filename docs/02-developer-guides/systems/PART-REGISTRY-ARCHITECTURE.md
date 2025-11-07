# PartRegistry Architecture

**Version:** 1.0
**Date:** 2025-11-07
**Purpose:** Design specification for PartRegistry singleton
**Milestone:** Milestone 1

---

## Table of Contents
1. [Overview](#overview)
2. [Architecture Design](#architecture-design)
3. [API Specification](#api-specification)
4. [Data Structures](#data-structures)
5. [Loading Strategy](#loading-strategy)
6. [Caching Strategy](#caching-strategy)
7. [Integration Points](#integration-points)
8. [Error Handling](#error-handling)
9. [Code Structure](#code-structure)

---

## Overview

### Purpose

The **PartRegistry** singleton is the central data authority for:
- Ship part definitions (50+ parts across 10 systems)
- System upgrade costs and requirements
- Economy configuration (XP curve, skill points, costs)
- Part discovery state (story unlocks)

### Design Goals

1. **Single Source of Truth:** All game balance data in JSON files
2. **Fast Lookups:** O(1) dictionary access for all queries
3. **Data Validation:** Catch errors at load time, not runtime
4. **Easy Maintenance:** Add new parts without code changes
5. **Clear API:** Simple, consistent interface for all consumers

### Consumers

- **Workshop UI:** Display parts, costs, requirements
- **Ship Systems:** Check upgrade requirements, consume parts
- **MissionManager:** Award parts, unlock discoveries
- **GameState:** Validate inventory, calculate capacity
- **AI Service:** Generate part recommendations

---

## Architecture Design

### Singleton Pattern (Godot Autoload)

```
PartRegistry (Autoload)
    ↓ (loads on startup)
    ↓
JSON Data Files
    ↓ (parsed and cached)
    ↓
In-Memory Dictionaries
    ↓ (queried by)
    ↓
Game Systems
```

### File Organization

```
godot/scripts/autoload/part_registry.gd  (main singleton)
godot/assets/data/
    ├── parts/*.json           (loaded into _parts_cache)
    ├── systems/ship_systems.json   (loaded into _systems_config)
    └── economy/economy_config.json (loaded into _economy_config)
```

---

## API Specification

### Core Part Queries

#### `get_part(part_id: String) -> Dictionary`
Get complete part definition by ID.

**Parameters:**
- `part_id`: Unique part identifier (e.g., "hull_scrap_plates_l1_common")

**Returns:**
- Dictionary with part data (see DATA-SCHEMA-SPECIFICATIONS.md)
- Empty dictionary {} if not found

**Example:**
```gdscript
var part = PartRegistry.get_part("hull_scrap_plates_l1_common")
if not part.is_empty():
    print(part.name)  # "Scrap Hull Plates"
    print(part.stats.max_hp)  # 50
```

**Performance:** O(1) dictionary lookup

---

#### `get_parts_for_system(system_name: String, level: int) -> Array`
Get all parts compatible with a system at a specific level.

**Parameters:**
- `system_name`: System identifier ("hull", "power", etc.)
- `level`: Target level (1-5)

**Returns:**
- Array of part dictionaries
- Empty array [] if no parts found
- Sorted by rarity (common → uncommon → rare)

**Example:**
```gdscript
var hull_parts = PartRegistry.get_parts_for_system("hull", 1)
for part in hull_parts:
    print("%s (%s)" % [part.name, part.rarity])
# Output:
# Scrap Hull Plates (common)
# Reinforced Hull Plates (uncommon)
# Composite Armor Plating (rare)
```

**Performance:** O(n) filter where n = parts for that system (typically 5-10)

---

#### `get_parts_by_rarity(rarity: String) -> Array`
Get all parts of a specific rarity tier.

**Parameters:**
- `rarity`: "common", "uncommon", or "rare"

**Returns:**
- Array of part dictionaries
- Empty array [] if invalid rarity

**Example:**
```gdscript
var rare_parts = PartRegistry.get_parts_by_rarity("rare")
print("Found %d rare parts" % rare_parts.size())
```

**Performance:** O(n) filter where n = total parts

---

#### `get_all_parts() -> Dictionary`
Get all loaded parts organized by system type.

**Returns:**
- Dictionary: `{system_name: [parts...]}`

**Example:**
```gdscript
var all_parts = PartRegistry.get_all_parts()
for system_name in all_parts:
    print("%s: %d parts" % [system_name, all_parts[system_name].size()])
```

**Performance:** O(1) return cached structure

---

### Part Discovery

#### `is_part_unlocked(part_id: String) -> bool`
Check if a part has been discovered by the player.

**Parameters:**
- `part_id`: Part to check

**Returns:**
- `true` if part is discovered or starts unlocked (`discovered: true` in JSON)
- `false` if still locked

**Example:**
```gdscript
if PartRegistry.is_part_unlocked("hull_composite_armor_l1_rare"):
    # Show in shop
else:
    # Show as "???"
```

**Performance:** O(1) dictionary lookup

---

#### `discover_part(part_id: String) -> void`
Unlock a part for the player (story progression).

**Parameters:**
- `part_id`: Part to unlock

**Side Effects:**
- Adds to discovered parts list
- Saves to GameState.progress.discovered_parts
- Emits EventBus.part_discovered signal

**Example:**
```gdscript
# In MissionManager after mission complete:
PartRegistry.discover_part("warp_basic_core_l1_common")
# Player can now see and acquire this part
```

**Performance:** O(1) set operation

---

#### `get_discovered_parts() -> Array`
Get list of all discovered part IDs.

**Returns:**
- Array of part ID strings

**Example:**
```gdscript
var discovered = PartRegistry.get_discovered_parts()
print("Discovered %d parts" % discovered.size())
```

**Performance:** O(1) return cached array

---

### Upgrade Cost Queries

#### `get_upgrade_cost(system_name: String, target_level: int, part_id: String) -> Dictionary`
Calculate the cost to upgrade a system using a specific part.

**Parameters:**
- `system_name`: System to upgrade ("hull", "power", etc.)
- `target_level`: Desired level (1-5)
- `part_id`: Specific part to use (optional, uses cheapest common if empty)

**Returns:**
```gdscript
{
    "credits": 100,
    "part_id": "hull_scrap_plates_l1_common",
    "part_name": "Scrap Hull Plates",
    "rarity": "common",
    "affordable": true,     # Player has enough credits
    "have_part": true       # Part is in inventory
}
```

**Example:**
```gdscript
var cost = PartRegistry.get_upgrade_cost("hull", 1, "")
if cost.affordable and cost.have_part:
    # Enable upgrade button
    button.text = "UPGRADE TO L1\n(%d CR + %s)" % [cost.credits, cost.part_name]
else:
    button.disabled = true
```

**Performance:** O(1) lookup + O(1) GameState queries

---

#### `get_base_upgrade_cost(system_name: String, target_level: int) -> Dictionary`
Get base upgrade cost from configuration (no rarity multiplier).

**Parameters:**
- `system_name`: System identifier
- `target_level`: Target level

**Returns:**
```gdscript
{
    "credits": 100,
    "rarity_required": "common"
}
```

**Performance:** O(1) dictionary lookup

---

### System Configuration

#### `get_system_config(system_name: String) -> Dictionary`
Get complete configuration for a system.

**Returns:**
```gdscript
{
    "system_name": "hull",
    "display_name": "Hull & Structure",
    "description": "...",
    "max_level": 5,
    "milestone_1_max_level": 3,
    "compatible_parts": [...],
    "power_costs": [0, 0, 0, 0, 10],
    "base_upgrade_costs": {...}
}
```

**Example:**
```gdscript
var config = PartRegistry.get_system_config("hull")
print(config.display_name)  # "Hull & Structure"
print(config.power_costs[2])  # Power cost at level 3 (index 2)
```

**Performance:** O(1) dictionary lookup

---

#### `get_power_cost(system_name: String, level: int) -> int`
Get power consumption for a system at a specific level.

**Parameters:**
- `system_name`: System identifier
- `level`: System level (1-5)

**Returns:**
- Power cost in PU
- 0 if invalid system/level

**Example:**
```gdscript
var power = PartRegistry.get_power_cost("shields", 3)
print("Shields L3 consume %d PU" % power)  # 40 PU
```

**Performance:** O(1) array access

---

### Economy Configuration

#### `get_xp_for_level(level: int) -> int`
Get total XP required to reach a level.

**Parameters:**
- `level`: Target level (1-5 for Milestone 1)

**Returns:**
- Total XP required
- 0 for level 1

**Example:**
```gdscript
var xp_needed = PartRegistry.get_xp_for_level(3)
print("Level 3 requires %d XP" % xp_needed)  # 250 XP
```

**Performance:** O(1) array access

---

#### `get_xp_curve() -> Array`
Get complete XP curve.

**Returns:**
- Array: [0, 100, 250, 450, 700, 1000]

**Example:**
```gdscript
var curve = PartRegistry.get_xp_curve()
for i in curve.size():
    print("Level %d: %d XP" % [i + 1, curve[i]])
```

**Performance:** O(1) return cached array

---

#### `get_skill_points_per_level() -> int`
Get number of skill points awarded per level up.

**Returns:**
- Integer (default: 2)

**Performance:** O(1) return cached value

---

#### `get_inventory_capacity_formula() -> String`
Get formula for calculating inventory capacity.

**Returns:**
- String: "100 + (50 * hull_level)"

**Performance:** O(1) return cached string

---

#### `calculate_inventory_capacity(hull_level: int) -> float`
Calculate inventory capacity for a hull level.

**Parameters:**
- `hull_level`: Current hull system level

**Returns:**
- Capacity in kg

**Example:**
```gdscript
var capacity = PartRegistry.calculate_inventory_capacity(2)
print("Capacity: %.1f kg" % capacity)  # 200.0 kg
```

**Performance:** O(1) simple calculation

---

### Validation

#### `validate_part_id(part_id: String) -> bool`
Check if a part ID exists.

**Parameters:**
- `part_id`: Part to validate

**Returns:**
- `true` if part exists
- `false` if not found

**Example:**
```gdscript
if PartRegistry.validate_part_id(reward_part_id):
    GameState.add_item(PartRegistry.get_part(reward_part_id))
else:
    push_error("Invalid part ID in mission: " + reward_part_id)
```

**Performance:** O(1) dictionary lookup

---

## Data Structures

### Internal Caches

```gdscript
# Part data indexed by part_id
var _parts_cache: Dictionary = {}
# Example: {"hull_scrap_plates_l1_common": {...}, ...}

# Parts organized by system type
var _parts_by_system: Dictionary = {}
# Example: {"hull": [part1, part2, ...], "power": [...], ...}

# Parts organized by rarity
var _parts_by_rarity: Dictionary = {
    "common": [],
    "uncommon": [],
    "rare": []
}

# System configurations
var _systems_config: Dictionary = {}
# Example: {"hull": {...config...}, "power": {...}, ...}

# Economy configuration
var _economy_config: Dictionary = {}

# Discovered parts (player progression)
var _discovered_parts: Dictionary = {}
# Example: {"hull_scrap_plates_l1_common": true, ...}

# Loading state
var _is_loaded: bool = false
var _load_error: bool = false
```

---

## Loading Strategy

### Startup Load (Eager)

Load all data in `_ready()` before any game systems initialize.

**Advantages:**
- Simple implementation
- No lazy loading complexity
- Guaranteed data availability
- Fast lookups after load

**Disadvantages:**
- Slight startup delay (~50-100ms for 50+ parts)
- Loads unused data (acceptable for small dataset)

**Load Order:**
1. Economy config (foundational rules)
2. System config (system definitions)
3. All part files (bulk data)
4. Discovered parts from GameState (player progress)
5. Build caches and indexes

### Load Sequence

```gdscript
func _ready() -> void:
    print("PartRegistry: Loading data...")

    # Load configurations
    if not _load_economy_config():
        _load_error = true
        return

    if not _load_system_config():
        _load_error = true
        return

    # Load all part files
    var part_files = _get_part_files()
    for file_path in part_files:
        if not _load_part_file(file_path):
            push_error("Failed to load: " + file_path)
            # Continue loading other files

    # Build indexes
    _build_part_indexes()

    # Load player progress
    _load_discovered_parts()

    _is_loaded = true
    print("PartRegistry: Loaded %d parts from %d systems" % [
        _parts_cache.size(),
        _parts_by_system.size()
    ])
```

---

## Caching Strategy

### Cache Types

**1. Primary Cache (_parts_cache)**
- Key: part_id (String)
- Value: Complete part dictionary
- Purpose: Fast O(1) lookup by ID

**2. System Index (_parts_by_system)**
- Key: system_name (String)
- Value: Array of part references
- Purpose: Filter parts by system

**3. Rarity Index (_parts_by_rarity)**
- Key: rarity (String)
- Value: Array of part references
- Purpose: Filter parts by rarity

**4. Discovery Cache (_discovered_parts)**
- Key: part_id (String)
- Value: bool (true if discovered)
- Purpose: Fast unlock checks

### Cache Invalidation

**Never invalidated** - data is static after load.

**Exception:** Discovery cache updates when parts are unlocked.

### Memory Footprint

**Estimated size:**
- 50 parts × ~500 bytes/part = ~25 KB
- Indexes: ~5 KB
- Total: ~30 KB (negligible for modern systems)

---

## Integration Points

### With GameState

**Reads:**
- `GameState.get_credits()` - Check affordability
- `GameState.get_part_count(part_id)` - Check inventory
- `GameState.ship.systems[system].level` - Current system level
- `GameState.progress.discovered_parts` - Load discoveries

**Writes:**
- `GameState.progress.discovered_parts` - Save discoveries

**Example:**
```gdscript
func get_upgrade_cost(system_name: String, target_level: int, part_id: String) -> Dictionary:
    var cost = get_base_upgrade_cost(system_name, target_level)
    var part = get_part(part_id)

    return {
        "credits": cost.credits,
        "part_id": part_id,
        "part_name": part.name,
        "rarity": part.rarity,
        "affordable": GameState.get_credits() >= cost.credits,
        "have_part": GameState.get_part_count(part_id) > 0
    }
```

---

### With Workshop UI

**Workshop queries PartRegistry for:**
- Available parts for each system
- Upgrade costs and requirements
- Part stats and descriptions
- Discovery status (show locked parts as "???")

**Example:**
```gdscript
# In workshop.gd
func _update_hull_system_display() -> void:
    var hull_level = GameState.ship.systems.hull.level
    var available_parts = PartRegistry.get_parts_for_system("hull", hull_level + 1)

    for part in available_parts:
        if PartRegistry.is_part_unlocked(part.id):
            _add_part_button(part)
        else:
            _add_locked_part_placeholder()
```

---

### With MissionManager

**MissionManager calls PartRegistry to:**
- Award parts as mission rewards
- Unlock parts (story progression)
- Validate reward part IDs

**Example:**
```gdscript
# In mission_manager.gd
func _award_mission_rewards(rewards: Dictionary) -> void:
    # Award credits
    if rewards.has("credits"):
        GameState.add_credits(rewards.credits)

    # Award parts
    if rewards.has("parts"):
        for part_data in rewards.parts:
            var part = PartRegistry.get_part(part_data.part_id)
            if not part.is_empty():
                GameState.add_item(part)

    # Unlock discoveries
    if rewards.has("story_unlocks"):
        for part_id in rewards.story_unlocks:
            PartRegistry.discover_part(part_id)
```

---

### With Ship Systems

**Ship system classes query PartRegistry for:**
- Upgrade requirements
- Power consumption
- Compatible parts

**Example:**
```gdscript
# In hull_system.gd
func can_upgrade() -> bool:
    if level >= max_level:
        return false

    var cost = PartRegistry.get_upgrade_cost("hull", level + 1, "")
    return cost.affordable and cost.have_part
```

---

## Error Handling

### Load-Time Errors

**Missing File:**
```gdscript
if not FileAccess.file_exists(file_path):
    push_error("PartRegistry: File not found: " + file_path)
    return false
```

**JSON Parse Error:**
```gdscript
var error = json.parse(json_text)
if error != OK:
    push_error("PartRegistry: JSON parse error in %s: %s" % [
        file_path,
        json.get_error_message()
    ])
    return false
```

**Invalid Schema:**
```gdscript
if not data.has("parts"):
    push_error("PartRegistry: Invalid schema in " + file_path)
    return false
```

**Duplicate Part ID:**
```gdscript
if _parts_cache.has(part.id):
    push_error("PartRegistry: Duplicate part ID: " + part.id)
    # Overwrite with warning, or skip?
```

---

### Runtime Errors

**Invalid Part ID:**
```gdscript
func get_part(part_id: String) -> Dictionary:
    if not _parts_cache.has(part_id):
        push_warning("PartRegistry: Part not found: " + part_id)
        return {}  # Return empty dict, not null
    return _parts_cache[part_id]
```

**Invalid System Name:**
```gdscript
func get_system_config(system_name: String) -> Dictionary:
    if not _systems_config.has(system_name):
        push_error("PartRegistry: Unknown system: " + system_name)
        return {}
    return _systems_config[system_name]
```

**Not Loaded:**
```gdscript
func _check_loaded() -> bool:
    if not _is_loaded:
        push_error("PartRegistry: Data not loaded yet!")
        return false
    if _load_error:
        push_error("PartRegistry: Load failed, cannot query data")
        return false
    return true
```

---

## Code Structure

### File: `godot/scripts/autoload/part_registry.gd`

```gdscript
extends Node

## PartRegistry Singleton
## Central data authority for ship parts, upgrade costs, and economy config
## Load order: Economy config → System config → Part files → Indexes

# ============================================================================
# CONSTANTS
# ============================================================================

const DATA_PATH = "res://assets/data/"
const PARTS_PATH = DATA_PATH + "parts/"
const SYSTEMS_PATH = DATA_PATH + "systems/"
const ECONOMY_PATH = DATA_PATH + "economy/"

const PART_FILES = [
    "hull_parts.json",
    "power_parts.json",
    "propulsion_parts.json",
    "warp_parts.json",
    "life_support_parts.json",
    "computer_parts.json",
    "sensors_parts.json",
    "shields_parts.json",
    "weapons_parts.json",
    "communications_parts.json"
]

# ============================================================================
# STATE
# ============================================================================

var _parts_cache: Dictionary = {}
var _parts_by_system: Dictionary = {}
var _parts_by_rarity: Dictionary = {"common": [], "uncommon": [], "rare": []}
var _systems_config: Dictionary = {}
var _economy_config: Dictionary = {}
var _discovered_parts: Dictionary = {}
var _is_loaded: bool = false
var _load_error: bool = false

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
    print("PartRegistry: Initializing...")
    _load_all_data()

# ============================================================================
# LOADING
# ============================================================================

func _load_all_data() -> void:
    # Load economy config
    if not _load_economy_config():
        _load_error = true
        return

    # Load system config
    if not _load_system_config():
        _load_error = true
        return

    # Load all part files
    for file_name in PART_FILES:
        var file_path = PARTS_PATH + file_name
        if not _load_part_file(file_path):
            push_warning("PartRegistry: Failed to load " + file_name)

    # Build indexes
    _build_part_indexes()

    # Load discovered parts from GameState
    _load_discovered_parts()

    _is_loaded = true
    print("PartRegistry: Loaded %d parts from %d systems" % [
        _parts_cache.size(),
        _parts_by_system.size()
    ])

func _load_economy_config() -> bool:
    var file_path = ECONOMY_PATH + "economy_config.json"
    # ... JSON loading logic ...
    return true

func _load_system_config() -> bool:
    var file_path = SYSTEMS_PATH + "ship_systems.json"
    # ... JSON loading logic ...
    return true

func _load_part_file(file_path: String) -> bool:
    # ... JSON loading logic ...
    # Add parts to _parts_cache
    return true

func _build_part_indexes() -> void:
    # Organize parts by system
    # Organize parts by rarity
    pass

func _load_discovered_parts() -> void:
    # Load from GameState.progress.discovered_parts
    # Also mark parts with discovered: true in JSON
    pass

# ============================================================================
# PART QUERIES
# ============================================================================

func get_part(part_id: String) -> Dictionary:
    if not _check_loaded():
        return {}
    return _parts_cache.get(part_id, {})

func get_parts_for_system(system_name: String, level: int) -> Array:
    # Filter _parts_by_system[system_name] by level
    pass

func get_parts_by_rarity(rarity: String) -> Array:
    return _parts_by_rarity.get(rarity, [])

func get_all_parts() -> Dictionary:
    return _parts_by_system.duplicate()

# ============================================================================
# DISCOVERY
# ============================================================================

func is_part_unlocked(part_id: String) -> bool:
    return _discovered_parts.get(part_id, false)

func discover_part(part_id: String) -> void:
    if _discovered_parts.has(part_id):
        return  # Already discovered

    _discovered_parts[part_id] = true
    GameState.progress.discovered_parts.append(part_id)
    EventBus.part_discovered.emit(part_id, get_part(part_id).name)

func get_discovered_parts() -> Array:
    return GameState.progress.discovered_parts

# ============================================================================
# UPGRADE COSTS
# ============================================================================

func get_upgrade_cost(system_name: String, target_level: int, part_id: String = "") -> Dictionary:
    # If no part_id, use cheapest common part
    # Calculate cost with rarity multiplier
    # Check affordability and inventory
    pass

func get_base_upgrade_cost(system_name: String, target_level: int) -> Dictionary:
    var config = get_system_config(system_name)
    if config.is_empty():
        return {}
    return config.base_upgrade_costs.get(str(target_level), {})

# ============================================================================
# SYSTEM CONFIG
# ============================================================================

func get_system_config(system_name: String) -> Dictionary:
    return _systems_config.get(system_name, {})

func get_power_cost(system_name: String, level: int) -> int:
    var config = get_system_config(system_name)
    if config.is_empty():
        return 0
    var costs = config.get("power_costs", [])
    if level < 1 or level > costs.size():
        return 0
    return costs[level - 1]

# ============================================================================
# ECONOMY CONFIG
# ============================================================================

func get_xp_for_level(level: int) -> int:
    var curve = _economy_config.get("xp_curve", {}).get("levels", [])
    if level < 1 or level > curve.size():
        return 0
    return curve[level - 1]

func get_xp_curve() -> Array:
    return _economy_config.get("xp_curve", {}).get("levels", [])

func get_skill_points_per_level() -> int:
    return _economy_config.get("skill_points", {}).get("per_level", 2)

func get_inventory_capacity_formula() -> String:
    return _economy_config.get("inventory", {}).get("formula", "")

func calculate_inventory_capacity(hull_level: int) -> float:
    var base = _economy_config.get("inventory", {}).get("base_capacity_kg", 100)
    var per_level = _economy_config.get("inventory", {}).get("capacity_per_hull_level", 50)
    return base + (per_level * hull_level)

# ============================================================================
# VALIDATION
# ============================================================================

func validate_part_id(part_id: String) -> bool:
    return _parts_cache.has(part_id)

func _check_loaded() -> bool:
    if not _is_loaded:
        push_error("PartRegistry: Data not loaded!")
        return false
    if _load_error:
        push_error("PartRegistry: Load failed!")
        return false
    return true
```

---

## Testing Strategy

### Unit Tests

Test each API method independently:

```gdscript
# Test get_part
assert(PartRegistry.get_part("invalid_id").is_empty())
var part = PartRegistry.get_part("hull_scrap_plates_l1_common")
assert(part.name == "Scrap Hull Plates")

# Test get_parts_for_system
var hull_parts = PartRegistry.get_parts_for_system("hull", 1)
assert(hull_parts.size() >= 3)

# Test discovery
assert(not PartRegistry.is_part_unlocked("rare_part_id"))
PartRegistry.discover_part("rare_part_id")
assert(PartRegistry.is_part_unlocked("rare_part_id"))

# Test upgrade costs
var cost = PartRegistry.get_upgrade_cost("hull", 1, "hull_scrap_plates_l1_common")
assert(cost.credits == 100)
assert(cost.rarity == "common")
```

### Integration Tests

Test with GameState integration:

```gdscript
# Setup
GameState.reset_to_new_game()
GameState.add_credits(500)
var part = PartRegistry.get_part("hull_scrap_plates_l1_common")
GameState.add_item(part)

# Test affordability check
var cost = PartRegistry.get_upgrade_cost("hull", 1, part.id)
assert(cost.affordable == true)
assert(cost.have_part == true)

# Consume resources
GameState.spend_credits(cost.credits)
GameState.remove_item(part.id)

# Verify
assert(GameState.get_credits() == 400)
assert(GameState.get_part_count(part.id) == 0)
```

### Load Tests

Verify data integrity:

```gdscript
# Check all files loaded
assert(PartRegistry._parts_cache.size() >= 50)
assert(PartRegistry._parts_by_system.size() == 10)

# Check no duplicate IDs
var ids = {}
for part_id in PartRegistry._parts_cache:
    assert(not ids.has(part_id), "Duplicate ID: " + part_id)
    ids[part_id] = true

# Check all systems have parts
for system in ["hull", "power", "propulsion", "warp", "life_support",
               "computer", "sensors", "shields", "weapons", "communications"]:
    assert(PartRegistry._parts_by_system.has(system))
    assert(PartRegistry._parts_by_system[system].size() > 0)
```

---

**Related Documents:**
- [DATA-SCHEMA-SPECIFICATIONS.md](./DATA-SCHEMA-SPECIFICATIONS.md) - JSON schemas
- [ECONOMY-IMPLEMENTATION-CHECKLIST.md](./ECONOMY-IMPLEMENTATION-CHECKLIST.md) - Implementation tasks
- [MIGRATION-PLAN.md](./MIGRATION-PLAN.md) - Migration strategy

**Version:** 1.0
**Last Updated:** 2025-11-07
