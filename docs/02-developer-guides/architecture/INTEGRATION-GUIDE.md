# Space Adventures - Integration Guide

**Version:** Phase 1, Week 4
**Date:** 2025-11-06
**Status:** Foundation Complete - Integration Verified

## Overview

This document describes how the Godot game client integrates with the backend microservices architecture, providing a complete understanding of the communication flow, data formats, and integration patterns.

## Architecture Overview

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                     Godot Game Client                        │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │ GameState  │  │SaveManager │  │ EventBus   │            │
│  └────────────┘  └────────────┘  └────────────┘            │
│         │                                                    │
│  ┌──────▼──────────────────────────────────────┐            │
│  │        ServiceManager (HTTP Client)         │            │
│  └──────┬──────────────────────────────────────┘            │
│         │                                                    │
│  ┌──────▼──────────────────────────────────────┐            │
│  │          AIService (API Wrapper)            │            │
│  └──────┬──────────────────────────────────────┘            │
└─────────┼──────────────────────────────────────────────────┘
          │ HTTP POST (JSON)
          ▼
┌─────────────────────────────────────────────────────────────┐
│            Backend Microservices (Docker)                   │
│                                                              │
│  ┌───────────────────────────────────────────────┐          │
│  │     Gateway Service (Port 17010)              │          │
│  │              NCC-1701-0                       │          │
│  │  - Request routing                            │          │
│  │  - Health aggregation                         │          │
│  │  - Service discovery                          │          │
│  └───────┬──────────────────────────────────────┘          │
│          │                                                   │
│  ┌───────▼──────────────────────────────────────┐          │
│  │     AI Service (Port 17011)                   │          │
│  │              NCC-1701-1                       │          │
│  │  - Content generation (missions, dialogue)    │          │
│  │  - Chat system (4 AI personalities)           │          │
│  │  - Multi-provider routing                     │          │
│  │    (Claude, OpenAI, Ollama)                   │          │
│  └───────┬──────────────────────────────────────┘          │
│          │                                                   │
│  ┌───────▼──────────────────────────────────────┐          │
│  │     Redis Cache (Port 17014)                  │          │
│  │              NCC-1701-4                       │          │
│  │  - Response caching (24h TTL)                 │          │
│  │  - SHA-256 prompt hashing                     │          │
│  └───────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

### Port Registry (NCC-1701 System)

| Service | Port | Registry | Purpose |
|---------|------|----------|---------|
| Gateway | 17010 | NCC-1701-0 | Single entry point, routing |
| AI Service | 17011 | NCC-1701-1 | Content generation |
| Whisper | 17012 | NCC-1701-2 | Voice transcription (optional) |
| Image Gen | 17013 | NCC-1701-3 | Image generation (future) |
| Redis | 17014 | NCC-1701-4 | Cache & sessions |
| PostgreSQL | 17015 | NCC-1701-5 | Database (future) |

## Communication Flow

### 1. Service Health Check

**Godot Client → Gateway → AI Service**

```
ServiceManager.check_service("ai")
    ↓ HTTP GET
http://localhost:17010/health/all
    ↓ Gateway checks all services
http://ai-service:17011/health
    ↓ Response
{
  "status": "healthy",
  "service": "ai-service",
  "providers": ["ollama"],
  "cache_enabled": true
}
```

### 2. AI Chat Message

**Godot Client → Gateway → AI Service → Redis → AI Provider**

```gdscript
// GDScript
AIService.chat_message("Hello ATLAS", "atlas", session_id)
```

```
    ↓ HTTP POST
http://localhost:17011/api/chat/message
    ↓ JSON Body
{
  "session_id": "session_123",
  "message": "Hello ATLAS",
  "ai_personality": "atlas",
  "game_state": {
    "player": {"name": "Captain", "level": 1},
    "ship": {"name": "Ship", "ship_class": "Scout"}
  }
}
    ↓ AI Service checks Redis cache
Redis: GET ai_response:<sha256_hash>
    ↓ Cache miss, generate content
Ollama/Claude/OpenAI: Generate response
    ↓ Cache result
Redis: SET ai_response:<hash> = response (TTL: 24h)
    ↓ JSON Response
{
  "success": true,
  "ai_personality": "atlas",
  "ai_name": "ATLAS",
  "message": "Hello, Captain. How may I assist?",
  "cached": false,
  "generation_time_ms": 1234.56
}
    ↓ Parse in Godot
GameState updated
EventBus.chat_message_received.emit()
UI displays message
```

### 3. Mission Generation

