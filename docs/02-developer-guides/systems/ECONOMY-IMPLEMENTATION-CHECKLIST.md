# Economy Implementation Checklist

**Version:** 1.0
**Date:** 2025-11-07
**Purpose:** Master checklist for implementing hybrid economy system (credits + parts)
**Milestone:** Milestone 1 (95% → 100%)

---

## Overview

**Goal:** Implement data-driven hybrid economy with:
- Credits currency
- Parts inventory with rarity tiers
- Story-driven part unlocks
- Inventory capacity system
- XP/leveling with skill points
- Upgrade cost system (credits + parts)

**Scope:** Level 1-3 content (Milestone 1), Level 4-5 placeholders

**Total Estimated Time:** 12-16 hours

---

## Phase 1: Data Files Creation (3-4 hours) ✅ COMPLETE

### 1.1 Parts Data Files
**Location:** `godot/assets/data/parts/`

- [x] **hull_parts.json** (45 min) ✅
  - [x] 5+ parts per level (L1-L3) - 9 parts total
  - [x] Common/uncommon/rare tiers per level
  - [x] Level 4-5 placeholder parts (deferred)
  - [x] Complete metadata (name, description, stats, weight, rarity)
  - [x] Validation: All fields present and valid

- [x] **power_parts.json** (45 min) ✅
  - [x] Same structure as hull_parts - 9 parts total
  - [x] Power generation stats
  - [x] Efficiency values
  - [x] Level 1-3 complete, 4-5 placeholders (deferred)

- [x] **propulsion_parts.json** (45 min) ✅
  - [x] Speed and maneuverability stats - 9 parts total
  - [x] Power consumption values
  - [x] Level 1-3 complete, 4-5 placeholders (deferred)

- [x] **warp_parts.json** (30 min) ✅
  - [x] Warp factor and range stats - 6 parts total
  - [x] Level 1-3 complete, 4-5 placeholders (deferred)

- [x] **life_support_parts.json** (30 min) ✅
  - [x] Crew capacity stats - 6 parts total
  - [x] Level 1-3 complete, 4-5 placeholders (deferred)

- [ ] **Create 5 more system part files** (2.5 hours)
  - [ ] computer_parts.json
  - [ ] sensors_parts.json
  - [ ] shields_parts.json
  - [ ] weapons_parts.json
  - [ ] communications_parts.json

### 1.2 System Configuration
**Location:** `godot/assets/data/systems/`

- [x] **ship_systems.json** (30 min) ✅
  - [x] 10 systems with level requirements
  - [x] Compatible part IDs per system
  - [x] Power consumption tables
  - [x] System unlock conditions
  - [x] Upgrade costs per level (credits + required parts)
  - [x] Stats per level for each system

### 1.3 Economy Configuration
**Location:** `godot/assets/data/economy/`

- [x] **economy_config.json** (30 min) ✅
  - [x] Starting credits (0)
  - [x] Tutorial rewards (300 CR + choice of 2 L1 parts)
  - [x] Base upgrade costs per level
  - [x] Cost multipliers by rarity (common 1.0, uncommon 1.5, rare 2.0)
  - [x] XP curve array [0, 100, 250, 450, 700, 1000]
  - [x] Skill points per level (2)
  - [x] Level cap (5 for Milestone 1)
  - [x] Inventory capacity formula (100 + 50 * hull_level)

### 1.4 Tutorial Mission Updates
**Location:** `godot/assets/data/missions/`

- [ ] **mission_tutorial.json** (20 min)
  - [ ] Update rewards to: 300 CR, hull_plate_l1, power_cell_l1
  - [ ] Add choice: hull or power part
  - [ ] Narrative about discovering parts
  - **Dependencies:** Part files exist
  - **Risk:** None

**Phase 1 Subtotal:** 3-4 hours

---

## Phase 2: PartRegistry Singleton (2-3 hours) ✅ COMPLETE

### 2.1 Create PartRegistry
**Location:** `godot/scripts/autoload/part_registry.gd`

- [x] **Basic structure** (30 min) ✅
  - [x] Extends Node
  - [x] Dictionary for loaded parts (720+ lines total)
  - [x] Dictionary for discovered parts
  - [x] Loading state flag

- [x] **Loading system** (45 min) ✅
  - [x] `_load_all_parts()` - Parse all part JSON files
  - [x] `_load_economy_config()` - Parse economy config
  - [x] `_load_system_config()` - Parse ship systems config
  - [x] Error handling for missing/invalid files (graceful fallbacks)
  - [x] Validation of data structure (push_warning on errors)

