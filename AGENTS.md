# Repository Guidelines

## Agent-Specific Instructions
- Start with `CLAUDE.md` (repo root) for detailed agent workflows, prompt discipline, safety rules, and decision-making conventions. Treat it as the source of truth.
- Service-specific guides: see `python/CLAUDE.md` for backend agent patterns and `godot/CLAUDE.md` for client/UI agent guidance.
- Follow the Definition of Done and review practices described in `CLAUDE.md` when proposing changes or generating content.

## Project Structure & Module Organization
- `python/ai-service/`: FastAPI service for missions, dialogue, story; code in `src/`, tests in `tests/`.
- `python/gateway/`: FastAPI API gateway; code in `src/`, tests in `tests/`.
- `python/whisper-service/`: Optional transcription service; code in `src/`.
- `python/shared/`: Shared models/utilities.
- `godot/`: Game client (scenes, scripts, assets); tests under `godot/scripts/tests/` and test scenes in `godot/scenes/`.
- `scripts/`: Dev helpers (`start-all.sh`, `stop-all.sh`, `status.sh`, etc.).
- `docker-compose.yml`: Local stack (gateway, ai-service, whisper, redis).
- `.env.example` files: Root and per service for configuration.

## Build, Test, and Development Commands
- Start services: `./scripts/start-all.sh` (Ollama, Redis, AI service). Stop: `./scripts/stop-all.sh`.
- Status/logs: `./scripts/status.sh`, `./scripts/logs.sh`.
- Docker stack: `docker-compose up -d` (add `--profile voice` to include whisper).
- Run services locally (example): `cd python/ai-service && uvicorn main:app --reload --port 17011`.
- Python tests: `cd python/ai-service && pytest -q`; `cd python/gateway && pytest -q`.

## Coding Style & Naming Conventions
- Python: PEP 8, 4‑space indent. Format with Black, lint with Flake8, type‑check with MyPy.
  - Examples: `black python`, `flake8 python/ai-service/src python/gateway/src`, `mypy python/ai-service/src`.
- GDScript: 4‑space indent; file names `snake_case.gd`; classes `PascalCase`.
- Naming: modules/files `snake_case.py`, classes `PascalCase`, functions/vars `snake_case`.

## Testing Guidelines
- Framework: Pytest (+ asyncio). Coverage reports enabled (HTML + terminal) where configured.
- Conventions: place tests in `tests/`, files `test_*.py`, functions `test_*`.
- Run subsets: `pytest tests/test_story_engine.py -q`.
- Godot: run test scenes under `godot/scenes/` (e.g., `test_*`) or execute `scripts/tests/*.gd` in editor.
- Target: keep new/changed code at ≥80% line coverage when feasible.

## Commit & Pull Request Guidelines
- Commits: Conventional Commits (e.g., `feat:`, `fix:`, `docs:`, `test:`, `chore:`). Scope optional (e.g., `feat(ai-service): add story endpoints`).
- PRs: clear description, linked issues, steps to verify; include screenshots/video for Godot UI changes and sample `curl` for API changes.
- CI hygiene: passing tests, formatted code, no secrets committed; update docs when behavior or endpoints change.

## Security & Configuration Tips
- Copy `.env.example` → `.env` per service; never commit secrets.
- Prefer local models via Ollama during dev; set `AI_PROVIDER_*` vars accordingly.
- Validate health at `http://localhost:17010/health` (gateway) and `:17011/health` (AI).
