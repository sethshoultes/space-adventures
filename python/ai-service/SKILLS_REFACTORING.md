# AI Skills System - Refactoring Decision

**Date:** 2025-11-08
**Status:** Skills system moved to experimental branch
**Main Branch:** Simplified to Phase 1 only

---

## Decision Summary

The complete AI Skills System (Phases 2 & 3) has been moved to an experimental branch (`feature/skills-system-experimental`) due to complexity concerns with local LLM models.

**Main branch now contains:**
- ✅ Phase 1: Enhanced static functions (12 basic functions)
- ✅ Simple ATLAS prompt without skills documentation
- ✅ Clean, straightforward implementation

**Experimental branch contains:**
- 🧪 Phase 2: Function composition system (skills)
- 🧪 Phase 3: Restricted code interpreter
- 🧪 All 21 tests passing
- 🧪 Complete documentation

---

## Why This Decision?

### User Feedback

**User's concern:**
> "How does the AI create skills? Does it create skills in the background? Or do I have to tell it specifically how to create skills? Maybe this is a little bit too complicated and we should probably move it to its own branch for later consideration."

### Key Issues Identified

1. **Complexity for Local Models**
   - Creating skills requires complex JSON structure building
   - 28 primitive operations to learn
   - Variable resolution syntax (`$variable`)
   - Small local models (Llama 3.2:3b) struggle with this complexity

2. **Practical Usage**
   - `execute_python()` is simpler and more intuitive
   - Basic functions cover most use cases
   - Skills system adds cognitive overhead
   - Benefits don't outweigh complexity for this project

3. **KISS Principle**
   - "Keep It Simple, Stupid"
   - Simpler solution is more maintainable
   - Easier to debug and understand
   - Better for hobby/learning project

---

## What's in Main Branch (Phase 1)

### Functions Available (12 total)

**Ship Information:**
- `get_ship_status()` - Complete ship status report
- `get_ship_info(field)` - Specific ship information
- `get_power_budget()` - Power consumption and availability
- `get_system_status(system_name)` - Individual system status
- `get_available_upgrades()` - List of available upgrades

**Player Information:**
- `get_player_info(field)` - Player information
- `get_player_skills()` - Player skill levels

**Mission & Context:**
- `get_mission_context()` - Current mission details
- `get_location_info()` - Current location information
- `get_inventory()` - Player inventory

**Actions:**
- `recommend_upgrade(system_name, rationale)` - Suggest upgrades
- `set_mission_hint(hint_text)` - Provide mission hints

### ATLAS Prompt

Simple, focused prompt covering:
- Role and capabilities
- Basic function usage
- Personality and communication style
- When to defer to other agents

**No complex skills documentation** - just straightforward function calling.

---

## What's in Experimental Branch

### Branch: `feature/skills-system-experimental`

**Complete implementation including:**

#### Phase 2: Function Composition System (Skills)

**Files:**
- `src/orchestrator/primitives.py` (313 lines)
  - 28 primitive operations across 6 categories
  - Pure functions for data transformation

- `src/orchestrator/skill_executor.py` (242 lines)
  - JSON-based skill execution engine
  - Step-by-step execution with validation
  - Variable resolution system

- `src/orchestrator/skill_storage.py` (405 lines)
  - Redis persistence for skills
  - Conversation/agent indexing
  - Metadata tracking

**Functions:**
- `create_skill()` - Create and save skill definitions
- `use_skill()` - Execute saved skills
- `list_skills()` - List available skills
- `get_available_primitives()` - Get primitive operations

#### Phase 3: Restricted Code Interpreter

**Files:**
- `src/orchestrator/code_validator.py` (395 lines)
  - AST-based code validation
  - Whitelist approach for security

- `src/orchestrator/code_executor.py` (406 lines)
  - Sandboxed execution environment
  - 2-second timeout (signal.SIGALRM)
  - 100 MB memory limit (resource.setrlimit)
  - Read-only game_state

**Function:**
- `execute_python()` - Execute validated Python code

#### Testing & Documentation

- `test_skills_system.py` (568 lines) - 21/21 tests passing
- `SKILLS_SYSTEM_COMPLETE.md` - Comprehensive system documentation
- `IMPLEMENTATION_SUMMARY.md` - Final implementation report