**Godot Client → AI Service → Redis → AI Provider**

```gdscript
// GDScript
AIService.generate_mission("medium", "salvage", "Old Earth Ruins")
```

```
    ↓ HTTP POST
http://localhost:17011/api/missions/generate
    ↓ JSON Body
{
  "difficulty": "medium",
  "mission_type": "salvage",
  "location": "Old Earth Ruins",
  "game_state": {
    "player": {
      "level": 5,
      "rank": "Lieutenant",
      "skills": {"engineering": 10, "combat": 5}
    },
    "ship": {
      "ship_class": "Frigate",
      "operational_systems": ["hull", "power", "sensors"]
    }
  }
}
    ↓ AI Service builds context
Prompt Template + Game State = Full Prompt
    ↓ Check cache
Redis: GET ai_response:<prompt_hash>
    ↓ Cache miss, generate
AI Provider generates mission JSON
    ↓ Validate with Pydantic
MissionResponse schema validation
    ↓ Cache and return
Redis: SET + Return to Godot
    ↓ JSON Response
{
  "success": true,
  "mission": {
    "mission_id": "mission_salvage_001",
    "title": "Salvage Operation: Hull Components",
    "type": "salvage",
    "difficulty": "medium",
    "location": "Old Earth Ruins",
    "description": "...",
    "stages": [...]
  },
  "cached": false,
  "generation_time_ms": 2345.67
}
    ↓ Parse in Godot
Display mission in UI
Player can accept/decline
```

## Data Models

### GameState (Godot → Backend)

Sent with most API requests to provide context for AI generation.

```json
{
  "player": {
    "name": "Captain Smith",
    "level": 5,
    "rank": "Lieutenant",
    "skills": {
      "engineering": 10,
      "diplomacy": 5,
      "combat": 8,
      "science": 3
    }
  },
  "ship": {
    "name": "USS Discovery",
    "ship_class": "Frigate",
    "operational_systems": [
      "hull",
      "power",
      "propulsion",
      "sensors",
      "shields"
    ]
  },
  "progress": {
    "phase": 1,
    "completed_missions_count": 12
  }
}
```

### Mission Response (Backend → Godot)

```json
{
  "success": true,
  "mission": {
    "mission_id": "mission_001",
    "title": "Salvage Operation",
    "type": "salvage",
    "location": "Old Earth Ruins",
    "difficulty": "medium",
    "description": "Recover ship components...",
    "stages": [
      {
        "stage_id": "stage_1",
        "description": "Approach the ruins",
        "choices": [
          {
            "choice_id": "choice_1",
            "text": "Scan for dangers",
            "requirements": {
              "skill": "science",
              "skill_level": 5
            },
            "consequences": {
              "success": {
                "next_stage": "stage_2",
                "xp_bonus": 25
              },
              "failure": {
                "next_stage": "stage_fail"
              }
            }
          }
        ]
      }
    ],
    "rewards": {
      "xp": 100,
      "items": ["hull_component_lvl2"]
    }
  },
  "cached": false,
  "generation_time_ms": 2341.23
}
```

### Chat Response (Backend → Godot)

```json
{
  "success": true,
  "ai_personality": "atlas",
  "ai_name": "ATLAS",
  "message": "Affirmative, Captain. Ship systems are nominal...",
  "command_executed": null,
  "actions": null,
  "cached": false,
  "generation_time_ms": 1234.56
}
```

### Dialogue Response (Backend → Godot)

```json
{
  "success": true,
  "npc_name": "Jax Morgan",
  "npc_role": "Salvage Yard Owner",
  "dialogue": "Ah, looking for hull parts? I've got a few...",
  "mood": "friendly",
  "cached": false,
  "generation_time_ms": 892.34
}
```

## Integration Patterns

### 1. Service Availability Check

**Always check service availability before making requests:**

```gdscript
if not ServiceManager.is_service_available("ai"):
    show_error("AI service unavailable")
    # Use fallback static content
    return

# Service is available, proceed with request
var result = await AIService.generate_mission("medium")
```

### 2. Async HTTP Requests

**All service calls are asynchronous using `await`:**

```gdscript
# Start request (non-blocking)
var result = await AIService.chat_message(message, "atlas")

# Code here executes after response received
if result.success:
    display_chat(result.data.message)
else:
    show_error(result.error)
```

### 3. Error Handling

**Three-level error handling:**

