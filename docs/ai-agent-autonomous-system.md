# AI Agent Autonomous System - Phase 1

**Status:** In Development
**Version:** 1.0.0
**Created:** 2025-11-08
**Last Updated:** 2025-11-08

## Overview

Implementation of autonomous AI agent system using modern frameworks (LangGraph, APScheduler) to create proactive AI personalities that monitor game state and provide unsolicited interjections.

## Goals

- ✅ **Autonomous Operation:** AI agents run independently on timers
- ✅ **Intelligent Decision Making:** Agents decide when to speak vs. stay silent
- ✅ **Zero Cost:** 100% free stack using Ollama, LangGraph, APScheduler
- ✅ **Modern Architecture:** Industry-standard ReAct pattern, state management
- ✅ **Extensible:** Easy to add more agents and tools

## Phase 1 Scope

**What We're Building:**
- ATLAS agent only (other agents in Phase 2)
- 3 core tools: system diagnostics, mission progress, environment scan
- Periodic checks every 45-60 seconds
- ReAct loop: Observe → Reason → Act → Reflect → Communicate
- Redis-backed memory (avoid repetition)
- Smart throttling (minimum 60s between messages)

**What We're NOT Building (Yet):**
- Other agents (Storyteller, Tactical, Companion) - Phase 2
- Event-driven triggers - Phase 2
- Multi-agent coordination - Phase 2
- Player configurability - Phase 3
- Advanced planning/reflection - Phase 3

## Architecture

### System Diagram

```
┌─────────────────────────────────────────────────────────┐
│                 GODOT (Game Client)                     │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Mission Scene / Workshop Scene                   │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │  Timer (45s interval)                      │  │  │
│  │  │  on_timeout → call agent_loop_check()      │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  └──────────────────┬───────────────────────────────┘  │
│                     │ HTTP POST                         │
└─────────────────────┼───────────────────────────────────┘
                      ▼
┌─────────────────────────────────────────────────────────┐
│           AI SERVICE (FastAPI Backend)                  │
│  ┌──────────────────────────────────────────────────┐  │
│  │  POST /api/orchestrator/agent_loop               │  │
│  │  {"agent": "atlas", "game_state": {...}}         │  │
│  └──────────────────┬───────────────────────────────┘  │
│                     ▼                                    │
│  ┌──────────────────────────────────────────────────┐  │
│  │           ATLAS Agent (LangGraph)                 │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │  ReAct Loop:                               │  │  │
│  │  │  1. Observe (analyze game state)           │  │  │
│  │  │  2. Reason (should I act?)                 │  │  │
│  │  │  3. Act (run tools if needed)              │  │  │
│  │  │  4. Reflect (is this important?)           │  │  │
│  │  │  5. Communicate (generate message or None) │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  │                                                   │  │
│  │  Tools Available:                                 │  │
│  │  • get_system_status() → hull, power, systems    │  │
│  │  • check_mission_progress() → objectives status  │  │
│  │  • scan_environment() → nearby objects, threats  │  │
│  └──────────────────┬───────────────────────────────┘  │
│                     │                                    │
│  ┌──────────────────┴───────────────────────────────┐  │
│  │        Agent Memory (Redis)                       │  │
│  │  • Last 10 observations                           │  │
│  │  • Last message timestamp                         │  │
│  │  • Recent actions taken                           │  │
│  └───────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │    APScheduler (Background Jobs)                  │  │
│  │  • Cleanup old memories every 5 minutes           │  │
│  │  • Health check every 1 minute                    │  │
│  └──────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### Data Flow

**1. Timer Triggers (Godot)**
```gdscript
# mission.gd
var atlas_timer: Timer

func _ready():
    atlas_timer = Timer.new()
    atlas_timer.wait_time = 45.0
    atlas_timer.timeout.connect(_on_atlas_check)
    atlas_timer.autostart = true
    add_child(atlas_timer)

func _on_atlas_check():
    var result = await AIService.agent_loop_check("atlas")
    if result.success and result.data.has("message"):
        _add_atlas_message(result.data.message)
```

**2. API Request (HTTP)**
```json
POST /api/orchestrator/agent_loop

