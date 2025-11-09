# Story API Reference

## Overview

The Story API provides endpoints for dynamic narrative generation in Space Adventures. It powers the hybrid mission system by generating contextual narratives based on player history, relationships, and world state.

**Base URL:** `http://localhost:17011/api/story`

**Service:** AI Service (Port 17011)

**Purpose:**
- Generate contextual narratives for mission stages
- Generate choice outcomes with consequences
- Track player memory and relationships
- Provide world state context
- Manage mission pool (generic side missions)

**Key Features:**
- Smart caching with player state hash (1-hour TTL)
- Contextual generation using player memory
- Graceful fallback to templates on LLM failure
- World state integration for global narrative context

---

## Endpoints

### POST /api/story/generate_narrative

Generate dynamic narrative text for a mission stage.

Uses StoryEngine to generate contextual narrative based on:
- Mission template structure (hybrid mission JSON)
- Player history (last 10 choices)
- Relationships with NPCs (-100 to +100)
- Active consequences
- World state (economy, factions, events)

Returns cached result if player state hash matches (1-hour TTL).

**Request Body:**

```json
{
  "player_id": "player_123",
  "mission_template": {
    "mission_id": "tutorial_shipyard",
    "title": "Tutorial Mission",
    "context": {
      "location": "Abandoned Shipyard",
      "theme": "discovery",
      "tone": "mysterious",
      "key_npcs": ["Engineer Chen"]
    },
    "stages": [
      {
        "stage_id": "stage_1",
        "narrative_structure": {
          "setup": "You arrive at the derelict shipyard.",
          "conflict": "The main door is sealed.",
          "prompt": "Describe the player's arrival and their initial observations.",
          "include": ["atmospheric tension", "ship detail"]
        },
        "choices": []
      }
    ]
  },
  "stage_id": "stage_1",
  "player_state": {
    "level": 5,
    "current_mission": "tutorial_shipyard",
    "completed_missions": ["intro_mission"],
    "phase": 1
  },
  "world_context": {
    "economy": {"fuel_price": 150},
    "factions": {"ScavengersGuild": 75},
    "recent_events": []
  }
}
```

**Request Schema:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `player_id` | string | Yes | Player identifier |
| `mission_template` | object | Yes | Hybrid mission JSON structure |
| `stage_id` | string | Yes | Stage ID to generate narrative for |
| `player_state` | object | Yes | Current player state (level, missions, phase) |
| `world_context` | object | No | World state context (optional) |

**Response:**

```json
{
  "success": true,
  "narrative": "The abandoned shipyard looms before you, its skeletal frame silhouetted against Earth's pale sky. Decades of neglect have taken their toll—the main entrance is sealed tight, rusted metal warped by time and weather. You recall Engineer Chen's warning about structural instability. The air smells of ozone and decay.",
  "cached": false,
  "generation_time_ms": 1234
}
```

**Response Schema:**

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Always true on success |
| `narrative` | string | Generated narrative text (2-3 paragraphs, present tense, second person) |
| `cached` | boolean | True if from cache, false if freshly generated |
| `generation_time_ms` | integer | Time taken to generate/retrieve (milliseconds) |

**Cache Behavior:**

Cache key format: `story_cache:{mission_id}:{stage_id}:{player_state_hash}`

Player state hash includes:
- Player level
- Current mission
- Completed missions count
- Game phase

Cache TTL: 3600 seconds (1 hour)

**Error Responses:**

**500 Internal Server Error:**
```json
{
  "detail": "Narrative generation failed: Stage stage_1 not found in mission template"
}
```

**Fallback Behavior:**

If LLM generation fails or times out (10 second timeout), returns fallback narrative from template:
- Uses `narrative_structure.setup` + `narrative_structure.conflict`
- Ensures missions always have narrative even if AI service is down

**Example cURL:**

