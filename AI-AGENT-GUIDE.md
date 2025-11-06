# AI Agent Development Guide

**For AI developers (Claude Code, etc.) working on this project.**

This project uses AI agents as the **primary developers**. You (AI agent) will perform ~99% of implementation work. The user provides direction, decisions, and approval.

---

## Quick Start

**When starting a new session:**

1. **Read** `/STATUS.md` - Current task and context
2. **Check** `/DECISIONS.md` - Don't re-decide things
3. **Review** current directory's `CLAUDE.md` - Specific guidance
4. **Reference** `/ROADMAP.md` - Current milestone checklist
5. **Proceed** with implementation

**When finishing a session:**

1. **Update** `/STATUS.md` with progress
2. **Commit** with detailed message
3. **Document** decisions in `/DECISIONS.md` (if any)
4. **Update** `/JOURNAL.md` if you learned something new
5. **Mark** checklist items in `/ROADMAP.md`

---

## Decision Authority Levels

### ✅ Decide Autonomously (Just Do It)

You have full authority to decide and implement:

**Code Style & Organization:**
- Variable and function naming
- Code formatting and indentation
- File organization within established patterns
- Directory structure for new features (following existing patterns)
- Code comments and inline documentation

**Implementation Details:**
- Which GDScript/Python patterns to use
- How to structure classes and functions
- Error handling approaches
- Performance optimizations (non-breaking)
- Refactoring for readability
- Test implementations

**Documentation:**
- Update docs as you work
- Add code comments
- Create new CLAUDE.md files for new directories
- Update README files
- Document discoveries in `/JOURNAL.md`

**Dependencies:**
- Small utility libraries (must document why)
- Godot plugins (common, well-supported)
- Python packages (within reason, document)

**Bug Fixes:**
- Fix obvious bugs
- Correct typos and errors
- Improve error messages
- Fix broken functionality

**Principles to Follow:**
- SOLID, DRY, KISS, YAGNI
- Godot best practices
- Python best practices (PEP 8)
- Clear over clever code
- Simple over complex solutions

### ⚠️ Propose First (Quick Check)

Ask before implementing, but you can suggest solution:

**Architecture Changes:**
- Adding new singletons
- Changing service boundaries
- Modifying core data structures
- Changing API contracts

**Significant Refactoring:**
- Renaming core classes
- Reorganizing major systems
- Changing established patterns
- Breaking changes to APIs

**New Features:**
- Adding features not in roadmap
- Expanding scope beyond milestone
- Adding new systems/mechanics
- Significant UI additions

**Technology Decisions:**
- Adding new backend services
- Changing database approaches
- Adding new external APIs
- Major dependency additions

**How to Propose:**
```markdown
**Proposal:** [What you want to do]

**Rationale:** [Why this is better]

**Alternatives:** [Other options considered]

**Impact:** [What changes, what breaks]

**Recommendation:** [Your suggestion]

Proceed? (yes/no/adjust)
```

### 🛑 Always Ask (Need Approval)

**Never decide these alone - always ask first:**

**Game Design:**
- Ship system balance (damage, power costs, etc.)
- Player progression (XP curves, level requirements)
- Mission difficulty and rewards
- Ship class requirements
- Resource costs and availability

**User-Facing Content:**
- Mission narratives and dialogue
- Character personality traits
- Story decisions and consequences
- Tutorial text and guidance
- UI copy and messaging

**Scope Changes:**
- Cutting planned features
- Adding major features
- Changing milestone goals
- Deferring implementations

**Breaking Changes:**
- Changes that break saves
- Changes that break existing gameplay
- Changes that require user migration
- Major API redesigns

**Technology Stack:**
- Removing/replacing core services
- Changing AI providers
- Major architecture pivots
- Changing game engine approaches

---

## Development Workflow

### Standard Session Pattern

```
1. Read STATUS.md
   ↓
2. Check ROADMAP.md for current checklist
   ↓
3. Read relevant CLAUDE.md for context
   ↓
4. Implement next item on checklist
   ↓
5. Test implementation
   ↓
6. Update STATUS.md
   ↓
7. Commit with message
   ↓
8. Check off ROADMAP.md item
   ↓
9. Update JOURNAL.md if learned something
```

### When You Hit a Blocker

**Critical Blocker (stops progress):**
- **Stop work**
- **Document in STATUS.md** under "Blockers"
- **Ask user immediately**
- Example: "Need game design decision on ship balance"

**Non-Critical Blocker (other work possible):**
- **Make reasonable assumption**
- **Mark with `TODO: VERIFY` in code**
- **Document in STATUS.md** under "Notes for Next Session"
- **Continue with other tasks**
- **Mention at end of session**
- Example: "Guessed power cost formula, marked for verification"

