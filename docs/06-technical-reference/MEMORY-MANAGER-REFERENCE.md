# Memory Manager Reference

**Complete API reference for player story memory tracking**

## Overview

The Memory Manager tracks player story history to enable contextual storytelling. It maintains player choices, NPC relationships, unresolved consequences, and story state in Redis for fast access during narrative generation.

**Purpose:**
- Provide context for dynamic narrative generation
- Track player choice history (last 100)
- Manage relationships with NPCs and factions
- Track consequences for future story callbacks
- Maintain story state (current mission, arc, flags)

**Storage:** Redis (async client)

**Performance:** O(1) operations using FIFO lists and hashes

---

## Architecture

### Redis Schema

```
player_choices:{player_id}
  Type: List (FIFO, max 100)
  Value: JSON objects (choice_id, mission_id, stage_id, timestamp, outcome)
  TTL: None (persists until explicitly deleted)

player_relationships:{player_id}
  Type: Hash
  Fields: character_id → score (-100 to +100)
  TTL: None

player_consequences:{player_id}
  Type: List
  Value: JSON objects (consequence_id, mission_id, timestamp, resolved)
  TTL: None

player_story:{player_id}
  Type: Hash
  Fields: current_mission, story_arc, flags (JSON array)
  TTL: None
```

### Data Flow

```
Player makes choice
       ↓
StoryEngine.generate_choice_outcome()
       ↓
MemoryManager.add_choice()          → Redis: player_choices:{id}
       ↓
MemoryManager.update_relationship()  → Redis: player_relationships:{id}
       ↓
MemoryManager.track_consequence()    → Redis: player_consequences:{id}
       ↓
StoryEngine.generate_stage_narrative()
       ↓
MemoryManager.get_context()         ← Redis: All player memory
       ↓
Build prompt with context
       ↓
Generate narrative with LLM
```

---

## API Methods

### Initialization

```python
from redis.asyncio import Redis
from memory_manager import MemoryManager

redis_client = Redis(host="localhost", port=6379, db=0, decode_responses=True)
memory = MemoryManager(redis_client)
```

**Parameters:**
- `redis_client` (redis.asyncio.Redis): Async Redis client with `decode_responses=True`

**Class Variables:**
- `max_choices` (int): Maximum choices to keep (default: 100)

---

### add_choice()

Record player choice (maintains FIFO list of last 100).

```python
await memory.add_choice(
    player_id="player_123",
    choice={
        "choice_id": "investigate_cautiously",
        "mission_id": "tutorial_shipyard",
        "stage_id": "stage_1",
        "timestamp": 1699564320,
        "outcome": "success",
        "consequences": {
            "flags": ["cautious_explorer"],
            "relationships": {"Engineer_Chen": 5}
        }
    }
)
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `player_id` | str | Yes | Player identifier |
| `choice` | dict | Yes | Choice data (see structure below) |

**Choice Structure:**
```python
{
    "choice_id": str,          # Choice identifier
    "mission_id": str,         # Mission this choice belongs to
    "stage_id": str,          # Stage this choice occurred in
    "timestamp": int,         # Unix timestamp (auto-added if missing)
    "outcome": str,           # "success", "partial", or "failure"
    "consequences": dict      # Optional: consequence tracking data
}
```

**Returns:** None

**Side Effects:**
- Pushes choice to Redis list (right side = newest)
- Trims list to last 100 choices (FIFO)
- Auto-adds timestamp if not present

**Redis Operations:**
```redis
RPUSH player_choices:player_123 '{"choice_id": "...", ...}'
LTRIM player_choices:player_123 -100 -1
```

**Example:**
```python
choice = {
    "choice_id": "force_door_open",
    "mission_id": "tutorial_shipyard",
    "stage_id": "stage_2",
    "outcome": "partial"
}
await memory.add_choice("player_123", choice)
# Timestamp auto-added, stored in Redis
```

---

### get_choices()

Get recent player choices.

```python
choices = await memory.get_choices(
    player_id="player_123",
    limit=10
)
# Returns: [choice_dict, choice_dict, ...] (most recent first)
```

**Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `player_id` | str | Required | Player identifier |
| `limit` | int | 10 | Number of recent choices to return |

**Returns:** `List[Dict[str, Any]]` - List of choice dicts (most recent first)

**Redis Operations:**
```redis
LRANGE player_choices:player_123 -10 -1  # Get last 10
```

**Notes:**
- Returns up to `limit` choices (may return fewer if player has fewer)
- Automatically reverses list (most recent first)
- Returns empty list if player has no choices

**Example:**
```python
# Get last 5 choices
recent = await memory.get_choices("player_123", limit=5)
for choice in recent:
    print(f"{choice['choice_id']} at {choice['timestamp']}")

