# CLAUDE.md - Learning Documentation

**Context for AI agents working in `/docs/03-learnings/`**

---

## Purpose of This Directory

This directory captures **curated technical lessons** organized by category. Unlike the session-based JOURNAL.md, these are reference materials documenting patterns, anti-patterns, and insights.

**Think of it as:**
- **Your team wiki** - Patterns future developers can reference
- **Your personal reference** - Solutions to problems you've already solved
- **Portfolio material** - Proof of learning and growth

---

## Files in This Directory

### docker-lessons.md
**Topics:** Docker Compose, networking, health checks, port management, orchestration patterns

**Add lessons here when:**
- Solving Docker service communication issues
- Discovering Compose orchestration patterns
- Fixing port conflicts or health check problems
- Learning volume or environment variable patterns

### godot-lessons.md
**Topics:** Autoload patterns, signals, scene management, GDScript quirks, save/load, HTTP patterns

**Add lessons here when:**
- Discovering Godot-specific patterns or anti-patterns
- Solving signal/event-driven architecture challenges
- Learning scene management or autoload best practices
- Finding GDScript gotchas or performance patterns

### ai-integration-lessons.md
**Topics:** Prompt engineering, multi-provider patterns, caching, error handling, context management

**Add lessons here when:**
- Discovering effective prompt patterns
- Solving AI provider integration challenges
- Learning caching or validation strategies
- Finding differences between providers (Ollama/OpenAI/Claude)

### architecture-lessons.md
**Topics:** Design patterns, SOLID principles, microservices, API design, testing strategies

**Add lessons here when:**
- Making architectural decisions
- Discovering design patterns in practice
- Refactoring for better structure
- Learning when patterns apply (or don't)

---

## When to Add Lessons

**Add a lesson when you:**
1. ✅ Solve a non-trivial problem
2. ✅ Discover a pattern worth repeating
3. ✅ Learn something you wish you knew earlier
4. ✅ Encounter a gotcha or anti-pattern
5. ✅ Make a decision that others should know about

**Don't add:**
- ❌ Simple fixes or obvious solutions
- ❌ One-off problems unlikely to recur
- ❌ Lessons better suited for JOURNAL.md (session reflections)

---

## Lesson Entry Format

```markdown
## [Date]: [Lesson Title]

**Context:** [What were you building/doing?]

**Problem:** [What challenge did you face?]

**Solution:** [How did you solve it?]

**Code Example:**
```language
# Show the pattern with actual code
```

**Why This Matters:** [Why should future-you care about this?]

**Resources:**
- [Link to docs]
- [Stack Overflow answer]
- [Relevant article]

**Related Patterns:** [Cross-reference other lessons if applicable]
```

---

## Example Lesson

```markdown
## 2024-11-07: Use Pydantic for All API Request/Response Models

**Context:** Building FastAPI endpoints for AI service. Initially used plain dictionaries for request/response data.

**Problem:**
- Hard to validate incoming data
- No type checking
- Unclear what fields are required
- Godot side had to guess response structure

**Solution:** Created Pydantic models for all API contracts.

**Code Example:**
```python
from pydantic import BaseModel, Field

class MissionRequest(BaseModel):
    difficulty: int = Field(ge=1, le=5, description="Mission difficulty 1-5")
    mission_type: str = Field(..., description="salvage|exploration|trade")
    player_level: int = Field(ge=1, description="Player level")

class MissionResponse(BaseModel):
    mission_id: str
    title: str
    description: str
    stages: list[MissionStage]

@router.post("/generate", response_model=MissionResponse)
async def generate_mission(request: MissionRequest):
    # FastAPI validates automatically
    # Return type is validated against MissionResponse
    pass
```

**Why This Matters:**
- Automatic validation (FastAPI checks types/constraints)
- Self-documenting API (OpenAPI docs generated automatically)
- Type safety (IDE autocomplete, fewer bugs)
- Clear contracts between Godot and Python

**Resources:**
- Pydantic Docs: https://docs.pydantic.dev/
- FastAPI Docs: https://fastapi.tiangolo.com/tutorial/response-model/

**Related Patterns:** API design patterns, type safety strategies
```

---

## AI Agent Workflow

### During Development

**When you solve something interesting:**
1. Note it mentally: "This is worth documenting"
2. Continue with current task (don't break flow)
3. At end of session, add lesson entry
4. Keep entries concise (future-you wants quick reference, not essays)

### At End of Session

**Before updating STATUS.md:**
1. Review what you learned this session
2. Ask: "Did I discover any patterns worth documenting?"
3. If yes: Add 1-3 lesson entries to appropriate file
4. Cross-reference in JOURNAL.md if applicable

**Don't overthink it:**
- Rough notes are fine (can refine later)
- Better to capture something than nothing
- Future-you will be grateful

---

## For User

**How to use these lessons:**
- 📖 **Before starting work:** Review relevant category to refresh memory
- 🔍 **When stuck:** Search for similar problems you've solved
- 📝 **Portfolio/blog:** Turn lessons into articles or talking points
- 🎯 **Interviews:** "Here's a specific challenge I solved and what I learned"

**These lessons prove you're learning, not just coding.**

---

## Decision Authority

**AI Agent can autonomously:**
- ✅ Add new lesson entries
- ✅ Update existing lessons with new insights
- ✅ Cross-reference between lessons
- ✅ Organize lessons within files

**AI Agent should ask first:**
- ⚠️ Creating new category files (beyond the 4 existing)
- ⚠️ Removing existing lessons (even if outdated)
- ⚠️ Major reorganization of structure

---

**Remember:** The goal is to capture learning, not to write perfect documentation. Rough notes that exist > perfect notes that don't.
