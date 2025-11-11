# Godot Client – Dev Guide

## Service URLs (Project Settings)
- Keys under `application/config`:
  - `gateway_url` (default: `http://localhost:17010`)
  - `ai_url` (default: `http://localhost:17011`)
  - `whisper_url` (default: `http://localhost:17012`)
- Edit in Godot: Project → Project Settings → Application → Config.
- The client prefers the gateway when available and falls back to the AI service directly.

## Networking Behavior
- Preferred routes:
  - Gateway: `GET/POST {gateway_url}/api/v1/ai/...`
- Fallback routes (if gateway is offline):
  - Direct AI: `GET/POST {ai_url}/api/...`
- Short timeouts and automatic retry are enabled for chat, orchestrator, and story endpoints.

## Run Locally
- Scripts (recommended):
  - `./scripts/start-all.sh` – starts AI service, Redis, Ollama; prints health URLs.
  - `./scripts/status.sh` – shows service status and ports.
- Docker Compose:
  - `docker-compose up -d` (add `--profile voice` to include Whisper service).

## Quick Connectivity Checks
- From terminal:
  - AI: `curl {ai_url}/health`
  - Gateway: `curl {gateway_url}/health`
- In Godot (Output):
  - `ServiceManager: Checking all services...` followed by availability logs.

## Troubleshooting
- Error `HTTP request failed: 2`:
  - Ensure at least the AI service is running (`{ai_url}/health == 200`).
  - Verify Project Settings URLs match your environment.
  - Gateway down? The client should fall back to direct AI automatically.
- CORS/ports:
  - When using Docker, ensure ports 17010/17011 are published and not blocked by firewall/VPN.

## Notes
- Story and chat use the same fallback strategy; no editor changes are required after setting URLs.
- For CI or offline development, a mock mode and a headless test runner are planned (see root `GODOT-REVIEW-CHECKLIST.md`).
