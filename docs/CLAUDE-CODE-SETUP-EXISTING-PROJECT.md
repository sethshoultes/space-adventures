# AI-Agent Memory System Setup - EXISTING PROJECT

**FOR: Claude Code (AI Agent)**
**PURPOSE: Add AI-Agent Memory System to existing project**
**EXECUTION TIME: ~15 minutes**

---

## What This Does

This document provides instructions for adding the AI-Agent Memory System to an **EXISTING project** (as opposed to a new/greenfield project). This handles:
- Checking for existing documentation files
- Merging with existing CLAUDE.md (if present)
- Capturing current project state (not "starting from scratch")
- Minimal disruption to existing workflow

---

## Prerequisites (Ask Human First)

Before starting, collect this information:

1. **Current state**: [ask: "What are you currently working on in this project?"]
2. **Current blockers**: [ask: "Are there any blockers or issues preventing progress?"]
3. **Next milestone**: [ask: "What's the next major milestone or goal for this project?"]
4. **Existing docs**: [I'll detect automatically, but ask: "Do you have existing documentation I should preserve?"]

**Once you have these answers, proceed with detection and setup.**

---

## Phase 1: Detection (Check What Exists)

### Step 1.1: Check for Existing Memory System Files

**Tool:** `Bash`

**Command:**
```bash
ls -la STATUS.md ROADMAP.md DECISIONS.md JOURNAL.md CLAUDE.md 2>/dev/null || echo "Some files missing (expected for existing project)"
```

**Record which files exist:**
- [ ] STATUS.md exists
- [ ] ROADMAP.md exists
- [ ] DECISIONS.md exists
- [ ] JOURNAL.md exists
- [ ] CLAUDE.md exists

### Step 1.2: Check for Other Documentation

**Tool:** `Bash`

**Command:**
```bash
ls -la README.md CONTRIBUTING.md docs/ .github/ 2>/dev/null || echo "No additional docs found"
```

**Record what exists:**
- [ ] README.md
- [ ] CONTRIBUTING.md
- [ ] docs/ directory
- [ ] .github/ directory (GitHub templates)

### Step 1.3: Check Git History

**Tool:** `Bash`

**Command:**
```bash
git log --oneline -10 2>/dev/null || echo "Not a git repo or no commits"
```

**Purpose:** Understand recent work to populate STATUS.md accurately.

---

## Phase 2: Strategic Decisions

Based on detection, decide strategy for each file:

### Decision Tree:

**For each file:**

1. **File doesn't exist** → Create new (use templates from new-project instructions)

2. **File exists, is memory system file** → Ask human:
   - "I see [file] already exists. Should I:
     a) Append to it (preserve existing content)
     b) Replace it (start fresh with new format)
     c) Leave it alone (use as-is)"

3. **CLAUDE.md exists, not memory system** → Merge strategy:
   - Read existing CLAUDE.md
   - Prepend memory system instructions
   - Preserve existing content

4. **Other docs exist (README, etc.)** → Preserve, don't touch:
   - Leave README.md unchanged
   - Leave CONTRIBUTING.md unchanged
   - Add references to memory system in CLAUDE.md

---

## Phase 3: Create Missing Files

### Step 3.1: Create STATUS.md (Existing Project Version)

**If STATUS.md doesn't exist:**

**Tool:** `Write`
**File:** `/[project-root]/STATUS.md`

**Content Template (EXISTING PROJECT):**
```markdown
# Project Status

**Last Updated:** [current-date YYYY-MM-DD HH:MM]
**Current Phase:** [ask human: "What phase/milestone is the project in?"]
**Current Task:** [answer from prerequisites: "current state"]

## What I'm Working On

[1-2 paragraph description based on human's answer about current work]

## Recent Progress

[Ask human: "What have you completed recently?" OR check recent git commits]

- [Recent item 1 from git log or human input]
- [Recent item 2]
- [Recent item 3]

## Current Blockers

[Answer from prerequisites: "current blockers" OR "None"]

## Next Steps

[Based on human's answer about next milestone, list 3-5 concrete next steps]

1. [Next step 1]
2. [Next step 2]
3. [Next step 3]

## Context Links

- [Existing docs, e.g., README.md, architecture docs]
- [AI-Agent Memory System Guide](docs/AI-AGENT-MEMORY-SYSTEM.md)
```

