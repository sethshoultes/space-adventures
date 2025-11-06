# 03-game-design - AI Agent Context

**Purpose:** Game design specifications, mechanics, and systems documentation.

## Directory Contents

### Subdirectories
- **core-systems/** - Fundamental mechanics and progression
- **ship-systems/** - 10 ship systems and classification
- **content-systems/** - Missions and crew management

### Key Files by Subdirectory

**core-systems/**
- game-design-document.md - Core game loop and vision
- player-progression-system.md - XP, levels, ranks, skills
- resources-survival.md - Resource mechanics

**ship-systems/**
- ship-systems.md - 10 core systems with levels 0-5
- ship-classification-system.md - 10 ship classes
- ship-documentation.md - Complete specifications

**content-systems/**
- mission-framework.md - Mission structure and JSON schema
- crew-companion-system.md - Crew management mechanics

## When to Use This Directory

**Use when:**
- Implementing game mechanics
- Creating missions or content
- Balancing systems
- Understanding game flow
- Designing features
- Writing game code

## Common Tasks

### Task: Implement ship system
1. Read ship-systems/ship-systems.md for specific system
2. Understand level progression (0-5)
3. Note power consumption formula
4. Review dependencies on other systems
5. Implement in Godot
6. Test all levels

### Task: Create new mission
1. Read content-systems/mission-framework.md
2. Choose mission type (salvage, exploration, etc.)
3. Follow JSON schema
4. Design meaningful choices
5. Balance rewards
6. Test all paths

### Task: Balance progression
1. Review core-systems/player-progression-system.md
2. Check XP curve and level requirements
3. Test progression feels good
4. Adjust if needed
5. Update documentation

## Relationships

**Defines:**
- All game mechanics and rules
- Content structure
- Progression systems
- Ship capabilities

**Informs:**
- Implementation in `../02-developer-guides/`
- AI content generation in `../05-ai-content/`
- UI design in `../04-ui-graphics/`
- Testing procedures in `../01-user-guides/`

## Key Concepts

### Two-Phase Structure
**Phase 1: Earthbound** (MVP)
- Scavenge Earth for ship parts
- Build systems Level 0 → 1+
- Workshop hub
- 15+ missions
- Unlock warp travel

**Phase 2: Space Exploration** (Post-MVP)
- Leave Earth
- Explore galaxy
- Random encounters
- Advanced systems (Level 2-5)
- Endgame content

**Transition Requirement:** All 10 systems at Level 1 minimum

### 10 Ship Systems

Each system has:
- **Levels:** 0 (broken) → 5 (maximum)
- **Power Cost:** Increases per level
- **Mechanics:** Unique gameplay effects
- **Dependencies:** Some require others

**Critical Systems:**
- Power Core: Generates power for all systems
- Life Support: Crew survival and capacity
- Warp Drive: Required for space travel

### Ship Classification

Ship class determined by system configuration:
- Scout: Minimal systems, high propulsion
- Frigate: Balanced combat
- Science Vessel: High sensors and computer
- Cruiser: Well-rounded
- Dreadnought: Maximum combat capability

Players work toward specific class bonuses.

### Mission System

**Structure:**
```json
{
  "mission_id": "unique_id",
  "type": "salvage|exploration|trade|rescue|combat|story",
  "stages": [
    {
      "choices": [
        {
          "requirements": {"skill": "engineering", "level": 3},
          "consequences": {"success": {...}, "failure": {...}}
        }
      ]
    }
  ],
  "rewards": {"xp": 100, "items": [...]}
}
```

### Player Progression

**Levels:** 1 (Cadet) → 10 (Admiral)
**XP Curve:** Exponential (100 → 25,600 for max level)
**Skills:** Engineering, Diplomacy, Combat, Science
**Ranks:** Earned at specific levels with bonuses

## AI Agent Instructions

**When implementing mechanics:**
1. Read design doc first - don't guess
2. Follow formulas exactly as specified
3. Test edge cases (Level 0, Level 5, no power, etc.)
4. Balance is critical - don't improvise
5. Update design docs if changes needed

**When creating content:**
1. Follow mission-framework.md JSON schema
2. Maintain Star Trek TNG tone
3. Provide meaningful choices (not obvious "right" answer)
4. Balance rewards with difficulty
5. Test all choice paths

**When balancing:**
1. Use spreadsheets to model formulas
2. Test full progression (Level 1 → 10)
3. Check power budget at different stages
4. Ensure systems feel impactful
5. Document rationale for changes

## Design Principles

**60/40 Content Rule:**
- 60% scripted, high-quality missions
- 40% AI-generated for variety
- Never sacrifice quality for quantity

**Meaningful Choices:**
- No "trap" choices
- Multiple valid approaches
- Consequences matter
- Player agency respected

**Progressive Unlock:**
- Systems unlock gradually
- Each upgrade feels meaningful
- Clear goals at each stage
- Satisfying progression curve

**Star Trek TNG Tone:**
- Serious but hopeful sci-fi
- Ethical dilemmas (not black/white)
- Wonder of exploration
- Character-driven moments
- Consequences have weight

## Quick Reference

**Phase 1 Requirements:**
- All 10 systems implemented (Level 0-1 minimum)
- 15+ missions
- Workshop UI
- Save/load system
- Progression tracking

**Ship System Power Budget:**
- Level 0: 0 power
- Level 1: 10-20 power each
- Total at Level 1: ~150 power needed
- Power Core Level 1: Generates 150 power

**Mission Rewards:**
- Easy (1-2): 50-100 XP
- Medium (3-4): 100-200 XP
- Hard (5): 200-300 XP

**Skill Checks:**
- Level 0-2: Novice
- Level 3-5: Competent
- Level 6-8: Expert
- Level 9-10: Master

---

**Parent Context:** [../CLAUDE.md](../CLAUDE.md)
**Directory Index:** [README.md](./README.md)
