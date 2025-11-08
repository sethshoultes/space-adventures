# Reward Balance Calculator & Economy Spreadsheet

**Version:** 1.0
**Date:** November 7, 2025
**Purpose:** Comprehensive calculator for balancing XP, credits, parts, and progression in Space Adventures
**Audience:** Game designers, content creators, balancing team, AI content generators

---

## Table of Contents
1. [XP Progression Table](#xp-progression-table)
2. [Credit Economy Table](#credit-economy-table)
3. [Mission Reward Calculator](#mission-reward-calculator)
4. [Progression Gate Analysis](#progression-gate-analysis)
5. [Balance Validation Tools](#balance-validation-tools)
6. [Example Calculations](#example-calculations)

---

## XP Progression Table

### Level Progression (1-10)

| Level | XP Needed | Total XP | Rank | Missions Needed* | Hours Est. |
|-------|-----------|----------|------|------------------|------------|
| 1 | 0 | 0 | Cadet | 0 | 0.0 |
| 2 | 100 | 100 | Cadet | 1 | 0.3 |
| 3 | 150 | 250 | Ensign | 2-3 | 0.8 |
| 4 | 200 | 450 | Ensign | 4-5 | 1.4 |
| 5 | 250 | 700 | Lieutenant JG | 6-7 | 2.2 |
| 6 | 300 | 1,000 | Lieutenant JG | 8-10 | 3.1 |
| 7 | 350 | 1,350 | Lieutenant | 11-13 | 4.2 |
| 8 | 400 | 1,750 | Lieutenant | 14-17 | 5.5 |
| 9 | 450 | 2,200 | Lt. Commander | 18-22 | 6.9 |
| 10 | 500 | 2,700 | Lt. Commander | 23-27 | 8.4 |

**\*Based on average 100 XP per mission**
**Time estimate:** ~20 minutes per mission (includes cutscenes, choices, reading)

### XP Formula
```
XP for Level = 100 + ((Level - 1) * 50)

Total XP for Level N = Σ(100 + ((i - 1) * 50)) for i = 1 to N-1
```

### Missions Needed by Difficulty

**Average XP per mission difficulty:**

| Difficulty | Base XP | With Bonuses | Missions to Level 10 |
|------------|---------|--------------|---------------------|
| Tutorial (★) | 100-150 | 175-250 | 11-27 |
| Easy (★★) | 100-150 | 150-200 | 14-27 |
| Medium (★★★) | 150-200 | 200-275 | 10-18 |
| Hard (★★★★) | 200-300 | 250-350 | 8-11 |
| Very Hard (★★★★★) | 300-400 | 350-500 | 5-8 |

**Mixed difficulty progression (realistic):**
- 1 Tutorial (★): 175 XP
- 12 Easy (★★): 1,800 XP (150 avg)
- 8 Medium (★★★): 1,600 XP (200 avg)
- 4 Hard (★★★★): 1,000 XP (250 avg)
- **Total: 25 missions = 4,575 XP (exceeds Level 10 requirement of 2,700 XP)**

---

## Credit Economy Table

### System Upgrade Costs

**Base cost formula:** `credits = base_cost * rarity_multiplier`

**Rarity multipliers:**
- Common: 1.0×
- Uncommon: 1.5×
- Rare: 2.0×

| System | Level | Base Cost | Common | Uncommon | Rare |
|--------|-------|-----------|--------|----------|------|
| **Hull** | 1 | 100 | 100 | 150 | 200 |
| | 2 | 200 | 200 | 300 | 400 |
| | 3 | 300 | 300 | 450 | 600 |
| **Power** | 1 | 100 | 100 | 150 | 200 |
| | 2 | 200 | 200 | 300 | 400 |
| | 3 | 300 | 300 | 450 | 600 |
| **Propulsion** | 1 | 100 | 100 | 150 | 200 |
| | 2 | 200 | 200 | 300 | 400 |
| | 3 | 300 | 300 | 450 | 600 |
| **Warp** | 1 | 100 | 100 | 150 | 200 |
| | 2 | 200 | 200 | 300 | 400 |
| | 3 | 300 | 300 | 450 | 600 |
| **Life Support** | 1 | 100 | 100 | 150 | 200 |
| | 2 | 200 | 200 | 300 | 400 |
| | 3 | 300 | 300 | 450 | 600 |
| **Computer** | 1 | 100 | 100 | 150 | 200 |
| | 2 | 200 | 200 | 300 | 400 |
| | 3 | 300 | 300 | 450 | 600 |
| **Sensors** | 1 | 100 | 100 | 150 | 200 |
| | 2 | 200 | 200 | 300 | 400 |
| | 3 | 300 | 300 | 450 | 600 |
| **Shields** | 1 | 100 | 100 | 150 | 200 |
| | 2 | 200 | 200 | 300 | 400 |
| | 3 | 300 | 300 | 450 | 600 |
| **Weapons** | 1 | 100 | 100 | 150 | 200 |
| | 2 | 200 | 200 | 300 | 400 |
| | 3 | 300 | 300 | 450 | 600 |
| **Communications** | 1 | 100 | 100 | 150 | 200 |
| | 2 | 200 | 200 | 300 | 400 |
| | 3 | 300 | 300 | 450 | 600 |

### Total Cost Calculations

**All 10 systems to Level 1 (common parts):**
```
10 systems × 100 credits = 1,000 credits
```

**All 10 systems to Level 2 (common parts):**
```
Level 1: 10 × 100 = 1,000
Level 2: 10 × 200 = 2,000
Total: 3,000 credits
```

**All 10 systems to Level 3 (common parts):**
```
Level 1: 10 × 100 = 1,000
Level 2: 10 × 200 = 2,000
Level 3: 10 × 300 = 3,000
Total: 6,000 credits
```

**Mixed rarity upgrade (realistic):**
```
Level 1: 7 common (700) + 3 uncommon (450) = 1,150 credits
Level 2: 5 common (1,000) + 4 uncommon (1,200) + 1 rare (400) = 2,600 credits
Level 3: 3 common (900) + 5 uncommon (2,250) + 2 rare (1,200) = 4,350 credits
Total: 8,100 credits
```

### Credits Earned per Mission

| Difficulty | Min | Max | Average |
|------------|-----|-----|---------|
| Tutorial (★) | 300 | 500 | 400 |
| Easy (★★) | 200 | 400 | 300 |
| Medium (★★★) | 300 | 600 | 450 |
| Hard (★★★★) | 400 | 800 | 600 |
| Very Hard (★★★★★) | 500 | 1,000 | 750 |

### Missions Needed for Credit Goals

**Goal: All Level 1 systems (1,000 credits)**
- 3 tutorial missions (400 avg) = 1,200 credits ✅

**Goal: All Level 2 systems (3,000 credits total)**
- 10 mixed missions (300 avg) = 3,000 credits ✅

**Goal: All Level 3 systems (6,000 credits total)**
- 20 mixed missions (300 avg) = 6,000 credits ✅

**Realistic mixed difficulty (25 missions to Level 10):**
```
1 Tutorial: 400
12 Easy: 3,600 (300 avg)
8 Medium: 3,600 (450 avg)
4 Hard: 2,400 (600 avg)
Total: 10,000 credits
```
**Result:** Enough for all Level 3 systems (6,000) + 4,000 credits for repairs/trading

---

## Mission Reward Calculator

### Base Reward Formula

**XP Formula:**
```
base_xp = 50 + (difficulty * 50)
variance = ±25
final_xp = base_xp + random(-variance, variance)

Difficulty 1: 75-125 XP
Difficulty 2: 125-175 XP
Difficulty 3: 175-225 XP
Difficulty 4: 225-275 XP
Difficulty 5: 275-325 XP
```

**Credits Formula:**
```
base_credits = 200 + (difficulty * 150)
variance = ±100
final_credits = base_credits + random(-variance, variance)

Difficulty 1: 250-450 credits
Difficulty 2: 400-600 credits
Difficulty 3: 550-750 credits
Difficulty 4: 700-900 credits
Difficulty 5: 850-1,050 credits
```

### Bonus XP Calculator

| Bonus Type | Skill Level | XP Bonus | Example |
|------------|-------------|----------|---------|
| Skill Check (Low) | 1-2 | +15 | "Examine logs" |
| Skill Check (Medium) | 3-4 | +25 | "Hack terminal" |
| Skill Check (High) | 5+ | +40 | "Advanced repair" |
| Discovery (Minor) | Any | +15 | "Find backstory" |
| Discovery (Moderate) | 2+ | +30 | "Scan hidden cache" |
| Discovery (Major) | 4+ | +50 | "Uncover mystery" |
| Perfect Completion | - | +50 | "All objectives done" |
| Exceptional Outcome | - | +100 | "Best possible result" |

### Example Mission Rewards

**Easy Salvage Mission (Difficulty 2):**
```
Base XP: 150
Base Credits: 500
Parts: 1-2 common hull/propulsion parts
Weight: 25-30 kg

Player choices:
- Direct path: 150 XP, 500 credits
- Explore side area: +15 XP discovery
- Engineering check success: +25 XP skill bonus
- Total possible: 190 XP, 500 credits, 2 parts
```

**Medium Exploration Mission (Difficulty 3):**
```
Base XP: 200
Base Credits: 650
Parts: 1-2 parts (1 uncommon)
Weight: 20-35 kg

Player choices:
- Quick completion: 200 XP, 650 credits
- Scan anomaly: +30 XP discovery
- Science check: +25 XP skill bonus
- Hidden location: +30 XP discovery
- Total possible: 285 XP, 650 credits, 2 parts
```

**Hard Story Mission (Difficulty 4):**
```
Base XP: 250
Base Credits: 800
Parts: 2-3 parts (1-2 uncommon/rare)
Weight: 30-50 kg

Player choices:
- Standard path: 250 XP, 800 credits
- Diplomatic resolution: +30 XP skill bonus
- Major revelation: +50 XP discovery
- Perfect completion: +50 XP bonus
- Total possible: 380 XP, 800 credits, 3 parts
```

### Part Distribution Table

| Difficulty | Common | Uncommon | Rare | Total Parts |
|------------|--------|----------|------|-------------|
| Tutorial (★) | 2-3 | 0 | 0 | 2-3 |
| Easy (★★) | 1-2 | 0-1 | 0 | 1-2 |
| Medium (★★★) | 1-2 | 1 | 0 | 1-2 |
| Hard (★★★★) | 2 | 1-2 | 0-1 | 2-3 |
| Very Hard (★★★★★) | 2 | 2 | 1-2 | 2-3 |

---

## Progression Gate Analysis

### Critical Milestones

**Phase 1 → Phase 2 Transition:**
- **Requirement:** All 10 systems at Level 1 minimum
- **Parts needed:** 10 parts (ideally common)
- **Credits needed:** 1,000 (if purchasing all)
- **Missions needed:** ~5-7 missions (tutorial + story missions provide parts)

**Comfortable Play Experience (Level 2 systems):**
- **Requirement:** All systems at Level 2
- **Parts needed:** 20 parts total (10 Level 1 + 10 Level 2)
- **Credits needed:** 3,000 total
- **Missions needed:** ~12-15 missions

**Challenge Readiness (Level 3 systems):**
- **Requirement:** Most systems at Level 3
- **Parts needed:** 30 parts total
- **Credits needed:** 6,000 total
- **Missions needed:** ~20-25 missions

### Parts Needed for Full Progression

**Level 1 (Phase 2 unlock):**
```
10 systems × 1 part each = 10 parts
Story missions guarantee 7-8 of these
Player must find 2-3 via optional missions
```

**Level 2 (Comfortable progression):**
```
10 systems × 1 part each = 10 additional parts
Mix of common (70%) and uncommon (30%)
Missions provide enough parts naturally
```

**Level 3 (Milestone 1 cap):**
```
10 systems × 1 part each = 10 additional parts
Mix of common (50%), uncommon (40%), rare (10%)
Player must seek out rare parts
```

### Timeline Estimates

**Speedrun (minimal side content):**
- Tutorial: 1 mission (0.3 hours)
- Story missions: 6 missions (2 hours)
- Required upgrades: 3 missions (1 hour)
- **Total: 10 missions, 3.3 hours to Phase 2**

**Normal playthrough:**
- Tutorial: 1 mission
- Story missions: 6-8 missions
- Optional content: 8-10 missions
- Exploration: 3-5 missions
- **Total: 18-24 missions, 6-8 hours to Phase 2**

**Completionist:**
- All available missions: 30+ missions
- All optional objectives completed
- All parts discovered
- All ship classes tried
- **Total: 30+ missions, 10+ hours to Phase 2**

---

## Balance Validation Tools

### Economy Health Checks

**XP Pacing Check:**
```
Average XP per mission = Total XP earned / Missions completed
Target: 125-175 XP per mission

Example:
25 missions = 3,750 XP total
3,750 / 25 = 150 XP per mission ✅ (within target)
```

**Credit Flow Check:**
```
Credits earned per hour = Total credits / Hours played
Target: 800-1,200 credits per hour

Example:
8 hours = 8,000 credits
8,000 / 8 = 1,000 credits/hour ✅ (within target)
```

**Upgrade Affordability Check:**
```
Mission credits / Upgrade cost = Missions per upgrade
Target: 2-4 missions per Level 1 upgrade

Example:
Average 350 credits per mission
100 credit upgrade = 0.3 missions ✅ (affordable)
200 credit upgrade = 0.6 missions ✅ (affordable)
300 credit upgrade = 0.9 missions ✅ (affordable)
```

### Red Flags Checklist

**❌ Economy Too Generous:**
- [ ] Player can afford all Level 3 upgrades in <15 missions
- [ ] Player reaches Level 10 in <20 missions
- [ ] Credits exceed 10,000 before Phase 2
- [ ] Player has 20+ spare parts in storage

**❌ Economy Too Stingy:**
- [ ] Player cannot afford Level 1 upgrades after 10 missions
- [ ] Player reaches Level 5 after 20+ missions
- [ ] Credits below 500 at mission 10+
- [ ] Player stuck waiting for story parts after 15 missions

**❌ Progression Blockers:**
- [ ] Required parts not available
- [ ] Mission difficulty spike without warning
- [ ] Skill checks impossible with current level
- [ ] Phase 2 unlock delayed past 25 missions

**✅ Healthy Balance Indicators:**
- [x] Player reaches Level 5 around mission 10-12
- [x] Player can afford mixed-rarity upgrades regularly
- [x] Credits hover around 1,000-3,000 mid-game
- [x] Phase 2 unlocks around mission 15-20
- [x] Player has choices in upgrade order
- [x] Optional content feels rewarding, not mandatory

### Difficulty Curve Validation

**Mission 1-5 (Tutorial Phase):**
- **Difficulty:** ★-★★
- **XP:** 400-600 total
- **Credits:** 1,500-2,000 total
- **Goal:** Reach Level 2-3, unlock basic systems

**Mission 6-15 (Early Game):**
- **Difficulty:** ★★-★★★
- **XP:** 1,500-2,000 total
- **Credits:** 3,000-4,500 total
- **Goal:** Reach Level 5-7, all Level 1-2 systems

**Mission 16-25 (Mid Game):**
- **Difficulty:** ★★★-★★★★
- **XP:** 2,000-3,000 total
- **Credits:** 4,000-6,000 total
- **Goal:** Reach Level 8-10, unlock Phase 2

---

## Example Calculations

### Example 1: "How many missions to reach Level 5?"

**Given:**
- Starting Level: 1
- Target Level: 5
- XP needed: 700 total

**Average mission XP by difficulty:**
- Easy (★★): 150 XP
- Medium (★★★): 200 XP

**Calculation:**
```
Option A (all easy missions):
700 XP / 150 XP = 4.7 missions → 5 easy missions

Option B (mixed difficulty):
Tutorial (★): 175 XP
3 Easy (★★): 450 XP (150 avg)
1 Medium (★★★): 200 XP
Total: 825 XP → 5 missions
```

**Answer:** 5-7 missions depending on difficulty mix and bonuses

---

### Example 2: "Credits needed for all Level 1 systems?"

**Given:**
- 10 ship systems
- Target level: 1
- Part rarity: common

**Calculation:**
```
10 systems × 100 credits (Level 1 common) = 1,000 credits

Missions needed (average 350 credits):
1,000 / 350 = 2.9 missions → 3 missions
```

**With tutorial reward:**
```
Tutorial: 400 credits
Remaining: 1,000 - 400 = 600 credits
600 / 350 = 1.7 missions → 2 more missions
Total: 3 missions (1 tutorial + 2 easy)
```

**Answer:** 3 missions (if using common parts)

---

### Example 3: "Unlock warp drive - what's the path?"

**Warp Drive Requirements:**
- Level 1 warp system installed
- Cost: 100 credits + 1 warp part (common)

**Fastest path:**
```
Mission 1 (Tutorial):
  - Reward: 175 XP, 400 credits, 2 parts (hull, power)
  - Result: Level 1 hull and power installed

Mission 2 (Story: "Search for the Drive"):
  - Reward: 150 XP, 300 credits, 1 warp part (guaranteed)
  - Result: Warp part acquired

Workshop:
  - Spend 100 credits to install warp part
  - Result: Level 1 warp system installed ✅
```

**Answer:** 2 missions + 100 credits = Warp drive operational

---

### Example 4: "Player at mission 15 - are they on track?"

**Expected progression at mission 15:**

**Level:**
```
Assuming 150 XP average:
15 missions × 150 XP = 2,250 XP
Target Level: Between 8-9 ✅
```

**Credits:**
```
Assuming 400 credits average:
15 missions × 400 credits = 6,000 credits
Target: 3,000-5,000 credits ✅
```

**Systems:**
```
Expected: 7-10 systems at Level 1
Expected: 4-7 systems at Level 2
Expected: 0-3 systems at Level 3
```

**Answer:** On track for normal progression if XP and credits align

---

### Example 5: "Balance a new mission - Difficulty 3"

**Design parameters:**
- Difficulty: 3 (★★★)
- Type: Exploration
- Player level: 5-7

**Calculations:**

**XP Range:**
```
Base: 50 + (3 × 50) = 200 XP
Variance: ±25 XP
Range: 175-225 XP

Bonuses:
- Scan anomaly: +30 XP
- Science check: +25 XP
Total possible: 280 XP
```

**Credits Range:**
```
Base: 200 + (3 × 150) = 650 credits
Variance: ±100 credits
Range: 550-750 credits
Final: 650 credits (average)
```

**Parts:**
```
Difficulty 3 guideline:
- 1-2 parts
- 1 uncommon required
- Rarity: 50% common, 35% uncommon, 15% rare

Award: 1 common sensor part + 1 uncommon computer part
```

**Final mission rewards:**
```json
{
  "rewards": {
    "xp": 200,
    "credits": 650,
    "items": [
      {"part_id": "sensors_basic_array_l1_common", "quantity": 1},
      {"part_id": "computer_neural_net_l1_uncommon", "quantity": 1}
    ]
  },
  "bonus_xp": {
    "scan_anomaly": 30,
    "science_check": 25
  }
}
```

**Validation:**
```
✅ XP within 175-225 range
✅ Credits within 550-750 range
✅ Part count: 2 (matches difficulty 3)
✅ Rarity mix: 1 common + 1 uncommon (appropriate)
✅ Total possible XP: 255 (reasonable bonus)
```

---

### Example 6: "Spreadsheet Copy-Paste - Full Progression Table"

**Copy this table to Excel/Google Sheets:**

```
Level	XP_Needed	Total_XP	Missions_Avg	Missions_Easy	Missions_Med	Missions_Hard	Credits_Needed_L1	Credits_Needed_L2	Credits_Needed_L3
1	0	0	0	0	0	0	0	0	0
2	100	100	1	1	1	1	100	300	600
3	150	250	3	2	2	1	200	600	1200
4	200	450	5	3	3	2	300	900	1800
5	250	700	7	5	4	3	400	1200	2400
6	300	1000	10	7	5	4	500	1500	3000
7	350	1350	14	9	7	5	600	1800	3600
8	400	1750	18	12	9	6	700	2100	4200
9	450	2200	22	15	11	7	800	2400	4800
10	500	2700	27	18	14	8	1000	3000	6000
```

**Formula columns:**
- Missions_Avg: `=Total_XP / 100`
- Missions_Easy: `=Total_XP / 150`
- Missions_Med: `=Total_XP / 200`
- Missions_Hard: `=Total_XP / 300`
- Credits_Needed_L1: `=Level * 10 * 100`
- Credits_Needed_L2: `=Level * 10 * 300`
- Credits_Needed_L3: `=Level * 10 * 600`

---

## Summary & Quick Reference

### Key Ratios (Healthy Economy)

**XP per Mission:** 125-175 XP average
**Credits per Mission:** 300-500 credits average
**Credits per Hour:** 800-1,200 credits
**Missions to Level 10:** 20-27 missions
**Hours to Phase 2:** 6-10 hours

### Upgrade Cost Summary

**Level 1 (Common):** 100 credits × 10 systems = 1,000 credits
**Level 2 (Common):** 200 credits × 10 systems = 2,000 credits
**Level 3 (Common):** 300 credits × 10 systems = 3,000 credits
**Full L1-L3:** 6,000 credits total

### Part Requirements

**Phase 2 Unlock:** 10 Level 1 parts (mostly common)
**Comfortable Play:** 20 total parts (L1 + L2)
**Challenge Ready:** 30 total parts (L1 + L2 + L3)

### Validation Checklist

**✅ Economy is healthy if:**
- Player reaches Level 5 by mission 10-12
- Player has 1,000-3,000 credits mid-game
- All Level 1 systems installed by mission 8-10
- Phase 2 unlocks between mission 15-20
- Player has upgrade choices, not bottlenecks

**❌ Economy needs tuning if:**
- Player stuck below Level 3 after 10 missions
- Credits below 500 at mission 10+
- Cannot afford basic upgrades regularly
- Phase 2 delayed past mission 25
- Forced to grind for specific parts

---

**Document Status:** Complete v1.0
**Last Updated:** November 7, 2025
**Related Documents:**
- [Mission Reward Guidelines](./mission-reward-guidelines.md)
- [Player Progression System](../core-systems/player-progression-system.md)
- [Ship Systems](../ship-systems/ship-systems.md)

**For Questions:** Consult game design team or use this calculator to validate mission rewards before implementation.
