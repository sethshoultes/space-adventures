# Dynamic Story Engine - Implementation Checklist

**Date Started:** 2025-01-09
**Status:** 🚧 In Progress
**Completion:** 0/12 tasks (0%)

---

## Overview

Implementing a hybrid dynamic story engine that generates contextual narratives based on player choices, relationships, and world state.

**Architecture:** Hybrid Level 3/Level 4
- **Level 4 (Cache-Only)**: Story content generated on-demand with full context
- **Level 3 (Lazy Queue)**: Generic side missions kept in small reactive queue

**Code Estimate:** ~430 lines (57% reduction from full AI-first system)
**Dependencies:** Zero new (just Redis)
**Complexity:** Medium

---

## Quick Reference

| Component | File | Lines | Status |
|-----------|------|-------|--------|
| Planning Docs | `docs/05-ai-content/dynamic-story-engine.md` | N/A | ✅ Complete |
| Memory Manager | `python/ai-service/src/story/memory_manager.py` | ~100 | ⏳ Pending |
| Story Engine | `python/ai-service/src/story/story_engine.py` | ~150 | ⏳ Pending |
| World State | `python/ai-service/src/story/world_state.py` | ~80 | ⏳ Pending |
| Mission Pool | `python/ai-service/src/story/mission_pool.py` | ~100 | ⏳ Pending |
| API Endpoints | `python/ai-service/src/api/story.py` | N/A | ⏳ Pending |
| Storyteller Updates | `python/ai-service/src/agents/storyteller_agent.py` | N/A | ⏳ Pending |
| Hybrid Mission Schema | `docs/05-ai-content/dynamic-story-engine.md` | N/A | ✅ Complete |
| Godot Integration | `godot/scripts/ui/mission.gd` | N/A | ⏳ Pending |
| Tutorial Conversion | `godot/assets/data/missions/tutorial.json` | N/A | ⏳ Pending |

---

## Master Checklist

### ✅ Week 1: Core Infrastructure (Planning & Memory)

#### ✅ Day 1-2: Planning & Schema Design
- [x] Create comprehensive planning document
- [x] Design hybrid mission JSON schema
- [x] Design Redis memory schema
- [x] Define API endpoints
- [x] Document Storyteller agent modes
- [x] Create master checklist (this file)

**Status:** ✅ Complete
**Date Completed:** 2025-01-09

---

#### ⏳ Day 3-4: Memory Manager (~100 lines)

**File:** `python/ai-service/src/story/memory_manager.py`

**Tasks:**
- [ ] Create `story/` directory in ai-service
- [ ] Create `memory_manager.py` file
- [ ] Implement `add_choice()` - Record player choice (keep last 100)
- [ ] Implement `get_choices()` - Retrieve recent choices
- [ ] Implement `update_relationship()` - Update NPC relationship score (-100 to +100)
- [ ] Implement `get_relationships()` - Get all relationship scores
- [ ] Implement `track_consequence()` - Record consequence for future callback
- [ ] Implement `get_active_consequences()` - Get unresolved consequences
- [ ] Implement `get_context()` - Build context dict for prompts (last 10 choices)
- [ ] Add Redis client initialization
- [ ] Write unit tests for all methods
- [ ] Test FIFO behavior for choice list (max 100)
- [ ] Test relationship score boundaries (-100 to +100)
- [ ] Document API in docstrings

**Redis Keys Used:**
- `player_choices:{player_id}` - List (FIFO, max 100)
- `player_relationships:{player_id}` - Hash
- `player_consequences:{player_id}` - List
- `player_story:{player_id}` - Hash (story state)

**Status:** ⏳ Pending
**Estimated Time:** 4-6 hours
**Blockers:** None

---

#### ⏳ Day 5-7: Story Engine (~150 lines)

**File:** `python/ai-service/src/story/story_engine.py`

