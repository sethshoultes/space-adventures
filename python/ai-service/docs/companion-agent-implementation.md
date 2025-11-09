# Companion Agent Implementation

## Overview

The Companion Agent is an empathetic AI companion that monitors crew morale and player emotional state, providing encouragement, support, and celebrating achievements. It follows the LangGraph ReAct pattern like other agents in the system.

**File Location:** `/python/ai-service/src/agents/companion_agent.py`

## Agent Characteristics

### Personality
- Warm, supportive, optimistic (not saccharine)
- Empathetic and perceptive
- Occasional gentle humor
- Respectful of player's choices

### Throttling (Most Selective)
- `min_message_interval`: 120 seconds (2 minutes)
- `max_messages_per_hour`: 15 messages
- **Rationale:** Companion is thoughtful and selective to avoid being annoying

### Urgency Levels

#### INFO
General encouragement, casual observations
- "The crew seems in good spirits today. Your leadership is showing."

#### MEDIUM
Emotional support after setbacks, recognition of progress
- "I know that last mission was rough. But you made the right call."
- "Noticed you completed 5 missions. Well done."

#### URGENT
Major achievements, defining moments
- "You've accomplished something remarkable, captain. Take a moment to appreciate it."

#### CRITICAL (Rarely Used)
Player might be struggling, needs strong encouragement
- "I believe in you. We all do. You can do this."

## Workflow

### 1. Observe
Monitors:
- Player level and XP
- Completed missions count
- Active mission difficulty
- Hull damage (recent setbacks)
- Recent player actions

**Key Observations:**
- Damage indicators
- Mission difficulty levels
- Progress milestones
- Idle time between missions

### 2. Reason
Determines if emotional support is needed based on:
- Recent damage/setbacks
- High difficulty missions (4-5)
- Level ups or mission milestones
- Extended idle time without mission
- First-time observations (new achievements)

**Decision Criteria:**
```python
should_check_morale = True if:
  - Recent damage detected
  - Tackling difficulty 4+ mission
  - Potential level up or progress
  - Mission completion detected
  - Player idle between missions
```

### 3. Act
Executes tools to evaluate situation:

**Always Runs:**
- `check_crew_morale()` - Assess crew emotional state

**Conditionally Runs:**
- `evaluate_player_progress()` - Check for achievements (if progress/completion detected)
- `assess_emotional_tone()` - Determine support needs

### 4. Reflect
Analyzes tool results to determine if support message should be generated:

**Priority Order:**
1. **Critical Morale** (crew losses, critical morale) → CRITICAL urgency
2. **Low Morale** (mission failures, low morale) → MEDIUM urgency
3. **Major Milestones** (10 missions, all systems, spaceflight) → URGENT urgency
4. **Achievements** (level ups, 5 mission increments) → MEDIUM urgency
5. **Good Morale** (excellent morale) → INFO urgency
6. **Encouragement Needed** (from emotional tone) → MEDIUM urgency

### 5. Communicate
Generates appropriate message based on urgency and situation:

**CRITICAL Messages:**
- Acknowledge difficulty
- Strong encouragement
- "I believe in you. We all do."

**URGENT Messages:**
- Celebrate major achievement
- Reflect on accomplishment
- "Take a moment to appreciate how far you've come."

**MEDIUM Messages:**
- Support after setbacks
- Recognize progress
- "You made the right call."

**INFO Messages:**
- Acknowledge good morale
- Gentle encouragement
- "The crew seems in good spirits today."

## Tools

### check_crew_morale(game_state)
Monitors crew morale based on:
- Recent crew losses (from notable_events)
- Recent mission failures
- Ship damage (hull percentage)
- Mission difficulty
- Completed missions (success factor)

**Returns:**
```python
{
  "overall_morale": "critical" | "low" | "good" | "excellent",
  "morale_score": 0-100,
  "recent_crew_losses": int,
  "recent_mission_failures": int,
  "morale_factors": List[str],
  "crew_needs": List[str]
}
```

**Morale Calculation:**
- Start: 100 (neutral)
- Crew loss: -25 each
- Mission failure: -15 each
- Hull < 50%: -20
- Difficulty 4+: -10
- Completed missions: +5 each (capped at +30)
- Hull > 90%: +10

### evaluate_player_progress(game_state)
Tracks achievements and milestones:

**Detects:**
- Level milestones (level 10+)
- Mission milestones (10, 25 missions)
- Ship system milestones (all systems online, max level systems)
- Phase progression (achieved spaceflight)
- Exploration (locations discovered)

**Returns:**
```python
{
  "current_level": int,
  "recent_level_up": bool,
  "recent_achievements": List[str],
  "major_milestone": bool,
  "milestone_name": str,
  "progress_summary": str,
  "total_missions_completed": int,
  "ship_systems_operational": int
}
```

### assess_emotional_tone(game_state)
Determines if player needs encouragement:

**Analyzes:**
- Hull condition
- Mission difficulty
- Player level vs. progress
- Success indicators

**Returns:**
```python
{
  "needs_encouragement": bool,
  "facing_difficult_challenge": bool,
  "celebrating_success": bool,
  "emotional_state": "struggling" | "challenged" | "engaged" | "triumphant",
  "support_type": "none" | "gentle" | "moderate" | "strong" | "celebration",
  "hull_condition": str,
  "current_challenge_level": int
}
```

**Decision Logic:**
- Difficulty 4+ → needs encouragement (gentle)
- Hull < 30% → struggling (moderate)
- Level 3+ but < 5 missions → needs encouragement (gentle)
- 10+ missions OR level 5+ → celebrating success
- Hull < 60% + difficulty 3+ → challenged (moderate)
- Hull > 80% + 5+ missions → no support needed

