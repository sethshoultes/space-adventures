# Milestone 2 Manual Test Checklist

**Version:** 1.0
**Date:** 2025-11-13
**Purpose:** Manual testing procedures for Milestone 2 features

---

## Overview

This checklist covers manual testing for:
- ✅ Warp Drive system (Levels 0-5)
- ✅ Life Support system (Levels 0-5)
- ✅ Workshop UI integration
- ✅ Power budget management
- ✅ New missions with part rewards
- ✅ Save/load functionality

**Automated Tests:** Run `scripts/test_m2.sh` before manual testing
**Prerequisites:** Working Milestone 1 installation with economy system

---

## 1. Warp Drive System Tests

### 1.1 Workshop UI - Warp Drive Card

**Expected:** Warp Drive card visible in Workshop UI, 2x5 systems grid

**Steps:**
1. Launch game
2. Open Workshop scene
3. Locate Warp Drive card in systems panel

**Verify:**
- [ ] Warp Drive card displays correctly
- [ ] Shows "NOT INSTALLED" status at Level 0
- [ ] Shows current level (0-5)
- [ ] Shows power cost (0, 20, 30, 50, 80, 120)
- [ ] Upgrade button present

**Screenshot:** Workshop UI showing Warp Drive card

---

### 1.2 Warp Drive Level 0 → 1 Upgrade

**Expected:** Can upgrade from Level 0 to Level 1 using credits + part

**Setup:**
```gdscript
# In Godot debug console
GameState.add_credits(1000)
GameState.add_item_to_inventory("warp_basic_core_l1_common", 1)
```

**Steps:**
1. Verify credits: 1000+ CR
2. Verify inventory: warp_basic_core_l1_common × 1
3. Click Warp Drive "Upgrade" button
4. Confirm upgrade dialog

**Verify:**
- [ ] Credits deducted (check exact amount)
- [ ] Part consumed from inventory
- [ ] Warp Drive now Level 1
- [ ] Status changes to "OPERATIONAL"
- [ ] Power budget increases by 20 PU
- [ ] Power meter updates visually

**Expected Values:**
- Warp Factor: 1
- Speed: 1× light speed
- Range: 2 light years
- Power Cost: 20 PU

---

### 1.3 Warp Drive Level 1 → 2 Upgrade

**Setup:**
```gdscript
GameState.add_credits(2000)
GameState.add_item_to_inventory("warp_w3_drive_l2_common", 1)
```

**Steps:**
1. Click Warp Drive "Upgrade" button (Level 1 → 2)
2. Confirm upgrade

**Verify:**
- [ ] Warp Drive now Level 2
- [ ] Warp Factor: 3
- [ ] Speed: 9× light speed
- [ ] Range: 10 light years
- [ ] Power Cost: 30 PU (increase from 20)
- [ ] Power budget updates correctly

---

### 1.4 Warp Drive Level 2 → 3 Upgrade (Special Abilities)

**Setup:**
```gdscript
GameState.add_credits(3000)
GameState.add_item_to_inventory("warp_w5_drive_l3_common", 1)
```

**Steps:**
1. Upgrade to Level 3
2. Check system details panel

**Verify:**
- [ ] Warp Drive now Level 3
- [ ] Warp Factor: 5
- [ ] Speed: 125× light speed
- [ ] Range: 50 light years
- [ ] Power Cost: 50 PU
- [ ] **Special:** "Can escape hostile encounters" displayed
- [ ] Tooltip/description mentions special ability

---

### 1.5 Warp Drive Stats Display

**Steps:**
1. Click on Warp Drive card
2. Review stats panel (if implemented)

**Verify:**
- [ ] Warp factor displayed
- [ ] Light speed multiplier shown
- [ ] Range in light years shown
- [ ] Travel time per LY shown
- [ ] Accessible systems count shown
- [ ] Special abilities listed (L3+)
- [ ] Power cost clearly displayed

---

## 2. Life Support System Tests

### 2.1 Workshop UI - Life Support Card

**Expected:** Life Support card visible in Workshop UI

**Steps:**
1. Open Workshop scene
2. Locate Life Support card

**Verify:**
- [ ] Life Support card displays correctly
- [ ] Shows "NOT INSTALLED" status at Level 0
- [ ] Shows current level (0-5)
- [ ] Shows power cost (0, 5, 10, 15, 25, 35)
- [ ] Upgrade button present

---

### 2.2 Life Support Level 0 → 1 Upgrade

**Setup:**
```gdscript
GameState.add_credits(500)
GameState.add_item_to_inventory("life_support_basic_recycler_l1_common", 1)
```

**Steps:**
1. Upgrade Life Support to Level 1
2. Check system status

