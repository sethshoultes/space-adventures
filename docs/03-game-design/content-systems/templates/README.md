# Mission Templates and Examples

**Purpose:** Ready-to-use templates and fully-worked examples for mission creation
**Audience:** Content creators, mission designers, AI content generators
**Status:** Complete v1.0

---

## Quick Start

**Creating your first mission?**

1. **Read:** [mission-creation-checklist.md](./mission-creation-checklist.md) (15 minutes)
2. **Choose a template:**
   - Salvage: [mission-template-salvage.json](./mission-template-salvage.json)
   - Exploration: [mission-template-exploration.json](./mission-template-exploration.json)
   - Story: [mission-template-story.json](./mission-template-story.json)
3. **Study an example:**
   - Easy salvage: [example-missions/easy-salvage-example.json](./example-missions/easy-salvage-example.json)
   - Medium exploration: [example-missions/medium-exploration-example.json](./example-missions/medium-exploration-example.json)
4. **Copy, customize, test**

---

## Directory Contents

### Templates (Starting Points)

**[mission-template-salvage.json](./mission-template-salvage.json)**
- Difficulty 2 salvage mission template
- Fully commented with design explanations
- Demonstrates: 3-stage structure, skill checks (Engineering 2-4), risk/reward choices
- Use for: Retrieving ship parts, raiding locations, competing with scavengers

**[mission-template-exploration.json](./mission-template-exploration.json)**
- Difficulty 3 exploration mission template
- Science-focused with ethical choices
- Demonstrates: Discovery mechanics, Science 2-4 checks, moral dilemmas
- Use for: Investigating mysteries, scientific discoveries, lore revelations

**[mission-template-story.json](./mission-template-story.json)**
- Difficulty 2 story mission template
- Character-driven with branching paths
- Demonstrates: Relationship building, Diplomacy 1-3, narrative consequences
- Use for: Character introductions, major story beats, faction relationships

### Complete Examples (Reference Implementations)

