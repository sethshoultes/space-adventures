# Development Roadmap

> **This is a hobby/learning project.** Milestones are flexible goals, not deadlines. Build when motivated, pause when needed, pivot if not fun.

**Current Milestone:** Milestone 1 - Proof of Concept
**Status:** 90% Complete (Economy, mission system, UI all working - testing phase)
**Next Checkpoint:** Full game playthrough testing → Milestone 1 complete!

---

## 🎯 Current Focus: Milestone 1 - Proof of Concept

**Goal:** Build the minimum game loop to validate the concept is fun.

**Success Criteria:**
- ✅ Can play for 15 minutes
- ✅ The core loop feels interesting
- ✅ Want to continue building

**If not fun after Milestone 1: Pivot or abandon. That's OK for a learning project.**

---

### Implementation Checklist

**AI Agent: Work through these in order, checking off as you complete them.**

#### ✅ Foundation (Complete)
- [x] Docker Compose stack (Gateway, AI Service, Redis)
- [x] NCC-1701 port system (17010-17099)
- [x] Godot project structure
- [x] 5 autoload singletons (ServiceManager, GameState, SaveManager, EventBus, AIService)
- [x] Test scene with UI
- [x] Documentation organization
- [x] AI-agent workflow setup

---

#### ✅ Ship Systems Implementation (Complete)

**All 3 core systems implemented with Level 0-5 support + economy integration**

##### Hull System ✅
- [x] Created `godot/scripts/systems/hull_system.gd`
- [x] Base ShipSystem class created
- [x] Full Level 0-5 implementation (0-500 HP)
- [x] Upgrade system with credit + part consumption
- [x] Damage and repair mechanics
- [x] GameState integration
- [x] EventBus signal emission
- [x] Save/load persistence

##### Power Core System ✅
- [x] Created `godot/scripts/systems/power_system.gd`
- [x] Full Level 0-5 implementation (0-1000 PU)
- [x] Upgrade system with economy integration
- [x] Power output calculation
- [x] GameState ship power tracking
- [x] Save/load persistence

##### Propulsion System ✅
- [x] Created `godot/scripts/systems/propulsion_system.gd`
- [x] Full Level 0-5 implementation (0x-12x speed)
- [x] Upgrade system with economy integration
- [x] Speed and maneuverability stats
- [x] Save/load persistence

---

#### ✅ Hybrid Economy System (Complete)

**Two-currency model with story-driven part unlocks**

##### Data Infrastructure ✅
- [x] PartRegistry singleton (720+ lines, 30+ API methods)
- [x] 39 parts defined (5 systems × 3 rarity tiers)
- [x] JSON data files (parts, systems, economy config)
- [x] O(1) lookup performance with dictionaries

##### GameState Integration ✅
- [x] Credits system (add, spend, validation)
- [x] Skill points allocation system
- [x] Enhanced inventory (stacking, weight, capacity)
- [x] XP/leveling with PartRegistry integration
- [x] 5 new EventBus signals for economy

##### Ship System Upgrades ✅
- [x] Upgrade refactor (credits + parts required)
- [x] Transaction rollback on failure
- [x] PartRegistry cost queries
- [x] All subclasses inherit new behavior

##### Workshop UI ✅
- [x] Player status panel (credits, XP, level, skill points)
- [x] Upgrade cost display with validation
- [x] Inventory popup (800x600, shows parts/rarity/weight)
- [x] Skill allocation popup (600x500)
- [x] Real-time updates via EventBus

##### Mission Rewards ✅
- [x] Missions grant credits + parts
- [x] Part discovery system (story-driven unlocks)
- [x] Tutorial mission updated (300 CR + 2 L1 parts)
- [x] Mission complete UI shows all rewards

---

#### ✅ Tutorial Mission (Complete)

**"The Inheritance" - Hand-written JSON mission**

- [x] 9 stages with branching paths
- [x] Multiple skill checks (engineering, diplomacy)
- [x] Rewards Level 1 systems + credits + parts
- [x] Integrated with ATLAS AI commentary (6 interjections)
- [x] Full narrative (~2000 words)
- [x] Star Trek TNG tone maintained

---

#### ✅ Workshop UI (Complete)

**Fully functional ship management interface**