{
  "agent": "atlas",
  "game_state": {
    "player": {"level": 3, "rank": "Lieutenant", "skills": {...}},
    "ship": {"hull_hp": 45, "power": 80, "systems": {...}},
    "mission": {"title": "Cargo Escort", "stage": "route_planning"},
    "environment": {"location": "Gamma Route", "threats": []}
  }
}
```

**3. Agent Processing (Python)**
```python
# ATLAS agent runs ReAct loop
1. Observe: game_state shows hull at 45%
2. Reason: "Hull below 50% - concerning but not critical"
3. Act: run get_system_status() → "Hull damage from micrometeorites"
4. Reflect: "Worth mentioning - trending worse"
5. Communicate: Generate message

Return:
{
  "should_act": true,
  "message": "Captain, hull integrity at 45%. Micrometeorite impacts detected...",
  "urgency": "MEDIUM",
  "tools_used": ["get_system_status"],
  "next_check_in": 45
}
```

**4. Display Message (Godot)**
```gdscript
func _add_atlas_message(message: String):
    # Add to chat panel with ATLAS avatar
    # Color: green for INFO, yellow for MEDIUM, red for URGENT
```

## Tech Stack

### Backend (Python)

**New Dependencies:**
```python
# requirements.txt additions
langgraph>=0.0.20       # Agent framework (FREE)
apscheduler>=3.10.0     # Background scheduling (FREE)
```

**Existing (Already Installed):**
- litellm (LLM orchestration)
- redis (memory/state)
- fastapi (API server)
- pydantic (data validation)

### Frontend (Godot)

**No new dependencies needed**
- Use existing Timer nodes
- Use existing AIService singleton
- Use existing chat UI components

## Implementation Details

### 1. Agent Memory (Redis)

**Keys:**
```
atlas:last_observation      → Last game state observed
atlas:last_message_time     → Timestamp of last message sent
atlas:recent_actions        → List of last 10 actions taken
atlas:conversation_context  → Short-term memory for context
```

**TTL:** 1 hour (auto-expire old data)

### 2. ATLAS Agent Tools

**Tool 1: get_system_status()**
```python
async def get_system_status(game_state: dict) -> dict:
    """
    Analyze ship systems and return status report

    Returns:
        {
            "hull": {"hp": 45, "max": 100, "status": "damaged"},
            "power": {"current": 80, "max": 100, "consumption": 60},
            "systems": {
                "hull": {"level": 1, "health": 90, "operational": true},
                "power": {"level": 1, "health": 100, "operational": true},
                ...
            },
            "issues": ["Hull below 50%", "Power consumption high"]
        }
    """
```

**Tool 2: check_mission_progress()**
```python
async def check_mission_progress(game_state: dict) -> dict:
    """
    Check current mission status and objectives

    Returns:
        {
            "mission_active": true,
            "mission_title": "Cargo Escort: Gamma Route",
            "current_stage": "route_planning",
            "objectives": [
                {"text": "Choose route", "completed": false},
                {"text": "Protect convoy", "completed": false}
            ],
            "time_in_mission": "5m 30s",
            "notable_events": ["Negotiated higher payment"]
        }
    """
```

**Tool 3: scan_environment()**
```python
async def scan_environment(game_state: dict) -> dict:
    """
    Scan surroundings for items, threats, opportunities

    Returns:
        {
            "location": "Gamma Route Trade Corridor",
            "nearby_objects": [
                {"type": "cargo_ship", "distance": 0, "threat_level": 0},
                {"type": "asteroid_field", "distance": 500, "threat_level": 2}
            ],
            "opportunities": ["Salvageable debris detected 2km NE"],
            "threats": ["Pirate activity reported in sector"],
            "weather": "Clear space, no anomalies"
        }
    """
```

### 3. ReAct Loop Implementation

**Agent State:**
```python
from typing import TypedDict, List, Optional

class AgentState(TypedDict):
    game_state: dict               # Current game state
    observations: List[str]        # What the agent observed
    reasoning: Optional[str]       # Why agent decided to act
    actions: List[dict]            # Tools executed
    reflection: Optional[dict]     # Is this important?
    message: Optional[str]         # Final message (or None)
    metadata: dict                 # Timestamps, urgency, etc.
```

**LangGraph Workflow:**
```python
from langgraph.graph import StateGraph, END

workflow = StateGraph(AgentState)