```bash
curl -X POST http://localhost:17011/api/story/generate_narrative \
  -H "Content-Type: application/json" \
  -d '{
    "player_id": "player_123",
    "mission_template": {...},
    "stage_id": "stage_1",
    "player_state": {"level": 5, "current_mission": "tutorial_shipyard"},
    "world_context": null
  }'
```

---

### POST /api/story/generate_outcome

Generate outcome narrative for player choice.

Determines consequence of choice, generates descriptive narrative, and updates player memory with:
- Story flags (e.g., "cautious_explorer")
- Relationship changes with NPCs
- World impact consequences for future callbacks

**Request Body:**

```json
{
  "player_id": "player_123",
  "choice": {
    "choice_id": "investigate_cautiously",
    "type": "exploration",
    "outcome_prompt": "Describe what the player finds when they investigate the sealed door carefully.",
    "paths": {
      "success": {
        "next_stage": "stage_2"
      },
      "partial": {
        "next_stage": "stage_2_alt"
      },
      "failure": {
        "next_stage": "stage_fail"
      }
    },
    "consequence_tracking": {
      "flags": ["cautious_explorer"],
      "relationships": {
        "Engineer_Chen": 5
      },
      "world_impact": "shipyard_stabilized"
    }
  },
  "player_state": {
    "level": 5,
    "current_mission": "tutorial_shipyard"
  },
  "world_context": null
}
```

**Request Schema:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `player_id` | string | Yes | Player identifier |
| `choice` | object | Yes | Choice dict from hybrid mission (includes paths, consequence_tracking) |
| `player_state` | object | Yes | Current player state |
| `world_context` | object | No | World state context (optional) |

**Response:**

```json
{
  "success": true,
  "outcome": "success",
  "narrative": "You approach the sealed door cautiously, examining the rust patterns and structural weak points. Your careful inspection reveals a maintenance hatch hidden beneath debris—a safer entry point that avoids triggering the unstable main entrance.",
  "consequences": {
    "flags": ["cautious_explorer"],
    "relationships": {
      "Engineer_Chen": 5
    },
    "world_impact": "shipyard_stabilized"
  },
  "next_stage": "stage_2",
  "generation_time_ms": 892
}
```

**Response Schema:**

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Always true on success |
| `outcome` | string | Outcome type: "success", "partial", or "failure" |
| `narrative` | string | Generated outcome narrative (2-3 sentences) |
| `consequences` | object | Consequence tracking data |
| `next_stage` | string | Next stage ID based on outcome path |
| `generation_time_ms` | integer | Time taken to generate (milliseconds) |

**Side Effects:**

This endpoint modifies player memory:
- Adds story flags to player (tracked in Redis)
- Updates relationships with NPCs (delta applied)
- Tracks world impact consequences for future callbacks

**Error Responses:**

**500 Internal Server Error:**
```json
{
  "detail": "Outcome generation failed: Invalid choice structure"
}
```

**Fallback Behavior:**

If LLM generation fails or times out:
- Returns generic outcome: "Your choice has consequences."
- Still applies consequence tracking (flags, relationships, world impact)

**Example cURL:**

```bash
curl -X POST http://localhost:17011/api/story/generate_outcome \
  -H "Content-Type: application/json" \
  -d '{
    "player_id": "player_123",
    "choice": {...},
    "player_state": {"level": 5},
    "world_context": null
  }'
```

---

### GET /api/story/memory/{player_id}

Get player memory context.

Returns comprehensive memory data used for contextual narrative generation:
- Recent choices (last N, default 10)
- All relationship scores
- Active (unresolved) consequences
- Story state (current mission, arc, flags)

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `player_id` | string | Yes | Player identifier |

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | integer | 10 | Number of recent choices to return |

**Response:**

