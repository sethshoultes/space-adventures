# Integration Test Checklist
**Date:** 2024-11-06
**Milestone:** Milestone 1 - Proof of Concept
**Test Phase:** Workshop UI + Ship Systems Integration

---

## Test Environment Setup

**Prerequisites:**
- [ ] Godot 4.2+ installed
- [ ] Project opens without errors
- [ ] No console errors on startup
- [ ] All autoload singletons loaded successfully

**Starting State:**
- GameState: Player Level 1, all systems at Level 0
- No save files (fresh start)

---

## Test Suite 1: Main Menu Navigation

### Test 1.1: Main Menu Loads
- [ ] Main menu scene loads without errors
- [ ] Title displays correctly: "SPACE ADVENTURES"
- [ ] All buttons are visible
- [ ] Output log shows "Main Menu Initialized"
- [ ] Service status checks run automatically

### Test 1.2: Workshop Button Navigation
**Steps:**
1. Click "OPEN WORKSHOP" button
2. Verify scene transition

**Expected Results:**
- [ ] Workshop scene loads without errors
- [ ] Workshop title displays: "WORKSHOP"
- [ ] Ship name displays: "USS Unnamed Vessel (None)"
- [ ] Power budget shows: 0 PU generation, 0 PU consumption
- [ ] All three systems show "Level 0: NOT INSTALLED"

### Test 1.3: Return to Main Menu
**Steps:**
1. From Workshop, click "MAIN MENU" button

**Expected Results:**
- [ ] Returns to main menu scene
- [ ] No errors in console
- [ ] Main menu displays correctly

---

## Test Suite 2: Ship System Display

### Test 2.1: Initial System Display (Level 0)
**Hull System:**
- [ ] Name: "Hull & Structure"
- [ ] Status: "Level 0: NOT INSTALLED"
- [ ] Description: "Ship frame only, not spaceworthy."
- [ ] Button: "UPGRADE TO L1 (Cost: 100 credits)"
- [ ] Button is enabled

**Power Core System:**
- [ ] Name: "Power Core"
- [ ] Status: "Level 0: NOT INSTALLED"
- [ ] Description: "Ship is dead in space."
- [ ] Button: "UPGRADE TO L1 (Cost: 150 credits)"
- [ ] Button is enabled

**Propulsion System:**
- [ ] Name: "Propulsion (Impulse Engines)"
- [ ] Status: "Level 0: NOT INSTALLED"
- [ ] Description: "No propulsion system installed."
- [ ] Button: "UPGRADE TO L1 (Cost: 100 credits)"
- [ ] Button is enabled

### Test 2.2: Power Budget Display (Initial State)
- [ ] Power Generation: 0 PU
- [ ] Power Consumption: 0 PU
- [ ] Available Power: 0 PU (should show neutral color)
- [ ] Hull Integrity: 0/0 HP

---

## Test Suite 3: Hull System Upgrade Flow

### Test 3.1: Upgrade Hull to Level 1
**Steps:**
1. Click "UPGRADE TO L1" on Hull System
2. Observe UI changes