**Action:**
1. Replace `[placeholders]` with actual values from prerequisites
2. Check git log for recent progress: `git log --oneline -10`
3. Ask human to validate current state description
4. Confirm before writing

---

### Step 3.2: Create ROADMAP.md (Existing Project Version)

**If ROADMAP.md doesn't exist:**

**Tool:** `Write`
**File:** `/[project-root]/ROADMAP.md`

**Content Template (EXISTING PROJECT):**
```markdown
# Roadmap

## Completed Milestones

[Ask human: "What major milestones have you completed so far?"]

### [Milestone Name] ✅ Complete
**Completed:** [date if known, or "Prior to memory system setup"]
**Goal:** [What this achieved]

[List 3-5 completed items if human remembers, or:]
- [x] [Item 1]
- [x] [Item 2]
- [x] [Item 3]

[Note: "Additional completed work not itemized - project was in progress before memory system"]

---

## Current Milestone: [Next Milestone Name] ⏳ ([estimate]% complete)

**Goal:** [answer from prerequisites: "next milestone"]

### In Progress
[Based on STATUS.md "Current Task"]
- ⏳ [Current task from STATUS.md] ([estimate]% complete)

### Pending
[Based on human input or inferred from codebase]
- [ ] [Pending task 1]
- [ ] [Pending task 2]
- [ ] [Pending task 3]

### Testing
- [ ] [Testing tasks for current milestone]

### Decision Gate
- [ ] **[Milestone Complete?]** - Review before next milestone

---

## Future Milestones

[Ask human: "What milestones come after the current one?"]

### [Milestone Name] (Not started)
**BLOCKED UNTIL:** [Current Milestone] complete

- [ ] [Task 1]
- [ ] [Task 2]

---

**Note:** This roadmap was created mid-project. Earlier work is summarized in "Completed Milestones" but not fully itemized.
```

**Action:**
1. Work with human to identify completed milestones
2. Don't try to backfill entire project history (too much work)
3. Focus on current + future milestones
4. Add note explaining this is mid-project roadmap

---

### Step 3.3: Create DECISIONS.md (Existing Project Version)

**If DECISIONS.md doesn't exist:**

**Tool:** `Write`
**File:** `/[project-root]/DECISIONS.md`

**Content Template (EXISTING PROJECT):**
```markdown
# Decision Log

## Format

Each decision includes:
- **Date:** When decided
- **Decision:** What was chosen
- **Context:** Why this decision was needed
- **Alternatives:** What else was considered
- **Rationale:** Why this option was chosen
- **Tradeoffs:** What we gave up
- **Status:** ✅ Active / ⚠️ Deprecated / ❌ Superseded

---

**Note:** This decision log was created mid-project. Earlier decisions are documented retroactively based on current codebase state. Future decisions will be documented as they occur.

---

## Decision 001: Adopt AI-Agent Memory System

**Date:** [current-date YYYY-MM-DD]
**Status:** ✅ Active

**Decision:**
Adopt the AI-Agent Memory System (STATUS.md, ROADMAP.md, DECISIONS.md, JOURNAL.md, CLAUDE.md) for this existing project.

**Context:**
Project is already in development, but lacks persistent context for AI-assisted development. Each session requires re-explaining project state, decisions, and next steps.

**Alternatives Considered:**

1. **Continue without formal system**
   - Pros: No setup overhead
   - Cons: Continue wasting time on context re-explanation each session

2. **Backfill complete project history**
   - Pros: Complete documentation
   - Cons: Weeks of effort, diminishing returns

3. **Add memory system starting now** (chosen)
   - Pros: Immediate benefits, minimal effort, focus on future
   - Cons: Lose some historical context (mitigated by git log)

**Rationale:**
- Don't need perfect historical documentation
- Need effective context management going forward
- Can document key past decisions retroactively (Decision 002+)
- Git log preserves historical context
- Proven results from other projects

**Tradeoffs:**
- ❌ Incomplete historical record (pre-memory system)
- ✅ Immediate productivity improvement (future sessions)
- ✅ Minimal setup effort (vs. weeks of backfilling)

**Implementation:**
- Created STATUS.md with current state
- Created ROADMAP.md with current + future milestones
- Will document key past decisions as Decision 002+
- Going forward: update memory files every session

**Related:**
- [AI-Agent Memory System Guide](docs/AI-AGENT-MEMORY-SYSTEM.md)

---

## Decision 002: [Key Past Decision 1]

**Date:** [Unknown - Retroactive Documentation]
**Status:** ✅ Active

[Ask human: "What were the 3-5 most important architectural or technology decisions made in this project?"]

[Document these as Decision 002, 003, 004, etc.]

[Template for retroactive decisions:]

**Decision:** [What was chosen - inferred from codebase or ask human]

**Context:** [Why this was needed - inferred or ask human]

**Rationale:** [Why this was chosen - inferred from code patterns or ask human]

**Note:** This decision predates the memory system and is documented retroactively based on current codebase.

---

## Decision 003: [Key Past Decision 2]

[Same format as Decision 002]

---

[Continue for 3-5 key past decisions]

---

## Future Decisions

[Future decisions will be documented here as they occur, following the standard format]
```

