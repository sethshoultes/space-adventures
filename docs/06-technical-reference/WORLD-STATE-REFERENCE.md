# World State Reference

**Complete API reference for global game state management**

## Overview

The World State Manager tracks global game state that evolves based on player actions and major events. Unlike player-specific memory (relationships, choices), world state is shared across all players and represents the broader game universe.

**Purpose:**
- Track economy per sector (prices, availability)
- Manage faction standings (global power/influence)
- Maintain event timeline (major world events)
- Provide context for dynamic narrative generation
- Enable world-responsive storytelling

**Storage:** Redis (async client)

**Scope:** Global (shared by all players)

---

## Architecture

### Redis Schema

```
world_economy:{sector}
  Type: Hash
  Fields: fuel_price, parts_availability, trader_count, etc.
  TTL: 7 days (economy changes slowly)

world_factions
  Type: Hash
  Fields: faction_name → standing (0-100)
  TTL: None

world_events
  Type: Sorted Set (sorted by timestamp)
  Members: JSON event objects
  Score: Unix timestamp
  TTL: 30 days
```

### World State vs Player Memory

| Aspect | World State | Player Memory |
|--------|-------------|---------------|
| **Scope** | Global (all players) | Per-player |
| **Storage** | `world_*` keys | `player_*:{id}` keys |
| **Example** | ScavengersGuild has 75% power | Player has +25 relationship with ScavengersGuild |
| **Purpose** | Broad context (economy, faction power) | Personal context (choices, relationships) |
| **Updates** | Major events, admin actions | Player choices |

**Key Difference:**
- **World factions:** Global power/influence (0-100, neutral=50)
- **Player relationships:** Personal reputation (-100 to +100, neutral=0)

### Data Flow

```
Player completes major mission
         ↓
Mission has world_impact flag
         ↓
WorldState.update_faction()     → Redis: world_factions
         ↓
WorldState.add_event()          → Redis: world_events
         ↓
StoryEngine.generate_narrative()
         ↓
WorldState.get_world_context()  ← Redis: Economy + Factions + Events
         ↓
Include in narrative prompt
         ↓
Generate contextual narrative
```

---

## API Methods

### Initialization

```python
from redis.asyncio import Redis
from world_state import WorldState

redis_client = Redis(host="localhost", port=6379, db=0, decode_responses=True)
world_state = WorldState(redis_client)
```

**Parameters:**
- `redis_client` (redis.asyncio.Redis): Async Redis client with `decode_responses=True`

---

### update_economy()

Update economy for a sector.

```python
await world_state.update_economy(
    sector="earth",
    updates={
        "fuel_price": 150,
        "parts_availability": 0.8,
        "trader_count": 5
    }
)
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `sector` | str | Yes | Sector name (e.g., "earth", "mars_orbit", "asteroid_belt") |
| `updates` | dict | Yes | Dict of economic values to update |

**Common Economic Fields:**
- `fuel_price` (int): Credits per unit of fuel
- `parts_availability` (float): 0.0-1.0 (0=none, 1=abundant)
- `trader_count` (int): Number of active traders in sector
- `market_stability` (str): "stable", "volatile", "booming", "crash"
- `supply_scarcity` (float): 0.0-1.0 (0=abundant, 1=scarce)

**Returns:** None

**Side Effects:**
- Updates specified fields in Redis hash
- Sets TTL to 7 days (economy changes slowly)
- Converts values to strings for storage

**Redis Operations:**
```redis
HSET world_economy:earth fuel_price "150"
HSET world_economy:earth parts_availability "0.8"
EXPIRE world_economy:earth 604800  # 7 days
```

**Example:**
```python
# Market boom after major discovery
await world_state.update_economy("mars_orbit", {
    "fuel_price": 80,  # Lower prices
    "parts_availability": 0.9,  # More available
    "market_stability": "booming",
    "trader_count": 12
})

