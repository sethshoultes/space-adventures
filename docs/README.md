# Space Adventures - Documentation Library

**Version:** v0.1.0-foundation
**Last Updated:** 2025-11-06
**Status:** Phase 1 Complete

## 📚 Documentation Overview

This documentation library contains everything you need to understand, develop, test, and deploy Space Adventures. The documentation is organized by audience and purpose for easy navigation.

## 🗂️ Directory Structure

### [00-getting-started](./00-getting-started/) - Start Here!
Quick start guides for developers and testers.
- **[Developer Setup](./00-getting-started/DEVELOPER-SETUP.md)** - Get up and running in < 5 minutes
- Environment configuration
- Troubleshooting installation issues

### [01-user-guides](./01-user-guides/) - For Players & Testers
Guides for testing and playing the game.
- **[Testing Guide](./01-user-guides/testing/TESTING-GUIDE.md)** - Comprehensive testing procedures
- Test cases and pass/fail criteria
- Bug reporting guidelines

### [02-developer-guides](./02-developer-guides/) - For Developers
Technical implementation guides and project management.

#### [Architecture](./02-developer-guides/architecture/)
- **[Technical Architecture](./02-developer-guides/architecture/technical-architecture.md)** - System design
- **[Integration Guide](./02-developer-guides/architecture/INTEGRATION-GUIDE.md)** - Godot ↔ Backend integration

#### [Project Management](./02-developer-guides/project-management/)
- **[Development Organization](./02-developer-guides/project-management/development-organization.md)** - Master plan
- **[MVP Roadmap](./02-developer-guides/project-management/mvp-roadmap.md)** - Week-by-week breakdown

#### [Deployment](./02-developer-guides/deployment/)
- **[CI/CD Deployment](./02-developer-guides/deployment/ci-cd-deployment.md)** - Automated deployment

### [03-game-design](./03-game-design/) - Game Design Documents
Complete game design specifications.

#### [Core Systems](./03-game-design/core-systems/)
- **[Game Design Document](./03-game-design/core-systems/game-design-document.md)** - Core game loop
- **[Player Progression](./03-game-design/core-systems/player-progression-system.md)** - XP, levels, ranks
- **[Resources & Survival](./03-game-design/core-systems/resources-survival.md)** - Resource mechanics

#### [Ship Systems](./03-game-design/ship-systems/)
- **[Ship Systems](./03-game-design/ship-systems/ship-systems.md)** - 10 core systems
- **[Ship Classification](./03-game-design/ship-systems/ship-classification-system.md)** - Ship classes
- **[Ship Documentation](./03-game-design/ship-systems/ship-documentation.md)** - Complete specs

#### [Content Systems](./03-game-design/content-systems/)
- **[Mission Framework](./03-game-design/content-systems/mission-framework.md)** - Mission structure
- **[Crew Companion System](./03-game-design/content-systems/crew-companion-system.md)** - Crew mechanics

### [04-ui-graphics](./04-ui-graphics/) - UI & Visual Design
User interface and graphics guidelines.
- **[UI Graphics Index](./04-ui-graphics/UI-GRAPHICS-INDEX.md)** - Complete UI guide
- Prompt engineering for DALL-E
- Screen designs and mockups
- Dashboard implementation

### [05-ai-content](./05-ai-content/) - AI Integration
AI-powered content generation systems.
- **[AI Integration](./05-ai-content/ai-integration.md)** - Multi-provider AI
- **[AI Chat & Storytelling](./05-ai-content/ai-chat-storytelling-system.md)** - 4 personalities
- **[Whisper Voice Transcription](./05-ai-content/whisper-voice-transcription.md)** - Voice input

### [06-technical-reference](./06-technical-reference/) - Technical Reference
Quick reference guides and specifications.
- **[Port Mapping](./06-technical-reference/PORT-MAPPING.md)** - NCC-1701 registry
- **[Settings System](./06-technical-reference/settings-system.md)** - Game settings

### [07-ai-agent-templates](./07-ai-agent-templates/) - For AI Agents
Templates and guidelines for AI development assistants.
- **[CLAUDE.md Templates](./07-ai-agent-templates/claude-md-templates.md)** - Agent context files

## 🚀 Quick Start Paths

### I Want To...

**Play/Test the Game**
1. Read [Getting Started](./00-getting-started/)
2. Follow [Testing Guide](./01-user-guides/testing/TESTING-GUIDE.md)
3. Report bugs using test report template

**Develop the Game**
1. Read [Developer Setup](./00-getting-started/DEVELOPER-SETUP.md)
2. Review [Technical Architecture](./02-developer-guides/architecture/technical-architecture.md)
3. Check [Development Organization](./02-developer-guides/project-management/development-organization.md)
4. Read [Integration Guide](./02-developer-guides/architecture/INTEGRATION-GUIDE.md)

**Understand Game Design**
1. Start with [Game Design Document](./03-game-design/core-systems/game-design-document.md)
2. Review [Ship Systems](./03-game-design/ship-systems/ship-systems.md)
3. Check [Mission Framework](./03-game-design/content-systems/mission-framework.md)

