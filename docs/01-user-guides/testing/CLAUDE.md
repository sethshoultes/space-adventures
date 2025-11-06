# testing - AI Agent Context

**Purpose:** Testing procedures and test case documentation.

## Directory Contents

### Key Files
1. **TESTING-GUIDE.md** (656 lines) - Complete testing procedures
   - 6 comprehensive test cases
   - Setup and prerequisites
   - Performance benchmarks
   - Troubleshooting guide
   - Test report template

## When to Use This Documentation

**Use when:**
- Verifying features work correctly
- Running QA tests
- Debugging integration issues
- Creating test reports
- Performance benchmarking
- Regression testing

## Common Tasks

### Task: Run full test suite
1. Start services: `docker compose up -d`
2. Open Godot test scene
3. Execute Test Cases 1-6 sequentially
4. Document results using template
5. Report failures

### Task: Debug failed test
1. Identify which test case failed
2. Check service logs: `docker compose logs [service]`
3. Verify prerequisites met
4. Re-run specific test
5. Document findings

### Task: Add new test case
1. Read existing test case format
2. Identify feature to test
3. Write: Prerequisites, Steps, Expected Results, Pass/Fail
4. Add to TESTING-GUIDE.md
5. Update test case count

## Test Case Details

### TC1: Service Connectivity
**Tests:** Gateway (17010), AI Service (17011) health endpoints
**Critical:** Yes - all other tests depend on this
**Expected Time:** < 1 minute

### TC2: AI Chat Integration
**Tests:** 4 AI personalities, session management, context
**Critical:** Yes - core feature
**Expected Time:** 5-7 minutes
**Dependencies:** AI provider (Ollama/OpenAI)

### TC3: Mission Generation
**Tests:** AI-generated missions with different parameters
**Critical:** Yes - core gameplay feature
**Expected Time:** 3-5 minutes
**Dependencies:** TC1, TC2

### TC4: Dialogue Generation
**Tests:** NPC dialogue with personality traits
**Critical:** No - nice to have
**Expected Time:** 2-3 minutes

### TC5: Save/Load System
**Tests:** Game state persistence across multiple slots
**Critical:** Yes - data integrity
**Expected Time:** 3-4 minutes
**Dependencies:** GameState, SaveManager singletons

### TC6: EventBus Signals
**Tests:** Event-driven communication between systems
**Critical:** Yes - architecture foundation
**Expected Time:** 2-3 minutes

## AI Agent Instructions

**When updating tests:**
1. Verify all test cases still pass
2. Update expected results if features changed
3. Add new test cases for new features
4. Update performance benchmarks if infrastructure improved

**When test fails:**
1. Don't immediately assume code is broken
2. Verify prerequisites (services running, AI provider configured)
3. Check service logs for errors
4. Reproduce issue manually
5. Only then investigate code

**When creating test documentation:**
1. Use clear, numbered steps
2. Include exact button clicks/commands
3. Specify expected outputs precisely
4. Add pass/fail criteria
5. Include troubleshooting tips

## Relationships

**Depends On:**
- `../../00-getting-started/DEVELOPER-SETUP.md` - Environment setup
- `../../02-developer-guides/architecture/INTEGRATION-GUIDE.md` - System architecture
- Docker services running (gateway, ai-service, redis)
- Godot test scene (godot/scenes/main_menu.tscn)

**Validates:**
- Service connectivity
- Godot ↔ Backend integration
- AI content generation
- Save/load system
- Event-driven architecture

## Performance Expectations

**Acceptable:**
- Gateway health: < 100ms
- AI chat: 1-5 seconds (Ollama may be slower)
- Mission generation: 5-15 seconds
- Save/load: < 1 second

**Needs Investigation:**
- Gateway health: > 500ms
- AI chat: > 10 seconds
- Mission generation: > 30 seconds
- Save/load: > 2 seconds

## Quick Reference Commands

**Check service status:**
```bash
docker compose ps
curl http://localhost:17010/health
curl http://localhost:17011/health
```

**View logs:**
```bash
docker compose logs -f gateway
docker compose logs -f ai-service
docker compose logs --tail=100 ai-service
```

**Restart services:**
```bash
docker compose restart gateway
docker compose restart ai-service
docker compose restart redis
```

**Clean restart:**
```bash
docker compose down
docker compose up -d
```

## Test Report Template Location

Full template is in TESTING-GUIDE.md, includes:
- Test environment details
- Test results per case (Pass/Fail/Blocked/Skipped)
- Issues found
- Performance notes
- Screenshots/logs
- Overall assessment

---

**Parent Context:** [../../CLAUDE.md](../../CLAUDE.md)
**Directory Index:** [README.md](./README.md)
**User Guides:** [../CLAUDE.md](../CLAUDE.md)