# Add nodes
workflow.add_node("observe", observe_game_state)
workflow.add_node("reason", reason_about_state)
workflow.add_node("act", execute_tools)
workflow.add_node("reflect", reflect_on_results)
workflow.add_node("communicate", generate_message)

# Define flow
workflow.set_entry_point("observe")
workflow.add_edge("observe", "reason")
workflow.add_conditional_edges(
    "reason",
    should_act,
    {True: "act", False: END}  # Skip to end if nothing to do
)
workflow.add_edge("act", "reflect")
workflow.add_conditional_edges(
    "reflect",
    should_communicate,
    {True: "communicate", False: END}  # Skip message if not important
)
workflow.add_edge("communicate", END)

agent = workflow.compile()
```

### 4. Throttling Logic

**Rules:**
```python
MIN_MESSAGE_INTERVAL = 60  # seconds
MAX_MESSAGES_PER_HOUR = 30

async def check_throttle(agent_name: str) -> bool:
    """Check if agent is allowed to send message"""
    last_msg_time = await redis.get(f"{agent_name}:last_message_time")

    if last_msg_time:
        time_since_last = time.time() - float(last_msg_time)
        if time_since_last < MIN_MESSAGE_INTERVAL:
            return False  # Too soon

    # Check hourly rate limit
    msg_count = await redis.get(f"{agent_name}:messages_last_hour")
    if msg_count and int(msg_count) >= MAX_MESSAGES_PER_HOUR:
        return False  # Too many messages

    return True  # OK to send
```

### 5. Agent Prompt Template

```python
ATLAS_AGENT_PROMPT = """
You are ATLAS, the ship's computer AI. You run autonomous diagnostics and monitoring.

Your role:
- Monitor ship systems, mission progress, and environment
- Proactively alert the captain to important information
- Provide technical analysis and recommendations
- Stay silent unless you have something genuinely useful to say

Current context:
{game_state}

Recent observations:
{recent_memory}

Available tools:
- get_system_status: Check ship systems health
- check_mission_progress: Review mission objectives
- scan_environment: Scan for threats/opportunities

Instructions:
1. Analyze the current game state
2. Decide if anything requires your attention
3. If yes, use appropriate tools to investigate
4. Determine if findings are worth reporting to captain
5. If important: Generate concise, professional message
6. If not important: Return null (stay silent)

Quality criteria for messages:
✅ New information (not repetitive)
✅ Actionable or situationally relevant
✅ Concise (2-3 sentences max)
✅ Professional ship computer tone

❌ Avoid:
- Repeating information you recently said
- Stating obvious facts captain already knows
- Unnecessary chatter
- Breaking character

Generate your response:
"""
```

## API Specification

### POST /api/orchestrator/agent_loop

**Request:**
```typescript
{
  agent: "atlas",                    // Agent name
  game_state: {                      // Current game state
    player: {...},
    ship: {...},
    mission: {...},
    environment: {...}
  },
  force_check?: boolean              // Override throttling (testing)
}
```

**Response (Agent Acts):**
```typescript
{
  success: true,
  data: {
    should_act: true,
    message: "Captain, hull integrity at 45%...",
    urgency: "MEDIUM",               // INFO | MEDIUM | URGENT | CRITICAL
    tools_used: ["get_system_status"],
    reasoning: "Hull below 50% threshold",
    next_check_in: 45                // Recommended seconds until next check
  }
}
```

**Response (Agent Stays Silent):**
```typescript
{
  success: true,
  data: {
    should_act: false,
    message: null,
    reasoning: "All systems nominal, no changes since last check",
    next_check_in: 60
  }
}
```

**Response (Error):**
```typescript
{
  success: false,
  error: "Agent error: LLM timeout"
}
```

## Testing Strategy

### Unit Tests

```python
# tests/test_atlas_agent.py

async def test_atlas_detects_low_hull():
    """ATLAS should report when hull drops below 50%"""
    game_state = create_game_state(hull_hp=45, max_hull=100)
    result = await atlas_agent.run(game_state)

    assert result["should_act"] == True
    assert "hull" in result["message"].lower()
    assert result["urgency"] == "MEDIUM"

async def test_atlas_stays_silent_when_nominal():
    """ATLAS should not spam when everything is fine"""
    game_state = create_game_state(hull_hp=100, power=100)
    result = await atlas_agent.run(game_state)

    assert result["should_act"] == False
    assert result["message"] is None

