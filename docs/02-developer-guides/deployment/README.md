# Deployment Documentation

**Purpose:** CI/CD pipelines, deployment procedures, and infrastructure configuration.

## Files in This Directory

### [ci-cd-deployment.md](./ci-cd-deployment.md)
**Comprehensive CI/CD and deployment guide.**

Contains:
- Docker Compose configuration
- Environment variable management
- CI/CD pipeline setup (GitHub Actions)
- Deployment procedures
- Monitoring and logging
- Backup and recovery procedures
- Security considerations

**Audience:** DevOps, developers, system administrators
**Critical:** Yes - required for production deployment

## Deployment Overview

### Development Environment
```bash
# Local development with Docker Compose
docker compose up -d

# Services available at:
# - Gateway: http://localhost:17010
# - AI Service: http://localhost:17011
# - Whisper: http://localhost:17012 (optional)
# - Redis: localhost:17014
```

### Production Environment
- Containerized deployment via Docker
- Environment-based configuration
- Health monitoring
- Automated backups
- CI/CD automation

## Quick Start

### First Time Deployment
1. Clone repository
2. Copy `.env.example` to `.env`
3. Configure environment variables
4. Run `docker compose up -d`
5. Verify health: `curl http://localhost:17010/health`

### Update Deployment
1. Pull latest changes: `git pull`
2. Rebuild services: `docker compose build`
3. Restart: `docker compose up -d`
4. Verify: Check health endpoints

### Rollback
1. Checkout previous version: `git checkout <tag>`
2. Rebuild: `docker compose build`
3. Restart: `docker compose up -d`
4. Verify: Run tests

## Key Concepts

### NCC-1701 Port System
All services use Star Trek-themed ports (17010-17099) to avoid conflicts:
- **17010:** Gateway (NCC-1701-0)
- **17011:** AI Service (NCC-1701-1)
- **17012:** Whisper (NCC-1701-2)
- **17014:** Redis (NCC-1701-4)

See: [../../06-technical-reference/PORT-MAPPING.md](../../06-technical-reference/PORT-MAPPING.md)

### Environment Configuration
All sensitive configuration via `.env`:
- API keys (OpenAI, Anthropic)
- Service ports
- AI provider selection
- Feature flags
- Database connections

### Docker Compose Stack
```yaml
services:
  gateway:     # Entry point (17010)
  ai-service:  # Content generation (17011)
  whisper:     # Voice transcription (17012, optional)
  redis:       # Caching (17014)
```

### Health Monitoring
All services implement `/health` endpoints:
```bash
curl http://localhost:17010/health  # Gateway
curl http://localhost:17011/health  # AI Service
curl http://localhost:17012/health  # Whisper
```

## Common Tasks

### Start All Services
```bash
docker compose up -d
docker compose ps  # Verify all healthy
```

### Stop All Services
```bash
docker compose down
```

### View Logs
```bash
docker compose logs -f gateway      # Gateway logs
docker compose logs -f ai-service   # AI service logs
docker compose logs --tail=100      # Last 100 lines all services
```

### Restart Single Service
```bash
docker compose restart gateway
docker compose restart ai-service
```

### Rebuild After Code Changes
```bash
docker compose build gateway    # Rebuild specific service
docker compose up -d gateway    # Restart with new build
```

### Check Service Health
```bash
# Quick health check script
for service in gateway ai-service whisper; do
  echo "Checking $service..."
  curl -f http://localhost:1701X/health || echo "$service unhealthy"
done
```

## Related Documentation

- **Setup:** [../../00-getting-started/DEVELOPER-SETUP.md](../../00-getting-started/DEVELOPER-SETUP.md)
- **Architecture:** [../architecture/technical-architecture.md](../architecture/technical-architecture.md)
- **Ports:** [../../06-technical-reference/PORT-MAPPING.md](../../06-technical-reference/PORT-MAPPING.md)
- **Testing:** [../../01-user-guides/testing/TESTING-GUIDE.md](../../01-user-guides/testing/TESTING-GUIDE.md)

## Troubleshooting

### Services Won't Start
1. Check ports not in use: `lsof -i :17010-17014`
2. Check Docker running: `docker ps`
3. Check logs: `docker compose logs`
4. Verify `.env` file exists and is configured

### Service Unhealthy
1. Check logs: `docker compose logs [service]`
2. Verify dependencies (AI service needs Redis)
3. Check environment variables
4. Restart service: `docker compose restart [service]`

### AI Provider Errors
1. Verify API keys in `.env`
2. Check AI_PROVIDER setting (ollama/openai/claude)
3. If using Ollama, verify it's running: `ollama list`
4. Check rate limits for cloud providers

## Security Considerations

**Never commit:**
- `.env` file
- API keys
- Credentials
- Private keys

**Always:**
- Use `.env.example` as template
- Rotate API keys regularly
- Use HTTPS in production
- Monitor access logs
- Keep dependencies updated

---

**Navigation:**
- [📚 Documentation Index](../../README.md)
- [🤖 AI Agent Context](../../CLAUDE.md)
- [📁 Developer Guides](..)
