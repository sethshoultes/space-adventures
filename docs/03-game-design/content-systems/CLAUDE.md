# content-systems - AI Agent Context

**Purpose:** Mission framework, crew management, and content creation resources.

## Key Files
- **mission-framework.md** - Mission JSON schema, 6 types, example missions, AI integration
- **mission-reward-guidelines.md** - Comprehensive reward balancing, PartRegistry, validation
- **CONTENT-CREATOR-GUIDE.md** - Complete mission creation workflow (start here for new missions)
- **crew-companion-system.md** - Crew mechanics and relationships

## When to Use
- Creating missions from scratch
- Designing balanced mission rewards
- Validating mission JSON
- Balancing progression and economy
- Understanding mission structure
- Implementing crew system
- Generating AI content
- Quality control for missions

## Mission Creation Workflow

**For Human/AI Content Creators:**

1. **Read First:**
   - CONTENT-CREATOR-GUIDE.md (complete workflow)
   - mission-reward-guidelines.md (reward balancing)

2. **Start Mission:**
   - Copy template from `/godot/assets/data/mission_templates/`
   - Follow step-by-step guide in CONTENT-CREATOR-GUIDE.md

3. **Balance Rewards:**
   - Use reward tables in mission-reward-guidelines.md
   - Validate part IDs against PartRegistry

4. **Test & Validate:**
   - Run through testing checklist
   - Playtest all paths
   - Verify JSON syntax

5. **Submit:**
   - Final review checklist
   - Submit for integration

## Key Concepts

### Mission Structure
**JSON with:**
- Metadata (id, title, type, difficulty)
- Requirements (level, systems, completed missions)
- Stages with choices and consequences
- Rewards (XP, credits, items, unlocks)

**Types:** Salvage, Exploration, Trade, Rescue, Combat, Story

### Reward Scaling

| Difficulty | Stars | Base XP | Credits | Parts |
|------------|-------|---------|---------|-------|
| Tutorial | ★ | 100-150 | 300-500 | 2-3 common |
| Easy | ★★ | 100-150 | 200-400 | 1-2 (mostly common) |
| Medium | ★★★ | 150-200 | 300-600 | 1-2 (1 rare) |
| Hard | ★★★★ | 200-300 | 400-800 | 2-3 (1-2 rare) |
| Very Hard | ★★★★★ | 300-400 | 500-1000 | 2-3 (2-3 rare) |

### Choice Bonuses
- **Skill check success:** +25 XP (standard), +40 XP (high-level skill 5+)
- **Discovery:** +15-50 XP based on importance
- **Perfect completion:** +50-100 XP (story missions)

### PartRegistry Integration

**Part ID Format:** `{system}_{type}_l{level}_{rarity}`

**Examples:**
- `hull_scrap_plates_l1_common`
- `power_fusion_cell_l1_common`
- `warp_coil_l1_common`

**Award vs Discovery:**
- **items:** Physical parts added to inventory
- **discovered_parts:** Unlocks parts in PartRegistry catalog

### Achievement Integration

**Missions trigger achievements:**
- `first_mission` - Complete 1 mission
- `five_missions` - Complete 5 missions
- `ten_missions` - Complete 10 missions
- `ten_successful_checks` - Pass 10 skill checks
- `ten_parts` - Discover 10 parts
- `twenty_parts` - Discover 20 parts

**See:** [ACHIEVEMENTS.md](../../ACHIEVEMENTS.md)

## Quality Standards

**Star Trek TNG Tone:**
- Serious but hopeful sci-fi
- Ethical dilemmas (not black/white)
- Wonder of exploration
- Character-driven moments
- Consequences have weight

**Validation Checklist:**
```
✓ XP matches difficulty tier
✓ Credits appropriate for mission type
✓ All part_ids validated against PartRegistry
✓ Rarity distribution logical
✓ Skill bonuses assigned correctly (15/25/40 XP)
✓ Discovery rewards justified
✓ Unlocks narratively coherent
✓ Mission completable with available systems
✓ All paths tested
```

## Quick Reference Links

**For Mission Creation:**
- [Content Creator Guide](./CONTENT-CREATOR-GUIDE.md) - Start here
- [Mission Reward Guidelines](./mission-reward-guidelines.md) - Balancing reference
- [Mission Framework](./mission-framework.md) - Schema and structure
- [Mission Templates](../../../godot/assets/data/mission_templates/) - Pre-built templates

**For AI Integration:**
- [AI Mission Generation Prompts](../../05-ai-content/ai-mission-generation-prompts.md)
- [AI Integration](../../05-ai-content/ai-integration.md)

**For Progression:**
- [Player Progression System](../core-systems/player-progression-system.md)
- [Achievement System](../../ACHIEVEMENTS.md)
- [Ship Systems](../ship-systems/ship-systems.md)

---

**Parent:** [../CLAUDE.md](../CLAUDE.md)
**Last Updated:** 2025-11-07