---

## How to Use

### Working with Main (Current)

```bash
# You're already on main
git status  # Should show: On branch main

# AI service running with 12 functions
curl http://localhost:17011/api/orchestrator/health
# functions_available: 12
```

**For development:**
- Use basic functions for ship/player queries
- ATLAS responds with simple, clear answers
- No complex skill creation needed

### Working with Experimental Branch

```bash
# Switch to experimental branch
git checkout feature/skills-system-experimental

# Restart AI service to load skills system
pkill -f "uvicorn main:app"
cd python/ai-service
source venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 17011

# Verify skills system loaded
curl http://localhost:17011/api/orchestrator/health
# functions_available: 17 (12 basic + 5 skills functions)

# Run comprehensive tests
python3 test_skills_system.py
```

**For experimentation:**
- Test skill creation
- Try Python code execution
- Experiment with primitives
- Build complex analysis capabilities

### Switching Back

```bash
# Return to main (simplified)
git checkout main

# Restart service
pkill -f "uvicorn main:app"
cd python/ai-service
source venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 17011
```

---

## Future Considerations

### When to Revisit Skills System

Consider moving back from experimental when:

1. **Better Local Models Available**
   - Larger models (7B+) that handle complex JSON
   - Better instruction-following capabilities
   - Improved reasoning about structured data

2. **Cloud LLM Integration**
   - Using GPT-4 or Claude for ATLAS
   - Models that excel at structured output
   - Cost is acceptable for project

3. **Specific Use Case Emerges**
   - Need for complex, reusable analysis patterns
   - Building domain-specific AI capabilities
   - Skills library becomes valuable

4. **User Explicitly Requests It**
   - Wants to experiment with skills
   - Has specific workflow in mind
   - Willing to handle complexity

### Alternative: Selective Features

Could cherry-pick specific features:

- ✅ Keep `execute_python()` in main (useful, simple)
- ❌ Keep skills in experimental (too complex)
- 🤔 Consider adding 3-5 most useful primitives to main

---

## Lessons Learned

### Design Principles Validated

1. **KISS Principle**
   - Simpler solution won
   - Complexity adds cognitive load
   - Perfect is the enemy of good

2. **YAGNI (You Aren't Gonna Need It)**
   - Built complex system before validating need
   - Should have tested Phase 1 longer first
   - User feedback confirmed suspicions

3. **Iterative Development**
   - Good to build experimental features
   - Good to move them to branches
   - Good to simplify when needed

### Technical Insights

1. **Local LLM Limitations**
   - Small models (3B) struggle with complex JSON
   - Better at simple function calls
   - Structured output is challenging

2. **Git Workflow**
   - Easy to preserve work in branches
   - Can switch between simple/complex versions
   - No code lost, just reorganized

3. **Testing Value**
   - 21 passing tests give confidence
   - Can return to experimental anytime
   - Implementation is solid, just too complex for now

---

## Statistics

### Code Metrics

**Main Branch (Simplified):**
- Files: Core orchestrator files only
- Functions: 12
- Complexity: Low

**Experimental Branch:**
- New Files Created: 6
- Lines Added: ~2,329
- Test Lines: 568
- Functions: 17 (12 + 5 skills)
- Tests: 21/21 passing
- Complexity: High

### Implementation Time

- Phase 1: ~2 hours
- Phase 2 & 3: ~4 hours (multi-hour session)
- Refactoring: ~30 minutes
- Total: ~6.5 hours

---

## Conclusion

**The skills system works perfectly** - all tests pass, it's well-designed, and it's production-ready. However, it's **too complex for the current use case** with small local LLM models.

**Decision:** Keep it in experimental branch for future use. Use simplified Phase 1 approach in main for now.

**Result:**
- ✅ Simpler, more maintainable codebase
- ✅ Better suited to local LLM capabilities
- ✅ Advanced features preserved for future
- ✅ User gets practical, working system

This is the right decision for a hobby project focused on learning and progress over perfection.

---

**Last Updated:** 2025-11-08
**Branch:** main (simplified)
**Experimental Branch:** feature/skills-system-experimental (full implementation)