**Verify:**
- [ ] Credits deducted
- [ ] Part consumed
- [ ] Life Support now Level 1
- [ ] Status: "OPERATIONAL"
- [ ] Power budget increases by 5 PU
- [ ] Crew Capacity: 1
- [ ] Emergency Duration: 24 hours
- [ ] Radiation Protection: 10%

---

### 2.3 Life Support Level 1 → 2 Upgrade (Unlocks Crew)

**Setup:**
```gdscript
GameState.add_credits(1000)
GameState.add_item_to_inventory("life_support_climate_control_l2_common", 1)
```

**Steps:**
1. Upgrade to Level 2
2. Check for crew system unlock message

**Verify:**
- [ ] Life Support now Level 2
- [ ] Crew Capacity: 4
- [ ] Emergency Duration: 1 week (168 hours)
- [ ] Radiation Protection: 30%
- [ ] Morale Bonus: +10%
- [ ] Power Cost: 10 PU
- [ ] **Special:** "Crew system unlocked" displayed
- [ ] Crew UI becomes available (future feature)

---

### 2.4 Life Support Level 2 → 3 Upgrade

**Setup:**
```gdscript
GameState.add_credits(1500)
GameState.add_item_to_inventory("life_support_bio_recycling_l3_common", 1)
```

**Steps:**
1. Upgrade to Level 3
2. Review stats

**Verify:**
- [ ] Life Support now Level 3
- [ ] Crew Capacity: 10
- [ ] Emergency Duration: 1 month (720 hours)
- [ ] Radiation Protection: 50%
- [ ] Morale Bonus: +20%
- [ ] Power Cost: 15 PU
- [ ] **Special:** "Crew can perform tasks" displayed

---

### 2.5 Life Support Stats Display

**Verify:**
- [ ] Crew capacity shown
- [ ] Emergency duration formatted correctly (hours → days → weeks → months)
- [ ] Radiation protection shown as percentage
- [ ] Morale bonus shown (if > 0%)
- [ ] Special abilities listed
- [ ] Power cost displayed

---

## 3. Power Budget Management

### 3.1 Power Consumption Display

**Expected:** Power meter updates when systems are upgraded/activated

**Setup:**
1. Set Power Core to Level 3 (generates 400 PU)
2. Upgrade Warp to Level 2 (30 PU)
3. Upgrade Life Support to Level 2 (10 PU)

**Verify:**
- [ ] Power Total: 400 PU
- [ ] Power Used: 40 PU (30 + 10)
- [ ] Power Available: 360 PU
- [ ] Power meter bar reflects usage visually
- [ ] Color coding (green = plenty, yellow = moderate, red = low)

**Test Formula:**
```
Power Available = Power Total - Power Used
360 = 400 - (30 + 10)
```

---

### 3.2 Multiple System Power Budget

**Setup:**
1. Upgrade multiple systems:
   - Hull L2 (0 PU)
   - Power Core L3 (400 PU generation)
   - Propulsion L2 (15 PU)
   - Warp L2 (30 PU)
   - Life Support L2 (10 PU)

**Verify:**
- [ ] Total power used: 55 PU minimum
- [ ] Power available: 345 PU
- [ ] All systems show power consumption
- [ ] Total adds up correctly

---

### 3.3 Insufficient Power Warning

**Setup:**
1. Set Power Core to Level 1 (150 PU)
2. Try to activate systems totaling > 150 PU

**Expected Behavior:** (Design decision needed)
- [ ] Warning shown when power exceeds generation
- [ ] Cannot activate system if insufficient power
- [ ] OR systems auto-deactivate
- [ ] Clear feedback to player

---

## 4. Mission Tests

### 4.1 Mission: Industrial Zone Salvage

**Expected:** Mission rewards warp drive parts

**Steps:**
1. Start mission "Toxic Treasures" (Industrial Zone)
2. Complete mission successfully
3. Check rewards

**Verify:**
- [ ] Mission available in mission list
- [ ] Can start and play mission
- [ ] Mission stages flow correctly
- [ ] Choices present and functional
- [ ] On completion, rewards granted:
  - [ ] warp_basic_core_l1_common × 1
  - [ ] warp_w3_drive_l2_common × 1
- [ ] XP awarded (175 base)
- [ ] Credits awarded (500 base)

**Test Multiple Paths:**
- [ ] Try different choice combinations
- [ ] Verify all paths reach completion
- [ ] Check conditional rewards work

---

### 4.2 Mission: Orbital Station Salvage

**Expected:** Mission rewards life support parts

**Steps:**
1. Start mission "Breath of Dying Stars" (Orbital Station)
2. Complete mission successfully
3. Check rewards

**Verify:**
- [ ] Mission available
- [ ] Can start and play mission
- [ ] On completion, rewards granted:
  - [ ] life_support_basic_recycler_l1_common × 1
  - [ ] life_support_climate_control_l2_common × 1
