# Getting Started

**Purpose:** Quick start guides for developers and testers to get the project running.

## Files in This Directory

### [DEVELOPER-SETUP.md](./DEVELOPER-SETUP.md)
**Primary entry point for all developers.**

Complete setup guide covering:
- Prerequisites (Godot 4.2+, Docker, Python 3.10+)
- Installation steps (< 5 minutes)
- Environment configuration
- Starting backend services
- Opening and running the Godot project
- Development workflow
- Common development tasks
- IDE setup recommendations
- Troubleshooting guide

**Audience:** Developers, AI agents
**Time to Complete:** 5-10 minutes

## Quick Start

```bash
# 1. Clone and enter directory
cd space-adventures

# 2. Start backend services
docker compose up -d

# 3. Open Godot
godot godot/project.godot
# Press F5 to run

# 4. Test with main menu test scene
```

## Related Documentation

- **Testing Guide:** [../01-user-guides/testing/TESTING-GUIDE.md](../01-user-guides/testing/TESTING-GUIDE.md)
- **Architecture:** [../02-developer-guides/architecture/technical-architecture.md](../02-developer-guides/architecture/technical-architecture.md)
- **Integration:** [../02-developer-guides/architecture/INTEGRATION-GUIDE.md](../02-developer-guides/architecture/INTEGRATION-GUIDE.md)

## Prerequisites

Before following this guide, ensure you have:
- macOS, Windows, or Linux
- 8GB+ RAM
- 5GB+ free disk space
- Internet connection (for Docker images)

## Troubleshooting

If you encounter issues:
1. Check [DEVELOPER-SETUP.md](./DEVELOPER-SETUP.md) troubleshooting section
2. Verify Docker is running: `docker ps`
3. Check services: `docker compose logs`
4. Verify ports: [../06-technical-reference/PORT-MAPPING.md](../06-technical-reference/PORT-MAPPING.md)

---

**Navigation:**
- [📚 Documentation Index](../README.md)
- [🤖 AI Agent Context](../CLAUDE.md)
- [🎮 Project Root](../../)