**Action:**
1. Create Decision 001 (adopting memory system)
2. Ask human for 3-5 key past decisions
3. Document those as Decision 002-006 (retroactive)
4. Don't try to document every decision ever made
5. Focus on architectural, technology, and design decisions that matter going forward

---

### Step 3.4: Create JOURNAL.md (Existing Project Version)

**If JOURNAL.md doesn't exist:**

**Tool:** `Write`
**File:** `/[project-root]/JOURNAL.md`

**Content Template (EXISTING PROJECT):**
```markdown
# Development Journal

**Note:** This journal was created mid-project. Earlier learnings are not documented here but may be discoverable in git commit messages and code comments.

---

## [current-date YYYY-MM-DD]: Added AI-Agent Memory System to Existing Project

**What:**
Integrated the AI-Agent Memory System (STATUS.md, ROADMAP.md, DECISIONS.md, JOURNAL.md, CLAUDE.md) into this existing project.

**Why:**
Project lacked persistent context for AI-assisted development. Each session required 15-30 minutes re-explaining what we're working on, why decisions were made, and what's next.

**How:**
- Created STATUS.md with current project state
- Created ROADMAP.md with current + future milestones
- Created DECISIONS.md with retroactive key decisions
- Created JOURNAL.md (this file) for future learnings
- Created/updated CLAUDE.md with project instructions

**Challenges (Existing Project):**
- Don't have complete historical record (mitigated: git log + human knowledge)
- Some past decisions forgotten (documented what we remember)
- Current state required investigation (checked git log, asked human)

**Solutions:**
- Focus on current state + future (not perfect historical record)
- Document key past decisions retroactively (3-5 most important)
- Git log provides historical context when needed

**Expected Benefits:**
- Faster session startup (2-5 min vs. 15-30 min)
- Consistent decision-making going forward
- Knowledge preservation (future learnings documented)
- Better project continuity

**Next:**
Begin using memory system. Update STATUS.md every session with progress.

**Related:**
- Decision 001 (Adopt AI-Agent Memory System)
- [AI-Agent Memory System Guide](docs/AI-AGENT-MEMORY-SYSTEM.md)

---

## [future-date]: [Future Learning Entry]

[Future learnings will be documented here as they occur]
```

**Action:**
1. Document the setup process itself as first journal entry
2. Note that this is mid-project (explain gap in historical learnings)
3. Going forward, capture learnings as they occur

---

### Step 3.5: Create or Update CLAUDE.md (Existing Project Version)

**Tool:** First `Read` (check if exists), then `Edit` or `Write`

**Check if CLAUDE.md exists:**

#### Case A: CLAUDE.md Doesn't Exist

