# Docker & Microservices Lessons

**Lessons learned while building and orchestrating the Space Adventures microservices architecture.**

---

## 2024-11-05: NCC-1701 Port System - Avoiding Common Port Conflicts

**Context:** Setting up Docker Compose for Gateway, AI Service, Redis services. Initial design used standard ports 8000-8003.

**Problem:** Common development ports (8000, 8001, 3000, 5432, 6379) frequently conflict with other local services. Developers often have multiple projects running or forgot to stop previous services.

**Solution:** Implemented Star Trek-themed port registry (NCC-1701 series):
- 17010: Gateway Service (NCC-1701-0)
- 17011: AI Service (NCC-1701-1)
- 17012: Whisper Service (NCC-1701-2) [optional]
- 17014: Redis (NCC-1701-4)

**Configuration:**
```yaml
# docker-compose.yml
services:
  gateway:
    ports:
      - "17010:8000"  # External:Internal
    environment:
      - PORT=8000
      - AI_SERVICE_URL=http://ai-service:8000
```

**Why This Matters:**
- Lower probability of port conflicts (17000 range rarely used)
- Memorable (Star Trek theme matches game)
- Professional practice (custom port ranges)
- Teaches port management strategies

**Additional Benefits:**
- Fun Easter egg for Star Trek fans
- Educational value for learning port management
- Easy to document ("NCC-1701 ports")

**Resources:**
- Docker Compose networking docs
- Port ranges 49152-65535 (ephemeral ports, safe to use)
- `/docs/02-architecture/NCC-1701-PORT-REGISTRY.md`

**Related Patterns:** Service discovery, environment-based configuration

---

## 2024-11-05: Health Check Dependencies in Docker Compose

**Context:** Gateway service starting before AI service was ready, causing connection errors.

**Problem:** Docker Compose `depends_on` only waits for container to **start**, not for service to be **ready**. Gateway tried to connect to AI service before it finished initialization.

**Solution:** Implement health checks with `condition: service_healthy`:

```yaml
services:
  ai-service:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  gateway:
    depends_on:
      ai-service:
        condition: service_healthy  # Wait for health, not just start
      redis:
        condition: service_healthy
```

**Why This Matters:**
- Prevents race conditions during startup
- Services start in correct order with dependencies ready
- Better development experience (fewer mysterious connection errors)
- Production-grade pattern

**Gotchas:**
- Health check endpoint must respond quickly (< timeout)
- Start period should account for slow initialization (AI model loading)
- Retries should be generous for development (slow machines)

**Resources:**
- Docker Compose healthcheck docs: https://docs.docker.com/compose/compose-file/compose-file-v3/#healthcheck

**Related Patterns:** Service orchestration, graceful startup patterns

---

## 2024-11-05: Environment Variables vs Hardcoded Config

**Context:** Initial Dockerfiles had hardcoded ports and service URLs. Made it difficult to change configuration without rebuilding images.

**Problem:** Hardcoded configuration requires image rebuilds for simple changes. Different environments (dev/staging/prod) need different configs.

**Solution:** Use environment variables with sensible defaults:

```dockerfile
# Dockerfile
ENV PORT=8000
ENV AI_SERVICE_URL=http://ai-service:8000
ENV REDIS_URL=redis://redis:6379

# Can override in docker-compose.yml or .env file
```

```yaml
# docker-compose.yml
services:
  gateway:
    environment:
      - PORT=${GATEWAY_PORT:-17010}
      - AI_SERVICE_URL=http://ai-service:8000
```

```bash
# .env file
GATEWAY_PORT=17010
AI_SERVICE_PORT=17011
REDIS_PORT=17014
```

**Why This Matters:**
- Configuration changes don't require rebuilds
- Same image works in different environments
- Easy to override for testing
- 12-factor app methodology

**Best Practices:**
- Provide sensible defaults
- Document all environment variables in `.env.example`
- Use `${VAR:-default}` syntax for defaults in Compose
- Never commit `.env` with secrets to git

**Resources:**
- 12-Factor App: Config (https://12factor.net/config)
- Docker Compose environment docs

**Related Patterns:** Configuration management, deployment strategies

---

## Template for New Lessons

```markdown
## [Date]: [Lesson Title]

**Context:** [What were you building?]

**Problem:** [What challenge did you face?]

**Solution:** [How did you solve it?]

**Configuration/Code:**
```yaml
# Show the pattern with actual config
```

**Why This Matters:** [Why should future-you care?]

**Gotchas:** [Things that might trip you up]

**Resources:** [Links to docs, articles, etc.]

**Related Patterns:** [Cross-references]
```

---

## Topics to Document (As We Learn)

**Docker Compose Orchestration:**
- [ ] Service restart policies (when to use always vs on-failure)
- [ ] Volume management for data persistence
- [ ] Network isolation strategies
- [ ] Logging and log aggregation
- [ ] Resource limits (memory, CPU)

**Microservices Communication:**
- [ ] Service discovery patterns
- [ ] Circuit breaker patterns (handling service failures)
- [ ] Retry logic and backoff strategies
- [ ] API versioning across services
- [ ] Request tracing and debugging

**Development Workflow:**
- [ ] Hot reload in Docker development
- [ ] Debugging services in containers
- [ ] Testing strategies for microservices
- [ ] Local vs production parity

**Performance:**
- [ ] Container optimization (image size, layers)
- [ ] Startup time optimization
- [ ] Resource allocation strategies
- [ ] Caching strategies (Docker layers, app-level)

---

**AI Agent:** Add lessons here as you discover Docker and microservices patterns. Focus on problems specific to this project's architecture.
