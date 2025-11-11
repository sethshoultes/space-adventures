# 02-developer-guides - AI Agent Context

**Purpose:** Technical implementation guides, architecture, and project management for developers.

## Directory Contents

### Subdirectories
- **architecture/** - System design and integration patterns
- **project-management/** - Development planning and roadmaps
- **deployment/** - CI/CD and infrastructure

### Key Files by Subdirectory

**architecture/**
- technical-architecture.md - Complete system architecture
- INTEGRATION-GUIDE.md - Godot ↔ Backend integration (749 lines)

**project-management/**
- development-organization.md - Master development plan
- mvp-roadmap.md - Week-by-week MVP breakdown

**deployment/**
- ci-cd-deployment.md - Automated deployment configuration

## When to Use This Directory

**Use this documentation when:**
- Understanding system architecture
- Implementing new features
- Integrating Godot with backend
- Planning development work
- Setting up CI/CD
- Deploying services
- Onboarding developers

## Common Tasks

### Task: Understand the architecture
1. Read architecture/technical-architecture.md
2. Review microservices diagram
3. Understand data flow: Godot → Gateway → AI Service
4. Check architecture/INTEGRATION-GUIDE.md for details

### Task: Implement new feature
1. Check project-management/development-organization.md for current phase
2. Review architecture/technical-architecture.md for affected components
3. Read architecture/INTEGRATION-GUIDE.md for integration patterns
4. Follow SOLID principles from root CLAUDE.md
5. Update documentation when done

### Task: Deploy services
1. Read deployment/ci-cd-deployment.md
2. Configure environment variables
3. Set up Docker Compose
4. Configure CI/CD pipeline
5. Test deployment

### Task: Plan next phase
1. Review project-management/development-organization.md
2. Check project-management/mvp-roadmap.md for timing
3. Identify dependencies
4. Break down into weekly tasks
5. Update roadmap

## Relationships

**Core Documentation:**
- Most critical directory for technical work
- All implementation starts here
- Architecture decisions documented here

**Depends On:**
- `../00-getting-started/DEVELOPER-SETUP.md` - Environment setup
- `../06-technical-reference/PORT-MAPPING.md` - Port configuration

**Informs:**
- All implementation work
- Testing procedures in `../01-user-guides/`
- Game design decisions in `../03-game-design/`

## Key Concepts

### Microservices Architecture
```
Godot (GDScript)
    ↓ HTTP
ServiceManager → Gateway (17010)
    ↓
    ├→ AI Service (17011) → Redis (17014)
    └→ Whisper (17012)
    ↓
External APIs (Claude, OpenAI, Ollama)
```

### Godot Integration Patterns

**Singletons (Autoload):**
1. **ServiceManager** - HTTP client, service health checking, gateway fallback
2. **GameState** - Central game data (player, ship, inventory, economy)
3. **SaveManager** - JSON persistence (5 slots + autosave)
4. **EventBus** - 55+ signals for decoupled communication
5. **AIService** - AI content generation client (legacy)
6. **StoryService** - Dynamic Story Engine client (Memory Manager, World State)
7. **MissionManager** - Mission flow, rewards, progression tracking
8. **AIPersonalityManager** - Multi-AI personality system (4 personalities)
9. **AdaptiveLayoutManager** - Context-aware UI layout calculations
10. **PartRegistry** - Data-driven parts/systems/economy (720+ lines)

**Communication Flow:**
```
UI Button Click
    ↓
AI Service (singleton)
    ↓
ServiceManager._make_request()
    ↓
HTTP POST → Gateway → AI Service
    ↓
JSON Response
    ↓
GameState update
    ↓
EventBus.emit_signal()
    ↓
UI Update
```

### Development Milestones

**This project uses milestone-based development, not timeline-based phases.**

**Milestone 1: Proof of Concept** (Current - 92% complete) ✅
- ✅ Microservices architecture (Gateway, AI Service, Whisper, Redis)
- ✅ NCC-1701 port system (17010-17014)
- ✅ Godot foundation (10 autoload singletons, 3,600+ lines)
- ✅ Core ship systems (Hull, Power, Propulsion Level 0-5)
- ✅ Workshop UI with economy integration
- ✅ Mission system with scrolling narrative log
- ✅ Magentic UI with 4 AI personalities
- ✅ Dynamic Story Engine (Memory Manager, World State)
- ✅ Hybrid Economy (PartRegistry, credits + parts)
- ✅ Main menu with DALL-E background
- ⏳ Testing: Full game playthrough validation

**Milestone 2: Expand Content** (Future - after M1 validation)
- Add more systems (Warp, Life Support)
- Add more missions (salvage, exploration, story)
- Expand AI personalities and interjections
- UI improvements and polish

**Milestone 3: Share It** (Future - public release)
- All 10 systems complete
- 10+ missions total
- Polish and deployment preparation
- Public release on GitHub/itch.io

**See:** `/ROADMAP.md` for complete milestone checklists and `/STATUS.md` for current progress

### Design Principles

**SOLID:**
- Single Responsibility: GameState = data, Managers = logic
- Open/Closed: Extend ship systems, don't modify base
- Liskov Substitution: All ShipSystems interchangeable
- Interface Segregation: Separate concerns (Upgradeable, Damageable)
- Dependency Inversion: Depend on abstractions (AIProvider)

**DRY:** Single source of truth for all data
**KISS:** Simplest solution that works
**YAGNI:** Build only what's needed now

## AI Agent Instructions

**When implementing features:**
1. Check current phase in project-management/development-organization.md
2. Read relevant architecture docs
3. Follow integration patterns from architecture/INTEGRATION-GUIDE.md
4. Apply SOLID principles
5. Write tests
6. Update documentation

**When debugging:**
1. Check architecture diagrams for data flow
2. Verify service connectivity
3. Review integration patterns
4. Check logs for each service
5. Test integration points

**When planning:**
1. Review development-organization.md for roadmap
2. Check mvp-roadmap.md for timing
3. Identify dependencies between features
4. Break work into weekly chunks
5. Update project management docs

## Architecture Decision Records

### ADR-001: Microservices Architecture
**Decision:** Use microservices instead of monolith
**Rationale:** Separation of concerns, independent scaling, AI service isolation
**Status:** Implemented

### ADR-002: NCC-1701 Port System
**Decision:** Use Star Trek-themed ports (17010-17099)
**Rationale:** Avoid conflicts with common ports, memorable, thematic
**Status:** Implemented

### ADR-003: Godot Singletons
**Decision:** 10 autoload singletons for global functionality
**Rationale:** Global access, persistent across scenes, clear separation of concerns. Expanded from initial 5 to include advanced systems (Magentic UI, Story Engine, Economy)
**Status:** Implemented (3,600+ lines total)

### ADR-004: JSON Save Format
**Decision:** Use JSON for save files (not binary)
**Rationale:** Human-readable, debuggable, version-migratable
**Status:** Implemented

### ADR-005: Event-Driven Architecture
**Decision:** EventBus with signals for decoupled communication
**Rationale:** Loose coupling, extensibility, testability
**Status:** Implemented

## Quick Reference

**Current Status:** Milestone 1 (92% complete) - Testing Phase

**Next Steps:**
1. Complete full game playthrough testing
2. Validate Milestone 1 ("Is it fun?" decision)
3. See `/STATUS.md` and `/ROADMAP.md` for current tasks

**Critical Files:**
- architecture/technical-architecture.md - System design
- architecture/INTEGRATION-GUIDE.md - Integration patterns
- architecture/magentic-ui-architecture.md - Multi-AI system
- project-management/development-organization.md - Development plan
- systems/PART-REGISTRY-ARCHITECTURE.md - Economy system

**Port Registry (NCC-1701):**
- 17010: Gateway (primary entry point)
- 17011: AI Service (with automatic fallback)
- 17012: Whisper (optional voice transcription)
- 17014: Redis (caching)

**Advanced Systems:**
- Magentic UI: 4 AI personalities, adaptive layouts
- Story Engine: Memory Manager, World State, Mission Pool
- Hybrid Economy: PartRegistry (720+ lines), credits + parts

---

**Parent Context:** [../CLAUDE.md](../CLAUDE.md)
**Directory Index:** [README.md](./README.md)
