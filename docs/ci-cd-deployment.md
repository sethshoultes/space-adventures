# Space Adventures - CI/CD & Deployment Guide

**Version:** 1.0
**Date:** November 5, 2025
**Purpose:** Complete CI/CD pipeline and deployment strategy

---

## Table of Contents
1. [Overview](#overview)
2. [Git Branching Strategy](#git-branching-strategy)
3. [Environment Configuration](#environment-configuration)
4. [CI/CD Pipeline](#cicd-pipeline)
5. [Deployment Process](#deployment-process)
6. [Monitoring & Logging](#monitoring--logging)
7. [Backup & Recovery](#backup--recovery)
8. [Security](#security)

---

## Overview

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     GIT WORKFLOW                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  feature/* ──┐                                             │
│  bugfix/*  ──┼──> develop ──> main ──> v1.0.0 (tag)       │
│  hotfix/*  ──┘        │          │          │              │
│                       │          │          │              │
│                       ▼          ▼          ▼              │
│                      DEV    STAGING    PRODUCTION          │
└─────────────────────────────────────────────────────────────┘
```

### Environments

**1. Development (dev)**
- **URL**: https://dev.space-adventures.example.com
- **Branch**: `develop`
- **Auto-deploy**: Yes (on push to develop)
- **Purpose**: Active development, feature testing
- **Database**: PostgreSQL (dev_database)
- **AI**: Ollama (local), mock providers

**2. Staging (staging)**
- **URL**: https://staging.space-adventures.example.com
- **Branch**: `main`
- **Auto-deploy**: Manual approval required
- **Purpose**: Pre-production testing, QA
- **Database**: PostgreSQL (staging_database)
- **AI**: Production AI providers (limited quota)

**3. Production (prod)**
- **URL**: https://space-adventures.example.com
- **Branch**: Tagged releases (v1.0.0, v1.1.0, etc.)
- **Auto-deploy**: Manual approval + tagged release
- **Purpose**: Live production environment
- **Database**: PostgreSQL with replication
- **AI**: All production AI providers

---

## Git Branching Strategy

### Git Flow Model

We use **Git Flow** with the following branches:

#### **Main Branches**

**`main`** (protected)
- Production-ready code only
- Never commit directly to main
- Merged from develop via Pull Request
- Tagged with version numbers (v1.0.0, v1.1.0)
- Deploys to staging (auto) and production (manual)

**`develop`** (protected)
- Integration branch for features
- Active development happens here
- Features merge into develop
- Auto-deploys to development environment
- Create release branches from develop

#### **Supporting Branches**

**`feature/*`** (temporary)
- Naming: `feature/add-ship-classification`
- Branch from: `develop`
- Merge back to: `develop`
- Deleted after merge
- Used for new features

**`bugfix/*`** (temporary)
- Naming: `bugfix/fix-warp-calculation`
- Branch from: `develop`
- Merge back to: `develop`
- Used for non-critical bugs

**`hotfix/*`** (temporary)
- Naming: `hotfix/critical-security-fix`
- Branch from: `main`
- Merge back to: `main` AND `develop`
- Used for critical production fixes
- Tagged immediately after merge

**`release/*`** (temporary)
- Naming: `release/v1.2.0`
- Branch from: `develop`
- Merge back to: `main` AND `develop`
- Used for release preparation
- Only bug fixes, no new features

### Branch Protection Rules

**`main` branch:**
```yaml
Protection Rules:
  - Require pull request reviews: 2
  - Dismiss stale reviews: Yes
  - Require status checks to pass: Yes
  - Require branches to be up to date: Yes
  - Include administrators: Yes
  - Restrict pushes: Yes
  - Required checks:
    - lint
    - test-python
    - test-godot
    - build
```

**`develop` branch:**
```yaml
Protection Rules:
  - Require pull request reviews: 1
  - Require status checks to pass: Yes
  - Required checks:
    - lint
    - test-python
```

### Commit Message Convention

Follow **Conventional Commits**:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Build process, tooling changes
- `ci`: CI/CD changes

**Examples:**
```
feat(ship-systems): Add warp drive Level 4 capabilities

Implemented Level 4 warp drive with extended range and faster
calculations. Updated ship-systems.md documentation.

Closes #123

---

fix(api): Fix race condition in mission generation

Race condition occurred when multiple concurrent requests hit the
mission generation endpoint. Added request queue and locking.

Fixes #456

---

docs(readme): Update installation instructions for Docker

Added troubleshooting section for common Docker issues.
```

---

## Environment Configuration

### Environment Variables

#### **Development (.env.dev)**
```bash
# Environment
ENVIRONMENT=development
LOG_LEVEL=DEBUG
DEBUG=true
RELOAD=true

# Database
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=space_adventures_dev
POSTGRES_USER=dev_user
POSTGRES_PASSWORD=dev_password

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_DB=0

# AI Providers
AI_PROVIDER=ollama
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama2
OPENAI_API_KEY=sk-test-key
ANTHROPIC_API_KEY=sk-ant-test-key

# Cache
CACHE_ENABLED=true
CACHE_TTL_SECONDS=3600

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:8080
```

#### **Staging (.env.staging)**
```bash
# Environment
ENVIRONMENT=staging
LOG_LEVEL=INFO
DEBUG=false

# Database
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=space_adventures_staging
POSTGRES_USER=staging_user
POSTGRES_PASSWORD=${STAGING_DB_PASSWORD}  # From secrets

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_DB=0

# AI Providers
AI_PROVIDER=openai
OPENAI_API_KEY=${OPENAI_API_KEY}
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}

# Cache
CACHE_ENABLED=true
CACHE_TTL_SECONDS=86400

# Monitoring
SENTRY_DSN=${SENTRY_DSN}
SENTRY_ENVIRONMENT=staging

# CORS
CORS_ORIGINS=https://staging.space-adventures.example.com
```

#### **Production (.env.prod)**
```bash
# Environment
ENVIRONMENT=production
LOG_LEVEL=WARNING
DEBUG=false

# Database
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=space_adventures_prod
POSTGRES_USER=prod_user
POSTGRES_PASSWORD=${PROD_DB_PASSWORD}  # From secrets

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_DB=0

# AI Providers
AI_PROVIDER=openai
OPENAI_API_KEY=${OPENAI_API_KEY}
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
GOOGLE_API_KEY=${GOOGLE_API_KEY}

# Cache
CACHE_ENABLED=true
CACHE_TTL_SECONDS=86400

# Monitoring
SENTRY_DSN=${SENTRY_DSN}
SENTRY_ENVIRONMENT=production
SENTRY_TRACES_SAMPLE_RATE=0.1

# Security
SECRET_KEY=${SECRET_KEY}
CORS_ORIGINS=https://space-adventures.example.com

# Backup
S3_BACKUP_BUCKET=space-adventures-backups
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
```

### GitHub Secrets

Configure these in GitHub Settings > Secrets and variables > Actions:

**Development:**
- `DEV_SERVER_HOST`
- `DEV_SERVER_USER`
- `DEV_SERVER_SSH_KEY`
- `DEV_API_URL`

**Staging:**
- `STAGING_SERVER_HOST`
- `STAGING_SERVER_USER`
- `STAGING_SERVER_SSH_KEY`
- `STAGING_API_URL`
- `STAGING_DB_PASSWORD`

**Production:**
- `PROD_SERVER_HOST`
- `PROD_SERVER_USER`
- `PROD_SERVER_SSH_KEY`
- `PROD_API_URL`
- `PROD_DB_PASSWORD`
- `SECRET_KEY`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `S3_BACKUP_BUCKET`

**API Keys:**
- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY`
- `GOOGLE_API_KEY`

**Monitoring:**
- `SENTRY_DSN`
- `GRAFANA_PASSWORD`

**Notifications:**
- `SLACK_WEBHOOK`

---

## CI/CD Pipeline

### Pipeline Overview

```
┌──────────────────────────────────────────────────────────┐
│                    CI/CD STAGES                          │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  1. LINT                                                 │
│     ├─ Black (formatting)                               │
│     ├─ isort (imports)                                  │
│     ├─ Flake8 (linting)                                 │
│     └─ MyPy (type checking)                             │
│                                                          │
│  2. TEST                                                 │
│     ├─ Python unit tests (pytest)                       │
│     ├─ Integration tests                                │
│     ├─ Godot validation                                 │
│     └─ Code coverage                                    │
│                                                          │
│  3. BUILD                                                │
│     ├─ Docker image build                               │
│     ├─ Tag with version/branch                          │
│     └─ Push to registry                                 │
│                                                          │
│  4. DEPLOY                                               │
│     ├─ Deploy to environment                            │
│     ├─ Run migrations                                   │
│     ├─ Health checks                                    │
│     └─ Smoke tests                                      │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Workflow Triggers

| Event | Branch | Workflow |
|-------|--------|----------|
| Push | `develop` | Lint → Test → Build → Deploy to Dev |
| Push | `main` | Lint → Test → Build → Deploy to Staging (approval) |
| Push | `feature/*` | Lint → Test |
| Pull Request | → `develop` | Lint → Test |
| Pull Request | → `main` | Lint → Test → Build |
| Tag | `v*` | Lint → Test → Build → Deploy to Production (approval) |

### Job Dependencies

```
lint
 └─> test-python ─┐
 └─> test-godot ──┤
                  ├─> build
                  │    └─> deploy-dev
                  │    └─> deploy-staging
                  │         └─> deploy-production
```

---

## Deployment Process

### Development Deployment (Automatic)

**Trigger:** Push to `develop` branch

```bash
# Developer workflow
git checkout develop
git pull origin develop
git checkout -b feature/new-feature
# ... make changes ...
git add .
git commit -m "feat(scope): description"
git push origin feature/new-feature

# Create PR to develop
# After approval and merge, auto-deploys to dev
```

**What happens:**
1. CI runs lint and tests
2. Docker image built and tagged `develop-latest`
3. Image pushed to registry
4. SSH into dev server
5. Pull new image
6. Run `docker-compose -f docker-compose.dev.yml up -d`
7. Health check
8. Slack notification

### Staging Deployment (Manual Approval)

**Trigger:** Push to `main` branch (after PR from `develop`)

```bash
# Create release PR
git checkout develop
git pull origin develop
git checkout main
git pull origin main
git merge develop
git push origin main
```

**What happens:**
1. CI runs full test suite
2. Docker image built and tagged `staging-latest`
3. **Manual approval required** in GitHub Actions
4. Deploy to staging server
5. Run database migrations
6. Health checks
7. Smoke tests
8. Slack notification

### Production Deployment (Tagged Release)

**Trigger:** Create and push a version tag

```bash
# Create release
git checkout main
git pull origin main
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin v1.2.0
```

**What happens:**
1. Full CI pipeline runs
2. **Automated database backup**
3. Build image tagged `production-latest` and `v1.2.0`
4. **Manual approval required** (protected environment)
5. Deploy to production
6. Run migrations
7. Health checks
8. Smoke tests
9. Create GitHub release
10. Slack notification

### Rollback Process

**Manual trigger:**

```bash
# Option 1: Revert to previous tag
git checkout main
git tag -a v1.1.1 -m "Rollback to v1.1.1"
git push origin v1.1.1

# Option 2: Manual rollback via SSH
ssh prod-server
cd /opt/space-adventures/production
git checkout v1.1.1
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d
```

---

## Monitoring & Logging

### Health Checks

**Endpoints:**
- `/health` - Overall service health
- `/api/missions/health` - Missions service
- `/api/documentation/health` - Documentation service

**Health check response:**
```json
{
  "status": "healthy",
  "version": "1.2.0",
  "environment": "production",
  "services": {
    "database": "healthy",
    "redis": "healthy",
    "ai_providers": {
      "openai": "healthy",
      "anthropic": "healthy"
    }
  },
  "uptime_seconds": 86400
}
```

### Prometheus Metrics

**Metrics collected:**
- Request rate, latency, errors (RED metrics)
- Database query performance
- Redis hit rate
- AI generation times
- Docker container metrics
- System resources (CPU, memory, disk)

**Custom metrics:**
```python
# python/src/monitoring/metrics.py

from prometheus_client import Counter, Histogram, Gauge

# Request metrics
http_requests_total = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

http_request_duration = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration',
    ['method', 'endpoint']
)

# AI metrics
ai_generation_duration = Histogram(
    'ai_generation_duration_seconds',
    'AI content generation duration',
    ['provider', 'task_type']
)

ai_generation_errors = Counter(
    'ai_generation_errors_total',
    'AI generation errors',
    ['provider', 'error_type']
)

# Game metrics
active_players = Gauge(
    'active_players',
    'Number of active players'
)

missions_completed = Counter(
    'missions_completed_total',
    'Total missions completed',
    ['mission_type']
)
```

### Grafana Dashboards

**1. System Overview Dashboard**
- Service health status
- Request rate and latency
- Error rate
- Active users
- Database connections
- Redis memory usage

**2. AI Performance Dashboard**
- Generation times by provider
- Token usage and costs
- Cache hit rates
- Error rates by provider
- Queue depth and processing time

**3. Game Metrics Dashboard**
- Active players
- Missions completed
- Ship classifications achieved
- XP distribution
- Popular mission types

### Logging

**Log levels by environment:**
- Development: DEBUG
- Staging: INFO
- Production: WARNING

**Log format:**
```json
{
  "timestamp": "2025-11-05T14:30:00Z",
  "level": "INFO",
  "service": "ai-service",
  "environment": "production",
  "request_id": "abc123",
  "user_id": "user_456",
  "message": "Mission generated successfully",
  "metadata": {
    "mission_type": "exploration",
    "generation_time_ms": 1250,
    "ai_provider": "claude"
  }
}
```

**Log aggregation:**
- Centralized logging with Loki or ELK stack
- Retention: 30 days production, 7 days staging/dev
- Alert on ERROR level logs in production

---

## Backup & Recovery

### Automated Backups

**Schedule:**
- Production: Every 6 hours
- Staging: Daily at 2 AM UTC
- Development: Not backed up (test data)

**Backup script:**
```bash
#!/bin/bash
# scripts/backup-prod.sh

set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
BACKUP_FILE="space_adventures_${TIMESTAMP}.sql"

# PostgreSQL backup
docker-compose exec -T postgres pg_dump -U prod_user -d space_adventures_prod > "${BACKUP_DIR}/${BACKUP_FILE}"

# Compress
gzip "${BACKUP_DIR}/${BACKUP_FILE}"

# Upload to S3
aws s3 cp "${BACKUP_DIR}/${BACKUP_FILE}.gz" "s3://${S3_BUCKET}/backups/${BACKUP_FILE}.gz"

# Clean up old local backups (keep last 7 days)
find ${BACKUP_DIR} -name "*.sql.gz" -mtime +7 -delete

# Clean up old S3 backups (keep last 30 days)
aws s3 ls "s3://${S3_BUCKET}/backups/" | while read -r line; do
    fileDate=$(echo $line | awk '{print $1}')
    fileName=$(echo $line | awk '{print $4}')
    age=$(( ($(date +%s) - $(date -d "$fileDate" +%s)) / 86400 ))
    if [ $age -gt 30 ]; then
        aws s3 rm "s3://${S3_BUCKET}/backups/${fileName}"
    fi
done

echo "Backup completed: ${BACKUP_FILE}.gz"
```

**Backup verification:**
- Weekly automated restore test on staging
- Alert if backup fails
- Backup size monitoring

### Disaster Recovery

**Recovery Time Objective (RTO):** 1 hour
**Recovery Point Objective (RPO):** 6 hours

**Recovery steps:**

1. **Restore database from backup:**
```bash
# Download latest backup from S3
aws s3 cp "s3://${S3_BUCKET}/backups/latest.sql.gz" ./restore.sql.gz
gunzip restore.sql.gz

# Restore to PostgreSQL
docker-compose exec -T postgres psql -U prod_user -d space_adventures_prod < restore.sql

# Verify
docker-compose exec postgres psql -U prod_user -d space_adventures_prod -c "SELECT COUNT(*) FROM players;"
```

2. **Redeploy services:**
```bash
cd /opt/space-adventures/production
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

3. **Verify health:**
```bash
curl -f https://space-adventures.example.com/health
```

---

## Security

### SSL/TLS Certificates

**Let's Encrypt with Certbot:**

```bash
# Install certbot
sudo apt-get install certbot

# Obtain certificate
sudo certbot certonly --standalone -d space-adventures.example.com

# Auto-renewal cron
0 0 1 * * certbot renew --quiet
```

### Security Headers

**Nginx configuration:**
```nginx
# nginx/prod.conf

add_header X-Frame-Options "SAMEORIGIN";
add_header X-Content-Type-Options "nosniff";
add_header X-XSS-Protection "1; mode=block";
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';";
```

### Secrets Management

**Never commit secrets to Git!**

✅ **Good:**
- Use environment variables
- Store in GitHub Secrets
- Use AWS Secrets Manager or HashiCorp Vault in production

❌ **Bad:**
- Hardcoded API keys in code
- .env files committed to Git
- Passwords in docker-compose files

### Database Security

**PostgreSQL hardening:**
```sql
-- Create read-only user for replicas
CREATE USER readonly_user WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE space_adventures_prod TO readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_user;

-- Restrict network access (postgresql.conf)
listen_addresses = 'localhost'

-- Require SSL
ssl = on
ssl_cert_file = '/etc/ssl/certs/server.crt'
ssl_key_file = '/etc/ssl/private/server.key'
```

### Dependency Scanning

**Automated security scans:**
- Dependabot for dependency updates
- Snyk for vulnerability scanning
- Trivy for Docker image scanning

---

## Troubleshooting

### Common Issues

**1. Deployment fails with "Image pull failed"**
```bash
# Solution: Check registry authentication
docker login ghcr.io -u <username> -p <GITHUB_TOKEN>
```

**2. Database migration fails**
```bash
# Solution: Manual migration
docker-compose exec ai-service alembic upgrade head
```

**3. Health check fails after deployment**
```bash
# Check logs
docker-compose logs -f ai-service

# Check service status
docker-compose ps
```

**4. High memory usage**
```bash
# Check container stats
docker stats

# Restart specific service
docker-compose restart ai-service
```

---

## Quick Reference Commands

### Development
```bash
# Start dev environment
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Run tests
docker-compose -f docker-compose.dev.yml exec ai-service pytest

# Shell access
docker-compose -f docker-compose.dev.yml exec ai-service /bin/sh
```

### Staging
```bash
# Deploy to staging
git push origin main

# Check deployment status
# (View in GitHub Actions)

# SSH to staging server
ssh staging-server
cd /opt/space-adventures/staging
docker-compose -f docker-compose.staging.yml ps
```

### Production
```bash
# Create release
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0

# Manual rollback
ssh prod-server
cd /opt/space-adventures/production
git checkout v1.1.1
docker-compose -f docker-compose.prod.yml up -d --force-recreate

# View production logs
ssh prod-server
docker-compose -f docker-compose.prod.yml logs -f --tail=100
```

---

**Document Complete**
**Last Updated:** November 5, 2025
