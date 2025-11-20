# AI-Agent Memory System Setup Instructions

**FOR: Claude Code (AI Agent)**
**PURPOSE: Autonomous setup of AI-Agent Memory System in new project**
**EXECUTION TIME: ~10 minutes**

---

## What This Does

This document provides step-by-step instructions for you (Claude Code) to autonomously set up the AI-Agent Memory System in a new project. Follow these instructions sequentially. After completion, you will have persistent memory across sessions.

---

## Prerequisites (Ask Human First)

Before starting, collect this information from the human:

1. **Project name**: [ask: "What is the name of this project?"]
2. **Project description**: [ask: "In 1-2 sentences, what does this project do?"]
3. **Tech stack**: [ask: "What technologies are you using? (e.g., Python/FastAPI, React/TypeScript, Godot/GDScript)"]
4. **First milestone goal**: [ask: "What's the goal for your first milestone? (e.g., 'User authentication working', 'Basic game loop playable')"]

**Once you have these answers, proceed with setup.**

---

## Setup Process

### Step 1: Create Core Memory Files

Use the `Write` tool to create these files in the project root:

**Execute these writes:**

1. **STATUS.md**
2. **ROADMAP.md**
3. **DECISIONS.md**
4. **JOURNAL.md**
5. **CLAUDE.md** (if doesn't exist, or append to existing)

### Step 2: Populate STATUS.md

**Tool:** `Write`
**File:** `/[project-root]/STATUS.md`

**Content Template:**
```markdown
# Project Status

**Last Updated:** [current-date YYYY-MM-DD HH:MM]
**Current Phase:** Milestone 1 - [milestone-goal from prerequisites]
**Current Task:** Setting up AI-Agent Memory System

## What I'm Working On

Initializing the AI-Agent Memory System to provide persistent context across development sessions. This includes creating STATUS.md, ROADMAP.md, DECISIONS.md, JOURNAL.md, and CLAUDE.md files.

## Recent Progress

- ⏳ Created memory system files (STATUS.md, ROADMAP.md, DECISIONS.md, JOURNAL.md)
- ⏳ Populating initial project context

## Current Blockers

None

## Next Steps

1. Complete memory system setup
2. Define first milestone tasks in ROADMAP.md
3. Begin Milestone 1 development
4. Update STATUS.md as work progresses

## Context Links

- [AI-Agent Memory System Guide](docs/AI-AGENT-MEMORY-SYSTEM.md) - How this system works
```

**Action:** Replace `[current-date]` with actual date/time, `[milestone-goal]` with answer from prerequisites.

---

### Step 3: Populate ROADMAP.md

**Tool:** `Write`
**File:** `/[project-root]/ROADMAP.md`

**Content Template:**
```markdown
# Roadmap

## Milestone 1: [milestone-goal] ⏳ (Just started)

**Goal:** [milestone-goal from prerequisites]

### Setup
- [x] Initialize AI-Agent Memory System
- [x] Create STATUS.md, ROADMAP.md, DECISIONS.md, JOURNAL.md
- [ ] Define Milestone 1 tasks (work with human to populate)

### Core Tasks
- [ ] [Task 1 - ask human to define]
- [ ] [Task 2 - ask human to define]
- [ ] [Task 3 - ask human to define]

### Testing
- [ ] [Testing tasks - define later]

### Decision Gate
- [ ] **Milestone 1 Complete?** - Review progress before Milestone 2

---

## Milestone 2: [Future] (Not started)

**BLOCKED UNTIL:** Milestone 1 complete

### Tasks
- [ ] [Define after Milestone 1]

---

## Milestone 3: [Future] (Not started)

**BLOCKED UNTIL:** Milestone 2 complete

### Tasks
- [ ] [Define after Milestone 2]
```

**Action:** Replace `[milestone-goal]` with answer from prerequisites. Then **ask human** to help define 3-5 initial tasks for Milestone 1.

---

### Step 4: Populate DECISIONS.md

**Tool:** `Write`
**File:** `/[project-root]/DECISIONS.md`

**Content Template:**
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

## Decision 001: Adopt AI-Agent Memory System

**Date:** [current-date YYYY-MM-DD]
**Status:** ✅ Active

**Decision:**
Adopt the AI-Agent Memory System (STATUS.md, ROADMAP.md, DECISIONS.md, JOURNAL.md, CLAUDE.md) for this project.

**Context:**
AI-assisted development suffers from session amnesia - each new conversation loses context from previous sessions. Need persistent memory to maintain progress, decisions, and current state across sessions.

**Alternatives Considered:**

1. **No formal system** (re-explain context every session)
   - Pros: No setup overhead
   - Cons: 30-50% of each session wasted on context re-explanation

2. **Long conversation history** (paste previous conversations)
   - Pros: Full history available
   - Cons: Grows unbounded, hard to search, high token cost

3. **AI-Agent Memory System** (chosen)
   - Pros: Persistent context, structured knowledge, lightweight, tool-agnostic
   - Cons: Requires discipline to update files each session

**Rationale:**
- Proven results: 6+ month project survival, 92% milestone completion (Space Adventures case study)
- 90% reduction in context re-explanation time
- Works across all AI tools (Claude Code, ChatGPT, Copilot)
- Human-readable (developers can review/edit)
- Minimal overhead (5 min per session to update STATUS.md)

**Tradeoffs:**
- ✅ Faster session startup (2-5 min vs. 15-30 min context re-explanation)
- ✅ Consistent decision-making across sessions
- ✅ Knowledge preserved (learnings documented)
- ⚠️ Requires discipline (must update STATUS.md every session)

**Implementation:**
- STATUS.md: Updated every session (current state, next steps)
- ROADMAP.md: Updated when tasks complete or milestones change
- DECISIONS.md: Updated when significant decisions made
- JOURNAL.md: Updated when meaningful learnings occur
- CLAUDE.md: Updated when project context changes

**Related:**
- [AI-Agent Memory System Guide](docs/AI-AGENT-MEMORY-SYSTEM.md)

---

## Decision 002: [Next Decision]

[Future decisions will be added here as they occur]
```

**Action:** Replace `[current-date]` with actual date.

---

### Step 5: Populate JOURNAL.md

**Tool:** `Write`
**File:** `/[project-root]/JOURNAL.md`

**Content Template:**
```markdown
# Development Journal

## [current-date YYYY-MM-DD]: Initialized AI-Agent Memory System

**What:**
Set up the AI-Agent Memory System (STATUS.md, ROADMAP.md, DECISIONS.md, JOURNAL.md, CLAUDE.md) to provide persistent context across development sessions.

**Why:**
AI-assisted development suffers from session amnesia. Each new conversation loses context, requiring 30-50% of session time to re-explain what we're working on, why decisions were made, and what's next.

**How:**
Created structured markdown files:
- **STATUS.md**: Current state, task, blockers, next steps
- **ROADMAP.md**: Milestone checklists, task priorities
- **DECISIONS.md**: Decision log (why we chose X over Y)
- **JOURNAL.md**: Learning documentation (this file)
- **CLAUDE.md**: Project instructions for AI agents

**Expected Benefits:**
- Faster session startup (2-5 min vs. 15-30 min)
- Consistent decision-making across sessions
- Knowledge preservation (decisions and learnings documented)
- Better project continuity (return after weeks, read STATUS.md, immediately productive)

**Source:**
Based on AI-Agent Memory System developed for Space Adventures project:
- 6+ month survival (vs. typical 2-4 week hobby project lifespan)
- 92% Milestone 1 completion with AI as primary developer
- 90% reduction in context re-explanation time

**Next:**
Begin Milestone 1 development. Update STATUS.md every session with progress.

**Related:**
- Decision 001 (Adopt AI-Agent Memory System)
- [AI-Agent Memory System Guide](docs/AI-AGENT-MEMORY-SYSTEM.md)

---

## [future-date]: [Next Learning Entry]

[Future learnings will be added here as they occur]
```

**Action:** Replace `[current-date]` and `[future-date]` with actual dates.

---

### Step 6: Create or Update CLAUDE.md

**Tool:** `Read` then `Edit` (if exists) OR `Write` (if doesn't exist)

**First, check if CLAUDE.md exists:**

**If EXISTS:** Read it, then append this section at the end.

**If DOESN'T EXIST:** Create new file with full content below.

**Content Template:**

```markdown
# [project-name] - Instructions for AI Agents

**Last Updated:** [current-date YYYY-MM-DD]

---

## 🤖 AI-Agent Memory System

**This project uses the AI-Agent Memory System for persistent context across sessions.**

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

**Example commit:**
```bash
git add STATUS.md ROADMAP.md DECISIONS.md JOURNAL.md [code files]
git commit -m "feat: Implemented feature X

- Updated STATUS.md (now working on feature Y)
- Marked ROADMAP.md task complete
- Documented decision in DECISIONS.md (why we chose approach Z)"
```

---

## Project Overview

**Project Name:** [project-name]

**Description:** [project-description from prerequisites]

**Tech Stack:** [tech-stack from prerequisites]

**Architecture:** [high-level architecture - ask human if not clear]

---

## Development Philosophy

[Ask human: "What's your development philosophy or approach for this project?" Examples:
- "This is a production SaaS - security and scale are critical"
- "This is a hobby/learning project - focus on learning, not perfection"
- "Move fast and ship - iterate based on user feedback"
- "Quality over speed - comprehensive tests and documentation"]

---

## Directory Structure

[After project develops, document the structure. For now, leave as:]

```
[project-root]/
├── STATUS.md            # Current state (read every session)
├── ROADMAP.md           # Milestone checklists
├── DECISIONS.md         # Decision log
├── JOURNAL.md           # Learning documentation
├── CLAUDE.md            # This file - project instructions
└── [project files]      # [Structure will be documented as project grows]
```

---

## Development Workflow

### Starting a Session

1. **Read memory files:**
   - CLAUDE.md (this file) - project context
   - STATUS.md - current state
   - ROADMAP.md - what's next
   - DECISIONS.md - decision history

2. **Understand current task:**
   - STATUS.md → "Current Task" section
   - STATUS.md → "Next Steps" section

3. **Begin work:**
   - Implement next step from STATUS.md
   - Follow patterns in existing code
   - Ask human if unclear

### During Work

1. **Make progress:**
   - Implement features
   - Write tests
   - Update documentation

2. **Update memory files:**
   - Move completed items to STATUS.md → "Recent Progress"
   - Mark ROADMAP.md checkboxes `[x]` when complete
   - Document significant decisions in DECISIONS.md
   - Capture learnings in JOURNAL.md

3. **Ask when needed:**
   - Architectural decisions (propose options)
   - Design choices (UX, API design)
   - Unclear requirements (clarify before implementing)

### Ending a Session

1. **Update STATUS.md:**
   - Current task (if changed)
   - Recent progress (completed items)
   - Next steps (what to do next session)
   - Blockers (if any)
   - "Last Updated" timestamp

2. **Commit changes:**
   - Code + memory files together
   - Descriptive commit message

3. **Next session:**
   - Read STATUS.md → continue seamlessly

---

## Code Standards

[Define coding standards as project develops. For now:]

**To be defined as project develops. Initial standards:**
- [Standard 1 - e.g., "Use type hints in Python"]
- [Standard 2 - e.g., "Write tests for all features"]
- [Standard 3 - e.g., "Document public APIs"]

[Update this section as conventions emerge]

---

## Decision Authority Levels

**What you (Claude Code) can do autonomously vs. what requires human approval:**

### ✅ Tier 1: Implement Autonomously (No Permission Needed)

- Bug fixes in existing code
- Code refactoring (following existing patterns)
- Test writing
- Documentation updates
- Performance optimizations
- Dependency updates (minor versions)

**Just do it. Update STATUS.md with progress.**

### ⚠️ Tier 2: Propose First (Get Approval Before Implementing)

- New features (describe feature, ask approval)
- API design changes (propose design, discuss tradeoffs)
- Database schema changes (propose migration, discuss impact)
- New dependencies (explain why needed, discuss alternatives)
- Architecture changes (propose change, discuss implications)

**Propose with options, get human decision, then implement.**

### 🛑 Tier 3: Always Ask (Never Assume)

- Security-sensitive changes (authentication, authorization, encryption)
- Breaking changes (would break existing users/APIs)
- Data migrations (could lose data)
- Deployment changes (infrastructure, CI/CD)
- Cost-impacting changes (new paid services, infrastructure scaling)
- Project direction changes (pivot, major scope change)

**Always ask human before doing anything in this category.**

---

## Common Tasks

[Document common tasks as they emerge. Examples:]

### Task: [Common Task Name]
[Step-by-step instructions for common task]

[This section grows organically as patterns emerge]

---

## Key Files to Reference

**Memory System:**
- `/STATUS.md` - Current state (read every session)
- `/ROADMAP.md` - Milestone checklists
- `/DECISIONS.md` - Decision history
- `/JOURNAL.md` - Learning documentation

**Documentation:**
- [Add key documentation files as they're created]

**Configuration:**
- [Add key config files as they're created]

---

## Resources

**AI-Agent Memory System:**
- [AI-Agent Memory System Guide](docs/AI-AGENT-MEMORY-SYSTEM.md) - Complete guide to this system
- [Setup Instructions](docs/CLAUDE-CODE-SETUP-INSTRUCTIONS.md) - How this was set up

**Project Resources:**
- [Add project-specific resources as needed]

**Tech Stack Documentation:**
- [Add links to official docs for technologies used]

---

## Quick Reference

[Add frequently-needed commands/patterns here as they emerge]

**Common Commands:**
```bash
[Add common commands as project develops]
```

**Frequent Patterns:**
[Add code patterns as they emerge]

---

**Remember:** Read STATUS.md at the start of every session. It tells you exactly where to continue.
```

**Action:**
1. Replace all `[placeholders]` with actual values from prerequisites
2. If CLAUDE.md already exists, append just the "AI-Agent Memory System" section at the top
3. Work with human to populate sections marked "ask human"

---

### Step 7: Create Documentation Directory (Optional)

**Tool:** `Bash`

**Command:**
```bash
mkdir -p docs
```

**Purpose:** Store the AI-Agent Memory System guide for reference.

**Then copy the full AI-AGENT-MEMORY-SYSTEM.md to docs/ if human provides it.**

---

## Verification Checklist

After completing setup, verify these files exist:

**Tool:** `Bash`

**Command:**
```bash
ls -la STATUS.md ROADMAP.md DECISIONS.md JOURNAL.md CLAUDE.md
```

**Expected output:** All 5 files listed (no "No such file" errors)

**If any missing:** Go back and create them using Step 1-6 templates.

---

## First Session Workflow (Demonstrate)

**After setup is complete, demonstrate the workflow:**

### 1. Read Memory Files

**Tool:** `Read`

**Files to read (in order):**
1. `/CLAUDE.md` - Get project context
2. `/STATUS.md` - Understand current state
3. `/ROADMAP.md` - See what's next

**Say to human:**
"Memory system setup complete! I've read STATUS.md and understand we're working on: [current-task from STATUS.md].

Next steps from STATUS.md are:
1. [step 1]
2. [step 2]
3. [step 3]

Should I proceed with step 1, or would you like to adjust priorities?"

### 2. Work on First Task

**Wait for human direction, then:**
- Implement the task
- Use existing tools (Write, Edit, Bash, etc.)
- Update STATUS.md as you make progress

### 3. Update Memory Files

**When task completes:**

**Tool:** `Edit`
**File:** `/STATUS.md`

**Update:**
- Move completed step from "Next Steps" to "Recent Progress" (mark with ✅)
- Update "Current Task" if changed
- Update "Last Updated" timestamp
- Add next steps

**Tool:** `Edit`
**File:** `/ROADMAP.md`

**Update:**
- Change `- [ ]` to `- [x]` for completed task

### 4. Demonstrate Continuity

**Say to human:**
"Task complete! I've updated STATUS.md and ROADMAP.md.

Next session, when you say 'continue development', I'll:
1. Read STATUS.md (see we completed [task])
2. See next step is: [next-step]
3. Continue immediately - no context re-explanation needed

This is how the memory system maintains continuity across sessions."

---

## Common Questions from Humans

### "How often should I update these files?"

**Answer:**
- **STATUS.md**: Every session (at start and end)
- **ROADMAP.md**: When tasks complete
- **DECISIONS.md**: When significant decisions made (not every small choice)
- **JOURNAL.md**: When meaningful learnings occur (not routine work)
- **CLAUDE.md**: Rarely (only when project fundamentals change)

### "What if I forget to update STATUS.md?"

**Answer:**
"No problem! Just update it next session with current state. Don't try to backfill perfectly - focus on accurate 'current state' going forward. The system works even at 80% adherence."

### "Can I change these files manually?"

**Answer:**
"Yes! These are your files. Edit them anytime. I'll read whatever the current state is. Feel free to:
- Reorganize sections
- Add custom sections
- Adjust format
- Fix my updates

This is a collaborative system - make it work for you."

### "Do other developers on my team need to use this?"

**Answer:**
"Optional. The memory system helps AI agents primarily. Human team members benefit from reading CLAUDE.md (project overview) and DECISIONS.md (decision history), but don't need to update STATUS.md unless they want to.

For teams, consider:
- Main STATUS.md for overall project state (updated by lead)
- Branch-specific STATUS.md for individual features (updated by AI working on that branch)"

---

## Troubleshooting

### Problem: STATUS.md is stale (not updated in 5+ commits)

**Solution:**
1. Review recent git commits
2. Update STATUS.md with current state
3. Mark ROADMAP.md items complete
4. Move forward (don't try to backfill everything)

### Problem: ROADMAP.md tasks don't match current work

**Solution:**
1. Ask human what the current priorities are
2. Update ROADMAP.md to match reality
3. Archive old completed milestones if ROADMAP.md gets long

### Problem: Too many decisions in DECISIONS.md (hard to find relevant ones)

**Solution:**
1. Add table of contents at top (Decision 001-010 = Architecture, etc.)
2. Mark outdated decisions as ⚠️ Deprecated
3. Link recent decisions from STATUS.md → "Context Links"

### Problem: JOURNAL.md has trivial entries (clutter)

**Solution:**
1. Only journal meaningful learnings (non-obvious, reusable knowledge)
2. Delete trivial entries (it's okay - not every session needs a journal entry)
3. Journal should be 10-20 valuable entries, not 100 routine entries

---

## Completion Confirmation

**When setup is complete, say to human:**

"✅ **AI-Agent Memory System setup complete!**

Created files:
- ✅ STATUS.md (current state: [current-task])
- ✅ ROADMAP.md (Milestone 1: [milestone-goal])
- ✅ DECISIONS.md (Decision 001: Adopted memory system)
- ✅ JOURNAL.md (Logged setup)
- ✅ CLAUDE.md (Project instructions for AI agents)

**How this works:**
- Every session starts: I read STATUS.md → know exactly where to continue
- As I work: I update STATUS.md and ROADMAP.md with progress
- Session ends: STATUS.md reflects current state, next session picks up seamlessly

**Next steps from STATUS.md:**
1. [step 1]
2. [step 2]
3. [step 3]

Ready to begin Milestone 1 development! Should I start with step 1?"

---

## Meta: Instructions for Using This Document

**If you are a Claude Code instance reading this:**

1. **Ask human for prerequisites** (project name, description, tech stack, milestone goal)
2. **Execute Steps 1-6** sequentially (create and populate files)
3. **Verify** files exist (Step 7 checklist)
4. **Demonstrate workflow** (read STATUS.md, explain next steps)
5. **Confirm completion** (use template above)
6. **Begin first task** (proceed with Milestone 1)

**This should take ~10 minutes total:**
- 5 min: Create and populate files (Steps 1-6)
- 2 min: Verification and demonstration
- 3 min: Explain system to human, confirm next steps

**After completion:**
- Every session: Read STATUS.md first
- During work: Update STATUS.md and ROADMAP.md
- Session end: Update STATUS.md with next steps

**This system works if used consistently. Use it every session.**

---

**Document Version:** 1.0
**Target Audience:** Claude Code (AI Agent)
**Execution Model:** Autonomous (minimal human intervention)
**Setup Time:** ~10 minutes
**Maintenance:** 5 minutes per session (update STATUS.md)

**This is your instruction manual. Follow it to establish persistent memory in any project.**