**Action:** Create new CLAUDE.md with full content (use template from new-project instructions, but note it's an existing project):

**Add this note at top:**
```markdown
# [Project Name] - Instructions for AI Agents

**Last Updated:** [current-date]

**Note:** This documentation was created mid-project. Some historical context may be incomplete. See git log and existing docs for additional context.
```

Then proceed with standard CLAUDE.md structure.

#### Case B: CLAUDE.md Exists (But Not Memory System Format)

**Tool:** `Read` then `Edit`

**Action:**
1. Read existing CLAUDE.md
2. Prepend this section at the very top:

```markdown
# [Project Name] - Instructions for AI Agents

**Last Updated:** [current-date]

---

## 🤖 AI-Agent Memory System

**This project NOW uses the AI-Agent Memory System for persistent context across sessions.**

### Every Session: Read These Files (In Order)

**CRITICAL:** At the start of EVERY session, read these files sequentially:

1. **This file (CLAUDE.md)** - Project context, tech stack, conventions
2. **/STATUS.md** - Current state, current task, blockers, next steps
3. **/ROADMAP.md** - Milestone checklists, task priorities
4. **/DECISIONS.md** - Decision history (why we chose X over Y)

**This provides full context in 2-5 minutes** (vs. 15-30 minutes re-explaining).

### During Work: Update These Files

**As you work:**
- ✅ **Update STATUS.md** with progress (move items from "Next Steps" to "Recent Progress")
- ✅ **Mark ROADMAP.md items complete** (change `- [ ]` to `- [x]`)
- ✅ **Document significant decisions** in DECISIONS.md (architectural choices, tech selections)
- ✅ **Capture learnings** in JOURNAL.md (non-obvious discoveries, edge cases, patterns)

### At Session End: Commit Memory State

**Before ending session:**
1. ✅ **Update STATUS.md** with current state and next steps
2. ✅ **Update "Last Updated" timestamp** in STATUS.md
3. ✅ **Commit memory files** with code changes
4. ✅ Next session will read STATUS.md and continue seamlessly

---

[Existing CLAUDE.md content preserved below]
```

3. Preserve all existing content below the memory system section
4. Update "Last Updated" timestamp

#### Case C: CLAUDE.md Exists (Already Has Memory System)

**Action:** Ask human:
> "I see CLAUDE.md already has memory system instructions. Should I:
> a) Update to latest format
> b) Leave as-is
> c) Merge improvements"

Then proceed based on answer.

---

## Phase 4: Retroactive Documentation

### Step 4.1: Capture Current State from Git

**Tool:** `Bash`

**Command:**
```bash
git log --oneline --since="1 week ago"
```

**Purpose:** Populate STATUS.md "Recent Progress" with actual recent work.

**Action:**
- Read last 10-20 commit messages
- Summarize in STATUS.md "Recent Progress" section
- Gives accurate picture of recent activity

### Step 4.2: Identify Key Past Decisions

**Tool:** `Grep` or ask human

**Search for technology choices in codebase:**
```bash
# Check package.json, requirements.txt, Cargo.toml, etc.
cat package.json requirements.txt Cargo.toml setup.py 2>/dev/null | head -20
```

**Infer decisions from dependencies:**
- React in package.json → Decision: "Use React for frontend"
- FastAPI in requirements.txt → Decision: "Use FastAPI for backend"
- PostgreSQL in code → Decision: "Use PostgreSQL as database"

**Ask human:**
> "I see you're using [React, FastAPI, PostgreSQL] based on the codebase. Were there any important decisions about:
> 1. Architecture (monolith vs microservices, etc.)
> 2. Technology choices (why React over Vue, etc.)
> 3. Design patterns (REST vs GraphQL, etc.)
>
> I'll document these in DECISIONS.md so we don't re-debate them."

**Action:**
- Document 3-5 key decisions in DECISIONS.md
- Mark as retroactive: "Date: Unknown - Retroactive Documentation"
- Focus on decisions that matter going forward

### Step 4.3: Determine Current Milestone

**Tool:** Ask human OR infer from ROADMAP/TODO comments

**Search for TODOs in code:**
```bash
git grep -n "TODO\|FIXME\|HACK" | head -20
```

**Ask human:**
> "Based on recent commits and TODOs in code, it looks like you're working on [inferred goal]. Is this accurate? What would you call the current milestone?"

**Action:**
- Define current milestone in ROADMAP.md
- Populate with pending tasks based on TODOs + human input
- Estimate completion % based on TODOs done vs. remaining