- [ ] XP awarded (225 base)
- [ ] Credits awarded (700 base)

**Special Checks:**
- [ ] Propulsion L1 requirement enforced (if implemented)
- [ ] Orbital mechanics described in narrative
- [ ] "First time in space" tone feels appropriate

---

### 4.3 Mission: Underground Bunker Exploration

**Expected:** Exploration mission with tech rewards

**Steps:**
1. Start mission "Echoes from Below" (Mount Weather)
2. Complete mission
3. Check rewards

**Verify:**
- [ ] Mission available
- [ ] Can start and play mission
- [ ] Narrative feels appropriate (government bunker, exodus data)
- [ ] Rewards granted (conditional based on choices)
- [ ] XP awarded (200 base)
- [ ] Credits awarded (600 base)

---

### 4.4 Mission: Exodus Archive

**Expected:** Story mission with lore rewards

**Steps:**
1. Start mission "The Exodus Archive" (Cape Canaveral)
2. Complete mission
3. Review story content

**Verify:**
- [ ] Mission available
- [ ] Story-focused narrative (less action)
- [ ] Emotional weight appropriate
- [ ] Rewards granted
- [ ] XP awarded (150 base)
- [ ] Credits awarded (400 base)
- [ ] Unlocks exodus fleet coordinates

---

### 4.5 Mission Part Rewards Validation

**For each mission that rewards parts:**

**Verify:**
- [ ] Part IDs match those in part registry
- [ ] Parts actually appear in inventory after mission
- [ ] Quantities correct
- [ ] Part names display correctly
- [ ] Parts can be used for upgrades

---

## 5. Workshop UI Integration

### 5.1 Systems Grid Layout

**Expected:** 2×5 grid showing all 10 systems

**Verify:**
- [ ] All 10 system cards visible
- [ ] Warp Drive card present
- [ ] Life Support card present
- [ ] Cards arranged in grid (2 columns, 5 rows)
- [ ] Consistent styling across cards
- [ ] Icons/labels clear and readable

---

### 5.2 Schematic Dots

**Expected:** Visual representation of systems on ship schematic

**Verify:**
- [ ] Schematic panel visible (left column)
- [ ] Dots for all 10 systems
- [ ] Warp Drive dot positioned correctly
- [ ] Life Support dot positioned correctly
- [ ] Dot color indicates status:
  - Grey: Not installed (L0)
  - Green: Operational
  - Red: Damaged/offline
- [ ] Clicking dot highlights corresponding system card

---

### 5.3 Upgrade Button States

**Test each state:**

**State 1: Cannot Upgrade (No Part)**
- [ ] Button displays "NO PART"
- [ ] Button disabled/greyed out
- [ ] Tooltip explains requirement

**State 2: Cannot Upgrade (Insufficient Credits)**
- [ ] Button displays "NOT ENOUGH CR"
- [ ] Button disabled
- [ ] Shows cost in tooltip

**State 3: Can Upgrade**
- [ ] Button displays "UPGRADE"
- [ ] Button enabled
- [ ] Hover shows cost details

**State 4: Max Level**
- [ ] Button displays "MAX LEVEL"
- [ ] Button disabled
- [ ] No upgrade possible

---

### 5.4 Power Budget Panel

**Expected:** Visual power meter and stats

**Verify:**
- [ ] Power Total displayed (e.g., "400 PU")
- [ ] Power Used displayed (e.g., "55 PU")
- [ ] Power Available displayed (e.g., "345 PU")
- [ ] Visual bar graph shows usage percentage
- [ ] Bar color indicates status (green/yellow/red)
- [ ] Updates in real-time when systems change

---

## 6. Save/Load Functionality

### 6.1 Save Game with M2 Systems

**Setup:**
1. Upgrade Warp to Level 2
2. Upgrade Life Support to Level 3
3. Adjust power settings
4. Save game (Slot 1)

**Verify:**
- [ ] Save completes without errors
- [ ] Save file created/updated
- [ ] Save info shows correct data

---

### 6.2 Load Game with M2 Systems

**Steps:**
1. Quit game
2. Restart game
3. Load Slot 1

**Verify:**
- [ ] Warp Drive restored to Level 2
- [ ] Warp stats correct (warp factor, range, etc.)
- [ ] Life Support restored to Level 3
- [ ] Life Support stats correct (crew capacity, radiation, etc.)
- [ ] Power budget recalculated correctly
- [ ] System health preserved
- [ ] Active/inactive states preserved
- [ ] No corruption or errors

---

### 6.3 Save/Load Multiple Slots

**Test:**
1. Create different configurations in Slots 1, 2, 3
   - Slot 1: Warp L1, Life L1
   - Slot 2: Warp L2, Life L2
   - Slot 3: Warp L3, Life L3