# Market crash after disaster
await world_state.update_economy("earth", {
    "fuel_price": 300,  # Higher prices
    "parts_availability": 0.2,  # Scarce
    "market_stability": "crash",
    "trader_count": 2
})
```

---

### get_economy()

Get economy state for a sector.

```python
economy = await world_state.get_economy("earth")
# Returns: {"fuel_price": 150, "parts_availability": 0.8, ...}
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `sector` | str | Yes | Sector name |

**Returns:** `Dict[str, Any]` - Dict of economic values (empty if not set)

**Type Conversion:**
- Attempts to convert to int/float
- Falls back to string if conversion fails
- Logs warning for invalid values

**Redis Operations:**
```redis
HGETALL world_economy:earth
```

**Example:**
```python
economy = await world_state.get_economy("earth")
if economy:
    fuel_price = economy.get("fuel_price", 100)
    availability = economy.get("parts_availability", 0.5)

    if fuel_price > 200:
        print("Warning: Fuel prices are high!")
    if availability < 0.3:
        print("Warning: Parts are scarce!")
else:
    print("No economy data for this sector")

# Use in narrative prompt
if economy.get("market_stability") == "crash":
    prompt += "\nThe market has crashed. Traders are scarce. Prices are inflated."
```

---

### update_faction()

Update global faction standing (power/influence).

```python
await world_state.update_faction(
    faction="ScavengersGuild",
    standing=75
)
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `faction` | str | Yes | Faction name |
| `standing` | int | Yes | Power/influence level (0-100) |

**Standing Scale:**
- **0-20:** Collapsing (faction losing power)
- **21-40:** Weakened
- **41-60:** Neutral/Stable (50 = default)
- **61-80:** Growing power
- **81-100:** Dominant (major influence)

**Returns:** None

**Side Effects:**
- Updates faction standing in Redis hash
- Clamps value to [0, 100]

**Redis Operations:**
```redis
HSET world_factions ScavengersGuild "75"
```

**Note:** This is global faction power, not player relationship. For player relationships, use `MemoryManager.update_relationship()`.

**Example:**
```python
# Faction gains power after successful campaign
await world_state.update_faction("EarthDefenseForce", 85)

# Faction loses power after major defeat
await world_state.update_faction("PirateConsortium", 35)

# New faction emerges
await world_state.update_faction("MartianRebels", 60)
```

---

### get_faction()

Get global faction standing.

```python
standing = await world_state.get_faction("ScavengersGuild")
# Returns: 75 (or 50 if not set)
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `faction` | str | Yes | Faction name |

**Returns:** `int` - Standing (0-100), or 50 if not set (neutral default)

**Type Safety:**
- Returns 50 (neutral) if faction not found
- Returns 50 if value is invalid (logs warning)

**Redis Operations:**
```redis
HGET world_factions ScavengersGuild
```

**Example:**
```python
standing = await world_state.get_faction("ScavengersGuild")
if standing > 70:
    print("ScavengersGuild is powerful and influential")
elif standing < 30:
    print("ScavengersGuild is weak and struggling")
else:
    print("ScavengersGuild has moderate influence")

# Use in mission selection
if standing < 40:
    # Faction too weak to offer major missions
    disable_faction_missions("ScavengersGuild")
```

---

### get_all_factions()

Get all faction standings.

```python
factions = await world_state.get_all_factions()
# Returns: {"ScavengersGuild": 75, "EarthDefenseForce": 60, ...}
```

**Parameters:** None

**Returns:** `Dict[str, int]` - Dict mapping faction names to standings

**Type Safety:**
- Converts all standings to int
- Defaults to 50 (neutral) for invalid values
- Logs warnings for invalid data

**Redis Operations:**
```redis
HGETALL world_factions
```

**Example:**
```python
factions = await world_state.get_all_factions()

# Find most powerful faction
most_powerful = max(factions.items(), key=lambda x: x[1])
print(f"Most powerful: {most_powerful[0]} ({most_powerful[1]})")

# Check faction balance
dominant = [name for name, standing in factions.items() if standing > 80]
if dominant:
    print(f"Dominant factions: {', '.join(dominant)}")

# Use in world context
context = {
    "dominant_faction": most_powerful[0],
    "faction_count": len(factions),
    "power_distribution": factions
}
```

