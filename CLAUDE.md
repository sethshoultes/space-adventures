# CLAUDE.md

**Primary guidance for AI agents (Claude Code, etc.) working on this project.**

## Project Overview

**Space Adventures** is a serious sci-fi choose-your-own-adventure web game inspired by Star Trek: TNG.

Players scavenge post-exodus Earth for ship parts, build a starship system by system, and eventually launch into space — all guided by an AI Game Master powered by Claude.

**This is a hobby/learning project.** Milestones not timelines. Progress over perfection.

## Architecture (v2 — Web Game)

> **Note:** The original Godot implementation is archived on branch `archive/godot-v1`.

```
┌─────────────────────────────────────────────────┐
│                   BROWSER                        │
│  React + Three.js + Tailwind                     │
│  - 3D ship viewer (Three.js)                     │
│  - Narrative UI (React)                          │
│  - WebSocket for real-time streaming             │
└────────────────┬────────────────────────────────┘
                 │ WebSocket + REST
┌────────────────▼────────────────────────────────┐
│              SERVER (FastAPI)                     │
│  - /api/game/* — REST endpoints                  │
│  - /ws/{session} — streaming game interaction    │
│  - Claude Agent SDK Game Master                  │
│  - Markdown memory system                        │
│  - SQLite game state persistence                 │
│  - Redis cache                                   │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│         CLAUDE AGENT SDK                         │
│  Game Master agent with tools:                   │
│  - check_inventory, modify_ship_system           │
│  - resolve_skill_check, award_xp                 │
│  - update_relationship, trigger_event            │
│  System prompt: Star Trek TNG tone               │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│         CLOUDFLARE WORKER (heartbeat/)           │
│  - Cron-triggered keep-alive                     │
│  - Health monitoring                             │
│  (Future — not yet implemented)                  │
└─────────────────────────────────────────────────┘
```

## Directory Structure

```
server/          — Python backend (FastAPI + Claude Agent SDK)
  src/
    main.py      — FastAPI app entry point
    config.py    — Settings (pydantic-settings, env vars)
    api/         — REST and WebSocket routes
    game_master/ — Claude Agent SDK game master (agent, tools, prompts)
    memory/      — Markdown-based player memory system
    state/       — Pydantic models + SQLite database layer
    data/        — Game data JSONs (missions, parts, systems, economy)
  tests/         — pytest tests
  pyproject.toml — Python dependencies

web/             — React + Three.js + Tailwind frontend
heartbeat/       — Cloudflare Worker (health/keep-alive)
memory/          — Player memory markdown files (templates)
docs/            — Design documentation (carried from v1)
python/          — Legacy Python services (to be reorganized into server/)
```

## Tech Stack

| Layer       | Technology                          |
|-------------|-------------------------------------|
| Frontend    | React, Three.js, Tailwind CSS       |
| Backend     | Python 3.11+, FastAPI, Uvicorn      |
| AI Engine   | Claude Agent SDK (Anthropic)         |
| Database    | SQLite (aiosqlite) + Redis cache     |
| Memory      | Markdown files (fed to agent context)|
| Hosting     | TBD (Cloudflare Workers for heartbeat)|

## Key Concepts

### Game Master Agent
The core of the game. A Claude agent with tools that:
- Drives narrative (Star Trek TNG tone: serious, hopeful, ethical dilemmas)
- Presents 2-5 meaningful choices per scene
- Uses tools to check/modify game state (never hallucinate stats)
- Tracks consequences via markdown memory files
- Streams responses via WebSocket for real-time feel

### Markdown Memory System
Player memories stored as markdown files in `memory/`:
- `player_profile.md` — Stats, play style, achievements
- `relationships.md` — NPCs, factions, crew
- `decisions.md` — Major choices and consequences
- `world_state.md` — Ship status, economy, locations
- `daily/*.md` — Session logs

These files are read into the Game Master's context each turn, giving it long-term memory.

### 10 Ship Systems
Hull, Power Core, Propulsion, Warp Drive, Life Support, Computer Core, Sensors, Shields, Weapons, Communications. Each has levels 0-5. All must reach Level 1 to leave Earth (Phase 1 → Phase 2 transition).

## Development Commands

```bash
# Server
cd server
pip install -e ".[dev]"
uvicorn src.main:app --reload --port 8000

# Frontend (once scaffolded)
cd web
npm install
npm run dev

# Tests
cd server && pytest
```

## Development Principles

1. **KISS** — Simplest solution that works
2. **DRY** — Single source of truth
3. **YAGNI** — Don't build it until needed
4. **SOLID** — Clean, maintainable code
5. **Real data only** — No mocks, no fakes, no bypasses
6. **Delete old code** — No legacy, no backups, one way to do things

## For AI Agents

**Start each session:**
1. Read this file
2. Check STATUS.md for current task
3. Check ROADMAP.md for milestone progress
4. Implement → Test → Commit

**Decision authority:** Make implementation decisions autonomously. Ask for game design decisions.

**Remember:** This is a hobby project. Have fun. Ship working code.
