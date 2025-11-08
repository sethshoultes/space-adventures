# Agent Loop API Documentation

## Endpoint

```
POST /api/orchestrator/agent_loop
```

## Purpose

This endpoint enables autonomous AI agents (starting with ATLAS) to periodically monitor game state and provide proactive interjections. Called every 45-60 seconds by the Godot client.

## Request Format

```json
{
  "agent": "atlas",
  "game_state": {
    "player": {
      "level": 3,
      "rank": "Lieutenant",
      "skills": {"engineering": 5, "diplomacy": 3}
    },
    "ship": {
      "hull_hp": 45,
      "max_hull_hp": 100,
      "power": 80,
      "max_power": 100,
      "systems": {
        "hull": {"level": 1, "health": 90, "operational": true},
        "power": {"level": 1, "health": 100, "operational": true}
      }
    },
    "mission": {
      "title": "Cargo Escort",
      "stage": "route_planning"
    },
    "environment": {
      "location": "Gamma Route",
      "threats": []
    }
  },
  "force_check": false
}
```

### Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `agent` | string | Yes | Agent name (`atlas`, `storyteller`, `tactical`, `companion`) |
| `game_state` | object | Yes | Current game state for agent to analyze |
| `force_check` | boolean | No | Override throttling (for testing). Default: `false` |

## Response Format

### Success Response (Agent Acts)

```json
{
  "success": true,
  "data": {
    "should_act": true,
    "message": "Captain, hull integrity at 45%. Recommend immediate repair.",
    "urgency": "MEDIUM",
    "tools_used": ["get_system_status"],
    "reasoning": "Hull below 50% threshold (45%)",
    "next_check_in": 45
  },
  "error": null
}
```

### Success Response (Agent Stays Silent)

```json
{
  "success": true,
  "data": {
    "should_act": false,
    "message": null,
    "reasoning": "All systems nominal, no changes requiring attention",
    "next_check_in": 60
  },
  "error": null
}
```

### Error Response

```json
{
  "success": false,
  "data": null,
  "error": "Agent error: LLM timeout"
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Whether the check was successful |
| `data.should_act` | boolean | Whether agent decided to send a message |
| `data.message` | string\|null | Agent's message (null if staying silent) |
| `data.urgency` | string | Urgency level: `INFO`, `MEDIUM`, `URGENT`, `CRITICAL` |
| `data.tools_used` | string[] | List of tools agent used during analysis |
| `data.reasoning` | string | Why agent made this decision |
| `data.next_check_in` | number | Recommended seconds until next check |
| `error` | string\|null | Error message if failed |

## Example Usage

### curl

```bash
curl -X POST http://localhost:17011/api/orchestrator/agent_loop \
  -H "Content-Type: application/json" \
  -d '{
    "agent": "atlas",
    "game_state": {
      "ship": {"hull_hp": 45, "max_hull_hp": 100}
    }
  }'
```

### Python

```python
import requests

response = requests.post(
    "http://localhost:17011/api/orchestrator/agent_loop",
    json={
        "agent": "atlas",
        "game_state": {
            "ship": {"hull_hp": 45, "max_hull_hp": 100}
        }
    }
)

data = response.json()
if data["success"] and data["data"]["should_act"]:
    print(f"ATLAS: {data['data']['message']}")
```

### GDScript (Godot)

```gdscript
func _on_atlas_timer_timeout():
    var game_state = GameState.get_state()

    var result = await AIService.agent_loop_check("atlas", game_state)

    if result.success and result.data.has("message") and result.data.message:
        _add_atlas_message(result.data.message, result.data.urgency)
```

## Testing

A test script is provided at `/python/ai-service/test_agent_loop.py`:

```bash
cd python/ai-service
source venv/bin/activate
python test_agent_loop.py
```

Tests include:
- ✅ Nominal state (agent stays silent)
- ✅ Low hull (agent sends MEDIUM urgency message)
- ✅ Critical hull (agent sends URGENT message)
- ✅ Invalid agent name (returns 400 error)
- ✅ Scheduler status in health check

## Implementation Status

### Phase 1 (Current)
- ✅ Endpoint implemented
- ✅ Request/response models
- ✅ ATLAS agent support
- ✅ Basic game state analysis (placeholder logic)
- ⚠️ TODO: Full ReAct loop with LangGraph
- ⚠️ TODO: Redis-based throttling
- ⚠️ TODO: Agent memory and context

### Phase 2 (Future)
- ❌ Storyteller agent
- ❌ Tactical agent
- ❌ Companion agent
- ❌ Multi-agent coordination
- ❌ Event-driven triggers

## Background Scheduler

The service includes APScheduler with two background jobs:

### Memory Cleanup Job
- **Frequency:** Every 5 minutes
- **Purpose:** Clean up old agent observations from Redis
- **Status:** Placeholder (TODO: implement Redis cleanup)

### Health Check Job
- **Frequency:** Every 1 minute
- **Purpose:** Monitor AI provider availability
- **Status:** Active, logs unhealthy providers

Check scheduler status:
```bash
curl http://localhost:17011/health | jq '.scheduler'
```

Output:
```json
{
  "status": "running",
  "jobs": [
    {
      "id": "health_check",
      "name": "Service health check",
      "next_run": "2025-11-08T16:27:19.331042-07:00"
    },
    {
      "id": "memory_cleanup",
      "name": "Clean up old agent memories",
      "next_run": "2025-11-08T16:31:19.330964-07:00"
    }
  ]
}
```

## Design Reference

See `/docs/ai-agent-autonomous-system.md` for complete architectural details, including:
- ReAct loop implementation
- Agent tools (get_system_status, check_mission_progress, scan_environment)
- Throttling rules
- Memory management
- Token usage and performance

## Next Steps

To complete the autonomous agent system:

1. **Implement ReAct Loop** (Priority 1)
   - Set up LangGraph state machine
   - Implement observe/reason/act/reflect/communicate nodes
   - Add agent tools (system_status, mission_progress, environment_scan)

2. **Add Throttling** (Priority 1)
   - Redis-based last message timestamp
   - Minimum 60s between messages
   - Max 30 messages per hour

3. **Implement Memory** (Priority 2)
   - Store last 10 observations in Redis
   - Track recent actions
   - Prevent repetitive messages

4. **Add Remaining Agents** (Priority 3)
   - Storyteller (narrative events)
   - Tactical (combat analysis)
   - Companion (morale/crew)

## Files Modified

- `/python/ai-service/src/models/orchestrator.py` - Added `AgentLoopRequest`, `AgentLoopResponse`, `UrgencyLevel`
- `/python/ai-service/src/api/orchestrator.py` - Added `agent_loop_check` endpoint
- `/python/ai-service/main.py` - Added APScheduler, background jobs, scheduler status in health check
- `/python/ai-service/requirements.txt` - Added `tzlocal>=5.0`
- `/python/ai-service/test_agent_loop.py` - Test suite for endpoint