- [x] **Core API methods** (1 hour) ✅
  - [x] `get_part(part_id: String) -> Dictionary` - O(1) lookup
  - [x] `get_parts_for_system(system_name: String, level: int) -> Array`
  - [x] `get_parts_by_rarity(rarity: String) -> Array`
  - [x] `is_part_unlocked(part_id: String) -> bool`
  - [x] `discover_part(part_id: String) -> void`
  - [x] `get_upgrade_cost(system_name: String, level: int, part_id: String) -> Dictionary`
  - [x] **30+ additional methods implemented** (see PART-REGISTRY-API-REFERENCE.md)

- [x] **Caching strategy** (30 min) ✅
  - [x] Load all data on startup (_ready)
  - [x] Cache lookups in dictionaries (parts, systems, systems_by_name)
  - [x] No lazy loading (data set is small)

- [x] **Register autoload** (5 min) ✅
  - [x] Added to project.godot: PartRegistry="*res://scripts/autoload/part_registry.gd"
  - [x] Verified compilation (exit code 0)

**Phase 2 Subtotal:** 2-3 hours ✅ COMPLETE

---

## Phase 3: GameState Updates (1-2 hours) ✅ COMPLETE

### 3.1 Add Credits System
**Location:** `godot/scripts/autoload/game_state.gd`

- [x] **Add credits field** (10 min) ✅
  - [x] `player.credits: int = 0` in player dictionary
  - [x] Initialize to 0 (tutorial gives first credits)

- [x] **Credits API** (20 min) ✅
  - [x] `add_credits(amount: int) -> void`
  - [x] `spend_credits(amount: int) -> bool` (returns false if insufficient)
  - [x] `can_afford(amount: int) -> bool`
  - [x] Emit EventBus.credits_changed signal

### 3.2 Update Inventory System
**Location:** `godot/scripts/autoload/game_state.gd`

- [x] **Add inventory metadata** (15 min) ✅
  - [x] Track part counts (stackable by part_id)
  - [x] Track total weight via `get_total_inventory_weight()`
  - [x] Track capacity limit via `get_inventory_capacity()`
  - [x] Add `progress.discovered_parts: Array` to progress dictionary

- [x] **Inventory API** (30 min) ✅
  - [x] Update `add_item()` to handle stacking and weight validation
  - [x] Add `can_carry_item(part_id: String, quantity: int) -> bool` (check capacity)
  - [x] Add `get_part_count(part_id: String) -> int`
  - [x] Add `get_total_inventory_weight() -> float` (uses PartRegistry for weights)
  - [x] Add `get_inventory_capacity() -> float` (uses PartRegistry calculation)
  - [x] Add `consume_item(part_id: String, quantity: int) -> bool` (for upgrades)
  - [x] Emit EventBus.inventory_full signal when capacity exceeded

### 3.3 Update XP System
**Location:** `godot/scripts/autoload/game_state.gd`

- [x] **Replace hardcoded XP curve** (15 min) ✅
  - [x] Load XP curve from economy_config.json via PartRegistry
  - [x] Use array: [0, 100, 250, 450, 700, 1000]
  - [x] Update `_calculate_next_level_xp()` to use PartRegistry.get_xp_for_level()

- [x] **Add skill points** (20 min) ✅
  - [x] Add `player.skill_points: int` to player dictionary
  - [x] Award 2 skill points per level up (from PartRegistry.get_skill_points_per_level())
  - [x] Add `allocate_skill_point(skill_name: String) -> bool`
  - [x] Add `get_available_skill_points() -> int`
  - [x] Emit EventBus.skill_allocated and EventBus.level_up signals

### 3.4 Save/Load Updates
**Location:** `godot/scripts/autoload/game_state.gd`

- [x] **Update serialization** (10 min) ✅
  - [x] Include credits in save data (added to player dict)
  - [x] Include discovered_parts in save data (added to progress dict)
  - [x] Include skill_points in save data (added to player dict)
  - [x] Updated `reset_to_new_game()` with all new fields

### 3.5 EventBus Signal Updates
**Location:** `godot/scripts/autoload/event_bus.gd`

- [x] **Add economy signals** (5 min) ✅
  - [x] `signal credits_changed(new_amount: int)`
  - [x] `signal level_up(new_level: int, skill_points_gained: int)` (updated signature)
  - [x] `signal skill_allocated(skill_name: String, new_value: int)`
  - [x] `signal part_discovered(part_id: String, part_name: String)`
  - [x] `signal inventory_full()`