```json
{
  "success": true,
  "recent_choices": [
    {
      "choice_id": "investigate_cautiously",
      "mission_id": "tutorial_shipyard",
      "stage_id": "stage_1",
      "timestamp": 1699564320,
      "outcome": "success",
      "consequences": {}
    }
  ],
  "relationships": {
    "Engineer_Chen": 5,
    "Captain_Rodriguez": -10,
    "ScavengersGuild": 25
  },
  "active_consequences": [
    {
      "consequence_id": "shipyard_collapse_risk",
      "choice_id": "ignore_warning",
      "timestamp": 1699564000,
      "resolved": false
    }
  ],
  "story_state": {
    "current_mission": "tutorial_shipyard",
    "story_arc": "earth_exodus",
    "flags": "[\"cautious_explorer\", \"engineer_ally\"]"
  }
}
```

**Response Schema:**

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Always true on success |
| `recent_choices` | array | Last N choices (most recent first) |
| `relationships` | object | NPC/faction name → score (-100 to +100) |
| `active_consequences` | array | Unresolved consequences (for future callbacks) |
| `story_state` | object | Current mission, story arc, flags |

**Error Responses:**

**500 Internal Server Error:**
```json
{
  "detail": "Memory retrieval failed: Redis connection error"
}
```

**Example cURL:**

```bash
# Get last 10 choices (default)
curl http://localhost:17011/api/story/memory/player_123

# Get last 20 choices
curl http://localhost:17011/api/story/memory/player_123?limit=20
```

---

### GET /api/story/mission_pool

Get generic side mission from pool.

Returns mission from lazy queue (Level 3 mission pool). Automatically refills queue when running low (<2 missions).

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `difficulty` | string | "medium" | Mission difficulty: "easy", "medium", "hard", "extreme" |

**Response:**

```json
{
  "success": true,
  "mission": {
    "mission_id": "salvage_1699564320",
    "title": "Salvage Operation",
    "type": "salvage",
    "difficulty": "medium",
    "description": "Recover valuable parts from a derelict ship.",
    "location": "Debris Field",
    "rewards": {
      "credits": 250,
      "items": ["salvaged_parts"]
    }
  },
  "source": "queue",
  "queue_count": 2
}
```

**Response Schema:**

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Always true on success |
| `mission` | object | Mission template (simple, no player context) |
| `source` | string | "queue" (from cache) or "generated" (just created) |
| `queue_count` | integer | Remaining missions in queue after this request |

**Mission Pool Behavior:**

- Maintains 2-3 missions per difficulty in queue
- Generates reactively when queue runs low (<2)
- No scheduled pre-generation (fills only when requested)
- 24 hour TTL (missions can expire)
- Mission types: salvage, exploration, trade

**Error Responses:**

**500 Internal Server Error:**
```json
{
  "detail": "Mission pool error: LLM generation failed"
}
```

**Example cURL:**

```bash
# Get medium difficulty mission (default)
curl http://localhost:17011/api/story/mission_pool

# Get hard difficulty mission
curl "http://localhost:17011/api/story/mission_pool?difficulty=hard"
```

---

### GET /api/story/world_context

Get world state context.

Returns global world state used for contextual narrative generation:
- Economy (if sector specified)
- All faction standings (global power/influence, not player relationships)
- Recent events (last 5, if include_events=true)

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `sector` | string | null | Sector name to get economy for (optional) |
| `include_events` | boolean | true | Include recent world events |

**Response:**

```json
{
  "success": true,
  "context": {
    "economy": {
      "fuel_price": 150,
      "parts_availability": 0.8,
      "trader_count": 5
    },
    "factions": {
      "ScavengersGuild": 75,
      "EarthDefenseForce": 60,
      "MarsTradingConsortium": 45
    },
    "recent_events": [
      {
        "event_id": "earth_exodus_anniversary",
        "title": "50th Anniversary of Exodus",
        "description": "Commemorating 50 years since humanity left Earth.",
        "timestamp": 1699564320,
        "impact": "global"
      }
    ]
  }
}
```

**Response Schema:**

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Always true on success |
| `context` | object | World state data |
| `context.economy` | object | Economy for specified sector (if sector provided) |
| `context.factions` | object | Faction name → standing (0-100, 50=neutral) |
| `context.recent_events` | array | Last 5 events (if include_events=true) |

