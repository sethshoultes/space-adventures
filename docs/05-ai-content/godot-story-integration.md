# Godot Dynamic Story Integration Guide

**Purpose:** Guide for integrating Godot game client with Python story engine for dynamic narrative generation
**Status:** Implementation guide for Week 4
**Related:** [Dynamic Story Engine](./dynamic-story-engine.md), [Hybrid Mission Example](../../godot/assets/data/missions/mission_tutorial_hybrid.json)

---

## Overview

This guide explains how the Godot game client integrates with the Python story engine to deliver contextual, dynamic narratives that respond to player choices, relationships, and world state.

**Architecture:**
```
Godot Mission Scene
    ↓
Load Mission JSON (hybrid format)
    ↓
Detect narrative_structure presence → Hybrid Mission
    ↓
Call /api/story/generate_narrative (POST)
    ↓
Story Engine builds prompt with player context
    ↓
LLM generates contextual narrative
    ↓
Response cached (1 hour TTL)
    ↓
Godot displays generated text
    ↓
Player makes choice
    ↓
Call /api/story/generate_outcome (POST)
    ↓
Update /api/story/memory (track choice, relationships, consequences)
```

---

## Detecting Hybrid Missions

**Static Mission:**
```json
{
  "stage_id": "arrival",
  "description": "The museum sits half-buried in sand...",
  "choices": [
    {
      "choice_id": "front_entrance",
      "consequences": {
        "success": {
          "text": "The doors open automatically..."
        }
      }
    }
  ]
}
```

**Hybrid Mission:**
```json
{
  "stage_id": "arrival",
  "narrative_structure": {
    "setup": "Player arrives at abandoned museum",
    "prompt": "Describe the museum exterior at dawn..."
  },
  "choices": [
    {
      "choice_id": "front_entrance",
      "outcome_prompt": {
        "success": {
          "setup": "Doors open via solar power",
          "key_elements": ["Exhibit hall", "Spacecraft displays"]
        }
      }
    }
  ]
}
```

**Detection Logic (GDScript):**
```gdscript
func is_hybrid_mission(mission_data: Dictionary) -> bool:
    """Check if mission uses hybrid narrative generation"""
    if not mission_data.has("stages"):
        return false

    for stage in mission_data.stages:
        if stage.has("narrative_structure"):
            return true

    return false
```

---

## Story API Integration

### 1. Generate Stage Narrative

**When:** Player enters a new mission stage
**Endpoint:** `POST /api/story/generate_narrative`

**GDScript Example:**
```gdscript
# In scripts/ui/mission.gd or similar

func _display_stage_narrative(mission: Dictionary, stage_id: String) -> void:
    """Display narrative for current stage (hybrid or static)"""

    var stage = _find_stage(mission, stage_id)
    if not stage:
        push_error("Stage not found: " + stage_id)
        return

    # Check if hybrid mission
    if stage.has("narrative_structure"):
        # Dynamic narrative generation
        await _generate_and_display_narrative(mission, stage_id)
    else:
        # Static narrative
        _display_static_narrative(stage.description)


func _generate_and_display_narrative(mission: Dictionary, stage_id: String) -> void:
    """Generate dynamic narrative via story API"""

    # Show loading indicator
    narrative_label.text = "Loading..."

    # Build request
    var request_data = {
        "player_id": GameState.get_player_id(),
        "mission_template": mission,
        "stage_id": stage_id,
        "player_state": _build_player_state(),
        "world_context": null  # Story API will fetch if needed
    }

    # Call story API
    var result = await StoryService.generate_narrative(request_data)

    if result.success:
        # Display generated narrative
        narrative_label.text = result.narrative

        # Show cache indicator (optional)
        if result.cached:
            cache_indicator.text = "[cached]"
    else:
        # Fallback to static narrative
        push_warning("Narrative generation failed: " + result.error)
        var stage = _find_stage(mission, stage_id)
        _display_static_narrative(stage.get("description", "Error loading narrative"))


func _build_player_state() -> Dictionary:
    """Build player state for cache key"""
    return {
        "level": GameState.player.level,
        "current_mission": GameState.progress.current_mission,
        "completed_missions": GameState.progress.completed_missions,
        "phase": GameState.progress.phase
    }
```

