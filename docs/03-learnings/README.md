# Learning Documentation

> **Purpose:** Capture the learning journey, not just task completion. This directory documents insights, patterns, and "aha!" moments that make hobby projects valuable.

**This directory is different from JOURNAL.md:**
- **JOURNAL.md** = Session-by-session learning diary (personal reflections)
- **This directory** = Curated technical lessons by category (reference material)

---

## 📚 Learning Categories

### Docker & Microservices
**File:** [docker-lessons.md](docker-lessons.md)

**Topics Covered:**
- Docker Compose orchestration patterns
- Service networking and dependencies
- Health check strategies
- Port management and conflicts
- Volume management for persistence
- Environment variable management

**When to Update:** After discovering Docker patterns, solving orchestration issues, or learning container best practices.

---

### Godot Game Development
**File:** [godot-lessons.md](godot-lessons.md)

**Topics Covered:**
- Autoload singleton patterns
- Signal-based architecture
- Scene management best practices
- GDScript patterns and anti-patterns
- Save/load system implementation
- HTTPRequest async patterns
- UI/UX patterns in Godot

**When to Update:** After discovering Godot-specific patterns, solving engine quirks, or learning GDScript best practices.

---

### AI Integration & Prompt Engineering
**File:** [ai-integration-lessons.md](ai-integration-lessons.md)

**Topics Covered:**
- Prompt engineering for consistent output
- Multi-provider abstraction patterns
- Caching strategies for AI responses
- Error handling for AI services
- Context management for narrative consistency
- Ollama vs OpenAI vs Claude trade-offs
- Pydantic validation patterns

**When to Update:** After discovering prompt patterns, solving AI integration challenges, or learning provider-specific quirks.

---

### Architecture & Design Patterns
**File:** [architecture-lessons.md](architecture-lessons.md)

**Topics Covered:**
- When microservices make sense (and when they don't)
- SOLID principles in practice
- Event-driven architecture patterns
- Separation of concerns strategies
- API design patterns
- Error handling architectures
- Testing strategies

**When to Update:** After making architectural decisions, refactoring code, or discovering design patterns.

---

## How to Use This Directory

### For AI Agents (You!)

**When to Add Lessons:**
1. After solving a non-trivial problem
2. After discovering a pattern or anti-pattern
3. After making an architectural decision
4. After learning something you wish you knew earlier
5. After encountering a gotcha or pitfall

**Format for Lesson Entries:**

```markdown
## [Date]: [Lesson Title]

**Context:** [What were you trying to do?]

**Problem:** [What challenge did you face?]

**Solution:** [How did you solve it?]

**Code Example:**
```language
# Show the pattern in action
```

**Why This Matters:** [Why is this lesson important?]

**Resources:** [Links to docs, Stack Overflow, etc.]

**Related Patterns:** [Cross-reference other lessons]
```

**Example Entry:**

```markdown
## 2024-11-07: Godot Signals Must Be Defined at Class Level

**Context:** Tried to define signals in `_ready()` function to keep them close to initialization logic.

**Problem:** Other scripts couldn't connect to signals before `_ready()` was called, causing timing issues and null reference errors.

**Solution:** Always define signals at the class level, before any functions.

**Code Example:**
```gdscript
# ✅ Good - signals defined at class level
class_name ShipSystem
signal health_changed(new_health: int, old_health: int)
signal upgraded(new_level: int)

func _ready():
    # Initialization here

# ❌ Bad - signals in _ready()
func _ready():
    signal health_changed(new_health: int)  # Won't work!
```

**Why This Matters:** Godot's signal system requires signals to exist before connections can be made. Early connections (like in autoload scripts) will fail if signals don't exist yet.

**Resources:**
- Godot Docs: Signals (https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)

**Related Patterns:** EventBus pattern, Autoload initialization order
```

### For User (Developer)

**This directory is your reference material:**
- ✅ Look here when you encounter similar problems in the future
- ✅ Review before starting new features to apply learned patterns
- ✅ Share these lessons in blog posts or portfolio
- ✅ Use as talking points in interviews ("Here's what I learned building X...")

**Don't expect perfection:**
- Lessons can be rough notes initially
- You can refine them later
- More entries = more learning documented
- Even "obvious" lessons are worth documenting (you'll forget!)

---

## Current Status

**Lessons Documented:** 0 (directory just created)

**Next Session:** Start documenting lessons from Phase 1, Weeks 1-4 retrospectively
- Docker Compose setup challenges
- Godot singleton patterns discovered
- AI service integration insights
- Port management lessons (NCC-1701 system)

---

## Cross-References

**Related Documentation:**
- `/JOURNAL.md` - Session-by-session learning diary
- `/DECISIONS.md` - Architectural decision log
- `/docs/01-user-guides/TESTING-GUIDE.md` - Testing patterns and approaches

**How They Connect:**
- **JOURNAL.md** = "Today I learned X while doing Y"
- **This directory** = "Here's the pattern I discovered, use it like this"
- **DECISIONS.md** = "We chose approach X over Y because Z"

---

**AI Agent:** Update these lesson files whenever you discover something worth remembering. Focus on patterns that will help future development sessions or other developers working on similar projects.