**World State vs Player Relationships:**

- **World State factions:** Global power/influence (0-100, shared by all players)
- **Player relationships:** Personal reputation with NPCs/factions (-100 to +100, unique per player)

**Error Responses:**

**500 Internal Server Error:**
```json
{
  "detail": "World context error: Redis connection failed"
}
```

**Example cURL:**

```bash
# Get full world context
curl http://localhost:17011/api/story/world_context

# Get context for specific sector
curl "http://localhost:17011/api/story/world_context?sector=earth"

# Get context without events
curl "http://localhost:17011/api/story/world_context?include_events=false"
```

---

### DELETE /api/story/invalidate_cache

Invalidate cached narratives for player/mission.

Call this when:
- Player levels up
- Major story choice made
- Significant state change (phase change, mission completion)

Forces fresh narrative generation on next request.

**Request Body:**

```json
{
  "player_id": "player_123",
  "mission_id": "tutorial_shipyard",
  "player_state": {
    "level": 6,
    "current_mission": "tutorial_shipyard",
    "completed_missions": ["intro_mission"],
    "phase": 1
  }
}
```

**Request Schema:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `player_id` | string | Yes | Player identifier |
| `mission_id` | string | Yes | Mission to invalidate cache for |
| `player_state` | object | Yes | Current player state (for hash calculation) |

**Response:**

```json
{
  "success": true,
  "deleted_count": 3
}
```

**Response Schema:**

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Always true on success |
| `deleted_count` | integer | Number of cache keys deleted |

**Cache Invalidation Pattern:**

Deletes all cache keys matching:
```
story_cache:{mission_id}:*:{player_state_hash}
```

**Error Responses:**

**500 Internal Server Error:**
```json
{
  "detail": "Cache invalidation failed: Redis connection error"
}
```

**Example cURL:**

```bash
curl -X DELETE http://localhost:17011/api/story/invalidate_cache \
  -H "Content-Type: application/json" \
  -d '{
    "player_id": "player_123",
    "mission_id": "tutorial_shipyard",
    "player_state": {"level": 6, "current_mission": "tutorial_shipyard"}
  }'
```

---

## Data Models

### GenerateNarrativeRequest

```python
class GenerateNarrativeRequest(BaseModel):
    player_id: str
    mission_template: Dict[str, Any]
    stage_id: str
    player_state: Dict[str, Any]
    world_context: Optional[Dict[str, Any]] = None
```

### GenerateNarrativeResponse

```python
class GenerateNarrativeResponse(BaseModel):
    success: bool
    narrative: str
    cached: bool
    generation_time_ms: int
```

### GenerateOutcomeRequest

```python
class GenerateOutcomeRequest(BaseModel):
    player_id: str
    choice: Dict[str, Any]
    player_state: Dict[str, Any]
    world_context: Optional[Dict[str, Any]] = None
```

### GenerateOutcomeResponse

```python
class GenerateOutcomeResponse(BaseModel):
    success: bool
    outcome: str
    narrative: str
    consequences: Dict[str, Any]
    next_stage: Optional[str]
    generation_time_ms: int
```

### MemoryContextResponse

```python
class MemoryContextResponse(BaseModel):
    success: bool
    recent_choices: list
    relationships: Dict[str, int]
    active_consequences: list
    story_state: Dict[str, str]
```

### MissionPoolResponse

```python
class MissionPoolResponse(BaseModel):
    success: bool
    mission: Dict[str, Any]
    source: str
    queue_count: int
```

### WorldContextResponse

```python
class WorldContextResponse(BaseModel):
    success: bool
    context: Dict[str, Any]
```

### InvalidateCacheRequest

```python
class InvalidateCacheRequest(BaseModel):
    player_id: str
    mission_id: str
    player_state: Dict[str, Any]
```

### InvalidateCacheResponse

```python
class InvalidateCacheResponse(BaseModel):
    success: bool
    deleted_count: int
```

---

## Caching

