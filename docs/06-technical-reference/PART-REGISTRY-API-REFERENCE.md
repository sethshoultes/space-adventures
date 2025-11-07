# PartRegistry API Reference

**Quick reference guide for PartRegistry singleton**
**Version:** 1.0
**Date:** 2025-11-07

---

## Quick Access

```gdscript
# PartRegistry is an autoload singleton - access from anywhere
var part = PartRegistry.get_part("hull_scrap_plates_l1_common")
var cost = PartRegistry.get_upgrade_cost("hull", 1)
```

---

## Part Queries

### get_part(part_id: String) -> Dictionary

Get complete part definition.

```gdscript
var part = PartRegistry.get_part("hull_scrap_plates_l1_common")
if not part.is_empty():
    print(part.name)         # "Scrap Hull Plates"
    print(part.level)        # 1
    print(part.rarity)       # "common"
    print(part.stats.max_hp) # 50
```

**Returns:** Part dictionary or `{}` if not found

---

### get_parts_for_system(system_name: String, level: int = -1) -> Array

Get parts for a system, optionally filtered by level.

```gdscript
# All hull parts
var hull_parts = PartRegistry.get_parts_for_system("hull")

# Only level 2 hull parts
var hull_l2 = PartRegistry.get_parts_for_system("hull", 2)

# Display in UI
for part in hull_l2:
    print("%s (%s) - %d HP" % [part.name, part.rarity, part.stats.max_hp])
```

**Returns:** Array of part dictionaries, sorted by level then rarity

---

### get_parts_by_rarity(rarity: String) -> Array

Get all parts of a specific rarity.

```gdscript
var rare_parts = PartRegistry.get_parts_by_rarity("rare")
print("Found %d rare parts" % rare_parts.size())
```

**Valid rarities:** `"common"`, `"uncommon"`, `"rare"`

---

### get_all_parts() -> Dictionary

Get all parts organized by system.

```gdscript
var all_parts = PartRegistry.get_all_parts()
for system_name in all_parts:
    print("%s: %d parts" % [system_name, all_parts[system_name].size()])
```

**Returns:** `{"hull": [parts...], "power": [parts...], ...}`

---

## Discovery System

### is_part_unlocked(part_id: String) -> bool

Check if player has discovered a part.

```gdscript
if PartRegistry.is_part_unlocked("hull_composite_armor_l1_rare"):
    show_part_in_shop()
else:
    show_locked_part_placeholder()
```

---

### discover_part(part_id: String) -> void

Unlock a part (story progression).

```gdscript
# After mission complete
PartRegistry.discover_part("warp_basic_core_l1_common")
# Part is now visible in shop/workshop
```

**Side Effects:**
- Updates internal cache
- Saves to GameState.progress.discovered_parts
- Emits EventBus.part_discovered signal

---

### get_discovered_parts() -> Array

Get list of all discovered part IDs.

```gdscript
var discovered = PartRegistry.get_discovered_parts()
print("Player has discovered %d parts" % discovered.size())
```

---

## Upgrade Costs

### get_upgrade_cost(system_name: String, target_level: int, part_id: String = "") -> Dictionary

Calculate upgrade cost with rarity multiplier.

```gdscript
# Use cheapest common part
var cost = PartRegistry.get_upgrade_cost("hull", 2)

# Use specific part
var rare_cost = PartRegistry.get_upgrade_cost("hull", 2, "hull_composite_armor_l2_rare")

# Check requirements
if cost.affordable and cost.have_part:
    perform_upgrade()
else:
    show_insufficient_resources_message()
```

**Returns:**
```gdscript
{
    "credits": 200,
    "part_id": "hull_reinforced_structure_l2_common",
    "part_name": "Reinforced Hull Structure",
    "rarity": "common",
    "affordable": true,    # Player has enough credits
    "have_part": true,     # Part is in inventory
    "success": true
}
```

---

### get_base_upgrade_cost(system_name: String, target_level: int) -> Dictionary

Get base cost before rarity multiplier.