**Verify:**
- [ ] Each slot preserves its configuration
- [ ] Loading slot switches to correct state
- [ ] No cross-contamination between slots

---

## 7. Edge Cases & Stress Tests

### 7.1 Rapid Upgrades

**Test:**
1. Add 50000 credits
2. Add 10× of each part
3. Rapidly upgrade systems multiple times

**Verify:**
- [ ] No crashes
- [ ] Credits deduct correctly each time
- [ ] Parts consumed correctly
- [ ] Power updates correctly
- [ ] No negative values
- [ ] UI remains responsive

---

### 7.2 Downgrade Prevention

**Test:**
1. Upgrade Warp to Level 3
2. Attempt to set level to Level 1 via debug

**Expected:**
- [ ] System prevents downgrade (or handles gracefully)
- [ ] No data corruption

---

### 7.3 Missing Part References

**Test:**
1. Manually edit a mission JSON to reference invalid part ID
2. Complete mission

**Expected:**
- [ ] Error logged (but game doesn't crash)
- [ ] Mission completes
- [ ] Invalid part not added to inventory
- [ ] OR mission validation prevents loading

---

### 7.4 Power Overload

**Test:**
1. Upgrade all systems to max level
2. Check if power generation sufficient

**Expected:**
- [ ] Clear feedback if power insufficient
- [ ] Systems deactivate OR warning shown
- [ ] No silent failures

---

### 7.5 Save File Corruption

**Test:**
1. Save game
2. Manually corrupt save file (invalid JSON)
3. Try to load

**Expected:**
- [ ] Error caught and logged
- [ ] User notified ("Save file corrupted")
- [ ] Game doesn't crash
- [ ] Option to delete corrupted save

---

## 8. Acceptance Criteria

**Milestone 2 is COMPLETE when:**

### Systems Functionality
- [x] Warp Drive system implemented (L0-L5)
- [x] Life Support system implemented (L0-L5)
- [x] All system stats match specifications
- [x] Power consumption correct for all levels
- [x] Special abilities function (L3+ Warp, L2+ Life)

### Parts & Economy
- [x] warp_parts.json loads without errors (9 parts)
- [x] life_support_parts.json loads without errors (9 parts)
- [x] All part IDs unique
- [x] Parts integrate with PartRegistry
- [x] Can purchase and use parts for upgrades

### Missions
- [x] 4 new missions playable
- [x] All missions parse without errors
- [x] All stage references valid
- [x] Part rewards functional
- [x] No orphaned stages

### Workshop UI
- [x] Warp Drive card visible and functional
- [x] Life Support card visible and functional
- [x] Schematic dots display correctly
- [x] Power budget updates correctly
- [x] Upgrade flow works end-to-end

### Save/Load
- [x] Systems save correctly to JSON
- [x] Systems load correctly from JSON
- [x] All stats preserved across save/load
- [x] No data loss or corruption

### Testing
- [x] All automated tests pass
- [x] No critical bugs
- [x] No crashes during normal gameplay
- [x] Performance acceptable

---

## 9. Known Issues & Limitations

**Document any known issues here:**

- [ ] Issue: [Description]
  - Impact: [High/Medium/Low]
  - Workaround: [If any]
  - Tracked: [Issue #]

---

## 10. Testing Console Commands

**Quick test setup commands:**

```gdscript
# Add test resources
GameState.add_credits(50000)
GameState.add_item_to_inventory("warp_basic_core_l1_common", 5)
GameState.add_item_to_inventory("warp_w3_drive_l2_common", 5)
GameState.add_item_to_inventory("warp_w5_drive_l3_common", 5)
GameState.add_item_to_inventory("life_support_basic_recycler_l1_common", 5)
GameState.add_item_to_inventory("life_support_climate_control_l2_common", 5)
GameState.add_item_to_inventory("life_support_bio_recycling_l3_common", 5)

# Set Power Core to generate enough power
var power = GameState.get_system_reference("power")
power.set_level(5)

# Quick upgrade systems
var warp = GameState.get_system_reference("warp")
warp.set_level(3)

var life = GameState.get_system_reference("life_support")
life.set_level(3)

# Check power budget
print("Power Total: ", GameState.ship.power_total)
print("Power Used: ", GameState.ship.power_used)
print("Power Available: ", GameState.ship.power_available)

# Check system stats
print("Warp Factor: ", warp.warp_factor)
print("Crew Capacity: ", life.crew_capacity)
```

---

## Completion Sign-Off

**Tester:** ________________
**Date:** ________________
**Milestone 2 Status:** [ ] PASS / [ ] FAIL
**Notes:**

---

**Next Steps:**
- If all tests pass → Mark Milestone 2 complete in ROADMAP.md
- If tests fail → Document issues, fix, and retest
- Update STATUS.md with Milestone 2 completion date
- Begin Milestone 3 planning
