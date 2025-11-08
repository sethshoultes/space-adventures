# Test Scripts Directory

**Purpose:** Automated and manual test scripts for Space Adventures systems
**Last Updated:** 2025-11-07

---

## Overview

This directory contains comprehensive test suites for validating game systems, particularly the reward and achievement systems.

## Test Files

### Automated Test Suites

#### `test_rewards.gd`
**Purpose:** Comprehensive automated tests for reward system
**Tests:** 34 automated tests covering:
- Basic rewards (XP, credits, parts)
- Part discovery and PartRegistry integration
- Conditional rewards
- Bonus XP calculations
- Achievement unlocks
- Inventory weight limits
- Performance benchmarks
- Edge cases (zero rewards, invalid data, max level)

**How to Run:**
1. Attach script to a Node in a test scene
2. Run scene (F5 or F6)
3. Check console for test results

**Expected Output:**
```
=== Reward System Test Suite ===
Starting reward system tests...

TEST: XP Awarding
  ✓ PASS: XP should increase by 100
  ✓ PASS: Player should level up after enough XP
  ✓ XP awarding works correctly

...

=== Test Summary ===
Tests Passed: 34
Tests Failed: 0
Total Tests: 34
✓ ALL TESTS PASSED!
```

---

#### `test_mission_progression.gd`
**Purpose:** Tests complete mission flow including stages, choices, and rewards
**Tests:** Mission progression integration:
- Mission loading and validation
- Stage transitions
- Skill check success/failure
- Choice consequences
- Reward application from missions
- Achievement unlocks from missions
- Mission unlock chains
- Mission failure handling

**How to Run:**
1. Attach script to a Node
2. Ensure `mission_tutorial.json` exists
3. Run scene
4. Check console for results

---

#### `test_economy_system.gd`
**Purpose:** Tests economy balance and progression
**Tests:** Economy system validation (existing file)

---

### Manual Test Scenes

#### `test_rewards_scene.gd`
**Purpose:** Interactive UI for manually testing reward scenarios
**Scene:** `godot/scenes/test_rewards.tscn`

**Features:**
- Real-time game state display
- Buttons to trigger reward scenarios
- Visual feedback on reward application
- Event monitoring and logging
- Quick reset/refresh functionality

**How to Use:**
1. Open `scenes/test_rewards.tscn`
2. Press F6 to run scene
3. Click buttons to test different scenarios
4. Watch state panel update in real-time
5. Check console for detailed logs

**Available Test Buttons:**
- Award 100 XP
- Award 300 Credits
- Award Hull Part
- Discover New Part
- Award 500 XP (Level Up)
- Complete Test Mission
- Award Full Mission Rewards
- Unlock Test Achievement
- Test Inventory Weight
- Test Invalid Part
- Reset Game State
- Refresh Display
- Run Automated Tests

---

## Test Data

### `mission_test_rewards.json`
**Location:** `godot/assets/data/missions/mission_test_rewards.json`

**Purpose:** Comprehensive test mission with all reward types

**Features:**
- Tests all reward types in one mission
- Multiple test paths (basic, conditional, discovery, achievements)
- Valid part_ids from PartRegistry
- Conditional rewards based on skill checks
- Achievement unlock triggers
- Mission unlock chains

**Test Paths:**
1. **Basic Rewards**: Standard XP, credits, parts
2. **Conditional Success**: Bonus rewards from skill check
3. **Conditional Failure**: Base rewards when skill check fails
4. **Discovery**: Part discovery system test
5. **Achievements**: Achievement unlock test

**Rewards Tested:**
- Base XP: 100
- Credits: 500
- Parts: hull_scrap_plates_l1_common, power_fusion_cell_l1_common
- Discoveries: 4-6 parts unlocked
- Unlocks: 3 mission unlocks
- Conditional bonuses: +50 XP, +200 credits

---

## Running Tests

### Quick Start

**Option 1: Automated Tests (Console)**
```bash
# Open Godot
godot godot/project.godot

# In Godot console or script:
var test = load("res://scripts/tests/test_rewards.gd").new()
add_child(test)
```

**Option 2: Interactive Testing (Scene)**
```bash
# Open scene
godot godot/project.godot

# Press F6 on test_rewards.tscn
# Click buttons to test
```

**Option 3: Mission Flow Testing**
```bash
# Load mission_test_rewards.json in MissionManager
# Play through different paths
# Verify rewards apply correctly
```

---

## Test Requirements

### Prerequisites

