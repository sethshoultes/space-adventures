# 01-user-guides - AI Agent Context

**Purpose:** Testing and gameplay guides for end users and QA testers.

## Directory Contents

### Subdirectories
- **testing/** - Testing procedures and test cases

### Key Files
- **testing/TESTING-GUIDE.md** (656 lines) - Comprehensive testing guide

## When to Use This Directory

**Use this documentation when:**
- Creating test plans
- Writing testing procedures
- Documenting QA processes
- Creating user-facing guides
- Reporting bugs
- Verifying features work correctly

## Common Tasks

### Task: Set up testing environment
1. Follow `../00-getting-started/DEVELOPER-SETUP.md`
2. Verify all services running: `docker compose ps`
3. Open Godot test scene
4. Begin testing/TESTING-GUIDE.md procedures

### Task: Run comprehensive tests
1. Read testing/TESTING-GUIDE.md overview
2. Execute 6 test cases in order
3. Document results using test report template
4. Report failures with detailed logs

### Task: Create new test case
1. Read existing test cases in testing/TESTING-GUIDE.md
2. Follow test case format (Prerequisites, Steps, Expected Results, Pass/Fail)
3. Add to appropriate section
4. Update test case count in overview

## Relationships

**Depends On:**
- `../00-getting-started/DEVELOPER-SETUP.md` - Environment setup
- `../02-developer-guides/architecture/INTEGRATION-GUIDE.md` - System understanding
- Backend services running

**Used By:**
- QA testers
- Playtesters
- Developers verifying features
- CI/CD automated testing (future)

**Related Documentation:**
- **Architecture:** `../02-developer-guides/architecture/technical-architecture.md`
- **Game Design:** `../03-game-design/core-systems/game-design-document.md`

## Key Concepts

### Test Cases
6 comprehensive test cases covering:
1. Service connectivity
2. AI chat integration (4 personalities)
3. Mission generation
4. Dialogue generation
5. Save/load system
6. EventBus signals

### Test Report Template
Standard format for reporting test results:
- Test environment details
- Test results per case
- Issues found
- Performance notes
- Screenshots/logs

### Performance Benchmarks
- Gateway health: < 100ms
- AI chat: 1-5 seconds
- Mission generation: 5-15 seconds
- Save/load: < 1 second

## AI Agent Instructions

**When creating test documentation:**
1. Follow format in testing/TESTING-GUIDE.md
2. Include Prerequisites, Steps, Expected Results
3. Add pass/fail criteria
4. Include troubleshooting tips

**When updating tests:**
1. Verify tests still work
2. Update expected results if features changed
3. Add new test cases for new features
4. Update performance benchmarks

**When troubleshooting test failures:**
1. Check service availability
2. Review logs
3. Verify prerequisites met
4. Check for regression

## Testing Strategy

### Manual Testing (Current)
- 6 comprehensive test cases
- Test scene with interactive buttons
- Real-time output logging
- Manual verification

### Automated Testing (Future)
- GDScript unit tests
- Python pytest integration
- CI/CD test runner
- Performance regression tests

## Quick Reference

**Run all tests:**
1. Start services: `docker compose up -d`
2. Open Godot: `godot godot/project.godot`
3. Press F5 to run test scene
4. Click each test button in order

**Check test prerequisites:**
- ✅ Docker services running
- ✅ Gateway responsive (http://localhost:17010/health)
- ✅ AI service responsive (http://localhost:17011/health)
- ✅ Ollama running or OpenAI configured

**Report test failure:**
1. Note which test failed
2. Copy output logs
3. Screenshot if visual issue
4. Check service logs: `docker compose logs`
5. Use test report template

---

**Parent Context:** [../CLAUDE.md](../CLAUDE.md)
**Directory Index:** [README.md](./README.md)
