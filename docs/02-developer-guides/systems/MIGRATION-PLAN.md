# Migration Plan: Hardcoded to Data-Driven Economy

**Version:** 1.0
**Date:** 2025-11-07
**Purpose:** Step-by-step plan to migrate from hardcoded system to data-driven economy
**Milestone:** Milestone 1

---

## Table of Contents
1. [Overview](#overview)
2. [Current State Analysis](#current-state-analysis)
3. [Migration Strategy](#migration-strategy)
4. [Phase-by-Phase Migration](#phase-by-phase-migration)
5. [File-by-File Changes](#file-by-file-changes)
6. [Testing After Each Phase](#testing-after-each-phase)
7. [Rollback Plan](#rollback-plan)
8. [Backward Compatibility](#backward-compatibility)

---

## Overview

### Migration Goals

1. **Replace Hardcoded Values:** Move all costs, stats, and configuration to JSON
2. **Add Missing Features:** Credits, parts inventory, discovery system
3. **Maintain Stability:** No breaking changes to existing functionality
4. **Enable Testing:** Each phase independently testable
5. **Safe Rollback:** Can revert to previous phase if issues arise

### Migration Approach

**Incremental Migration:**
- Phase 1: Add new data files (no code changes)
- Phase 2: Add PartRegistry (parallel to existing code)
- Phase 3: Add GameState features (extend, don't replace)
- Phase 4: Update systems to use PartRegistry (one by one)
- Phase 5: Update UI (parallel implementation)
- Phase 6: Remove old code (cleanup)

**NOT Big Bang Rewrite:**
- Avoid replacing everything at once
- Keep old code working during transition
- Test each phase independently
- Rollback to previous phase if needed

---

## Current State Analysis

### What Exists Now

**GameState (godot/scripts/autoload/game_state.gd):**
- ✅ Player data (name, level, xp, skills)
- ✅ Ship data (systems with levels)
- ✅ Basic inventory (array of items)
- ✅ Progress tracking (completed missions)
- ❌ No credits system
- ❌ No part discovery tracking
- ❌ No inventory capacity limits
- ❌ No skill points system
- ⚠️ Hardcoded XP curve

**Ship Systems (godot/scripts/systems/*.gd):**
- ✅ HullSystem, PowerSystem, PropulsionSystem exist
- ✅ Basic upgrade() method
- ⚠️ Hardcoded max_level = 3
- ❌ No upgrade cost checking
- ❌ No part requirements
- ❌ Don't query PartRegistry

**Workshop UI (godot/scripts/ui/workshop.gd):**
- ✅ Displays systems and levels
- ✅ Upgrade buttons
- ⚠️ Hardcoded cost display (_get_upgrade_cost function)
- ❌ No credits display
- ❌ No inventory panel
- ❌ No skills panel

**MissionManager (godot/scripts/autoload/mission_manager.gd):**
- ✅ Basic mission flow
- ✅ XP rewards
- ❌ No credits rewards
- ❌ No part rewards
- ❌ No story unlock system

### What Needs to Change

**Must Add:**
- PartRegistry singleton
- Credits system in GameState
- Part discovery tracking
- Inventory capacity system
- Skill points system
- Data-driven upgrade costs
- UI for credits, inventory, skills

**Must Update:**
- All ship systems to check costs
- Workshop UI to display new features
- MissionManager to award new rewards
- Save/load to include new data

**Can Remove (later):**
- Hardcoded costs in workshop.gd
- Hardcoded XP curve in game_state.gd

---

## Migration Strategy

### Core Principles

1. **Additive Changes First:** Add new systems alongside old ones
2. **Feature Flags:** Use boolean flags to enable/disable new features during testing
3. **Parallel Implementation:** Run old and new code side-by-side, compare results
4. **Gradual Cutover:** Switch consumers to new system one at a time
5. **Keep Old Code:** Don't delete until migration complete and tested

### Migration Phases

```
Phase 1: Data Foundation
    ↓ (no code changes, just data)
Phase 2: PartRegistry
    ↓ (new singleton, doesn't affect existing code)
Phase 3: GameState Extensions
    ↓ (adds features, doesn't break existing)
Phase 4: Ship System Updates
    ↓ (update existing systems one by one)
Phase 5: UI Updates
    ↓ (parallel UI components)
Phase 6: Cleanup
    ↓ (remove old code)
Complete
```

---

## Phase-by-Phase Migration

### Phase 1: Data Foundation (No Risk)

**Goal:** Create all JSON data files without changing any code.

**Actions:**
1. Create `godot/assets/data/parts/` directory
2. Create all 10 part JSON files (see DATA-SCHEMA-SPECIFICATIONS.md)
3. Create `godot/assets/data/systems/ship_systems.json`
4. Create `godot/assets/data/economy/economy_config.json`
5. Validate JSON syntax (use online validator)
6. Commit data files

**Testing:**
- JSON files parse correctly (validate online)
- No code runs yet, nothing can break

**Rollback:**
- Delete data directory (no code changes)

**Time:** 3-4 hours

---

### Phase 2: Add PartRegistry (Low Risk)

**Goal:** Implement PartRegistry singleton, but don't use it yet.

**Actions:**
1. Create `godot/scripts/autoload/part_registry.gd`
2. Implement loading functions (see PART-REGISTRY-ARCHITECTURE.md)
3. Implement all API methods
4. Register autoload in project.godot
5. Add print statements to verify loading
6. Commit PartRegistry

**Testing:**
- Run game and check console for "PartRegistry: Loaded X parts" message
- Open GDScript console and query: `print(PartRegistry.get_part("hull_scrap_plates_l1_common"))`
- Verify data loaded correctly
- **Old systems still work** (not using PartRegistry yet)

**Rollback:**
- Comment out autoload in project.godot
- Keep code, don't delete yet

**Time:** 2-3 hours

---

### Phase 3: Extend GameState (Low Risk)

**Goal:** Add new features to GameState without breaking existing functionality.

**Actions:**
1. Add `credits: int = 0` to player dictionary
2. Add credits API functions (add_credits, spend_credits, get_credits)
3. Add `discovered_parts: Array` to progress dictionary
4. Update inventory functions to handle stacking and weight
5. Add `unspent_skill_points: int` to player dictionary
6. Replace hardcoded XP curve with PartRegistry query
7. Update serialization (to_dict/from_dict) to include new fields
8. Commit GameState changes

**Testing:**
- Run game and verify old saves still load (new fields default to 0)
- Test credits API: `GameState.add_credits(100)`, `GameState.get_credits()` → 100
- Test skill points: `GameState.player.unspent_skill_points = 2`
- Verify XP curve still works
- **Old functionality unaffected**

**Rollback:**
- Revert GameState to previous commit
- Old saves still work

**Time:** 1-2 hours

---

### Phase 4: Update Ship Systems (Medium Risk)

**Goal:** Update each ship system to check costs and consume resources.

**Strategy:** Update ONE system at a time, test, commit, repeat.

#### 4.1 Update HullSystem (30 min)

**Changes:**
```gdscript
# OLD CODE (keep for reference)
func upgrade_old() -> bool:
    if level >= max_level:
        return false
    level += 1
    return true

# NEW CODE
func upgrade() -> bool:
    if level >= max_level:
        return false

    # Check resources
    var cost = PartRegistry.get_upgrade_cost("hull", level + 1, "")
    if not cost.affordable:
        push_warning("Insufficient credits")
        return false
    if not cost.have_part:
        push_warning("Required part not in inventory")
        return false

    # Consume resources
    if not GameState.spend_credits(cost.credits):
        return false
    if not GameState.remove_item(cost.part_id):
        return false

    # Upgrade
    level += 1
    health = 100
    max_health = 100
    active = true

    return true
```

**Testing:**
- Try to upgrade hull with 0 credits → fails correctly
- Add credits: `GameState.add_credits(500)`
- Add part: `GameState.add_item(PartRegistry.get_part("hull_scrap_plates_l1_common"))`
- Upgrade hull → succeeds, resources consumed
- **Other systems still use old code, still work**

**Rollback:**
- Revert hull_system.gd to previous version

#### 4.2 Update PowerSystem (30 min)

Same process as HullSystem.

**Testing:**
- Power system upgrade with resources → works
- Hull system still works (already updated)
- Propulsion system still works (old code)

**Rollback:**
- Revert power_system.gd

#### 4.3 Update PropulsionSystem (30 min)

Same process.

**Testing:**
- All three systems upgraded and work
- Resources consumed correctly

#### 4.4 Update Remaining 7 Systems (1.5 hours)

Follow the pattern established. Each system:
1. Update can_upgrade() to check PartRegistry
2. Update upgrade() to consume resources
3. Test independently
4. Commit
5. Move to next system

**Total Time:** 2-3 hours

---

### Phase 5: Update UI (Medium Risk)

**Goal:** Add new UI elements without breaking existing display.

**Strategy:** Add new panels alongside existing panels, don't modify existing.

#### 5.1 Add Credits Display (15 min)

**Changes to workshop.tscn:**
- Add Label node: `CreditsLabel` in header
- Position next to ship name

**Changes to workshop.gd:**
```gdscript
@onready var credits_label: Label = $MarginContainer/VBoxContainer/Header/CreditsLabel

func _update_all_displays() -> void:
    # Existing code...
    _update_credits_display()  # NEW

func _update_credits_display() -> void:
    credits_label.text = "Credits: %d CR" % GameState.get_credits()
```

**Testing:**
- Credits display shows "Credits: 0 CR"
- Add credits, display updates
- **Existing UI unaffected**

**Rollback:**
- Delete CreditsLabel node
- Remove function call

#### 5.2 Add Inventory Panel (45 min)

**Changes:**
- Add new VBoxContainer in workshop.tscn: `InventoryPanel`
- Add ScrollContainer with item list
- Implement _populate_inventory() function

**Testing:**
- Inventory displays parts
- Weight shown correctly
- **Existing upgrade buttons still work**

**Rollback:**
- Hide InventoryPanel node
- Don't delete yet

#### 5.3 Add Skills Panel (30 min)

Similar process to inventory panel.

#### 5.4 Update Upgrade Buttons (20 min)

**Changes:**
```gdscript
# OLD (keep commented)
# button.text = "UPGRADE TO L%d\n(Cost: %d credits)" % [next_level, cost]

# NEW
var cost = PartRegistry.get_upgrade_cost(system_name, next_level, "")
button.text = "UPGRADE TO L%d\n(%d CR + %s)" % [
    next_level,
    cost.credits,
    cost.part_name
]
button.disabled = not (cost.affordable and cost.have_part)
```

**Testing:**
- Button shows correct cost
- Button disabled when can't afford
- Button enabled when have resources
- Clicking button consumes resources

**Total Time:** 2-3 hours

---

### Phase 6: Update MissionManager (Low Risk)

**Goal:** Award credits and parts as mission rewards.

**Changes:**
```gdscript
# OLD (keep)
func _award_rewards_old(mission: Dictionary) -> void:
    if mission.rewards.has("xp"):
        GameState.add_xp(mission.rewards.xp)

# NEW (add)
func _award_rewards(mission: Dictionary) -> void:
    var rewards = mission.rewards

    # XP (old code)
    if rewards.has("xp"):
        GameState.add_xp(rewards.xp)

    # Credits (new)
    if rewards.has("credits"):
        GameState.add_credits(rewards.credits)

    # Parts (new)
    if rewards.has("parts"):
        for part_data in rewards.parts:
            var part = PartRegistry.get_part(part_data.part_id)
            if not part.is_empty():
                GameState.add_item(part)

    # Story unlocks (new)
    if rewards.has("story_unlocks"):
        for part_id in rewards.story_unlocks:
            PartRegistry.discover_part(part_id)
```

**Testing:**
- Complete tutorial mission
- Verify 300 CR awarded
- Verify parts added to inventory
- Verify parts discovered (unlocked)
- **Old missions without new rewards still work**

**Rollback:**
- Comment out new code sections
- Keep old _award_rewards_old() active

**Time:** 1 hour

---

### Phase 7: Cleanup (Low Risk)

**Goal:** Remove old code once new system proven stable.

**Actions:**
1. Remove hardcoded cost function from workshop.gd
2. Remove hardcoded XP curve from game_state.gd
3. Remove commented-out old code
4. Remove debug print statements
5. Final code review
6. Commit cleanup

**Testing:**
- Full playthrough: tutorial → upgrade systems → save/load
- Verify all features work
- No console errors

**Rollback:**
- Revert to previous commit (keep old code)

**Time:** 1 hour

---

## File-by-File Changes

### godot/scripts/autoload/game_state.gd

**Line-by-line changes:**

```gdscript
# Line 14-26: Player dictionary
var player: Dictionary = {
    "name": "Player",
    "level": 1,
    "xp": 0,
    "xp_to_next_level": 200,
    "rank": "Cadet",
    "credits": 0,  # ADD THIS LINE
    "unspent_skill_points": 0,  # ADD THIS LINE
    "skills": {
        "engineering": 0,
        "diplomacy": 0,
        "combat": 0,
        "science": 0
    }
}

# Line 64-71: Progress dictionary
var progress: Dictionary = {
    "phase": 1,
    "completed_missions": [],
    "discovered_locations": [],
    "major_choices": [],
    "discovered_parts": [],  # ADD THIS LINE
    "playtime_seconds": 0.0,
    "game_started": 0.0
}

# Line 136-138: Replace hardcoded XP curve
func _calculate_next_level_xp(current_level: int) -> int:
    # OLD: return int(200 * pow(1.5, current_level - 1))
    # NEW:
    return PartRegistry.get_xp_for_level(current_level + 1)

# After line 168: Add credits functions
func add_credits(amount: int) -> void:
    player.credits += amount
    EventBus.credits_changed.emit(player.credits, amount)

func spend_credits(amount: int) -> bool:
    if player.credits < amount:
        return false
    player.credits -= amount
    EventBus.credits_changed.emit(player.credits, -amount)
    return true

func get_credits() -> int:
    return player.credits

# After line 340: Add skill point functions
func award_skill_points(amount: int) -> void:
    player.unspent_skill_points += amount

func spend_skill_point(skill_name: String) -> bool:
    if player.unspent_skill_points <= 0:
        return false
    if not player.skills.has(skill_name):
        return false

    player.unspent_skill_points -= 1
    increase_skill(skill_name, 1)
    return true

# Line 319-332: Update inventory functions
func add_item(item: Dictionary) -> bool:
    # Check capacity
    var weight = item.get("weight", 0.0)
    var current_weight = get_inventory_weight()
    var capacity = PartRegistry.calculate_inventory_capacity(ship.systems.hull.level)

    if current_weight + weight > capacity:
        push_warning("Inventory at capacity!")
        return false

    # Check if part already exists (stacking)
    if item.has("id"):
        for inv_item in inventory:
            if inv_item.id == item.id:
                inv_item.quantity = inv_item.get("quantity", 1) + 1
                EventBus.item_added.emit(item)
                return true

    # Add as new item
    item.quantity = 1
    inventory.append(item)
    EventBus.item_added.emit(item)
    return true

func get_inventory_weight() -> float:
    var total = 0.0
    for item in inventory:
        var weight = item.get("weight", 0.0)
        var quantity = item.get("quantity", 1)
        total += weight * quantity
    return total

func get_part_count(part_id: String) -> int:
    for item in inventory:
        if item.get("id") == part_id:
            return item.get("quantity", 1)
    return 0
```

---

### godot/scripts/systems/hull_system.gd

**Changes:**

```gdscript
# Replace upgrade() function entirely
func upgrade() -> bool:
    if level >= max_level:
        push_warning("Hull already at max level")
        return false

    # Get upgrade cost
    var target_level = level + 1
    var cost = PartRegistry.get_upgrade_cost("hull", target_level, "")

    if cost.is_empty():
        push_error("Failed to get upgrade cost for hull level " + str(target_level))
        return false

    # Check affordability
    if not cost.affordable:
        push_warning("Insufficient credits: need %d, have %d" % [
            cost.credits,
            GameState.get_credits()
        ])
        return false

    # Check part availability
    if not cost.have_part:
        push_warning("Required part not in inventory: " + cost.part_name)
        return false

    # Consume resources
    if not GameState.spend_credits(cost.credits):
        push_error("Failed to spend credits")
        return false

    if not GameState.remove_item(cost.part_id):
        push_error("Failed to remove part from inventory")
        # Refund credits
        GameState.add_credits(cost.credits)
        return false

    # Perform upgrade
    level = target_level
    health = 100
    max_health = 100
    active = true

    print("Hull upgraded to level %d" % level)
    EventBus.system_upgraded.emit("hull", level)

    return true

# Update can_upgrade()
func can_upgrade() -> bool:
    if level >= max_level:
        return false

    var cost = PartRegistry.get_upgrade_cost("hull", level + 1, "")
    return cost.affordable and cost.have_part
```

---

### godot/scripts/ui/workshop.gd

**Changes:**

```gdscript
# Add UI references after line 27
@onready var credits_label: Label = $MarginContainer/VBoxContainer/Header/CreditsLabel
@onready var inventory_panel: Panel = $MarginContainer/VBoxContainer/InventoryPanel
@onready var inventory_list: VBoxContainer = $MarginContainer/VBoxContainer/InventoryPanel/ScrollContainer/VBoxContainer
@onready var skills_panel: Panel = $MarginContainer/VBoxContainer/SkillsPanel

# Update _update_all_displays() after line 72
func _update_all_displays() -> void:
    _update_ship_info()
    _update_power_budget()
    _update_credits_display()  # NEW
    _update_inventory_panel()  # NEW
    _update_skills_panel()  # NEW
    _update_system_display("hull", hull_system, hull_status, hull_description, hull_upgrade_button)
    _update_system_display("power", power_system, power_status, power_description, power_upgrade_button)
    _update_system_display("propulsion", propulsion_system, propulsion_status, propulsion_description, propulsion_upgrade_button)

# Replace _get_upgrade_cost() at line 119
func _get_upgrade_cost(system_name: String, target_level: int) -> int:
    # OLD: Hardcoded formula
    # NEW: Query PartRegistry
    var cost = PartRegistry.get_upgrade_cost(system_name, target_level, "")
    return cost.get("credits", 0)

# Add new functions
func _update_credits_display() -> void:
    credits_label.text = "Credits: %d CR" % GameState.get_credits()

func _update_inventory_panel() -> void:
    # Clear existing items
    for child in inventory_list.get_children():
        child.queue_free()

    # Add items
    for item in GameState.inventory:
        var item_label = Label.new()
        item_label.text = "%s x%d (%.1f kg)" % [
            item.name,
            item.get("quantity", 1),
            item.weight
        ]
        inventory_list.add_child(item_label)

    # Show capacity
    var weight = GameState.get_inventory_weight()
    var capacity = PartRegistry.calculate_inventory_capacity(GameState.ship.systems.hull.level)
    var capacity_label = Label.new()
    capacity_label.text = "Total: %.1f / %.1f kg" % [weight, capacity]
    inventory_list.add_child(capacity_label)

func _update_skills_panel() -> void:
    # Implementation for skills UI
    pass
```

---

## Testing After Each Phase

### Phase 1: Data Files
```
✓ JSON files exist
✓ JSON syntax valid (use online validator)
✓ All required fields present
✓ No duplicate part IDs
```

### Phase 2: PartRegistry
```
✓ PartRegistry loads on startup
✓ Console shows "Loaded X parts from Y systems"
✓ Can query parts in GDScript console
✓ No errors in console
✓ Old code still works (not using PartRegistry yet)
```

### Phase 3: GameState
```
✓ Credits API works (add/spend/get)
✓ Skill points API works
✓ XP curve still works
✓ Inventory weight calculation works
✓ Save/load includes new fields
✓ Old saves load with defaults
✓ Old functionality unaffected
```

### Phase 4: Ship Systems
```
✓ Can't upgrade without credits
✓ Can't upgrade without parts
✓ Successful upgrade consumes resources
✓ System level increases
✓ Resources deducted correctly
✓ Can still upgrade old way if needed (fallback)
```

### Phase 5: UI
```
✓ Credits display shows correct amount
✓ Inventory panel shows parts
✓ Skills panel shows points
✓ Upgrade buttons show new cost format
✓ Buttons disabled when can't afford
✓ Buttons enabled when have resources
✓ Old UI elements still work
```

### Phase 6: MissionManager
```
✓ Tutorial mission awards 300 CR
✓ Tutorial mission awards parts
✓ Parts added to inventory
✓ Parts discovered (unlocked)
✓ Old missions still work
```

### Phase 7: Complete Integration
```
✓ New game → tutorial → earn resources → upgrade systems
✓ Save game
✓ Load game
✓ All state preserved
✓ No console errors
✓ No console warnings
```

---

## Rollback Plan

### Per-Phase Rollback

Each phase is independently reversible:

**Phase 1:** Delete data directory
**Phase 2:** Comment out PartRegistry autoload
**Phase 3:** Revert game_state.gd
**Phase 4:** Revert individual system files
**Phase 5:** Hide new UI panels
**Phase 6:** Comment out new reward code
**Phase 7:** Restore old code from previous commit

### Git Strategy

```bash
# Commit after each phase
git add .
git commit -m "Phase X: [description]"

# If issues arise, revert last phase
git revert HEAD

# Or create feature branch
git checkout -b economy-system
# Work on feature branch
# Merge when complete and tested
```

### Feature Flag Approach

Add a feature flag in GameState:

```gdscript
const USE_NEW_ECONOMY = true  # Toggle to switch between old/new

func upgrade_system():
    if USE_NEW_ECONOMY:
        return upgrade_with_costs()
    else:
        return upgrade_old_way()
```

This allows instant rollback without code changes.

---

## Backward Compatibility

### Save File Compatibility

**Problem:** New fields in save files might break old saves.

**Solution:** Default values for missing fields.

```gdscript
func from_dict(data: Dictionary) -> void:
    # Old saves won't have credits
    player.credits = data.player.get("credits", 0)

    # Old saves won't have discovered_parts
    progress.discovered_parts = data.progress.get("discovered_parts", [])

    # Old saves won't have unspent_skill_points
    player.unspent_skill_points = data.player.get("unspent_skill_points", 0)
```

**Testing:**
1. Create save file with old version
2. Load save file with new version
3. Verify defaults applied
4. Verify gameplay continues normally

### Old Mission Files

**Problem:** Old missions don't have credits/parts rewards.

**Solution:** Mission reward parsing handles missing fields.

```gdscript
func _award_rewards(mission: Dictionary) -> void:
    var rewards = mission.get("rewards", {})

    # Optional fields (old missions won't have these)
    if rewards.has("credits"):
        GameState.add_credits(rewards.credits)

    if rewards.has("parts"):
        # Award parts

    # Required fields (all missions have this)
    if rewards.has("xp"):
        GameState.add_xp(rewards.xp)
```

---

## Risk Mitigation

### High-Risk Areas

1. **Save File Format Changes**
   - Risk: Breaking existing saves
   - Mitigation: Default values, version checking
   - Fallback: Manual save migration script

2. **Resource Consumption Bugs**
   - Risk: Duplication (award resources twice) or loss (consume but don't upgrade)
   - Mitigation: Transaction pattern (check → consume → upgrade, rollback on error)
   - Testing: Edge cases (exactly enough resources, not enough, overflow)

3. **UI Rendering Issues**
   - Risk: New panels break layout
   - Mitigation: Parallel implementation, don't modify existing nodes
   - Fallback: Hide new panels, keep old UI

### Testing Checklist

Before marking phase complete:

```
✓ New functionality works
✓ Old functionality still works
✓ No console errors
✓ No console warnings
✓ Save/load works
✓ Can rollback to previous phase if needed
✓ Code committed to git
✓ Documentation updated
```

---

## Success Criteria

**Migration is complete when:**

1. ✅ All JSON data files exist and load correctly
2. ✅ PartRegistry provides all data
3. ✅ GameState tracks credits, parts, skills
4. ✅ All 10 systems check costs before upgrading
5. ✅ Workshop UI displays credits, inventory, skills
6. ✅ Missions award credits and parts
7. ✅ Tutorial gives 300 CR + parts (player choice)
8. ✅ Save/load preserves all economy data
9. ✅ No hardcoded costs remain
10. ✅ Full playthrough works end-to-end

**Test Scenario:**
```
1. Start new game (0 CR, no parts)
2. Complete tutorial mission
3. Verify: 300 CR, 1 part in inventory
4. Attempt upgrade with insufficient resources → fails
5. Add missing part to inventory
6. Upgrade system → success, resources consumed
7. Save game
8. Load game
9. Verify all data restored
10. Continue playing
```

---

## Timeline Estimate

| Phase | Description | Time | Cumulative |
|-------|-------------|------|------------|
| Phase 1 | Data files | 3-4 hours | 4 hours |
| Phase 2 | PartRegistry | 2-3 hours | 7 hours |
| Phase 3 | GameState | 1-2 hours | 9 hours |
| Phase 4 | Ship Systems | 2-3 hours | 12 hours |
| Phase 5 | UI Updates | 2-3 hours | 15 hours |
| Phase 6 | MissionManager | 1 hour | 16 hours |
| Phase 7 | Cleanup | 1 hour | 17 hours |
| **Total** | | **12-17 hours** | |

**Buffer for issues:** +20% = 14-20 hours total

**Recommended schedule:**
- Day 1: Phases 1-2 (data + PartRegistry)
- Day 2: Phases 3-4 (GameState + systems)
- Day 3: Phases 5-6 (UI + missions)
- Day 4: Phase 7 + testing (cleanup + validation)

---

**Related Documents:**
- [ECONOMY-IMPLEMENTATION-CHECKLIST.md](./ECONOMY-IMPLEMENTATION-CHECKLIST.md) - Task checklist
- [DATA-SCHEMA-SPECIFICATIONS.md](./DATA-SCHEMA-SPECIFICATIONS.md) - JSON schemas
- [PART-REGISTRY-ARCHITECTURE.md](./PART-REGISTRY-ARCHITECTURE.md) - PartRegistry design

**Version:** 1.0
**Last Updated:** 2025-11-07
