# Mission Reward Guidelines

**Version:** 1.0
**Date:** November 7, 2025
**Purpose:** Comprehensive guide for designing balanced, rewarding mission rewards for Space Adventures
**Audience:** Content creators (human and AI), mission designers, balancing team

---

## Table of Contents
1. [Overview](#overview)
2. [Reward Scaling by Difficulty](#reward-scaling-by-difficulty)
3. [Reward Components Explained](#reward-components-explained)
4. [Choice-Based Bonuses](#choice-based-bonuses)
5. [PartRegistry Integration](#partregistry-integration)
6. [Examples from Tutorial Mission](#examples-from-tutorial-mission)
7. [Common Mistakes to Avoid](#common-mistakes-to-avoid)
8. [AI Generation Guidelines](#ai-generation-guidelines)
9. [Testing Checklist](#testing-checklist)

---

## Overview

### Mission Reward Philosophy

**Rewarding Player Investment:**
- Missions reward players for time, skill, and smart choices
- Rewards scale with difficulty and player effort
- Multiple paths to success provide variety in rewards
- Discovery and exploration grant bonus rewards
- Failure still provides partial XP (learning experience)

**Progression Balance:**
- Tutorial mission: 100-175 XP (1-1.75 missions to Level 2)
- Average mission: 100-200 XP based on difficulty
- Optional objectives add 25-50 XP
- Skill checks add 15-40 XP per success
- Perfect completion adds 50-100 XP

**Economy Balance:**
- Credits allow purchasing common parts
- Rare parts locked behind missions (story-driven unlocks)
- Early missions generous to enable progression
- Mid-game balances earning/spending
- Late-game rewards reflect higher stakes

---

## Reward Scaling by Difficulty

### Difficulty Stars and Base Rewards

| Difficulty | Stars | Base XP | Credits | Common Parts | Rare Parts | Typical Mission Types |
|------------|-------|---------|---------|--------------|------------|-----------------------|
| **Tutorial** | ★☆☆☆☆ | 100-150 | 300-500 | 2-3 | 0 | Introduction, first salvage |
| **Easy** | ★★☆☆☆ | 100-150 | 200-400 | 1-2 | 0-1 | Basic salvage, simple exploration |
| **Medium** | ★★★☆☆ | 150-200 | 300-600 | 1-2 | 1 | Trade missions, moderate salvage |
| **Hard** | ★★★★☆ | 200-300 | 400-800 | 2-3 | 1-2 | Combat, complex diplomacy |
| **Very Hard** | ★★★★★ | 300-400 | 500-1000 | 2-3 | 2-3 | Story missions, major confrontations |

### Notes on Scaling

**XP Ranges:**
- Lower bound: Minimal engagement, direct path
- Upper bound: Perfect completion with all bonuses
- Range gives designers flexibility for choice rewards

**Credit Scaling:**
- Reflects mission risk and time investment
- Tutorial missions generous (jumpstart economy)
- Later missions balanced around upgrade costs
- Hard missions provide meaningful financial reward

**Part Distribution:**
- Common parts: Readily available through missions
- Rare parts: Gated behind specific missions or difficult objectives
- Story missions: Always provide progression-critical parts
- Optional missions: Random quality for replayability

---

## Reward Components Explained

### 1. Experience Points (XP)

**Purpose:** Player level progression, skill point acquisition

**XP Curve (Milestone 1 - Levels 1-5):**
```
Level 2: 100 XP total
Level 3: 250 XP total (+150)
Level 4: 450 XP total (+200)
Level 5: 700 XP total (+250)
```

**Average Missions to Level:**
- Level 1 → 2: 1 mission (tutorial = 100 XP)
- Level 2 → 3: 1-2 missions (150 XP needed)
- Level 3 → 4: 1-2 missions (200 XP needed)
- Level 4 → 5: 2 missions (250 XP needed)

**Design Impact:**
- Expect 8-12 missions in Milestone 1
- Each mission should provide meaningful XP progress
- Never below 50 XP for partial completion
- Tutorial mission should get player to ~Level 2

**JSON Structure:**
```json
{
  "rewards": {
    "xp": 100
  }
}
```

---

### 2. Credits (Currency)

**Purpose:** Purchase parts, pay for upgrades, economic transactions

**Economy Context:**
- Starting credits: 0 (tutorial awards 300)
- Level 1 upgrade cost: 100 credits (common part)
- Level 2 upgrade cost: 200 credits (common part)
- Level 3 upgrade cost: 300 credits (common part)

**Rarity Multipliers:**
- Common part: 1.0x base cost
- Uncommon part: 1.5x base cost
- Rare part: 2.0x base cost

**Credit Guidelines by Mission Type:**

**Salvage Missions:**
- Direct material recovery = lower credits
- Focus on parts over currency
- 200-400 credits typical

**Trade Missions:**
- Negotiation and diplomacy = higher credits
- Currency as main reward
- 400-800 credits typical

**Combat Missions:**
- High risk = high financial reward
- Salvage from enemies adds value
- 500-1000 credits typical

**Story Missions:**
- Varied based on narrative importance
- Major missions: 500-800 credits
- Minor story beats: 300-500 credits

**JSON Structure:**
```json
{
  "rewards": {
    "credits": 300
  }
}
```

---

### 3. Ship Parts (Items)

**Purpose:** Enable ship upgrades, progression gates, collection goals

**Part Types:**
- **Common (White):** Standard parts, readily available
- **Uncommon (Green):** Better stats, moderate rarity
- **Rare (Blue):** Best stats, limited availability

**Part Award Guidelines:**

**Story Missions (Guaranteed Parts):**
```json
{
  "rewards": {
    "items": [
      {"part_id": "hull_scrap_plates_l1_common", "quantity": 1},
      {"part_id": "power_fusion_cell_l1_common", "quantity": 1}
    ]
  }
}
```
- Always provide parts for intended progression
- Lock progression-critical parts behind specific missions
- Use common rarity for guaranteed rewards

**Optional Missions (Variable Parts):**
```json
{
  "rewards": {
    "items": [
      {"part_id": "propulsion_chemical_thruster_l1_common", "quantity": 1}
    ]
  }
}
```
- Can include uncommon/rare parts for variety
- Difficulty affects rarity chance
- Use for exploration/discovery missions

**Part Quantity:**
- Standard mission: 1-2 parts
- Complex mission: 2-3 parts
- Story milestone: 2-4 parts
- Avoid overwhelming inventory (weight limits exist)

---

### 4. Discovered Parts (Story Unlocks)

**Purpose:** Unlock parts in PartRegistry for crafting/purchasing

**Discovery vs Award:**

**Discovered Parts:**
```json
{
  "rewards": {
    "discovered_parts": [
      "hull_scrap_plates_l1_common",
      "power_fusion_cell_l1_common"
    ]
  }
}
```
- Adds part to player's "known parts" catalog
- Part becomes visible in workshop
- Player can find/purchase this part in future
- Does NOT add part to inventory

**Awarded Parts (items):**
```json
{
  "rewards": {
    "items": [
      {"part_id": "hull_scrap_plates_l1_common", "quantity": 1}
    ]
  }
}
```
- Adds physical part to player inventory
- Immediately usable for upgrades
- Consumes inventory weight capacity

**When to Use Each:**

**Discovered Parts:**
- First mission introducing a system
- Story moments revealing new technology
- Exploration discoveries
- Trade route unlocks

**Awarded Parts:**
- Mission completion rewards
- Quest item delivery
- Salvage operations
- Combat loot

**Typical Pattern (Tutorial Mission):**
```json
{
  "rewards": {
    "items": [
      {"part_id": "hull_scrap_plates_l1_common", "quantity": 1},
      {"part_id": "power_fusion_cell_l1_common", "quantity": 1}
    ],
    "discovered_parts": [
      "hull_scrap_plates_l1_common",
      "power_fusion_cell_l1_common"
    ]
  }
}
```
- Award parts immediately for installation
- Discover parts for future reference
- Enables "I know what this is" in future missions

---

### 5. Mission Unlocks (Progression Gates)

**Purpose:** Control narrative flow, gate content, create progression chains

**Unlock Types:**

**Mission Unlocks:**
```json
{
  "rewards": {
    "unlocks": [
      "mission_first_salvage",
      "mission_power_up"
    ]
  }
}
```
- Unlocks specific follow-up missions
- Creates quest chains
- Ensures story coherence

**Location Unlocks:**
```json
{
  "rewards": {
    "unlocks": [
      "location_spaceport_ruins",
      "location_research_facility"
    ]
  }
}
```
- Opens new exploration areas
- Enables future mission types
- Expands world map

**Hub Unlocks:**
```json
{
  "rewards": {
    "unlocks": [
      "workshop_hub"
    ]
  }
}
```
- Unlocks major gameplay systems
- Typically story missions only
- One-time progression gates

**Unlock Guidelines:**
- Tutorial mission: Unlock 2-3 starter missions + workshop
- Story missions: Unlock next story beat + optional content
- Optional missions: Unlock related optional missions
- Exploration missions: Unlock nearby locations
- Never lock all content behind one mission

---

## Choice-Based Bonuses

### Skill Check Success Bonuses

**Standard Skill Check (+25 XP):**
```json
{
  "choice_id": "hack_terminal",
  "text": "Hack the security terminal",
  "requirements": {
    "skill": "engineering",
    "skill_level": 3
  },
  "success_chance": "skill_based",
  "consequences": {
    "success": {
      "text": "You successfully bypass the security system.",
      "next_stage": "inside_safe",
      "effects": ["security_bypassed"],
      "xp_bonus": 25
    },
    "failure": {
      "text": "Security alert triggered!",
      "next_stage": "inside_alerted"
    }
  }
}
```
- Standard skill check: +25 XP
- Represents player skill investment
- Only on success (failure gives no bonus)

**High-Level Skill Check (+40 XP):**
```json
{
  "choice_id": "advanced_repair",
  "requirements": {
    "skill": "engineering",
    "skill_level": 5
  },
  "consequences": {
    "success": {
      "xp_bonus": 40
    }
  }
}
```
- Requires skill level 5+: +40 XP
- Reflects rarity of high skill levels
- Reserved for challenging content

---

### Discovery Bonuses (+15-50 XP)

**Minor Discovery (+15 XP):**
```json
{
  "choice_id": "examine_logs",
  "consequences": {
    "success": {
      "text": "You find useful information in the logs.",
      "effects": ["learned_backstory"],
      "xp_bonus": 15
    }
  }
}
```
- Optional investigation
- Flavor text or minor lore
- Small XP reward for curiosity

**Moderate Discovery (+25-30 XP):**
```json
{
  "choice_id": "scan_area",
  "consequences": {
    "success": {
      "text": "Your scan reveals a hidden cache.",
      "effects": ["found_secret"],
      "xp_bonus": 30
    }
  }
}
```
- Hidden content or secret area
- Tangible gameplay benefit
- Rewards exploration

**Major Discovery (+50 XP):**
```json
{
  "choice_id": "discover_mystery",
  "requirements": {
    "skill": "science",
    "skill_level": 4
  },
  "consequences": {
    "success": {
      "text": "You uncover evidence of something extraordinary.",
      "effects": ["major_story_revelation"],
      "xp_bonus": 50
    }
  }
}
```
- Story revelations
- Unlocks major content
- Requires skill + exploration
- Reserved for important discoveries

---

### Perfect Completion Bonuses (+50-100 XP)

**Perfect Mission Completion (+50 XP):**
```json
{
  "choice_id": "complete_all_objectives",
  "consequences": {
    "success": {
      "text": "Mission accomplished with all objectives completed.",
      "effects": ["perfect_completion"],
      "xp_bonus": 50,
      "complete": true
    }
  }
}
```
- All optional objectives completed
- No mistakes or failures
- Clean execution

**Exceptional Outcome (+100 XP):**
```json
{
  "choice_id": "best_possible_outcome",
  "consequences": {
    "success": {
      "text": "You've achieved the best possible outcome.",
      "effects": ["legendary_success"],
      "xp_bonus": 100,
      "complete": true
    }
  }
}
```
- Reserved for story missions
- Multiple skill checks passed
- Exceptional player choices
- Rare achievement

---

### Bonus Stacking Examples

**Example 1: Skilled Explorer**
- Base mission XP: 150
- Skill check passed (+25)
- Secret discovered (+30)
- **Total: 205 XP**

**Example 2: Perfect Execution**
- Base mission XP: 200
- Three skill checks (+75)
- All objectives (+50)
- **Total: 325 XP**

**Example 3: Story Discovery**
- Base mission XP: 150
- Major revelation skill check (+40)
- Story discovery (+50)
- Perfect completion (+100)
- **Total: 340 XP** (exceptional, story mission only)

---

## PartRegistry Integration

### Understanding PartRegistry

**PartRegistry Purpose:**
- Central authority for all ship parts
- Validates part IDs
- Manages part discovery state
- Provides part metadata

**Part ID Format:**
```
{system}_{type}_{level}_{rarity}

Examples:
hull_scrap_plates_l1_common
power_fusion_cell_l1_common
propulsion_ion_drive_l2_uncommon
warp_coil_l3_rare
```

---

### Valid Part IDs by System

**Hull System:**
```
hull_scrap_plates_l1_common
hull_composite_armor_l1_uncommon
hull_reinforced_bulkheads_l1_rare
hull_durasteel_plating_l2_common
hull_ablative_armor_l2_uncommon
```

**Power System:**
```
power_fusion_cell_l1_common
power_plasma_reactor_l1_uncommon
power_antimatter_core_l1_rare
power_enhanced_reactor_l2_common
power_zero_point_module_l2_rare
```

**Propulsion System:**
```
propulsion_chemical_thruster_l1_common
propulsion_ion_drive_l1_uncommon
propulsion_plasma_engine_l1_rare
propulsion_fusion_drive_l2_common
propulsion_gravitic_engine_l2_rare
```

**Warp Drive System:**
```
warp_coil_l1_common
warp_nacelle_l1_uncommon
warp_core_l1_rare
warp_enhanced_coil_l2_common
warp_transwarp_coil_l2_rare
```

**Life Support System:**
```
life_support_air_recycler_l1_common
life_support_hydroponic_bay_l1_uncommon
life_support_bio_filter_l1_rare
life_support_enhanced_scrubbers_l2_common
life_support_stasis_pods_l2_rare
```

---

### Rarity Distribution Guidelines

**Mission Type Rarity Tables:**

**Story Mission (Guaranteed Progression):**
- Common: 100% (progression parts)
- Uncommon: 0-20% (bonus rewards)
- Rare: 0% (special occasions only)

**Salvage Mission:**
- Common: 70%
- Uncommon: 25%
- Rare: 5%

**Exploration Mission:**
- Common: 50%
- Uncommon: 35%
- Rare: 15%

**Combat Mission:**
- Common: 60%
- Uncommon: 30%
- Rare: 10%

**Trade Mission:**
- Common: 80% (purchased goods)
- Uncommon: 15%
- Rare: 5%

---

### Story-Driven Unlock Strategy

**Tutorial Mission ("The Inheritance"):**
```json
{
  "rewards": {
    "items": [
      {"part_id": "hull_scrap_plates_l1_common", "quantity": 1},
      {"part_id": "power_fusion_cell_l1_common", "quantity": 1}
    ],
    "discovered_parts": [
      "hull_scrap_plates_l1_common",
      "power_fusion_cell_l1_common"
    ]
  }
}
```
**Why:** Introduces hull and power systems, foundational for all ships

**First Salvage Mission:**
```json
{
  "rewards": {
    "items": [
      {"part_id": "propulsion_chemical_thruster_l1_common", "quantity": 1}
    ],
    "discovered_parts": [
      "propulsion_chemical_thruster_l1_common",
      "propulsion_ion_drive_l1_uncommon"
    ]
  }
}
```
**Why:** Enables ship movement, discover alternate propulsion types

**Warp Drive Quest (Phase 1 Goal):**
```json
{
  "rewards": {
    "items": [
      {"part_id": "warp_coil_l1_common", "quantity": 1}
    ],
    "discovered_parts": [
      "warp_coil_l1_common",
      "warp_nacelle_l1_uncommon",
      "warp_core_l1_rare"
    ]
  }
}
```
**Why:** Critical for Phase 2 unlock, multiple quality tiers discovered

---

### Validation Checklist

**Before finalizing mission rewards:**

1. **Part ID Validation:**
   ```
   ✓ All part_ids exist in PartRegistry
   ✓ System names match: hull, power, propulsion, warp, life_support, computer, sensors, shields, weapons, communications
   ✓ Level format: l1, l2, l3, l4, l5
   ✓ Rarity format: common, uncommon, rare
   ```

2. **Quantity Validation:**
   ```
   ✓ Quantity is positive integer
   ✓ Total parts don't exceed 3-4 per mission
   ✓ Consider inventory weight limits
   ```

3. **Discovery Validation:**
   ```
   ✓ Discovered parts also in items (or vice versa)
   ✓ New parts introduce logical progression
   ✓ Don't discover all parts at once
   ```

4. **Progression Validation:**
   ```
   ✓ Story missions provide required parts
   ✓ Optional missions provide variety
   ✓ Player can't get stuck without parts
   ```

---

## Examples from Tutorial Mission

### Complete Tutorial Mission Breakdown

**Mission:** "The Inheritance" (mission_tutorial.json)
**Difficulty:** ★☆☆☆☆ (Tutorial)
**Base Rewards:**
```json
{
  "rewards": {
    "xp": 100,
    "credits": 300,
    "items": [
      {"part_id": "hull_scrap_plates_l1_common", "quantity": 1},
      {"part_id": "power_fusion_cell_l1_common", "quantity": 1}
    ],
    "discovered_parts": [
      "hull_scrap_plates_l1_common",
      "power_fusion_cell_l1_common"
    ],
    "unlocks": [
      "mission_first_salvage",
      "mission_power_up",
      "workshop_hub"
    ]
  }
}
```

---

### Choice-Based Bonus Examples

**Choice 1: Side Entrance (+15 XP)**
```json
{
  "choice_id": "side_entrance",
  "text": "Circle around, look for another way in",
  "consequences": {
    "success": {
      "text": "You emerge inside the workshop area, behind the scavengers.",
      "next_stage": "workshop_uncontested",
      "effects": ["avoided_scavengers"],
      "xp_bonus": 15
    }
  }
}
```
**Why:** Rewarding exploration and caution

---

**Choice 2: Observe First (Skill Check + 25 XP)**
```json
{
  "choice_id": "observe_first",
  "text": "Stay hidden, observe the situation before acting",
  "requirements": {
    "skill": "science",
    "skill_level": 2
  },
  "success_chance": "skill_based",
  "consequences": {
    "success": {
      "text": "You gather valuable intel about the scavengers and museum systems.",
      "next_stage": "workshop_informed",
      "effects": ["gathered_intel", "knows_power_active"],
      "xp_bonus": 25
    },
    "failure": {
      "text": "You accidentally alert the scavengers.",
      "next_stage": "workshop_contested",
      "effects": ["encountered_scavengers", "suspicious_scavengers"]
    }
  }
}
```
**Why:** Skill check provides information and bonus XP

---

**Choice 3: Diplomatic Resolution (+30 XP)**
```json
{
  "choice_id": "explain_inheritance",
  "text": "Explain that your grandfather owned this workshop—it's legally yours",
  "requirements": {
    "skill": "diplomacy",
    "skill_level": 2
  },
  "success_chance": "skill_based",
  "consequences": {
    "success": {
      "text": "The scavengers believe you and step aside peacefully.",
      "next_stage": "workshop_open",
      "effects": ["peaceful_resolution", "potential_ally"],
      "xp_bonus": 30
    },
    "failure": {
      "text": "They don't believe your story.",
      "next_stage": "workshop_negotiation",
      "effects": ["failed_diplomacy"]
    }
  }
}
```
**Why:** Diplomatic skill check, higher reward for peaceful resolution

---

**Choice 4: Security System Mastery (+40 XP)**
```json
{
  "choice_id": "reactivate_security",
  "text": "Access the museum's security system, politely escort the scavengers out",
  "requirements": {
    "skill": "engineering",
    "skill_level": 3
  },
  "success_chance": "skill_based",
  "consequences": {
    "success": {
      "text": "Service robots activate and escort scavengers out.",
      "next_stage": "workshop_open",
      "effects": ["security_active", "museum_controlled"],
      "xp_bonus": 40
    },
    "failure": {
      "text": "Security alarms blare. The scavengers are alerted.",
      "next_stage": "workshop_contested",
      "effects": ["failed_hacking", "scavengers_alerted"]
    }
  }
}
```
**Why:** High-skill solution, creative problem solving, significant bonus

---

**Choice 5: Perfect Completion (+50 XP)**
```json
{
  "choice_id": "begin_repairs",
  "text": "Begin installing the basic systems",
  "consequences": {
    "success": {
      "text": "By sunset, you have a ship. Level 1 systems across the board.",
      "next_stage": "mission_complete",
      "mission_result": "success",
      "xp_bonus": 50
    }
  }
}
```
**Why:** Mission completion, ship functional, major milestone

---

**Choice 6: Discovery Bonus (+35 XP)**
```json
{
  "choice_id": "examine_datapad",
  "text": "Check your grandfather's datapad for notes about the ship",
  "requirements": {
    "skill": "science",
    "skill_level": 2
  },
  "success_chance": "skill_based",
  "consequences": {
    "success": {
      "text": "The datapad contains decades of notes and a mysterious star map.",
      "next_stage": "workshop_claimed",
      "effects": ["found_mystery", "grandpa_notes"],
      "xp_bonus": 35
    },
    "failure": {
      "text": "The datapad's encryption is beyond you.",
      "next_stage": "workshop_claimed",
      "effects": []
    }
  }
}
```
**Why:** Optional discovery, story hook, skill-gated content

---

### Optimal Path Analysis

**Perfect Run (Maximum XP):**
```
1. Observe first (Science 2+): +25 XP
2. Reactivate security (Engineering 3+): +40 XP
3. Examine datapad (Science 2+): +35 XP
4. Begin repairs: +50 XP

Base: 100 XP
Bonuses: +150 XP
Total: 250 XP
```
**Result:** Player reaches Level 2 and halfway to Level 3 in one mission

**Average Run (Moderate XP):**
```
1. Side entrance: +15 XP
2. Confident approach: +30 XP
3. Begin repairs: +50 XP

Base: 100 XP
Bonuses: +95 XP
Total: 195 XP
```
**Result:** Player nearly reaches Level 2

**Minimal Run (Base XP):**
```
1. Front entrance: 0 XP
2. Use biometric access: +10 XP
3. Enter workshop: +15 XP
4. Begin repairs: +50 XP

Base: 100 XP
Bonuses: +75 XP
Total: 175 XP
```
**Result:** Player reaches Level 2 comfortably

**Key Insight:** Even the "worst" path provides meaningful progression. Perfect execution provides significant advantage but isn't required.

---

## Common Mistakes to Avoid

### 1. Over-Rewarding Early Missions

**❌ Mistake:**
```json
{
  "mission_id": "second_mission",
  "difficulty": 2,
  "rewards": {
    "xp": 500,
    "credits": 2000,
    "items": [
      {"part_id": "hull_reinforced_bulkheads_l3_rare", "quantity": 5}
    ]
  }
}
```

**Why Wrong:**
- 500 XP would level player from 2 → 4 instantly
- 2000 credits bypasses economy for 6+ missions
- Level 3 rare parts skip intended progression
- Quantity 5 floods inventory

**✅ Fix:**
```json
{
  "mission_id": "second_mission",
  "difficulty": 2,
  "rewards": {
    "xp": 150,
    "credits": 400,
    "items": [
      {"part_id": "hull_durasteel_plating_l2_common", "quantity": 1}
    ]
  }
}
```

**Guideline:** Second mission should grant ~150 XP, 300-400 credits, 1-2 common parts.

---

### 2. Under-Rewarding Difficult Content

**❌ Mistake:**
```json
{
  "mission_id": "complex_heist",
  "difficulty": 5,
  "requirements": {
    "min_level": 4,
    "required_systems": ["sensors", "computer"],
    "completed_missions": ["mission_chain_1", "mission_chain_2"]
  },
  "rewards": {
    "xp": 100,
    "credits": 200,
    "items": [
      {"part_id": "sensors_basic_array_l1_common", "quantity": 1}
    ]
  }
}
```

**Why Wrong:**
- Difficulty 5 mission with Level 1 rewards
- Player has Level 4 requirements, needs Level 3+ parts
- 100 XP too low for complex mission
- Rewards don't match investment

**✅ Fix:**
```json
{
  "mission_id": "complex_heist",
  "difficulty": 5,
  "requirements": {
    "min_level": 4,
    "required_systems": ["sensors", "computer"],
    "completed_missions": ["mission_chain_1", "mission_chain_2"]
  },
  "rewards": {
    "xp": 300,
    "credits": 800,
    "items": [
      {"part_id": "sensors_advanced_suite_l3_rare", "quantity": 1},
      {"part_id": "computer_tactical_core_l3_uncommon", "quantity": 1}
    ]
  }
}
```

**Guideline:** Difficulty 5 missions should provide 300+ XP, 600-1000 credits, rare/uncommon parts.

---

### 3. Missing Part Unlocks

**❌ Mistake:**
```json
{
  "mission_id": "discover_warp_technology",
  "type": "exploration",
  "rewards": {
    "xp": 200,
    "credits": 500
  }
}
```

**Why Wrong:**
- Mission title implies warp discovery
- No warp parts awarded or discovered
- Player can't act on discovery
- Wasted narrative opportunity

**✅ Fix:**
```json
{
  "mission_id": "discover_warp_technology",
  "type": "exploration",
  "rewards": {
    "xp": 200,
    "credits": 500,
    "items": [
      {"part_id": "warp_coil_l1_common", "quantity": 1}
    ],
    "discovered_parts": [
      "warp_coil_l1_common",
      "warp_nacelle_l1_uncommon"
    ],
    "unlocks": [
      "mission_test_warp_drive"
    ]
  }
}
```

**Guideline:** Discovery missions must unlock related parts and follow-up content.

---

### 4. Invalid Part ID References

**❌ Mistake:**
```json
{
  "rewards": {
    "items": [
      {"part_id": "hull_armor_plate", "quantity": 1},
      {"part_id": "power_reactor_mk2", "quantity": 1},
      {"part_id": "warp_drive_coil", "quantity": 1}
    ]
  }
}
```

**Why Wrong:**
- Missing level designator (l1, l2, etc.)
- Missing rarity (common, uncommon, rare)
- Wrong naming format
- Parts don't exist in PartRegistry

**✅ Fix:**
```json
{
  "rewards": {
    "items": [
      {"part_id": "hull_composite_armor_l1_uncommon", "quantity": 1},
      {"part_id": "power_enhanced_reactor_l2_common", "quantity": 1},
      {"part_id": "warp_coil_l1_common", "quantity": 1}
    ]
  }
}
```

**Guideline:** Always use format: `{system}_{type}_{level}_{rarity}`. Validate against PartRegistry.

---

### 5. Unclear Unlock Chains

**❌ Mistake:**
```json
{
  "mission_id": "random_encounter_1",
  "requirements": {
    "completed_missions": ["mission_alpha", "mission_beta", "mission_gamma"]
  },
  "rewards": {
    "unlocks": ["mission_omega"]
  }
}
```

**Why Wrong:**
- Requires 3 missions to unlock 1 random encounter
- No clear narrative connection
- Players may miss content
- Unlock chain too complex

**✅ Fix:**
```json
{
  "mission_id": "rescue_operation",
  "requirements": {
    "completed_missions": ["distress_call_received"]
  },
  "rewards": {
    "unlocks": [
      "grateful_survivors_quest",
      "location_refugee_camp"
    ]
  }
}
```

**Guideline:** Unlock chains should be clear, narratively logical, and rewarding.

---

### 6. Inconsistent Difficulty Scaling

**❌ Mistake:**
```json
[
  {
    "mission_id": "easy_salvage",
    "difficulty": 1,
    "rewards": {"xp": 200, "credits": 500}
  },
  {
    "mission_id": "hard_combat",
    "difficulty": 4,
    "rewards": {"xp": 150, "credits": 300}
  }
]
```

**Why Wrong:**
- Easy mission rewards better than hard mission
- Inverted difficulty/reward ratio
- No incentive to attempt challenging content

**✅ Fix:**
```json
[
  {
    "mission_id": "easy_salvage",
    "difficulty": 1,
    "rewards": {"xp": 100, "credits": 300}
  },
  {
    "mission_id": "hard_combat",
    "difficulty": 4,
    "rewards": {"xp": 250, "credits": 700}
  }
]
```

**Guideline:** Higher difficulty = proportionally higher rewards. Always.

---

## AI Generation Guidelines

### Specific Rules for AI Content Generation

When generating missions via AI service, apply these constraints:

**1. XP Formula:**
```python
base_xp = 50 + (difficulty * 50)
# Difficulty 1: 100 XP
# Difficulty 2: 150 XP
# Difficulty 3: 200 XP
# Difficulty 4: 250 XP
# Difficulty 5: 300 XP

# Add variance: ±25 XP
final_xp = random.randint(base_xp - 25, base_xp + 25)
```

**2. Credits Formula:**
```python
base_credits = 200 + (difficulty * 150)
# Difficulty 1: 350 credits
# Difficulty 2: 500 credits
# Difficulty 3: 650 credits
# Difficulty 4: 800 credits
# Difficulty 5: 950 credits

# Add variance: ±100 credits
final_credits = random.randint(base_credits - 100, base_credits + 100)
```

**3. Part Selection Algorithm:**
```python
def select_mission_rewards(difficulty: int, mission_type: str) -> list:
    num_parts = 1 if difficulty <= 2 else 2

    # Determine part level (match player expected level)
    part_level = min(difficulty, 3)  # Cap at L3 for Milestone 1

    # Select rarity based on mission type
    rarity_weights = {
        "salvage": {"common": 0.7, "uncommon": 0.25, "rare": 0.05},
        "exploration": {"common": 0.5, "uncommon": 0.35, "rare": 0.15},
        "combat": {"common": 0.6, "uncommon": 0.3, "rare": 0.1},
        "trade": {"common": 0.8, "uncommon": 0.15, "rare": 0.05},
        "story": {"common": 1.0, "uncommon": 0.0, "rare": 0.0}
    }

    rarity = random.choices(
        ["common", "uncommon", "rare"],
        weights=rarity_weights[mission_type].values()
    )[0]

    # Select random systems (avoid duplicates)
    available_systems = ["hull", "power", "propulsion", "warp", "life_support"]
    selected_systems = random.sample(available_systems, num_parts)

    # Build part IDs
    parts = []
    for system in selected_systems:
        part_id = f"{system}_{get_random_part_type(system)}_l{part_level}_{rarity}"
        if validate_part_exists(part_id):
            parts.append({"part_id": part_id, "quantity": 1})

    return parts
```

**4. Skill Check Bonus Assignment:**
```python
def assign_skill_check_bonus(skill_level: int) -> int:
    if skill_level <= 2:
        return 15  # Low skill check
    elif skill_level <= 4:
        return 25  # Standard skill check
    else:
        return 40  # High skill check
```

---

### Quality Control Checklist for AI

**Before finalizing AI-generated mission:**

```
✓ XP within range for difficulty (base ± 25)
✓ Credits within range for difficulty (base ± 100)
✓ Parts count: 1-2 for easy, 2-3 for hard
✓ Part levels don't exceed difficulty level
✓ Part IDs validated against PartRegistry
✓ Rarity distribution matches mission type
✓ Skill check bonuses match skill level (15/25/40)
✓ Discovery bonuses justified (15-50 XP)
✓ No perfect completion bonus unless story mission
✓ Total XP with all bonuses < 400 (prevents exploits)
✓ Unlocks are narratively logical
✓ Discovered parts include awarded parts
```

---

### AI Prompt Template

```
Generate a mission reward structure for:

Mission Type: {mission_type}
Difficulty: {difficulty} (1-5 stars)
Mission ID: {mission_id}
Player Level: {player_level}

Requirements:
1. Base XP: {base_xp} ± 25
2. Base Credits: {base_credits} ± 100
3. Parts: {num_parts} parts, level {part_level}, rarity weighted for {mission_type}
4. Skill checks: Assign bonuses (15/25/40 XP) based on skill level
5. Discoveries: Optional, 15-50 XP if narratively appropriate
6. Unlocks: 1-3 logical follow-up missions or locations

Validate all part_ids against PartRegistry format:
{system}_{type}_l{level}_{rarity}

Available systems: hull, power, propulsion, warp, life_support
Rarities: common, uncommon, rare
Levels: 1-3 (Milestone 1)

Output JSON following mission-framework.md schema.
```

---

## Testing Checklist

### Pre-Release Mission Testing

**1. Reward Calculation Testing:**
```
✓ Total base XP matches difficulty tier
✓ All bonus XP sources identified and tested
✓ Maximum possible XP calculated (with all bonuses)
✓ Minimum possible XP calculated (failure path)
✓ XP range is reasonable (not too wide/narrow)
```

**2. Economy Impact Testing:**
```
✓ Credits awarded align with difficulty
✓ Credit amount supports 1-2 upgrade purchases
✓ Parts awarded are useful at current game stage
✓ Part rarity matches acquisition difficulty
✓ Total rewards don't break economy progression
```

**3. Progression Testing:**
```
✓ Mission unlocks test: Complete mission → Check unlocks available
✓ Part discovery test: Complete mission → Parts visible in workshop
✓ Item awards test: Complete mission → Items in inventory
✓ Level progression test: Track XP gain through full playthrough
```

**4. Balance Testing:**
```
✓ Compare mission to similar difficulty missions
✓ Time-to-reward ratio feels fair (15min mission = appropriate rewards)
✓ Optional objectives feel worth pursuing
✓ Skill checks feel rewarding but not mandatory
✓ Failure paths still provide some progression
```

---

### Testing Scenarios

**Scenario 1: Economy Balance Test**
```
Test: Complete 5 missions of same difficulty
Expected Result:
- Player gains 1-1.5 levels
- Player can afford 2-3 upgrades
- Player has parts for 2-3 system upgrades
- Player has discovered 5-8 new parts
```

**Scenario 2: Skill Investment Test**
```
Test: Complete mission twice (once with skills, once without)
Expected Result:
- Skilled player: 30-50% more XP via bonuses
- Skilled player: Access to better story outcomes
- Skilled player: Feels rewarded for specialization
- Unskilled player: Still completes with base rewards
```

**Scenario 3: Progression Gate Test**
```
Test: Track required missions to unlock Phase 2
Expected Result:
- 8-12 missions to reach all systems Level 1
- Each system unlocked via 1-2 dedicated missions
- Unlocks feel natural, not forced
- Player understands progression path
```

---

### Quality Assurance Metrics

**Mission Reward Quality Scorecard:**

| Metric | Target | Weight |
|--------|--------|--------|
| XP matches difficulty | 100% | Critical |
| Credits appropriate | 100% | Critical |
| Part IDs valid | 100% | Critical |
| Rarity distribution logical | 90% | High |
| Unlocks narratively coherent | 90% | High |
| Skill bonuses assigned correctly | 100% | High |
| Discovery rewards justified | 80% | Medium |
| Economy impact balanced | 90% | High |

**Pass Threshold:** 95% overall score with all Critical metrics at 100%

---

## Conclusion

**Mission rewards are the primary progression driver in Space Adventures.** Well-designed rewards:

1. **Motivate Players:** Clear goals, satisfying outcomes
2. **Balance Progression:** Not too fast, not too slow
3. **Reward Skill:** Better players earn more
4. **Support Economy:** Credits and parts flow logically
5. **Tell Stories:** Rewards reflect narrative importance
6. **Enable Exploration:** Discovery rewarded, not punished

**Use these guidelines to:**
- Design missions that feel fair and rewarding
- Validate AI-generated content
- Balance risk vs. reward
- Create satisfying progression curves
- Avoid common pitfalls

**Remember:** Players should feel that every mission matters. Even failed missions teach lessons. Perfect missions feel legendary. This balance is the heart of great mission design.

---

**Document Status:** Complete v1.0
**Last Updated:** November 7, 2025
**Related Documents:**
- [Mission Framework](./mission-framework.md) - Mission JSON schema and structure
- [Player Progression System](../core-systems/player-progression-system.md) - XP curves and leveling
- [Ship Systems](../ship-systems/ship-systems.md) - Part requirements and upgrades
- [Economy Implementation Checklist](../../02-developer-guides/systems/ECONOMY-IMPLEMENTATION-CHECKLIST.md) - Technical implementation

**For Questions/Revisions:** Consult with game design team or reference tutorial mission as gold standard.