## Integration

### Import
```python
from src.agents.companion_agent import CompanionAgent
```

### Initialization
```python
companion = CompanionAgent(
    redis_client=redis_client,
    llm_client=llm_client,
    min_message_interval=120,  # 2 minutes
    max_messages_per_hour=15
)
```

### Running the Agent
```python
result = await companion.run(game_state, force_check=False)

# Result structure:
{
    "should_act": bool,
    "message": str | None,
    "urgency": "INFO" | "MEDIUM" | "URGENT" | "CRITICAL",
    "tools_used": List[str],
    "reasoning": str,
    "next_check_in": 120
}
```

### Response Handling (in Godot)
```gdscript
# When companion message received
if companion_result.message:
    var urgency = companion_result.urgency

    match urgency:
        "CRITICAL":
            show_companion_message(message, Color.RED, true)  # Priority
        "URGENT":
            show_companion_message(message, Color.GOLD, true)
        "MEDIUM":
            show_companion_message(message, Color.CYAN, false)
        "INFO":
            show_companion_message(message, Color.WHITE, false)
```

## Testing

### Run Tests
```bash
cd python/ai-service
pytest tests/test_companion_agent.py -v
```

### Test Scenarios Covered
1. Normal state observation
2. Damaged ship detection
3. Difficult mission detection
4. Tool execution
5. Critical morale reflection
6. Achievement celebration
7. Full workflow integration
8. Throttling behavior

### Manual Testing
```python
# Test with damaged ship
game_state = {
    "player": {"level": 3, "xp": 150},
    "ship": {"hull_hp": 25, "max_hull_hp": 100},
    "progress": {"completed_missions": ["m1", "m2"]},
    "mission": {"difficulty": 4}
}

result = await companion.run(game_state, force_check=True)
print(result["message"])  # Should offer encouragement
```

## Implementation Decisions

### Why Most Selective Throttling?
- Companion messages are personal and emotional
- Too frequent = feels artificial and annoying
- Rare, well-timed messages have more impact
- Players should feel companion is thoughtful, not chatty

### Why Three Tools?
- `check_crew_morale` - Core responsibility (morale monitoring)
- `evaluate_player_progress` - Achievement recognition
- `assess_emotional_tone` - Determines support type

These three cover the companion's domain without overlap with other agents.

### Why No LLM in Initial Implementation?
- Current implementation uses rule-based logic for speed/reliability
- Messages are template-based but context-aware
- LLM integration can be added later for more natural language
- Rule-based ensures consistent, appropriate tone

### Message Template Philosophy
- Keep messages short (1-2 sentences)
- Focus on emotional support, not information
- Avoid repetitive phrases
- Match urgency to situation severity
- Never patronizing or saccharine

## Future Enhancements

### Potential Improvements
1. **LLM-Generated Messages** - More natural, varied language
2. **Player Personality Tracking** - Adapt tone to player style
3. **Long-term Memory** - Reference past conversations
4. **Emotion Detection** - Analyze player choice patterns
5. **Crew Member Voices** - Different companion personalities

### Integration with Other Agents
- **ATLAS** focuses on ship systems → Companion focuses on people
- **Storyteller** focuses on narrative → Companion focuses on emotion
- **Tactical Officer** focuses on combat → Companion focuses on aftermath

Companion complements without duplicating.

## Common Issues

### "Companion is too quiet"
- Check `min_message_interval` (120s is intentional)
- Verify game state has progress/events to trigger
- Use `force_check=True` in testing

### "Companion repeats messages"
- Ensure game state is changing between checks
- Check Redis memory for recent observations
- Verify observation comparison logic

### "Urgency seems wrong"
- Review morale calculation thresholds
- Check milestone detection logic
- Test with specific game states

## Example Scenarios

### Scenario 1: Player Takes Heavy Damage
```python
game_state = {
    "ship": {"hull_hp": 20, "max_hull_hp": 100},
    "progress": {"completed_missions": ["m1", "m2", "m3"]}
}
```
**Expected:** MEDIUM urgency, "I know that last mission was rough..."

### Scenario 2: Player Completes 10 Missions
```python
game_state = {
    "progress": {"completed_missions": [...10 missions...]}
}
```
**Expected:** URGENT urgency, celebration of milestone

### Scenario 3: Player Has Excellent Morale
```python
game_state = {
    "ship": {"hull_hp": 95, "max_hull_hp": 100},
    "progress": {"completed_missions": [...8 missions...]}
}
```
**Expected:** INFO urgency, "The crew seems in good spirits..."

### Scenario 4: Multiple Crew Losses
```python
game_state = {
    "progress": {
        "notable_events": [
            "crew member lost in mission",
            "crew member died in accident",
            "crew member killed in combat"
        ]
    }
}
```
**Expected:** CRITICAL urgency, strong encouragement

## Architecture Notes

### Follows BaseAgent Pattern
- Inherits from `BaseAgent`
- Implements abstract `run()` method
- Uses Redis for memory/throttling
- Returns standardized response format

### LangGraph Workflow
- StateGraph with typed `AgentState`
- Five nodes: observe → reason → act → reflect → communicate
- Conditional edges for decision points
- Compiled workflow for efficient execution

### Tool Integration
- Tools added to `tools.py`
- Schemas in `TOOL_SCHEMAS`
- Functions in `TOOL_FUNCTIONS`
- Companion filters to only its three tools in `get_available_tools()`

## Documentation
- Implementation guide: This file
- API documentation: In code docstrings
- Tests: `/tests/test_companion_agent.py`
- Main docs: `/docs/autonomous-agent-implementation.md`

---

**Author:** AI Agent (Claude Code)
**Date:** 2025-11-08
**Status:** Complete - Ready for Testing