**Expected Results:**
- [ ] Console: "Upgrading Hull system"
- [ ] Console: "Hull System upgraded to Level 1: 50 HP, 5.0% kinetic armor"
- [ ] Console: "Hull upgraded to Level 1"
- [ ] Status changes to: "Level 1: OPERATIONAL"
- [ ] Description changes to: "Patchwork hull cobbled from salvaged materials..."
- [ ] Button changes to: "UPGRADE TO L2 (Cost: 400 credits)"
- [ ] Hull Integrity: 50/50 HP
- [ ] Power budget: Still 0 PU available (hull doesn't consume power at L1)
- [ ] Auto-save triggered (check console for save message)

### Test 3.2: Verify GameState Updated
**Check GameState (via console or debug):**
- [ ] GameState.ship.systems.hull.level = 1
- [ ] GameState.ship.systems.hull.active = true
- [ ] GameState.ship.max_hull_hp = 50
- [ ] GameState.ship.hull_hp = 50

---

## Test Suite 4: Power Core Upgrade Flow

### Test 4.1: Upgrade Power Core to Level 1
**Steps:**
1. Click "UPGRADE TO L1" on Power Core System
2. Observe UI changes

**Expected Results:**
- [ ] Console: "Upgrading Power Core"
- [ ] Console: "Power Core upgraded to Level 1: 100 PU, 80% efficiency, 0% cost reduction"
- [ ] Console: "Power Core upgraded to Level 1"
- [ ] Status changes to: "Level 1: OPERATIONAL (+100 PU)"
- [ ] Description changes to: "Basic fusion cell. Enough to get started."
- [ ] Button changes to: "UPGRADE TO L2 (Cost: 600 credits)"
- [ ] Power Generation: 100 PU (updated!)
- [ ] Power Consumption: 0 PU (no systems consuming yet)
- [ ] Available Power: 100 PU (GREEN - positive)
- [ ] Auto-save triggered

### Test 4.2: Verify Power Budget Calculations
- [ ] GameState.ship.power_total = 100
- [ ] GameState.ship.power_consumption = 0
- [ ] GameState.ship.power_available = 100
- [ ] Power available label is GREEN (positive power)

---

## Test Suite 5: Propulsion System Upgrade Flow

### Test 5.1: Upgrade Propulsion to Level 1
**Steps:**
1. Click "UPGRADE TO L1" on Propulsion System
2. Observe UI changes

**Expected Results:**
- [ ] Console: "Upgrading Propulsion system"
- [ ] Console: "Propulsion System upgraded to Level 1: 1x speed, 5% dodge"
- [ ] Console: "Propulsion upgraded to Level 1"
- [ ] Status changes to: "Level 1: OPERATIONAL (-10 PU)"
- [ ] Description changes to: "Old reliable. Slow but functional."
- [ ] Button changes to: "UPGRADE TO L2 (Cost: 400 credits)"
- [ ] Power Generation: Still 100 PU
- [ ] Power Consumption: 10 PU (updated!)
- [ ] Available Power: 90 PU (GREEN - still positive)
- [ ] Auto-save triggered

### Test 5.2: Verify Power Budget with Consumption
- [ ] GameState.ship.power_total = 100
- [ ] GameState.ship.power_consumption = 10
- [ ] GameState.ship.power_available = 90
- [ ] Power available label is still GREEN (positive)

---

## Test Suite 6: Multi-Level Upgrades

### Test 6.1: Upgrade Hull to Level 2
**Steps:**
1. Click "UPGRADE TO L2" on Hull System

**Expected Results:**
- [ ] Status: "Level 2: OPERATIONAL"
- [ ] Description: "Proper hull plating with reinforced stress points..."
- [ ] Button: "UPGRADE TO L3 (Cost: 900 credits)"
- [ ] Hull Integrity: 100/100 HP (doubled)
- [ ] Power still balanced (hull L1-L2 don't consume power)

### Test 6.2: Upgrade Power Core to Level 2
**Steps:**
1. Click "UPGRADE TO L2" on Power Core System

**Expected Results:**
- [ ] Status: "Level 2: OPERATIONAL (+200 PU)"
- [ ] Description: "Standard deuterium reactor. Reliable and efficient."
- [ ] Button: "UPGRADE TO L3 (Cost: 1350 credits)"
- [ ] Power Generation: 200 PU (doubled)
- [ ] Available Power: ~190 PU (increased significantly)
- [ ] Level 2 bonus: -10% power cost reduction applies

### Test 6.3: Upgrade Propulsion to Level 2
**Steps:**
1. Click "UPGRADE TO L2" on Propulsion System

**Expected Results:**
- [ ] Status: "Level 2: OPERATIONAL (-15 PU)"
- [ ] Description: "Standard ion propulsion. Quiet and efficient."
- [ ] Button: "UPGRADE TO L3 (Cost: 900 credits)"
- [ ] Power Consumption: ~15 PU (or less with power core reduction)
- [ ] Available Power: Still positive

---

## Test Suite 7: Save/Load Integration

### Test 7.1: Manual Save
**Steps:**
1. With systems at various levels (e.g., Hull L2, Power L2, Propulsion L2)
2. Click "SAVE GAME" button

**Expected Results:**
- [ ] Console: "Manual save requested"
- [ ] Console: "Game saved successfully"
- [ ] No errors in console
- [ ] Save file created at user://saves/save_slot_1.json

### Test 7.2: Load Save (Fresh Start)
**Steps:**
1. Close and reopen Godot project
2. Open Main Menu scene
3. Click "OPEN WORKSHOP"
4. Observe system states

**Expected Results:**
- [ ] Hull System: Level 2, 100/100 HP
- [ ] Power Core: Level 2, 200 PU
- [ ] Propulsion: Level 2, speed 2x
- [ ] Power budget calculations correct
- [ ] All descriptions match current levels

### Test 7.3: Auto-Save After Upgrades
**Steps:**
1. Perform any system upgrade
2. Close Godot WITHOUT manual save
3. Reopen project and load Workshop

**Expected Results:**
- [ ] Auto-save preserved the upgrade
- [ ] System level matches last upgrade
- [ ] No data loss

---

## Test Suite 8: EventBus Integration

### Test 8.1: System Upgraded Events
**Monitor console while upgrading any system:**
- [ ] EventBus signal fires: "EventBus: System upgraded: [system_name] to Level [X]"
- [ ] UI updates automatically after upgrade
- [ ] No duplicate updates

### Test 8.2: Game Saved Events
**Monitor console while saving:**
- [ ] EventBus signal fires: "EventBus: Game saved to slot [X]"
- [ ] Workshop receives the signal

---

## Test Suite 9: Edge Cases & Error Handling

### Test 9.1: Max Level Upgrade Attempt
**Steps:**
1. Upgrade any system to Level 5
2. Observe button state

**Expected Results:**
- [ ] Button text: "MAX LEVEL"
- [ ] Button is disabled
- [ ] Clicking does nothing (no console errors)

### Test 9.2: Negative Power Budget
**Steps:**
1. Ensure Power Core is at Level 1 (100 PU)
2. Upgrade Propulsion to Level 5 (60 PU consumption)
3. Try upgrading other power-consuming systems until power goes negative

**Expected Results:**
- [ ] Available Power shows negative value
- [ ] Available Power label turns RED
- [ ] Game doesn't crash
- [ ] Systems still function (game allows negative power for now)

### Test 9.3: Rapid Button Clicking
**Steps:**
1. Rapidly click the same upgrade button multiple times

**Expected Results:**
- [ ] System upgrades only once per click
- [ ] No duplicate upgrades
- [ ] No console errors
- [ ] UI remains responsive

---

## Test Suite 10: Performance & Stability

### Test 10.1: Scene Transitions
**Steps:**
1. Navigate Main Menu → Workshop → Main Menu → Workshop (repeat 5 times)

**Expected Results:**
- [ ] No memory leaks (Godot debugger shows stable memory)
- [ ] Scene loads remain fast
- [ ] No accumulating errors in console
- [ ] System states persist correctly

### Test 10.2: Extended Session
**Steps:**
1. Perform 20+ system upgrades across all three systems
2. Save and load multiple times
3. Navigate between scenes frequently

**Expected Results:**
- [ ] Game remains stable
- [ ] No performance degradation
- [ ] Save/load continues to work
- [ ] UI remains responsive

---

## Test Suite 11: Visual & UX Validation

### Test 11.1: UI Layout
- [ ] All text is readable (no clipping)
- [ ] Buttons are properly sized
- [ ] Spacing is consistent
- [ ] Colors are appropriate (green for positive, red for negative)
- [ ] Workshop title and ship name are prominent

### Test 11.2: User Experience
- [ ] Button press feedback is immediate
- [ ] Upgrade costs increase logically
- [ ] System descriptions are informative
- [ ] Power budget is easy to understand
- [ ] Navigation is intuitive

---

## Test Results Summary

**Test Date:** _____________
**Tester:** _____________
**Total Tests:** 60+
**Passed:** _____
**Failed:** _____
**Blocked:** _____

### Critical Issues Found:
1.
2.
3.

### Minor Issues Found:
1.
2.
3.

### Improvements Suggested:
1.
2.
3.

---

## Sign-Off

**Integration Test Status:** ☐ PASS  ☐ FAIL  ☐ PARTIAL

**Notes:**


**Tested By:** ___________________  **Date:** ___________

**Approved By:** ___________________  **Date:** ___________

---

## Next Steps After Tests Pass

1. [ ] Document any bug fixes made during testing
2. [ ] Update STATUS.md with test completion
3. [ ] Create GitHub release tag (if applicable)
4. [ ] Begin work on Mission UI system
5. [ ] Plan 15-minute complete gameplay loop test