**Phase 3 Subtotal:** 1-2 hours ✅ COMPLETE (649 lines GameState, 184 lines EventBus)

---

## Phase 4: Ship System Upgrade Refactor (2-3 hours)

### 4.1 Update Ship System Classes
**Location:** `godot/scripts/systems/*.gd`

- [ ] **HullSystem.gd** (30 min)
  - [ ] Update `can_upgrade()` to check credits + required part
  - [ ] Update `upgrade()` to consume credits + part
  - [ ] Query PartRegistry for upgrade costs
  - [ ] Emit cost information in signals
  - **Dependencies:** PartRegistry API complete
  - **Risk:** None

- [ ] **PowerSystem.gd** (30 min)
  - [ ] Same updates as HullSystem
  - **Dependencies:** HullSystem complete
  - **Risk:** None

- [ ] **PropulsionSystem.gd** (30 min)
  - [ ] Same updates as HullSystem
  - **Dependencies:** HullSystem complete
  - **Risk:** None

- [ ] **Update all 7 remaining systems** (1.5 hours)
  - [ ] WarpSystem.gd
  - [ ] LifeSupportSystem.gd
  - [ ] ComputerSystem.gd
  - [ ] SensorsSystem.gd
  - [ ] ShieldsSystem.gd
  - [ ] WeaponsSystem.gd
  - [ ] CommunicationsSystem.gd
  - **Dependencies:** First 3 systems complete
  - **Risk:** None (pattern established)

### 4.2 Update Base ShipSystem Class
**Location:** `godot/scripts/systems/ship_system.gd`

- [ ] **Add cost calculation** (20 min)
  - [ ] `get_upgrade_cost() -> Dictionary` (returns {credits: int, part_id: String})
  - [ ] Query PartRegistry
  - [ ] Handle missing data gracefully
  - **Dependencies:** PartRegistry API
  - **Risk:** None

**Phase 4 Subtotal:** 2-3 hours

---

## Phase 5: Workshop UI Updates (2-3 hours)

### 5.1 Add Resource Display
**Location:** `godot/scenes/workshop.tscn` + `godot/scripts/ui/workshop.gd`

- [ ] **Credits display** (15 min)
  - [ ] Add Label for credits in header
  - [ ] Update on scene load
  - [ ] Update on EventBus credit changes
  - **Dependencies:** GameState credits API
  - **Risk:** None

- [ ] **Inventory capacity display** (15 min)
  - [ ] Add Label showing "Inventory: X/Y kg"
  - [ ] Color code: green if under 75%, yellow 75-99%, red at capacity
  - [ ] Update on scene load and changes
  - **Dependencies:** GameState inventory API
  - **Risk:** None

### 5.2 Update Upgrade Buttons
**Location:** `godot/scripts/ui/workshop.gd`

- [ ] **Show costs in UI** (30 min)
  - [ ] Update button text to show "UPGRADE TO L2\n(150 CR + Hull Plate L2)"
  - [ ] Query PartRegistry for costs
  - [ ] Show part rarity with color coding
  - **Dependencies:** PartRegistry API
  - **Risk:** None

- [ ] **Disable button logic** (20 min)
  - [ ] Check credits >= cost
  - [ ] Check part in inventory
  - [ ] Check inventory capacity if reward item
  - [ ] Show tooltip explaining why disabled
  - **Dependencies:** Cost display complete
  - **Risk:** Tooltip implementation complexity

### 5.3 Inventory Panel (NEW)
**Location:** `godot/scenes/workshop.tscn` + `godot/scripts/ui/workshop.gd`

- [ ] **Create inventory UI** (45 min)
  - [ ] ScrollContainer with VBoxContainer
  - [ ] Display all parts in inventory
  - [ ] Show: icon (placeholder), name, quantity, weight, rarity
  - [ ] Sort by: system type, then rarity, then name
  - [ ] Show total weight at bottom
  - **Dependencies:** GameState inventory API
  - **Risk:** UI layout complexity

- [ ] **Part tooltips** (20 min)
  - [ ] Hover over part to see full stats
  - [ ] Show: description, level requirement, compatible systems
  - [ ] Show if part is locked/unlocked
  - **Dependencies:** Inventory UI created
  - **Risk:** None

### 5.4 Skills Panel (NEW)
**Location:** `godot/scenes/workshop.tscn` + `godot/scripts/ui/workshop.gd`