**Request Example:**
```json
{
  "player_id": "player_12345",
  "mission_template": { /* full hybrid mission JSON */ },
  "stage_id": "arrival",
  "player_state": {
    "level": 3,
    "current_mission": "tutorial_first_salvage_hybrid",
    "completed_missions": ["mission_a", "mission_b"],
    "phase": 1
  },
  "world_context": null
}
```

**Response Example:**
```json
{
  "success": true,
  "narrative": "The Old Aerospace Museum rises from the Nevada desert like a monument to humanity's lost ambitions. Solar panels still gleam in the dawn light, testament to engineering that outlived its creators. Your grandfather's coordinates point to the main hall. But fresh footprints mar the sand—you're not alone here.",
  "cached": false,
  "generation_time_ms": 1847
}
```

---

### 2. Generate Choice Outcomes

**When:** Player makes a choice
**Endpoint:** `POST /api/story/generate_outcome`

**GDScript Example:**
```gdscript
func _on_choice_selected(choice: Dictionary) -> void:
    """Handle player choosing an option"""

    # Check if hybrid choice
    if choice.has("outcome_prompt"):
        # Dynamic outcome generation
        await _generate_and_apply_outcome(choice)
    else:
        # Static outcome
        _apply_static_outcome(choice)


func _generate_and_apply_outcome(choice: Dictionary) -> void:
    """Generate dynamic outcome for player choice"""

    # Show loading
    outcome_label.text = "Processing..."

    # Determine outcome type based on success roll
    var success = _roll_success(choice)
    var outcome_type = "success" if success else "failure"

    # Build request
    var request_data = {
        "player_id": GameState.get_player_id(),
        "choice": {
            "choice_id": choice.choice_id,
            "text": choice.text,
            "outcome_prompt": choice.outcome_prompt.get(outcome_type),
            "consequences": choice.consequences.get(outcome_type)
        },
        "player_state": _build_player_state(),
        "world_context": null
    }

    # Call story API
    var result = await StoryService.generate_outcome(request_data)

    if result.success:
        # Display outcome narrative
        outcome_label.text = result.narrative

        # Apply consequences
        _apply_consequences(result.consequences)

        # Update memory (relationships, flags)
        _update_player_memory(choice, result)

        # Navigate to next stage
        if result.next_stage:
            await _transition_to_stage(result.next_stage)
    else:
        push_error("Outcome generation failed: " + result.error)


func _roll_success(choice: Dictionary) -> bool:
    """Determine if choice succeeds based on skill checks"""
    var success_chance = choice.get("success_chance", 100)

    if success_chance == "skill_based":
        # Check if player meets skill requirement
        var req = choice.get("requirements", {})
        if req.has("skill"):
            var player_skill = GameState.player.skills.get(req.skill, 0)
            return player_skill >= req.get("skill_level", 0)
        return true
    elif typeof(success_chance) == TYPE_INT:
        # Random roll
        return randf() * 100 < success_chance
    else:
        return true


func _apply_consequences(consequences: Dictionary) -> void:
    """Apply consequences to game state"""

    # XP bonus
    if consequences.has("xp_bonus"):
        GameState.add_xp(consequences.xp_bonus)

    # Effects
    if consequences.has("effects"):
        for effect in consequences.effects:
            GameState.add_effect(effect)

    # Story flags
    if consequences.has("story_flags"):
        for flag_key in consequences.story_flags:
            GameState.set_story_flag(flag_key, consequences.story_flags[flag_key])

    # Relationships
    if consequences.has("relationships"):
        for npc in consequences.relationships:
            var delta = consequences.relationships[npc]
            GameState.update_relationship(npc, delta)


func _update_player_memory(choice: Dictionary, result: Dictionary) -> void:
    """Track choice in memory manager"""

    var memory_data = {
        "choice_id": choice.choice_id,
        "choice_text": choice.text,
        "outcome": result.outcome,
        "narrative": result.narrative,
        "timestamp": Time.get_unix_time_from_system()
    }

    # Send to memory manager via API
    await StoryService.add_player_choice(GameState.get_player_id(), memory_data)

    # Update relationships if any
    if result.consequences.has("relationships"):
        for npc in result.consequences.relationships:
            var delta = result.consequences.relationships[npc]
            await StoryService.update_relationship(
                GameState.get_player_id(),
                npc,
                delta
            )
```