---

## Phase 5: Verification & Handoff

### Step 5.1: Verify All Files Created

**Tool:** `Bash`

**Command:**
```bash
ls -la STATUS.md ROADMAP.md DECISIONS.md JOURNAL.md CLAUDE.md
```

**Expected:** All 5 files exist (or human confirmed to skip certain files)

### Step 5.2: Read and Validate STATUS.md

**Tool:** `Read`

**File:** `/STATUS.md`

**Validation:**
- [ ] "Last Updated" is today
- [ ] "Current Task" matches what human said
- [ ] "Next Steps" has 3-5 concrete actions
- [ ] "Recent Progress" reflects recent git commits

**If not accurate:** Ask human to review and correct before proceeding.

### Step 5.3: Demonstrate Workflow

**Say to human:**

> "✅ **AI-Agent Memory System setup complete for existing project!**
>
> Created/updated files:
> - STATUS.md (current state: [current-task])
> - ROADMAP.md (current milestone: [milestone])
> - DECISIONS.md ([N] decisions documented, including [N-1] retroactive)
> - JOURNAL.md (setup documented)
> - CLAUDE.md (memory system instructions added)
>
> **How this works going forward:**
> - Every session: I read STATUS.md → know exactly where to continue
> - As I work: I update STATUS.md and ROADMAP.md with progress
> - Session ends: STATUS.md reflects current state
>
> **What's different (existing project):**
> - Historical decisions partially documented (3-5 key decisions captured)
> - Current milestone inferred from recent work
> - Roadmap focused on current + future (not complete backfill)
> - Git log provides additional historical context when needed
>
> **Next steps from STATUS.md:**
> 1. [step 1]
> 2. [step 2]
> 3. [step 3]
>
> Ready to continue with step 1?"

---

## Special Cases: Existing Project Scenarios

### Scenario 1: Project Has README but No Other Docs