**Work on AI Features**
1. Read [AI Integration](./05-ai-content/ai-integration.md)
2. Review [AI Chat System](./05-ai-content/ai-chat-storytelling-system.md)
3. Optional: [Voice Input](./05-ai-content/whisper-voice-transcription.md)

**Design UI/Graphics**
1. Start with [UI Graphics Index](./04-ui-graphics/UI-GRAPHICS-INDEX.md)
2. Use [Prompt Guide](./04-ui-graphics/ui-graphics-prompt-guide.md)
3. Reference [Screen Designs](./04-ui-graphics/screen-designs.md)

## 📖 Documentation Standards

### File Naming
- Use kebab-case for filenames: `game-design-document.md`
- Use descriptive names: `ship-classification-system.md` not `ships.md`
- Keep names concise but clear

### Directory Naming
- Use numbered prefixes for ordering: `00-getting-started`, `01-user-guides`
- Use kebab-case: `project-management` not `Project_Management`
- Group related content together

### Document Structure
Each document should have:
1. **Title** - Clear, descriptive
2. **Metadata** - Version, date, status
3. **Overview** - Brief summary
4. **Table of Contents** - For long documents
5. **Content** - Well-organized sections
6. **References** - Links to related docs

### Cross-References
Use relative paths for links:
```markdown
See [Technical Architecture](./02-developer-guides/architecture/technical-architecture.md)
```

## 🔍 Search Tips

### By Topic
- **Architecture:** `02-developer-guides/architecture/`
- **Game Design:** `03-game-design/`
- **Testing:** `01-user-guides/testing/`
- **AI Features:** `05-ai-content/`
- **UI/Graphics:** `04-ui-graphics/`

### By Audience
- **Testers:** Start in `01-user-guides/`
- **Developers:** Start in `02-developer-guides/`
- **Designers:** Start in `03-game-design/` and `04-ui-graphics/`
- **AI Agents:** Check `07-ai-agent-templates/` and each directory's `CLAUDE.md`

### Common Searches
- "How do I set up the project?" → [Developer Setup](./00-getting-started/DEVELOPER-SETUP.md)
- "How do I test the game?" → [Testing Guide](./01-user-guides/testing/TESTING-GUIDE.md)
- "How do ship systems work?" → [Ship Systems](./03-game-design/ship-systems/ship-systems.md)
- "How do I integrate AI?" → [AI Integration](./05-ai-content/ai-integration.md)
- "What ports does the system use?" → [Port Mapping](./06-technical-reference/PORT-MAPPING.md)

## 🤖 For AI Development Assistants

Each directory contains a `CLAUDE.md` file with:
- Purpose and scope of the directory
- Key files and their relationships
- Common tasks and workflows
- Related directories and dependencies

Start with [AI Agent Templates](./07-ai-agent-templates/claude-md-templates.md) for guidelines on creating and using these context files.

## 📊 Documentation Status

### Phase 1 Complete ✅
- Architecture documentation
- Development guides
- Testing procedures
- Integration guides
- Game design specifications

### In Progress 🚧
- Advanced gameplay documentation (Phase 2)
- Content creation guides
- Asset pipeline documentation

### Planned 📝
- API reference documentation
- Performance optimization guides
- Deployment playbooks
- Content creator guides

## 🔗 External Resources

### Game Engine
- [Godot Documentation](https://docs.godotengine.org/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/)

### Backend
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

### AI Providers
- [Anthropic Claude](https://docs.anthropic.com/)
- [OpenAI API](https://platform.openai.com/docs/)
- [Ollama](https://ollama.ai/)

## 📝 Contributing to Documentation

### Adding New Documents
1. Determine the appropriate category
2. Create file in correct directory
3. Update directory's README.md index
4. Update directory's CLAUDE.md if needed
5. Add cross-references from related docs
6. Update this master index

### Updating Existing Documents
1. Update document version and date
2. Update changelog if present
3. Review cross-references for accuracy
4. Update directory index if title changed

### Documentation Review Checklist
- [ ] Clear title and metadata
- [ ] Proper formatting and structure
- [ ] Working cross-references
- [ ] Code examples tested
- [ ] Spelling and grammar checked
- [ ] Audience-appropriate language
- [ ] Updated in directory index

## 📧 Getting Help

- **Documentation Issues:** Check troubleshooting sections
- **Code Issues:** See [Developer Guides](./02-developer-guides/)
- **Game Design Questions:** See [Game Design](./03-game-design/)
- **Testing Issues:** See [Testing Guide](./01-user-guides/testing/TESTING-GUIDE.md)

## 📜 Version History

### v0.1.0-foundation (2025-11-06)
- Initial documentation organization
- Complete Phase 1 documentation
- Established directory structure
- Created master index

---

**Navigation:**
- [🏠 Project Root](../)
- [📖 Main CLAUDE.md](../CLAUDE.md)
- [🎮 Godot Documentation](../godot/CLAUDE.md)

**Last Updated:** 2025-11-06
**Maintained By:** Claude Code AI Assistant
