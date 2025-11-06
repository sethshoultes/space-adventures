# deployment - AI Agent Context

**Purpose:** CI/CD pipelines, deployment procedures, and infrastructure configuration.

## Directory Contents

### Key Files
1. **ci-cd-deployment.md** - Complete deployment guide
   - Docker Compose configuration
   - Environment management
   - CI/CD pipeline (GitHub Actions)
   - Monitoring and logging
   - Backup procedures
   - Security considerations

## When to Use This Documentation

**Use when:**
- Setting up deployment environment
- Configuring CI/CD pipelines
- Deploying to production
- Troubleshooting deployment issues
- Setting up monitoring
- Implementing backups
- Configuring environment variables

## Common Tasks

### Task: Initial deployment setup
1. Read ci-cd-deployment.md sections 1-3
2. Copy `.env.example` to `.env`
3. Configure environment variables
4. Run `docker compose up -d`
5. Verify health endpoints
6. Run integration tests

### Task: Deploy code changes
1. Commit changes to git
2. Tag release if needed: `git tag v0.x.x`
3. Build services: `docker compose build`
4. Restart: `docker compose up -d`
5. Verify health
6. Run smoke tests

### Task: Configure CI/CD
1. Read ci-cd-deployment.md Section 4
2. Create `.github/workflows/` directory
3. Copy workflow templates
4. Configure secrets in GitHub
5. Test pipeline on feature branch
6. Merge to main

### Task: Troubleshoot deployment
1. Check service status: `docker compose ps`
2. Review logs: `docker compose logs [service]`
3. Verify environment variables
4. Check port conflicts
5. Test health endpoints
6. Review ci-cd-deployment.md troubleshooting section

## Relationships

**Depends On:**
- `../architecture/technical-architecture.md` - Service architecture
- `../../06-technical-reference/PORT-MAPPING.md` - Port configuration
- `../../00-getting-started/DEVELOPER-SETUP.md` - Prerequisites

**Enables:**
- Production deployment
- Continuous integration
- Automated testing
- Service monitoring
- Disaster recovery

## Deployment Architecture

### Local Development
```
Developer Machine
├── Docker Desktop
├── Godot Editor
└── Services:
    ├── Gateway (17010)
    ├── AI Service (17011)
    ├── Whisper (17012, optional)
    └── Redis (17014)
```

### Production (Future)
```
Cloud Infrastructure
├── Container Orchestration (Docker/K8s)
├── Load Balancer
├── Services:
│   ├── Gateway (17010) × N replicas
│   ├── AI Service (17011) × N replicas
│   └── Redis (17014) - Persistent
├── Monitoring (Prometheus/Grafana)
└── Logging (ELK Stack)
```

## Environment Configuration

### Required Variables
```bash
# AI Provider
AI_PROVIDER=ollama              # or openai, claude
OPENAI_API_KEY=sk-...          # if using OpenAI
ANTHROPIC_API_KEY=sk-ant-...   # if using Claude

# Service Ports (NCC-1701)
GATEWAY_PORT=17010
AI_SERVICE_PORT=17011
WHISPER_PORT=17012
REDIS_PORT=17014

# Ollama (local AI)
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama2

# Features
ENABLE_WHISPER=false           # Voice transcription optional
ENABLE_IMAGE_GEN=false         # Image generation optional
```

### Optional Variables
```bash
# Performance
REDIS_MAX_MEMORY=512mb
AI_TIMEOUT=30

# Logging
LOG_LEVEL=INFO
LOG_FORMAT=json

# Caching
CACHE_TTL=86400  # 24 hours
```

## Docker Compose Structure

### Service Dependencies
```
Gateway ───────┐
               ├──> AI Service ──> Redis
Whisper ───────┘                    └──> Persistence Volume
```

### Health Check Strategy
- All services implement `/health` endpoint
- Gateway aggregates health status
- Unhealthy services auto-restart
- Dependencies checked before startup

### Volume Management
```yaml
volumes:
  redis-data:     # Persistent cache
  whisper-models: # Voice transcription models (optional)
```

## CI/CD Pipeline

### GitHub Actions Workflow
```yaml
on: [push, pull_request]
jobs:
  test:
    - Lint Python code
    - Run Python tests
    - Test Docker builds

  deploy:
    - Build containers
    - Push to registry
    - Deploy to environment
    - Run smoke tests
```

### Deployment Stages
1. **Build:** Compile and containerize services
2. **Test:** Run unit and integration tests
3. **Deploy:** Push to environment
4. **Verify:** Health checks and smoke tests
5. **Monitor:** Track metrics and logs

## Monitoring Strategy

### Health Endpoints
```bash
# Gateway health (includes all services)
GET /health
{
  "status": "healthy",
  "services": {
    "ai": "healthy",
    "redis": "healthy"
  }
}

# Individual service health
GET /api/ai/health
GET /api/whisper/health
```

### Metrics to Monitor
- Request latency (p50, p95, p99)
- Error rates (4xx, 5xx)
- Cache hit rate
- AI generation time
- Service uptime

### Logging
- Structured JSON logs
- Log levels: DEBUG, INFO, WARNING, ERROR
- Centralized log aggregation (future)
- Log rotation and retention

## Backup and Recovery

### What to Back Up
1. Redis data (cache can be regenerated)
2. Environment configuration
3. Custom AI prompts
4. User data (future)

### Backup Strategy
```bash
# Redis backup
docker compose exec redis redis-cli SAVE
docker compose cp redis:/data/dump.rdb ./backups/

# Configuration backup
cp .env .env.backup.$(date +%Y%m%d)
```

### Recovery Procedure
1. Stop services: `docker compose down`
2. Restore volumes
3. Restore configuration
4. Start services: `docker compose up -d`
5. Verify health
6. Run tests

## AI Agent Instructions

**When deploying:**
1. Always read ci-cd-deployment.md first
2. Verify all environment variables set
3. Test locally before production
4. Run health checks after deployment
5. Monitor logs for errors

**When troubleshooting:**
1. Check service status first
2. Review logs for specific service
3. Verify environment configuration
4. Test service dependencies
5. Check network connectivity

**When updating infrastructure:**
1. Document changes in ci-cd-deployment.md
2. Test in development first
3. Plan rollback strategy
4. Update CI/CD pipelines
5. Update monitoring dashboards

## Quick Commands

**Service Management:**
```bash
docker compose up -d           # Start all services
docker compose down            # Stop all services
docker compose ps              # Check status
docker compose logs -f         # Follow logs
docker compose restart         # Restart all services
```

**Individual Service:**
```bash
docker compose restart gateway      # Restart gateway
docker compose logs gateway         # View gateway logs
docker compose build gateway        # Rebuild gateway
docker compose up -d gateway        # Start gateway only
```

**Health Checks:**
```bash
curl http://localhost:17010/health  # Gateway
curl http://localhost:17011/health  # AI Service
curl http://localhost:17012/health  # Whisper
```

**Clean Up:**
```bash
docker compose down -v         # Remove volumes too
docker system prune -a         # Clean up everything
```

---

**Parent Context:** [../../CLAUDE.md](../../CLAUDE.md)
**Directory Index:** [README.md](./README.md)
**Developer Guides:** [../CLAUDE.md](../CLAUDE.md)
