# Space Adventures - Port Mapping System

**Theme:** Star Trek NCC Registry Numbers
**Base:** NCC-1701 (USS Enterprise)
**Port Range:** 17010-17099

---

## Service Port Assignments

### Core Services

| Service | Port | Registry Reference | Purpose |
|---------|------|-------------------|---------|
| **Gateway Service** | `17010` | NCC-1701-0 | API Gateway - Single entry point |
| **AI Service** | `17011` | NCC-1701-1 | AI content generation |
| **Whisper Service** | `17012` | NCC-1701-2 | Voice transcription |
| **Image Service** | `17013` | NCC-1701-3 | Image generation (future) |

### Support Services

| Service | Port | Registry Reference | Purpose |
|---------|------|-------------------|---------|
| **Redis** | `17014` | NCC-1701-4 | Cache & sessions |
| **PostgreSQL** | `17015` | NCC-1701-5 | Database (future) |
| **Redis Commander** | `17081` | NCC-1701-81 | Redis UI (debug only) |

### Reserved for Future

| Service | Port | Registry Reference | Purpose |
|---------|------|-------------------|---------|
| **Metrics Service** | `17016` | NCC-1701-6 | Prometheus metrics (future) |
| **Logging Service** | `17017` | NCC-1701-7 | Centralized logging (future) |
| **Backup Service** | `17018` | NCC-1701-8 | Backup automation (future) |

---

## Port Mapping Details

### Gateway Service (17010)
- **External:** http://localhost:17010
- **Internal:** Container port 17010
- **Routes:**
  - `/health` - Gateway health
  - `/health/all` - All services health
  - `/api/v1/ai/*` → AI Service
  - `/api/v1/whisper/*` → Whisper Service
  - `/api/v1/images/*` → Image Service

### AI Service (17011)
- **External:** http://localhost:17011
- **Internal:** Container port 17011
- **Endpoints:**
  - `/api/missions/generate`
  - `/api/chat/message`
  - `/api/dialogue/generate`
  - `/docs` - Swagger UI

### Whisper Service (17012)
- **External:** http://localhost:17012
- **Internal:** Container port 17012
- **Endpoints:**
  - `/api/transcribe`
- **Status:** Optional (profile: voice)

### Image Service (17013)
- **External:** http://localhost:17013
- **Internal:** Container port 17013
- **Status:** Future implementation

### Redis (17014)
- **External:** localhost:17014
- **Internal:** Container port 17014
- **Purpose:** AI response caching, session storage
- **Protocol:** Redis protocol

### PostgreSQL (17015)
- **External:** localhost:17015
- **Internal:** Container port 17015
- **Status:** Future implementation
- **Protocol:** PostgreSQL protocol

### Redis Commander (17081)
- **External:** http://localhost:17081
- **Internal:** Container port 8081 (mapped from 17081)
- **Purpose:** Web UI for Redis debugging
- **Status:** Debug profile only

---

## Configuration Updates Required

### Environment Variables

```bash
# Gateway
PORT=17010
AI_SERVICE_URL=http://ai-service:17011
WHISPER_SERVICE_URL=http://whisper-service:17012
IMAGE_SERVICE_URL=http://image-service:17013

# AI Service
PORT=17011
REDIS_HOST=redis
REDIS_PORT=17014

# Whisper Service
PORT=17012

# Redis
PORT=17014

# PostgreSQL (future)
PORT=17015
```

### Docker Compose

All docker-compose files updated with new port mappings.

### Godot Configuration

Service URLs in Godot autoload scripts:
```gdscript
const GATEWAY_URL = "http://localhost:17010"
const AI_SERVICE_URL = "http://localhost:17011"
const WHISPER_SERVICE_URL = "http://localhost:17012"
```

---

## Testing Endpoints

```bash
# Gateway
curl http://localhost:17010/health

# AI Service
curl http://localhost:17011/health

# Whisper Service
curl http://localhost:17012/health

# Redis
redis-cli -p 17014 ping

# Swagger UI
open http://localhost:17011/docs
```

---

## Migration from Old Ports

### Old → New Mapping

| Service | Old Port | New Port | Change |
|---------|----------|----------|--------|
| Gateway | 8000 | 17010 | +9010 |
| AI Service | 8001 | 17011 | +9010 |
| Whisper | 8002 | 17012 | +9010 |
| Image | 8003 | 17013 | +9010 |
| Redis | 6379 | 17014 | +10635 |
| PostgreSQL | 5432 | 17015 | +11583 |
| Redis Commander | 8081 | 17081 | +9000 |

### Breaking Changes

⚠️ **Important:** This is a breaking change for existing deployments.

**After updating:**
1. Stop all running containers
2. Update configuration
3. Rebuild containers
4. Start with new ports

```bash
docker-compose down
git pull
docker-compose up -d --build
```

---

## Firewall Rules

If using firewall, allow ports:
```bash
# Core services
17010-17013

# Support services
17014-17015

# Debug tools (optional)
17081
```

---

## Why NCC-1701 Range?

- **Thematic:** Matches Star Trek universe
- **Unique:** Unlikely to conflict with common services
- **Memorable:** Easy to remember (1701 + service number)
- **Expandable:** Room for 90 services (17010-17099)
- **Professional:** Above privileged port range (>1024)

---

## Quick Reference Card

**Copy this to your notes:**

```
Space Adventures Services - NCC-1701 Registry
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Gateway:   http://localhost:17010  (API Gateway)
AI:        http://localhost:17011  (Content Gen)
Whisper:   http://localhost:17012  (Voice→Text)
Redis:     localhost:17014          (Cache)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Docs:      http://localhost:17011/docs
Debug:     http://localhost:17081  (Redis UI)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

**Last Updated:** November 5, 2025
**Status:** Active - All services updated to NCC-1701 registry system