```gdscript
# Level 1: Service availability
if not ServiceManager.is_service_available("ai"):
    return _error_fallback("Service offline")

# Level 2: HTTP request
var result = await AIService.generate_mission("medium")
if not result.success:
    return _error_fallback(result.error)

# Level 3: Response validation
if not result.data.has("mission"):
    return _error_fallback("Invalid response format")

# Success path
process_mission(result.data.mission)
```

### 4. Event-Driven Updates

**Use EventBus for decoupled updates:**

```gdscript
# Service makes request
var result = await AIService.chat_message(msg, "atlas")

# AIService emits event on success
# EventBus.chat_message_received.emit(ai_personality, message, metadata)

# UI listens to event (separate script)
func _ready():
    EventBus.chat_message_received.connect(_on_chat_received)

func _on_chat_received(ai: String, msg: String, meta: Dictionary):
    display_message(ai, msg)
```

### 5. Caching Awareness

**Leverage backend caching for performance:**

```gdscript
# First request: slow (1-5 seconds)
var result1 = await AIService.generate_mission("medium")
# result1.data.cached == false

# Same request again: fast (<100ms)
var result2 = await AIService.generate_mission("medium")
# result2.data.cached == true

# Cache TTL: 24 hours
# Cache key: SHA-256 of prompt + parameters
```

## Service Configuration

### Environment Variables

All services use centralized configuration via `.env`:

```bash
# NCC-1701 Port Registry
GATEWAY_PORT=17010
AI_SERVICE_PORT=17011
WHISPER_SERVICE_PORT=17012
REDIS_PORT=17014

# AI Provider Selection
AI_PROVIDER_STORY=claude      # For critical story missions
AI_PROVIDER_RANDOM=ollama     # For random content
AI_PROVIDER_QUICK=ollama      # For quick generation

# API Keys (optional - use Ollama for free local AI)
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...

# Ollama Configuration (local)
OLLAMA_BASE_URL=http://host.docker.internal:11434
OLLAMA_MODEL=llama3.2:3b

# Cache Settings
CACHE_ENABLED=true
CACHE_TTL_HOURS=24
```

### Godot Configuration

Service URLs are hardcoded in singletons but can be overridden:

```gdscript
# godot/scripts/autoload/service_manager.gd
const SERVICES: Dictionary = {
    "gateway": "http://localhost:17010",
    "ai": "http://localhost:17011",
    "whisper": "http://localhost:17012",
}

# To override for testing:
ServiceManager.SERVICES["ai"] = "http://localhost:27011"
```

## Testing Integration

### Manual Testing

```bash
# 1. Start backend services
docker compose up -d

# 2. Verify health
curl http://localhost:17010/health/all

# 3. Open Godot
godot godot/project.godot

# 4. Press F5 to run test scene

# 5. Click test buttons:
#    - Test Service Connection
#    - Test AI Chat
#    - Test Mission Generation
#    - Test Dialogue Generation
#    - Test Save/Load
```

### Automated Testing

```bash
# Backend tests
cd python/ai-service
pytest tests/

# Integration tests (future)
cd python/tests
pytest test_integration.py
```

## Performance Considerations

### Response Times

| Operation | Target | Acceptable | Needs Optimization |
|-----------|--------|------------|-------------------|
| Health check | <50ms | <100ms | >200ms |
| Chat (cached) | <100ms | <200ms | >500ms |
| Chat (uncached) | 1-3s | <5s | >10s |
| Mission gen (cached) | <100ms | <200ms | >500ms |
| Mission gen (uncached) | 2-5s | <10s | >20s |
| Save to disk | <50ms | <100ms | >200ms |

### Optimization Strategies

1. **Caching:**
   - 24-hour TTL for AI responses
   - SHA-256 prompt hashing
   - Redis for fast lookup

2. **Request Pooling:**
   - 5 concurrent HTTP request slots
   - Reuse connections

3. **Async Operations:**
   - All service calls non-blocking
   - UI remains responsive

4. **Lazy Loading:**
   - Services checked on-demand
   - 30-second refresh interval

5. **Graceful Degradation:**
   - Fallback to static content
   - Service offline doesn't crash game

## Troubleshooting

### Common Issues

**1. "Service unavailable"**
- Check Docker: `docker compose ps`
- Check logs: `docker compose logs ai-service`
- Restart: `docker compose restart`

**2. "Connection refused"**
- Verify ports: `netstat -an | grep 17010`
- Check firewall settings
- Verify `.env` port configuration

**3. "Invalid response format"**
- Check AI service logs for validation errors
- Verify Pydantic models match
- Check network issues (partial response)