```gdscript
var base = PartRegistry.get_base_upgrade_cost("hull", 2)
print("Base cost: %d CR" % base.credits)
print("Rarity required: %s" % base.rarity_required)
```

**Returns:** `{"credits": 200, "rarity_required": "common"}`

---

## System Configuration

### get_system_config(system_name: String) -> Dictionary

Get complete system configuration.

```gdscript
var config = PartRegistry.get_system_config("hull")
print(config.display_name)          # "Hull & Structure"
print(config.max_level)             # 5
print(config.milestone_1_max_level) # 3
print(config.compatible_parts)      # Array of part IDs
```

---

### get_power_cost(system_name: String, level: int) -> int

Get power consumption for a system at a level.

```gdscript
var shields_l3_power = PartRegistry.get_power_cost("shields", 3)
print("Shields L3 consume %d PU" % shields_l3_power)  # 40 PU
```

---

## Economy Configuration

### get_xp_for_level(level: int) -> int

Get total XP required to reach a level.

```gdscript
var xp_needed = PartRegistry.get_xp_for_level(3)
print("Level 3 requires %d total XP" % xp_needed)  # 250 XP
```

---

### get_xp_curve() -> Array

Get complete XP curve.

```gdscript
var curve = PartRegistry.get_xp_curve()
# [0, 100, 250, 450, 700, 1000]

for i in curve.size():
    print("Level %d: %d XP" % [i + 1, curve[i]])
```

---

### get_skill_points_per_level() -> int

Get skill points awarded per level up.

```gdscript
var points = PartRegistry.get_skill_points_per_level()  # 2
```

---

### calculate_inventory_capacity(hull_level: int) -> float

Calculate inventory capacity for a hull level.

```gdscript
var capacity = PartRegistry.calculate_inventory_capacity(2)
print("Capacity: %.1f kg" % capacity)  # 200.0 kg
```

**Formula:** `100 + (50 * hull_level)`

---

### get_inventory_capacity_formula() -> String

Get formula as string for display.

```gdscript
var formula = PartRegistry.get_inventory_capacity_formula()
# "100 + (50 * hull_level)"
```

---

## Validation

### validate_part_id(part_id: String) -> bool

Check if a part ID exists.

```gdscript
if PartRegistry.validate_part_id(reward_part_id):
    GameState.add_item(PartRegistry.get_part(reward_part_id))
else:
    push_error("Invalid part ID in mission: " + reward_part_id)
```

---

## Common Patterns

### Workshop: Display Upgrade Options

```gdscript
func display_upgrade_options(system_name: String):
    var current_level = GameState.ship.systems[system_name].level
    var target_level = current_level + 1

    # Get all parts for this upgrade
    var parts = PartRegistry.get_parts_for_system(system_name, target_level)

    for part in parts:
        # Only show unlocked parts
        if not PartRegistry.is_part_unlocked(part.id):
            continue

        # Get cost for this specific part
        var cost = PartRegistry.get_upgrade_cost(system_name, target_level, part.id)

        # Create button
        var button = create_upgrade_button(part, cost)
        button.disabled = not (cost.affordable and cost.have_part)
```

---

### Ship System: Check Upgrade Requirements

```gdscript
# In hull_system.gd
func can_upgrade() -> bool:
    if level >= max_level:
        return false

    var cost = PartRegistry.get_upgrade_cost("hull", level + 1)
    return cost.affordable and cost.have_part

func upgrade() -> bool:
    if not can_upgrade():
        return false

    var cost = PartRegistry.get_upgrade_cost("hull", level + 1)

    # Consume resources
    GameState.spend_credits(cost.credits)
    GameState.remove_item(cost.part_id)

    # Perform upgrade
    level += 1
    EventBus.system_upgraded.emit("hull", level)

    return true
```

---

### Mission: Award Part Rewards

