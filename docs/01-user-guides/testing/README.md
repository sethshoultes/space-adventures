# Testing Documentation

**Purpose:** Comprehensive testing procedures for Space Adventures.

## Files in This Directory

### [TESTING-GUIDE.md](./TESTING-GUIDE.md)
**The definitive testing guide for Space Adventures.**

Contains:
- Complete setup instructions
- 6 comprehensive test cases
- Performance benchmarks
- Troubleshooting guide
- Test report template

**Audience:** QA testers, playtesters, developers
**Time Required:** 20-30 minutes for full test suite

## Test Cases Overview

### Test Case 1: Service Connectivity
**Purpose:** Verify backend services are accessible
**Duration:** 2-3 minutes

### Test Case 2: AI Chat Integration
**Purpose:** Test all 4 AI personalities (ATLAS, Companion, MENTOR, CHIEF)
**Duration:** 5-7 minutes

### Test Case 3: Mission Generation
**Purpose:** Verify mission creation with different parameters
**Duration:** 3-5 minutes

### Test Case 4: Dialogue Generation
**Purpose:** Test NPC dialogue creation
**Duration:** 2-3 minutes

### Test Case 5: Save/Load System
**Purpose:** Verify game state persistence
**Duration:** 3-4 minutes

### Test Case 6: EventBus Signals
**Purpose:** Test event-driven architecture
**Duration:** 2-3 minutes

## Quick Start

```bash
# 1. Setup environment
Follow ../../../00-getting-started/DEVELOPER-SETUP.md

# 2. Start services
docker compose up -d

# 3. Open Godot
godot godot/project.godot

# 4. Run test scene (F5)
# Click test buttons in order 1-6

# 5. Document results
Use test report template in TESTING-GUIDE.md
```

## Prerequisites

Before testing:
- ✅ Docker services running
- ✅ Godot 4.2+ installed
- ✅ AI provider configured (Ollama or OpenAI)
- ✅ Test scene loads successfully

## Performance Benchmarks

Expected performance:
- Gateway health check: < 100ms
- AI chat response: 1-5 seconds
- Mission generation: 5-15 seconds
- Dialogue generation: 3-8 seconds
- Save/load: < 1 second
- EventBus signals: < 10ms

## Common Issues

### Services Not Available
**Solution:** Check `docker compose ps`, restart with `docker compose restart`

### AI Generation Timeouts
**Solution:** Increase timeout in service_manager.gd, verify AI provider running

### Save Files Not Found
**Solution:** Check godot/saves/ directory exists, verify file permissions

## Related Documentation

- **Setup:** [../../00-getting-started/DEVELOPER-SETUP.md](../../00-getting-started/DEVELOPER-SETUP.md)
- **Integration:** [../../02-developer-guides/architecture/INTEGRATION-GUIDE.md](../../02-developer-guides/architecture/INTEGRATION-GUIDE.md)
- **Architecture:** [../../02-developer-guides/architecture/technical-architecture.md](../../02-developer-guides/architecture/technical-architecture.md)

---

**Navigation:**
- [📚 Documentation Index](../../README.md)
- [🤖 AI Agent Context](../../CLAUDE.md)
- [📁 User Guides](..)