- [ ] **Create skills UI** (30 min)
  - [ ] Show 4 skills: Engineering, Diplomacy, Combat, Science
  - [ ] Show current level and unspent points
  - [ ] "+" button to spend point (disabled if no points)
  - [ ] Show skill descriptions
  - **Dependencies:** GameState skill API
  - **Risk:** None

- [ ] **Skill spending** (15 min)
  - [ ] Confirm dialog: "Spend skill point on [skill]?"
  - [ ] Update GameState on confirm
  - [ ] Refresh UI
  - [ ] Show notification
  - **Dependencies:** Skills UI created
  - **Risk:** None

**Phase 5 Subtotal:** 2-3 hours

---

## Phase 6: MissionManager Updates (1 hour)

### 6.1 Update Mission Rewards
**Location:** `godot/scripts/autoload/mission_manager.gd`

- [ ] **Parse new reward format** (20 min)
  - [ ] Support `"credits": 300` in mission JSON
  - [ ] Support `"parts": ["hull_plate_l1"]` array
  - [ ] Support choice rewards (player picks one)
  - **Dependencies:** Mission JSON updated
  - **Risk:** None

- [ ] **Award rewards** (20 min)
  - [ ] Call `GameState.add_credits(amount)`
  - [ ] Call `GameState.add_item(part)` for each part
  - [ ] Check inventory capacity before adding parts
  - [ ] Show overflow warning if capacity exceeded
  - **Dependencies:** GameState APIs
  - **Risk:** Inventory overflow handling

- [ ] **Unlock parts** (20 min)
  - [ ] Call `PartRegistry.discover_part(part_id)` for story unlocks
  - [ ] Track discovered parts in GameState
  - [ ] Show "New part discovered!" notification
  - **Dependencies:** PartRegistry API
  - **Risk:** None

**Phase 6 Subtotal:** 1 hour

---

## Phase 7: EventBus Signal Updates (30 min)

### 7.1 Add New Signals
**Location:** `godot/scripts/autoload/event_bus.gd`

- [ ] **Economy signals** (15 min)
  - [ ] `signal credits_changed(new_amount: int, delta: int)`
  - [ ] `signal part_discovered(part_id: String, part_name: String)`
  - [ ] `signal inventory_capacity_changed(used: float, max: float)`
  - [ ] `signal skill_point_spent(skill_name: String, new_level: int)`
  - **Dependencies:** None
  - **Risk:** None

- [ ] **Update existing signals** (15 min)
  - [ ] Update `system_upgraded` to include cost information
  - [ ] Update `item_added` to include stack information
  - **Dependencies:** None
  - **Risk:** Breaking existing listeners (check all uses)

**Phase 7 Subtotal:** 30 min

---

## Phase 8: Testing & Validation (2-3 hours)

### 8.1 Unit Tests
- [ ] **PartRegistry tests** (30 min)
  - [ ] Test loading all part files
  - [ ] Test get_part() with valid/invalid IDs
  - [ ] Test get_parts_for_system()
  - [ ] Test is_part_unlocked() and discover_part()
  - [ ] Test get_upgrade_cost()
  - **Dependencies:** PartRegistry complete
  - **Risk:** None

- [ ] **GameState tests** (30 min)
  - [ ] Test credits add/spend
  - [ ] Test inventory add/remove with stacking
  - [ ] Test inventory capacity checks
  - [ ] Test XP curve from config
  - [ ] Test skill point award/spend
  - **Dependencies:** GameState updates complete
  - **Risk:** None

### 8.2 Integration Tests
- [ ] **Workshop flow** (45 min)
  - [ ] Start new game (0 CR, no parts)
  - [ ] Complete tutorial (300 CR + parts)
  - [ ] Verify credits awarded
  - [ ] Verify parts added to inventory
  - [ ] Attempt upgrade with insufficient resources
  - [ ] Perform successful upgrade
  - [ ] Verify credits and part consumed
  - [ ] Verify system upgraded
  - **Dependencies:** All systems integrated
  - **Risk:** None

- [ ] **Save/load test** (30 min)
  - [ ] Save game with credits and parts
  - [ ] Load game
  - [ ] Verify all economy data restored
  - [ ] Verify inventory intact
  - [ ] Verify discovered parts persist
  - **Dependencies:** Save/load updates complete
  - **Risk:** Save format issues

