# architecture - AI Agent Context

**Purpose:** System architecture, design patterns, and integration specifications.

## Directory Contents

### Key Files
1. **technical-architecture.md** - Complete system architecture
   - Microservices overview
   - Component diagrams
   - Technology stack
   - Design decisions

2. **INTEGRATION-GUIDE.md** (749 lines) - Integration specifications
   - Architecture diagrams
   - Communication flows
   - Data models and schemas
   - API reference
   - Integration patterns
   - Security considerations

## When to Use This Documentation

**Use when:**
- Starting any development work (always read first)
- Understanding system design
- Implementing new features
- Debugging integration issues
- Making architectural decisions
- Onboarding new developers
- Planning refactoring

## Common Tasks

### Task: Understand the architecture
1. Read technical-architecture.md overview
2. Study microservices diagram
3. Understand data flow
4. Review integration patterns in INTEGRATION-GUIDE.md

### Task: Implement new backend service
1. Review microservices architecture
2. Check port registry (17010-17099)
3. Follow service template pattern
4. Implement health endpoint
5. Add to docker-compose.yml
6. Update INTEGRATION-GUIDE.md

### Task: Add new Godot feature
1. Identify which singleton handles functionality
2. Review singleton API in INTEGRATION-GUIDE.md
3. Follow integration patterns
4. Use EventBus for decoupling
5. Update GameState if needed
6. Emit appropriate signals

### Task: Add new API endpoint
1. Determine service (Gateway vs AI Service)
2. Define Pydantic models
3. Implement endpoint
4. Add caching if appropriate
5. Update INTEGRATION-GUIDE.md API reference
6. Add corresponding Godot client method

## Relationships

**Core Documents:**
- Most critical directory for technical work
- All implementation follows these specifications
- Single source of truth for architecture

**Depends On:**
- `../../06-technical-reference/PORT-MAPPING.md` - Port registry

**Informs:**
- All development work
- Testing procedures
- Deployment configuration
- Game design decisions

## Architectural Patterns

### Microservices Pattern
**Purpose:** Separation of concerns, independent scaling
**Implementation:**
- Gateway: Entry point and routing
- AI Service: Content generation and caching
- Whisper: Voice transcription (optional)
- Redis: Shared caching layer

### Singleton Pattern (Godot)
**Purpose:** Global access to core functionality
**Implementation:**
- ServiceManager: HTTP communication
- GameState: Central data store
- SaveManager: Persistence layer
- EventBus: Event distribution
- AIService: AI client

**Anti-pattern Warning:** Don't create additional singletons unless absolutely necessary. 5 is enough.

### Observer Pattern (EventBus)
**Purpose:** Decoupled communication
**Implementation:**
- 50+ signal definitions
- Publishers emit signals
- Subscribers connect to signals
- No direct dependencies

**Example:**
```gdscript
# Publisher (AIService)
EventBus.chat_message_received.emit("atlas", "Hello", {})

# Subscriber (UI)
EventBus.chat_message_received.connect(_on_chat_message)
```

### Repository Pattern (SaveManager)
**Purpose:** Abstraction over persistence
**Implementation:**
- save_game(slot: int) → bool
- load_game(slot: int) → bool
- list_saves() → Array
- delete_save(slot: int) → bool

### Strategy Pattern (AI Providers)
**Purpose:** Swappable AI implementations
**Implementation:**
```python
# Python AI service
class AIProvider(ABC):
    async def generate(prompt: str) -> str

class ClaudeProvider(AIProvider): ...
class OpenAIProvider(AIProvider): ...
class OllamaProvider(AIProvider): ...
```

## Data Flow Analysis