# Get all choices (up to 100)
all_choices = await memory.get_choices("player_123", limit=100)
```

---

### update_relationship()

Update relationship score with NPC/faction.

```python
new_score = await memory.update_relationship(
    player_id="player_123",
    character="Engineer_Chen",
    delta=5
)
# Returns: 15 (new score, clamped to -100 to +100)
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `player_id` | str | Yes | Player identifier |
| `character` | str | Yes | NPC or faction name |
| `delta` | int | Yes | Change in relationship (-100 to +100) |

**Returns:** `int` - New relationship score (clamped to -100 to +100)

**Relationship Scale:**
- **-100 to -50:** Hostile (enemy)
- **-49 to -20:** Unfriendly
- **-19 to +19:** Neutral
- **+20 to +49:** Friendly
- **+50 to +100:** Allied (trusted friend)

**Side Effects:**
- Updates relationship in Redis hash
- Clamps new score to [-100, +100]
- Creates relationship entry if doesn't exist (starts at 0)

**Redis Operations:**
```redis
HGET player_relationships:player_123 Engineer_Chen  # Get current
HSET player_relationships:player_123 Engineer_Chen 15  # Update
```

**Type Safety:**
- Handles invalid scores (non-numeric) by resetting to 0
- Logs warning if invalid data found

**Example:**
```python
# Improve relationship
await memory.update_relationship("player_123", "Captain_Rodriguez", 10)

# Damage relationship
await memory.update_relationship("player_123", "Pirate_Leader", -25)

# Large delta is clamped
score = await memory.update_relationship("player_123", "Ally", 500)
# Returns: 100 (clamped to max)
```

---

### get_relationships()

Get all relationship scores for player.

```python
relationships = await memory.get_relationships("player_123")
# Returns: {"Engineer_Chen": 15, "Captain_Rodriguez": -10, ...}
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `player_id` | str | Yes | Player identifier |

**Returns:** `Dict[str, int]` - Dict mapping character names to scores

**Redis Operations:**
```redis
HGETALL player_relationships:player_123
```

**Type Safety:**
- Converts all scores to int
- Skips entries with invalid scores (logs warning)
- Returns empty dict if no relationships exist

**Example:**
```python
relationships = await memory.get_relationships("player_123")
for name, score in relationships.items():
    sentiment = "positive" if score > 20 else "negative" if score < -20 else "neutral"
    print(f"{name}: {score} ({sentiment})")

# Check specific relationship
if "Engineer_Chen" in relationships:
    score = relationships["Engineer_Chen"]
    if score > 50:
        print("Engineer Chen is a trusted ally")
```

---

### track_consequence()

Track consequence for future callback.

```python
await memory.track_consequence(
    player_id="player_123",
    consequence={
        "consequence_id": "shipyard_collapse_risk",
        "mission_id": "tutorial_shipyard",
        "timestamp": 1699564320,
        "can_callback_after": 3,  # missions
        "resolved": False
    }
)
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `player_id` | str | Yes | Player identifier |
| `consequence` | dict | Yes | Consequence data (see structure) |