**Strategy:**
- Leave README.md unchanged (it's for users, not AI)
- Create all memory system files
- In CLAUDE.md, reference README.md: "See README.md for user-facing documentation"

### Scenario 2: Project Has CONTRIBUTING.md

**Strategy:**
- Leave CONTRIBUTING.md unchanged
- Add note in CLAUDE.md: "For contribution guidelines, see CONTRIBUTING.md"
- Memory system complements CONTRIBUTING (not replaces)

### Scenario 3: Project Has docs/ Directory with Architecture Docs

**Strategy:**
- Leave docs/ unchanged
- In CLAUDE.md, link to key docs: "See docs/architecture.md for system architecture"
- In DECISIONS.md, reference: "See docs/ for detailed architecture (DECISIONS.md focuses on why)"
- Memory system provides AI context layer on top of existing docs

### Scenario 4: Project Has Existing CLAUDE.md with Different Format

**Strategy:**
- Read existing CLAUDE.md completely
- Identify sections to preserve
- Prepend memory system instructions
- Merge overlapping content (e.g., if both have "Tech Stack", consolidate)
- Ask human to review merged version

### Scenario 5: Monorepo or Multi-Service Project

**Strategy:**
- Create root-level STATUS.md (overall project state)
- Consider per-service CLAUDE.md (service-specific context)
- Single ROADMAP.md (cross-service milestones)
- Single DECISIONS.md (architectural decisions)
- Ask human: "Should I create per-service STATUS.md files, or just root-level?"

### Scenario 6: Very Old Project (Years of History)

**Strategy:**
- Don't try to backfill years of decisions (impossible, low value)
- Focus on recent history (last 3-6 months from git log)
- Document current architecture (not how we got here)
- In DECISIONS.md: "Note: This project has extensive history. Only recent/active decisions documented."
- Historical context discoverable via git log when needed

---

## Troubleshooting: Existing Project Issues

### Problem: Can't determine current state (unclear what we're working on)

**Solution:**
1. Check last 20 git commits: `git log --oneline -20`
2. Check for TODO/FIXME comments: `git grep "TODO\|FIXME"`
3. Ask human directly: "What were you working on last session?"
4. If still unclear: STATUS.md "Current Task" = "Resuming development - need to triage priorities"

### Problem: Too many past decisions to document

**Solution:**
- Focus on architectural decisions (not implementation details)
- Document top 5 most important decisions
- Note in DECISIONS.md: "Additional historical decisions not documented. See git log or ask human if needed."
- Can add more decisions retroactively over time (as they become relevant)

### Problem: Existing CLAUDE.md conflicts with memory system format

**Solution:**
1. Read existing CLAUDE.md completely
2. Identify unique content to preserve
3. Create merged version (memory system + existing content)
4. Ask human to review: "I merged your existing CLAUDE.md with memory system instructions. Please review [file] to ensure I didn't lose important context."

### Problem: Project has no git history (or sparse commits)

**Solution:**
- Ask human for recent progress: "What have you worked on recently?"
- STATUS.md "Recent Progress" based on human input, not git log
- Note in STATUS.md: "Note: Progress based on current conversation, not git log"
- Going forward: Encourage better commit messages

### Problem: Current milestone unclear (project goals vague)

**Solution:**
- Ask human: "What's the next major deliverable or goal?"
- If human unsure: "Let's define a short-term milestone. What would 'good progress' look like in 2-4 weeks?"
- ROADMAP.md can have placeholder milestone: "Current Focus: [Improvements and Bug Fixes]"
- Refine milestone definition as work clarifies

---

## Completion Checklist

**Before considering setup complete:**

- [ ] STATUS.md created with accurate current state
- [ ] ROADMAP.md created with current + future milestones
- [ ] DECISIONS.md created with 3-5 retroactive key decisions
- [ ] JOURNAL.md created with setup notes
- [ ] CLAUDE.md created or updated with memory system instructions
- [ ] Human reviewed and validated STATUS.md accuracy
- [ ] Demonstrated workflow to human
- [ ] Committed memory files to git (if project uses git)

**Git commit message:**
```bash
git add STATUS.md ROADMAP.md DECISIONS.md JOURNAL.md CLAUDE.md
git commit -m "docs: Add AI-Agent Memory System to existing project

- Created STATUS.md (current state tracking)
- Created ROADMAP.md (milestone planning)
- Created DECISIONS.md (decision log with retroactive decisions)
- Created JOURNAL.md (learning documentation)
- Updated CLAUDE.md (AI agent instructions)

This enables persistent context for AI-assisted development.
Reduces session startup time from 15-30 min to 2-5 min.

See docs/AI-AGENT-MEMORY-SYSTEM.md for system details."
```

---

## Meta: Instructions for Using This Document

**If you are a Claude Code instance reading this:**

1. **Execute Phase 1: Detection** (check what files exist)
2. **Execute Phase 2: Decide strategy** (create, merge, or preserve each file)
3. **Execute Phase 3: Create missing files** (using existing-project templates)
4. **Execute Phase 4: Retroactive documentation** (capture current state, key decisions)
5. **Execute Phase 5: Verify and handoff** (validate with human, demonstrate)

**This should take ~15 minutes total:**
- 3 min: Detection (check existing files, git log)
- 5 min: Create missing files (adapted for existing project)
- 5 min: Retroactive documentation (capture current state, key decisions)
- 2 min: Verification and demonstration

**Key Differences from New Project Setup:**
- ✅ Check for existing files first (don't blindly overwrite)
- ✅ Merge with existing CLAUDE.md (preserve human's work)
- ✅ Capture current state from git log (not "starting from scratch")
- ✅ Document 3-5 key past decisions retroactively (not complete history)
- ✅ Focus on current + future (don't try to backfill years of history)

**After completion:**
- Every session: Read STATUS.md first (same as new project)
- During work: Update STATUS.md and ROADMAP.md (same as new project)
- Session end: Update STATUS.md with next steps (same as new project)

**This system works for existing projects if adapted correctly. Use this guide to integrate smoothly.**

---

**Document Version:** 1.0
**Target Audience:** Claude Code (AI Agent)
**Project Type:** Existing/mid-development projects
**Setup Time:** ~15 minutes
**Maintenance:** 5 minutes per session (update STATUS.md)

**This is the existing-project variant. Use CLAUDE-CODE-SETUP-INSTRUCTIONS.md for new projects.**
