# Architecture Documentation

**Purpose:** System architecture, design patterns, and integration specifications.

## Files in This Directory

### [technical-architecture.md](./technical-architecture.md)
**Complete system architecture document.**

Contains:
- Microservices architecture overview
- Component diagrams
- Data models (Python Pydantic + GDScript)
- API endpoint specifications
- Technology stack details
- Design decisions and rationale

**Audience:** Developers, architects, AI agents
**Critical:** Yes - foundation for all development

### [INTEGRATION-GUIDE.md](./INTEGRATION-GUIDE.md)
**Comprehensive integration guide (749 lines).**

Contains:
- Architecture diagrams
- Communication flow documentation
- Complete data models with JSON schemas
- API reference for all Godot singletons
- Integration patterns and best practices
- Security considerations
- Error handling strategies

**Audience:** Developers implementing features
**Critical:** Yes - required reading for all developers

## Architecture Overview

### Microservices Stack

```
┌─────────────────────────────────────┐
│     Godot Game Client (GDScript)    │
│  ┌────────────────────────────────┐ │
│  │   5 Autoload Singletons        │ │
│  │  - ServiceManager              │ │
│  │  - GameState                   │ │
│  │  - SaveManager                 │ │
│  │  - EventBus                    │ │
│  │  - AIService                   │ │
│  └────────────────────────────────┘ │
└──────────────┬──────────────────────┘
               │ HTTP REST
               ↓
┌─────────────────────────────────────┐
│    Gateway Service (Port 17010)     │
│  - Request routing                  │
│  - Service discovery                │
│  - Health aggregation               │
└──────────────┬──────────────────────┘
               │
      ┌────────┴────────┐
      ↓                 ↓
┌─────────────┐   ┌─────────────┐
│ AI Service  │   │  Whisper    │
│ (17011)     │   │  (17012)    │
│             │   │  Optional   │
└──────┬──────┘   └─────────────┘
       │
       ↓
┌─────────────┐
│   Redis     │
│  (17014)    │
│  Caching    │
└─────────────┘
       │
       ↓
┌─────────────────────┐
│  External AI APIs   │
│  - Claude           │
│  - OpenAI           │
│  - Ollama (local)   │
└─────────────────────┘
```

### Key Design Patterns

**Singleton Pattern:** Godot autoload scripts (ServiceManager, GameState, etc.)
**Factory Pattern:** Ship system creation
**Strategy Pattern:** AI provider selection (Claude/OpenAI/Ollama)
**Observer Pattern:** EventBus with 50+ signals
**Repository Pattern:** SaveManager for data persistence

### Data Flow

1. **User Input** → UI button click
2. **Godot Singleton** → AIService.generate_mission()
3. **HTTP Request** → ServiceManager._make_request()
4. **Gateway** → Route to AI Service (17011)
5. **AI Service** → Check Redis cache
6. **Cache Miss** → Generate via LLM
7. **Response** → Cache in Redis (24h TTL)
8. **JSON Return** → Back to Godot
9. **State Update** → GameState updates
10. **Event Trigger** → EventBus.emit_signal()
11. **UI Update** → Listeners respond

## Quick Reference

### Ports (NCC-1701 Registry)
- **17010** - Gateway (NCC-1701-0)
- **17011** - AI Service (NCC-1701-1)
- **17012** - Whisper (NCC-1701-2)
- **17014** - Redis (NCC-1701-4)

### Godot Singletons
```gdscript
ServiceManager  # HTTP client, health checking
GameState       # Central game data
SaveManager     # JSON persistence
EventBus        # Event-driven communication
AIService       # AI content generation
```

### API Endpoints
```
GET  /health
POST /api/chat/message
POST /api/missions/generate
POST /api/dialogue/generate
POST /api/encounters/generate
```

## Related Documentation

- **Setup:** [../../00-getting-started/DEVELOPER-SETUP.md](../../00-getting-started/DEVELOPER-SETUP.md)
- **Testing:** [../../01-user-guides/testing/TESTING-GUIDE.md](../../01-user-guides/testing/TESTING-GUIDE.md)
- **Ports:** [../../06-technical-reference/PORT-MAPPING.md](../../06-technical-reference/PORT-MAPPING.md)
- **Game Design:** [../../03-game-design/core-systems/game-design-document.md](../../03-game-design/core-systems/game-design-document.md)

## For Developers

**New to the codebase?**
1. Read technical-architecture.md for system overview
2. Read INTEGRATION-GUIDE.md for implementation details
3. Review code in godot/scripts/autoload/
4. Check python/gateway/ and python/ai-service/

**Implementing a feature?**
1. Identify affected services (Godot, Gateway, AI?)
2. Review relevant sections in INTEGRATION-GUIDE.md
3. Follow integration patterns
4. Update documentation

**Debugging?**
1. Check architecture diagrams for data flow
2. Verify service connectivity
3. Review error handling patterns
4. Check logs for each service

---

**Navigation:**
- [📚 Documentation Index](../../README.md)
- [🤖 AI Agent Context](../../CLAUDE.md)
- [📁 Developer Guides](..)