**Consequence Structure:**
```python
{
    "consequence_id": str,       # Unique consequence identifier
    "mission_id": str,          # Mission that triggered this
    "timestamp": int,           # Unix timestamp (auto-added if missing)
    "can_callback_after": int,  # Optional: missions before callback eligible
    "resolved": bool            # Auto-set to False if missing
}
```

**Returns:** None

**Side Effects:**
- Adds consequence to Redis list
- Auto-adds timestamp if missing
- Auto-sets `resolved: False` if missing

**Redis Operations:**
```redis
RPUSH player_consequences:player_123 '{"consequence_id": "...", ...}'
```

**Use Cases:**
- Track major story decisions (e.g., "saved_scientist")
- Set up future callbacks (e.g., "station_collapse_risk")
- Enable branching narrative paths
- Create delayed consequences (e.g., faction retaliation)

**Example:**
```python
# Track major decision
await memory.track_consequence("player_123", {
    "consequence_id": "saved_scientist",
    "mission_id": "rescue_mission",
    "can_callback_after": 2
})

# Track world impact
await memory.track_consequence("player_123", {
    "consequence_id": "reactor_destabilized",
    "mission_id": "station_crisis",
    "can_callback_after": 0  # Immediate consequences
})
```

---

### get_active_consequences()

Get unresolved consequences.

```python
consequences = await memory.get_active_consequences("player_123")
# Returns: [consequence_dict, consequence_dict, ...]
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `player_id` | str | Yes | Player identifier |

**Returns:** `List[Dict[str, Any]]` - List of unresolved consequence dicts

**Redis Operations:**
```redis
LRANGE player_consequences:player_123 0 -1  # Get all
```

**Filtering:**
- Only returns consequences with `resolved: False`
- Maintains chronological order (oldest first)

**Example:**
```python
active = await memory.get_active_consequences("player_123")
for cons in active:
    print(f"Unresolved: {cons['consequence_id']} from {cons['mission_id']}")

    # Check if eligible for callback
    if cons.get("can_callback_after", 0) == 0:
        print("  → Ready for immediate callback")

# Check for specific consequence
reactor_unstable = any(
    c["consequence_id"] == "reactor_destabilized"
    for c in active
)
if reactor_unstable:
    print("Warning: Reactor still unstable!")
```

---

### resolve_consequence()

Mark consequence as resolved.

```python
resolved = await memory.resolve_consequence(
    player_id="player_123",
    consequence_id="shipyard_collapse_risk"
)
# Returns: True if found and resolved, False if not found
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `player_id` | str | Yes | Player identifier |
| `consequence_id` | str | Yes | Consequence to resolve |

**Returns:** `bool` - True if found and resolved, False if not found

**Side Effects:**
- Marks consequence as `resolved: True`
- Preserves consequence in list (for history)
- Uses Redis pipeline for atomic update

**Redis Operations:**
```redis
LRANGE player_consequences:player_123 0 -1  # Get all
DEL player_consequences:player_123          # Clear list
RPUSH player_consequences:player_123 ...   # Rebuild with update
```

**Atomic Update:**
Uses Redis pipeline to ensure atomic operation (prevents race conditions)

**Example:**
```python
# Resolve after callback mission
if await memory.resolve_consequence("player_123", "reactor_destabilized"):
    print("Reactor crisis resolved!")
else:
    print("Consequence not found (already resolved or never existed)")

# Check before resolving
active = await memory.get_active_consequences("player_123")
if "station_collapse" in [c["consequence_id"] for c in active]:
    # Present callback mission
    present_callback_mission("station_collapse")
    # After mission completion:
    await memory.resolve_consequence("player_123", "station_collapse")
```

---

### update_story_state()

Update player story state fields.