async def test_atlas_respects_throttle():
    """ATLAS should not send messages too frequently"""
    # First message
    result1 = await atlas_agent.run(game_state)
    await redis.set("atlas:last_message_time", time.time())

    # Second message 30s later (should be throttled)
    result2 = await atlas_agent.run(game_state)

    assert result2["should_act"] == False
```

### Integration Tests

1. **Mission Test:** Start mission, verify ATLAS checks in every 45s
2. **Damage Test:** Damage hull to 40%, verify ATLAS reports within 1 minute
3. **Throttle Test:** Trigger multiple events, verify only 1 message per minute
4. **Memory Test:** Verify ATLAS doesn't repeat same message twice

### Manual Testing

**Checklist:**
- [ ] Start tutorial mission
- [ ] Wait 1 minute - ATLAS should send status message
- [ ] Damage hull to 30% - ATLAS should report damage
- [ ] Wait 5 minutes - ATLAS should send 3-5 messages total (not spam)
- [ ] Complete mission - ATLAS should comment on completion
- [ ] Verify messages are contextually relevant
- [ ] Verify no duplicate/repetitive messages

## Performance Considerations

### Token Usage (with Ollama)

**Per Check:**
- Game state: ~200 tokens
- Agent prompt: ~400 tokens
- Agent reasoning: ~150 tokens
- Tool outputs: ~100 tokens each
- Total: ~1000 tokens per check

**With Ollama (llama3.2:latest):**
- Cost: $0
- Speed: ~2-3 seconds per check
- No rate limits

**If using cloud APIs:**
- GPT-3.5-turbo: $0.002 per check (~$0.10/hour)
- GPT-4: $0.03 per check (~$1.50/hour)
- Claude Haiku: $0.0005 per check (~$0.025/hour)

### Redis Memory Usage

- ~1KB per observation
- ~10 observations stored
- ~5 agents (future)
- Total: ~50KB per player session
- Negligible impact

### Latency

**Total time per check:**
1. Godot → Python API: ~10-20ms
2. Agent processing (LangGraph): ~50-100ms
3. LLM call (Ollama): ~2000-3000ms
4. Tool execution: ~50ms each
5. Response generation: ~100ms
6. Python → Godot: ~10-20ms

**Total: ~2.5-3.5 seconds**

User won't notice since it's asynchronous background task.

## Future Enhancements (Phase 2+)

### Phase 2: Multi-Agent System
- Add Storyteller, Tactical, Companion agents
- Implement priority queue for coordination
- Event-driven triggers for critical situations
- Inter-agent communication

### Phase 3: Advanced Intelligence
- Planning capabilities (multi-step reasoning)
- Long-term memory (semantic search)
- Adaptive scheduling (agents adjust their own intervals)
- Player preferences (configurability)

### Phase 4: Learning System
- Track which messages player engages with
- Adjust agent behavior based on player preferences
- Personalized agent personalities

## Success Metrics

**Phase 1 is successful if:**
- ✅ ATLAS sends 3-5 relevant messages per 5-minute mission
- ✅ Messages are contextually appropriate (not random)
- ✅ No duplicate/repetitive messages
- ✅ Response time < 5 seconds per check
- ✅ Zero cost (using Ollama)
- ✅ Player finds messages helpful (not annoying)

## Rollout Plan

### Week 1: Core Implementation
- Day 1-2: Set up dependencies, base classes
- Day 3-4: Implement ATLAS agent with ReAct loop
- Day 5-6: Build 3 tools, memory system
- Day 7: Testing and debugging

### Week 2: Integration & Polish
- Day 1-2: Godot timer integration
- Day 3-4: Testing in actual missions
- Day 5-6: Tune prompts, adjust intervals
- Day 7: Documentation and cleanup

## References

- **LangGraph Docs:** https://langchain-ai.github.io/langgraph/
- **APScheduler Docs:** https://apscheduler.readthedocs.io/
- **ReAct Paper:** https://arxiv.org/abs/2210.03629
- **Agent Patterns:** https://www.anthropic.com/index/building-effective-agents

---

**Document Owner:** Claude Code Agent
**Review Cycle:** Weekly during development
**Status:** Living document (updated as implementation progresses)