**4. "Timeout"**
- Increase timeout in AIService (current: 30s)
- Check AI provider status (Ollama running?)
- Network latency issues

**5. "Cache not working"**
- Check Redis: `docker compose logs redis`
- Verify CACHE_ENABLED=true in .env
- Check Redis connection: `redis-cli -p 17014 ping`

### Debug Mode

Enable verbose logging:

```gdscript
# In Godot scripts
print("ServiceManager: Making request to ", url)
print("Response: ", JSON.stringify(response))

# Check Godot Output tab for logs
```

```bash
# Backend logs
docker compose logs -f gateway
docker compose logs -f ai-service

# Specific service
docker compose logs ai-service --tail=100
```

## Security Considerations

### 1. API Keys

- **Never commit** `.env` to git
- Use `.env.example` as template
- Keep keys secure

### 2. Input Validation

- All user input validated in backend
- Pydantic schemas enforce types
- SQL injection not possible (no DB yet)

### 3. Rate Limiting

- Not implemented in Phase 1
- TODO: Add rate limiting to Gateway
- TODO: Add request throttling

### 4. CORS

- Currently disabled for local development
- TODO: Configure proper CORS for production

## Future Enhancements

### Phase 2 (Post-Foundation)

1. **WebSocket Support:**
   - Real-time chat updates
   - Live mission events
   - Multiplayer foundations

2. **Authentication:**
   - User accounts
   - Save sync to cloud
   - Leaderboards

3. **Analytics:**
   - Telemetry collection
   - Performance monitoring
   - User behavior tracking

4. **CDN Integration:**
   - Asset hosting
   - Faster downloads
   - Reduced bandwidth

## API Reference

### ServiceManager

```gdscript
# Check single service
var available: bool = ServiceManager.is_service_available("ai")

# Check all services
var results: Dictionary = await ServiceManager.check_all_services()

# Get service URL
var url: String = ServiceManager.get_service_url("gateway")

# Get cached status
var status: Dictionary = ServiceManager.get_service_status("ai")
```

### AIService

```gdscript
# Generate mission
var result: Dictionary = await AIService.generate_mission(
    "medium",           # difficulty
    "salvage",          # mission_type (optional)
    "Old Earth Ruins"   # location (optional)
)

# Chat message
var result: Dictionary = await AIService.chat_message(
    "Hello ATLAS",      # message
    "atlas",            # ai_personality
    "session_123",      # session_id (optional)
    []                  # conversation_context (optional)
)

# Generate dialogue
var result: Dictionary = await AIService.generate_dialogue(
    "Jax Morgan",       # npc_name
    "Salvage Owner",    # npc_role
    "Player arrives",   # context
    "asks about parts"  # player_action (optional)
)

# Test connection
var success: bool = await AIService.test_connection()

# Get health info
var health: Dictionary = AIService.get_health_info()
```

### GameState

```gdscript
# Player functions
GameState.add_xp(100, "mission_complete")
GameState.increase_skill("engineering", 5)

# Ship functions
GameState.install_system("hull", 2, "part_id_123")
GameState.damage_system("shields", 25)
GameState.repair_system("shields", 50)

# Inventory functions
GameState.add_item({"id": "item_123", "type": "hull_part"})
GameState.remove_item("item_123")

# Progress functions
GameState.complete_mission("mission_001")
var count: int = GameState.get_completed_missions_count()

# Serialization
var data: Dictionary = GameState.to_dict()
GameState.from_dict(saved_data)
```

### SaveManager

```gdscript
# Save operations
var success: bool = SaveManager.save_game(1)  # slot 1-5
var success: bool = SaveManager.quick_save()  # slot 1
var success: bool = SaveManager.auto_save()   # slot 0

# Load operations
var success: bool = SaveManager.load_game(1)
var success: bool = SaveManager.quick_load()

# Save info
var exists: bool = SaveManager.save_exists(1)
var info: Dictionary = SaveManager.get_save_info(1)
var all_saves: Array = SaveManager.get_all_save_info()

# Utility
var time_str: String = SaveManager.format_playtime(3661.5)
# Returns: "1h 1m"
```

### EventBus

```gdscript
# Connect to signals
EventBus.mission_completed.connect(_on_mission_completed)
EventBus.xp_gained.connect(_on_xp_gained)
EventBus.chat_message_received.connect(_on_chat_received)

# Emit events (usually done by systems)
EventBus.mission_completed.emit(mission_id, rewards)
EventBus.system_installed.emit("hull", 2)

# Convenience functions
EventBus.notify("Game saved!", "success", 3.0)
EventBus.error("Save Failed", "Disk full")
```

