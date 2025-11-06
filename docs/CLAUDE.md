# Documentation Library - AI Agent Context

**Purpose:** Master context file for AI development assistants working with Space Adventures documentation
**Last Updated:** 2025-11-06
**Status:** Phase 1 Complete

## Quick Reference

### Documentation Structure
```
docs/
├── 00-getting-started/     → Installation & setup
├── 01-user-guides/         → Testing & gameplay guides
├── 02-developer-guides/    → Technical implementation
├── 03-game-design/         → Game mechanics & systems
├── 04-ui-graphics/         → Visual design & UI
├── 05-ai-content/          → AI integration
├── 06-technical-reference/ → Quick reference guides
└── 07-ai-agent-templates/  → AI agent guidelines
```

### Primary Entry Points
- **Setup:** `00-getting-started/DEVELOPER-SETUP.md`
- **Architecture:** `02-developer-guides/architecture/technical-architecture.md`
- **Integration:** `02-developer-guides/architecture/INTEGRATION-GUIDE.md`
- **Game Design:** `03-game-design/core-systems/game-design-document.md`
- **Testing:** `01-user-guides/testing/TESTING-GUIDE.md`

## When Working On...

### Backend Services
**Read First:**
- `02-developer-guides/architecture/technical-architecture.md`
- `02-developer-guides/architecture/INTEGRATION-GUIDE.md`
- `06-technical-reference/PORT-MAPPING.md`

**Related:**
- `05-ai-content/ai-integration.md` (AI providers)
- `00-getting-started/DEVELOPER-SETUP.md` (environment)

### Godot Game Client
**Read First:**
- `../godot/CLAUDE.md` (Godot-specific context)
- `02-developer-guides/architecture/INTEGRATION-GUIDE.md`
- `03-game-design/core-systems/game-design-document.md`

**Related:**
- `03-game-design/ship-systems/ship-systems.md`
- `04-ui-graphics/screen-designs.md`

### AI Features
**Read First:**
- `05-ai-content/ai-integration.md`
- `05-ai-content/ai-chat-storytelling-system.md`

**Related:**
- `03-game-design/content-systems/mission-framework.md`
- `05-ai-content/whisper-voice-transcription.md` (voice)

### UI/Graphics
**Read First:**
- `04-ui-graphics/UI-GRAPHICS-INDEX.md`
- `04-ui-graphics/screen-designs.md`

**Related:**
- `04-ui-graphics/ui-graphics-prompt-guide.md`
- `03-game-design/core-systems/game-design-document.md`

### Game Systems
**Read First:**
- `03-game-design/ship-systems/ship-systems.md`
- `03-game-design/core-systems/player-progression-system.md`

**Related:**
- `03-game-design/ship-systems/ship-classification-system.md`
- `03-game-design/content-systems/mission-framework.md`

### Testing
**Read First:**
- `01-user-guides/testing/TESTING-GUIDE.md`
- `00-getting-started/DEVELOPER-SETUP.md`

**Related:**
- `02-developer-guides/architecture/INTEGRATION-GUIDE.md`

### Deployment
**Read First:**
- `02-developer-guides/deployment/ci-cd-deployment.md`
- `06-technical-reference/PORT-MAPPING.md`

**Related:**
- `00-getting-started/DEVELOPER-SETUP.md`

## Documentation Hierarchy

### Level 1: Getting Started
Must-read for all developers and testers.
- Purpose: Get environment running
- Audience: Everyone
- Time: 10-15 minutes

### Level 2: Role-Specific Guides
Read based on your role.
- **Testers:** `01-user-guides/`
- **Developers:** `02-developer-guides/`
- **Designers:** `03-game-design/`, `04-ui-graphics/`

### Level 3: Deep Dives
Reference as needed during development.
- Technical specifications
- API references
- Implementation details

### Level 4: Templates & Reference
Utilities and quick references.
- Port mappings
- Settings schemas
- AI agent templates

## Common Tasks → Documentation

| Task | Primary Document | Supporting Documents |
|------|------------------|---------------------|
| Set up dev environment | `00-getting-started/DEVELOPER-SETUP.md` | `06-technical-reference/PORT-MAPPING.md` |
| Add new ship system | `03-game-design/ship-systems/ship-systems.md` | `../godot/CLAUDE.md` |
| Integrate AI feature | `05-ai-content/ai-integration.md` | `02-developer-guides/architecture/INTEGRATION-GUIDE.md` |
| Create new mission | `03-game-design/content-systems/mission-framework.md` | `05-ai-content/ai-chat-storytelling-system.md` |
| Design UI screen | `04-ui-graphics/screen-designs.md` | `04-ui-graphics/ui-graphics-prompt-guide.md` |
| Add test case | `01-user-guides/testing/TESTING-GUIDE.md` | `02-developer-guides/architecture/INTEGRATION-GUIDE.md` |
| Deploy service | `02-developer-guides/deployment/ci-cd-deployment.md` | `00-getting-started/DEVELOPER-SETUP.md` |