**Tasks:**
- [ ] Create `story_engine.py` file
- [ ] Implement `generate_stage_narrative()` - Generate narrative for mission stage
- [ ] Implement `generate_choice_outcome()` - Generate consequence of player choice
- [ ] Implement `_build_context()` - Build context from memory + world state
- [ ] Implement `_generate_cache_key()` - Create cache key with player state hash
- [ ] Implement `invalidate_cache()` - Clear cache when player state changes
- [ ] Implement `_check_cache()` - Check for cached narrative
- [ ] Implement `_store_cache()` - Store generated narrative in cache
- [ ] Add LLM client integration (Ollama/OpenAI/Claude)
- [ ] Write prompt templates for narrative generation
- [ ] Write prompt templates for choice outcomes
- [ ] Add error handling for LLM failures
- [ ] Write integration tests with mock LLM
- [ ] Test cache hit/miss scenarios
- [ ] Test cache invalidation on player state change
- [ ] Performance test (generation time <2s)
- [ ] Document all methods

**Redis Keys Used:**
- `story_cache:{mission_id}:{stage_id}:{player_hash}` - String (JSON), TTL 1 hour

**Status:** ⏳ Pending
**Estimated Time:** 8-10 hours
**Blockers:** Requires memory_manager.py complete

---

### ⏳ Week 2: World State & Mission Pool

#### ⏳ Day 8-9: World State Manager (~80 lines)

**File:** `python/ai-service/src/story/world_state.py`

**Tasks:**
- [ ] Create `world_state.py` file
- [ ] Implement `update_economy()` - Update sector economy based on player actions
- [ ] Implement `get_economy()` - Get economy state for sector
- [ ] Implement `update_faction()` - Update faction reputation
- [ ] Implement `get_faction()` - Get faction standing
- [ ] Implement `add_event()` - Add event to global timeline
- [ ] Implement `get_recent_events()` - Get recent world events
- [ ] Implement `get_world_context()` - Build world state dict for prompts
- [ ] Add Redis client initialization
- [ ] Write unit tests for all methods
- [ ] Test economy updates
- [ ] Test faction reputation changes
- [ ] Test event timeline (sorted by timestamp)
- [ ] Document all methods

**Redis Keys Used:**
- `world_economy:{sector}` - Hash (TTL 7 days or persistent)
- `world_factions` - Hash (persistent)
- `world_events` - Sorted Set (score=timestamp, TTL 30 days)

**Status:** ⏳ Pending
**Estimated Time:** 4-6 hours
**Blockers:** None

---

#### ⏳ Day 10-12: Mission Pool (Lazy Queue) (~100 lines)

**File:** `python/ai-service/src/story/mission_pool.py`

**Tasks:**
- [ ] Create `mission_pool.py` file
- [ ] Implement `get_mission()` - Get mission from queue (generate if empty)
- [ ] Implement `fill_queue_if_low()` - Reactively fill to 2-3 missions
- [ ] Implement `_generate_generic_mission()` - Generate simple side mission
- [ ] Implement `count_available()` - Count missions in queue
- [ ] Implement `_get_from_queue()` - Pop mission from queue
- [ ] Implement `_add_to_queue()` - Add mission to queue
- [ ] Add LLM client for mission generation
- [ ] Write prompt template for generic missions (salvage/exploration/trade)
- [ ] Add error handling for generation failures
- [ ] Write integration tests
- [ ] Test lazy filling behavior (only when queue <2)
- [ ] Test queue max size (3 missions)
- [ ] Verify NO scheduled tasks (reactive only)
- [ ] Document all methods

**Redis Keys Used:**
- `mission_pool:{difficulty}` - List (TTL 24 hours)

**Status:** ⏳ Pending
**Estimated Time:** 6-8 hours
**Blockers:** None

---

### ⏳ Week 3: API & Agent Updates

#### ⏳ Day 13-15: Story API Endpoints

**File:** `python/ai-service/src/api/story.py`

