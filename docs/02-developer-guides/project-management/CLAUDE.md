# project-management - AI Agent Context

**Purpose:** Development planning, roadmaps, and project organization.

## Directory Contents

### Key Files
1. **development-organization.md** - Master development plan
   - 5-phase development structure
   - Microservices overview
   - CLAUDE.md system documentation
   - Week-by-week breakdowns
   - QA and launch plans

2. **mvp-roadmap.md** - Week-by-week MVP plan
   - 6-week MVP roadmap
   - Daily task breakdowns
   - Deliverables and success criteria
   - Testing plans

## When to Use This Documentation

**Use when:**
- Planning new development work
- Understanding project structure
- Tracking progress
- Breaking down features into tasks
- Estimating timelines
- Onboarding to project workflow
- Preparing phase transitions

## Common Tasks

### Task: Plan next phase
1. Read development-organization.md for phase N+1
2. Review objectives and deliverables
3. Identify dependencies on current phase
4. Break down into weekly objectives
5. Create detailed task list
6. Update development-organization.md with actuals

### Task: Start new week
1. Check mvp-roadmap.md for current week
2. Review week objectives
3. Read daily task breakdown
4. Prioritize tasks
5. Begin implementation

### Task: Track progress
1. Review completed deliverables
2. Check off completed weekly objectives
3. Update phase progress percentage
4. Document blockers or delays
5. Adjust timelines if needed

### Task: Transition to new phase
1. Verify all previous phase deliverables complete
2. Run comprehensive testing
3. Tag release in git
4. Update documentation
5. Review next phase requirements
6. Begin Week 1 of new phase

## Relationships

**Defines:**
- Overall project structure
- Development timeline
- Task breakdown
- Success criteria

**Depends On:**
- Architecture decisions from `../architecture/`
- Game design from `../../03-game-design/`
- Testing procedures from `../../01-user-guides/testing/`

**Informs:**
- Daily development work
- Testing schedules
- Release planning
- Documentation updates

## Development Structure

### 5-Phase Approach

**Milestone 1: Proof of Concept** (Current - 92% complete) ✅
- ✅ Microservices architecture (Gateway, AI Service, Whisper, Redis)
- ✅ Godot foundation (10 autoload singletons, 3,600+ lines)
- ✅ Core ship systems (Hull, Power, Propulsion Level 0-5)
- ✅ Workshop UI with economy integration
- ✅ Mission system with scrolling narrative log
- ✅ Magentic UI with 4 AI personalities
- ✅ Dynamic Story Engine (Memory Manager, World State)
- ✅ Hybrid Economy (PartRegistry, credits + parts)
- ⏳ Testing: Full game playthrough validation

**Milestone 2: Expand Content** (Future - after M1 validation)
- Add more systems (Warp, Life Support)
- Add more missions (salvage, exploration, story)
- Expand AI personalities and interjections
- UI improvements and polish

**Milestone 3: Share It** (Future - public release)
- All 10 systems complete (Level 0-5)
- 10+ missions total
- Polish and deployment preparation
- Public release on GitHub/itch.io

**See:** `/ROADMAP.md` for complete milestone checklists and `/STATUS.md` for current progress

### Week Structure

**Each week follows pattern:**
- **Day 1-2:** Feature implementation
- **Day 3-4:** Testing and refinement
- **Day 5:** Documentation and cleanup
- **End of Week:** Deliverables verified

### Daily Task Structure

**Morning:**
- Review daily objectives
- Check directory CLAUDE.md for context
- Plan implementation approach

**Afternoon:**
- Implement features
- Write tests as you go
- Document code

**Evening:**
- Commit with clear messages
- Update documentation
- Review progress

## AI Agent Instructions

**When planning work:**
1. Always start with development-organization.md
2. Understand which phase we're in
3. Check phase objectives and deliverables
4. Use mvp-roadmap.md for tactical planning
5. Break work into testable increments

**When implementing:**
1. Follow phase structure
2. Complete week objectives before moving on
3. Test continuously, not just at end
4. Update documentation as you go
5. Use CLAUDE.md files in each directory

**When blocked:**
1. Document the blocker
2. Assess impact on timeline
3. Find workaround if possible
4. Update roadmap if needed
5. Communicate changes

## Current Status

**Milestone 1: Proof of Concept (92% complete)**
- All services implemented
- Godot foundation complete (10 singletons)
- Core systems and economy implemented
- Magentic UI with 4 AI personalities
- Dynamic Story Engine operational

**Next: Complete M1 Testing**
- Full game playthrough validation
- See `/STATUS.md` and `/ROADMAP.md` for current tasks

## Key Principles

### Phase-Based Development
- Clear objectives per phase
- Deliverables define completion
- Testing at end of each phase
- No phase overlap (finish before starting next)

### Incremental Progress
- Small, testable changes
- Continuous integration
- Regular commits
- Documentation alongside code

### Quality Focus
- Test as you build
- Code reviews (AI-assisted)
- Performance monitoring
- User feedback integration

## Milestone Tracking

**Milestone 1: Proof of Concept** (92% complete)
- [✅] Microservices architecture
- [✅] 10 Godot singletons (3,600+ lines)
- [✅] Core ship systems (Hull, Power, Propulsion)
- [✅] Workshop UI with economy
- [✅] Mission system with narrative log
- [✅] Magentic UI (4 AI personalities)
- [✅] Dynamic Story Engine
- [⏳] Full playthrough testing

**Milestone 2: Expand Content** (Future)
- [ ] Additional ship systems (Warp, Life Support)
- [ ] More missions (salvage, exploration, story)
- [ ] Expanded AI personality content
- [ ] UI polish and improvements

## Quick Reference

**Current Milestone:** 1 - Proof of Concept (92% complete)
**Current Task:** Full game playthrough testing
**Next Milestone:** 2 - Expand Content (after M1 validation)
**Decision Point:** "Is it fun?" determines next steps

**Key Documents:**
- development-organization.md - Strategic plan
- mvp-roadmap.md - Tactical plan

**Update Frequency:**
- development-organization.md: After each phase
- mvp-roadmap.md: Weekly progress updates

---

**Parent Context:** [../../CLAUDE.md](../../CLAUDE.md)
**Directory Index:** [README.md](./README.md)
**Developer Guides:** [../CLAUDE.md](../CLAUDE.md)