## Key Concepts

### NCC-1701 Port Registry
All services use Star Trek-themed ports (17010-17099).
See: `06-technical-reference/PORT-MAPPING.md`

### Microservices Architecture
- Gateway (17010) → Single entry point
- AI Service (17011) → Content generation
- Redis (17014) → Caching layer

See: `02-developer-guides/architecture/technical-architecture.md`

### Godot Integration
- 5 autoload singletons (ServiceManager, GameState, etc.)
- Event-driven architecture via EventBus
- JSON save/load system

See: `02-developer-guides/architecture/INTEGRATION-GUIDE.md`

### Game Loop
Phase 1: Earthbound (ship building) → Phase 2: Space exploration

See: `03-game-design/core-systems/game-design-document.md`

## Documentation Conventions

### File References
Always use relative paths from current location:
```markdown
[Technical Architecture](./02-developer-guides/architecture/technical-architecture.md)
```

### Cross-Directory References
Use `../` to go up directories:
```markdown
[Main CLAUDE.md](../CLAUDE.md)
[Godot Context](../godot/CLAUDE.md)
```

### Code Examples
Always specify language for syntax highlighting:
```gdscript
# GDScript example
var health: int = 100
```

```python
# Python example
def generate_mission():
    pass
```

### Audience Indicators
Documents should clearly state audience:
- **For Testers:** Testing procedures
- **For Developers:** Implementation details
- **For Designers:** Game mechanics
- **For AI Agents:** Context and relationships

## Search Strategy for AI Agents

### 1. Identify Task Category
- Backend? → `02-developer-guides/architecture/`
- Game Design? → `03-game-design/`
- Testing? → `01-user-guides/testing/`
- UI? → `04-ui-graphics/`

### 2. Find Primary Document
- Check directory README.md for index
- Look for document matching task type

### 3. Read Related Documents
- Check "Related" sections
- Follow cross-references
- Review directory CLAUDE.md

### 4. Understand Context
- Read overview/summary sections
- Check prerequisites
- Note dependencies

## Directory-Specific Context

Each directory has its own `CLAUDE.md` with:
- **Purpose:** What this directory contains
- **Key Files:** Most important documents
- **Relationships:** How files relate
- **Common Tasks:** Typical workflows
- **Dependencies:** External requirements

## Update Protocol

When modifying documentation:

1. **Update Document:**
   - Change content
   - Update version/date metadata
   - Update changelog if present

2. **Update Indexes:**
   - Update directory README.md
   - Update directory CLAUDE.md if structure changed
   - Update master README.md if needed

3. **Update Cross-References:**
   - Check links still work
   - Update related document references
   - Add new links to relevant docs

4. **Verify Navigation:**
   - Test all relative links
   - Ensure breadcrumb trail works
   - Confirm search paths updated

## Anti-Patterns to Avoid

❌ **Don't:**
- Create documentation without updating indexes
- Use absolute file paths in links
- Skip directory README/CLAUDE.md files
- Duplicate information across documents
- Create deeply nested structures (3 levels max)
- Use unclear file names

✅ **Do:**
- Keep directory structure flat and clear
- Use cross-references liberally
- Maintain consistent formatting
- Update metadata (version, date)
- Write for specific audiences
- Use descriptive file names

## Quick Wins for AI Agents

### Need Architecture Overview?
→ `02-developer-guides/architecture/technical-architecture.md`

### Need Integration Details?
→ `02-developer-guides/architecture/INTEGRATION-GUIDE.md`

### Need Game Mechanics?
→ `03-game-design/core-systems/game-design-document.md`

### Need Setup Instructions?
→ `00-getting-started/DEVELOPER-SETUP.md`

### Need Testing Procedures?
→ `01-user-guides/testing/TESTING-GUIDE.md`

### Need AI Integration?
→ `05-ai-content/ai-integration.md`

### Need Port Information?
→ `06-technical-reference/PORT-MAPPING.md`

## Version Context

**Current Phase:** Phase 1 Complete (v0.1.0-foundation)
**Status:** Production-ready foundation
**Next Phase:** Phase 2 - Game Systems & Ship Building

See: `02-developer-guides/project-management/development-organization.md`

---

**Related Files:**
- [Master README](./README.md) - Complete documentation index
- [Project CLAUDE.md](../CLAUDE.md) - Root project context
- [Godot CLAUDE.md](../godot/CLAUDE.md) - Godot-specific context

**For AI Agents:** Always start with the directory's CLAUDE.md file to understand context before reading specific documents.