**Tasks:**
- [ ] Create `api/story.py` file
- [ ] Create Pydantic models for requests/responses
- [ ] Implement `POST /api/story/generate_narrative` endpoint
- [ ] Implement `POST /api/story/generate_outcome` endpoint
- [ ] Implement `GET /api/story/memory/{player_id}` endpoint
- [ ] Implement `GET /api/story/mission_pool` endpoint
- [ ] Add request validation
- [ ] Add error handling (500, 400, 404)
- [ ] Add logging
- [ ] Register router in main.py
- [ ] Write API integration tests
- [ ] Test all endpoints with curl/Postman
- [ ] Document API in docstrings
- [ ] Update API documentation

**Models Needed:**
- `GenerateNarrativeRequest`
- `GenerateNarrativeResponse`
- `GenerateOutcomeRequest`
- `GenerateOutcomeResponse`
- `MemoryContextResponse`
- `MissionPoolResponse`

**Status:** ⏳ Pending
**Estimated Time:** 6-8 hours
**Blockers:** Requires story_engine.py, memory_manager.py, mission_pool.py complete

---

#### ⏳ Day 16-18: Storyteller Agent Updates

**File:** `python/ai-service/src/agents/storyteller_agent.py`

**Tasks:**
- [ ] Add `mode` parameter to `run()` method ("chat" or "story")
- [ ] Implement `_chat_mode()` - Answer lore questions only
- [ ] Implement `_story_mode()` - Generate narrative with context
- [ ] Update chat mode system prompt (Q&A only, no story generation)
- [ ] Update story mode system prompt (narrative generation with memory)
- [ ] Add player memory context to story mode prompts
- [ ] Add world state context to story mode prompts
- [ ] Update tools for story generation
- [ ] Write unit tests for both modes
- [ ] Test chat mode doesn't generate narrative
- [ ] Test story mode includes player history
- [ ] Test mode switching
- [ ] Document changes

**Status:** ⏳ Pending
**Estimated Time:** 4-6 hours
**Blockers:** Requires memory_manager.py, world_state.py complete

---

### ⏳ Week 4: Mission Conversion & Integration

#### ⏳ Day 19-21: Hybrid Mission Format

**Tasks:**
- [ ] Read existing tutorial mission (`godot/assets/data/missions/tutorial.json`)
- [ ] Design hybrid version with narrative_structure blocks
- [ ] Add `context` section (location, theme, tone, npcs)
- [ ] Convert stage descriptions to `narrative_structure` with prompts
- [ ] Convert choice text to `outcome_prompt` instructions
- [ ] Add `consequence_tracking` to choices (flags, relationships, world impact)
- [ ] Add multiple `paths` per choice (success/partial/failure)
- [ ] Save as new hybrid format
- [ ] Test narrative generation with tutorial mission
- [ ] Validate consequence tracking works
- [ ] Test choice outcomes feel appropriate
- [ ] Test memory persistence

**Example Conversion:**
```json
// OLD (static)
{
  "description": "You arrive at an abandoned shipyard..."
}

// NEW (hybrid)
{
  "narrative_structure": {
    "setup": "Player arrives at shipyard",
    "prompt": "Describe the first view of the shipyard ruins",
    "include": ["Visual details", "Atmosphere", "Immediate danger"]
  }
}
```

**Status:** ⏳ Pending
**Estimated Time:** 6-8 hours
**Blockers:** Requires story API complete

---

#### ⏳ Day 22-24: Godot Integration

**File:** `godot/scripts/ui/mission.gd`

**Tasks:**
- [ ] Add story API client methods to `AIService` singleton
- [ ] Update `_load_mission_stage()` to call story API for narrative
- [ ] Update `_on_choice_pressed()` to call outcome API
- [ ] Add loading indicator during AI generation
- [ ] Add error handling for story API failures
- [ ] Update UI to show "Generating narrative..." message
- [ ] Test integration with hybrid mission format
- [ ] Test loading states
- [ ] Test error states (AI unavailable)
- [ ] Verify save/load preserves story state
- [ ] Document changes