### User Interaction → Backend → Response
```
1. User clicks "Generate Mission"
2. UIButton._on_pressed()
3. AIService.generate_mission(difficulty, type, location)
4. ServiceManager._make_post_request(url, body)
5. HTTPRequest.request(url, headers, body)
6. Gateway receives POST /api/missions/generate
7. Gateway routes to AI Service (17011)
8. AI Service checks Redis cache (SHA-256 hash)
9. Cache miss → LLM generation
10. Response cached (24h TTL)
11. JSON returned → Gateway → Godot
12. AIService parses response
13. GameState updates (if needed)
14. EventBus.mission_generated.emit(mission_data)
15. UI updates via signal connection
```

### Save/Load Flow
```
1. User presses 'S' or clicks Save
2. SaveManager.save_game(slot)
3. GameState.to_dict() → Dictionary
4. JSON.stringify(data) → String
5. FileAccess.open(path, WRITE)
6. Write JSON to file
7. Close file
8. EventBus.game_saved.emit(slot, metadata)
9. UI shows "Game Saved" notification
```

## Integration Patterns

### Pattern 1: Async HTTP Request
**Use for:** All backend communication
```gdscript
func generate_mission(difficulty: String) -> Dictionary:
    var url = AI_SERVICE_URL + "/api/missions/generate"
    var body = {"difficulty": difficulty, "game_state": _prepare_game_state()}
    return await _make_post_request(url, body)
```

### Pattern 2: Event-Driven Update
**Use for:** Decoupled communication
```gdscript
# Publisher
func _on_xp_gained(amount: int):
    GameState.player.xp += amount
    EventBus.xp_gained.emit(amount, "mission_complete")

# Subscriber
func _ready():
    EventBus.xp_gained.connect(_on_xp_gained)
```

### Pattern 3: Caching Strategy
**Use for:** Expensive AI operations
```python
# Check cache first
cache_key = hashlib.sha256(prompt.encode()).hexdigest()
cached = await redis.get(cache_key)
if cached:
    return json.loads(cached)

# Generate and cache
result = await ai_provider.generate(prompt)
await redis.setex(cache_key, 86400, json.dumps(result))
return result
```

### Pattern 4: Error Handling
**Use for:** Graceful degradation
```gdscript
var result = await AIService.generate_mission("medium")
if not result.success:
    push_error("Mission generation failed: " + result.error)
    # Fallback to hardcoded mission or show error to user
    return null
return result.data.mission
```

## AI Agent Instructions

**When implementing features:**
1. Always review both technical-architecture.md and INTEGRATION-GUIDE.md first
2. Follow existing patterns (don't invent new ones)
3. Use appropriate singleton for functionality
4. Emit EventBus signals for state changes
5. Handle errors gracefully

**When adding services:**
1. Use NCC-1701 port range (17xxx)
2. Implement /health endpoint
3. Add to docker-compose.yml
4. Update PORT-MAPPING.md
5. Update INTEGRATION-GUIDE.md

**When modifying architecture:**
1. Document decision and rationale
2. Update architecture diagrams
3. Update both technical-architecture.md and INTEGRATION-GUIDE.md
4. Notify team/users
5. Plan migration if needed

## Quick Reference

**Godot → Backend Communication:**
```
Godot Singleton → ServiceManager → HTTPRequest → Gateway → Service
```

**Backend → Godot Response:**
```
Service → JSON Response → Gateway → Godot → Parse → GameState → EventBus → UI
```

**Event Flow:**
```
Action → State Change → EventBus.emit_signal() → Listeners Update
```

**Cache Flow:**
```
Request → Check Redis → Hit? Return : Generate → Cache → Return
```

## Critical Files to Keep in Sync

When modifying architecture, update ALL of these:
1. technical-architecture.md - High-level design
2. INTEGRATION-GUIDE.md - Implementation details
3. ../../06-technical-reference/PORT-MAPPING.md - Port registry
4. ../../00-getting-started/DEVELOPER-SETUP.md - Setup instructions
5. docker-compose.yml - Service configuration
6. Godot singleton code - Implementation

---

**Parent Context:** [../../CLAUDE.md](../../CLAUDE.md)
**Directory Index:** [README.md](./README.md)
**Developer Guides:** [../CLAUDE.md](../CLAUDE.md)