```gdscript
# In mission_manager.gd
func award_mission_rewards(rewards: Dictionary):
    # Award credits
    if rewards.has("credits"):
        GameState.add_credits(rewards.credits)

    # Award parts
    if rewards.has("parts"):
        for part_data in rewards.parts:
            if PartRegistry.validate_part_id(part_data.part_id):
                var part = PartRegistry.get_part(part_data.part_id)
                GameState.add_item(part)

    # Story unlocks
    if rewards.has("story_unlocks"):
        for part_id in rewards.story_unlocks:
            PartRegistry.discover_part(part_id)
            show_notification("New part discovered: " + part_id)
```

---

### UI: Display Part Stats

```gdscript
func display_part_details(part_id: String):
    var part = PartRegistry.get_part(part_id)
    if part.is_empty():
        return

    # Display basic info
    name_label.text = part.name
    description_label.text = part.description
    level_label.text = "Level: %d" % part.level
    rarity_label.text = part.rarity.capitalize()
    weight_label.text = "%.1f kg" % part.weight

    # Display stats (varies by system type)
    if part.system_type == "hull":
        stat1_label.text = "Max HP: %d" % part.stats.max_hp
        stat2_label.text = "Armor (Kinetic): %d" % part.stats.armor_kinetic
    elif part.system_type == "power":
        stat1_label.text = "Power Output: %d PU" % part.stats.power_output
        stat2_label.text = "Efficiency: %d%%" % part.stats.efficiency
    # ... etc

    # Show if unlocked
    if PartRegistry.is_part_unlocked(part_id):
        locked_overlay.hide()
    else:
        locked_overlay.show()
```

---

## System Names

Valid system_name values:
- `"hull"`
- `"power"`
- `"propulsion"`
- `"warp"`
- `"life_support"`
- `"computer"`
- `"sensors"`
- `"shields"`
- `"weapons"`
- `"communications"`

---

## Rarity Values

Valid rarity values:
- `"common"` - Multiplier: 1.0
- `"uncommon"` - Multiplier: 1.5
- `"rare"` - Multiplier: 2.0

---

## Part Data Structure

```gdscript
{
    "id": "hull_scrap_plates_l1_common",
    "name": "Scrap Hull Plates",
    "description": "Salvaged metal plates welded together...",
    "system_type": "hull",
    "level": 1,
    "rarity": "common",
    "weight": 25.0,
    "stats": {
        "max_hp": 50,
        "armor_kinetic": 5,
        "armor_energy": 0
    },
    "discovered": false,
    "story_unlock": "tutorial_first_salvage"
}
```

---

## Error Handling

**All methods return safe defaults:**
- `get_part()` returns `{}` (empty dict) if not found
- `get_parts_for_system()` returns `[]` (empty array) if system invalid
- `get_power_cost()` returns `0` if system/level invalid
- `get_xp_for_level()` returns `0` if level invalid

**Check results:**
```gdscript
var part = PartRegistry.get_part(part_id)
if part.is_empty():
    push_error("Part not found: " + part_id)
    return

var cost = PartRegistry.get_upgrade_cost("hull", 1)
if not cost.get("success", false):
    push_error(cost.get("error", "Unknown error"))
    return
```

---

## Performance

- **Part lookup:** O(1) - Dictionary indexed by part_id
- **System filter:** O(n) where n = parts in that system (~5-10)
- **Rarity filter:** O(n) where n = total parts (~50)
- **Memory:** ~30 KB for 50 parts (negligible)
- **Startup:** ~50ms to load all data files

---

## Related Documents

- [PART-REGISTRY-ARCHITECTURE.md](../02-developer-guides/systems/PART-REGISTRY-ARCHITECTURE.md) - Design spec
- [DATA-SCHEMA-SPECIFICATIONS.md](../02-developer-guides/systems/DATA-SCHEMA-SPECIFICATIONS.md) - JSON schemas
- [PART-REGISTRY-IMPLEMENTATION-REPORT.md](../02-developer-guides/systems/PART-REGISTRY-IMPLEMENTATION-REPORT.md) - Implementation details

---

**Version:** 1.0
**Last Updated:** 2025-11-07