```python
await memory.update_story_state(
    player_id="player_123",
    current_mission="tutorial_shipyard",
    story_arc="earth_exodus",
    custom_field="custom_value"
)
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `player_id` | str | Yes | Player identifier |
| `**kwargs` | Any | Yes | Fields to update (key-value pairs) |

**Returns:** None

**Side Effects:**
- Updates specified fields in Redis hash
- Converts all values to strings
- Creates fields if they don't exist

**Redis Operations:**
```redis
HSET player_story:player_123 current_mission "tutorial_shipyard"
HSET player_story:player_123 story_arc "earth_exodus"
```

**Common Fields:**
- `current_mission` - Current mission ID
- `story_arc` - Current story arc name
- `flags` - JSON array of story flags (use `add_story_flag()` instead)

**Example:**
```python
# Update current mission
await memory.update_story_state(
    "player_123",
    current_mission="rescue_mission",
    story_arc="mars_conflict"
)

# Add custom tracking
await memory.update_story_state(
    "player_123",
    last_visited_sector="mars_orbit",
    reputation_tier="veteran"
)
```

---

### get_story_state()

Get player story state.

```python
state = await memory.get_story_state("player_123")
# Returns: {"current_mission": "tutorial_shipyard", "story_arc": "earth_exodus", ...}
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `player_id` | str | Yes | Player identifier |

**Returns:** `Dict[str, str]` - Dict of story state fields

**Redis Operations:**
```redis
HGETALL player_story:player_123
```

**Example:**
```python
state = await memory.get_story_state("player_123")
current_mission = state.get("current_mission", "none")
story_arc = state.get("story_arc", "main")

print(f"Mission: {current_mission}, Arc: {story_arc}")

# Check if player has completed arc
if state.get("earth_exodus_complete") == "true":
    print("Earth Exodus arc completed!")
```

---

### add_story_flag()

Add story flag to player.

```python
await memory.add_story_flag("player_123", "cautious_explorer")
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `player_id` | str | Yes | Player identifier |
| `flag` | str | Yes | Flag to add (e.g., "cautious_explorer") |

**Returns:** None

**Side Effects:**
- Adds flag to player's flags array (stored as JSON in Redis)
- Prevents duplicates (only adds if not already present)

**Redis Operations:**
```redis
HGET player_story:player_123 flags           # Get current flags
HSET player_story:player_123 flags "[...]"  # Update with new flag
```

**Common Flags:**
- `cautious_explorer` - Player tends to investigate carefully
- `risk_taker` - Player takes bold risks
- `engineer_ally` - Ally with Engineer NPCs
- `diplomat` - Resolves conflicts peacefully
- `combat_veteran` - Experienced in combat

**Example:**
```python
# Add personality flag
await memory.add_story_flag("player_123", "cautious_explorer")

# Add achievement flag
await memory.add_story_flag("player_123", "saved_chen")

# Add progression flag
await memory.add_story_flag("player_123", "phase_1_complete")
```

---

### has_story_flag()

Check if player has story flag.

```python
is_cautious = await memory.has_story_flag("player_123", "cautious_explorer")
# Returns: True if player has flag
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `player_id` | str | Yes | Player identifier |
| `flag` | str | Yes | Flag to check |

**Returns:** `bool` - True if player has flag

**Redis Operations:**
```redis
HGET player_story:player_123 flags  # Get flags array
```

**Example:**
```python
# Check personality flags
if await memory.has_story_flag("player_123", "risk_taker"):
    # Present risky option
    present_risky_choice()

# Check progression
if not await memory.has_story_flag("player_123", "tutorial_complete"):
    # Show tutorial
    show_tutorial()

# Check multiple flags
is_engineer_ally = await memory.has_story_flag("player_123", "engineer_ally")
saved_chen = await memory.has_story_flag("player_123", "saved_chen")
if is_engineer_ally and saved_chen:
    # Special dialogue option
    enable_special_dialogue()
```

---

### get_context()

Build comprehensive context for narrative generation.

```python
context = await memory.get_context(
    player_id="player_123",
    limit=10
)
```

**Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `player_id` | str | Required | Player identifier |
| `limit` | int | 10 | Number of recent choices to include |

**Returns:** `Dict[str, Any]` - Context dict with all player memory data