**[example-missions/easy-salvage-example.json](./example-missions/easy-salvage-example.json)**
- **Mission:** "Ghosts of Commerce" - Trading post salvage
- **Difficulty:** 2 (Easy)
- **Playtime:** 10-12 minutes
- **Features:**
  - 6 stages with multiple paths
  - Engineering 2-3, Diplomacy 2, Science 3 skill checks
  - Risk/reward decisions (force vs bypass locks)
  - Optional discovery content (trader's cache)
  - Conditional rewards based on player choices
  - Perfect play: 315 XP total

**[example-missions/medium-exploration-example.json](./example-missions/medium-exploration-example.json)**
- **Mission:** "The Quantum Echo" - Quantum research lab investigation
- **Difficulty:** 3 (Medium)
- **Playtime:** 12-18 minutes
- **Features:**
  - 8 stages with ethical choices
  - Science 3-5, Engineering 3-4, Diplomacy 2 skill checks
  - Multiple information-gathering approaches
  - Moral dilemma with no "correct" answer
  - Failure is possible and meaningful
  - Perfect outcome requires Science 5 mastery
  - Perfect play: 415 XP total

### Workflow Guide

**[mission-creation-checklist.md](./mission-creation-checklist.md)**
- Complete step-by-step mission creation guide
- 5 phases: Design, Implementation, Rewards, Testing, Polish
- Common pitfalls and how to avoid them
- Quality assurance scorecard
- Pre-submission final checklist

---

## Template Usage Guide

### How to Use Templates

1. **Copy the template file** to your working directory
2. **Replace all placeholder content:**
   - mission_id: Your unique ID
   - title, description, location: Your mission concept
   - Stages and choices: Your narrative and mechanics
   - Rewards: Balanced for your difficulty
3. **Remove or keep _comment fields:**
   - Game ignores fields starting with `_`
   - Keep comments during development
   - Remove before final submission for cleaner JSON
4. **Validate:**
   - Check JSON syntax
   - Validate all part_ids against PartRegistry
   - Test all stage transitions

### Template Features Explained

**Every template includes:**
- ✅ **Metadata section** - mission_id, title, type, difficulty, requirements
- ✅ **Stage structure** - approach, challenge, resolution pattern
- ✅ **Choice examples** - skill checks, risk/reward, moral choices
- ✅ **Reward balancing** - base + conditional rewards
- ✅ **Inline comments** - explaining design decisions
- ✅ **Design notes** - philosophy and best practices

---

## Mission Type Guide

### Salvage Missions

**Focus:** Retrieving ship parts from locations
**Template:** [mission-template-salvage.json](./mission-template-salvage.json)
**Example:** [example-missions/easy-salvage-example.json](./example-missions/easy-salvage-example.json)

**Typical Structure:**
1. **Approach** - How to enter (direct, cautious, skilled)
2. **Navigate** - Deal with obstacles (security, hazards, rivals)
3. **Retrieve** - Get the parts (force, bypass, negotiate)
4. **Escape** - Leave safely (or not)

**Key Skills:** Engineering (bypassing locks, hacking), Diplomacy (negotiating with rivals)

**Rewards:** Ship parts (guaranteed), credits (moderate), XP (100-200 base)

---

### Exploration Missions

**Focus:** Investigating mysteries and discovering knowledge
**Template:** [mission-template-exploration.json](./mission-template-exploration.json)
**Example:** [example-missions/medium-exploration-example.json](./example-missions/medium-exploration-example.json)

**Typical Structure:**
1. **Investigation** - Gather information (scan, ask, explore)
2. **Discovery** - Uncover the mystery (analyze, deduce)
3. **Decision** - What to do with knowledge (moral choice)

**Key Skills:** Science (scanning, analysis, understanding), Engineering (data recovery)

**Rewards:** Rare parts (conditional), discovered_parts (many), knowledge unlocks, XP (150-250 base)

---

### Story Missions

**Focus:** Character development and narrative progression
**Template:** [mission-template-story.json](./mission-template-story.json)

**Typical Structure:**
1. **Character Introduction** - Meet NPC or witness event
2. **Proposition** - NPC offers alliance, rivalry, or choice
3. **Branching Paths** - Player choice determines future relationship

**Key Skills:** Diplomacy (negotiation, persuasion), often low requirements (1-3) for accessibility

**Rewards:** Mission unlocks (major), relationship changes, discovered_parts, moderate XP (100-150 base)

---

## Reward Balancing Quick Reference

### XP by Difficulty

| Difficulty | Stars | Base XP | With Bonuses |
|------------|-------|---------|--------------|
| Tutorial | ★☆☆☆☆ | 100-150 | 175-250 |
| Easy | ★★☆☆☆ | 100-150 | 175-245 |
| Medium | ★★★☆☆ | 150-200 | 225-315 |
| Hard | ★★★★☆ | 200-300 | 300-425 |
| Very Hard | ★★★★★ | 300-400 | 400-550 |

### Skill Check Bonuses

- **Skill level 1-2:** +15-20 XP (accessible)
- **Skill level 3-4:** +25-30 XP (standard)
- **Skill level 5+:** +35-40 XP (mastery)

### Discovery Bonuses

- **Minor:** +15 XP (flavor text, small lore)
- **Moderate:** +25-30 XP (useful information, secret area)
- **Major:** +50 XP (breakthrough, story revelation)

### Perfect Completion

- **All objectives:** +50 XP (standard)
- **Exceptional outcome:** +100 XP (story missions, rare)

---

## Part ID Reference

**Format:** `{system}_{type}_l{level}_{rarity}`

**Valid Systems:**
- hull, power, propulsion, warp, life_support
- computer, sensors, shields, weapons, communications

**Valid Rarities:**
- common, uncommon, rare

**Valid Levels:**
- l1, l2, l3 (Milestone 1 cap at Level 3)
- l4, l5 (future content)

**Examples:**
```json
"items": [
  {"part_id": "hull_scrap_plates_l1_common", "quantity": 1},
  {"part_id": "power_fusion_cell_l1_common", "quantity": 1},
  {"part_id": "propulsion_ion_drive_l1_uncommon", "quantity": 1}
]
```

**Validation:** All part_ids MUST exist in PartRegistry
**See:** `/godot/assets/data/parts/*.json` for complete part lists

---

## Common Mistakes and Solutions

### ❌ Mistake: Invalid part_id
```json
"items": [{"part_id": "hull_armor_plate", "quantity": 1}]
```
**Problem:** Missing level and rarity
**✅ Fix:**
```json
"items": [{"part_id": "hull_scrap_plates_l1_common", "quantity": 1}]
```

---

### ❌ Mistake: Over-rewarding easy missions
```json
{
  "difficulty": 1,
  "rewards": {"xp": 500, "credits": 2000}
}
```
**Problem:** Tutorial mission gives enough XP to skip 3 levels
**✅ Fix:**
```json
{
  "difficulty": 1,
  "rewards": {"xp": 100, "credits": 300}
}
```

---

### ❌ Mistake: Missing next_stage
```json
{
  "choice_id": "enter_lab",
  "consequences": {
    "success": {
      "text": "You enter the lab..."
      // Missing next_stage!
    }
  }
}
```
**Problem:** Choice leads nowhere, mission breaks
**✅ Fix:**
```json
{
  "choice_id": "enter_lab",
  "consequences": {
    "success": {
      "text": "You enter the lab...",
      "next_stage": "lab_interior"
    }
  }
}
```

---

### ❌ Mistake: Orphaned stage
```json
{
  "stages": [
    {"stage_id": "start", "choices": [{"next_stage": "middle"}]},
    {"stage_id": "middle", "choices": [{"next_stage": "end"}]},
    {"stage_id": "secret", "choices": []} // Never reached!
  ]
}
```
**Problem:** "secret" stage is unreachable
**✅ Fix:** Add a choice in "middle" or "start" that leads to "secret"

---

## Testing Checklist

**Before submitting your mission:**

- [ ] **JSON valid** (no syntax errors)
- [ ] **All part_ids validated** (exist in PartRegistry)
- [ ] **All next_stage references valid** (stage exists)
- [ ] **Mission completable** (at least one success path)
- [ ] **All paths tested** (playthrough each choice branch)
- [ ] **Rewards balanced** (match difficulty tier)
- [ ] **Skill checks fair** (not too easy or impossible)
- [ ] **Choices meaningful** (different outcomes)
- [ ] **Writing quality** (grammar, spelling, tone)
- [ ] **Playtime acceptable** (5-15 minutes)

---

## Related Documentation

**Mission Design:**
- [Mission Framework](../mission-framework.md) - JSON schema and structure
- [Mission Reward Guidelines](../mission-reward-guidelines.md) - Comprehensive balancing guide
- [Content Creator Guide](../CONTENT-CREATOR-GUIDE.md) - Complete workflow

**Game Systems:**
- [Player Progression System](../../core-systems/player-progression-system.md) - XP and leveling
- [Ship Systems](../../ship-systems/ship-systems.md) - Ship system requirements
- [Economy Implementation](../../../02-developer-guides/systems/ECONOMY-IMPLEMENTATION-CHECKLIST.md) - Part costs

**AI Integration:**
- [AI Integration](../../../05-ai-content/ai-integration.md) - AI-generated missions
- [AI Mission Generation Prompts](../../../05-ai-content/ai-mission-generation-prompts.md) - Templates for AI

---

## Support and Questions

**For mission creation help:**
1. Review [mission-creation-checklist.md](./mission-creation-checklist.md)
2. Study example missions in `example-missions/`
3. Reference [Mission Reward Guidelines](../mission-reward-guidelines.md)
4. Check [Mission Framework](../mission-framework.md) for schema details

**For AI-generated missions:**
- Use templates as starting points
- Validate all generated part_ids
- Test all paths thoroughly
- Apply quality standards rigorously

---

**Document Version:** 1.0
**Last Updated:** November 7, 2025
**Status:** Complete

**Contributing:** All mission templates are examples. Customize freely. Follow quality standards. Test thoroughly. Have fun creating content!