---

### add_event()

Add event to global timeline.

```python
await world_state.add_event({
    "event_id": "earth_exodus_anniversary",
    "title": "50th Anniversary of Exodus",
    "description": "Commemorating 50 years since humanity left Earth.",
    "timestamp": 1699564320,
    "impact": "global",
    "affected_factions": ["EarthDefenseForce", "ScavengersGuild"]
})
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `event` | dict | Yes | Event data (see structure) |

**Event Structure:**
```python
{
    "event_id": str,              # Unique event identifier
    "title": str,                 # Event title
    "description": str,           # Event description
    "timestamp": int,             # Unix timestamp (auto-added if missing)
    "impact": str,                # "global", "regional", "local"
    "affected_factions": list,    # Optional: factions affected
    "sector": str                 # Optional: sector where event occurred
}
```

**Returns:** None

**Side Effects:**
- Adds event to sorted set (sorted by timestamp)
- Auto-adds timestamp if missing
- Sets TTL to 30 days

**Redis Operations:**
```redis
ZADD world_events 1699564320 '{"event_id": "...", ...}'
EXPIRE world_events 2592000  # 30 days
```

**Use Cases:**
- Major story events (exodus anniversary, faction wars)
- World-changing player actions (reactor meltdown, treaty signed)
- Scheduled events (holiday, memorial)

**Example:**
```python
# Major faction event
await world_state.add_event({
    "event_id": "mars_trade_war",
    "title": "Mars Trade War Begins",
    "description": "Conflict erupts over trade routes to Mars.",
    "impact": "regional",
    "affected_factions": ["MarsTradingConsortium", "PirateConsortium"],
    "sector": "mars_orbit"
})

# Player-triggered event
await world_state.add_event({
    "event_id": "reactor_crisis_resolved",
    "title": "Station Reactor Stabilized",
    "description": "Player prevented catastrophic reactor failure.",
    "impact": "local",
    "sector": "earth"
})
```

---

### get_recent_events()

Get recent world events.

```python
events = await world_state.get_recent_events(limit=10)
# Returns: [event_dict, event_dict, ...] (most recent first)
```

**Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | int | 10 | Max number of events to return |

**Returns:** `List[Dict[str, Any]]` - List of event dicts (most recent first)

**Redis Operations:**
```redis
ZREVRANGE world_events 0 9  # Get last 10 (highest scores = newest)
```

**Example:**
```python
# Get last 5 events
recent = await world_state.get_recent_events(limit=5)
for event in recent:
    print(f"{event['title']} - {event['description']}")

# Check for specific event type
has_war = any(
    "war" in event["title"].lower()
    for event in recent
)
if has_war:
    prompt += "\nThe galaxy is at war. Tensions are high."

# Filter events by sector
earth_events = [
    e for e in recent
    if e.get("sector") == "earth"
]
if earth_events:
    print(f"Recent Earth events: {len(earth_events)}")
```

---

### get_world_context()

Build comprehensive world context for narrative generation.

```python
context = await world_state.get_world_context(
    sector="earth",
    include_events=True
)
```

**Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `sector` | str | None | Specific sector to include economy for (optional) |
| `include_events` | bool | True | Include recent events (default True) |

**Returns:** `Dict[str, Any]` - Context dict

**Response Structure:**
```python
{
    "economy": {                    # If sector specified
        "fuel_price": 150,
        "parts_availability": 0.8,
        "trader_count": 5
    },
    "factions": {                   # Always included
        "ScavengersGuild": 75,
        "EarthDefenseForce": 60,
        "MarsTradingConsortium": 45
    },
    "recent_events": [              # If include_events=True
        {
            "event_id": "earth_exodus_anniversary",
            "title": "50th Anniversary of Exodus",
            "description": "...",
            "timestamp": 1699564320,
            "impact": "global"
        }
    ]
}
```

**Redis Operations:**
```redis
HGETALL world_economy:earth      # If sector provided
HGETALL world_factions           # Always
ZREVRANGE world_events 0 4       # If include_events=True (last 5)
```

**Performance:** 2-3 Redis operations (depending on parameters)

**Example:**
```python
# Get full context for mission
context = await world_state.get_world_context(
    sector="earth",
    include_events=True
)