**Response Structure:**
```python
{
    "recent_choices": [        # Last N choices (most recent first)
        {"choice_id": "...", "mission_id": "...", ...},
        ...
    ],
    "relationships": {         # All relationships
        "Engineer_Chen": 15,
        "Captain_Rodriguez": -10,
        ...
    },
    "active_consequences": [   # Unresolved consequences
        {"consequence_id": "...", "mission_id": "...", ...},
        ...
    ],
    "story_state": {          # Story state fields
        "current_mission": "tutorial_shipyard",
        "story_arc": "earth_exodus",
        "flags": "[\"cautious_explorer\", ...]"
    }
}
```

**Side Effects:** None (read-only)

**Performance:** 4 Redis operations (LRANGE, HGETALL, LRANGE, HGETALL)

**Example:**
```python
# Get full context for prompt building
context = await memory.get_context("player_123", limit=10)

# Use in prompt
prompt = f"""
Player History:
{len(context['recent_choices'])} recent choices
{len(context['relationships'])} relationships
{len(context['active_consequences'])} active consequences

Recent Choices:
{context['recent_choices'][:3]}

Relationships:
{context['relationships']}
"""

# Check for specific patterns
cautious = any("cautious" in c.get("choice_id", "") for c in context["recent_choices"])
if cautious and context["relationships"].get("Engineer_Chen", 0) > 20:
    prompt += "\nPlayer is cautious and allies with Engineer Chen."
```

---

## Redis Schema Details

### player_choices:{player_id}

**Type:** List (FIFO)

**Structure:**
```
[
  '{"choice_id": "investigate", "mission_id": "tutorial", "timestamp": 1699564320, ...}',
  '{"choice_id": "repair", "mission_id": "tutorial", "timestamp": 1699564350, ...}',
  ...
]
```

**Operations:**
- `RPUSH` - Add new choice (right = newest)
- `LTRIM` - Maintain max 100 choices
- `LRANGE` - Get recent choices

**TTL:** None (persists)

**Max Size:** 100 entries (FIFO)

---

### player_relationships:{player_id}

**Type:** Hash

**Structure:**
```
{
  "Engineer_Chen": "15",
  "Captain_Rodriguez": "-10",
  "ScavengersGuild": "25",
  ...
}
```

**Operations:**
- `HSET` - Update relationship
- `HGET` - Get single relationship
- `HGETALL` - Get all relationships

**TTL:** None (persists)

**Value Range:** -100 to +100 (stored as string, converted to int)

---

### player_consequences:{player_id}

**Type:** List

**Structure:**
```
[
  '{"consequence_id": "reactor_unstable", "mission_id": "crisis", "resolved": false, ...}',
  '{"consequence_id": "saved_chen", "mission_id": "rescue", "resolved": true, ...}',
  ...
]
```

**Operations:**
- `RPUSH` - Add consequence
- `LRANGE` - Get all consequences
- Pipeline: `DEL` + `RPUSH` (to update resolved status)

**TTL:** None (persists)

**Filtering:** Filter `resolved: false` in application code

---

### player_story:{player_id}

**Type:** Hash

**Structure:**
```
{
  "current_mission": "tutorial_shipyard",
  "story_arc": "earth_exodus",
  "flags": "[\"cautious_explorer\", \"saved_chen\"]",
  "custom_field": "custom_value"
}
```

**Operations:**
- `HSET` - Update field
- `HGET` - Get single field
- `HGETALL` - Get all fields

**TTL:** None (persists)

**Special Fields:**
- `flags` - JSON array of strings

---

## Usage Patterns

### Pattern 1: Record Choice and Update Memory

```python
# After player makes choice
choice_data = {
    "choice_id": "investigate_cautiously",
    "mission_id": "tutorial_shipyard",
    "stage_id": "stage_1",
    "outcome": "success"
}
await memory.add_choice(player_id, choice_data)

# Update relationships from consequences
await memory.update_relationship(player_id, "Engineer_Chen", 5)

# Track world impact
await memory.track_consequence(player_id, {
    "consequence_id": "shipyard_stabilized",
    "mission_id": "tutorial_shipyard"
})

# Add personality flag
await memory.add_story_flag(player_id, "cautious_explorer")
```

