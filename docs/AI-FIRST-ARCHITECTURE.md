# AI-First Architecture Guide

**Understanding how Space Adventures uses AI-first patterns for intelligent background processing**

Last Updated: 2025-01-08

---

## Overview

Space Adventures implements **AI-first architecture** - a pattern where AI runs proactively in the background, making decisions and generating content before it's requested. This eliminates waiting time and creates a more responsive, intelligent game experience.

## What is AI-First Architecture?

Traditional approach:
```
User requests content → AI generates (2-3s wait) → User receives content
```

AI-First approach:
```
Background: AI pre-generates content → Stores in queue
User requests content → Instant delivery (< 10ms) → Background replenishes queue
```

## Implementation Patterns

### 1. Event-Driven (Your Base Pattern)

**What it does:** AI responds when triggered by specific events

**Current implementation:**
```
Player action (Godot) → HTTP request → FastAPI → AI Service → Response
```

**Files:**
- `godot/scripts/autoload/ai_service.gd` - Godot HTTP client
- `python/ai-service/src/api/missions.py` - Event-driven endpoints

**Example use cases:**
- Player requests new mission → Generate immediately
- NPC conversation → Generate dialogue on-demand
- Player makes choice → Generate consequences

**Pros:**
- Simple to implement
- Contextual to player's current state
- Predictable behavior

**Cons:**
- Player waits for AI (1-3 seconds)
- Can't optimize for off-peak processing
- Higher latency

---

### 2. Background Pre-Generation (NEW!)

**What it does:** AI generates content during downtime and stores it in a queue

**Implementation:**
```
Every 30 minutes:
  → Check mission queue levels
  → If low, generate 3-5 missions per type
  → Store in Redis queue (max 10 per type)

When player requests mission:
  → Check queue first
  → If available: instant delivery (< 10ms)
  → If empty: fall back to on-demand generation
  → Trigger background replenishment
```

**Files:**
- `python/ai-service/src/background/mission_queue.py` - Redis queue manager
- `python/ai-service/src/background/tasks.py` - Pre-generation logic
- `python/ai-service/src/api/missions_enhanced.py` - Queue-aware API

**Configuration (.env):**
```bash
MISSION_QUEUE_ENABLED=true
MISSION_QUEUE_SIZE=10          # Max per difficulty/type
MISSION_TTL_HOURS=24           # Queue expiration
```

**Example use cases:**
- Pre-generate 10 "easy salvage" missions
- Pre-generate 10 "medium exploration" missions
- Instant mission delivery when player requests
- Automatic queue replenishment

**Pros:**
- Instant response for users
- Optimizes AI costs (batch processing)
- Can run during low-traffic periods

**Cons:**
- Missions may be less contextual
- Uses Redis memory
- Requires queue management

---

### 3. Scheduled Tasks (NEW!)

**What it does:** AI generates content on a fixed schedule (cron-like)

**Implementation:**
```
Daily at 3 AM:  → Generate daily galaxy events
Daily at 2 AM:  → Clean up old cache entries
Weekly (Mon 2 AM): → Refresh galaxy state, faction movements
```

**Files:**
- `python/ai-service/src/background/scheduler.py` - APScheduler setup
- `python/ai-service/src/background/tasks.py` - Task definitions

**Configuration:**
```python
# In main.py startup
scheduler.add_cron_task(
    generate_daily_events,
    hour=3,
    minute=0,
    task_id="daily_events"
)
```

**Example use cases:**
- Daily news broadcasts
- Weekly economic updates
- Nightly cache cleanup
- Scheduled faction movements

**Pros:**
- Predictable scheduling
- Off-peak processing (low cost)
- Consistent content updates

**Cons:**
- Inflexible timing
- Requires service to stay running
- May miss events if service down

---

### 4. Interval Tasks (NEW!)

**What it does:** AI runs tasks at regular intervals

**Implementation:**
```
Every 30 minutes:
  → Check all mission queues
  → Replenish low queues
  → Log statistics
```

**Configuration:**
```python
scheduler.add_interval_task(
    replenish_all_queues,
    minutes=30,
    task_id="mission_replenishment"
)
```

**Example use cases:**
- Queue replenishment every 30 min
- Health checks every 5 min
- Statistics collection every hour

**Pros:**
- Flexible timing
- Responds to system load
- Easy to configure

**Cons:**
- Can't align to specific times
- May overlap if tasks run long

---

## Architecture Components

### Redis Mission Queue

**Purpose:** Store pre-generated missions for instant delivery

**Structure:**
```
mission_queue:easy:salvage     → List of missions
mission_queue:medium:combat    → List of missions
mission_queue:hard:exploration → List of missions
```