### Cache Key Generation

**Format:** `story_cache:{mission_id}:{stage_id}:{player_state_hash}`

**Player State Hash:**

Generated from relevant player state fields (excludes inventory details, exact timestamps):
- Player level
- Current mission
- Completed missions count
- Game phase

Hash algorithm: Python's built-in `hash()` (fast, non-cryptographic, perfect for cache keys)

**Example:** `story_cache:tutorial_shipyard:stage_1:a3f5c9d2e8b1f4a7`

### Cache TTL

**Default:** 3600 seconds (1 hour)

**Rationale:**
- Long enough to avoid redundant LLM calls
- Short enough to reflect player progression
- Balances performance vs freshness

### Cache Invalidation Rules

**Automatic invalidation triggers:**
- Player levels up → invalidate all mission caches
- Major story choice → invalidate current mission cache
- Phase change → invalidate all caches

**Manual invalidation:**
- Call `DELETE /api/story/invalidate_cache` endpoint
- Provide player state to calculate correct hash

### Cache Hit/Miss Metrics

All endpoints return `cached: true/false` and `generation_time_ms`:
- **Cache HIT:** ~10-50ms (Redis lookup)
- **Cache MISS:** ~800-3000ms (LLM generation + Redis write)

Monitor these metrics to optimize cache strategy.

---

## Error Handling

### HTTP Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | Success | Request processed successfully |
| 400 | Bad Request | Invalid difficulty, missing required fields |
| 500 | Internal Server Error | LLM timeout, Redis connection failure |

### Error Response Format

All errors return:
```json
{
  "detail": "Error message describing what went wrong"
}
```

### Common Errors

**LLM Generation Timeout (10 seconds):**
```
Narrative generation failed: LLM generation timed out after 10s
```

**Fallback:** Returns template-based narrative from `narrative_structure`

**Stage Not Found:**
```
Narrative generation failed: Stage stage_1 not found in mission template
```

**Fix:** Ensure `stage_id` exists in `mission_template.stages`

**Redis Connection Error:**
```
Memory retrieval failed: Redis connection error
```

**Fix:** Check Redis is running on configured host/port

**Invalid Player State Hash:**
```
Cache invalidation failed: Invalid player state structure
```

**Fix:** Ensure `player_state` includes level, current_mission, completed_missions, phase

---

## Performance Considerations

### LLM Generation Times

| Operation | Cache HIT | Cache MISS |
|-----------|-----------|------------|
| Generate narrative | ~10-50ms | ~800-2000ms |
| Generate outcome | ~10-50ms | ~600-1500ms |
| Get memory | ~10-30ms | N/A |
| Get world context | ~10-30ms | N/A |

### Rate Limiting

Currently no rate limiting implemented. For production:
- Consider per-player rate limits (e.g., 10 requests/minute)
- Add burst allowance for rapid choice sequences
- Cache aggressive to minimize LLM costs

### Optimization Tips

1. **Use caching aggressively:** Don't invalidate cache unless necessary
2. **Batch memory updates:** Update relationships/consequences in batch after mission completion
3. **Pre-warm world context:** Cache world context separately, refresh every 5 minutes
4. **Monitor generation times:** Alert if >3 seconds (indicates LLM issues)

---

## Related Documentation

- [Dynamic Story Engine](../05-ai-content/story-engine/dynamic-story-engine.md) - Story engine design and architecture
- [Memory Manager Reference](./MEMORY-MANAGER-REFERENCE.md) - Player memory tracking API
- [World State Reference](./WORLD-STATE-REFERENCE.md) - World state management API
- [Hybrid Mission Guide](../05-ai-content/story-engine/hybrid-mission-guide.md) - Creating hybrid missions
- [Godot Story Integration](../05-ai-content/story-engine/godot-story-integration.md) - Frontend integration guide

---

## Changelog

### 2025-11-09
- Initial documentation created
- All 6 endpoints documented with examples
- Added cache behavior, error handling, performance metrics