# Build narrative prompt with context
prompt = f"""
WORLD STATE:
Economy (Earth):
- Fuel Price: {context['economy'].get('fuel_price', 100)} credits
- Parts Available: {context['economy'].get('parts_availability', 0.5) * 100}%

Faction Power:
{'\n'.join(f'- {name}: {standing}' for name, standing in context['factions'].items())}

Recent Events:
{'\n'.join(f'- {e["title"]}' for e in context['recent_events'])}
"""

# Check for world conditions
if context['economy'].get('fuel_price', 100) > 200:
    prompt += "\nFuel is expensive due to supply shortages."

dominant_factions = [
    name for name, standing in context['factions'].items()
    if standing > 80
]
if dominant_factions:
    prompt += f"\n{dominant_factions[0]} dominates the region."

# Use without sector (no economy data)
global_context = await world_state.get_world_context()
# Returns: {"factions": {...}, "recent_events": [...]}
```

---

## Usage Patterns

### Pattern 1: Update World After Major Mission

```python
# Player completes mission with world impact
mission_complete = {
    "mission_id": "earth_defense",
    "world_impact": {
        "faction": "EarthDefenseForce",
        "standing_delta": 10,
        "event": {
            "event_id": "earth_defense_victory",
            "title": "Earth Defense Victorious",
            "description": "Player helped repel pirate attack.",
            "impact": "regional"
        }
    }
}

# Update faction standing
current = await world_state.get_faction("EarthDefenseForce")
await world_state.update_faction("EarthDefenseForce", current + 10)

# Add event to timeline
await world_state.add_event(mission_complete["world_impact"]["event"])

# Update economy (fewer pirates = better trade)
await world_state.update_economy("earth", {
    "trader_count": 8,  # More traders feel safe
    "market_stability": "stable"
})
```

### Pattern 2: Generate Contextual Narrative

```python
# Get world context for mission
context = await world_state.get_world_context(
    sector=mission_location,
    include_events=True
)

# Build prompt with world state
prompt = f"""
Generate narrative for mission stage.

WORLD CONTEXT:
{json.dumps(context, indent=2)}

INSTRUCTIONS:
Reference current economic conditions.
Mention dominant factions.
Reference recent events if relevant.
"""

# Generate narrative
narrative = await llm.generate(prompt)
```

### Pattern 3: Check World Conditions Before Mission

```python
# Before presenting mission to player
economy = await world_state.get_economy("mars_orbit")
factions = await world_state.get_all_factions()

# Check if mission is feasible
fuel_price = economy.get("fuel_price", 100)
if fuel_price > 300:
    # Mission requires travel, too expensive
    disable_mission("long_distance_trade")

# Check faction power
mars_traders = factions.get("MarsTradingConsortium", 50)
if mars_traders < 30:
    # Faction too weak to offer missions
    disable_faction_missions("MarsTradingConsortium")

# Check recent events
events = await world_state.get_recent_events(limit=5)
has_war = any("war" in e["title"].lower() for e in events)
if has_war:
    # Enable combat missions
    enable_combat_missions()
```

### Pattern 4: Dynamic Economy System

```python
import asyncio

async def simulate_economy():
    """Background task to simulate economy changes."""
    while True:
        # Get current economy
        earth_economy = await world_state.get_economy("earth")
        fuel_price = earth_economy.get("fuel_price", 100)

        # Simulate price fluctuation (±5%)
        import random
        delta = random.randint(-5, 5)
        new_price = max(50, min(300, fuel_price + delta))

        await world_state.update_economy("earth", {
            "fuel_price": new_price
        })

        # Wait 1 hour
        await asyncio.sleep(3600)