**New API Calls:**
```gdscript
func generate_stage_narrative(mission_template: Dictionary, stage_id: String) -> Dictionary:
    # POST to /api/story/generate_narrative
    pass

func generate_choice_outcome(choice: Dictionary) -> Dictionary:
    # POST to /api/story/generate_outcome
    pass
```

**Status:** ⏳ Pending
**Estimated Time:** 6-8 hours
**Blockers:** Requires story API complete

---

#### ⏳ Day 25-28: End-to-End Testing

**Tasks:**
- [ ] Full playthrough of tutorial mission with dynamic generation
- [ ] Verify each choice generates appropriate outcome
- [ ] Check past choices referenced in later narrative
- [ ] Test relationship changes persist
- [ ] Test consequence callbacks work
- [ ] Test world state changes are noticeable
- [ ] Test cache hit rate (goal: >30%)
- [ ] Test generation time (goal: <2s per narrative)
- [ ] Test memory usage (goal: <100MB)
- [ ] Test error scenarios (Redis down, LLM unavailable)
- [ ] Performance profiling
- [ ] Fix any bugs found
- [ ] Document any issues in JOURNAL.md
- [ ] Update STATUS.md with completion

**Performance Metrics:**
- Generation time: ____ms (target: <2000ms)
- Cache hit rate: ___% (target: >30%)
- Memory usage: ____MB (target: <100MB)
- Error rate: ___% (target: <1%)

**Status:** ⏳ Pending
**Estimated Time:** 8-10 hours
**Blockers:** Requires all previous tasks complete

---

## Progress Tracking

### Completion Status

| Week | Focus | Tasks Complete | Status |
|------|-------|----------------|--------|
| Week 1 | Core Infrastructure | 1/3 | 🚧 In Progress |
| Week 2 | World State & Mission Pool | 0/2 | ⏳ Pending |
| Week 3 | API & Agent Updates | 0/2 | ⏳ Pending |
| Week 4 | Integration & Testing | 0/3 | ⏳ Pending |

### Overall Progress
- **Tasks Completed:** 1/12 (8%)
- **Lines Written:** 0/430 (0%)
- **Tests Written:** 0/~30 (0%)
- **Time Spent:** ~2 hours (planning)
- **Estimated Remaining:** ~50-60 hours

---

## Architecture Summary

### Level 4: Cache-Only (Story Content)

```
Player Action
    ↓
Godot: Request narrative for stage
    ↓
Story Engine: Check cache (key includes player state hash)
    ↓
Cache MISS? → Build context from memory + world state
    ↓
Generate narrative via LLM (Ollama/Claude/OpenAI)
    ↓
Cache result (TTL: 1 hour)
    ↓
Return narrative to Godot
```

**Benefits:**
- Full player context (choices, relationships, world state)
- Contextual and personalized
- No pre-generation waste
- No scheduled tasks

**Trade-offs:**
- 1-2s generation time (acceptable with loading indicator)
- Requires Redis

### Level 3: Lazy Queue (Side Missions)

```
Player: Request side mission
    ↓
Mission Pool: Check queue count
    ↓
Queue has 2-3 missions? → Return one
    ↓
Queue low (<2)? → Generate 1-2 more reactively
    ↓
Return mission to player
```

**Benefits:**
- Instant delivery (mission already generated)
- Minimal waste (only 2-3 in queue)
- No scheduled tasks (reactive filling)

**Trade-offs:**
- Generic content (no player context)
- Only for simple side missions

---

## Dependencies

### Zero New Dependencies
- Uses existing Redis (for memory + cache)
- Uses existing LLM clients (Ollama/Claude/OpenAI)
- No APScheduler needed
- No new Python packages