**Request Example:**
```json
{
  "player_id": "player_12345",
  "choice": {
    "choice_id": "explain_inheritance",
    "text": "Explain that your grandfather owned this workshop",
    "outcome_prompt": {
      "setup": "Sarah laughs but listens",
      "key_elements": ["Sarah questions 'legal' concept", "Recognizes sincerity", "Steps aside"],
      "tone": "Tense becoming warm",
      "emotion": "Relief and gratitude"
    },
    "consequences": {
      "next_stage": "workshop_open",
      "xp_bonus": 30,
      "relationships": {"sarah": 25, "dex": 15}
    }
  },
  "player_state": { /* ... */ },
  "world_context": null
}
```

**Response Example:**
```json
{
  "success": true,
  "outcome": "success",
  "narrative": "'Legally?' Sarah laughs, but there's no malice in it. She studies your face, searching. Whatever she sees there—honesty, loss, determination—it's enough. 'There's no law left out here. But you've got honest eyes, kid. This place meant something to you.' She steps aside. 'Take your inheritance. Just remember—you'll need friends more than enemies.' Her partner visibly relaxes.",
  "consequences": {
    "next_stage": "workshop_open",
    "effects": ["peaceful_resolution", "potential_ally"],
    "xp_bonus": 30,
    "relationships": {"sarah": 25, "dex": 15},
    "story_flags": {
      "sarah_impressed": true,
      "resolution_method": "diplomacy"
    }
  },
  "next_stage": "workshop_open",
  "generation_time_ms": 2134
}
```

---

### 3. Player Memory Context

**When:** Before generating narrative (optional, for advanced context)
**Endpoint:** `GET /api/story/memory/{player_id}`

**GDScript Example:**
```gdscript
func _get_player_memory_context() -> Dictionary:
    """Fetch player's narrative context from memory manager"""

    var player_id = GameState.get_player_id()
    var result = await StoryService.get_memory_context(player_id, 10)  # Last 10 choices

    if result.success:
        return {
            "recent_choices": result.recent_choices,
            "relationships": result.relationships,
            "active_consequences": result.active_consequences,
            "story_state": result.story_state
        }
    else:
        return {}
```

**Response Example:**
```json
{
  "success": true,
  "recent_choices": [
    {
      "choice_id": "side_entrance",
      "outcome": "success",
      "timestamp": "2025-11-09T10:23:45Z"
    }
  ],
  "relationships": {
    "sarah": 25,
    "dex": 15
  },
  "active_consequences": [
    {
      "consequence_id": "peaceful_resolution",
      "triggered_by": "explain_inheritance",
      "callback_mission": "mission_sarah_returns"
    }
  ],
  "story_state": {
    "current_mission": "tutorial_first_salvage_hybrid",
    "current_arc": "inheritance",
    "resolution_method": "diplomacy"
  }
}
```

---

## Story Service Singleton (GDScript)

Create `scripts/autoload/story_service.gd`:

