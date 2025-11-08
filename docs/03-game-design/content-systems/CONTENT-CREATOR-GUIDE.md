# Space Adventures - Content Creator Guide

**Version:** 1.0
**Date:** November 7, 2025
**Purpose:** Complete guide for creating high-quality missions from scratch
**Audience:** Content creators (human and AI), mission designers, narrative writers

---

## Table of Contents
1. [Getting Started](#getting-started)
2. [Mission Creation Workflow](#mission-creation-workflow)
3. [Step-by-Step Mission Design](#step-by-step-mission-design)
4. [Quality Standards](#quality-standards)
5. [Testing Procedures](#testing-procedures)
6. [Best Practices](#best-practices)
7. [Common Pitfalls](#common-pitfalls)
8. [Resources & Templates](#resources--templates)

---

## Getting Started

### What You'll Need

**Essential Reading:**
1. **[Mission Framework](./mission-framework.md)** - Mission structure and JSON schema
2. **[Mission Reward Guidelines](./mission-reward-guidelines.md)** - Reward balancing and economy
3. **[Player Progression System](../core-systems/player-progression-system.md)** - XP curves and leveling
4. **[Ship Systems](../ship-systems/ship-systems.md)** - System requirements and mechanics

**Tools:**
- Text editor with JSON validation (VS Code recommended)
- Mission template files (see [Templates](#resources--templates))
- PartRegistry reference (for valid part IDs)

**Time Investment:**
- Simple mission (2 stages): 1-2 hours
- Complex mission (4+ stages): 3-5 hours
- Story mission (branching paths): 5-8 hours

---

## Mission Creation Workflow

### Overview of Process

```
1. Concept & Design (30 min)
   ↓
2. Write Mission JSON (1-3 hours)
   ↓
3. Balance Rewards (30 min)
   ↓
4. Validate & Test (30 min - 1 hour)
   ↓
5. Polish & Revise (30 min)
   ↓
6. Final Review & Submit
```

### Quick Start Path

**"I want to create a mission right now!"**

1. **Choose a template:** Start with `/godot/assets/data/mission_templates/salvage_template.json`
2. **Copy template:** Save as `my_mission.json`
3. **Customize:** Change title, description, choices
4. **Balance rewards:** Use [Mission Reward Guidelines](./mission-reward-guidelines.md) tables
5. **Validate:** Run through testing checklist
6. **Test in-game:** Load mission and play through all paths

---

## Step-by-Step Mission Design

### Step 1: Concept & Design (30 minutes)

#### Define Your Mission

**Answer these questions:**

1. **What type of mission is this?**
   - Salvage: Retrieve ship parts
   - Exploration: Discover new locations/information
   - Trade: Negotiation and economy
   - Rescue: Help others in need
   - Combat: Tactical encounter
   - Story: Advance main narrative

2. **What's the core conflict?**
   - Example: "Scavengers occupy workshop, player must claim inheritance"
   - Example: "Distress signal from abandoned station, but is it a trap?"

3. **What choices will the player make?**
   - Minimum 2 meaningful choices per stage
   - Each choice should have different outcomes
   - No "obviously wrong" choices

4. **What skills are relevant?**
   - Engineering: Technical solutions, repairs
   - Diplomacy: Negotiation, persuasion
   - Combat: Tactical decisions, fighting
   - Science: Analysis, investigation

5. **What systems are required?**
   - Hull, Power: Usually required
   - Propulsion: If travel involved
   - Sensors: If detection needed
   - Communications: If diplomacy possible

#### Define Difficulty

Use this rubric:

| Difficulty | Level Req. | Skill Checks | Systems Required | Complexity |
|------------|-----------|--------------|------------------|------------|
| ★☆☆☆☆ (Tutorial) | 1 | 0-1 checks (level 1-2) | Hull, Power only | 2 stages, linear |
| ★★☆☆☆ (Easy) | 1-2 | 1-2 checks (level 2-3) | 2-3 systems | 2-3 stages, minimal branching |
| ★★★☆☆ (Medium) | 3-4 | 2-3 checks (level 3-4) | 3-4 systems | 3-4 stages, some branching |
| ★★★★☆ (Hard) | 5-7 | 3-4 checks (level 4-6) | 4-6 systems | 4+ stages, significant branching |
| ★★★★★ (Very Hard) | 8-10 | 4+ checks (level 6-10) | 6+ systems | 5+ stages, complex branching |

#### Outline Story Flow

**Create a simple flowchart:**

```
START: Mission Briefing
   ↓
STAGE 1: Approach
   ├─ Choice A (Stealth) → Stage 2a (Safe)
   ├─ Choice B (Direct) → Stage 2b (Combat)
   └─ Choice C (Diplomacy) → Stage 2c (Negotiation)
   ↓
STAGE 2: Main Challenge
   [Varies based on Stage 1 choice]
   ↓
STAGE 3: Resolution
   ├─ Success outcome
   ├─ Partial success
   └─ Failure outcome
   ↓
END: Rewards
```

**Example Outline Template:**

```markdown
Mission: "The Inheritance"
Type: Story/Salvage
Difficulty: ★☆☆☆☆

Flow:
1. Discovery: Find grandfather's workshop
2. Obstacle: Scavengers occupy it
3. Resolution: Claim workshop
   - Path A: Stealth (side entrance)
   - Path B: Diplomacy (negotiate)
   - Path C: Engineering (security system)
4. Reward: Workshop access + initial parts
```

---

### Step 2: Write Mission JSON (1-3 hours)

#### Start with Template

**For salvage mission:**

```bash
cp /godot/assets/data/mission_templates/salvage_template.json my_mission.json
```

**Template structure:**

```json
{
  "mission_id": "mission_template_salvage",
  "title": "[CHANGE ME]",
  "type": "salvage",
  "location": "[CHANGE ME]",
  "description": "[CHANGE ME]",
  "difficulty": 2,
  "requirements": {
    "min_level": 1,
    "required_systems": [],
    "completed_missions": []
  },
  "objectives": [
    "[Primary objective]",
    "[Optional objective]"
  ],
  "stages": [
    {
      "stage_id": "stage_1",
      "title": "[CHANGE ME]",
      "description": "[CHANGE ME]",
      "choices": [
        {
          "choice_id": "choice_1",
          "text": "[CHANGE ME]",
          "consequences": {
            "success": {
              "text": "[CHANGE ME]",
              "next_stage": "stage_2"
            }
          }
        }
      ]
    }
  ],
  "rewards": {
    "xp": 100,
    "credits": 300,
    "items": [],
    "discovered_parts": [],
    "unlocks": []
  }
}
```

#### Write Mission Metadata

**Mission ID:**
- Format: `mission_{category}_{name}`
- Example: `mission_tutorial`, `mission_salvage_spaceport`, `mission_story_rival`
- Must be unique across all missions
- Use lowercase, underscores only

**Title:**
- Evocative, mysterious, intriguing
- 2-5 words
- Examples: "The Inheritance", "Echoes in Hangar 7", "The Last Transmission"
- Avoid spoilers in title

**Location:**
- Where the mission takes place
- Examples: "Kennedy Spaceport Ruins", "Abandoned Research Facility", "Wasteland Trading Post"

**Description:**
- 2-3 sentences
- Hook the player
- Set the tone
- Don't reveal everything

**Example:**

```json
{
  "mission_id": "mission_salvage_spaceport_warp",
  "title": "Echoes in Hangar 7",
  "type": "salvage",
  "location": "Kennedy Spaceport Ruins",
  "description": "Abandoned decades ago, Kennedy Spaceport still holds valuable tech. Your sensors indicate a warp coil in Hangar 7, but security drones still patrol.",
  "difficulty": 2
}
```

#### Define Requirements

**Minimum Level:**
- Tutorial: 1
- Easy: 1-2
- Medium: 3-4
- Hard: 5-7
- Very Hard: 8-10

**Required Systems:**
- Only list systems that are REQUIRED to complete
- Don't list systems that just make it easier
- Example: Warp mission requires `["warp"]` to be installed

**Completed Missions:**
- List mission IDs that must be done first
- Creates quest chains
- Example: `["mission_tutorial"]` for first post-tutorial mission

**Example:**

```json
{
  "requirements": {
    "min_level": 1,
    "required_systems": [],
    "completed_missions": ["mission_tutorial"]
  }
}
```

#### Write Objectives

**Primary Objective:**
- What the player must do to complete mission
- Clear, actionable
- Example: "Retrieve warp coil from Hangar 7"

**Optional Objectives:**
- Extra goals for bonus rewards
- Use `[OPTIONAL]` prefix
- Example: "[OPTIONAL] Disable security without destroying drones"

**Example:**

```json
{
  "objectives": [
    "Retrieve warp coil from Hangar 7",
    "[OPTIONAL] Disable security without destroying drones",
    "[OPTIONAL] Recover engineer's personal log"
  ]
}
```

---

#### Write Stages & Choices

**Stage Structure:**

Each stage should have:
- `stage_id`: Unique identifier
- `title`: Stage header (what's happening)
- `description`: Scene-setting narrative (2-4 sentences)
- `choices`: 2-5 player options

**Choice Structure:**

Each choice should have:
- `choice_id`: Unique within mission
- `text`: Player-facing choice button text
- `requirements`: (Optional) Skill/system requirements
- `success_chance`: (Optional) "skill_based" or percentage
- `consequences`: What happens (success/failure paths)

**Example Stage:**

```json
{
  "stage_id": "approach",
  "title": "Approaching the Spaceport",
  "description": "The rusted gates of Kennedy Spaceport loom ahead. Collapsed towers and overgrown runways tell the story of rapid abandonment. Your destination is Hangar 7, visible in the distance. Security drones patrol in predictable patterns.",
  "choices": [
    {
      "choice_id": "hack_gate",
      "text": "Hack the security terminal at the gate",
      "requirements": {
        "skill": "engineering",
        "skill_level": 3
      },
      "success_chance": "skill_based",
      "consequences": {
        "success": {
          "text": "The terminal flickers to life. Ancient security protocols are no match for your skills. The drones power down, marking you as 'authorized personnel'.",
          "next_stage": "inside_safe",
          "effects": ["drones_disabled"],
          "xp_bonus": 25
        },
        "failure": {
          "text": "Your attempt triggers a security alert. The drones converge on your position!",
          "next_stage": "inside_combat",
          "effects": ["drones_alerted"]
        }
      }
    },
    {
      "choice_id": "sneak",
      "text": "Wait for patrol pattern, then sneak past",
      "success_chance": 70,
      "consequences": {
        "success": {
          "text": "Timing your movement carefully, you slip past the patrol. The hangar door stands ahead, unguarded.",
          "next_stage": "inside_safe"
        },
        "failure": {
          "text": "A drone's searchlight sweeps across you. Detected!",
          "next_stage": "inside_detected"
        }
      }
    },
    {
      "choice_id": "direct",
      "text": "Just walk in. They're old drones, probably non-functional",
      "consequences": {
        "text": "The drones power up immediately, weapons charging. They're very functional.",
        "next_stage": "inside_combat"
      }
    }
  ]
}
```

**Writing Good Choices:**

✅ **Good:**
- "Hack the security terminal" (specific, active)
- "Wait for patrol pattern, then sneak past" (shows player thinking)
- "Negotiate with the scavenger leader" (diplomatic)

❌ **Bad:**
- "Use your skills" (vague)
- "Do the smart thing" (condescending)
- "Win" (not a choice)

**Consequences Guidelines:**

- **success/failure**: Most skill checks have both
- **next_stage**: Where player goes next
- **effects**: Flags for later stages (e.g., "drones_disabled")
- **xp_bonus**: Reward for skill checks (15/25/40 XP)
- **complete**: Set to `true` for mission end

**Conditional Stage Progression:**

Use `effects` to track player choices:

```json
{
  "stage_id": "escape",
  "description": "Mission accomplished. You head for the exit.",
  "conditional_text": {
    "if_drones_disabled": "The drones remain inactive as you walk out. A clean operation.",
    "if_noise_made": "But as you leave the office, you hear the whir of drone rotors. They heard you.",
    "default": "The coast is clear. You slip out unnoticed."
  }
}
```

---

### Step 3: Balance Rewards (30 minutes)

Use **[Mission Reward Guidelines](./mission-reward-guidelines.md)** tables.

#### Base Rewards

**Lookup table by difficulty:**

| Difficulty | XP | Credits | Parts |
|------------|---------|---------|-------|
| ★☆☆☆☆ | 100-150 | 300-500 | 2-3 common |
| ★★☆☆☆ | 100-150 | 200-400 | 1-2 (mostly common) |
| ★★★☆☆ | 150-200 | 300-600 | 1-2 (1 rare) |
| ★★★★☆ | 200-300 | 400-800 | 2-3 (1-2 rare) |
| ★★★★★ | 300-400 | 500-1000 | 2-3 (2-3 rare) |

**Example for ★★☆☆☆ mission:**

```json
{
  "rewards": {
    "xp": 150,
    "credits": 400,
    "items": [
      {"part_id": "propulsion_chemical_thruster_l1_common", "quantity": 1}
    ],
    "discovered_parts": [
      "propulsion_chemical_thruster_l1_common",
      "propulsion_ion_drive_l1_uncommon"
    ],
    "unlocks": [
      "mission_next_in_chain"
    ]
  }
}
```

#### Part Selection

**Use PartRegistry valid IDs:**

**Format:** `{system}_{type}_l{level}_{rarity}`

**Available Systems:**
- `hull`, `power`, `propulsion`, `warp`, `life_support`
- `computer`, `sensors`, `shields`, `weapons`, `communications`

**Levels:** `l1`, `l2`, `l3`, `l4`, `l5` (Milestone 1 = l1-l3)

**Rarities:** `common`, `uncommon`, `rare`

**Example Part IDs:**
```
hull_scrap_plates_l1_common
power_fusion_cell_l1_common
propulsion_chemical_thruster_l1_common
warp_coil_l1_common
life_support_air_recycler_l1_common
```

**Part Award vs Discovery:**

```json
{
  "rewards": {
    "items": [
      // Player GETS this part in inventory
      {"part_id": "warp_coil_l1_common", "quantity": 1}
    ],
    "discovered_parts": [
      // Player DISCOVERS these parts (unlocked in workshop)
      "warp_coil_l1_common",        // Also award it
      "warp_nacelle_l1_uncommon",   // Discover for future
      "warp_core_l1_rare"           // Discover for future
    ]
  }
}
```

**Rule of thumb:**
- Award 1-2 parts per mission
- Discover 1-3 additional parts
- Always include awarded parts in discovered_parts

#### Unlocks

**Mission Unlocks:**
```json
{
  "unlocks": [
    "mission_follow_up_quest",
    "mission_optional_side_story"
  ]
}
```

**Location Unlocks:**
```json
{
  "unlocks": [
    "location_research_facility",
    "location_trading_post"
  ]
}
```

**Hub Unlocks (rare):**
```json
{
  "unlocks": [
    "workshop_hub"  // Tutorial mission only
  ]
}
```

---

### Step 4: Validate & Test (30 min - 1 hour)

#### JSON Validation

**Check JSON syntax:**

```bash
# In VS Code: Format Document (Shift+Alt+F)
# Or use online JSON validator: https://jsonlint.com/
```

**Common JSON errors:**
- Missing commas between elements
- Trailing commas (not allowed in JSON)
- Unescaped quotes in strings
- Mismatched brackets `{}` or `[]`

#### Validation Checklist

```
Mission Metadata:
✓ Unique mission_id
✓ Title is engaging (2-5 words)
✓ Description is 2-3 sentences
✓ Difficulty matches complexity (1-5 stars)
✓ Type is valid (salvage/exploration/trade/rescue/combat/story)

Requirements:
✓ min_level appropriate for difficulty
✓ required_systems are truly required
✓ completed_missions exist

Objectives:
✓ Primary objective clear
✓ Optional objectives marked [OPTIONAL]
✓ Objectives achievable

Stages:
✓ All stage_ids unique
✓ All next_stage references exist
✓ No dead-end stages (except final)
✓ No circular stage loops
✓ 2-5 choices per stage

Choices:
✓ All choice_ids unique within mission
✓ Choice text is clear and actionable
✓ Skill requirements match available skills
✓ Success/failure outcomes written
✓ XP bonuses appropriate (15/25/40)

Rewards:
✓ XP within range for difficulty
✓ Credits within range for difficulty
✓ Part IDs validated against PartRegistry
✓ Rarity distribution logical
✓ Discovered parts include awarded parts
✓ Unlocks are valid mission/location IDs

Narrative:
✓ Tone matches Star Trek TNG (serious sci-fi)
✓ Choices are meaningful
✓ No obvious "right" choice
✓ Consequences make sense
✓ Story is coherent
```

#### In-Game Testing

**Test all paths:**

1. **Happy Path:** Perfect execution with all skill checks passed
2. **Failure Path:** Fail all skill checks
3. **Alternative Paths:** Each different choice combination
4. **Edge Cases:** Missing requirements, low skills, etc.

**Testing script:**

```
1. Load mission in-game
2. Play through mission
3. Note XP awarded
4. Note credits awarded
5. Note items received
6. Check unlocks triggered
7. Verify achievements unlocked (if any)
8. Check narrative coherence
9. Verify all choices lead somewhere
10. Confirm no dead ends or crashes
```

---

## Quality Standards

### Narrative Quality

**Star Trek TNG Tone:**
- Serious but hopeful sci-fi
- Ethical dilemmas (not black/white)
- Wonder of exploration
- Character-driven moments
- Consequences have weight

**Good Example:**

> "The distress signal is clear, but your sensors detect active weapon signatures. This could be a genuine emergency—or an elaborate trap. Either way, people might be dying while you deliberate."

**Bad Example:**

> "You see a ship. It might be bad guys. What do you do?"

### Choice Quality

**Meaningful Choices Checklist:**

```
✓ No "obviously wrong" trap choices
✓ Multiple valid approaches
✓ Choices reflect different playstyles (combat/diplomacy/stealth)
✓ Consequences are logical
✓ Player agency respected
✓ Choices matter to story progression
```

**Good Choice Set:**

1. "Hail the ship and offer assistance" (Diplomatic, risky)
2. "Approach cautiously with shields raised" (Defensive, safe)
3. "Scan thoroughly before committing" (Scientific, requires sensors)
4. "Ignore and continue on your course" (Pragmatic, guilt)

**Bad Choice Set:**

1. "Do the smart thing" ❌ (Vague, patronizing)
2. "Do the dumb thing" ❌ (Obvious trap)
3. "Do the thing" ❌ (Meaningless)

### Balance Quality

**Difficulty-Appropriate Rewards:**

```
Easy missions (★★): 100-150 XP, 200-400 credits, 1-2 common parts
Hard missions (★★★★): 200-300 XP, 400-800 credits, 2-3 parts (1-2 rare)
```

**XP Budget Check:**

```python
# Calculate maximum possible XP
base_xp = 150  # From rewards.xp
skill_check_bonuses = 25 + 25 + 40  # 3 skill checks
discovery_bonuses = 30  # 1 discovery
perfect_completion = 50  # If story mission

total_max_xp = base_xp + skill_check_bonuses + discovery_bonuses + perfect_completion
# = 295 XP

# Should be < 400 XP to prevent exploits
assert total_max_xp < 400
```

---

## Testing Procedures

### Pre-Submission Testing

**Required Tests:**

1. **JSON Validation:** No syntax errors
2. **Schema Validation:** Matches mission template structure
3. **Reward Validation:** XP/credits/parts within guidelines
4. **Part ID Validation:** All part IDs exist in PartRegistry
5. **Unlock Validation:** All unlocks reference valid missions/locations
6. **Playthrough Test:** Complete mission at least once
7. **Edge Case Test:** Test failure paths and skill requirements

### Testing Template

```markdown
# Mission Test Report

**Mission ID:** mission_salvage_spaceport_warp
**Tester:** [Your Name]
**Date:** 2025-11-07

## Test Results

### JSON Validation
- [ ] No syntax errors
- [ ] Schema matches template
- [ ] All fields present

### Reward Validation
- [ ] XP within range (150 for ★★)
- [ ] Credits within range (400 for ★★)
- [ ] Part IDs valid
- [ ] Rarity appropriate

### Playthrough Tests

**Test 1: Perfect Path**
- Choices: hack_gate → pick_lock → take_both → leave
- Result: ✅ Success
- XP Earned: 215 (150 base + 25 + 40)
- Credits: 400
- Parts: warp_coil_l1_common, datapad (quest item)
- Unlocks: mission_test_warp_drive

**Test 2: Failure Path**
- Choices: direct → force_door → just_coil → leave
- Result: ✅ Success (but suboptimal)
- XP Earned: 150 (base only)
- Credits: 400
- Parts: warp_coil_l1_common

**Test 3: Alternative Path**
- Choices: sneak → pick_lock → take_both → leave
- Result: ✅ Success
- XP Earned: 195 (150 base + 15 + 30)

### Issues Found
- None

### Recommended Changes
- None

### Final Verdict
- [x] APPROVED - Ready for submission
- [ ] NEEDS WORK - Issues must be fixed
```

---

## Best Practices

### Do's

✅ **Start with a template** - Don't write from scratch
✅ **Test every path** - Play through all choice combinations
✅ **Balance rewards carefully** - Use reward guidelines tables
✅ **Write engaging narrative** - Make players care about choices
✅ **Use skill checks sparingly** - 1-3 per mission maximum
✅ **Provide multiple solutions** - Combat, stealth, diplomacy, technical
✅ **Respect player agency** - No "trap" choices
✅ **Keep it concise** - 2-4 stages ideal
✅ **Match tone** - Star Trek TNG style
✅ **Validate part IDs** - Check against PartRegistry

### Don'ts

❌ **Don't over-reward** - Ruins progression balance
❌ **Don't under-reward** - Players feel cheated
❌ **Don't make trap choices** - No obvious wrong answers
❌ **Don't break narrative tone** - No memes or modern slang
❌ **Don't use invalid part IDs** - Will crash game
❌ **Don't create circular unlocks** - Mission A unlocks B unlocks A
❌ **Don't write 10-stage missions** - Too complex, too long
❌ **Don't skip testing** - You will miss bugs
❌ **Don't ignore feedback** - Playtest with others
❌ **Don't plagiarize** - Original content only

---

## Common Pitfalls

### Pitfall 1: Over-Complicated Stage Flow

**Problem:**

```
Stage 1 → 5 choices
  → Stage 2a → 4 choices → Stage 3a, 3b, 3c, 3d
  → Stage 2b → 3 choices → Stage 3e, 3f, 3g
  → Stage 2c → ...
[20+ possible paths]
```

**Solution:**

```
Stage 1 → 3 choices
  → Stage 2a (Stealth)
  → Stage 2b (Combat)
  → Stage 2c (Diplomacy)
All converge → Stage 3 (Resolution)
[3 main paths, manageable]
```

**Rule of thumb:** 3-5 total endings maximum

---

### Pitfall 2: Invalid Part IDs

**Problem:**

```json
{
  "items": [
    {"part_id": "warp_drive", "quantity": 1}  // ❌ Wrong format
  ]
}
```

**Solution:**

```json
{
  "items": [
    {"part_id": "warp_coil_l1_common", "quantity": 1}  // ✅ Correct
  ]
}
```

**Always use:** `{system}_{type}_l{level}_{rarity}`

---

### Pitfall 3: Unbalanced Skill Checks

**Problem:**

```json
{
  "requirements": {
    "skill": "engineering",
    "skill_level": 10  // ❌ Max skill for trivial action
  }
}
```

**Solution:**

```json
{
  "requirements": {
    "skill": "engineering",
    "skill_level": 3  // ✅ Appropriate for medium difficulty
  }
}
```

**Skill level guidelines:**
- Level 1-2: Easy checks
- Level 3-4: Medium checks
- Level 5-7: Hard checks
- Level 8-10: Very hard checks (rare)

---

### Pitfall 4: Missing Unlock Chain

**Problem:**

Mission unlocks `mission_sequel` but `mission_sequel` doesn't exist yet.

**Solution:**

Only reference missions that exist or are being created simultaneously.

**Validation:**

```bash
# Check all unlocks reference valid missions
grep -r "mission_sequel" godot/assets/data/missions/
# Should find mission_sequel.json
```

---

### Pitfall 5: Narrative Tone Break

**Problem:**

> "You arrive at the spaceport. It's giving abandoned vibes fr fr. No cap the drones are still active tho. What's your move, bestie?"

**Solution:**

> "The rusted gates of Kennedy Spaceport loom ahead. Collapsed towers and overgrown runways tell the story of rapid abandonment. Security drones still patrol in predictable patterns."

**Maintain:** Serious sci-fi, Star Trek TNG tone

---

## Resources & Templates

### Mission Templates

**Location:** `/godot/assets/data/mission_templates/`

**Available Templates:**

1. **salvage_template.json** - Basic salvage mission
   - 3 stages: Approach → Challenge → Retrieval
   - Common choice types: Stealth, combat, diplomacy
   - Part rewards

2. **exploration_template.json** - Discovery-focused
   - 4 stages: Discovery → Investigation → Choice → Outcome
   - Optional objectives
   - Discovery rewards

3. **trade_template.json** - Negotiation and economy
   - 3 stages: Meeting → Negotiation → Deal
   - Diplomacy skill checks
   - Credit rewards

4. **rescue_template.json** - Time-pressure scenarios
   - 3 stages: Distress → Rescue → Escape
   - Moral choices
   - Reputation rewards

5. **combat_template.json** - Tactical encounters
   - 3 stages: Engagement → Combat → Aftermath
   - Combat skill checks
   - Military parts

6. **story_template.json** - Narrative-driven
   - 4+ stages with branching
   - Character development
   - Major unlocks

### Reference Documents

**Essential:**
- [Mission Framework](./mission-framework.md)
- [Mission Reward Guidelines](./mission-reward-guidelines.md)
- [Player Progression System](../core-systems/player-progression-system.md)
- [Ship Systems](../ship-systems/ship-systems.md)

**Advanced:**
- [AI Mission Generation Prompts](../../05-ai-content/ai-mission-generation-prompts.md)
- [Achievement System](../../ACHIEVEMENTS.md)

### PartRegistry Reference

**Quick Reference Part IDs:**

```
Hull:
- hull_scrap_plates_l1_common
- hull_composite_armor_l1_uncommon
- hull_reinforced_bulkheads_l1_rare

Power:
- power_fusion_cell_l1_common
- power_plasma_reactor_l1_uncommon
- power_antimatter_core_l1_rare

Propulsion:
- propulsion_chemical_thruster_l1_common
- propulsion_ion_drive_l1_uncommon
- propulsion_plasma_engine_l1_rare

Warp:
- warp_coil_l1_common
- warp_nacelle_l1_uncommon
- warp_core_l1_rare

Life Support:
- life_support_air_recycler_l1_common
- life_support_hydroponic_bay_l1_uncommon
- life_support_bio_filter_l1_rare
```

**Full list:** See mission-reward-guidelines.md Section "PartRegistry Integration"

### Example Missions

**Study these examples:**

1. **Tutorial Mission:** `mission_tutorial.json`
   - Perfect example of progression mission
   - All rewards balanced
   - Multiple paths, meaningful choices

2. **First Salvage:** `mission_first_salvage.json`
   - Simple 3-stage structure
   - Basic skill checks
   - Common part rewards

3. **Story Mission:** `mission_the_rival.json`
   - Branching narrative
   - Character development
   - Major unlocks

---

## Getting Help

### Documentation Questions

- Check [Mission Framework](./mission-framework.md) first
- Review [Mission Reward Guidelines](./mission-reward-guidelines.md) for balancing
- Consult [Player Progression](../core-systems/player-progression-system.md) for XP/levels

### Technical Issues

- JSON syntax errors? Use [JSONLint](https://jsonlint.com/)
- Part ID validation? Check [PartRegistry](./mission-reward-guidelines.md#partregistry-integration)
- Testing problems? See [Testing Guide](../../01-user-guides/testing/TESTING-GUIDE.md)

### Content Review

- Submit missions for review via GitHub PR
- Request playtesting feedback from community
- Iterate based on feedback

---

## Conclusion

**You're now ready to create high-quality missions for Space Adventures!**

**Quick Start Checklist:**

```
✓ Read Mission Framework
✓ Read Mission Reward Guidelines
✓ Choose a template
✓ Write mission JSON
✓ Balance rewards
✓ Validate & test
✓ Submit for review
```

**Remember:**
- Start simple (2-3 stages)
- Test every path
- Balance rewards carefully
- Match Star Trek TNG tone
- Respect player agency
- Have fun creating!

**Happy mission creating! 🚀**

---

**Document Status:** Complete v1.0
**Last Updated:** November 7, 2025
**Related Documentation:**
- [Mission Framework](./mission-framework.md)
- [Mission Reward Guidelines](./mission-reward-guidelines.md)
- [AI Mission Generation Prompts](../../05-ai-content/ai-mission-generation-prompts.md)
- [Player Progression System](../core-systems/player-progression-system.md)
