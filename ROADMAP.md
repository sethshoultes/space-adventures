# Development Roadmap

> **This is a hobby/learning project.** Milestones are flexible goals, not deadlines. Build when motivated, pause when needed, pivot if not fun.

**Current Milestone:** Milestone 1 - Proof of Concept
**Status:** 20% Complete (Foundation done, implementation starting)
**Next Checkpoint:** Can you play one complete game loop?

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

#### 🔨 Ship Systems Implementation (In Progress)

**Current Task: Implement 3 core systems (Level 0→1 only)**

##### Hull System
- [ ] **START HERE** → Create `godot/scripts/systems/hull_system.gd`
  - [ ] Extend base Node class (or create base ShipSystem class)
  - [ ] Properties: `level: int`, `health: int`, `max_health: int`, `active: bool`
  - [ ] Method: `upgrade()` - Level 0→1 upgrade logic
  - [ ] Method: `take_damage(amount: int)`
  - [ ] Method: `repair(amount: int)`
  - [ ] Method: `get_power_cost() -> int` (returns 0 for Hull)
  - [ ] Connect to GameState.ship.systems["hull"]
  - [ ] Emit EventBus signals on state changes

- [ ] Test Hull System
  - [ ] Can instantiate system
  - [ ] Level 0 starts with 0 HP, inactive
  - [ ] Can upgrade to Level 1
  - [ ] Level 1 has 50 HP, active
  - [ ] Can take damage
  - [ ] Can repair
  - [ ] Persists through save/load

##### Power Core System
- [ ] Create `godot/scripts/systems/power_system.gd`
  - [ ] Properties: `level: int`, `power_output: int`, `efficiency: float`, `active: bool`
  - [ ] Method: `upgrade()` - Level 0→1 upgrade logic
  - [ ] Method: `get_power_output() -> int`
  - [ ] Method: `get_power_cost() -> int` (returns 0, generates power)
  - [ ] Connect to GameState.ship.systems["power"]
  - [ ] Update GameState.ship.power_total when active

- [ ] Test Power System
  - [ ] Level 0: 0 power output
  - [ ] Level 1: 150 power output
  - [ ] Integrates with ship power calculations
  - [ ] Save/load works

##### Propulsion System
- [ ] Create `godot/scripts/systems/propulsion_system.gd`
  - [ ] Properties: `level: int`, `speed: int`, `maneuverability: float`, `active: bool`
  - [ ] Method: `upgrade()` - Level 0→1 upgrade logic
  - [ ] Method: `get_power_cost() -> int` (10 power at Level 1)
  - [ ] Method: `get_speed() -> int`
  - [ ] Connect to GameState.ship.systems["propulsion"]
  - [ ] Consume power when active

- [ ] Test Propulsion System
  - [ ] Level 0: 0 speed, consumes 0 power
  - [ ] Level 1: 50 speed, consumes 10 power
  - [ ] Power consumption updates ship totals
  - [ ] Save/load works

---

#### 📝 Content Creation

##### Tutorial Mission (Hand-Written)
- [ ] Create `godot/assets/data/missions/mission_tutorial.json`
  - [ ] Write mission structure (see mission-framework.md)
  - [ ] Include: mission_id, title, description, difficulty
  - [ ] Create 3-4 stages
  - [ ] Add 2-3 choices per stage
  - [ ] Write all text content (~500 words total)
  - [ ] Define rewards (100 XP, 200 resources)
  - [ ] Set requirements (none - this is tutorial)

**Mission Content Guidelines:**
- Teaches: How to upgrade systems
- Teaches: How missions work
- Teaches: Resource management
- Story: Finding first ship part in ruins
- Tone: Hopeful but serious (Star Trek TNG style)
- Length: 10-15 minutes to complete

- [ ] Test Tutorial Mission
  - [ ] JSON parses correctly
  - [ ] All stages load
  - [ ] Choices work
  - [ ] Rewards granted correctly
  - [ ] Text is clear and engaging

---

#### 🖼️ Workshop UI Implementation

##### Basic Workshop Scene
- [ ] Create `godot/scenes/workshop.tscn`
  - [ ] Background (simple, can be placeholder color)
  - [ ] Title label: "Workshop"
  - [ ] Ship name display
  - [ ] Resource counter display

##### Systems Panel
- [ ] Add VBoxContainer for systems list
  - [ ] For each system (Hull, Power, Propulsion):
    - [ ] System name label
    - [ ] Current level label
    - [ ] Health/status indicator
    - [ ] Upgrade button
    - [ ] Power cost display

##### System Detail Panel
- [ ] Show selected system details
  - [ ] System name and description
  - [ ] Current stats
  - [ ] Next level stats
  - [ ] Upgrade cost
  - [ ] "Upgrade" button (disabled if can't afford)

##### Resource Display
- [ ] Show current resources
- [ ] Show resource costs for upgrades
- [ ] Update in real-time

**UI Polish: Not needed for Milestone 1. Functional > Beautiful.**

- [ ] Wire up Workshop Scene
  - [ ] Load system data from GameState
  - [ ] Update UI when systems change
  - [ ] Connect upgrade buttons to upgrade logic
  - [ ] Update resource display
  - [ ] Show success/error messages

- [ ] Test Workshop UI
  - [ ] Displays all systems correctly
  - [ ] Upgrade buttons work
  - [ ] Resources update
  - [ ] Can't upgrade without resources
  - [ ] Visual feedback on upgrade

---

#### 💾 Save/Load Implementation

##### Auto-Save System
- [ ] Implement auto-save in SaveManager
  - [ ] Auto-save after mission complete
  - [ ] Auto-save after system upgrade
  - [ ] Auto-save every 5 minutes (optional)
  - [ ] Save to `godot/saves/autosave.json`

- [ ] Implement save/load UI
  - [ ] "Continue" button (loads autosave)
  - [ ] Show last save time
  - [ ] Handle missing save gracefully

- [ ] Test Save/Load
  - [ ] Game state persists correctly
  - [ ] All system data saves
  - [ ] All player data saves
  - [ ] Can load and continue
  - [ ] Corrupted saves handled gracefully

---

#### 🧪 Integration Testing

##### Complete Game Loop Test
- [ ] Start new game
- [ ] View Workshop
- [ ] Check resources (should have starting amount)
- [ ] Select Hull system
- [ ] Upgrade Hull to Level 1
- [ ] Verify resources deducted
- [ ] Verify Hull stats updated
- [ ] Start Tutorial mission
- [ ] Complete mission making choices
- [ ] Receive rewards (XP, resources)
- [ ] Return to Workshop
- [ ] Verify progression saved
- [ ] Close game
- [ ] Reopen game
- [ ] Continue from save
- [ ] Verify all state restored

**THIS IS THE CRITICAL TEST. If this works and is fun, Milestone 1 succeeds.**

---

### Milestone 1 Complete Criteria

- [ ] All 3 systems implemented and testable
- [ ] Tutorial mission complete and playable
- [ ] Workshop UI functional (doesn't need to be pretty)
- [ ] Auto-save works
- [ ] Complete game loop works end-to-end
- [ ] **Can play for 15 minutes and it's interesting**

**Decision Point: Is it fun?**
- ✅ YES → Continue to Milestone 2
- ❌ NO → Pivot or learn from experience

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

### Milestone 1 Progress: 20%
- Foundation: 100% ✅
- Ship Systems: 0% (0/3 complete)
- Content: 0% (0/1 missions)
- Workshop UI: 0%
- Save/Load: 50% (exists, needs auto-save)
- Integration Testing: 0%

### Overall Project Progress: 5%
- Milestone 1: 20%
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