## Dynamic Story System Integration

The dynamic story engine provides AI-generated narratives that adapt to player choices and game state.

### Architecture

```
Godot (Mission Scene)
    ↓
StoryService Singleton
    ↓ HTTP POST
Story API (/api/story/*)
    ↓
StoryEngine + MemoryManager + WorldState
    ↓
LLM (OpenAI/Ollama)
    ↓
Redis Cache (1-hour TTL)
```

### Godot Side: StoryService Singleton

**Location:** `godot/scripts/autoload/story_service.gd`

**Key Methods:**
- `generate_narrative(request_data: Dictionary) -> Dictionary`
- `generate_outcome(request_data: Dictionary) -> Dictionary`
- `get_memory_context(player_id: String) -> Dictionary`
- `build_player_state() -> Dictionary`
- `get_player_id() -> String`
- `is_available() -> bool`

**Example Usage:**

```gdscript
# Check if service is available
if StoryService.is_available():
    # Generate narrative for current stage
    var result = await StoryService.generate_narrative({
        "player_id": StoryService.get_player_id(),
        "mission_template": current_mission,
        "stage_id": current_stage.stage_id,
        "player_state": StoryService.build_player_state()
    })

    if result.success:
        narrative_label.text = result.narrative
        print("Cached: ", result.cached)
        print("Generation time: ", result.generation_time_ms, "ms")
    else:
        # Fallback to static content
        narrative_label.text = current_stage.description
else:
    # Service unavailable, use static content
    narrative_label.text = current_stage.description
```

### Hybrid Mission Detection

```gdscript
func _is_hybrid_mission() -> bool:
    for stage in mission.stages:
        if stage.has("narrative_structure"):
            return true
    return false

func _load_stage(stage: Dictionary) -> void:
    if _is_hybrid_mission():
        # Use dynamic narrative generation
        var narrative = await _generate_stage_narrative(stage)
        display_narrative(narrative)
    else:
        # Use static description
        display_narrative(stage.description)
```

### Memory Management

Player choices are automatically tracked and influence future narratives:

```gdscript
func _handle_choice(choice: Dictionary) -> void:
    # Choice is sent to story engine
    var outcome = await StoryService.generate_outcome({
        "player_id": StoryService.get_player_id(),
        "choice": choice,
        "stage_id": current_stage.stage_id,
        # ... other context
    })

    # Memory manager automatically:
    # - Adds choice to player history (last 100)
    # - Updates relationships if specified
    # - Tracks consequences
```

### Cache Invalidation

Cache is automatically invalidated when player state changes (level up, mission completion). Manual invalidation:

```gdscript
func _on_major_state_change() -> void:
    var result = await StoryService.invalidate_cache(
        player_id,
        mission_id,
        player_state
    )
    print("Invalidated ", result.deleted_count, " cache entries")
```

### Error Handling

```gdscript
var result = await StoryService.generate_narrative(request_data)

if not result.success:
    match result.error:
        "HTTP 503":
            show_error("AI service temporarily unavailable")
        "timeout":
            show_error("Generation timed out, using fallback")
        _:
            show_error("Unknown error: " + result.error)

    # Always fallback to static content
    display_narrative(stage.get("description", "Story continues..."))
```

### Performance Considerations

- **First request:** 800-2000ms (LLM generation)
- **Cached request:** 10-50ms (Redis retrieval)
- **Cache hit rate:** ~60-80% during normal gameplay
- **Cache TTL:** 1 hour

### Related Documentation

- [Story API Reference](../../06-technical-reference/STORY-API-REFERENCE.md)
- [Dynamic Story Engine](../../05-ai-content/story-engine/README.md)
- [Godot Story Integration](../../05-ai-content/godot-story-integration.md)
- [Memory Manager Reference](../../06-technical-reference/MEMORY-MANAGER-REFERENCE.md)
- [World State Reference](../../06-technical-reference/WORLD-STATE-REFERENCE.md)

## Conclusion

The integration between Godot and backend services is complete and functional. The architecture supports:

- ✅ Asynchronous HTTP communication
- ✅ Multi-provider AI generation
- ✅ Response caching for performance
- ✅ Graceful error handling
- ✅ Event-driven architecture
- ✅ Comprehensive testing capabilities

**Ready for Phase 2 development!**

---

**For Questions:**
- Architecture: docs/technical-architecture.md
- Game Design: docs/game-design-document.md
- Testing: docs/TESTING-GUIDE.md
- Godot: godot/CLAUDE.md
