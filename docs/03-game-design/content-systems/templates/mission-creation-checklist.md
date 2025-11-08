# Mission Creation Checklist

**Purpose:** Step-by-step guide for creating high-quality missions for Space Adventures
**Audience:** Content creators, mission designers, AI content generators
**Related:** [Mission Framework](../mission-framework.md), [Mission Reward Guidelines](../mission-reward-guidelines.md)

---

## Phase 1: Design

### Mission Concept
- [ ] **Mission type selected** (salvage, exploration, trade, rescue, combat, story)
- [ ] **Core concept defined** (one sentence: "Player does X to achieve Y")
- [ ] **Target difficulty determined** (1-5 stars based on player level and skills)
- [ ] **Primary objective clear** (what must be accomplished)
- [ ] **Optional objectives identified** (2-3 bonus goals)

### Narrative Design
- [ ] **Location chosen** (specific, evocative, fits world lore)
- [ ] **Mission title created** (evocative, mysterious, no spoilers)
- [ ] **Description written** (2-3 sentences, sets up situation)
- [ ] **Tone matches game** (serious sci-fi, Star Trek TNG inspiration)
- [ ] **Stakes established** (why does this matter?)

### Player Choice Design
- [ ] **3-5 meaningful choices per stage** (no filler options)
- [ ] **Multiple valid approaches** (no single "correct" path)
- [ ] **Skill checks justify rewards** (harder checks = better rewards)
- [ ] **Failure states considered** (what happens if checks fail?)
- [ ] **Moral choices have weight** (consequences, not just flavor)

### Stage Structure
- [ ] **Approach stage designed** (how player enters situation)
- [ ] **Challenge stages planned** (2-3 core decision points)
- [ ] **Resolution stage created** (climax, final choice)
- [ ] **Escape/aftermath considered** (optional complication)
- [ ] **Total playtime estimated** (5-15 minutes target)

---

## Phase 2: Implementation

### Mission Metadata
- [ ] **Unique mission_id assigned** (lowercase_with_underscores)
- [ ] **Title, type, location set**
- [ ] **Difficulty rating assigned** (1-5)
- [ ] **Requirements defined:**
  - [ ] Minimum player level
  - [ ] Required ship systems (if any)
  - [ ] Prerequisite missions (if any)

### Stage Implementation
**For each stage:**
- [ ] **Unique stage_id assigned**
- [ ] **Title and description written**
- [ ] **Image reference specified**
- [ ] **Choices implemented:**
  - [ ] Unique choice_id per choice
  - [ ] Clear action-oriented text
  - [ ] Requirements specified (if any)
  - [ ] Success chance set (100, percentage, or skill_based)
  - [ ] Consequences defined:
    - [ ] Success outcome written
    - [ ] Failure outcome written (if applicable)
    - [ ] next_stage connections correct
    - [ ] Effects flags assigned
    - [ ] XP bonuses set