```gdscript
extends Node

## Story Service - HTTP client for dynamic story engine
##
## Provides methods to interact with story API endpoints.

const BASE_URL = "http://localhost:8001/api/story"

var http_request: HTTPRequest


func _ready() -> void:
    http_request = HTTPRequest.new()
    add_child(http_request)


func generate_narrative(request_data: Dictionary) -> Dictionary:
    """Generate narrative for mission stage"""
    return await _post_request("/generate_narrative", request_data)


func generate_outcome(request_data: Dictionary) -> Dictionary:
    """Generate outcome for player choice"""
    return await _post_request("/generate_outcome", request_data)


func get_memory_context(player_id: String, limit: int = 10) -> Dictionary:
    """Get player memory context"""
    var url = BASE_URL + "/memory/" + player_id + "?limit=" + str(limit)
    return await _get_request(url)


func add_player_choice(player_id: String, choice_data: Dictionary) -> Dictionary:
    """Track player choice (called internally after outcome generation)"""
    # Memory is updated automatically by generate_outcome endpoint
    return {"success": true}


func update_relationship(player_id: String, npc: String, delta: int) -> Dictionary:
    """Update NPC relationship (called internally after outcome generation)"""
    # Relationships updated automatically by generate_outcome endpoint
    return {"success": true}


func invalidate_cache(player_id: String, mission_id: String, player_state: Dictionary) -> Dictionary:
    """Invalidate cached narratives after significant state change"""
    var request_data = {
        "player_id": player_id,
        "mission_id": mission_id,
        "player_state": player_state
    }
    return await _delete_request("/invalidate_cache", request_data)


# HTTP request helpers

func _post_request(endpoint: String, data: Dictionary) -> Dictionary:
    """Make POST request to story API"""
    var url = BASE_URL + endpoint
    var headers = ["Content-Type: application/json"]
    var body = JSON.stringify(data)

    http_request.request(url, headers, HTTPClient.METHOD_POST, body)
    var response = await http_request.request_completed

    return _parse_response(response)


func _get_request(url: String) -> Dictionary:
    """Make GET request to story API"""
    http_request.request(url)
    var response = await http_request.request_completed
    return _parse_response(response)


func _delete_request(endpoint: String, data: Dictionary) -> Dictionary:
    """Make DELETE request to story API"""
    var url = BASE_URL + endpoint
    var headers = ["Content-Type: application/json"]
    var body = JSON.stringify(data)

    http_request.request(url, headers, HTTPClient.METHOD_DELETE, body)
    var response = await http_request.request_completed

    return _parse_response(response)


func _parse_response(response: Array) -> Dictionary:
    """Parse HTTP response"""
    var result = response[0]
    var response_code = response[1]
    var headers = response[2]
    var body = response[3]

    if response_code != 200:
        return {
            "success": false,
            "error": "HTTP " + str(response_code)
        }

    var json = JSON.new()
    var parse_result = json.parse(body.get_string_from_utf8())

    if parse_result != OK:
        return {
            "success": false,
            "error": "JSON parse error"
        }

    return json.data
```

**Register in project.godot:**
```ini
[autoload]
StoryService="*res://scripts/autoload/story_service.gd"
```

---

## Cache Invalidation

**When to Invalidate:**
- Player levels up
- Significant story choice (major branching point)
- Relationship threshold crossed (e.g., hostile → neutral)
- World event occurs

**Example:**
```gdscript
func _on_player_level_up(new_level: int) -> void:
    """Invalidate narrative cache when player levels up"""

    var player_id = GameState.get_player_id()
    var mission_id = GameState.progress.current_mission
    var player_state = {
        "level": new_level,
        "current_mission": mission_id,
        "completed_missions": GameState.progress.completed_missions,
        "phase": GameState.progress.phase
    }

    await StoryService.invalidate_cache(player_id, mission_id, player_state)

    # Regenerate current stage narrative if in mission
    if mission_id:
        await _refresh_current_stage_narrative()
```

---

## Testing Dynamic Narratives

**1. Test with Same Player State:**
```gdscript
# First call
var result1 = await StoryService.generate_narrative(request_data)
print("First call: ", result1.cached)  # false

# Second call (same player state)
var result2 = await StoryService.generate_narrative(request_data)
print("Second call: ", result2.cached)  # true
print("Same narrative: ", result1.narrative == result2.narrative)  # true
```

**2. Test with Different Player State:**
```gdscript
# Player levels up
GameState.player.level += 1

# Regenerate narrative
var result3 = await StoryService.generate_narrative(request_data)
print("After level up: ", result3.cached)  # false (different player hash)
print("Different narrative: ", result1.narrative != result3.narrative)  # likely true
```

