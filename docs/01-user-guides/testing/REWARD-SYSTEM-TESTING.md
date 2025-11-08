# Reward System Testing Guide

**Purpose:** Comprehensive testing guide for the reward and achievement systems
**Audience:** Developers, QA testers, AI agents
**Last Updated:** 2025-11-07

---

## Table of Contents

1. [Overview](#overview)
2. [Test Environment Setup](#test-environment-setup)
3. [Automated Testing](#automated-testing)
4. [Manual Testing](#manual-testing)
5. [Test Scenarios](#test-scenarios)
6. [Expected Results](#expected-results)
7. [Economy Impact Validation](#economy-impact-validation)
8. [Performance Testing](#performance-testing)
9. [Troubleshooting](#troubleshooting)

---

## Overview

The reward system is the core progression mechanism in Space Adventures. It handles:

- **XP Awards**: Player experience points and leveling
- **Credit Awards**: In-game currency for purchases
- **Part Awards**: Ship parts added to inventory
- **Part Discovery**: Unlocking parts for use
- **Mission Unlocks**: Unlocking new missions
- **Achievement Unlocks**: Triggering achievement progress

### Testing Goals

- ✅ All reward types function correctly
- ✅ Rewards integrate with GameState and PartRegistry
- ✅ Achievements unlock at proper thresholds
- ✅ Conditional rewards apply correctly
- ✅ Inventory weight limits are respected
- ✅ Economy balance is maintained
- ✅ Performance is acceptable (< 100ms per reward)

---

## Test Environment Setup

### Prerequisites

1. **Godot Project**: Open the Space Adventures project in Godot 4.2+
2. **Autoloads Active**: Ensure all singletons are registered:
   - GameState
   - EventBus
   - PartRegistry
   - SaveManager

3. **Data Files Present**:
   - `godot/assets/data/missions/mission_tutorial.json`
   - `godot/assets/data/missions/mission_test_rewards.json`
   - `godot/assets/data/parts/*.json` (all part files)
   - `godot/assets/data/economy/economy_config.json`
   - `godot/assets/data/systems/ship_systems.json`

### Verification Steps

Before testing, verify the environment:

```bash
# 1. Check Godot project opens without errors
godot godot/project.godot

# 2. In Godot console, look for:
# - "GameState initialized"
# - "PartRegistry: Loaded X parts from Y files"
# - "EventBus initialized"
# - No red errors
```

If you see errors, resolve them before proceeding with tests.

---

## Automated Testing

### Running Test Suite

**Option 1: Via Test Script**

1. Open Godot Editor
2. Open Script: `godot/scripts/tests/test_rewards.gd`
3. Attach to a Node in a test scene
4. Press F5 to run
5. Check console output for test results

**Option 2: Via Command Line**

```bash
# Run test scene directly
godot --headless --script godot/scripts/tests/test_rewards.gd
```

**Option 3: Via Test Scene**

1. Open scene: `godot/scenes/test_rewards.tscn`
2. Press F6 to run current scene
3. Click "Run Automated Tests" button
4. View results in console and on-screen

### Test Coverage

The automated test suite covers:

- ✅ **Basic Rewards** (13 tests)
  - XP awarding
  - Credit awarding
  - Part awarding
  - Part discovery
  - Mission unlocks

- ✅ **Advanced Rewards** (8 tests)
  - Conditional rewards
  - Bonus XP calculations
  - Reward validation
  - Reward modification

- ✅ **Integration Tests** (6 tests)
  - Complete mission flow
  - Achievement unlocks
  - Inventory weight limits
  - PartRegistry integration

- ✅ **Performance Tests** (2 tests)
  - Reward calculation speed
  - Bulk reward processing

- ✅ **Edge Cases** (5 tests)
  - Zero rewards
  - Max level rewards
  - Invalid part IDs
  - Negative values

**Total: 34 automated tests**

### Interpreting Results

```
=== Test Summary ===
Tests Passed: 34
Tests Failed: 0
Total Tests: 34
✓ ALL TESTS PASSED!
```

- **All tests passed**: System is working correctly
- **Some tests failed**: Review error messages in console
- **Tests skipped**: Missing dependencies (e.g., PartRegistry not loaded)

---

## Manual Testing

Manual testing allows you to interactively test reward scenarios and see immediate feedback.

### Using Test Scene

1. Open scene: `godot/scenes/test_rewards.tscn`
2. Press F6 to run scene
3. Use buttons to trigger test scenarios
4. Watch state panel update in real-time

### Available Test Buttons

| Button | Tests |
|--------|-------|
| **Award 100 XP** | Basic XP awarding, signal emission |
| **Award 300 Credits** | Credit awarding, achievement check |
| **Award Hull Part** | Part inventory integration, stacking |
| **Discover New Part** | PartRegistry discovery system |
| **Award 500 XP (Level Up)** | Level-up logic, skill point awards |
| **Complete Test Mission** | Mission completion tracking |
| **Award Full Mission Rewards** | Complete reward package |
| **Unlock Test Achievement** | Achievement unlock system |
| **Test Inventory Weight** | Weight calculation and capacity |
| **Test Invalid Part** | Error handling for invalid data |
| **Reset Game State** | Reset to new game |
| **Refresh Display** | Update state display |
| **Run Automated Tests** | Launch test suite |

### Manual Test Procedure

1. **Start Fresh**: Click "Reset Game State"
2. **Choose Test Scenario**: See [Test Scenarios](#test-scenarios) below
3. **Execute Test**: Click appropriate buttons
4. **Verify Results**: Check state panel and console
5. **Record Results**: Note pass/fail and any issues

---

## Test Scenarios

### Scenario 1: Basic Reward Application

**Goal**: Verify basic rewards apply correctly

**Steps**:
1. Reset game state
2. Click "Award 100 XP"
3. Verify XP increases by 100
4. Click "Award 300 Credits"
5. Verify credits increase by 300
6. Click "Award Hull Part"
7. Verify inventory has 1 hull part

**Expected Results**:
- XP: 100
- Credits: 300
- Inventory: 1 item (hull_scrap_plates_l1_common)
- Console shows EventBus signals

**Pass/Fail**: ☐ Pass ☐ Fail

---

### Scenario 2: Level-Up Progression

**Goal**: Test XP accumulation and level-up mechanics

**Steps**:
1. Reset game state
2. Note initial level (should be 1)
3. Click "Award 500 XP (Level Up)" button
4. Verify level increased
5. Verify skill points awarded
6. Verify XP rolled over correctly

**Expected Results**:
- Level: 2 or 3 (depending on XP curve)
- Skill Points: 2+ (from level-up)
- XP: Remainder after level-up
- Achievement "level_3" may unlock if reached

**Pass/Fail**: ☐ Pass ☐ Fail

---

### Scenario 3: Part Discovery System

**Goal**: Test part discovery and PartRegistry integration

**Steps**:
1. Reset game state
2. Note discovered parts count (Progress panel)
3. Click "Discover New Part"
4. Verify discovered_parts count increased
5. Verify PartRegistry shows part as unlocked
6. Click "Discover New Part" again (same part)
7. Verify count doesn't double-increment

**Expected Results**:
- Discovered parts: +1 on first click
- Discovered parts: Same count on second click (no duplicate)
- Console shows "Part Discovered: [name]"
- PartRegistry.is_part_unlocked() returns true

**Pass/Fail**: ☐ Pass ☐ Fail

---

### Scenario 4: Achievement Unlocks

**Goal**: Test achievement triggers from rewards

**Steps**:
1. Reset game state
2. Click "Award Full Mission Rewards"
3. Verify "first_mission" achievement unlocks
4. Continue clicking until 1000 credits reached
5. Verify "credits_1000" achievement unlocks
6. Award enough XP to reach level 3
7. Verify "level_3" achievement unlocks

**Expected Results**:
- "first_mission" unlocks on first mission completion
- "credits_1000" unlocks at ≥1000 credits
- "level_3" unlocks at level ≥3
- Achievement panel shows 3 unlocked
- Console shows unlock events

**Pass/Fail**: ☐ Pass ☐ Fail

---

### Scenario 5: Conditional Rewards

**Goal**: Test skill-based bonus rewards

**Setup**: Modify GameState manually or use console:
```gdscript
GameState.increase_skill("engineering", 5)
```

**Steps**:
1. Reset game state
2. Set engineering skill to 5
3. Simulate skill check (≥3 required)
4. Award base reward (100 XP)
5. Award bonus reward (50 XP)
6. Verify total is 150 XP

**Expected Results**:
- Base XP awarded: 100
- Bonus XP awarded: 50
- Total XP: 150
- Console shows both XP events

**Pass/Fail**: ☐ Pass ☐ Fail

---

### Scenario 6: Inventory Weight Limits

**Goal**: Test inventory capacity enforcement

**Steps**:
1. Reset game state
2. Note starting capacity (100kg + 50kg per hull level)
3. Click "Test Inventory Weight"
4. Note current weight and can_carry status
5. Repeatedly add hull parts
6. Eventually trigger weight limit
7. Verify EventBus.inventory_full signal emits

**Expected Results**:
- Initial capacity: 100kg (hull level 0)
- Parts add weight correctly
- Can't add items beyond capacity
- Console shows "Inventory full" warning

**Pass/Fail**: ☐ Pass ☐ Fail

---

### Scenario 7: Invalid Data Handling

**Goal**: Test error handling for invalid inputs

**Steps**:
1. Reset game state
2. Click "Test Invalid Part"
3. Verify error is logged but doesn't crash
4. Check inventory didn't add invalid item
5. Manually try: `GameState.add_credits(-100)`
6. Verify negative credits rejected

**Expected Results**:
- Invalid part_id triggers error log
- Invalid part NOT added to inventory
- Negative credits rejected
- Game remains stable

**Pass/Fail**: ☐ Pass ☐ Fail

---

### Scenario 8: Mission Progression Flow

**Goal**: Test complete mission flow from start to rewards

**Using**: `mission_test_rewards.json`

**Steps**:
1. Load test mission (mission_test_rewards.json)
2. Choose "Test Basic Rewards" path
3. Progress through stages
4. Complete mission
5. Verify all rewards applied
6. Verify mission marked complete
7. Verify unlocks available

**Expected Results**:
- Base rewards: 100 XP, 500 credits
- Items: 2x hull parts, 1x power part
- Discovered parts: 4 parts unlocked
- Mission unlocks: 3 new missions available
- Achievement "first_mission" unlocked

**Pass/Fail**: ☐ Pass ☐ Fail

---

## Expected Results

### Pass Criteria

For each test scenario:

✅ **Functional**:
- Rewards apply correctly
- No console errors (red)
- State updates immediately
- Signals emit properly

✅ **Data Integrity**:
- XP never goes negative
- Credits never go negative
- Inventory respects weight limits
- Part IDs are validated
- No duplicate discoveries

✅ **Integration**:
- GameState updates correctly
- EventBus signals fire
- PartRegistry synchronizes
- Achievements unlock
- Save/load preserves state

✅ **Performance**:
- XP award: < 10ms
- Item add: < 20ms
- 100 item adds: < 1000ms
- No frame drops during rewards

### Fail Criteria

❌ **Critical Failures** (block release):
- Crash or hang
- Data corruption
- Negative XP/credits
- Inventory duplication
- Achievement data loss

❌ **Major Issues** (must fix):
- Console errors (red)
- Incorrect reward amounts
- Missing signals
- PartRegistry desync
- Performance > 100ms

⚠️ **Minor Issues** (should fix):
- Console warnings (yellow)
- Missing feedback messages
- Inconsistent formatting
- Suboptimal performance

---

## Economy Impact Validation

### Testing Economy Balance

Reward balance is critical for game progression. Test these scenarios to ensure economy stays balanced.

#### Test: Early Game Progression (Levels 1-3)

**Expected Economics**:
- Missions reward: 100-200 XP
- Missions reward: 200-500 credits
- Part cost: 100-300 credits
- Level-up requires: 200-450 XP

**Test Procedure**:
1. Start new game
2. Complete tutorial mission
3. Complete 2-3 early missions
4. Track:
   - Total XP earned
   - Total credits earned
   - Parts acquired
   - Parts affordable
5. Verify player can upgrade 2-3 systems

**Balance Check**:
- ✅ Player can afford at least 2 upgrades per mission
- ✅ Player levels up every 2-3 missions
- ✅ Parts are scarce but not impossible to get
- ❌ Player can't afford any upgrades (too expensive)
- ❌ Player levels too fast (< 2 missions per level)

#### Test: Mid Game Progression (Levels 3-5)

**Expected Economics**:
- Missions reward: 200-400 XP
- Missions reward: 400-800 credits
- Part cost: 300-600 credits
- Level-up requires: 450-1000 XP

**Balance Check**:
- ✅ Progression feels steady
- ✅ Upgrades are meaningful but attainable
- ✅ Player has meaningful choices (upgrade vs save)
- ❌ Progression too slow (grinding)
- ❌ Progression too fast (trivial)

#### Economy Validation Checklist

- [ ] Tutorial mission awards enough to buy first upgrade
- [ ] 3 missions = enough for 2-3 system upgrades
- [ ] 5 missions = level 3 reached
- [ ] 10 missions = level 5 reached, all systems level 1
- [ ] Credits accumulate but require choices (not unlimited)
- [ ] XP curve feels appropriate (not too steep/flat)

### Economy Tuning Tools

If balance issues are found, adjust these values:

**In `economy_config.json`**:
```json
{
  "xp_curve": {
    "levels": [0, 200, 450, 750, 1100, ...]  // Adjust XP per level
  }
}
```

**In Mission Files**:
```json
{
  "rewards": {
    "xp": 100,      // Adjust mission XP
    "credits": 300  // Adjust mission credits
  }
}
```

**In `ship_systems.json`**:
```json
{
  "base_upgrade_costs": {
    "1": {"credits": 100},  // Adjust upgrade costs
    "2": {"credits": 200}
  }
}
```

---

## Performance Testing

### Reward Calculation Speed

Performance is critical when awarding rewards, especially during mission completion.

#### Test: Single Reward Performance

**Procedure**:
```gdscript
var start = Time.get_ticks_msec()
GameState.add_xp(100, "test")
var elapsed = Time.get_ticks_msec() - start
print("XP award time: %d ms" % elapsed)
```

**Expected**: < 10ms per XP award

#### Test: Bulk Reward Performance

**Procedure**:
```gdscript
var start = Time.get_ticks_msec()
for i in range(100):
    GameState.add_item({"part_id": "hull_scrap_plates_l1_common", "quantity": 1})
var elapsed = Time.get_ticks_msec() - start
print("100 item adds: %d ms" % elapsed)
```

**Expected**: < 1000ms for 100 items

#### Test: Complete Mission Reward Package

**Procedure**:
```gdscript
var start = Time.get_ticks_msec()
# Award full mission rewards
GameState.add_xp(150, "mission")
GameState.add_credits(500)
GameState.add_item({"part_id": "hull_scrap_plates_l1_common", "quantity": 2})
GameState.add_item({"part_id": "power_fusion_cell_l1_common", "quantity": 1})
PartRegistry.discover_part("hull_scrap_plates_l1_common")
PartRegistry.discover_part("power_fusion_cell_l1_common")
GameState.complete_mission("test_mission")
var elapsed = Time.get_ticks_msec() - start
print("Full mission reward time: %d ms" % elapsed)
```

**Expected**: < 50ms for complete reward package

### Performance Benchmarks

| Operation | Target | Acceptable | Needs Optimization |
|-----------|--------|------------|-------------------|
| Single XP award | < 5ms | < 10ms | > 10ms |
| Single credit award | < 5ms | < 10ms | > 10ms |
| Single item add | < 10ms | < 20ms | > 20ms |
| Part discovery | < 10ms | < 20ms | > 20ms |
| Complete mission rewards | < 30ms | < 50ms | > 50ms |
| 100 XP awards | < 500ms | < 1000ms | > 1000ms |
| 100 item adds | < 500ms | < 1000ms | > 1000ms |

---

## Troubleshooting

### Common Issues

#### Issue: Tests Fail with "PartRegistry not loaded"

**Cause**: PartRegistry autoload not initialized

**Fix**:
1. Check `project.godot` has PartRegistry in autoload section
2. Verify part JSON files exist in `assets/data/parts/`
3. Check console for PartRegistry load errors

#### Issue: Invalid part_id errors

**Cause**: Using part_id that doesn't exist in part files

**Fix**:
1. Use only these validated part IDs:
   - `hull_scrap_plates_l1_common`
   - `power_fusion_cell_l1_common`
   - `propulsion_chemical_thruster_l1_common`
   - `warp_basic_nacelle_l1_common`
2. Check part files match part_id exactly
3. Verify PartRegistry loaded all part files

#### Issue: Achievements not unlocking

**Cause**: Achievement check functions not called

**Fix**:
1. Verify EventBus signals connected
2. Check `_check_*_achievements()` functions in GameState
3. Ensure rewards apply through GameState methods (not direct assignment)

#### Issue: Inventory not respecting weight limits

**Cause**: Weight calculation or capacity calculation error

**Fix**:
1. Check PartRegistry has weight data for parts
2. Verify hull level correct for capacity calculation
3. Test `can_carry_item()` before `add_item()`

#### Issue: XP/Credits going negative

**Cause**: Validation missing in add_xp/add_credits

**Fix**:
1. Check GameState.add_xp/add_credits have validation
2. Verify negative values are rejected
3. Test with `GameState.add_credits(-100)` and ensure it fails

### Debug Commands

Use these in Godot's script console for debugging:

```gdscript
# Check game state
print(GameState.to_dict())

# Check part registry
print(PartRegistry.get_all_parts())

# Check achievements
print(GameState.get_achievement_progress())

# Force unlock achievement
GameState.unlock_achievement("first_mission")

# Check inventory weight
print("Weight: %.1f / %.1f kg" % [GameState.get_total_inventory_weight(), GameState.get_inventory_capacity()])

# List discovered parts
print(PartRegistry.get_discovered_parts())
```

---

## Test Checklist

Use this checklist when performing a full test pass:

### Pre-Test
- [ ] Godot project opens without errors
- [ ] All autoloads initialized (check console)
- [ ] All data files present
- [ ] Test files created and accessible

### Automated Tests
- [ ] test_rewards.gd runs without errors
- [ ] All 34 tests pass
- [ ] No console errors (red)
- [ ] Performance within targets

### Manual Tests
- [ ] Scenario 1: Basic Rewards ✅
- [ ] Scenario 2: Level-Up ✅
- [ ] Scenario 3: Part Discovery ✅
- [ ] Scenario 4: Achievements ✅
- [ ] Scenario 5: Conditional Rewards ✅
- [ ] Scenario 6: Inventory Limits ✅
- [ ] Scenario 7: Invalid Data ✅
- [ ] Scenario 8: Mission Flow ✅

### Economy Validation
- [ ] Early game balance (levels 1-3)
- [ ] Mid game balance (levels 3-5)
- [ ] Upgrade costs reasonable
- [ ] XP curve appropriate
- [ ] Credit accumulation balanced

### Performance
- [ ] XP award < 10ms
- [ ] Item add < 20ms
- [ ] Complete mission rewards < 50ms
- [ ] No frame drops
- [ ] No memory leaks

### Integration
- [ ] Save/load preserves rewards
- [ ] EventBus signals fire
- [ ] PartRegistry syncs correctly
- [ ] Achievements persist

---

## Reporting Issues

When reporting test failures, include:

1. **Test scenario** that failed
2. **Expected result** vs **actual result**
3. **Console output** (errors and warnings)
4. **Game state** before test (use `GameState.to_dict()`)
5. **Steps to reproduce**
6. **Godot version** and platform

**Example Issue Report**:

```
Title: XP not awarding correctly in mission completion

Scenario: Scenario 8 - Mission Progression Flow
Expected: 100 XP awarded from base rewards
Actual: 0 XP awarded, XP remains at initial value

Console Output:
  [ERROR] GameState.add_xp: Invalid source parameter

Game State Before Test:
  {
    "player": {"level": 1, "xp": 0, ...},
    ...
  }

Steps to Reproduce:
1. Reset game state
2. Load mission_test_rewards.json
3. Complete mission
4. Check XP - still 0

Godot Version: 4.2.1
Platform: macOS 14.0
```

---

## Conclusion

This testing guide provides comprehensive coverage of the reward and achievement systems. By following these procedures, you can:

- ✅ Verify all reward types work correctly
- ✅ Ensure economy balance is maintained
- ✅ Validate integration with all systems
- ✅ Catch edge cases and errors
- ✅ Measure performance
- ✅ Document results for future reference

For questions or issues, refer to:
- `/docs/03-game-design/economy/ECONOMY-DESIGN.md`
- `/docs/02-developer-guides/systems/REWARD-SYSTEM.md`
- `/DECISIONS.md` for design rationale

Happy testing!