**Operations:**
```python
# Push mission to queue
await mission_queue.push_mission(mission_data, "medium", "salvage")

# Pop mission from queue (FIFO)
mission = await mission_queue.pop_mission("medium", "salvage")

# Check queue size
size = await mission_queue.get_queue_size("medium", "salvage")

# Get all stats
stats = await mission_queue.get_all_queue_stats()
```

**Location:** `python/ai-service/src/background/mission_queue.py`

---

### APScheduler Background Tasks

**Purpose:** Run periodic and scheduled AI tasks

**Task Types:**

**Interval Tasks:**
```python
scheduler.add_interval_task(
    replenish_all_queues,
    minutes=30,
    task_id="mission_replenishment"
)
```

**Cron Tasks:**
```python
scheduler.add_cron_task(
    generate_daily_events,
    hour=3,
    minute=0,
    day_of_week='mon',  # Optional
    task_id="weekly_events"
)
```

**Location:** `python/ai-service/src/background/scheduler.py`

---

### Background Task Definitions

**Available Tasks:**

1. **`pregenerate_missions(count=5)`**
   - Pre-generates missions for all types/difficulties
   - Fills mission queues
   - Runs every 30 minutes

2. **`generate_daily_events()`**
   - Creates daily news, events, economy changes
   - Runs at 3 AM daily
   - Caches for 24 hours

3. **`cleanup_old_cache()`**
   - Removes expired cache entries
   - Runs at 2 AM daily
   - Maintains cache health

4. **`refresh_galaxy_state()`**
   - Updates galaxy-wide state (factions, locations)
   - Runs Monday 2 AM weekly
   - Long-term story progression

5. **`replenish_all_queues()`**
   - Checks all queue levels
   - Triggers replenishment if low
   - Runs every 30 minutes

**Location:** `python/ai-service/src/background/tasks.py`

---

## API Endpoints

### Enhanced Mission Generation

**POST /api/missions/generate**

Enhanced with queue support:

```python
# 1. Check queue first
queued_mission = await mission_queue.pop_mission(difficulty, type)

if queued_mission:
    return queued_mission  # Instant! (< 10ms)

# 2. Fall back to on-demand generation
mission = await ai_client.generate(...)
return mission  # Slower (1-3s)
```

**Response includes source:**
```json
{
  "success": true,
  "mission": {...},
  "cached": true,
  "generation_time_ms": 8.2,
  "source": "queue"  // "queue", "cache", or "ai_generated"
}
```

---

### Queue Management Endpoints

**GET /api/missions/queue/stats**

Get queue statistics:
```json
{
  "enabled": true,
  "queues": {
    "easy/salvage": 8,
    "medium/combat": 5,
    "hard/exploration": 3
  },
  "total_missions": 16
}
```

**POST /api/missions/queue/replenish**

Manually trigger replenishment:
```bash
curl -X POST http://localhost:17011/api/missions/queue/replenish?count=5
```

**DELETE /api/missions/queue/clear**

Clear queue (useful for testing):
```bash
# Clear all
curl -X DELETE http://localhost:17011/api/missions/queue/clear

# Clear specific
curl -X DELETE http://localhost:17011/api/missions/queue/clear?difficulty=easy&mission_type=salvage
```

---

## Configuration

### Environment Variables

**Enable/Disable Features:**
```bash
BACKGROUND_TASKS_ENABLED=true     # Master switch
MISSION_QUEUE_ENABLED=true        # Mission queue system
CACHE_ENABLED=true                # Redis caching
```

**Queue Configuration:**
```bash
MISSION_QUEUE_SIZE=10             # Max missions per queue
MISSION_TTL_HOURS=24              # Queue expiration
STARTUP_PREGENERATE=true          # Pre-gen on startup
```

**Redis Configuration:**
```bash
REDIS_HOST=localhost
REDIS_PORT=17014
REDIS_DB=0
CACHE_TTL_HOURS=24
```

**Location:** `python/ai-service/.env.example`

---

## Development Workflow

### Testing the System

1. **Start Redis:**
```bash
docker-compose up -d redis
```

2. **Start AI Service:**
```bash
cd python/ai-service
source venv/bin/activate
python main.py
```

3. **Watch logs for background tasks:**
```
INFO - Background scheduler initialized
INFO - Configuring AI-first background tasks...
INFO - Added interval task 'mission_replenishment'
INFO - Added cron task 'daily_events'
INFO - Background tasks configured and started
```

4. **Check queue stats:**
```bash
curl http://localhost:17011/api/missions/queue/stats
```

5. **Manually trigger replenishment:**
```bash
curl -X POST http://localhost:17011/api/missions/queue/replenish?count=2
```

