# Space Adventures

**A narrative-driven space adventure game where you build your own starship and explore the cosmos.**

![Game Status](https://img.shields.io/badge/status-in%20development-yellow)
![Version](https://img.shields.io/badge/version-0.1.0--MVP-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 🚀 Overview

**Space Adventures** is a serious sci-fi choose-your-own-adventure game inspired by Star Trek: The Next Generation. Starting on a post-exodus Earth in 2247 AD, you'll scavenge for parts to build a starship from nothing, system by system. Once complete, embark on an AI-powered journey through the galaxy, making meaningful choices that shape your story.

### Core Features
- **🔧 Ship Building**: 10 core ship systems to find, install, and upgrade
- **🎮 Meaningful Choices**: Every decision matters - multiple approaches to challenges
- **🤖 AI-Powered Narrative**: Dynamic missions and encounters using ChatGPT or Ollama
- **📖 Deep Story**: Hand-crafted story missions mixed with AI-generated content
- **💾 Persistent Progress**: Save your journey and continue anytime
- **🎨 Retro-Tech Aesthetic**: Mix of ASCII schematics, pixel art, and clean UI

### Game Phases

**Phase 1: Earthbound (MVP)** - *4-6 hours*
- Scavenge abandoned Earth for ship parts
- Complete missions to earn components
- Build your ship system by system
- Launch into space when ready

**Phase 2: Space Exploration (Post-MVP)** - *12-20 hours*
- Explore multiple star systems
- Encounter alien species
- Face ethical dilemmas
- Shape your own story

---

## 📋 Table of Contents

- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Documentation](#-documentation)
- [Development](#-development)
- [Architecture](#-architecture)
- [Contributing](#-contributing)
- [Roadmap](#-roadmap)
- [License](#-license)

---

## 🔧 Installation

### Prerequisites

**Required:**
- [Godot Engine 4.2+](https://godotengine.org/download)
- [Docker & Docker Compose](https://docs.docker.com/get-docker/) (recommended)
- **OR** [Python 3.10+](https://www.python.org/downloads/) + [Redis](https://redis.io/download) (manual setup)
- Git

**For AI (Choose one):**
- [OpenAI API Key](https://platform.openai.com/api-keys) (paid, high quality)
- [Ollama](https://ollama.ai/) (free, local, requires good hardware)

### Setup Steps

#### **Option A: Docker (Recommended) 🐳**

1. **Clone and configure**
   ```bash
   git clone https://github.com/yourusername/space-adventures.git
   cd space-adventures
   cp python/.env.example python/.env
   # Edit python/.env with your AI settings
   ```

2. **Start services**
   ```bash
   docker-compose up -d
   ```

   Services started:
   - AI Service: http://localhost:8000
   - Redis Cache: localhost:6379
   - Redis UI: http://localhost:8081 (optional)

3. **Verify**
   ```bash
   # Check services
   docker-compose ps

   # Test API
   curl http://localhost:8000/health
   ```

4. **Open Godot and play**
   - Open Godot → Import → `godot/project.godot`
   - Press F5

#### **Option B: Manual Setup**

1. **Clone repository**
   ```bash
   git clone https://github.com/yourusername/space-adventures.git
   cd space-adventures
   ```

2. **Install and start Redis**
   ```bash
   # Linux
   sudo apt-get install redis-server
   redis-server

   # Mac
   brew install redis
   brew services start redis

   # Windows
   # Download from https://redis.io/download
   ```

3. **Set up Python**
   ```bash
   cd python
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   pip install -r requirements.txt
   cp .env.example .env
   # Edit .env
   ```

4. **Start AI service**
   ```bash
   python src/main.py
   ```

5. **Open Godot and play**
   - Open Godot → Import → `godot/project.godot`
   - Press F5

### Docker Commands

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f ai-service

# Stop services
docker-compose down

# Rebuild after code changes
docker-compose up -d --build

# Clear cache and restart
docker-compose down -v && docker-compose up -d

# Access Redis CLI
docker-compose exec redis redis-cli
```

---

## 🎮 Quick Start

### First Time Playing

1. **Start New Game** from the main menu
2. **Complete "The Inheritance"** - Learn the basic mechanics
3. **Explore the Workshop** - Your hub for building the ship
4. **Accept Missions** - Earn parts by completing objectives
5. **Install Parts** - Build your ship system by system
6. **Launch** - Once all 10 systems reach Level 1, blast off!

### Controls

**Keyboard:**
- Arrow Keys / WASD: Navigate UI
- Enter / Space: Confirm selection
- Escape: Back / Menu
- S: Quick save
- L: Quick load

**Mouse:**
- Click buttons and UI elements

---

## 📚 Documentation

Comprehensive design documents are in the `docs/` folder:

### Core Design
| Document | Description |
|----------|-------------|
| [**Game Design Document**](docs/game-design-document.md) | Complete game design, mechanics, systems |
| [**Technical Architecture**](docs/technical-architecture.md) | Code structure, data models, architecture |
| [**MVP Roadmap**](docs/mvp-roadmap.md) | Week-by-week development plan (6 weeks) |

### Game Systems
| Document | Description |
|----------|-------------|
| [**Ship Systems**](docs/ship-systems.md) | Detailed specs for all 10 ship systems (levels 0-5) |
| [**Ship Classification**](docs/ship-classification-system.md) | 10 ship classes (Scout, Explorer, Dreadnought, etc.) with requirements |
| [**Player Progression**](docs/player-progression-system.md) | Ranks, XP, attributes, skills, inventory, profile dashboard |
| [**Mission Framework**](docs/mission-framework.md) | How missions work, progression, encounters |
| [**Resources & Survival**](docs/resources-survival.md) | Resource management, time system, concurrent missions |
| [**Crew & Companions**](docs/crew-companion-system.md) | Optional crew system, relationships, abilities |

### AI & Content
| Document | Description |
|----------|-------------|
| [**AI Integration**](docs/ai-integration.md) | AI prompts, templates, integration patterns |
| [**Visual Features**](docs/visual-features.md) | AI image generation, galaxy maps, Stable Diffusion |
| [**Ship Documentation**](docs/ship-documentation.md) | AI-generated ship manuals, task queue system |
| [**Settings System**](docs/settings-system.md) | Multi-provider AI config, visual styles, preferences |

### Deployment & Operations
| Document | Description |
|----------|-------------|
| [**CI/CD & Deployment**](docs/ci-cd-deployment.md) | Complete CI/CD pipeline, Git workflow, environment setup |

---

## 🚀 CI/CD & Deployment

This project uses **GitHub Actions** for automated CI/CD with three environments:

### Environments

| Environment | Branch | URL | Auto-Deploy |
|-------------|--------|-----|-------------|
| **Development** | `develop` | https://dev.space-adventures.example.com | ✅ Yes |
| **Staging** | `main` | https://staging.space-adventures.example.com | ⚠️ Manual approval |
| **Production** | Tagged (`v*`) | https://space-adventures.example.com | ⚠️ Manual approval |

### Git Workflow (Git Flow)

```
feature/new-feature ──┐
bugfix/fix-issue   ───┼──> develop ──> main ──> v1.0.0 (tag)
hotfix/urgent      ───┘       │          │          │
                              ▼          ▼          ▼
                             DEV     STAGING     PROD
```

### Quick Start

**Development:**
```bash
docker-compose -f docker-compose.dev.yml up -d
# Includes: Hot reload, debug tools, pgAdmin, Redis Commander
```

**Staging:**
```bash
docker-compose -f docker-compose.staging.yml up -d
# Production-like environment for testing
```

**Production:**
```bash
docker-compose -f docker-compose.prod.yml up -d
# Optimized for performance, includes monitoring & backups
```

📖 **[Full CI/CD Documentation](docs/ci-cd-deployment.md)** - Git branching, deployment process, monitoring, backup/recovery

---

## 🛠️ Development

### Project Structure

```
space-adventures/
├── docs/              # Design documentation
├── godot/             # Godot game project
│   ├── scenes/        # Game scenes (.tscn)
│   ├── scripts/       # GDScript code
│   ├── assets/        # Sprites, fonts, data
│   └── saves/         # Save game files
├── python/            # Python AI service
│   ├── src/           # Source code
│   │   ├── api/       # FastAPI endpoints
│   │   ├── ai/        # AI integration
│   │   ├── models/    # Data models
│   │   └── cache/     # Response caching
│   ├── tests/         # Unit tests
│   └── requirements.txt
└── tools/             # Development utilities
```

### Technology Stack

**Game Engine:**
- Godot 4.2+ (GDScript)
- 2D graphics, scene management
- HTTP client for AI service

**AI Service:**
- Python 3.10+ with FastAPI
- LangChain (OpenAI + Ollama support)
- SQLite caching
- Pydantic validation

**Data:**
- JSON for game data and save files
- SQLite for AI response cache

### Running Tests

**Python tests:**
```bash
cd python
pytest tests/
```

**Manual testing:**
- Play through missions
- Test save/load
- Try to break things!

---

## 🏗️ Architecture

### System Overview

```
┌─────────────────────────────────────────────────┐
│              GODOT ENGINE (Game)                │
│  ┌───────────────────────────────────────────┐ │
│  │  UI Scenes → Game State → Save Manager   │ │
│  └───────────────────┬───────────────────────┘ │
└────────────────────────┼──────────────────────────┘
                         │ HTTP REST
                         │
┌────────────────────────▼──────────────────────────┐
│        PYTHON AI SERVICE (Content Gen)          │
│  ┌─────────────────────────────────────────┐   │
│  │  FastAPI → LangChain → OpenAI/Ollama   │   │
│  └─────────────────┬───────────────────────┘   │
│                    │                             │
│  ┌─────────────────▼───────────────────────┐   │
│  │  Response Cache (SQLite)                │   │
│  └─────────────────────────────────────────┘   │
└───────────────────────────────────────────────────┘
```

### Key Components

**Godot (Game Logic):**
- `GameState`: Global game state singleton
- `SaveManager`: Save/load system
- `AIService`: HTTP client for AI service
- `MissionManager`: Mission flow control
- Ship systems (10 classes)

**Python (AI Service):**
- `/api/missions/generate`: Generate missions
- `/api/encounters/generate`: Generate space encounters
- `/api/dialogue/generate`: Generate NPC dialogue
- Response caching for performance

---

## 🤝 Contributing

This is currently a solo hobby project, but contributions are welcome!

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Guidelines

- Follow existing code style (GDScript and Python)
- Add comments for complex logic
- Update documentation if changing features
- Test your changes thoroughly
- Write descriptive commit messages

### Areas We Need Help

- 🎨 Pixel art / sprite creation
- 📝 Mission writing (scripted content)
- 🎵 Sound effects and music
- 🧪 Playtesting and feedback
- 📚 Documentation improvements

---

## 🗺️ Roadmap

### ✅ Phase 0: Design (Current)
- [x] Game design document
- [x] Technical architecture
- [x] System specifications
- [x] Project setup

### 🚧 Phase 1: MVP (Weeks 1-6)
- [ ] Core game systems
- [ ] Save/load functionality
- [ ] 10 scripted missions
- [ ] AI integration
- [ ] Workshop UI
- [ ] Ship building mechanics
- **Goal:** Playable Earthbound phase (4-6 hours)

### 📅 Phase 2: Space Exploration (Weeks 7-12)
- [ ] Space phase implementation
- [ ] 5 star systems
- [ ] Combat system
- [ ] 20+ encounters
- [ ] First contact scenarios
- **Goal:** Complete game loop (20+ hours)

### 🎯 Phase 3: Polish (Months 4-6)
- [ ] Advanced graphics
- [ ] Sound design
- [ ] More star systems (50+)
- [ ] Multiple endings
- [ ] New Game+
- **Goal:** Release-ready quality

### 🌟 Phase 4: Post-Launch
- [ ] Mod support
- [ ] Community missions
- [ ] DLC content
- [ ] Mobile version (maybe)

---

## 🐛 Known Issues

**Current Status:** Design phase - no code yet!

Track issues on [GitHub Issues](https://github.com/yourusername/space-adventures/issues)

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

**Inspiration:**
- Star Trek: The Next Generation
- FTL: Faster Than Light
- The Expanse
- Mass Effect series

**Tools:**
- [Godot Engine](https://godotengine.org/) - Amazing open-source game engine
- [LangChain](https://www.langchain.com/) - AI integration framework
- [FastAPI](https://fastapi.tiangolo.com/) - Modern Python web framework
- [Ollama](https://ollama.ai/) - Local LLM runtime

**Special Thanks:**
- Claude (Anthropic) - AI assistant helping with development
- The Godot community
- Open source contributors everywhere

---

## 📬 Contact

**Developer:** [Your Name]
**Email:** your.email@example.com
**GitHub:** [@yourusername](https://github.com/yourusername)
**Discord:** [Space Adventures Community](#) (coming soon)

---

## ❓ FAQ

**Q: Does this cost money to play?**
A: No! The game is free. If you use OpenAI for AI generation, you'll need an API key (~$0.10-0.50 per playthrough). Or use Ollama for completely free local AI.

**Q: What are the system requirements?**
A: Very modest! Any modern computer can run the game. For Ollama AI, 16GB RAM and 8GB VRAM recommended.

**Q: Can I play offline?**
A: Yes, if using Ollama. OpenAI requires internet connection.

**Q: How long is the game?**
A: MVP is 4-6 hours. Full game will be 20-30 hours with high replayability.

**Q: Can I contribute missions or stories?**
A: Absolutely! See [Contributing](#-contributing) section.

**Q: Will there be sound/music?**
A: Not in MVP, but planned for later phases.

**Q: Can I mod the game?**
A: Not yet, but modding support is planned post-launch!

---

<div align="center">

**Made with ❤️ and 🤖 AI**

*Building spaceships, one system at a time.*

[⬆ Back to Top](#space-adventures)

</div>