### Existing Dependencies
- `redis.asyncio` - Already used
- `langchain` - Already used
- `fastapi` - Already used
- `pydantic` - Already used

---

## Testing Coverage

### Unit Tests (~15 tests)
- Memory Manager: 5 tests
- Story Engine: 5 tests
- World State: 3 tests
- Mission Pool: 2 tests

### Integration Tests (~10 tests)
- Story API endpoints: 4 tests
- Storyteller agent modes: 2 tests
- Full story flow: 2 tests
- Godot integration: 2 tests

### Manual Testing (~5 scenarios)
- Tutorial mission playthrough
- Multiple choice paths
- Consequence callbacks
- Error handling
- Performance profiling

---

## Success Criteria

### Technical Metrics
- [ ] All 430 lines of code written
- [ ] Zero new dependencies added
- [ ] Cache hit rate >30%
- [ ] Generation time <2 seconds
- [ ] Memory usage <100MB
- [ ] All tests passing (25/25)

### Gameplay Metrics
- [ ] Story feels contextual (references past choices)
- [ ] Choices feel meaningful (consequences tracked)
- [ ] No obvious repetition in narratives
- [ ] Relationships evolve naturally
- [ ] World state changes noticeable
- [ ] No inappropriate content generated

### User Experience Metrics
- [ ] Loading times acceptable (<2s)
- [ ] Error messages clear
- [ ] No crashes or freezes
- [ ] Save/load preserves story state
- [ ] Tutorial mission playable end-to-end

---

## Known Risks

### Risk: AI Generation Too Slow
**Status:** Monitoring
**Mitigation:** Caching, pre-generation on scene load, loading indicators

### Risk: AI Generates Inconsistent Content
**Status:** Monitoring
**Mitigation:** Include last 10 choices in prompt, track relationships, validate output

### Risk: Cache Invalidation Issues
**Status:** Monitoring
**Mitigation:** Player state hash in cache key, 1-hour TTL, track state changes

### Risk: Memory Usage Growth
**Status:** Monitoring
**Mitigation:** FIFO limit (100 choices), TTLs on world events, monitor Redis

### Risk: Redis Failure
**Status:** Monitoring
**Mitigation:** Clear error message, health check endpoint, no silent fallback

---

## Git Branch Management

### Research Branch to Merge
**Branch:** `origin/claude/ai-first-systems-research-011CUwKMnjet9JFgFokSaPmc`

**Contains:**
- AI-first architecture research
- Background pre-generation patterns
- Developer guide with limitations
- Performance benchmarks

**Action Items:**
- [ ] Merge research branch into main
- [ ] Extract useful patterns from research
- [ ] Archive AI-first docs in `docs/archive/` or reference folder

---

## Next Steps

**Immediate (Next Session):**
1. ✅ Merge research branch: `git merge origin/claude/ai-first-systems-research-011CUwKMnjet9JFgFokSaPmc`
2. ⏳ Create `python/ai-service/src/story/` directory
3. ⏳ Implement `memory_manager.py` (~100 lines)
4. ⏳ Write unit tests for memory manager

**This Week:**
- Complete Memory Manager (Day 3-4)
- Complete Story Engine (Day 5-7)
- Begin World State Manager (Day 8-9)

**This Month:**
- All 4 core components complete
- All API endpoints functional
- Tutorial mission converted
- Full end-to-end test passing

---

**Created:** 2025-01-09
**Last Updated:** 2025-01-09
**Status:** 🚧 Week 1 - Planning Complete, Implementation Starting

**Related Files:**
- [Technical Specification](docs/05-ai-content/dynamic-story-engine.md)
- [AI Chat System](docs/05-ai-content/ai-chat-storytelling-system.md)
- [Mission Framework](docs/03-game-design/content-systems/mission-framework.md)
- [Phase 2 Complete](PHASE_2_COMPLETE.md) - Multi-agent system reference