6. **Request a mission (should be instant if queue has content):**
```bash
curl -X POST http://localhost:17011/api/missions/generate \
  -H "Content-Type: application/json" \
  -d '{
    "difficulty": "medium",
    "mission_type": "salvage",
    "game_state": {...}
  }'
```

---

### Disabling Background Tasks

**For testing/development:**

```bash
# .env
BACKGROUND_TASKS_ENABLED=false
```

Service will fall back to 100% on-demand generation.

---

## Performance Impact

### Response Times

**Without Queue (event-driven only):**
- AI generation: 1000-3000ms
- User waits for every request

**With Queue (AI-first):**
- Queue hit: 5-15ms (instant!)
- Cache hit: 10-30ms
- AI generation (fallback): 1000-3000ms
- Queue replenishment: background (no user impact)

### Resource Usage

**Redis Memory:**
- ~1KB per mission
- 10 missions × 24 queues = 240 missions
- ~240KB total (negligible)

**CPU:**
- APScheduler: < 1% CPU
- Background tasks: 5-10% CPU during generation
- Idle: < 1% CPU

**AI Costs:**
- Batch pre-generation is cheaper (off-peak)
- Fewer redundant requests
- Better cache hit rates

---

## Best Practices

### For Hobby Projects

✅ **Do:**
- Start with event-driven (simple)
- Add queue for instant responses
- Use scheduled tasks for daily content
- Set reasonable queue sizes (10-20)

❌ **Don't:**
- Over-engineer (KISS principle)
- Pre-generate too much (wastes AI calls)
- Run expensive tasks during peak hours

### For Production

✅ **Do:**
- Monitor queue levels
- Set up alerts for failed tasks
- Use separate Redis DB for queues
- Implement queue size limits
- Add metrics/observability

❌ **Don't:**
- Let queues grow unbounded
- Skip error handling
- Ignore failed background tasks

---

## Troubleshooting

### Queue is always empty

**Check:**
1. Is `BACKGROUND_TASKS_ENABLED=true`?
2. Is `MISSION_QUEUE_ENABLED=true`?
3. Are there errors in logs?
4. Is Redis running?

**Debug:**
```bash
# Check Redis connection
redis-cli -p 17014 ping

# Check queue keys
redis-cli -p 17014 keys "mission_queue:*"

# Check scheduler status
curl http://localhost:17011/health
```

### Background tasks not running

**Check:**
1. Service startup logs
2. Scheduler initialization
3. Task registration

**Fix:**
```python
# Verify in logs:
"Added interval task 'mission_replenishment'"
"Added cron task 'daily_events'"
"Background tasks configured and started"
```

### High memory usage

**Solution:**
- Reduce `MISSION_QUEUE_SIZE`
- Lower `MISSION_TTL_HOURS`
- Clear queues periodically

---

## Future Enhancements

Potential additions for your project:

1. **Dynamic Queue Sizing**
   - Adjust queue size based on player activity
   - Larger queues during peak hours

2. **Priority Queues**
   - High-priority missions first
   - Player-level-specific queues

3. **Distributed Tasks**
   - Celery for heavy processing
   - Multiple worker nodes

4. **Metrics Dashboard**
   - Queue hit rate
   - Generation times
   - AI cost tracking

5. **Smart Pre-Generation**
   - ML-based prediction of what players will request
   - Context-aware pre-generation

---

## Summary

**You now have:**

✅ **Event-Driven Pattern** - Original on-demand generation
✅ **Background Pre-Generation** - Mission queue system
✅ **Scheduled Tasks** - Daily/weekly content updates
✅ **Interval Tasks** - Periodic queue replenishment

**Benefits:**
- Instant mission delivery (< 10ms from queue)
- Background AI processing (no user wait)
- Scheduled content updates (daily events)
- Automatic queue management

**Next Steps:**
1. Test the system locally
2. Adjust queue sizes for your needs
3. Customize task schedules
4. Monitor performance
5. Add custom background tasks as needed

---

## Reference Files

**Core Implementation:**
- `/python/ai-service/src/background/scheduler.py` - Task scheduler
- `/python/ai-service/src/background/mission_queue.py` - Queue manager
- `/python/ai-service/src/background/tasks.py` - Task definitions
- `/python/ai-service/main.py` - Integration & startup

**API:**
- `/python/ai-service/src/api/missions_enhanced.py` - Queue-aware API
- `/python/ai-service/src/api/missions.py` - Original event-driven API

**Configuration:**
- `/python/ai-service/.env.example` - All settings
- `/python/requirements.txt` - Dependencies (APScheduler)

**Documentation:**
- `/docs/AI-FIRST-ARCHITECTURE.md` - This file
