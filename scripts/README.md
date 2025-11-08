# Service Management Scripts

Convenient scripts for managing Space Adventures microservices during development.

## Available Scripts

### 🚀 `start-all.sh`
Start all required services (Ollama, Redis, AI Service)

```bash
./scripts/start-all.sh
```

**What it does:**
- Checks if Ollama is running, starts if needed
- Checks if Redis is running, starts if needed
- Starts AI Service on port 17011
- Creates logs in `logs/` directory
- Waits for services to be ready
- Shows service URLs and status

**Logs created:**
- `logs/ai-service.log` - AI Service output
- `logs/ollama.log` - Ollama output
- `logs/redis.log` - Redis output

---

### 🛑 `stop-all.sh`
Stop all Space Adventures services

```bash
./scripts/stop-all.sh
```

**What it does:**
- Stops AI Service (kills Python process)
- Leaves Redis and Ollama running (shared services)

**Note:** Redis and Ollama are not stopped automatically since they might be used by other applications. To stop them:
```bash
redis-cli shutdown       # Stop Redis
pkill ollama            # Stop Ollama
```

---

### 🔄 `restart-ai.sh`
Quickly restart just the AI Service

```bash
./scripts/restart-ai.sh
```

**What it does:**
- Stops AI Service
- Starts AI Service
- Waits for service to be ready
- Shows new PID and status

**Use when:**
- You've made code changes to the AI service
- You need to reload the service quickly
- You don't want to restart Redis/Ollama

---

### 📊 `status.sh`
Check status of all services

```bash
./scripts/status.sh
```

**Output:**
- ✓ Green checkmark = service running
- ✗ Red X = service not running
- Shows ports for each service
- Shows AI Service details (providers, scheduler status)

**Example output:**
```
Ollama (port 11434): ✓ Running
Redis (port 6379): ✓ Running
AI Service (port 17011): ✓ Running

AI Service Details:
  Status: healthy
  Providers: ollama
  Orchestrator: enabled
  Scheduler: running (2 jobs)
```

---

### 📋 `logs.sh`
Tail AI Service logs in real-time

```bash
./scripts/logs.sh
```

**What it does:**
- Opens `logs/ai-service.log` with `tail -f`
- Shows real-time log output
- Press Ctrl+C to exit

**Useful for:**
- Debugging AI service issues
- Monitoring agent loop checks
- Watching LLM requests/responses

---

### 🎮 `dev.sh`
Development mode - start everything and prepare for coding

```bash
./scripts/dev.sh
```

**What it does:**
- Runs `start-all.sh`
- Shows summary of running services
- Displays log locations
- Prepares environment for Godot development

**Perfect for:**
- Starting your dev session
- Ensuring all dependencies are running before launching Godot

---

## Quick Reference

```bash
# Start everything
./scripts/start-all.sh

# Check what's running
./scripts/status.sh

# Restart AI service after code changes
./scripts/restart-ai.sh

# Watch logs
./scripts/logs.sh

# Stop everything
./scripts/stop-all.sh
```

---

## Service Ports

| Service    | Port  | URL                              |
|------------|-------|----------------------------------|
| AI Service | 17011 | http://localhost:17011/health    |
| Ollama     | 11434 | http://localhost:11434/api/tags  |
| Redis      | 6379  | localhost:6379                   |

---

## Troubleshooting

### "Port already in use"

If you see this error:
```bash
# Find what's using the port
lsof -i :17011

# Kill the process
kill -9 <PID>

# Or use restart script
./scripts/restart-ai.sh
```

### "AI Service not responding"

```bash
# Check logs
tail -20 logs/ai-service.log

# Check status
./scripts/status.sh

# Restart
./scripts/restart-ai.sh
```

### "Ollama not found"

Install Ollama:
```bash
# macOS
brew install ollama

# Or download from https://ollama.ai
```

### "Redis not found"

Install Redis:
```bash
# macOS
brew install redis

# Start Redis manually
redis-server --daemonize yes
```

---

## Development Workflow

**Typical workflow:**

1. **Start of day:**
   ```bash
   ./scripts/start-all.sh
   ```

2. **Make changes to AI service:**
   ```bash
   # Edit code in python/ai-service/src/

   # Restart to apply changes
   ./scripts/restart-ai.sh
   ```

3. **Debug issues:**
   ```bash
   # Check what's running
   ./scripts/status.sh

   # Watch logs
   ./scripts/logs.sh
   ```

4. **End of day:**
   ```bash
   ./scripts/stop-all.sh
   ```

---

## Logs

All logs are stored in `logs/` directory:

```
logs/
├── ai-service.log    # AI Service output
├── ollama.log        # Ollama output
└── redis.log         # Redis output
```

**Viewing logs:**
```bash
# Tail AI service logs
tail -f logs/ai-service.log

# Last 50 lines
tail -50 logs/ai-service.log

# Search logs
grep "ERROR" logs/ai-service.log
```

---

## Future Enhancements

When more services are added (Gateway, Whisper, etc.):
- Scripts will auto-detect and manage them
- `status.sh` will show all services
- `start-all.sh` will start them in correct order
- Individual restart scripts will be added (e.g., `restart-gateway.sh`)

---

## Notes

- Scripts are idempotent (safe to run multiple times)
- Services are started in correct dependency order
- Health checks ensure services are ready before proceeding
- Logs are rotated automatically (by service)
- All scripts use absolute paths (work from any directory)

---

**Created:** 2025-11-08
**Last Updated:** 2025-11-08