**Technical Problem (can't solve):**
- **Document what you tried**
- **Research approaches**
- **Ask user for guidance or decision**
- Example: "Tried A, B, C - all have tradeoffs, need direction"

### Commit Strategy

**Commit frequency: After each logical unit of work**

**Commit Message Format:**
```
<type>: <short summary>

<detailed explanation>
- What changed
- Why it changed
- Any caveats or TODOs

Related: [Link to relevant doc if applicable]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code restructuring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

**Example:**
```
feat: Implement Hull system Level 0->1 upgrade

Added hull_system.gd with health tracking and upgrade mechanics.
Integrated with GameState singleton for persistence.

- Hull starts at Level 0 (broken, 0 HP)
- Can upgrade to Level 1 (50 HP, costs 100 resources)
- Health persists through save/load
- Emits EventBus.system_upgraded signal

TODO: Verify power cost formula with user
Related: docs/03-game-design/ship-systems/ship-systems.md
```

---

## Code Style Guidelines

### GDScript

**Follow Godot best practices:**

```gdscript
# Use type hints everywhere
var health: int = 100
var ship_name: String = "Enterprise"
var systems: Dictionary = {}

# Functions with type hints
func calculate_damage(base_damage: int, armor: int) -> int:
    return max(0, base_damage - armor)

# Constants in SCREAMING_CASE
const MAX_LEVEL: int = 5
const DEFAULT_POWER: int = 100

# Classes in PascalCase
class_name ShipSystem extends Node

# Properties and methods in snake_case
var current_health: int
func take_damage(amount: int) -> void:
    pass

# Document complex logic
func complex_calculation() -> float:
    # This formula balances power consumption with level scaling
    # See docs/03-game-design/ship-systems/ship-systems.md for rationale
    return base_value * pow(level, 1.5)
```

**Signals:**
```gdscript
# Define signals at top of class
signal health_changed(new_health: int, old_health: int)
signal system_upgraded(system_name: String, new_level: int)

# Emit with descriptive names
health_changed.emit(current_health, previous_health)
```

**Error Handling:**
```gdscript
# Use push_error for errors
if not is_valid():
    push_error("Invalid state: Cannot upgrade while damaged")
    return false

# Use assert for development checks
assert(level >= 0 and level <= MAX_LEVEL, "Level out of range")

# Return status booleans for operations
func upgrade() -> bool:
    if not can_upgrade():
        return false
    # ... upgrade logic
    return true
```

### Python

**Follow PEP 8 and FastAPI best practices:**

```python
# Type hints everywhere
def calculate_power(level: int) -> int:
    return 50 * level

# Pydantic models for all data
from pydantic import BaseModel, Field

class ShipSystem(BaseModel):
    level: int = Field(ge=0, le=5, description="System level 0-5")
    health: int = Field(ge=0, description="Current health points")
    active: bool = Field(default=False, description="Is system operational")

# Async for I/O operations
async def generate_mission(difficulty: str) -> Mission:
    response = await ai_provider.generate(prompt)
    return Mission.parse_obj(response)

# Descriptive variable names
ship_power_consumption = calculate_total_power(systems)
available_power = power_core_output - ship_power_consumption
```

**Documentation:**
```python
def complex_function(param: int) -> str:
    """
    Brief description of what this does.

    Args:
        param: What this parameter means

    Returns:
        What the return value represents

    Raises:
        ValueError: When this might raise an error
    """
    pass
```

---

## Communication & Updates

### After Each Session

**Update STATUS.md with:**
- Current task progress
- What's working
- Any blockers
- Next session starting point

**Example:**
```markdown
## 🎯 Current Task
Implementing Hull system (Level 0→1)

**Progress:** 80% complete
- ✅ Created hull_system.gd
- ✅ Integrated with GameState
- ✅ Added upgrade mechanics
- 🔨 Working on: Save/load persistence
- ⏳ Next: Testing and validation

## 💡 Notes for Next Session
- TODO: Verify power cost formula (assumed 10 per level)
- Health formula works well in testing
- Need to test edge case: upgrading with low resources
```

### Commit Messages

**Be detailed in commits:**
- What changed (code)
- Why it changed (rationale)
- Any assumptions or TODOs
- Link to relevant docs

**User should be able to understand progress by reading git log.**

### Ask vs Tell

**When to ask:**
- Game balance decisions
- Content creation (missions, dialogue)
- Scope changes
- User-facing changes
- Breaking changes

**When to tell (in STATUS.md):**
- Implementation progress
- Technical decisions made
- Blockers hit
- Assumptions made (mark for verification)

---

## Working with ROADMAP.md

**The roadmap is your task list.**

### Check Off Items As You Complete Them

```markdown
## Milestone 1 Checklist

### Ship Systems
- [x] Hull system (Level 0→1) ✅
- [ ] **CURRENT** → Power Core system (Level 0→1) 🔨
- [ ] **NEXT** → Propulsion system (Level 0→1) ⏳
```

**Update symbols:**
- `[x]` = Complete
- `✅` = Complete (visual indicator)
- `🔨` = In progress
- `⏳` = Up next
- `⏸️` = Blocked/paused

### Work Top to Bottom

Follow the checklist order unless there's a blocker.

If blocked on current item:
1. Mark as blocked in ROADMAP.md
2. Document blocker in STATUS.md
3. Move to next item if possible
4. Or ask user

---

## Testing Philosophy

**For hobby project: Manual testing is fine.**

**After each implementation:**
1. Run the game
2. Test the new feature manually
3. Verify it works as expected
4. Check edge cases (what breaks it?)
5. Document any issues in STATUS.md

**Before milestone completion:**
1. Run through complete game loop
2. Verify all features work together
3. Test save/load
4. Play for 10-15 minutes
5. Note: "Tested, works" or "Tested, found issues: [list]"

**Automated tests: Not required for hobby MVP.**

---

## Handling Uncertainty

### "I Don't Know the Right Approach"

**Options:**
1. **Research** - Look at Godot docs, examples, best practices
2. **Try simplest** - Implement simplest working solution
3. **Mark for review** - Add `TODO: Review approach` comment
4. **Ask user** - If it's a significant decision

**Prefer: Try simplest approach, mark for review, continue**

### "I'm Not Sure About Game Balance"

**Always ask user.**

Game balance is game design. Don't guess.

Examples:
- "How much should Hull Level 1 cost?"
- "How much HP should Hull Level 1 have?"
- "How much power should this consume?"

### "This Could Be Done Multiple Ways"

**Evaluate:**
1. Which is simpler?
2. Which is more maintainable?
3. Which follows established patterns?

**Choose the simplest maintainable approach.**

Document why in commit message.

---

## Learning & Documentation

### Document Discoveries

**When you learn something interesting:**

Update `/JOURNAL.md`:
```markdown
## 2024-11-07: Godot Signals Best Practice

**Discovery:** Signals should be defined at class level, not in _ready()

**Why it matters:** Allows other scripts to connect before _ready() is called

**Code example:**
```gdscript
# Good
class_name ShipSystem
signal upgraded(new_level: int)

# Bad
func _ready():
    signal upgraded(new_level: int)  # Won't work
```

**Resource:** Godot docs on signals
```

### Document Patterns

**When you establish a pattern:**

Add to appropriate `/docs/03-learnings/*.md`:
```markdown
## Pattern: Ship System Implementation

**Use this pattern for all ship systems:**

1. Extend base ShipSystem class
2. Implement get_power_cost() override
3. Register with GameState in _ready()
4. Emit EventBus signals on state change
5. Implement save()/load() methods

**Example:** See scripts/systems/hull_system.gd
```

---

## Red Flags (When to Stop and Ask)

🚩 **"This is getting complicated"**
- Stop, simplify, or ask for guidance

🚩 **"I'm not sure if this is fun"**
- This is a game design question, ask user

🚩 **"This breaks saves"**
- Breaking change, need approval

🚩 **"This will take way longer than expected"**
- Scope issue, discuss with user

🚩 **"I'm making lots of assumptions"**
- Too many unknowns, ask for clarity

🚩 **"This goes against the design docs"**
- Clarify: is the design wrong or implementation wrong?

---

## Success Metrics

**Good session:**
- ✅ Made progress on roadmap
- ✅ CODE THAT WORKS (even if rough)
- ✅ Updated STATUS.md
- ✅ Clear next steps
- ✅ Committed with good messages

**Great session:**
- ✅ Completed a milestone item
- ✅ Tested thoroughly
- ✅ Documented learnings
- ✅ No blockers remaining

**Perfect is the enemy of good:**
- Working rough code > perfect non-working code
- Ship milestone 1 > perfect Milestone 3 plans
- Learning > perfection

---

## Quick Reference

**Files to Read Daily:**
- `/STATUS.md` - Current state
- `/ROADMAP.md` - Current checklist
- Relevant `/docs/*/CLAUDE.md` - Context

**Files to Update Daily:**
- `/STATUS.md` - Progress and blockers
- `/ROADMAP.md` - Check off items
- `/JOURNAL.md` - If learned something

**Files to Update As Needed:**
- `/DECISIONS.md` - New decisions
- `/docs/03-learnings/*.md` - Patterns and discoveries

**When in Doubt:**
- Simpler is better
- Working code > perfect code
- Document assumptions
- Keep making progress

---

## Remember

**You are the developer.** Make decisions, write code, test, commit.

**User is the director.** Sets goals, makes game design decisions, provides feedback.

**This is a learning project.** Process > perfection. Progress > completion.

**Have fun.** If something sounds interesting, suggest it. If you discover something cool, document it.

---

**Ready to build? Check `/STATUS.md` for your current task.**