### Pattern 2: Build Context for Narrative Generation

```python
# Get full context
context = await memory.get_context(player_id, limit=10)

# Build prompt with context
prompt = build_narrative_prompt(
    mission_template=mission_json,
    stage_id=stage_id,
    player_context=context,
    world_context=world_state
)

# Generate narrative with LLM
narrative = await llm.generate(prompt)
```

### Pattern 3: Check for Callback Eligibility

```python
# Get active consequences
active = await memory.get_active_consequences(player_id)

# Filter for eligible callbacks
eligible = [
    c for c in active
    if c.get("can_callback_after", 0) == 0 or
       player_missions_since(c["mission_id"]) >= c["can_callback_after"]
]

# Present callback mission
if eligible:
    callback = eligible[0]
    present_callback_mission(callback["consequence_id"])

    # After mission completion
    await memory.resolve_consequence(player_id, callback["consequence_id"])
```

### Pattern 4: Personality-Driven Narrative

```python
# Check personality flags
is_cautious = await memory.has_story_flag(player_id, "cautious_explorer")
is_risk_taker = await memory.has_story_flag(player_id, "risk_taker")

# Get relationships
relationships = await memory.get_relationships(player_id)
engineer_ally = relationships.get("Engineer_Chen", 0) > 50

# Customize narrative based on personality
if is_cautious and engineer_ally:
    prompt += "\nPlayer is cautious and trusts Engineer Chen. Reference their careful approach."
elif is_risk_taker:
    prompt += "\nPlayer is bold and takes risks. Reference their daring choices."
```

---

## Performance

### Time Complexity

| Operation | Complexity | Notes |
|-----------|-----------|-------|
| `add_choice()` | O(1) | RPUSH + LTRIM |
| `get_choices()` | O(N) | N = limit, max 100 |
| `update_relationship()` | O(1) | HGET + HSET |
| `get_relationships()` | O(N) | N = num relationships |
| `track_consequence()` | O(1) | RPUSH |
| `get_active_consequences()` | O(N) | N = num consequences |
| `resolve_consequence()` | O(N) | N = num consequences (pipeline) |
| `add_story_flag()` | O(N) | N = num flags |
| `has_story_flag()` | O(N) | N = num flags |
| `get_context()` | O(N) | 4 Redis ops, N = largest list |

### Memory Usage

**Per Player:**
- **Choices:** ~100KB (100 choices × ~1KB each)
- **Relationships:** ~1-10KB (10-100 relationships)
- **Consequences:** ~5-20KB (5-20 consequences)
- **Story State:** ~1-5KB (few fields)

**Total per player:** ~100-150KB

**For 1000 players:** ~100-150MB

### Optimization Tips

1. **Use `get_context()` once per narrative generation** (don't call individual methods)
2. **Batch relationship updates** (use pipeline for multiple updates)
3. **Limit choices history** (100 is sufficient for context, prevents unbounded growth)
4. **Prune resolved consequences** (periodically clean up old resolved consequences)
5. **Cache context** (cache context for duration of mission stage)

---

## Related Documentation

- [Story API Reference](./STORY-API-REFERENCE.md) - Complete API documentation
- [Story Engine README](../05-ai-content/story-engine/README.md) - Story engine overview
- [World State Reference](./WORLD-STATE-REFERENCE.md) - World state management API
- [Dynamic Story Engine Spec](../05-ai-content/story-engine/dynamic-story-engine.md) - Design document

---

## Changelog

### 2025-11-09
- Initial documentation created
- Complete API reference with all methods
- Redis schema documentation
- Usage patterns and examples
- Performance analysis

### 2025-11-08
- Memory Manager implemented
- Type safety added (handles invalid Redis data)
- FIFO queue for choices
- Relationship clamping (-100 to +100)
