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

**Phase 1: Foundation** (Weeks 1-4) ✅ COMPLETE
- Gateway service implementation
- AI service implementation
- Whisper service implementation (optional)
- Image generation service
- Godot foundation (5 singletons)
- Comprehensive testing
- Documentation system

**Phase 2: Game Systems** (Weeks 5-8) → NEXT
- 10 ship system classes
- Workshop UI
- Mission system framework
- Inventory system
- Save/load integration
- Ship classification

**Phase 3: Content** (Weeks 9-12)
- 15+ story missions
- AI-generated mission integration
- Character development
- Quest chains
- Dialogue system
- Crew management

**Phase 4: Polish** (Weeks 13-16)
- Visual improvements
- Audio implementation
- Performance optimization
- Bug fixing
- Balance tuning
- Accessibility features

**Phase 5: Launch** (Weeks 17-20)
- Final QA
- Documentation completion
- Marketing materials
- Deployment automation
- Release preparation
- Post-launch monitoring

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

**✅ Phase 1 Complete (v0.1.0-foundation)**
- All services implemented
- Godot foundation complete
- Testing infrastructure ready
- Documentation organized

**→ Next: Phase 2, Week 5**
- Begin ship systems implementation
- See development-organization.md Section 4.2.1

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

**Phase 1 Milestones:** ✅
- [ Week 1] Gateway service operational
- [✅ Week 2] AI service with caching
- [✅ Week 3] Godot singletons functional
- [✅ Week 4] Testing infrastructure complete

**Phase 2 Milestones:** (Upcoming)
- [ ] Week 5: Ship systems base classes
- [ ] Week 6: Workshop UI complete
- [ ] Week 7: Mission system framework
- [ ] Week 8: Integration testing complete

## Quick Reference

**Current Phase:** 1 (Complete)
**Current Week:** N/A (Phase 1 complete)
**Next Phase:** 2 (Game Systems)
**Next Week:** Week 5 (Ship systems)

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
