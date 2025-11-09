# Dynamic Story Engine

**Complete guide to the Space Adventures dynamic story system**

## Overview

The Dynamic Story Engine generates contextual narratives based on player state, choices, and world events. It enables hybrid missions that combine pre-written structure with AI-generated content, creating unique experiences that adapt to player decisions while maintaining narrative quality.

**Key Features:**
- On-demand narrative generation with full player context
- Smart caching (1-hour TTL) for performance
- Player memory tracking (choices, relationships, consequences)
- World state integration (economy, factions, events)
- Graceful fallback to templates on LLM failure
- Mission pool with lazy queue for generic side missions

**Status:**
- Implementation: ✅ Complete
- Testing: ✅ Integration tested
- Documentation: ✅ Complete
- Production: ✅ Ready

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      GODOT CLIENT                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ StoryService │  │ MissionPlayer│  │  GameState   │     │
│  │  (Singleton) │  │    (Scene)   │  │  (Singleton) │     │
│  └───────┬──────┘  └──────┬───────┘  └──────┬───────┘     │
└──────────┼─────────────────┼─────────────────┼─────────────┘
           │                 │                 │
           │ HTTP REST API   │                 │
           ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────┐
│                    AI SERVICE (PORT 17011)                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │             Story API (/api/story/*)                  │  │
│  │  ┌────────────────────────────────────────────────┐  │  │
│  │  │ POST /generate_narrative - Generate stage text │  │  │
│  │  │ POST /generate_outcome   - Generate choice     │  │  │
│  │  │ GET  /memory/{id}        - Get player memory   │  │  │
│  │  │ GET  /mission_pool       - Get side mission    │  │  │
│  │  │ GET  /world_context      - Get world state     │  │  │
│  │  └────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌───────────────┬───────────────┬────────────────────┐   │
│  │ StoryEngine   │MemoryManager  │   WorldState       │   │
│  │               │               │                    │   │
│  │ - Narrative   │ - Choices     │ - Economy          │   │
│  │ - Outcomes    │ - Relations   │ - Factions         │   │
│  │ - Caching     │ - Consequences│ - Events           │   │
│  │ - LLM Client  │ - Story State │ - Sectors          │   │
│  └───────┬───────┴───────┬───────┴────────┬───────────┘   │
│          │               │                │               │
└──────────┼───────────────┼────────────────┼───────────────┘
           │               │                │
           ▼               ▼                ▼
      ┌──────────────────────────────────────┐
      │          REDIS (PORT 6379)            │
      │                                       │
      │  player_choices:{id}                 │
      │  player_relationships:{id}           │
      │  player_consequences:{id}            │
      │  player_story:{id}                   │
      │  story_cache:{mission}:{stage}:{hash}│
      │  world_economy:{sector}              │
      │  world_factions                      │
      │  world_events                        │
      │  mission_pool:{difficulty}           │
      └──────────────────────────────────────┘
```

---

## Core Components

### 1. Story Engine

**Purpose:** On-demand narrative generation with contextual caching

**Location:** `/python/ai-service/src/story/story_engine.py`

**Key Methods:**
- `generate_stage_narrative()` - Generate narrative for mission stage
- `generate_choice_outcome()` - Generate outcome for player choice
- `invalidate_cache()` - Clear cached narratives

**Features:**
- Level 4 (Cache-Only) implementation
- Full player context (choices, relationships, world state)
- 1-hour cache TTL
- 10-second LLM timeout
- Graceful fallback to template narratives

**See:** [Dynamic Story Engine Spec](./dynamic-story-engine.md)

### 2. Memory Manager

**Purpose:** Track player story history for contextual generation

**Location:** `/python/ai-service/src/story/memory_manager.py`

**Tracks:**
- **Choices:** Last 100 (FIFO queue)
- **Relationships:** NPCs/factions (-100 to +100)
- **Consequences:** Unresolved events for future callbacks
- **Story State:** Current mission, arc, flags

**Key Methods:**
- `add_choice()` - Record player choice
- `get_choices()` - Get recent choices
- `update_relationship()` - Modify NPC relationship
- `track_consequence()` - Track world impact
- `get_context()` - Build full memory context

**See:** [Memory Manager Reference](../../06-technical-reference/MEMORY-MANAGER-REFERENCE.md)

### 3. World State

**Purpose:** Manage global game state affecting narratives

**Location:** `/python/ai-service/src/story/world_state.py`

**Tracks:**
- **Economy:** Per-sector prices, availability, trader count
- **Factions:** Global power/influence (0-100, shared by all players)
- **Events:** Timeline of major world events

**Key Methods:**
- `update_economy()` - Change sector economy
- `get_economy()` - Get sector economic state
- `update_faction()` - Change faction power
- `add_event()` - Add world event to timeline
- `get_world_context()` - Build context for narratives

**See:** [World State Reference](../../06-technical-reference/WORLD-STATE-REFERENCE.md)

### 4. Mission Pool

**Purpose:** Lazy queue for generic side missions

**Location:** `/python/ai-service/src/story/mission_pool.py`

**Behavior:**
- Maintains 2-3 missions per difficulty in queue
- Generates reactively when queue runs low (<2)
- No scheduled pre-generation
- 24-hour TTL (missions can expire)

**Mission Types:**
- Salvage operations
- Exploration surveys
- Trade runs

**Key Methods:**
- `get_mission()` - Get mission from queue (generates if empty)
- `count_available()` - Check queue status
- `clear_queue()` - Reset queue

**See:** [Dynamic Story Engine Spec](./dynamic-story-engine.md)

---

## Integration Points

### Python Backend

**API Endpoints:** See [Story API Reference](../../06-technical-reference/STORY-API-REFERENCE.md)

**Implementation:**
- `/python/ai-service/src/api/story.py` - FastAPI router
- `/python/ai-service/src/story/` - Core engine modules

**Dependencies:**
- Redis (caching, memory, world state)
- LLM client (Claude/OpenAI/Ollama)

**Configuration:**
```bash
# .env
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0
AI_PROVIDER_STORY=claude  # or openai, ollama
ANTHROPIC_API_KEY=sk-...
```

### Godot Frontend

**StoryService Singleton:** See [Godot Story Integration](./godot-story-integration.md)

**Key Methods:**
```gdscript
# Generate narrative
var result = await StoryService.generate_narrative(mission_data, stage_id)
display_narrative(result.narrative)

# Generate outcome
var outcome = await StoryService.generate_outcome(choice_data)
apply_consequences(outcome.consequences)
update_relationships(outcome.consequences.relationships)
go_to_stage(outcome.next_stage)

# Get player memory
var memory = await StoryService.get_memory_context(player_id)
show_relationships_ui(memory.relationships)

# Invalidate cache on level up
await StoryService.invalidate_cache(mission_id)
```

**Hybrid Mission Support:**
- Loads mission JSON from `res://assets/data/missions/`
- Calls Story API for dynamic narrative
- Falls back to static content on error
- Applies consequences to GameState

**See:** [Godot Story Integration Guide](./godot-story-integration.md)

---

## Features

### ✅ Implemented

- **Contextual Narrative Generation**
  - Considers player history (last 10 choices)
  - Uses relationship scores
  - Incorporates active consequences
  - References world state

- **Player Memory Tracking**
  - FIFO queue (last 100 choices)
  - Relationship management (-100 to +100)
  - Consequence tracking for callbacks
  - Story flags (e.g., "cautious_explorer")

- **Smart Caching**
  - 1-hour TTL
  - Player state hash for invalidation
  - Cache hit/miss metrics
  - Manual invalidation on major events

- **Graceful Fallbacks**
  - Template narratives on LLM failure
  - 10-second timeout protection
  - Always returns playable content

- **World State Integration**
  - Economy per sector
  - Faction standings
  - Event timeline

- **Mission Pool**
  - Lazy queue (2-3 missions per difficulty)
  - Reactive generation
  - Simple templates

### ⏳ Planned (Future)

- **Mission Pool Auto-Replenishment**
  - Background task to keep queue full
  - Scheduled generation during low traffic
  - Priority queue based on player demand

- **Advanced Context**
  - Ship configuration in prompts
  - Crew roster references
  - Inventory-based narrative branches

- **LLM Provider Optimization**
  - Auto-select provider based on content type
  - Cost tracking and optimization
  - Fallback provider chains

- **Analytics**
  - Cache hit rate dashboard
  - Generation time monitoring
  - Player choice clustering
  - Relationship network visualization

---

## Documentation

### For Game Designers

- [Dynamic Story Engine Spec](./dynamic-story-engine.md) - Complete design document
- [Hybrid Mission Guide](./hybrid-mission-guide.md) - Creating hybrid missions (if exists)
- [Narrative Prompt Engineering](./prompt-engineering.md) - Writing effective prompts (if exists)

### For Developers

- [Story API Reference](../../06-technical-reference/STORY-API-REFERENCE.md) - Complete API documentation
- [Godot Story Integration](./godot-story-integration.md) - Frontend integration guide
- [Memory Manager Reference](../../06-technical-reference/MEMORY-MANAGER-REFERENCE.md) - Memory system API
- [World State Reference](../../06-technical-reference/WORLD-STATE-REFERENCE.md) - World state API

### For Content Creators

- [Migration Guide](./migration-guide.md) - Converting static to hybrid missions (if exists)
- [Hybrid Mission Example](../../03-game-design/content-systems/hybrid-mission-example.json) - Full example (if exists)
- [Consequence Tracking Guide](./consequence-tracking.md) - Designing callbacks (if exists)

---

## Quick Start

### For Game Designers

**Creating a Hybrid Mission:**

1. Start with mission template JSON:
```json
{
  "mission_id": "my_mission",
  "title": "Mission Title",
  "context": {
    "location": "Abandoned Station",
    "theme": "mystery",
    "tone": "tense",
    "key_npcs": ["Dr. Smith"]
  },
  "stages": [...]
}
```

2. Define narrative structure for each stage:
```json
{
  "stage_id": "stage_1",
  "narrative_structure": {
    "setup": "The player arrives at the station.",
    "conflict": "The airlock is damaged.",
    "prompt": "Describe the station's exterior and the airlock problem.",
    "include": ["atmospheric tension", "technical details"]
  },
  "choices": [...]
}
```

3. Define consequence tracking for choices:
```json
{
  "choice_id": "repair_airlock",
  "consequence_tracking": {
    "flags": ["skilled_engineer"],
    "relationships": {"Dr_Smith": 10},
    "world_impact": "station_operational"
  }
}
```

4. Place in `godot/assets/data/missions/my_mission.json`

5. Test in-game (narrative auto-generates)

**See:** [Hybrid Mission Guide](./hybrid-mission-guide.md)

### For Developers

**Calling Story API:**

```python
import httpx

# Generate narrative
response = await httpx.post(
    "http://localhost:17011/api/story/generate_narrative",
    json={
        "player_id": "player_123",
        "mission_template": mission_json,
        "stage_id": "stage_1",
        "player_state": {"level": 5, "current_mission": "my_mission"}
    }
)
narrative = response.json()["narrative"]
```

**Integrating in Godot:**

```gdscript
# In StoryService.gd
var result = await generate_narrative(mission_data, stage_id)
if result.success:
    display_narrative(result.narrative)
else:
    # Fallback to static content
    display_narrative(stage_data.fallback_text)
```

**See:** [Godot Story Integration](./godot-story-integration.md)

---

## Performance

### Cache Metrics

| Operation | Cache HIT | Cache MISS | Target |
|-----------|-----------|------------|--------|
| Generate narrative | 10-50ms | 800-2000ms | >80% hit rate |
| Generate outcome | 10-50ms | 600-1500ms | >70% hit rate |
| Get memory | 10-30ms | N/A | <50ms always |

### Optimization Strategy

1. **Aggressive caching:** 1-hour TTL balances freshness vs performance
2. **Player state hash:** Only invalidates on significant changes (level up, phase change)
3. **LLM timeouts:** 10-second max prevents hanging
4. **Fallback templates:** Always returns playable content
5. **Redis connection pool:** Reuses connections across requests

### Monitoring

Track these metrics:
- Cache hit rate (target: >80%)
- Generation time P95 (target: <3 seconds)
- LLM timeout rate (target: <1%)
- Fallback usage rate (target: <5%)

---

## Testing

### Manual Testing

```bash
# Start services
docker-compose up -d

# Generate narrative
curl -X POST http://localhost:17011/api/story/generate_narrative \
  -H "Content-Type: application/json" \
  -d @test_narrative_request.json

# Check cache hit
curl -X POST http://localhost:17011/api/story/generate_narrative \
  -H "Content-Type: application/json" \
  -d @test_narrative_request.json
# Should return cached:true, generation_time_ms:<50

# Get player memory
curl http://localhost:17011/api/story/memory/player_123?limit=5
```

### Integration Testing

```bash
cd /python/ai-service
pytest tests/test_story_integration.py -v
```

### In-Game Testing

1. Start game
2. Load hybrid mission
3. Observe narrative generation
4. Make choice
5. Verify consequences applied
6. Check relationships updated
7. Replay mission (should see cached narratives)

---

## Troubleshooting

### Narrative Not Generating

**Symptoms:** Getting template narratives instead of dynamic content

**Check:**
1. Redis running: `docker ps | grep redis`
2. AI service logs: `docker-compose logs ai-service`
3. LLM provider configured: Check `.env` file
4. API keys valid: Test with curl

### Cache Not Working

**Symptoms:** Every request generates fresh narrative (slow)

**Check:**
1. Redis connection: `redis-cli ping`
2. Cache keys exist: `redis-cli KEYS "story_cache:*"`
3. Player state hash consistent (same level, phase, mission)
4. TTL not expired (1 hour default)

### Relationships Not Updating

**Symptoms:** Relationship scores not changing after choices

**Check:**
1. `consequence_tracking.relationships` defined in choice JSON
2. `generate_outcome()` called (not just `generate_narrative()`)
3. Redis keys: `redis-cli HGETALL "player_relationships:player_123"`
4. Memory manager logs for update confirmation

### World State Not Affecting Narratives

**Symptoms:** Economy/faction changes not reflected

**Check:**
1. World state updated: `redis-cli HGETALL "world_economy:sector_name"`
2. `world_context` passed to `generate_narrative()`
3. Prompt template includes world state
4. Cache invalidated after world state change

---

## Related Systems

- [Mission Framework](../../03-game-design/content-systems/mission-framework.md) - Mission system overview
- [AI Integration](../ai-integration.md) - AI provider setup
- [Chat System](../ai-chat-storytelling-system.md) - Free-form player chat
- [Game State Management](../../02-developer-guides/architecture/game-state-management.md) - Player progression

---

## Changelog

### 2025-11-09
- Initial README created
- Complete architecture diagram
- Quick start guides for designers and developers
- Troubleshooting section
- Performance metrics

### 2025-11-08
- Dynamic story engine implemented
- Memory manager integrated
- World state tracking added
- Mission pool (Level 3) completed

### 2025-11-05
- Story API endpoints created
- Redis schema designed
- Pydantic models defined