1. **Autoloads Active:**
   - GameState
   - EventBus
   - PartRegistry
   - SaveManager

2. **Data Files Present:**
   - `assets/data/parts/*.json` (all 10 part files)
   - `assets/data/economy/economy_config.json`
   - `assets/data/systems/ship_systems.json`
   - `assets/data/missions/mission_tutorial.json`
   - `assets/data/missions/mission_test_rewards.json`

3. **Valid Part IDs:**
   - `hull_scrap_plates_l1_common`
   - `power_fusion_cell_l1_common`
   - `propulsion_chemical_thruster_l1_common`
   - `warp_basic_nacelle_l1_common`
   - `sensors_basic_array_l1_common`
   - `shields_deflector_l1_common`

### Environment Check

Before running tests, verify:

```gdscript
# Check in Godot console
print(has_node("/root/GameState"))  # Should be true
print(has_node("/root/PartRegistry"))  # Should be true
print(has_node("/root/EventBus"))  # Should be true
print(PartRegistry._is_loaded)  # Should be true
print(PartRegistry._parts_cache.size())  # Should be > 0
```

---

## Expected Test Results

### Pass Criteria

✅ **All automated tests pass** (34/34)
✅ **No console errors** (red messages)
✅ **Rewards apply correctly**
✅ **Achievements unlock at thresholds**
✅ **PartRegistry integration works**
✅ **Inventory respects weight limits**
✅ **Performance within targets** (< 50ms per operation)

### Performance Targets

| Operation | Target |
|-----------|--------|
| Single XP award | < 10ms |
| Single credit award | < 10ms |
| Single item add | < 20ms |
| Part discovery | < 20ms |
| Complete mission rewards | < 50ms |
| 100 XP awards | < 1000ms |
| 100 item adds | < 1000ms |

---

## Troubleshooting

### Common Issues

**Issue:** "PartRegistry not loaded" error
**Fix:**
- Check part JSON files exist
- Verify PartRegistry in autoload
- Check console for load errors

**Issue:** Invalid part_id errors
**Fix:**
- Use only validated part IDs listed above
- Check PartRegistry.validate_part_id()
- Verify part files match IDs

**Issue:** Tests fail with achievement errors
**Fix:**
- Check EventBus signals connected
- Verify GameState._check_*_achievements() methods
- Ensure achievements initialized

**Issue:** Negative XP/credits
**Fix:**
- Check GameState validation logic
- Test with negative values
- Ensure rejection logic works

---

## Test Coverage

### Systems Tested

- ✅ XP awarding and level-up
- ✅ Credit awarding and spending
- ✅ Part inventory management
- ✅ Part discovery system
- ✅ Mission completion tracking
- ✅ Achievement unlock system
- ✅ Conditional rewards
- ✅ Bonus XP calculations
- ✅ Inventory weight limits
- ✅ PartRegistry integration
- ✅ EventBus signal emission
- ✅ Save/load preservation
- ✅ Error handling
- ✅ Performance benchmarks

### Test Categories

1. **Unit Tests**: Individual function testing
2. **Integration Tests**: System interaction testing
3. **Flow Tests**: Complete mission flow testing
4. **Performance Tests**: Speed and efficiency testing
5. **Edge Case Tests**: Boundary and error testing
6. **Manual Tests**: Interactive UI testing

---

## Documentation

For detailed testing procedures, see:
- [Reward System Testing Guide](/docs/01-user-guides/testing/REWARD-SYSTEM-TESTING.md)
- [Economy Design](/docs/03-game-design/economy/ECONOMY-DESIGN.md)
- [Reward System](/docs/02-developer-guides/systems/REWARD-SYSTEM.md)

---

## Contributing

When adding new tests:

1. Follow existing test structure
2. Use `_assert_*()` helper functions
3. Print clear pass/fail messages
4. Include test in summary count
5. Document expected results
6. Test edge cases
7. Verify performance

**Test Naming Convention:**
- `test_*` functions for automated tests
- `_on_*` functions for signal handlers
- `_assert_*` functions for validation helpers

---

## Version History

**v1.0.0** (2025-11-07)
- Initial test suite creation
- 34 automated tests for reward system
- Interactive test scene
- Comprehensive test mission
- Full testing documentation

---

**For questions or issues, see:**
- [AI-AGENT-GUIDE.md](/AI-AGENT-GUIDE.md)
- [ROADMAP.md](/ROADMAP.md)
- [STATUS.md](/STATUS.md)