- [x] Workshop scene (`godot/scenes/workshop.tscn`)
- [x] Systems panel (3 systems displayed)
- [x] System detail panel (stats, upgrade costs)
- [x] Player status display (credits, level, XP bar)
- [x] Resource validation (disabled buttons when can't afford)
- [x] Power budget tracking
- [x] Upgrade button functionality
- [x] Inventory management popup
- [x] Skill allocation popup
- [x] Real-time UI updates

---

#### ✅ Mission System (Complete)

**Scrolling narrative log with manual pacing**

- [x] MissionManager singleton (400+ lines)
- [x] Mission UI scene with scrolling log
- [x] Mission controller (700+ lines)
- [x] Workshop → Mission navigation
- [x] Choice system (up to 4 choices per stage)
- [x] Result display with consequence text
- [x] Stardate separators between stages
- [x] Visual hierarchy (80% opacity for past stages)
- [x] Manual scroll pacing with inline indicator
- [x] Mission rewards integration
- [x] Save/load during missions

---

#### ✅ Magentic UI System (Complete)

**Microsoft-inspired adaptive multi-AI UI**

- [x] AIPersonalityManager singleton (350+ lines)
- [x] AdaptiveLayoutManager singleton (200+ lines)
- [x] AIPanel component (150+ lines)
- [x] 4 AI personalities (ATLAS active, 3 ready)
- [x] 5 UI states (NARRATIVE_FOCUS, AI_INTERJECTION, etc.)
- [x] Context-aware AI interjections
- [x] Adaptive two-panel layout (50/50 split)
- [x] Smooth 0.4s transitions
- [x] Signal-based decoupled architecture

---

#### ✅ Save/Load System (Complete)

**JSON-based persistence with versioning**

- [x] SaveManager singleton
- [x] Auto-save after missions/upgrades
- [x] 5 save slots + autosave
- [x] Save migration for version changes
- [x] Timestamp and playtime tracking
- [x] Graceful handling of corrupted saves
- [x] All game state persists correctly

---

#### ✅ Dynamic Story Engine (Complete - 2025-11-09)

**AI-powered contextual narrative generation**

- [x] Story API implementation
  - [x] POST /api/story/generate_narrative
  - [x] POST /api/story/generate_outcome
  - [x] GET /api/story/memory/{player_id}
  - [x] GET /api/story/mission_pool
  - [x] GET /api/story/world_context
  - [x] DELETE /api/story/invalidate_cache
- [x] Memory manager
  - [x] Player choice tracking (last 100 choices)
  - [x] Relationship tracking with NPCs/factions
  - [x] Consequence tracking
  - [x] Memory-aware narrative generation
- [x] World state tracking
  - [x] Economy state (scarcity, inflation)
  - [x] Faction reputation system
  - [x] Major events timeline
  - [x] Active missions tracking
- [x] Hybrid mission support
  - [x] narrative_structure field for AI generation
  - [x] Fallback to static descriptions
  - [x] Backward compatibility with static missions
- [x] Godot integration (StoryService)
  - [x] StoryService singleton
  - [x] generate_narrative() method
  - [x] generate_outcome() method
  - [x] Hybrid mission detection
  - [x] Graceful error handling
- [x] Documentation complete
  - [x] STORY-API-REFERENCE.md
  - [x] story-engine/README.md
  - [x] MEMORY-MANAGER-REFERENCE.md
  - [x] WORLD-STATE-REFERENCE.md
  - [x] godot-story-integration.md

---

#### 🧪 Integration Testing ⏳ NEXT UP

**Current Focus: Full game playthrough testing**

##### Complete Game Loop Test (Ready to Test)
- [ ] Start new game from Workshop
- [ ] View player status (0 CR, 0 skill points initially)
- [ ] Launch tutorial mission "The Inheritance"
- [ ] Complete mission making choices
- [ ] Observe ATLAS AI interjections (6 total)
- [ ] Test manual scroll pacing (click/wheel/keyboard)
- [ ] Receive mission rewards (300 CR, 2 L1 parts, XP)
- [ ] Return to Workshop
- [ ] View updated player status (300 CR, level up?)
- [ ] Open inventory popup (verify 2 parts received)
- [ ] Attempt system upgrades (should work with rewards)
- [ ] Verify upgrade costs deducted correctly
- [ ] Test skill point allocation
- [ ] Verify auto-save works
- [ ] Close and reopen game
- [ ] Continue from save
- [ ] Verify all state restored

##### Bug Testing
- [ ] Test with old save files (migration working?)
- [ ] Test AI panel layout (side-by-side, not overlay?)
- [ ] Test scroll indicator (appears, clickable, hides?)
- [ ] Test upgrade when insufficient resources
- [ ] Test inventory weight limits
- [ ] Test skill allocation validation

**THIS IS THE CRITICAL TEST. If this works and is fun, Milestone 1 succeeds.**

---

### Milestone 1 Complete Criteria

- [x] All 3 systems implemented and testable ✅
- [x] Tutorial mission complete and playable ✅
- [x] Workshop UI functional ✅
- [x] Auto-save works ✅
- [x] Economy system integrated ✅
- [x] Magentic UI with ATLAS AI ✅
- [x] Manual scroll pacing ✅
- [ ] **Complete game loop tested end-to-end** ⏳ IN PROGRESS
- [ ] **Can play for 15 minutes and it's interesting** ⏳ NEEDS TESTING
- [ ] **Bug-free or only minor issues** ⏳ NEEDS VALIDATION

**Decision Point: Is it fun?**
- ✅ YES → Continue to Milestone 2
- ❌ NO → Pivot or learn from experience

**Status:** 90% complete - testing and validation phase

---

## 📋 Next: Milestone 2 - Expand Content

**Only start after Milestone 1 complete and validated as fun.**

**Goal:** Add variety and depth to prove the content scales well.

### Checklist (Preview - Don't Start Yet)

#### Add 2 More Systems
- [ ] Warp Drive system (Level 0→1)
- [ ] Life Support system (Level 0→1)

#### Add 4 More Missions
- [ ] 2 salvage missions (different locations)
- [ ] 1 exploration mission
- [ ] 1 story mission (introduces Earth lore)

#### Add ATLAS AI Personality
- [ ] Implement AI chat with ATLAS
- [ ] Add ATLAS advice/hints in Workshop
- [ ] ATLAS commentary during missions

#### Improve Workshop UI
- [ ] Better visuals
- [ ] System dependencies shown
- [ ] Power budget visualization
- [ ] Mission selection screen

#### Test & Balance
- [ ] Play through all content
- [ ] Verify progression feels good
- [ ] Adjust costs/rewards
- [ ] Get feedback from friends

**Milestone 2 Complete: 5 systems, 5 missions, 1 AI personality, improved UI, balanced gameplay**

---

## 🚀 Future: Milestone 3 - Share It

**Goal:** Make it ready for GitHub release and public testing.

### Checklist (High-Level)

#### Complete All 10 Systems
- [ ] Add remaining 5 systems (Sensors, Shields, Weapons, Communications, Computer)
- [ ] All systems Level 0→1 implemented
- [ ] All systems tested and balanced

#### Content Completeness
- [ ] 10+ missions total
- [ ] Multiple mission types represented
- [ ] Clear progression path
- [ ] Tutorial teaches all mechanics

#### Polish & Preparation
- [ ] Pre-generate all missions using AI credits
- [ ] Include cached content in repo
- [ ] Write clear README with setup instructions
- [ ] Test on fresh machine
- [ ] Support all 3 AI providers (Ollama/Claude/OpenAI)
- [ ] Error handling and user feedback
- [ ] Known issues documented

#### Release
- [ ] Create GitHub release v0.1.0-alpha
- [ ] Post on relevant subreddits
- [ ] itch.io upload (optional)
- [ ] Gather feedback

**Milestone 3 Complete: Playable game others can download and enjoy**

---

## 💭 Someday/Maybe: Milestone 4+

**No timeline. Build if motivated after Milestone 3.**

See [docs/03-game-design/future-features/](docs/03-game-design/future-features/) for fully designed features:

- Captain's Log system
- Ship Personality AI
- First Contact Protocol
- Away Team Missions
- Crew Recruitment
- Exodus Timeline Mystery
- Additional systems (Levels 2-5)
- Phase 2: Space exploration

**Or move on to next project. Both are valid outcomes.**

---

## 📊 Progress Tracking

**AI Agent: Update these percentages as you complete items.**

### Milestone 1 Progress: 45%
- Foundation: 100% ✅
- AI Service Core: 100% ✅ (mission/chat/dialogue APIs)
- Godot Singletons: 100% ✅ (5 autoloads + test scene)
- Documentation: 100% ✅ (32 files + AI agent workflow)
- Testing Infrastructure: 100% ✅ (guides, integration docs)
- Ship Systems: 0% (0/3 complete) ← **START HERE**
- Content: 0% (0/1 missions)
- Workshop UI: 0%
- Save/Load: 90% (exists, needs auto-save triggers)
- Integration Testing: 0%

### Overall Project Progress: 12%
- Milestone 1: 45%
- Milestone 2: 0%
- Milestone 3: 0%

---

## 🗓️ Timeline Estimates

**These are estimates, not deadlines. Hobby project = build when motivated.**

**Milestone 1:** 2-3 weeks of focused work (or 1-2 months at hobby pace)
**Milestone 2:** 2-3 weeks of focused work
**Milestone 3:** 2-4 weeks of focused work

**Total to shareable MVP:** 2-4 months at hobby pace

**Reality:** Probably 6-12 months with life, interruptions, and motivation fluctuations.

**That's completely fine.**

---

## 📝 Notes

**For AI Agent:**
- Work top-to-bottom through current milestone
- Check off items as you complete them
- Update progress percentages
- Mark current item with 🔨
- Mark blockers with ⏸️
- Document assumptions in STATUS.md

**For User:**
- This is your project progress tracker
- No deadlines, work at your own pace
- Decide at each milestone: continue or pivot?
- Success = learning + fun, not completion

---

**Ready to start? Check `/STATUS.md` for current task, then dive into the first unchecked item above.**