- [ ] **Edge cases** (45 min)
  - [ ] Try to upgrade without credits
  - [ ] Try to upgrade without required part
  - [ ] Try to add item beyond inventory capacity
  - [ ] Try to spend skill point at max level
  - [ ] Try to load missing part data
  - [ ] Verify error handling graceful
  - **Dependencies:** All systems complete
  - **Risk:** Uncaught edge cases

**Phase 8 Subtotal:** 2-3 hours

---

## Phase 9: Documentation & Polish (1 hour)

### 9.1 Update Documentation
- [ ] **Update STATUS.md** (10 min)
  - [ ] Mark economy system complete
  - [ ] Update Milestone 1 to 100%
  - **Dependencies:** All testing complete
  - **Risk:** None

- [ ] **Update ROADMAP.md** (10 min)
  - [ ] Check off economy items
  - [ ] Update progress percentages
  - **Dependencies:** All testing complete
  - **Risk:** None

- [ ] **Update JOURNAL.md** (20 min)
  - [ ] Document key decisions (cost formulas, rarity tiers)
  - [ ] Note any challenges encountered
  - [ ] Record patterns for future reference
  - **Dependencies:** All work complete
  - **Risk:** None

### 9.2 Code Cleanup
- [ ] **Remove hardcoded values** (20 min)
  - [ ] Search for magic numbers in upgrade costs
  - [ ] Replace with PartRegistry lookups
  - [ ] Remove any test/debug code
  - [ ] Add comments to complex sections
  - **Dependencies:** All code complete
  - **Risk:** None

**Phase 9 Subtotal:** 1 hour

---

## Summary

**Total Estimated Time:** 12-16 hours

**Breakdown:**
- Phase 1 (Data Files): 3-4 hours
- Phase 2 (PartRegistry): 2-3 hours
- Phase 3 (GameState): 1-2 hours
- Phase 4 (Ship Systems): 2-3 hours
- Phase 5 (Workshop UI): 2-3 hours
- Phase 6 (MissionManager): 1 hour
- Phase 7 (EventBus): 30 min
- Phase 8 (Testing): 2-3 hours
- Phase 9 (Documentation): 1 hour

**Critical Path:**
1. Phase 1 (Data Files) → Phase 2 (PartRegistry) → Phase 3 (GameState)
2. Phase 4 (Ship Systems) depends on Phase 2-3
3. Phase 5 (Workshop UI) depends on Phase 2-4
4. Phase 6 (MissionManager) depends on Phase 2-3
5. Phase 7 (EventBus) can be done anytime
6. Phase 8 (Testing) depends on all previous phases
7. Phase 9 (Documentation) depends on Phase 8

**Recommended Order:**
Follow phases 1-9 in sequence for smoothest implementation.

---

## Risk Assessment

### High Risk
None identified

### Medium Risk
- **Content writing time** (Phase 1): May take longer than estimated for 50+ parts
  - Mitigation: Start with minimum viable parts (3 per level vs 5+), expand later
- **Inventory overflow handling** (Phase 6): Complex edge case
  - Mitigation: Clear error messages, prevent adding items if over capacity
- **Breaking old saves** (Phase 3.4): Save format changes
  - Mitigation: Acceptable for Milestone 1, implement migration for Milestone 2

### Low Risk
- **JSON parsing errors** (Phase 2): Handled with validation
- **UI layout complexity** (Phase 5): Use existing patterns
- **Tooltip implementation** (Phase 5): Use Godot built-in tooltips

---

## Completion Criteria

**Milestone 1 is 100% complete when:**
- [ ] All 50+ parts defined in JSON (Level 1-3 content complete)
- [ ] PartRegistry loads and caches all data
- [ ] Credits system fully functional
- [ ] Inventory with capacity and stacking works
- [ ] XP curve and skill points work
- [ ] All 10 systems use data-driven upgrade costs
- [ ] Workshop UI shows credits, inventory, skills
- [ ] Tutorial mission gives 300 CR + parts (player choice)
- [ ] All integration tests pass
- [ ] Save/load preserves all economy data
- [ ] Documentation updated

**Success Metric:** Can play through tutorial → earn resources → upgrade systems → save/load → continue playing with full economy system operational.

---

**Related Documents:**
- [DATA-SCHEMA-SPECIFICATIONS.md](./DATA-SCHEMA-SPECIFICATIONS.md) - JSON schemas
- [PART-REGISTRY-ARCHITECTURE.md](./PART-REGISTRY-ARCHITECTURE.md) - PartRegistry design
- [MIGRATION-PLAN.md](./MIGRATION-PLAN.md) - Migration strategy

**Version:** 1.0
**Last Updated:** 2025-11-07