**3. Test Relationship Tracking:**
```gdscript
# Make choice that affects Sarah
await _on_choice_selected(diplomatic_choice)

# Check relationship updated
var memory = await StoryService.get_memory_context(player_id)
print("Sarah relationship: ", memory.relationships.get("sarah", 0))  # Should be > 0
```

---

## Fallback Strategy

**Always provide fallback to static content:**

```gdscript
func _display_stage_narrative_safe(mission: Dictionary, stage_id: String) -> void:
    """Display narrative with fallback"""

    var stage = _find_stage(mission, stage_id)

    if stage.has("narrative_structure"):
        # Try dynamic generation
        var result = await StoryService.generate_narrative({
            "player_id": GameState.get_player_id(),
            "mission_template": mission,
            "stage_id": stage_id,
            "player_state": _build_player_state()
        })

        if result.success:
            narrative_label.text = result.narrative
            return

        push_warning("Dynamic narrative failed, using static fallback")

    # Fallback: Use static description or generic text
    var fallback_text = stage.get("description", "The story continues...")
    narrative_label.text = fallback_text
```

---

## Performance Considerations

**1. Caching:**
- First generation: ~1-3 seconds (LLM call)
- Cached result: <100ms (Redis lookup)
- Cache hit rate should be 60-80% for typical gameplay

**2. Loading Indicators:**
```gdscript
func _show_narrative_loading(show: bool) -> void:
    loading_spinner.visible = show
    narrative_label.modulate.a = 0.5 if show else 1.0
    choice_buttons_container.visible = not show
```

**3. Preloading (Optional):**
```gdscript
func _preload_next_stages(mission: Dictionary, current_stage_id: String) -> void:
    """Preload narratives for likely next stages"""

    var current_stage = _find_stage(mission, current_stage_id)
    var next_stage_ids = _get_possible_next_stages(current_stage)

    for next_id in next_stage_ids:
        # Generate in background (don't await)
        StoryService.generate_narrative({
            "player_id": GameState.get_player_id(),
            "mission_template": mission,
            "stage_id": next_id,
            "player_state": _build_player_state()
        })
```

---

## Summary Checklist

**Godot Integration Steps:**

- [ ] Create `StoryService` singleton
- [ ] Add `is_hybrid_mission()` detection
- [ ] Update `_display_stage_narrative()` for dynamic generation
- [ ] Update `_on_choice_selected()` for dynamic outcomes
- [ ] Implement `_apply_consequences()` for relationships and flags
- [ ] Add loading indicators for narrative generation
- [ ] Implement cache invalidation on level up / major events
- [ ] Add fallback to static content if API fails
- [ ] Test with hybrid mission example
- [ ] Test cache hit/miss scenarios
- [ ] Test relationship tracking across choices

**Story API Checklist:**

- [x] `/api/story/generate_narrative` endpoint
- [x] `/api/story/generate_outcome` endpoint
- [x] `/api/story/memory/{player_id}` endpoint
- [x] `/api/story/invalidate_cache` endpoint
- [x] Redis caching with player state hash
- [x] MemoryManager integration
- [x] WorldState integration
- [ ] End-to-end testing

---

## Next Steps

1. **Implement StoryService singleton** in Godot
2. **Update mission.gd** to detect and use hybrid missions
3. **Test with tutorial_hybrid.json**
4. **Create 2-3 more hybrid missions** for variety
5. **Performance testing** (cache hit rates, generation times)
6. **Polish loading UX** (spinners, progress indicators)

---

**Related Documentation:**
- [Dynamic Story Engine](./dynamic-story-engine.md) - Full technical spec
- [Hybrid Mission Example](../../godot/assets/data/missions/mission_tutorial_hybrid.json) - Complete reference
- [Memory Manager](../../python/ai-service/src/story/memory_manager.py) - Player context tracking
- [Story Engine](../../python/ai-service/src/story/story_engine.py) - Narrative generation logic