# Run in background
asyncio.create_task(simulate_economy())
```

---

## Redis Schema Details

### world_economy:{sector}

**Type:** Hash

**Structure:**
```
{
  "fuel_price": "150",
  "parts_availability": "0.8",
  "trader_count": "5",
  "market_stability": "stable"
}
```

**Operations:**
- `HSET` - Update fields
- `HGETALL` - Get all fields
- `EXPIRE` - Set TTL (7 days)

**TTL:** 7 days (economy changes slowly)

**Common Sectors:**
- `earth` - Earth surface and orbit
- `mars_orbit` - Mars orbit
- `asteroid_belt` - Main asteroid belt
- `outer_rim` - Outer solar system

---

### world_factions

**Type:** Hash

**Structure:**
```
{
  "ScavengersGuild": "75",
  "EarthDefenseForce": "60",
  "MarsTradingConsortium": "45",
  "PirateConsortium": "30"
}
```

**Operations:**
- `HSET` - Update faction
- `HGET` - Get single faction
- `HGETALL` - Get all factions

**TTL:** None (persists)

**Value Range:** 0-100 (stored as string, converted to int)

**Common Factions:**
- `ScavengersGuild` - Salvagers and traders
- `EarthDefenseForce` - Military/security
- `MarsTradingConsortium` - Mars merchants
- `PirateConsortium` - Organized pirates
- `ScienceCollective` - Researchers

---

### world_events

**Type:** Sorted Set (scored by timestamp)

**Structure:**
```
{
  '{"event_id": "exodus_anniversary", "title": "...", ...}': 1699564320,
  '{"event_id": "trade_war", "title": "...", ...}': 1699564350,
  ...
}
```

**Operations:**
- `ZADD` - Add event (score = timestamp)
- `ZREVRANGE` - Get recent events (highest scores = newest)
- `EXPIRE` - Set TTL (30 days)

**TTL:** 30 days (old events pruned)

**Sorting:** By timestamp (newest first when using `ZREVRANGE`)

---

## Performance

### Time Complexity

| Operation | Complexity | Notes |
|-----------|-----------|-------|
| `update_economy()` | O(N) | N = fields updated |
| `get_economy()` | O(N) | N = fields in hash |
| `update_faction()` | O(1) | HSET |
| `get_faction()` | O(1) | HGET |
| `get_all_factions()` | O(N) | N = num factions |
| `add_event()` | O(log N) | N = num events (sorted set) |
| `get_recent_events()` | O(log N + M) | N = num events, M = limit |
| `get_world_context()` | O(N) | 2-3 Redis ops, N = largest collection |

### Memory Usage

**Global Data:**
- **Economy (per sector):** ~1-2KB
- **Factions:** ~1-5KB (10-50 factions)
- **Events:** ~50-200KB (100-1000 events)

**Total:** ~50-500KB (shared by all players)

**TTL Strategy:**
- Economy: 7 days (changes slowly)
- Factions: None (manual updates only)
- Events: 30 days (auto-prune old events)

### Optimization Tips

1. **Cache world context** (refresh every 5 minutes, not per request)
2. **Batch economy updates** (update multiple fields at once)
3. **Limit event queries** (default 5 events, rarely need more)
4. **Use TTL** (automatic cleanup reduces memory usage)
5. **Monitor faction count** (too many factions = slower `get_all_factions()`)

---

## Related Documentation

- [Story API Reference](./STORY-API-REFERENCE.md) - Complete API documentation
- [Story Engine README](../05-ai-content/story-engine/README.md) - Story engine overview
- [Memory Manager Reference](./MEMORY-MANAGER-REFERENCE.md) - Player memory tracking API
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
- World State Manager implemented
- Type safety added (handles invalid Redis data)
- Economy TTL (7 days)
- Event TTL (30 days)
- Faction standing clamping (0-100)