### Choice Quality Checks
**For each choice:**
- [ ] **Text is clear and actionable** (player knows what they're choosing)
- [ ] **Requirements are fair** (skill checks match difficulty)
- [ ] **Consequences are meaningful** (choice matters)
- [ ] **Failure is interesting** (not just "try again")
- [ ] **All paths lead somewhere** (no dead ends)

### Flow Validation
- [ ] **All stage_ids unique** within mission
- [ ] **All choice_ids unique** within stage
- [ ] **All next_stage references valid** (stage exists)
- [ ] **Mission has completion path** (reaches mission_result: success)
- [ ] **Mission has failure path** (optional but recommended)
- [ ] **No orphaned stages** (all stages reachable from start)
- [ ] **No infinite loops** (stages don't cycle endlessly)

### Conditional Logic
- [ ] **Effects flags documented** (what each flag means)
- [ ] **Conditional text uses valid flags** (if_effect_name format)
- [ ] **Conditional rewards use valid flags**
- [ ] **Conditional requirements work** (requires_effect logic)

---

## Phase 3: Rewards & Balance

### Base Rewards
- [ ] **XP matches difficulty tier:**
  - [ ] Difficulty 1 (Tutorial): 100-150 XP
  - [ ] Difficulty 2 (Easy): 100-150 XP
  - [ ] Difficulty 3 (Medium): 150-200 XP
  - [ ] Difficulty 4 (Hard): 200-300 XP
  - [ ] Difficulty 5 (Very Hard): 300-400 XP

- [ ] **Credits match difficulty tier:**
  - [ ] Difficulty 1: 300-500 credits
  - [ ] Difficulty 2: 200-400 credits
  - [ ] Difficulty 3: 300-600 credits
  - [ ] Difficulty 4: 400-800 credits
  - [ ] Difficulty 5: 500-1000 credits

- [ ] **Parts awarded (items):**
  - [ ] 1-3 parts total (don't overwhelm inventory)
  - [ ] Part IDs validated against PartRegistry
  - [ ] Rarity matches difficulty (common for easy, rare for hard)
  - [ ] Quantity specified (positive integers)

- [ ] **Parts discovered:**
  - [ ] 2-5 parts unlocked for future use
  - [ ] Includes parts awarded in items
  - [ ] Logical progression (don't unlock all at once)

- [ ] **Mission unlocks:**
  - [ ] 1-3 follow-up missions unlocked
  - [ ] Unlocks are narratively logical
  - [ ] Creates progression chains

### Choice Bonuses
**For each skill check:**
- [ ] **Skill level 1-2:** +15-20 XP
- [ ] **Skill level 3-4:** +25-30 XP
- [ ] **Skill level 5+:** +35-40 XP

**For discoveries:**
- [ ] **Minor discovery:** +15 XP
- [ ] **Moderate discovery:** +25-30 XP
- [ ] **Major discovery:** +50 XP

**For perfect completion:**
- [ ] **All objectives:** +50 XP
- [ ] **Exceptional outcome:** +100 XP (story missions only)

### Conditional Rewards
- [ ] **Conditional rewards defined** (based on effects flags)
- [ ] **Rewards match achievement** (better play = better rewards)
- [ ] **Total possible XP calculated** (base + all bonuses)
- [ ] **Maximum XP reasonable** (< 400 XP prevents exploits)

### Failure Rewards
- [ ] **Failure XP set** (25-50 XP for learning)
- [ ] **Failure effects logged** (for story continuity)

---

## Phase 4: Testing

### JSON Validation
- [ ] **JSON is valid** (no syntax errors)
- [ ] **All required fields present:**
  - [ ] mission_id, title, type, location, description
  - [ ] difficulty, requirements, objectives
  - [ ] stages array (at least 1 stage)
  - [ ] rewards object

- [ ] **Part IDs validated:**
  - [ ] All part_id values exist in PartRegistry
  - [ ] Format: {system}_{type}_l{level}_{rarity}
  - [ ] Examples: hull_scrap_plates_l1_common

### Playthrough Testing
- [ ] **Full playthrough (success path):**
  - [ ] Mission starts correctly
  - [ ] Choices display properly
  - [ ] Stage transitions work
  - [ ] Mission completes successfully
  - [ ] Rewards granted correctly

- [ ] **Failure path tested:**
  - [ ] Failure is possible (if intended)
  - [ ] Failure is interesting (story continues)
  - [ ] Failure rewards granted

- [ ] **Skill check testing:**
  - [ ] Success works (player has skill)
  - [ ] Failure works (player lacks skill)
  - [ ] Bonuses calculated correctly

- [ ] **Alternative paths tested:**
  - [ ] All major choices lead somewhere
  - [ ] Different paths provide variety
  - [ ] Conditional content appears correctly

### Balance Testing
- [ ] **Time to complete:** 5-15 minutes (average player)
- [ ] **Difficulty feels fair** (matches star rating)
- [ ] **Rewards feel satisfying** (worth the time)
- [ ] **Skill checks accessible** (not too easy or impossible)
- [ ] **Choices feel meaningful** (not obvious "right" answer)

### Narrative Testing
- [ ] **Story makes sense** (no plot holes)
- [ ] **Characters behave consistently**
- [ ] **Tone matches game** (serious, hopeful sci-fi)
- [ ] **No lore contradictions** (check existing missions)
- [ ] **Dialogue sounds natural**

---

## Phase 5: Polish

### Writing Quality
- [ ] **Grammar and spelling checked**
- [ ] **Descriptions evocative** (paint a picture)
- [ ] **Dialogue natural** (people talk like this)
- [ ] **Pacing good** (not too slow or rushed)
- [ ] **Show don't tell** (player experiences, not lectures)

### Player Experience
- [ ] **Objectives clear** (player knows what to do)
- [ ] **Choices understandable** (no confusion)
- [ ] **Consequences logical** (outcomes make sense)
- [ ] **Feedback provided** (player knows results)
- [ ] **Endings satisfying** (closure, not abrupt)

### Technical Polish
- [ ] **Comments removed** (or marked clearly as _comment fields)
- [ ] **Formatting consistent** (proper indentation)
- [ ] **IDs follow conventions** (lowercase_with_underscores)
- [ ] **File named correctly** (mission_{id}.json)

---

## Common Pitfalls to Avoid

### Design Pitfalls
- ❌ **Linear missions** (only one path)
- ❌ **Obvious "correct" choices** (one choice clearly best)
- ❌ **Meaningless choices** (no real consequence)
- ❌ **Too many skill checks** (gates too much content)
- ❌ **Too few choices** (< 2 choices per stage)
- ❌ **Unclear objectives** (player doesn't know what to do)

### Implementation Pitfalls
- ❌ **Missing next_stage** (orphaned choices)
- ❌ **Invalid stage_id references** (typos)
- ❌ **Duplicate IDs** (mission_id, stage_id, choice_id)
- ❌ **JSON syntax errors** (missing commas, brackets)
- ❌ **Invalid part_id** (not in PartRegistry)

### Reward Pitfalls
- ❌ **Over-rewarding easy content** (difficulty 1 gives 500 XP)
- ❌ **Under-rewarding hard content** (difficulty 5 gives 100 XP)
- ❌ **Inconsistent difficulty scaling**
- ❌ **Too many parts** (inventory overflow)
- ❌ **No conditional rewards** (perfect play = same as lazy play)

### Writing Pitfalls
- ❌ **Info dumps** (walls of text)
- ❌ **Boring descriptions** ("You see a room")
- ❌ **Stilted dialogue** (nobody talks like this)
- ❌ **Lore contradictions** (doesn't match other missions)
- ❌ **Wrong tone** (too silly, too grimdark)

---

## Quality Assurance Scorecard

Rate each category 1-10. **Target: 8+ average.**

### Design (40%)
- [ ] **Concept:** Is the core idea interesting? ___/10
- [ ] **Choices:** Are choices meaningful and varied? ___/10
- [ ] **Structure:** Does the flow make sense? ___/10
- [ ] **Stakes:** Does the player care about the outcome? ___/10

### Implementation (30%)
- [ ] **Technical:** All IDs valid, JSON correct? ___/10
- [ ] **Flow:** All paths work, no dead ends? ___/10
- [ ] **Requirements:** Skill checks fair and balanced? ___/10

### Rewards (20%)
- [ ] **Balance:** XP and credits match difficulty? ___/10
- [ ] **Parts:** Valid IDs, appropriate rarity? ___/10
- [ ] **Progression:** Unlocks make narrative sense? ___/10

### Writing (10%)
- [ ] **Quality:** Grammar, spelling, clarity? ___/10
- [ ] **Tone:** Matches game (Star Trek TNG vibe)? ___/10

**Total Score:** ___/120 → ___% → **Pass: 80%+**

---

## Final Checklist

Before submitting mission:

- [ ] **Playtested fully** (all paths work)
- [ ] **Balanced correctly** (rewards match difficulty)
- [ ] **Narratively sound** (fits world, no contradictions)
- [ ] **Technically valid** (JSON perfect, IDs correct)
- [ ] **QA score 80%+** (meets quality threshold)
- [ ] **Fun to play** (most important!)

---

## Next Steps

**Mission approved?**
1. Add to mission database: `godot/assets/data/missions/`
2. Update mission index documentation
3. Test integration in game
4. Celebrate! You made content.

**Mission needs work?**
1. Review failed checklist items
2. Revise and retest
3. Run through checklist again
4. Iterate until quality meets threshold

---

**Remember:** Great missions take time. Iterate, test, polish. Players will remember your missions—make them worth remembering.

---

**Document Version:** 1.0
**Last Updated:** November 7, 2025
**Related Documents:**
- [Mission Framework](../mission-framework.md) - JSON schema and structure
- [Mission Reward Guidelines](../mission-reward-guidelines.md) - Balancing rewards
- [Mission Templates](./README.md) - Example templates and full missions
