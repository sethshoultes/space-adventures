# Space Adventures - Complete Ship Systems Guide

**Version:** 1.0
**Date:** November 13, 2025
**Purpose:** Visual reference and strategy guide for all 10 ship systems
**Audience:** Developers, players, and designers

---

## Table of Contents

1. [Overview: The 10 Core Systems](#overview-the-10-core-systems)
2. [Power Budget Planning](#power-budget-planning)
3. [Individual System Profiles](#individual-system-profiles)
   - [1. Hull & Structure](#1-hull--structure)
   - [2. Power Core](#2-power-core)
   - [3. Propulsion (Impulse Engines)](#3-propulsion-impulse-engines)
   - [4. Warp Drive](#4-warp-drive)
   - [5. Life Support](#5-life-support)
   - [6. Computer Core](#6-computer-core)
   - [7. Sensors](#7-sensors)
   - [8. Shields](#8-shields)
   - [9. Weapons](#9-weapons)
   - [10. Communications Array](#10-communications-array)
4. [Ship Configuration Examples](#ship-configuration-examples)
5. [Upgrade Strategies](#upgrade-strategies)
6. [System Synergies](#system-synergies)
7. [Quick Reference Cards](#quick-reference-cards)

---

## Overview: The 10 Core Systems

### System Comparison Table

| System | Critical? | Power Range | Primary Function | Phase 1 Req. | Phase 2 Focus |
|--------|-----------|-------------|------------------|--------------|---------------|
| **Hull & Structure** | ✓ | 0-10 PU | Survivability | L1 minimum | L3+ for combat |
| **Power Core** | ✓ | 0 PU | Energy generation | L1 minimum | L3+ for advanced systems |
| **Propulsion** | ✓ | 10-60 PU | Sub-light movement | L1 minimum | L3+ for combat agility |
| **Warp Drive** | ✓ | 20-120 PU | FTL travel | **L1 to exit Phase 1** | L3-5 for exploration |
| **Life Support** | ✓ | 5-35 PU | Crew survival | L1 minimum | L3+ for crew system |
| **Computer Core** | ✓ | 5-50 PU | AI assistance | L1 minimum | L3+ for tactical AI |
| **Sensors** | ✓ | 5-50 PU | Detection | L1 minimum | L3+ for scanning |
| **Shields** | Optional | 15-85 PU | Defense | Not required | L2-3 for combat |
| **Weapons** | Optional | 10-80 PU | Offense | Not required | L2-3 for combat |
| **Communications** | ✓ | 5-25 PU | Diplomacy | L1 minimum | L3+ for aliens |

**Legend:**
- **Critical:** Required for basic ship operation
- **Power Range:** Minimum to maximum power consumption
- **Phase 1 Req.:** All systems must reach Level 1 to unlock Phase 2
- L = Level

### System Level Progression

```
LEVEL 0: NOT INSTALLED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
System non-functional, ship capability severely limited

LEVEL 1: BASIC ★
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Minimum viable functionality, salvaged/cobbled together
Power: Low (5-20 PU per system)
Phase 1 accessible with all systems at L1

LEVEL 2: STANDARD ★★
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Reliable, professional-grade equipment
Power: Moderate (8-30 PU per system)
Early Phase 2 recommended baseline

LEVEL 3: ADVANCED ★★★
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Military/commercial grade with special abilities
Power: High (12-50 PU per system)
Mid-game sweet spot for balanced builds

LEVEL 4: MILITARY ★★★★
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Cutting-edge military technology
Power: Very High (18-80 PU per system)
Late-game specialized builds

LEVEL 5: EXPERIMENTAL ★★★★★
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Prototype/illegal/experimental tech
Power: Extreme (25-120 PU per system)
Endgame maximum capability
```

---

## Power Budget Planning

### Power Generation by Level

| Power Core Level | Output (PU) | Efficiency | Cost Reduction | Special Ability |
|------------------|-------------|------------|----------------|-----------------|
| **L0** | 0 | 0% | 0% | None |
| **L1** | 100 | 80% | 0% | Basic operation |
| **L2** | 200 | 85% | **-10%** | All systems 10% cheaper |
| **L3** | 400 | 90% | **-15%** | All systems 15% cheaper |
| **L4** | 700 | 93% | **-20%** | +100 PU emergency reserve |
| **L5** | 1000 | 98% | **-25%** | +5 PU/turn regeneration |

### Power Budget Milestones

#### Phase 1 Completion (All Systems L1)
```
REQUIRED SYSTEMS          BASE COST    WITH L1 POWER    ACTUAL COST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Hull L1                   0 PU         0 PU             0 PU
Power L1                  0 PU         0 PU             0 PU
Propulsion L1            10 PU        10 PU            10 PU
Warp L1                  20 PU        20 PU            20 PU
Life Support L1           5 PU         5 PU             5 PU
Computer L1               5 PU         5 PU             5 PU
Sensors L1                5 PU         5 PU             5 PU
Shields L1               15 PU        15 PU            15 PU
Weapons L1               10 PU        10 PU            10 PU
Communications L1         5 PU         5 PU             5 PU
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOTAL CONSUMPTION:       75 PU        75 PU            75 PU
POWER AVAILABLE (L1):   100 PU       100 PU           100 PU
SURPLUS:                 25 PU        25 PU            25 PU
```
**Status:** ✓ Sustainable - Room for growth

#### Early Phase 2 (Balanced L2)
```
SYSTEM                   BASE COST    WITH L2 POWER    ACTUAL COST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Hull L2                   0 PU         0 PU             0 PU
Power L2                  0 PU         0 PU             0 PU
Propulsion L2            15 PU        -10%            13.5 PU
Warp L2                  30 PU        -10%              27 PU
Life Support L2          10 PU        -10%               9 PU
Computer L2              10 PU        -10%               9 PU
Sensors L2               10 PU        -10%               9 PU
Shields L2               25 PU        -10%            22.5 PU
Weapons L2               20 PU        -10%              18 PU
Communications L2         8 PU        -10%             7.2 PU
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOTAL CONSUMPTION:      128 PU        -10%           115.2 PU
POWER AVAILABLE (L2):   200 PU       200 PU           200 PU
SURPLUS:                 72 PU                        84.8 PU
```
**Status:** ✓ Comfortable - Good headroom for upgrades

#### Mid-Game (Combat-Ready L3)
```
SYSTEM                   BASE COST    WITH L3 POWER    ACTUAL COST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Hull L3                   0 PU         0 PU             0 PU
Power L3                  0 PU         0 PU             0 PU
Propulsion L3            25 PU        -15%            21.3 PU
Warp L3                  50 PU        -15%            42.5 PU
Life Support L3          15 PU        -15%            12.8 PU
Computer L3              20 PU        -15%              17 PU
Sensors L3               20 PU        -15%              17 PU
Shields L3               40 PU        -15%              34 PU
Weapons L3               35 PU        -15%            29.8 PU
Communications L3        12 PU        -15%            10.2 PU
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOTAL CONSUMPTION:      217 PU        -15%           184.6 PU
POWER AVAILABLE (L3):   400 PU       400 PU           400 PU
SURPLUS:                183 PU                       215.4 PU
```
**Status:** ✓ Excellent - Can support L4-5 systems selectively

### Power Management Strategies

**Strategy 1: Essential Systems Priority**
```
HIGH PRIORITY (Always Active):
  ⚡ Power Core    - 0 PU  (generates power)
  🛡️ Hull          - 0 PU  (passive protection)
  💨 Propulsion    - XX PU (mobility)
  ❤️  Life Support - XX PU (survival)

MEDIUM PRIORITY (Combat/Exploration):
  🔍 Sensors       - XX PU (when exploring)
  🛡️ Shields       - XX PU (when threatened)
  🎯 Weapons       - XX PU (when fighting)

LOW PRIORITY (As Needed):
  🌌 Warp Drive    - XX PU (only when traveling)
  💻 Computer      - XX PU (constant for AI)
  📡 Communications- XX PU (diplomacy/missions)
```

**Strategy 2: Power Scaling Curve**
```
Level 1 → 2: +15 PU per system average
Level 2 → 3: +25 PU per system average
Level 3 → 4: +40 PU per system average
Level 4 → 5: +55 PU per system average

Recommended Power Core Levels:
  L1 Systems → Power L1 (100 PU)   ✓
  L2 Systems → Power L2 (200 PU)   ✓
  L3 Systems → Power L3 (400 PU)   ✓
  L4 Systems → Power L4 (700 PU)   Recommended
  L5 Systems → Power L5 (1000 PU)  Required
```

**Critical Insight:** The Power Core's cost reduction bonus (up to -25% at L5) is multiplicative with system upgrades. Upgrading Power Core early provides compounding benefits.

---

## Individual System Profiles

### 1. Hull & Structure

```
┌──────────────────────────────────────────────────────────────┐
│ 🛡️  HULL & STRUCTURE                                         │
│ Physical Integrity and Damage Resistance                     │
└──────────────────────────────────────────────────────────────┘
```

**Function:** Your ship's skeleton and armor. Everything else is useless if the hull fails.

#### Level Progression

| Level | Name | HP | Kinetic Armor | Energy Armor | Radiation | Power | Special |
|-------|------|---:|:-------------:|:------------:|:---------:|:-----:|---------|
| **L0** | No Hull | 0 | 0% | 0% | 0% | 0 | Not spaceworthy |
| **L1** | Salvaged Hull | 50 | 5% | 0% | 0% | 0 | Patchwork plates |
| **L2** | Reinforced | 100 | 15% | 0% | 0% | 0 | Proper plating |
| **L3** | Composite Armor | 200 | 25% | 10% | 10% | 0 | Military-grade |
| **L4** | Ablative Plating | 350 | 35% | 20% | 10% | 0 | Absorbs 50% first energy hit |
| **L5** | Regenerative | 500 | 45% | 30% | 10% | 10 | **1% HP regen/turn** |

#### Power Consumption Chart
```
L1  ░░░░░░░░░░░░░░░░░░░░  0 PU
L2  ░░░░░░░░░░░░░░░░░░░░  0 PU
L3  ░░░░░░░░░░░░░░░░░░░░  0 PU
L4  ░░░░░░░░░░░░░░░░░░░░  0 PU
L5  ██░░░░░░░░░░░░░░░░░░ 10 PU (for regeneration)
```

#### Strategic Importance
```
EARLY GAME:  ★★★★★ Critical (Must have L1 to survive)
MID GAME:    ★★★☆☆ Moderate (L2-3 recommended)
LATE GAME:   ★★★★★ Critical (L4-5 for combat)
EXPLORATION: ★★★☆☆ Moderate (Some armor helpful)
COMBAT:      ★★★★★ Essential (High HP + armor required)
```

#### Dependencies
- **None** - Hull is independent
- **Shields complement Hull** - Shields absorb hits before hull takes damage
- **Life Support requires Hull** - Can't maintain atmosphere without hull integrity

#### Upgrade Path Recommendations

**Phase 1 (Earthbound):**
- Start: L0 (No hull) → L1 ASAP
- First priority upgrade
- L1 sufficient for workshop missions

**Phase 2 (Early Space):**
- L2 within first 5 missions
- Adequate for exploration

**Phase 2 (Combat Ready):**
- L3 minimum for serious combat
- L4-5 for combat-focused builds

#### Key Stats Summary
```
LEVEL 1 (Salvaged):
  • 50 HP total
  • Blocks 5% kinetic damage
  • One good hit and you're in trouble

LEVEL 3 (Composite):
  • 200 HP total
  • Blocks 25% kinetic, 10% energy
  • Can survive several hits
  • Radiation protection for stellar phenomena

LEVEL 5 (Regenerative):
  • 500 HP total
  • Blocks 45% kinetic, 30% energy
  • Heals 5 HP per turn automatically
  • Costs 10 PU for nano-repair system
  • "Illegal in most sectors" flavor
```

---

### 2. Power Core

```
┌──────────────────────────────────────────────────────────────┐
│ ⚡ POWER CORE                                                 │
│ Energy Generation and Distribution                           │
└──────────────────────────────────────────────────────────────┘
```

**Function:** The heart of your ship. Without power, you're dead in space.

#### Level Progression

| Level | Name | Output (PU) | Efficiency | Cost Reduction | Power | Special |
|-------|------|------------:|:----------:|:--------------:|:-----:|---------|
| **L0** | No Power | 0 | 0% | 0% | 0 | Dead in space |
| **L1** | Fusion Cell | 100 | 80% | 0% | 0 | Basic operation |
| **L2** | Deuterium Reactor | 200 | 85% | **-10%** | 0 | All systems cheaper |
| **L3** | M/AM Core | 400 | 90% | **-15%** | 0 | Standard starship |
| **L4** | Advanced M/AM | 700 | 93% | **-20%** | 0 | +100 PU emergency |
| **L5** | Zero-Point Tap | 1000 | 98% | **-25%** | 0 | +5 PU/turn regen |

#### Power Output Chart
```
L1  ████░░░░░░░░░░░░░░░░  100 PU
L2  ████████░░░░░░░░░░░░  200 PU
L3  ████████████████░░░░  400 PU
L4  ██████████████████░░  700 PU
L5  ████████████████████ 1000 PU
```

#### Cost Reduction Impact
```
EXAMPLE: Shields L3 (40 PU base cost)

With Power L1:  40 PU (0% reduction)
With Power L2:  36 PU (-10% = 4 PU saved)
With Power L3:  34 PU (-15% = 6 PU saved)
With Power L4:  32 PU (-20% = 8 PU saved)
With Power L5:  30 PU (-25% = 10 PU saved)

Total savings across 10 systems can be 50+ PU!
```

#### Strategic Importance
```
EARLY GAME:  ★★★★★ Absolutely Critical
MID GAME:    ★★★★★ Absolutely Critical
LATE GAME:   ★★★★★ Absolutely Critical
EXPLORATION: ★★★★★ Absolutely Critical
COMBAT:      ★★★★★ Absolutely Critical
```

#### Dependencies
- **Powers Everything** - All other systems depend on power
- **Upgrade Before Other Systems** - Cost reduction applies to all
- **Synergizes with Computer** - L4+ Computer can optimize power distribution

#### Upgrade Path Recommendations

**Phase 1 (Earthbound):**
- L0 → L1 immediately (second priority after Hull)
- 100 PU supports all L1 systems

**Phase 2 (Early Space):**
- L1 → L2 within first 10 missions
- -10% cost reduction saves ~10-15 PU total

**Phase 2 (Mid-Game):**
- L2 → L3 when upgrading multiple systems to L3
- 400 PU + 15% reduction = ~470 PU effective
- Sweet spot for balanced builds

**Phase 2 (Late-Game):**
- L3 → L4 for combat/advanced builds
- Emergency 100 PU reserve can save your life
- L4 → L5 only for endgame min-maxing

#### Key Stats Summary
```
LEVEL 1 (Fusion Cell):
  • 100 PU output
  • Supports all systems at L1
  • 20% waste heat (80% efficient)

LEVEL 3 (M/AM Core):
  • 400 PU output
  • -15% cost to all systems
  • 90% efficient
  • "The workhorse of modern starships"

LEVEL 5 (Zero-Point):
  • 1000 PU output
  • -25% cost to all systems
  • 98% efficient
  • +5 PU regeneration per turn
  • "Draws power from fabric of space"
  • Unlimited potential
```

**Pro Tip:** Always upgrade Power Core before other systems. The cost reduction bonus pays for itself within 2-3 other upgrades.

---

### 3. Propulsion (Impulse Engines)

```
┌──────────────────────────────────────────────────────────────┐
│ 🚀 PROPULSION (IMPULSE ENGINES)                              │
│ Sub-Light Maneuvering and Combat Agility                     │
└──────────────────────────────────────────────────────────────┘
```

**Function:** Your ship's sub-light engines. Critical for combat evasion and in-system travel.

#### Level Progression

| Level | Name | Speed | Dodge Bonus | Power | Special |
|-------|------|:-----:|:-----------:|:-----:|---------|
| **L0** | No Engines | 0× | 0% | 0 | Drifting in space |
| **L1** | Chemical Thrusters | 1× | +5% | 10 | Old reliable |
| **L2** | Ion Drive | 2× | +10% | 15 | Quiet & efficient |
| **L3** | Plasma Engine | 4× | +18% | 25 | Evasive Maneuvers (1×/encounter) |
| **L4** | Gravitic Drive | 7× | +28% | 40 | Emergency Burn (2×/encounter) |
| **L5** | Inertial Dampener | 12× | +40% | 60 | Immune to kinetic collisions |

#### Power Consumption Chart
```
L1  ██░░░░░░░░░░░░░░░░░░ 10 PU
L2  ███░░░░░░░░░░░░░░░░░ 15 PU
L3  █████░░░░░░░░░░░░░░░ 25 PU
L4  ████████░░░░░░░░░░░░ 40 PU
L5  ████████████░░░░░░░░ 60 PU
```

#### Speed & Agility Progression
```
SPEED MULTIPLIER:
L1  █░░░░░░░░░░░░ 1×  (baseline)
L2  ██░░░░░░░░░░ 2×  (double)
L3  ████░░░░░░░░ 4×  (quadruple)
L4  ███████░░░░░ 7×  (sevenfold)
L5  ████████████ 12× (impossibly fast)

DODGE CHANCE:
L1  █░░░░░░░░░░░  5% (minimal)
L2  ██░░░░░░░░░░ 10% (noticeable)
L3  ███░░░░░░░░░ 18% (solid evasion)
L4  █████░░░░░░░ 28% (highly agile)
L5  ████████░░░░ 40% (precognitive evasion)
```

#### Strategic Importance
```
EARLY GAME:  ★★★☆☆ Moderate (L1 adequate)
MID GAME:    ★★★★☆ Important (L2-3 for combat)
LATE GAME:   ★★★★★ Critical (L4-5 for agility)
EXPLORATION: ★★★☆☆ Moderate (Speed is nice)
COMBAT:      ★★★★★ Essential (Dodge = survival)
```

#### Dependencies
- **Requires Power** - Higher levels need significant power
- **Synergy with Computer** - L3+ Computer + L3+ Propulsion = 20% faster travel
- **Combat Effectiveness** - Higher dodge = less damage taken = less hull/shield drain

#### Upgrade Path Recommendations

**Phase 1 (Earthbound):**
- L0 → L1 (third priority)
- 10 PU is cheap, basic mobility

**Phase 2 (Early Space):**
- L1 → L2 for exploration comfort
- 2× speed halves travel time

**Phase 2 (Combat Prep):**
- L2 → L3 before engaging in serious combat
- Evasive Maneuvers ability can save you
- 18% dodge is significant

**Phase 2 (Late-Game):**
- L3 → L4 for advanced combat
- Emergency Burn allows tactical repositioning
- L4 → L5 for perfectionists (very expensive)

#### Special Abilities
```
LEVEL 3 - EVASIVE MANEUVERS:
  • Use: Once per encounter
  • Effect: Instantly dodge next attack
  • "Barrel roll through incoming fire"

LEVEL 4 - EMERGENCY BURN:
  • Use: Twice per encounter
  • Effect: Instant position change
  • "Gravity manipulation for impossible turns"

LEVEL 5 - INERTIAL NEGATION:
  • Passive ability
  • Effect: Immune to kinetic collision damage
  • "Stop on a dime, turn on a credit"
  • Perfect maneuverability
```

#### Key Stats Summary
```
LEVEL 1 (Chemical):
  • 1× speed (baseline)
  • +5% dodge (minor)
  • 10 PU (very affordable)

LEVEL 3 (Plasma):
  • 4× speed (fast)
  • +18% dodge (solid)
  • 25 PU (moderate)
  • Evasive Maneuvers ability
  • "A pilot's dream"

LEVEL 5 (Inertial):
  • 12× speed (absurdly fast)
  • +40% dodge (incredible)
  • 60 PU (expensive but worth it)
  • Immune to collision damage
  • "You can stop on a dime"
```

---

### 4. Warp Drive

```
┌──────────────────────────────────────────────────────────────┐
│ 🌌 WARP DRIVE                                                │
│ Faster-Than-Light Interstellar Travel                        │
└──────────────────────────────────────────────────────────────┘
```

**Function:** FTL travel. Without this, you're stuck in one star system forever.

#### Level Progression

| Level | Warp Factor | Speed (×c) | Range (LY) | Travel Time | Systems | Power | Special |
|-------|:-----------:|:----------:|:----------:|:-----------:|:-------:|:-----:|---------|
| **L0** | — | 0× | 0 | ∞ | 0 | 0 | Trapped |
| **L1** | 1.0 | 1× | 2 | 1 day/LY | 3 | 20 | Phase 2 unlock |
| **L2** | 3.0 | 9× | 10 | 3 hrs/LY | 12 | 30 | Local sector |
| **L3** | 5.0 | 125× | 50 | 30 min/LY | 50 | 50 | Escape encounters |
| **L4** | 7.0 | 343× | 200 | 5 min/LY | 150 | 80 | Tactical jumps |
| **L5** | 9.0+ | 729× | ∞ | Instant | All | 120 | Transwarp |

#### Power Consumption Chart
```
L1  ████░░░░░░░░░░░░░░░░ 20 PU
L2  ██████░░░░░░░░░░░░░░ 30 PU
L3  ██████████░░░░░░░░░░ 50 PU
L4  ████████████████░░░░ 80 PU
L5  ████████████████████ 120 PU
```

#### Speed Progression (Log Scale)
```
Warp Factor vs. Speed (cubic relationship)

L1 (W1):  █ 1× light speed
L2 (W3):  ████ 9× light speed (3³)
L3 (W5):  ███████████ 125× light speed (5³)
L4 (W7):  ████████████████ 343× light speed (7³)
L5 (W9):  ████████████████████ 729× light speed (9³)
```

#### Range & Accessibility
```
SYSTEMS ACCESSIBLE:

L0: ░░░░░░░░░░░░░░░░░░░░  0 systems  (Earth only)
L1: ██░░░░░░░░░░░░░░░░░░  3 systems  (Sol neighbors)
L2: ████████░░░░░░░░░░░░ 12 systems  (Local sector)
L3: ███████████████░░░░░ 50 systems  (Regional)
L4: ███████████████████░ 150 systems (Galactic)
L5: ████████████████████ ALL systems (Unlimited)
```

#### Strategic Importance
```
EARLY GAME:  ★★★★★ CRITICAL (L1 required for Phase 2)
MID GAME:    ★★★★★ CRITICAL (L2-3 for exploration)
LATE GAME:   ★★★★☆ Important (L4-5 optional)
EXPLORATION: ★★★★★ ESSENTIAL (Higher = more systems)
COMBAT:      ★★★☆☆ Moderate (L3+ can escape)
```

#### Dependencies
- **Requires Power** - Highest power consumer
- **Phase 2 Gateway** - L1 minimum to leave Earth
- **Synergy with Sensors** - L3+ Warp + L4+ Sensors = Safe jump (detect hazards)

#### Upgrade Path Recommendations

**Phase 1 (Earthbound):**
- **L0 → L1 MANDATORY to complete Phase 1**
- Final system to upgrade (after all others at L1)
- 20 PU is manageable with Power L1

**Phase 2 (Early Space):**
- **Stay at L1 initially** - Save resources
- Upgrade L1 → L2 when you want to explore farther
- 12 systems gives plenty of content

**Phase 2 (Mid-Game):**
- L2 → L3 for serious exploration
- 50 systems = most of playable galaxy
- Ability to escape hostile encounters
- 30 min/LY = fast travel

**Phase 2 (Late-Game):**
- L3 → L4 for completionists
- L4 → L5 for endgame (very expensive)
- Transwarp is flashy but not required

#### Special Abilities
```
LEVEL 3 - ESCAPE CAPABILITY:
  • Can escape most hostile encounters
  • "Fast enough to outrun trouble"
  • Opens diplomatic options

LEVEL 4 - TACTICAL JUMPS:
  • Short-range combat repositioning
  • "Micro-warp in battle"
  • Flanking maneuvers possible

LEVEL 5 - TRANSWARP CORRIDORS:
  • Instant travel to discovered systems
  • "Jump across galaxy in moments"
  • No travel time at all
```

#### Travel Time Examples
```
JOURNEY: 10 Light Years

L1 (W1):  10 days
L2 (W3):  30 hours
L3 (W5):  5 hours
L4 (W7):  50 minutes
L5 (W9):  Instant

JOURNEY: 50 Light Years

L1 (W1):  50 days (not possible - 2 LY range)
L2 (W3):  Not possible (10 LY range)
L3 (W5):  25 hours
L4 (W7):  4 hours
L5 (W9):  Instant
```

#### Key Stats Summary
```
LEVEL 1 (Warp 1):
  • 1× light speed
  • 2 LY range
  • 3 accessible systems
  • YOUR TICKET OFF EARTH
  • Required to complete Phase 1

LEVEL 3 (Warp 5):
  • 125× light speed
  • 50 LY range
  • 50 accessible systems
  • Can escape hostile encounters
  • "The galaxy opens up"
  • Recommended mid-game target

LEVEL 5 (Warp 9+):
  • 729× light speed
  • Unlimited range
  • Entire galaxy accessible
  • Instant travel via transwarp
  • "Jump across galaxy in moments"
  • Endgame flex
```

**Critical Note:** Warp L1 is THE requirement to leave Phase 1. You cannot progress to space exploration without it. Plan accordingly!

---

### 5. Life Support

```
┌──────────────────────────────────────────────────────────────┐
│ ❤️  LIFE SUPPORT                                              │
│ Crew Survival and Environmental Systems                      │
└──────────────────────────────────────────────────────────────┘
```

**Function:** Keeps you alive. Also determines crew capacity and morale.

#### Level Progression

| Level | Name | Crew Cap | Emergency | Radiation | Power | Morale | Special |
|-------|------|:--------:|:---------:|:---------:|:-----:|:------:|---------|
| **L0** | No Life Support | 0 | 0 hrs | 0% | 0 | — | Instant death |
| **L1** | Basic O₂ Recycling | 1 | 24 hrs | 10% | 5 | — | You breathe |
| **L2** | Climate Control | 4 | 1 week | 30% | 10 | +10% | Unlocks crew |
| **L3** | Bio-Recycling | 10 | 1 month | 50% | 15 | +20% | Crew tasks |
| **L4** | Closed Ecosystem | 25 | 6 months | 75% | 25 | +30% | Produce food |
| **L5** | Bio-Dome | 50 | ∞ | 95% | 35 | +50% | Zero supply cost |

#### Power Consumption Chart
```
L1  █░░░░░░░░░░░░░░░░░░░  5 PU
L2  ██░░░░░░░░░░░░░░░░░░ 10 PU
L3  ███░░░░░░░░░░░░░░░░░ 15 PU
L4  █████░░░░░░░░░░░░░░░ 25 PU
L5  ███████░░░░░░░░░░░░░ 35 PU
```

#### Crew Capacity & Sustainability
```
CREW CAPACITY:

L0: ░ 0 crew  (uninhabitable)
L1: █ 1 crew  (solo only)
L2: ████ 4 crew  (small team)
L3: ██████████ 10 crew  (standard crew)
L4: █████████████████████████ 25 crew  (large crew)
L5: ██████████████████████████████████████████████ 50 crew

EMERGENCY DURATION (power loss):

L1: █ 24 hours  (get help fast)
L2: ████ 1 week  (reasonable margin)
L3: ████████████ 1 month  (self-sufficient)
L4: ████████████████████ 6 months  (deep space capable)
L5: ████████████████████████████████ Indefinite  (true colony ship)
```

#### Strategic Importance
```
EARLY GAME:  ★★★★★ Critical (L1 to breathe)
MID GAME:    ★★★★☆ Important (L2-3 for crew)
LATE GAME:   ★★★☆☆ Moderate (L4-5 quality of life)
EXPLORATION: ★★★★☆ Important (Higher = longer missions)
COMBAT:      ★★☆☆☆ Low (Not directly combat-related)
```

#### Dependencies
- **Requires Hull** - Can't maintain atmosphere without hull integrity
- **Enables Crew System** - L2+ required to recruit crew (Phase 2 feature)
- **Synergy with Computer** - L4+ Life Support + L4+ Computer = +25% crew efficiency

#### Upgrade Path Recommendations

**Phase 1 (Earthbound):**
- L0 → L1 immediately (fourth priority)
- 5 PU is cheap
- You can't survive without it

**Phase 2 (Early Space):**
- **Stay at L1 if solo play**
- L1 → L2 when crew system becomes available
- +10% morale unlocks crew recruitment

**Phase 2 (Mid-Game):**
- L2 → L3 for larger crew
- 10 crew capacity = full functionality
- 1 month emergency = safe for exploration

**Phase 2 (Late-Game):**
- L3 → L4 for resource efficiency
- Producing food reduces supply costs 50%
- L4 → L5 only for colony ship roleplay

#### Special Features by Level
```
LEVEL 2 - CLIMATE CONTROL:
  • +10% crew morale
  • Unlocks crew system
  • 4 crew capacity
  • "Comfortable for small team"

LEVEL 3 - BIO-RECYCLING:
  • +20% crew morale
  • Crew can perform tasks
  • 10 crew capacity
  • "Closed-loop life support"
  • 1 month self-sufficiency

LEVEL 4 - CLOSED ECOSYSTEM:
  • +30% crew morale
  • Produce food (50% supply cost reduction)
  • +20% crew efficiency
  • 6 month self-sufficiency
  • "You could live aboard indefinitely"

LEVEL 5 - BIO-DOME:
  • +50% crew morale
  • Zero supply costs
  • +40% crew efficiency
  • Indefinite sustainability
  • Psychological resilience
  • "A garden in space"
```

#### Radiation Protection
```
STELLAR PHENOMENA SURVIVAL:

L1:  ██░░░░░░░░ 10% protection  (dangerous)
L2:  ██████░░░░ 30% protection  (risky)
L3:  ██████████ 50% protection  (manageable)
L4:  ███████████████ 75% protection  (safe)
L5:  ███████████████████ 95% protection  (immune)

Example: Pulsar radiation (100 damage/turn)
  L1: Take 90 damage  (deadly)
  L3: Take 50 damage  (survivable)
  L5: Take 5 damage   (negligible)
```

#### Key Stats Summary
```
LEVEL 1 (Basic O₂):
  • 1 crew capacity
  • 24 hour emergency
  • 10% radiation protection
  • 5 PU (very cheap)
  • "Keeps you breathing"

LEVEL 3 (Bio-Recycling):
  • 10 crew capacity
  • 1 month emergency
  • 50% radiation protection
  • 15 PU (affordable)
  • +20% crew morale
  • Crew can perform tasks
  • Recommended mid-game target

LEVEL 5 (Bio-Dome):
  • 50 crew capacity
  • Indefinite emergency
  • 95% radiation protection
  • 35 PU (moderate)
  • +50% crew morale
  • Zero supply costs
  • +40% crew efficiency
  • "The crew considers this home"
```

---

### 6. Computer Core

```
┌──────────────────────────────────────────────────────────────┐
│ 💻 COMPUTER CORE                                             │
│ Ship Automation, AI Assistance, Tactical Calculations        │
└──────────────────────────────────────────────────────────────┘
```

**Function:** Your ship's brain. From basic calculations to sentient AI companion.

#### Level Progression

| Level | Name | Accuracy | Auto Features | Power | Special |
|-------|------|:--------:|:-------------:|:-----:|---------|
| **L0** | No Computer | — | None | 0 | Manual everything |
| **L1** | Basic Computer | — | Manual control | 5 | Calculator |
| **L2** | Standard AI | +10% | Targeting, Nav | 10 | Threat assessment |
| **L3** | Advanced AI | +20% | Tactical, Repair | 20 | Learns & adapts |
| **L4** | Tactical AI | +35% | Combat auto | 35 | Emergency protocols |
| **L5** | Sentient AI | +50% | Full autonomy | 50 | Companion NPC |

#### Power Consumption Chart
```
L1  █░░░░░░░░░░░░░░░░░░░  5 PU
L2  ██░░░░░░░░░░░░░░░░░░ 10 PU
L3  ████░░░░░░░░░░░░░░░░ 20 PU
L4  ███████░░░░░░░░░░░░░ 35 PU
L5  ██████████░░░░░░░░░░ 50 PU
```

#### Combat Effectiveness Bonus
```
WEAPON ACCURACY INCREASE:

L0: ░░░░░░░░░░  +0%  (manual aiming)
L1: ░░░░░░░░░░  +0%  (basic calculations)
L2: ██░░░░░░░░ +10%  (targeting assist)
L3: ████░░░░░░ +20%  (predictive targeting)
L4: ███████░░░ +35%  (tactical superiority)
L5: ██████████ +50%  (perfect accuracy)

Example: Base weapon 70% accuracy
  L2: 70% + 10% = 80%  (12% more hits)
  L5: 70% + 50% = 120% → 95% cap  (36% more hits!)
```

#### Strategic Importance
```
EARLY GAME:  ★★★☆☆ Moderate (L1 sufficient)
MID GAME:    ★★★★☆ Important (L2-3 for AI help)
LATE GAME:   ★★★★★ Critical (L4-5 force multiplier)
EXPLORATION: ★★★★☆ Important (Auto-nav helpful)
COMBAT:      ★★★★★ Essential (Accuracy = damage)
```

#### Dependencies
- **Synergies with Everything** - Computer enhances all systems
- **Computer + Sensors** - L2+ Computer + L3+ Sensors = Deep Space Scan
- **Computer + Shields** - L3+ Computer + L3+ Shields = Auto-modulation
- **Computer + Weapons** - L2+ Computer + L2+ Weapons = +15% accuracy
- **Computer + Propulsion** - L3+ Computer + L3+ Propulsion = 20% faster travel
- **Computer + Life Support** - L4+ Computer + L4+ Life Support = +25% crew efficiency

#### Upgrade Path Recommendations

**Phase 1 (Earthbound):**
- L0 → L1 (fifth priority)
- 5 PU is cheap
- Basic operation only

**Phase 2 (Early Space):**
- L1 → L2 for quality of life
- Targeting assist (+10% accuracy)
- Auto-navigation (-10% travel time)

**Phase 2 (Combat Prep):**
- L2 → L3 before serious combat
- +20% accuracy is huge
- Tactical recommendations
- Auto-repair (20% faster repairs)

**Phase 2 (Late-Game):**
- L3 → L4 for combat mastery
- Can fight autonomously
- Emergency protocols
- L4 → L5 for companion NPC experience

#### Features by Level
```
LEVEL 2 - STANDARD AI:
  • +10% weapon accuracy
  • Auto-navigation (-10% travel time)
  • Basic threat assessment
  • "Helpful AI assistant"

LEVEL 3 - ADVANCED AI:
  • +20% weapon accuracy
  • +15% sensor effectiveness
  • Tactical recommendations
  • Predictive analysis (danger warnings)
  • Auto-repair assistance (20% faster)
  • "Intelligent AI that learns"

LEVEL 4 - TACTICAL AI:
  • +35% weapon accuracy
  • +25% dodge (predictive evasion)
  • Combat automation (can fight alone)
  • Optimal solution finding
  • Emergency protocols (auto-shields)
  • "Thinks faster than you do"

LEVEL 5 - SENTIENT AI:
  • +50% all combat stats
  • Companion NPC (unique personality)
  • Creative problem-solving
  • Autonomous ship operations
  • Dialogue partner
  • Emotional intelligence (diplomacy)
  • Evolves over time
  • "It's not just a ship - it's a friend"
```

#### System Synergies (Examples)
```
COMPUTER L3 + SENSORS L3:
  "Deep Space Scan" ability
  → Detailed analysis of everything in range

COMPUTER L3 + SHIELDS L3:
  Auto-shield modulation
  → Shields adapt to damage faster

COMPUTER L4 + LIFE SUPPORT L4:
  Automated systems
  → +25% crew efficiency

COMPUTER L3 + PROPULSION L3:
  Optimal routing
  → 20% faster travel between systems
```

#### Key Stats Summary
```
LEVEL 1 (Basic):
  • Manual ship control
  • Basic calculations
  • 5 PU (cheap)
  • "Calculator with delusions"

LEVEL 3 (Advanced):
  • +20% weapon accuracy
  • +15% sensor effectiveness
  • Tactical recommendations
  • Auto-repair (20% faster)
  • 20 PU (moderate)
  • "Learns and adapts"
  • Recommended for all builds

LEVEL 5 (Sentient):
  • +50% all combat stats
  • Companion NPC character
  • Autonomous operation
  • Creative problem-solving
  • 50 PU (expensive)
  • "A true friend"
  • Endgame unique experience
```

**Pro Tip:** Computer L3 is one of the best mid-game investments. The synergies with other systems pay dividends across your entire ship.

---

### 7. Sensors

```
┌──────────────────────────────────────────────────────────────┐
│ 🔍 SENSORS                                                   │
│ Detection, Scanning, and Situational Awareness               │
└──────────────────────────────────────────────────────────────┘
```

**Function:** Your ship's eyes. See threats before they see you.

#### Level Progression

| Level | Name | Range | Detection | Warning | Power | Special |
|-------|------|:-----:|:---------:|:-------:|:-----:|---------|
| **L0** | No Sensors | 0 AU | None | 0% | 0 | Blind |
| **L1** | Optical | 1 AU | Visual | 0% | 5 | Basic sight |
| **L2** | EM Spectrum | 5 AU | Composition | +20% | 10 | Life signs |
| **L3** | Subspace Array | 50 AU | Comprehensive | +40% | 20 | Scan mini-game |
| **L4** | Multi-Phasic | 500 AU | Extremely detailed | +60% | 35 | Detect cloaked |
| **L5** | Quantum | Sector | Precognitive | +100% | 50 | See future |

#### Power Consumption Chart
```
L1  █░░░░░░░░░░░░░░░░░░░  5 PU
L2  ██░░░░░░░░░░░░░░░░░░ 10 PU
L3  ████░░░░░░░░░░░░░░░░ 20 PU
L4  ███████░░░░░░░░░░░░░ 35 PU
L5  ██████████░░░░░░░░░░ 50 PU
```

#### Detection Range
```
SENSOR RANGE (Astronomical Units):

L0: ░  0 AU    (blind)
L1: █  1 AU    (very short - within planet orbit)
L2: ████ 5 AU   (short - inner system)
L3: ████████████████████ 50 AU  (long - full system)
L4: ████████████████████████████████ 500 AU (very long - multi-system)
L5: ████████████████████████████████████████ Sector-wide (unlimited)

For reference:
  1 AU = Earth-Sun distance
  Neptune's orbit = ~30 AU
  Oort Cloud = 50,000 AU
```

#### Encounter Warning Time
```
ADVANCE WARNING:

L0: ░░░░░░░░░░  +0%   (ambushed constantly)
L1: ░░░░░░░░░░  +0%   (still surprised often)
L2: ████░░░░░░ +20%   (some preparation time)
L3: ████████░░ +40%   (good warning)
L4: ████████████ +60%   (excellent warning)
L5: ████████████████████ +100%  (precognitive)

Example: Enemy appears in 60 seconds
  L2: Detect at -12 seconds  = 72 seconds prep
  L4: Detect at -36 seconds  = 96 seconds prep
  L5: Detect at -60 seconds  = 120 seconds prep
```

#### Strategic Importance
```
EARLY GAME:  ★★★☆☆ Moderate (L1 to see)
MID GAME:    ★★★★☆ Important (L2-3 for safety)
LATE GAME:   ★★★★★ Critical (L4-5 for scanning)
EXPLORATION: ★★★★★ ESSENTIAL (Higher = find more)
COMBAT:      ★★★★☆ Important (Warning = preparation)
```

#### Dependencies
- **Synergy with Computer** - L2+ Computer + L3+ Sensors = Deep Space Scan
- **Synergy with Warp** - L3+ Warp + L4+ Sensors = Safe jump (hazard detection)
- **Explorer Build** - L4+ Sensors required for Explorer-class ship

#### Upgrade Path Recommendations

**Phase 1 (Earthbound):**
- L0 → L1 (sixth priority)
- 5 PU is cheap
- Basic visual detection

**Phase 2 (Early Space):**
- L1 → L2 ASAP for exploration safety
- Life sign detection
- +20% encounter warning
- Material composition scans

**Phase 2 (Mid-Game):**
- L2 → L3 for serious exploration
- 50 AU = full system awareness
- Hidden object detection
- Scan mini-game unlocked

**Phase 2 (Late-Game):**
- L3 → L4 for comprehensive scanning
- Detect cloaked ships
- Temporal anomalies
- L4 → L5 for "Future Vision" ability

#### Features by Level
```
LEVEL 2 - EM SPECTRUM:
  • 5 AU range (inner system)
  • Detect power signatures
  • Material composition analysis
  • Basic life sign detection
  • +20% encounter warning
  • "See across EM spectrum"

LEVEL 3 - SUBSPACE ARRAY:
  • 50 AU range (full system)
  • Long-range threat detection
  • Detailed life form scans
  • Technology level assessment
  • Hidden object detection
  • +40% encounter warning
  • Unlock scan mini-game
  • "Peer deep into space"

LEVEL 4 - MULTI-PHASIC:
  • 500 AU range (multi-system)
  • Detect cloaked ships
  • Temporal anomalies
  • Subspace rifts
  • Predict ship trajectories
  • +60% encounter warning
  • Can scan through interference
  • "Nothing hides from you"

LEVEL 5 - QUANTUM:
  • Sector-wide range (entire region)
  • Predict future positions (1hr ahead)
  • Quantum-level phenomena
  • Scan alternate dimensions
  • Absolutely nothing can hide
  • +100% encounter warning
  • "Future Vision" ability
  • "See things before they happen"
```

#### Special Ability: Future Vision (L5)
```
FUTURE VISION:
  • See consequences before choosing
  • Preview mission outcomes
  • Know if encounter is hostile
  • Essentially precognition
  • Makes exploration much safer
  • "You see the future"
```

#### Scan Mini-Game (L3+)
```
When scanning objects/ships at L3+:
  1. Initiate scan
  2. Match frequency patterns
  3. Discover:
     - Hidden cargo
     - Ship class/capabilities
     - Weaknesses
     - Crew composition
     - Technology level
```

#### Key Stats Summary
```
LEVEL 1 (Optical):
  • 1 AU range (very limited)
  • Visual data only
  • 5 PU (cheap)
  • "Fancy cameras"

LEVEL 3 (Subspace):
  • 50 AU range (full system)
  • Comprehensive analysis
  • Hidden object detection
  • +40% encounter warning
  • 20 PU (moderate)
  • Scan mini-game unlocked
  • Recommended for explorers

LEVEL 5 (Quantum):
  • Sector-wide range
  • Precognitive detection
  • +100% encounter warning
  • Future Vision ability
  • 50 PU (expensive)
  • "Nothing escapes your notice"
  • Ultimate exploration tool
```

**Pro Tip:** Sensors L3 is the sweet spot for Phase 2 exploration. 50 AU range covers most star systems entirely, giving you complete situational awareness.

---

### 8. Shields

```
┌──────────────────────────────────────────────────────────────┐
│ 🛡️ SHIELDS                                                    │
│ Energy Defense and Damage Mitigation                         │
└──────────────────────────────────────────────────────────────┘
```

**Function:** Your first line of defense. Shields absorb damage before hull takes hits.

#### Level Progression

| Level | Name | Shield HP | Reduction | Recharge | Power | Special |
|-------|------|:---------:|:---------:|:--------:|:-----:|---------|
| **L0** | No Shields | 0 | 0% | 0 | 0 | Hull takes all damage |
| **L1** | Deflector Screens | 50 | 25% | 5/turn | 15 | Basic protection |
| **L2** | Standard Shields | 150 | 50% | 15/turn | 25 | Block 1 shot |
| **L3** | Multi-Layered | 300 | 70% | 30/turn | 40 | Rapid recharge |
| **L4** | Adaptive Shields | 500 | 85% | 50/turn | 60 | Adapt to damage |
| **L5** | Phase Shields | 800 | 95% | 80/turn | 85 | 30% phase out |

#### Power Consumption Chart
```
L0  ░░░░░░░░░░░░░░░░░░░░  0 PU
L1  ███░░░░░░░░░░░░░░░░░ 15 PU
L2  █████░░░░░░░░░░░░░░░ 25 PU
L3  ████████░░░░░░░░░░░░ 40 PU
L4  ████████████░░░░░░░░ 60 PU
L5  █████████████████░░░ 85 PU
```

#### Shield HP & Recharge
```
SHIELD HIT POINTS:

L0: ░  0 HP    (no shields)
L1: ████ 50 HP   (minimal)
L2: ████████████ 150 HP  (standard)
L3: ████████████████████████ 300 HP  (solid)
L4: ████████████████████████████████████████ 500 HP  (strong)
L5: ████████████████████████████████████████████████████████████ 800 HP (maximum)

RECHARGE RATE (when not hit):

L1: █░░░░░░░░░  5 HP/turn  (slow)
L2: ███░░░░░░░ 15 HP/turn  (moderate)
L3: ██████░░░░ 30 HP/turn  (fast)
L4: ██████████ 50 HP/turn  (very fast)
L5: ████████████████ 80 HP/turn  (instant)

L3 Special: Full recharge in 3 turns if not hit
```

#### Damage Reduction
```
INCOMING DAMAGE MITIGATION:

Example: Enemy fires 100 damage shot

L0: 100 damage → Hull  (0% reduction)
L1:  75 damage → Hull  (25% reduction)
L2:  50 damage → Hull  (50% reduction)
L3:  30 damage → Hull  (70% reduction)
L4:  15 damage → Hull  (85% reduction)
L5:   5 damage → Hull  (95% reduction)
      OR 30% chance → 0 damage (phased out!)
```

#### Strategic Importance
```
EARLY GAME:  ★★☆☆☆ Optional (Phase 1 safe)
MID GAME:    ★★★★☆ Important (Phase 2 hostile)
LATE GAME:   ★★★★★ Critical (Combat required)
EXPLORATION: ★★★☆☆ Moderate (Some danger)
COMBAT:      ★★★★★ ESSENTIAL (Survival)
```

#### Dependencies
- **Requires Significant Power** - One of highest power consumers
- **Synergy with Computer** - L3+ Computer + L3+ Shields = Auto-modulation
- **Combat Build Required** - Frigate/Destroyer/Dreadnought class needs L2-4

#### Upgrade Path Recommendations

**Phase 1 (Earthbound):**
- **L0 → L1 OPTIONAL**
- Not required for Phase 1
- Save resources for critical systems

**Phase 2 (Early Space):**
- **L0/L1 → L2 before combat**
- Standard shields are minimum for safety
- 150 HP + 50% reduction = survivable

**Phase 2 (Combat Focus):**
- L2 → L3 for combat readiness
- 300 HP + 70% reduction = durable
- Rapid recharge keeps you in fight

**Phase 2 (Late-Game):**
- L3 → L4 for advanced combat
- Adaptive shields learn enemy attacks
- L4 → L5 for invincibility feel

#### Special Features by Level
```
LEVEL 2 - STANDARD SHIELDS:
  • 150 shield HP
  • 50% damage reduction
  • 15 HP/turn recharge
  • Block 1 shot completely (1×/encounter)
  • "Solid protection"

LEVEL 3 - MULTI-LAYERED:
  • 300 shield HP
  • 70% damage reduction
  • 30 HP/turn recharge
  • Rapid recharge: Full in 3 turns if not hit
  • Multiple shield layers
  • "Excellent protection"

LEVEL 4 - ADAPTIVE SHIELDS:
  • 500 shield HP
  • 85% damage reduction
  • 50 HP/turn recharge
  • Adaptive: After hit, +25% resist to that damage type
  • Can rotate frequency to reset
  • "Learns from attacks"

LEVEL 5 - PHASE SHIELDS:
  • 800 shield HP
  • 95% damage reduction
  • 80 HP/turn recharge
  • 30% chance to phase out (avoid damage entirely)
  • Immune to energy drain attacks
  • Can extend to nearby allies
  • "Sometimes you're not there"
```

#### Combat Survival Examples
```
SCENARIO: 5 Enemy Attacks @ 80 damage each

NO SHIELDS (L0):
  Hull takes: 400 damage total
  → Likely destroyed

STANDARD SHIELDS (L2):
  Turn 1: 40 dmg → Shields (110 HP left)
  Turn 2: 40 dmg → Shields (70 HP left)
  Turn 3: 40 dmg → Shields (30 HP left)
  Turn 4: 40 dmg → Shields depleted, 10 → Hull
  Turn 5: 80 dmg → Hull
  Total Hull damage: 90
  → Survived but hurt

ADAPTIVE SHIELDS (L4):
  Turn 1: 12 dmg → Shields (488 HP, adapt)
  Turn 2:  9 dmg → Shields (479 HP, +25% resist)
  Turn 3:  9 dmg → Shields (470 HP)
  Turn 4:  9 dmg → Shields (461 HP)
  Turn 5:  9 dmg → Shields (452 HP)
  Total Hull damage: 0
  → Flawless victory
```

#### Key Stats Summary
```
LEVEL 0 (None):
  • No shields
  • Hull takes ALL damage
  • Save 15-85 PU
  • Viable for pure exploration

LEVEL 2 (Standard):
  • 150 shield HP
  • 50% damage reduction
  • 15 HP/turn recharge
  • 25 PU (affordable)
  • Block 1 shot completely
  • Minimum for combat

LEVEL 4 (Adaptive):
  • 500 shield HP
  • 85% damage reduction
  • 50 HP/turn recharge
  • 60 PU (expensive)
  • Adapts to damage types
  • Recommended for combat builds

LEVEL 5 (Phase):
  • 800 shield HP
  • 95% damage reduction
  • 80 HP/turn recharge
  • 85 PU (very expensive)
  • 30% phase out chance
  • Can shield allies
  • "Near invincibility"
```

**Pro Tip:** Shields L2 is mandatory before engaging in any combat. The 50% damage reduction and 150 HP buffer is the difference between surviving and dying.

---

### 9. Weapons

```
┌──────────────────────────────────────────────────────────────┐
│ 🎯 WEAPONS                                                   │
│ Combat Offense and Self-Defense Systems                      │
└──────────────────────────────────────────────────────────────┘
```

**Function:** Your ship's teeth. For when diplomacy fails.

#### Level Progression

| Level | Type | Damage | Accuracy | Range | Ammo | Power | Special |
|-------|------|:------:|:--------:|:-----:|:----:|:-----:|---------|
| **L0** | None | 0 | — | — | — | 0 | Auto-flee only |
| **L1** | Laser Cannon | 15-25 | 70% | Short | ∞ | 10 | Precise crits |
| **L2** | Phaser Array | 30-50 | 80% | Medium | ∞ | 20 | Variable power |
| **L3** | Photon + Phaser | 40-60 / 80-120 | 85% | Long | 10 | 35 | Heavy torpedoes |
| **L4** | Quantum + Pulse | 60-90 / 150-200 | 90% | V.Long | 8 | 55 | Alpha Strike |
| **L5** | Experimental | Variable | 95% | Extreme | 5 | 80 | 4 weapon types |

#### Power Consumption Chart
```
L0  ░░░░░░░░░░░░░░░░░░░░  0 PU
L1  ██░░░░░░░░░░░░░░░░░░ 10 PU
L2  ████░░░░░░░░░░░░░░░░ 20 PU
L3  ███████░░░░░░░░░░░░░ 35 PU
L4  ███████████░░░░░░░░░ 55 PU
L5  ████████████████░░░░ 80 PU
```

#### Damage Output Comparison
```
SUSTAINED DPS (Phaser/Beam weapons, unlimited ammo):

L1 (Laser):     15-25 dmg  ████░░░░░░░░░░░░░░░░
L2 (Phaser):    30-50 dmg  ██████████░░░░░░░░░░
L3 (Phaser+):   40-60 dmg  ██████████████░░░░░░
L4 (Pulse):     60-90 ×2   ████████████████████ (rapid fire!)
L5 (Variable):  100-150    ████████████████████

BURST DAMAGE (Torpedoes, limited ammo):

L3 (Photon):    80-120 dmg    ████████████████
L4 (Quantum):   150-200 dmg   ████████████████████████ (bypasses 50% shields)
L5 (Transphasic): 120-180 dmg ████████████████████ (ignores shields!)
L5 (Tachyon):   80 dmg ×All  ████████████████ (hits all enemies)
```

#### Accuracy Progression
```
HIT CHANCE:

L0: ░░░░░░░░░░  —    (can't fight)
L1: ███████░░░ 70%   (miss often)
L2: ████████░░ 80%   (reliable)
L3: ████████░░ 85%   (good)
L4: █████████░ 90%   (excellent)
L5: █████████░ 95%   (near-perfect)

With Computer L3 (+20%):
  L2: 80% + 20% = 100% → 95% cap
  L5: 95% + 20% = 115% → 95% cap
```

#### Strategic Importance
```
EARLY GAME:  ★★☆☆☆ Optional (Phase 1 peaceful)
MID GAME:    ★★★☆☆ Moderate (Some combat)
LATE GAME:   ★★★★★ Critical (Combat frequent)
EXPLORATION: ★★☆☆☆ Low (Avoid fights)
COMBAT:      ★★★★★ ESSENTIAL (Your job)
```

#### Dependencies
- **Requires Significant Power** - High power consumer at L3+
- **Synergy with Computer** - L2+ Computer + L2+ Weapons = +15% accuracy
- **Combat Build Required** - Frigate/Destroyer/Dreadnought need L2-4

#### Upgrade Path Recommendations

**Phase 1 (Earthbound):**
- **L0 → L1 OPTIONAL**
- Not required for Phase 1
- Can auto-flee from threats

**Phase 2 (Early Space):**
- **L0/L1 → L2 if pursuing combat**
- Phasers are reliable damage
- Variable power option useful

**Phase 2 (Combat Focus):**
- L2 → L3 for serious firepower
- Photon torpedoes = burst damage
- Unlimited phasers + limited heavy torpedoes

**Phase 2 (Late-Game):**
- L3 → L4 for military-grade
- Quantum torpedoes bypass shields
- Alpha Strike = 300-400 damage burst
- L4 → L5 for experimental variety

#### Weapon Systems by Level
```
LEVEL 1 - LASER CANNON:
  • 15-25 damage
  • 70% accuracy
  • Short range
  • Unlimited shots
  • Precise: Crits on 90+ roll
  • "Salvaged mining laser"

LEVEL 2 - PHASER ARRAY:
  • 30-50 damage
  • 80% accuracy
  • Medium range
  • Unlimited shots
  • Variable power (50% for half cost)
  • Precise targeting (target specific systems)
  • "Standard energy weapon"

LEVEL 3 - PHOTON TORPEDOES + PHASERS:
  • Phasers: 40-60 damage (unlimited)
  • Torpedoes: 80-120 damage (10/encounter)
  • 85% accuracy
  • Long range
  • Heavy damage option
  • "Serious firepower"

LEVEL 4 - QUANTUM TORPEDOES + PULSE PHASERS:
  • Pulse: 60-90 damage, 2×/turn (rapid fire!)
  • Quantum: 150-200 damage (8/encounter)
  • 90% accuracy
  • Very long range
  • Quantum bypasses 50% shields
  • Alpha Strike: Fire everything (300-400 dmg, 2×/encounter)
  • "Military arsenal"

LEVEL 5 - EXPERIMENTAL WEAPONS:
  • 4 weapon types available
  • 95% accuracy
  • Extreme range
  • Transphasic Torpedoes: 120-180 dmg, ignore shields (5/enc)
  • Graviton Beam: 50 dmg + push/pull enemies
  • Tachyon Burst: 80 dmg to ALL enemies (3/enc)
  • Disruptor Cannon: 100-150 dmg + disable system
  • "Devastating and versatile"
```

#### Combat Scenario Example
```
FIGHT: Enemy Ship (300 HP, 100 Shield HP)

WEAPONS L2 (Phaser Array):
  Turn 1: 40 dmg → shields (60 HP left)
  Turn 2: 40 dmg → shields (20 HP left)
  Turn 3: 40 dmg → shields break, 20 → hull (280 HP left)
  Turn 4: 40 dmg → hull (240 HP left)
  Turn 5: 40 dmg → hull (200 HP left)
  → Enemy still alive, fight continues

WEAPONS L4 (Quantum + Pulse):
  Turn 1: Quantum torpedo 180 dmg → 90 to shields (bypasses 50%)
         Shields break, 80 → hull (220 HP left)
  Turn 2: Alpha Strike 350 dmg → hull
         Overkill
  → Enemy destroyed in 2 turns

Difference: 3+ turns saved = less damage taken
```

#### Special Abilities
```
LEVEL 2 - VARIABLE POWER:
  • Can fire at 50% power
  • Uses half power cost
  • Good for conserving energy

LEVEL 2 - PRECISE TARGETING:
  • Can target specific systems
  • Disable engines, weapons, shields
  • Tactical advantage

LEVEL 4 - ALPHA STRIKE:
  • Fire ALL weapons at once
  • 300-400 damage in one turn
  • 2 uses per encounter
  • Massive burst damage

LEVEL 5 - WEAPON VARIETY:
  • Choose weapon for situation
  • Transphasic for shielded enemies
  • Graviton for repositioning
  • Tachyon for multiple enemies
  • Disruptor for disabling
```

#### Key Stats Summary
```
LEVEL 0 (None):
  • Cannot engage in combat
  • Auto-flee only
  • Save 10-80 PU
  • Viable for pure exploration/diplomacy

LEVEL 2 (Phaser):
  • 30-50 damage
  • 80% accuracy
  • Unlimited shots
  • 20 PU (affordable)
  • Variable power option
  • Minimum for combat

LEVEL 4 (Quantum + Pulse):
  • 60-90 dmg ×2/turn (pulse)
  • 150-200 dmg torpedoes
  • 90% accuracy
  • 55 PU (expensive)
  • Quantum bypasses shields
  • Alpha Strike burst
  • Recommended for combat builds

LEVEL 5 (Experimental):
  • Variable damage (100-180)
  • 95% accuracy
  • 80 PU (very expensive)
  • 4 unique weapon types
  • Ultimate versatility
  • "Devastating"
```

**Pro Tip:** Weapons L4 with Computer L3 = 90% + 20% = 95% accuracy (capped). This combo makes you a surgical striker.

---

### 10. Communications Array

```
┌──────────────────────────────────────────────────────────────┐
│ 📡 COMMUNICATIONS ARRAY                                      │
│ Long-Range Communication, Translation, Diplomacy             │
└──────────────────────────────────────────────────────────────┘
```

**Function:** Your ship's voice. Essential for diplomacy and exploration.

#### Level Progression

| Level | Name | Range | Translation | Diplomacy | Power | Special |
|-------|------|:-----:|:-----------:|:---------:|:-----:|---------|
| **L0** | No Comms | None | None | — | 0 | Isolated |
| **L1** | Radio | Local | English | +0% | 5 | Basic Earth contact |
| **L2** | Subspace | System | Database | +10% | 8 | NPC missions |
| **L3** | Universal | Galaxy | Real-time | +20% | 12 | Speak to aliens |
| **L4** | Quantum | Unlimited | Instant | +35% | 18 | Classified networks |
| **L5** | Psionic | Empathic | Telepathic | +50% | 25 | Read emotions |

#### Power Consumption Chart
```
L1  █░░░░░░░░░░░░░░░░░░░  5 PU
L2  ██░░░░░░░░░░░░░░░░░░  8 PU
L3  ██░░░░░░░░░░░░░░░░░░ 12 PU
L4  ████░░░░░░░░░░░░░░░░ 18 PU
L5  █████░░░░░░░░░░░░░░░ 25 PU
```

#### Range & Connectivity
```
COMMUNICATION RANGE:

L0: ░  None      (total isolation)
L1: ████ Local    (same planet/station)
L2: ████████████ System-wide (real-time across system)
L3: ████████████████████ Galaxy-wide (instant across galaxy)
L4: ████████████████████████ Unlimited (instant anywhere)
L5: ████████████████████████████ Empathic (+ emotional layer)
```

#### Diplomacy Bonus
```
DIPLOMACY SUCCESS INCREASE:

L0: ░░░░░░░░░░  +0%  (no communication)
L1: ░░░░░░░░░░  +0%  (basic talk)
L2: ██░░░░░░░░ +10%  (network access)
L3: ████░░░░░░ +20%  (universal translation)
L4: ███████░░░ +35%  (classified intel)
L5: ██████████ +50%  (empathic understanding)

Example: Base diplomacy 60% success
  L3: 60% + 20% = 80%  (33% more successes)
  L5: 60% + 50% = 110% → 95% cap  (58% more successes)
```

#### Strategic Importance
```
EARLY GAME:  ★★★☆☆ Moderate (L1 for Earth contact)
MID GAME:    ★★★★☆ Important (L2-3 for aliens)
LATE GAME:   ★★★★☆ Important (L4-5 for depth)
EXPLORATION: ★★★★★ ESSENTIAL (Contact new species)
COMBAT:      ★★☆☆☆ Low (Not combat-related)
```

#### Dependencies
- **Low Power Cost** - One of cheapest systems
- **Enables Diplomacy** - L3+ unlocks diplomacy as alternative to combat
- **Synergy with Computer** - L3+ Comms + L4+ Computer = Codebreaking
- **Explorer/Support Build** - Required for Explorer/Support ship classes

#### Upgrade Path Recommendations

**Phase 1 (Earthbound):**
- L0 → L1 (seventh priority)
- 5 PU is cheap
- Basic Earth contact

**Phase 2 (Early Space):**
- **L1 → L2 ASAP for alien contact**
- System-wide communication
- Access to NPC missions
- +10% diplomacy helps

**Phase 2 (Mid-Game):**
- **L2 → L3 before first contact**
- Universal translator unlocks alien dialogue
- Diplomacy alternative to combat
- Galaxy-wide network access

**Phase 2 (Late-Game):**
- L3 → L4 for intel access
- Quantum encryption
- Classified networks
- L4 → L5 for unique RP experience

#### Features by Level
```
LEVEL 1 - RADIO TRANSCEIVER:
  • Local range (planet/station)
  • English only
  • Basic Earth contact
  • Receive short-range distress signals
  • "Hello? Can anyone hear me?"

LEVEL 2 - SUBSPACE RADIO:
  • System-wide range
  • Database translation
  • Real-time across star system
  • Access local information networks
  • Receive missions from NPCs
  • +10% diplomacy
  • "Connected to local network"

LEVEL 3 - UNIVERSAL TRANSLATOR:
  • Galaxy-wide range
  • Real-time translation (all species)
  • Communicate with all known aliens
  • Galactic information network access
  • +20% diplomacy
  • Unlock "Diplomacy" as combat alternative
  • "Speak to anyone, anywhere"

LEVEL 4 - QUANTUM ENTANGLEMENT COMM:
  • Unlimited range
  • Instant communication (no delay)
  • Cannot be intercepted or jammed
  • Access classified networks
  • +35% diplomacy
  • Receive special faction missions
  • "No delay, no interception"

LEVEL 5 - PSIONIC AMPLIFIER:
  • Unlimited + empathic range
  • Telepathic communication
  • Sense emotions and intentions
  • Detect lies/hostility
  • +50% diplomacy
  • "Empathic Understanding" ability
  • See another's perspective
  • Unlock hidden dialogue options
  • Communicate with non-verbal life
  • Sometimes receive visions/warnings
  • "Touch minds across the void"
```

#### Diplomacy vs. Combat
```
SCENARIO: Hostile Ship Encounter

NO COMMS (L0-1):
  → Must fight or flee
  → No dialogue options

UNIVERSAL TRANSLATOR (L3):
  → Can attempt diplomacy
  → Base 60% success
  → +20% from comms = 80%
  → Possible peaceful resolution
  → Unlock trade/alliance options

PSIONIC (L5):
  → Empathic understanding
  → Base 60% success
  → +50% from comms = 110% → 95% cap
  → Almost always succeed
  → Sense if they're lying
  → Deep cultural insight
  → Hidden dialogue branches
```

#### Special Abilities
```
LEVEL 3 - DIPLOMACY ALTERNATIVE:
  • Can talk instead of fight
  • Not all encounters are hostile
  • Negotiate, trade, ally
  • Star Trek TNG diplomatic approach

LEVEL 4 - QUANTUM SECURITY:
  • Cannot be intercepted
  • Cannot be jammed
  • Secure communications
  • Access classified missions

LEVEL 5 - EMPATHIC SENSING:
  • Detect lies (know if NPC lying)
  • Sense hostility before attack
  • "Empathic Understanding" - see from their perspective
  • Unlock unique dialogue with psionic species
  • Sometimes receive visions/warnings from unknown sources
```

#### Synergy: Comms + Computer (L3/L4)
```
LEVEL 3 COMMS + LEVEL 4 COMPUTER:
  "Codebreaking" ability
  → Intercept enemy communications
  → Learn enemy plans
  → Decrypt transmissions
  → Intel advantage in combat
```

#### Key Stats Summary
```
LEVEL 1 (Radio):
  • Local range only
  • English only
  • 5 PU (very cheap)
  • Basic Earth contact

LEVEL 3 (Universal):
  • Galaxy-wide range
  • All species translation
  • 12 PU (affordable)
  • +20% diplomacy
  • Diplomacy unlocked
  • Recommended for all builds
  • "Speak to anyone"

LEVEL 5 (Psionic):
  • Unlimited range
  • Telepathic/empathic
  • 25 PU (moderate)
  • +50% diplomacy
  • Sense lies/hostility
  • Hidden dialogue options
  • Talk to non-verbal life
  • "Touch minds"
  • Unique RP experience
```

**Pro Tip:** Communications L3 is mandatory for meaningful alien interaction. The universal translator opens up 50% of the game's content (diplomacy, trade, alliance paths).

---

## Ship Configuration Examples

### Scout-Class Configuration

```
┌──────────────────────────────────────────────────────────────┐
│ SCOUT-CLASS: FAST RECONNAISSANCE                             │
│ "Small, agile, sensors-focused"                              │
└──────────────────────────────────────────────────────────────┘

PRIORITY: Speed and stealth over combat

SYSTEM LEVELS:
  Hull:          L1  (50 HP, minimal)
  Power:         L2  (200 PU, efficient)
  Propulsion:    L3  (4× speed, 18% dodge) ★
  Warp:          L2  (9× FTL, 10 LY range)
  Life Support:  L1  (solo operation)
  Computer:      L2  (targeting assist)
  Sensors:       L3  (50 AU range) ★★
  Shields:       L1  (50 HP, minimal)
  Weapons:       L1  (laser only)
  Communications:L2  (system-wide)

POWER BUDGET:
  Total Power: 200 PU (with -10% reduction)
  Consumption: ~105 PU (after reduction)
  Available: 95 PU surplus

CLASS BONUSES:
  • +25% propulsion efficiency
  • +50% sensor range (50 AU → 75 AU!)
  • +15% evasion chance
  • Fast scanning (30% faster)

STRENGTHS:
  ✓ Excellent detection range
  ✓ Fast and evasive
  ✓ Power-efficient
  ✓ Good for exploration

WEAKNESSES:
  ✗ Fragile hull (50 HP)
  ✗ Minimal shields
  ✗ Low combat power
  ✗ Solo operation only

PLAYSTYLE:
  • Avoid combat via speed/sensors
  • Detect threats early, escape
  • Perfect for mapping new systems
  • Survey missions specialist

TOTAL COST: ~12 system levels
```

---

### Balanced Cruiser Configuration

```
┌──────────────────────────────────────────────────────────────┐
│ CRUISER-CLASS: JACK OF ALL TRADES                            │
│ "Balanced, versatile, general-purpose"                       │
└──────────────────────────────────────────────────────────────┘

PRIORITY: Balance across all systems

SYSTEM LEVELS (All L2-3):
  Hull:          L2  (100 HP, 15% kinetic armor)
  Power:         L3  (400 PU, -15% cost reduction) ★
  Propulsion:    L2  (2× speed, 10% dodge)
  Warp:          L2  (9× FTL, 10 LY range)
  Life Support:  L2  (4 crew, +10% morale)
  Computer:      L3  (tactical AI, +20% accuracy) ★
  Sensors:       L2  (5 AU range, +20% warning)
  Shields:       L3  (300 HP, 70% reduction) ★
  Weapons:       L3  (photon torpedoes) ★
  Communications:L2  (system-wide, +10% diplomacy)

POWER BUDGET:
  Total Power: 400 PU (with -15% reduction)
  Consumption: ~184 PU (after reduction)
  Available: 216 PU surplus

CLASS BONUSES:
  • +10% effectiveness in ALL mission types
  • -15% repair costs & fuel usage
  • +10% crew effectiveness (all skills)
  • Access to all mission types
  • 25% less system malfunctions

STRENGTHS:
  ✓ Can handle any situation
  ✓ No major weaknesses
  ✓ Good survivability (shields + hull)
  ✓ Decent combat (torpedoes + shields)
  ✓ Excellent power headroom

WEAKNESSES:
  ✗ Master of none
  ✗ Harder difficulty spikes
  ✗ Not optimized for any role

PLAYSTYLE:
  • Adapt to any mission type
  • Reliable workhorse ship
  • Safe exploration + combat
  • Best for first playthrough

TOTAL COST: ~25 system levels
```

---

### Heavy Cruiser Combat Configuration

```
┌──────────────────────────────────────────────────────────────┐
│ HEAVY CRUISER-CLASS: COMBAT POWERHOUSE                       │
│ "Heavy firepower with extended range"                        │
└──────────────────────────────────────────────────────────────┘

PRIORITY: Combat capability + operational range

SYSTEM LEVELS:
  Hull:          L4  (350 HP, 35% kinetic + 20% energy) ★★★
  Power:         L4  (700 PU, -20% cost, 100 PU emergency) ★★★
  Propulsion:    L3  (4× speed, 18% dodge, evasive)
  Warp:          L3  (125× FTL, 50 LY range, escape) ★
  Life Support:  L3  (10 crew, +20% morale)
  Computer:      L4  (tactical AI, +35% accuracy) ★★
  Sensors:       L3  (50 AU range, +40% warning)
  Shields:       L4  (500 HP, 85% reduction, adaptive) ★★★
  Weapons:       L4  (quantum torpedoes, alpha strike) ★★★
  Communications:L3  (galaxy-wide, +20% diplomacy)

POWER BUDGET:
  Total Power: 700 PU (with -20% reduction)
  Consumption: ~330 PU (after reduction)
  Available: 370 PU surplus
  + 100 PU emergency reserve

CLASS BONUSES:
  • +25% weapon damage
  • +25% shield strength
  • +50% mission duration before resupply
  • Can coordinate multiple ships
  • Systems last 30% longer

STRENGTHS:
  ✓ Excellent combat capability
  ✓ High survivability (adaptive shields + ablative hull)
  ✓ Long operational range
  ✓ Emergency power reserve
  ✓ Can lead combat groups

WEAKNESSES:
  ✗ High power consumption
  ✗ Expensive to maintain
  ✗ Slower than specialized ships

COMBAT EXAMPLE:
  Alpha Strike: 300-400 damage burst
  Then: Pulse phasers 60-90 dmg ×2/turn
  Defense: 500 HP adaptive shields + 350 HP hull
  Accuracy: 90% base + 35% computer = 95% (capped)

PLAYSTYLE:
  • Dominate hostile encounters
  • Deep space patrol
  • High-risk missions
  • Fleet command

TOTAL COST: ~36 system levels
```

---

### Explorer-Class Deep Space Configuration

```
┌──────────────────────────────────────────────────────────────┐
│ EXPLORER-CLASS: DEEP SPACE DISCOVERY                         │
│ "Go where no one has gone before"                            │
└──────────────────────────────────────────────────────────────┘

PRIORITY: Range, sensors, and self-sufficiency

SYSTEM LEVELS:
  Hull:          L3  (200 HP, 25% kinetic + 10% energy)
  Power:         L4  (700 PU, -20% cost, emergency) ★★
  Propulsion:    L3  (4× speed, 18% dodge)
  Warp:          L5  (729× FTL, unlimited, transwarp) ★★★★★
  Life Support:  L4  (25 crew, +30% morale, food production) ★★
  Computer:      L4  (tactical AI, +35% accuracy) ★★
  Sensors:       L5  (sector-wide, precognition, future vision) ★★★★★
  Shields:       L3  (300 HP, 70% reduction)
  Weapons:       L2  (phaser array)
  Communications:L4  (quantum, +35% diplomacy) ★★

POWER BUDGET:
  Total Power: 700 PU (with -20% reduction)
  Consumption: ~420 PU (after reduction)
  Available: 280 PU surplus

CLASS BONUSES:
  • +100% warp drive range per fuel unit
  • Deep space sensors (extreme range)
  • +25% diplomacy success
  • Can name discovered systems
  • Double XP from exploration/science
  • Resource prospecting from orbit

STRENGTHS:
  ✓ Unlimited warp range (go anywhere!)
  ✓ Precognitive sensors (see future!)
  ✓ Excellent diplomacy (+35% + 25% = +60%)
  ✓ Self-sufficient (food production)
  ✓ Large crew (25 capacity)

WEAKNESSES:
  ✗ Limited combat capability
  ✗ Vulnerable in direct combat
  ✗ Very expensive to build

UNIQUE ABILITIES:
  • Transwarp: Instant travel to any discovered system
  • Future Vision: See consequences before choosing
  • Resource Prospecting: Find rare materials from orbit
  • Name systems: Leave your mark on galaxy

PLAYSTYLE:
  • Explore uncharted space
  • First contact missions
  • Scientific discovery
  • Avoid combat via sensors
  • Ultimate explorer fantasy

TOTAL COST: ~39 system levels (endgame)
```

---

### Dreadnought Maximum Combat Configuration

```
┌──────────────────────────────────────────────────────────────┐
│ DREADNOUGHT-CLASS: MAXIMUM FIREPOWER                         │
│ "The ultimate expression of military power"                  │
└──────────────────────────────────────────────────────────────┘

PRIORITY: Overwhelming combat superiority

SYSTEM LEVELS (Focus on L4-5 combat systems):
  Hull:          L5  (500 HP, 45% kinetic + 30% energy, regen) ★★★★★
  Power:         L5  (1000 PU, -25% cost, +5 PU regen) ★★★★★
  Propulsion:    L4  (7× speed, 28% dodge, emergency burn) ★★
  Warp:          L4  (343× FTL, 200 LY, tactical jumps) ★★
  Life Support:  L4  (25 crew, +30% morale, food)
  Computer:      L5  (sentient AI, +50% all combat) ★★★★★
  Sensors:       L4  (500 AU, +60% warning, cloaked detection) ★★
  Shields:       L5  (800 HP, 95% reduction, 30% phase) ★★★★★
  Weapons:       L5  (experimental, 4 types) ★★★★★
  Communications:L3  (galaxy-wide, +20% diplomacy)

POWER BUDGET:
  Total Power: 1000 PU (with -25% reduction)
  Consumption: ~500 PU (after reduction)
  Available: 500 PU surplus
  + 5 PU regeneration per turn

CLASS BONUSES:
  • +40% weapon damage
  • +40% shield strength, +25% armor
  • Engage 3 enemies simultaneously
  • Area denial (enemies less likely to engage)
  • +50% XP from combat
  • Some factions negotiate rather than fight
  • Access to special heavy weapons

STRENGTHS:
  ✓ Near-invincible defense (phase shields + regen hull)
  ✓ Devastating offense (experimental weapons)
  ✓ Perfect accuracy (95% + 50% = capped)
  ✓ Sentient AI companion
  ✓ Can fight 3 enemies at once

WEAKNESSES:
  ✗ Extremely expensive (~200,000+ credits)
  ✗ High maintenance costs
  ✗ May affect diplomacy negatively
  ✗ Overkill for most content

COMBAT STATS:
  Offense:
    • 4 experimental weapon types
    • Base 95% accuracy + 50% AI = capped
    • +40% class damage bonus
    • Transphasic torpedoes ignore shields

  Defense:
    • 800 HP phase shields (95% reduction, 30% phase out)
    • 500 HP regenerative hull (5 HP/turn regen)
    • 45% kinetic armor, 30% energy armor
    • Total effective HP: ~20,000+ (math: hull + shields + armor + regen)

  Utility:
    • Sentient AI companion (emotional intelligence)
    • Tactical jumps (reposition in combat)
    • Multi-target engagement (3 at once)

PLAYSTYLE:
  • Dominate all combat
  • Territory defense
  • Major threat response
  • Show of force
  • "I am the danger"

TOTAL COST: ~46 system levels (maximum endgame)
```

---

## Upgrade Strategies

### Phase 1: Earthbound (All Systems L0 → L1)

**Goal:** Achieve spaceworthiness and unlock Phase 2

**Recommended Order:**
```
1. HULL L1          (50 HP - survive)           Cost: ~2,000 CR
2. POWER L1         (100 PU - run systems)      Cost: ~2,500 CR
3. PROPULSION L1    (1× speed - can move)       Cost: ~1,500 CR
4. LIFE SUPPORT L1  (1 crew - breathe)          Cost: ~1,000 CR
5. COMPUTER L1      (basic - operate ship)      Cost: ~1,000 CR
6. SENSORS L1       (1 AU - see threats)        Cost: ~800 CR
7. SHIELDS L1       (50 HP - optional)          Cost: ~1,500 CR
8. WEAPONS L1       (15-25 dmg - optional)      Cost: ~1,200 CR
9. COMMUNICATIONS L1 (local - Earth contact)    Cost: ~800 CR
10. WARP L1 ★★★     (1× FTL - UNLOCK PHASE 2)   Cost: ~5,000 CR

TOTAL ESTIMATED COST: ~17,300 CR
MISSIONS REQUIRED: ~15-20 missions @ 1,000 CR avg
```

**Strategy Tips:**
- Focus on systems 1-6 first (critical systems)
- Shields and Weapons are OPTIONAL for Phase 1 (save credits if needed)
- Warp Drive L1 is the FINAL requirement to leave Earth
- Complete as many missions as possible before upgrading Warp (you can't go back easily)

---

### Phase 2 Early Game: Foundation (L1 → L2)

**Goal:** Establish safe exploration capability

**Recommended Order:**
```
1. SENSORS L2       (5 AU - safety first!)      Priority: ★★★★★
2. COMMUNICATIONS L2 (system - NPC missions)    Priority: ★★★★★
3. POWER L2         (200 PU - support growth)   Priority: ★★★★☆
4. HULL L2          (100 HP - durability)       Priority: ★★★★☆
5. COMPUTER L2      (AI assist - QoL)           Priority: ★★★☆☆
6. WARP L2          (9× FTL - when ready)       Priority: ★★★☆☆
7. PROPULSION L2    (2× speed - comfort)        Priority: ★★☆☆☆
8. LIFE SUPPORT L2  (4 crew - if using crew)    Priority: ★★☆☆☆
9. SHIELDS L2       (150 HP - before combat)    Priority: ★★★★☆ (combat)
10. WEAPONS L2      (30-50 dmg - before combat) Priority: ★★★★☆ (combat)
```

**Why This Order:**
- **Sensors first** - Detect threats early, avoid danger
- **Communications** - Unlock alien dialogue, missions
- **Power** - -10% cost reduction helps future upgrades
- **Hull** - Double HP is significant survival boost
- **Shields + Weapons** - Only if pursuing combat path

---

### Phase 2 Mid-Game: Specialization (L2 → L3)

**Goal:** Choose your ship's identity

**Combat Build Path:**
```
1. POWER L3         (400 PU - support weapons/shields)
2. SHIELDS L3       (300 HP, 70% reduction - durability)
3. WEAPONS L3       (photon torpedoes - firepower)
4. HULL L3          (200 HP - survivability)
5. COMPUTER L3      (tactical AI - accuracy)
6. PROPULSION L3    (evasive maneuvers - dodge)
7. SENSORS L3       (50 AU - awareness)
8. Others as needed
```

**Explorer Build Path:**
```
1. POWER L3         (400 PU - support sensors/warp)
2. SENSORS L3       (50 AU - deep space scan)
3. WARP L3          (125× FTL, 50 LY - galaxy access)
4. COMMUNICATIONS L3 (universal translator - aliens)
5. COMPUTER L3      (tactical AI - synergies)
6. LIFE SUPPORT L3  (10 crew - self-sufficiency)
7. HULL L2-3        (survivability)
8. Shields/Weapons L2 (minimal combat)
```

**Balanced Build Path:**
```
Upgrade ALL systems to L2-3 evenly
  → Qualifies for Cruiser-class
  → Versatile, no weaknesses
  → Good for first playthrough
```

---

### Phase 2 Late-Game: Perfection (L3 → L4-5)

**Goal:** Maximize your chosen specialization

**Key Upgrades by Build:**

**Combat Dreadnought (L4-5):**
```
Priority systems:
  1. POWER L4-5      (700-1000 PU - run everything)
  2. SHIELDS L4-5    (adaptive/phase - invincibility)
  3. WEAPONS L4-5    (quantum/experimental - devastation)
  4. HULL L4-5       (ablative/regen - endurance)
  5. COMPUTER L4-5   (tactical/sentient - perfection)

Supporting systems (L3 adequate):
  - Warp L3 (can escape encounters)
  - Sensors L3 (awareness)
  - Propulsion L3 (dodge)
  - Life Support L3 (crew)
  - Comms L3 (diplomacy alternative)
```

**Explorer Excellence (L4-5):**
```
Priority systems:
  1. POWER L4-5      (700-1000 PU - run everything)
  2. WARP L4-5       (tactical jumps/transwarp - go anywhere)
  3. SENSORS L4-5    (multi-phasic/quantum - see everything)
  4. COMMUNICATIONS L4-5 (quantum/psionic - perfect diplomacy)
  5. COMPUTER L4-5   (tactical/sentient - companion)
  6. LIFE SUPPORT L4 (food production - self-sufficient)

Supporting systems (L2-3):
  - Hull L3 (adequate protection)
  - Shields L3 (defense)
  - Weapons L2 (minimal)
  - Propulsion L3 (speed)
```

---

### Power Core Upgrade Priority

**CRITICAL INSIGHT:** Always upgrade Power Core early in each tier.

```
UPGRADE PATH                 BENEFIT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
L1 → L2 (+100 PU, -10% cost)  Saves ~10-15 PU total
  ↓                           Pays for itself in 2-3 upgrades
Upgrade 2-3 other systems     Now more affordable
  ↓
L2 → L3 (+200 PU, -15% cost)  Saves ~15-25 PU total
  ↓                           Opens up L3 systems
Upgrade 3-5 other systems     Significantly cheaper
  ↓
L3 → L4 (+300 PU, -20% cost)  Saves ~25-40 PU total
  ↓                           + 100 PU emergency reserve
Upgrade remaining systems     All 20% cheaper
```

**Math Example:**
```
SCENARIO: Upgrading 5 systems to L3 (20 PU each base = 100 PU total)

With Power L2 (-10%):
  100 PU × 0.90 = 90 PU
  Savings: 10 PU

With Power L3 (-15%):
  100 PU × 0.85 = 85 PU
  Savings: 15 PU

With Power L4 (-20%):
  100 PU × 0.80 = 80 PU
  Savings: 20 PU

LESSON: Upgrade Power Core BEFORE other systems for multiplicative savings
```

---

## System Synergies

### Powerful Combinations

#### Computer + Sensors = "Deep Space Scan"
```
REQUIREMENT: Computer L2+ AND Sensors L3+

EFFECT:
  • Detailed analysis of everything in sensor range
  • Identify all ship classes, tech levels
  • Detect hidden cargo, weapons
  • Assess threat levels accurately
  • Find rare materials automatically

USE CASE: Perfect for explorers and scientists
```

#### Computer + Shields = "Auto-Modulation"
```
REQUIREMENT: Computer L3+ AND Shields L3+

EFFECT:
  • Shields adapt to damage faster
  • After 1 hit, gain resistance to that type
  • (Normally takes 2-3 hits to adapt)
  • Rotate shield frequency automatically

USE CASE: Combat survivability boost
```

#### Computer + Weapons = "Improved Targeting"
```
REQUIREMENT: Computer L2+ AND Weapons L2+

EFFECT:
  • +15% weapon accuracy (stacks with Computer base bonus)
  • Example: Weapon 80% + Computer 20% + Synergy 15% = 95% (capped)
  • More hits = more damage = faster fights

USE CASE: Combat damage output
```

#### Computer + Propulsion = "Optimal Routing"
```
REQUIREMENT: Computer L3+ AND Propulsion L3+

EFFECT:
  • Travel 20% faster between locations
  • Automated course corrections
  • Fuel efficiency improved
  • Less time wasted in transit

USE CASE: Exploration quality of life
```

#### Warp + Sensors = "Safe Jump"
```
REQUIREMENT: Warp L3+ AND Sensors L4+

EFFECT:
  • Detect hazards before warping
  • Avoid stellar phenomena (pulsars, black holes)
  • No accidental warp into danger
  • Can plot safest route

USE CASE: Deep space exploration safety
```

#### Communications + Computer = "Codebreaking"
```
REQUIREMENT: Communications L3+ AND Computer L4+

EFFECT:
  • Intercept enemy communications
  • Decrypt transmissions
  • Learn enemy plans in advance
  • Intel advantage in encounters

USE CASE: Tactical intelligence gathering
```

#### Life Support + Computer = "Automated Systems"
```
REQUIREMENT: Life Support L4+ AND Computer L4+

EFFECT:
  • Crew efficiency +25%
  • Automated resource management
  • Reduced crew workload
  • Better crew morale

USE CASE: Large crew management
```

---

### Build Synergy Examples

#### "Perfect Scout" Synergies
```
Propulsion L3 + Sensors L3 + Computer L2
  → Fast movement + long detection + optimal routing
  → Detect threats from 50 AU away
  → Escape at 4× speed before they arrive
  → Scan everything efficiently

Result: Near-perfect reconnaissance capability
```

#### "Tactical Superiority" Synergies
```
Weapons L4 + Computer L5 + Shields L4
  → Quantum weapons (90% accuracy)
  → +50% accuracy from sentient AI = 95% (capped)
  → Adaptive shields learn from attacks
  → Auto-shield activation when threatened

Result: Dominate any combat encounter
```

#### "Deep Explorer" Synergies
```
Warp L5 + Sensors L5 + Communications L4 + Computer L4
  → Transwarp anywhere instantly
  → Precognitive sensors (see future)
  → Quantum comms (cannot be jammed)
  → Codebreaking (intercept alien comms)

Result: Ultimate exploration and first contact capability
```

---

## Quick Reference Cards

### Hull Quick Reference
```
┌─────────────────────────────────────────┐
│ 🛡️  HULL & STRUCTURE                    │
├─────────────────────────────────────────┤
│ L1: 50 HP,  5% kinetic armor   (0 PU)  │
│ L2: 100 HP, 15% kinetic        (0 PU)  │
│ L3: 200 HP, 25% kin, 10% ener  (0 PU)  │
│ L4: 350 HP, 35% kin, 20% ener  (0 PU)  │
│ L5: 500 HP, 45% kin, 30% ener (10 PU)  │
│     +1% regen/turn (5 HP)               │
├─────────────────────────────────────────┤
│ PRIORITY: ★★★★★ (Critical always)       │
│ UPGRADE: L1 first, L2-3 mid-game        │
│ COMBAT: L3+ required                    │
│ POWER: Free until L5                    │
└─────────────────────────────────────────┘
```

### Power Core Quick Reference
```
┌─────────────────────────────────────────┐
│ ⚡ POWER CORE                           │
├─────────────────────────────────────────┤
│ L1: 100 PU,  80% eff,  0% reduction    │
│ L2: 200 PU,  85% eff, -10% reduction   │
│ L3: 400 PU,  90% eff, -15% reduction   │
│ L4: 700 PU,  93% eff, -20% reduction   │
│     +100 PU emergency reserve           │
│ L5: 1000 PU, 98% eff, -25% reduction   │
│     +5 PU/turn regen                    │
├─────────────────────────────────────────┤
│ PRIORITY: ★★★★★ (Upgrade early)         │
│ TIP: Cost reduction pays for itself     │
│ COMBO: Upgrade Power before others      │
│ POWER: Generates, doesn't consume       │
└─────────────────────────────────────────┘
```

### Warp Drive Quick Reference
```
┌─────────────────────────────────────────┐
│ 🌌 WARP DRIVE                           │
├─────────────────────────────────────────┤
│ L1: W1 (1× c), 2 LY,  3 sys   (20 PU) │
│ L2: W3 (9× c), 10 LY, 12 sys  (30 PU) │
│ L3: W5 (125×c), 50 LY, 50 sys (50 PU) │
│     Can escape encounters               │
│ L4: W7 (343×c), 200 LY        (80 PU) │
│     Tactical jumps                      │
│ L5: W9 (729×c), unlimited    (120 PU) │
│     Transwarp corridors                 │
├─────────────────────────────────────────┤
│ PRIORITY: ★★★★★ (L1 = Phase 2!)         │
│ PHASE 1: L1 required to leave Earth     │
│ EXPLORE: L2-3 opens galaxy              │
│ ENDGAME: L5 is flashy luxury            │
└─────────────────────────────────────────┘
```

### Shields Quick Reference
```
┌─────────────────────────────────────────┐
│ 🛡️ SHIELDS                               │
├─────────────────────────────────────────┤
│ L1:  50 HP, 25% reduc,  5/turn (15 PU) │
│ L2: 150 HP, 50% reduc, 15/turn (25 PU) │
│     Block 1 shot (1×/encounter)         │
│ L3: 300 HP, 70% reduc, 30/turn (40 PU) │
│     Rapid recharge (full in 3 turns)    │
│ L4: 500 HP, 85% reduc, 50/turn (60 PU) │
│     Adaptive (learn attacks)            │
│ L5: 800 HP, 95% reduc, 80/turn (85 PU) │
│     30% phase out (avoid dmg)           │
├─────────────────────────────────────────┤
│ PRIORITY: ★★★★★ (Combat essential)      │
│ COMBAT: L2 minimum, L3-4 recommended    │
│ EXPLORE: L1-2 adequate                  │
│ COST: High power consumption            │
└─────────────────────────────────────────┘
```

### Weapons Quick Reference
```
┌─────────────────────────────────────────┐
│ 🎯 WEAPONS                              │
├─────────────────────────────────────────┤
│ L1: 15-25 dmg, 70% acc        (10 PU)  │
│     Laser cannon                        │
│ L2: 30-50 dmg, 80% acc        (20 PU)  │
│     Phaser array (unlimited)            │
│ L3: 40-60 / 80-120, 85% acc   (35 PU)  │
│     Phaser + Photon torpedoes           │
│ L4: 60-90×2 / 150-200, 90%    (55 PU)  │
│     Pulse + Quantum, Alpha Strike       │
│ L5: 100-180 variable, 95%     (80 PU)  │
│     4 experimental weapon types         │
├─────────────────────────────────────────┤
│ PRIORITY: ★★★★★ (Combat builds)         │
│ COMBAT: L3-4 for serious fighting       │
│ EXPLORE: Optional (can avoid combat)    │
│ COMBO: +Computer for accuracy           │
└─────────────────────────────────────────┘
```

### Sensors Quick Reference
```
┌─────────────────────────────────────────┐
│ 🔍 SENSORS                              │
├─────────────────────────────────────────┤
│ L1: 1 AU, visual, 0% warn      (5 PU)  │
│ L2: 5 AU, composition, +20%   (10 PU)  │
│     Life signs, material scan           │
│ L3: 50 AU, comprehensive, +40%(20 PU)  │
│     Scan mini-game, hidden objects      │
│ L4: 500 AU, detailed, +60%    (35 PU)  │
│     Detect cloaked, anomalies           │
│ L5: Sector, precognitive, +100%(50 PU) │
│     Future Vision ability               │
├─────────────────────────────────────────┤
│ PRIORITY: ★★★★★ (Exploration)           │
│ EXPLORE: L3 sweet spot (50 AU)          │
│ SAFETY: Higher = more warning           │
│ L5: See future (game-changing)          │
└─────────────────────────────────────────┘
```

### Communications Quick Reference
```
┌─────────────────────────────────────────┐
│ 📡 COMMUNICATIONS                       │
├─────────────────────────────────────────┤
│ L1: Local, English, +0%        (5 PU)  │
│ L2: System, database, +10%     (8 PU)  │
│     NPC missions unlocked               │
│ L3: Galaxy, universal, +20%   (12 PU)  │
│     Diplomacy alternative               │
│ L4: Unlimited, quantum, +35%  (18 PU)  │
│     Classified networks                 │
│ L5: Empathic, psionic, +50%   (25 PU)  │
│     Sense lies, hidden dialogue         │
├─────────────────────────────────────────┤
│ PRIORITY: ★★★★☆ (Diplomacy builds)      │
│ ALIENS: L3 required for translation     │
│ L5: Unique RP experience                │
│ COST: Very affordable (5-25 PU)         │
└─────────────────────────────────────────┘
```

---

## Conclusion

This guide represents the complete specifications for all 10 ship systems in Space Adventures. Whether you're building a nimble Scout, a balanced Cruiser, or an overwhelming Dreadnought, understanding these systems is key to success.

**Key Takeaways:**

1. **Power Core is King** - Always upgrade early for cost reduction benefits
2. **Phase 1 Goal** - All systems to L1 (especially Warp!) to unlock space
3. **Choose Your Path** - Combat, exploration, or balanced - specialize in Phase 2
4. **Synergies Matter** - Computer + other systems = powerful combinations
5. **No Perfect Build** - Each playstyle has strengths and trade-offs

**Recommended First Playthrough Path:**
- Phase 1: Get all systems to L1 (~17,000 CR, 15-20 missions)
- Phase 2 Early: Sensors L2, Comms L2, Power L2 (safety and missions)
- Phase 2 Mid: All systems to L2-3 (Cruiser-class, balanced)
- Phase 2 Late: Specialize L4-5 based on preferred playstyle

**Document Stats:**
- Total systems: 10
- Total levels per system: 6 (L0-L5)
- Total unique configurations: 60 detailed entries
- Ship examples: 5 complete builds
- Power budget scenarios: 4 milestones
- Synergy combinations: 7 documented
- Quick reference cards: 7 systems

Good luck, Captain. The stars await.

---

**Document Version:** 1.0
**Last Updated:** November 13, 2025
**Source Files:**
- `/docs/03-game-design/ship-systems/ship-systems.md`
- `/docs/03-game-design/ship-systems/ship-classification-system.md`
- `/godot/scripts/systems/*.gd` (all 10 system implementations)

**Related Documents:**
- [Ship Classification System](../03-game-design/ship-systems/ship-classification-system.md)
- [Ship Systems Specification](../03-game-design/ship-systems/ship-systems.md)
- [Game Design Document](../03-game-design/core-systems/game-design-document.md)
- [Player Progression System](../03-game-design/core-systems/player-progression-system.md)
