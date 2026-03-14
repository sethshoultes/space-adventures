# AI-Agent Memory System

**A Multi-Document Approach to Persistent Context in AI-Assisted Development**

**Version:** 1.0
**Last Updated:** 2025-01-20
**License:** CC BY-SA 4.0 (feel free to use and adapt)

---

## Executive Summary

This document describes a **persistent memory system for AI-assisted development** that solves the "session amnesia" problem where AI agents lose context between conversations.

**Results from production use:**
- 6+ month hobby project survival (vs. typical 2-4 weeks)
- 92% milestone completion with AI as primary developer
- Zero session-to-session context loss
- Consistent decision-making across AI sessions
- Reduced context window usage (targeted docs vs. full codebase)
- Successfully adopted in additional projects (e.g., a commercial WordPress plugin: MemberPress Referral Program) to provide persistent context across AI-assisted sessions

**Core Innovation:**
A structured set of markdown files (`STATUS.md`, `ROADMAP.md`, `DECISIONS.md`, `JOURNAL.md`, `CLAUDE.md`, directory-level `CLAUDE.md`) that provide persistent memory for AI agents across sessions.

---

## Table of Contents

1. [The Problem: Session Amnesia](#the-problem-session-amnesia)
2. [The Solution: Multi-Document Memory System](#the-solution-multi-document-memory-system)
3. [System Architecture](#system-architecture)
4. [Core Documents Explained](#core-documents-explained)
5. [Implementation Guide](#implementation-guide)
6. [Template Files](#template-files)
7. [Best Practices](#best-practices)
8. [Real-World Results](#real-world-results)
9. [Adoption Guide](#adoption-guide)
10. [Advanced Patterns](#advanced-patterns)
11. [FAQ](#faq)

---

## The Problem: Session Amnesia

### What Is Session Amnesia?

AI-assisted development suffers from **context loss between sessions**:

**Typical AI-assisted workflow:**
```
Session 1:
Human: "Let's build a user authentication system"
AI: "Great! Let me understand your requirements..."
[30 minutes of discussion]
[Implementation begins]

Session 2 (next day):
Human: "Continue working on auth"
AI: "Sure! Can you remind me what we decided about..."
[15 minutes re-explaining context]
[Implementation continues]

Session 3 (next week):
Human: "Add OAuth support"
AI: "Let me understand your auth system first..."
[20 minutes catching up]
[Repeat]
```

**Problems:**
- ⏰ **Time waste:** 30-50% of each session spent re-explaining context
- 🔄 **Re-litigation:** Decisions get re-debated ("Why did we choose X over Y?")
- 🧠 **Mental load:** Human must remember and re-explain everything
- 📉 **Inconsistency:** Different AI sessions make different architectural decisions
- 🚫 **Context limits:** Pasting entire codebase every session hits token limits

### Why This Happens

**AI agents are stateless:**
- Each new conversation starts fresh
- No memory of previous sessions
- Context must be re-provided every time

**Existing "solutions" don't work well:**

❌ **Long context windows** (Claude 200K tokens)
- Expensive (high token cost per message)
- Slow (processing 200K tokens takes time)
- Wasteful (most context isn't relevant)
- Not persistent (still resets next session)

❌ **Conversation history** (replay old messages)
- Grows unbounded (dozens of pages)
- Hard to search (where was that decision?)
- Cluttered (implementation details obscure key decisions)
- Doesn't transfer (can't share context across projects)

❌ **Manual reminders** (developer explains every time)
- Time-consuming
- Error-prone (forget details)
- Doesn't scale
- Defeats purpose of AI assistance

### The Gap

**What's needed:**
- ✅ Persistent context (survives session restarts)
- ✅ Selective memory (relevant info, not everything)
- ✅ Structured knowledge (easy to query)
- ✅ Human-readable (developer can review/edit)
- ✅ Transferable (works across AI tools)
- ✅ Lightweight (low token usage)

**This is what the AI-Agent Memory System provides.**

---

## The Solution: Multi-Document Memory System

### Core Concept

**Create a structured memory layer using markdown files:**

```
project/
  STATUS.md           # Current task, progress, blockers
  ROADMAP.md          # Milestone checklists (what's next)
  DECISIONS.md        # Record of major decisions (why we chose X)
  JOURNAL.md          # Learning documentation (what we discovered)
  CLAUDE.md           # Project instructions (context for AI)
  docs/
    CLAUDE.md         # Master documentation context
  [directory]/
    CLAUDE.md         # Directory-specific context
```

### How It Works

**At session start:**
```
Human: "Continue development"

AI (reads files):
1. STATUS.md → "Current task: Implementing OAuth login"
2. ROADMAP.md → "Next: Add Google OAuth provider"
3. DECISIONS.md → "We chose JWT tokens over sessions because..."
4. auth/CLAUDE.md → "Auth system uses FastAPI + SQLAlchemy"

AI: "I'll continue implementing Google OAuth. I see we're using
     JWT tokens and FastAPI. Picking up where we left off..."
```

**During session:**
```
[AI implements feature]
[AI documents decision in DECISIONS.md]
[AI updates STATUS.md with progress]
[AI captures learning in JOURNAL.md]
```

**At session end:**
```
AI: "I've updated STATUS.md. We completed Google OAuth and started
     Facebook OAuth. Next session can continue with Facebook implementation."

STATUS.md:
  Current Task: Implementing Facebook OAuth (60% complete)
  Last Updated: 2025-01-20 14:30
  Next Steps: Add Facebook app credentials, test login flow
```

**Next session (seamless):**
```
Human: "Continue"

AI (reads STATUS.md): "I see we're 60% done with Facebook OAuth.
                       Continuing with app credentials..."
```

**Zero context re-explanation needed.**

### Key Benefits

**For AI Agents:**
- 📍 Instant situational awareness (no catch-up needed)
- 🎯 Clear priorities (ROADMAP.md tells what's next)
- 🧠 Consistent decisions (DECISIONS.md prevents re-litigation)
- 📚 Project knowledge (CLAUDE.md provides context)
- 🔍 Reduced token usage (targeted docs, not full codebase)

**For Human Developers:**
- ⏱️ Save time (no re-explaining every session)
- 🔄 Resume easily (read STATUS.md after weeks away)
- 📖 Understand history (DECISIONS.md explains why)
- 📝 Capture learnings (JOURNAL.md documents discoveries)
- 🤝 Transfer knowledge (new team members read docs)

**For Projects:**
- 📈 Higher completion rates (consistent progress)
- 🎯 Clearer direction (ROADMAP.md prevents drift)
- 🏗️ Better architecture (consistent decisions)
- 📚 Better documentation (generated as byproduct)
- 🔧 Easier maintenance (knowledge preserved)

---

## System Architecture

### Document Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│ Global Context (Read Every Session)                         │
│                                                              │
│  CLAUDE.md           - Project instructions, philosophy     │
│  STATUS.md           - Current state, task, blockers        │
│  ROADMAP.md          - Milestone checklists                 │
│  DECISIONS.md        - Decision log                         │
│  JOURNAL.md          - Learning documentation               │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ Domain Context (Read When Relevant)                         │
│                                                              │
│  docs/CLAUDE.md      - Master documentation                 │
│  backend/CLAUDE.md   - Backend-specific context             │
│  frontend/CLAUDE.md  - Frontend-specific context            │
│  auth/CLAUDE.md      - Auth system context                  │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ Implementation Details (Read As Needed)                     │
│                                                              │
│  docs/api-design.md     - API specifications               │
│  docs/architecture.md   - System architecture              │
│  docs/deployment.md     - Deployment guide                 │
└─────────────────────────────────────────────────────────────┘
```

### Information Flow

**Session Start:**
```
AI Agent starts
    ↓
Read CLAUDE.md (project context)
    ↓
Read STATUS.md (current state)
    ↓
Read ROADMAP.md (what's next)
    ↓
Read DECISIONS.md (why things are the way they are)
    ↓
Read relevant [directory]/CLAUDE.md (domain context)
    ↓
Ready to work (full context loaded)
```

**During Work:**
```
Implement feature
    ↓
Make architectural decision
    ↓
Document in DECISIONS.md
    ↓
Discover learning
    ↓
Document in JOURNAL.md
    ↓
Update STATUS.md with progress
    ↓
Mark ROADMAP.md item complete
```

**Session End:**
```
Update STATUS.md with:
  - Current task state
  - Progress percentage
  - Next steps
  - Blockers (if any)
    ↓
Commit changes (STATUS.md, DECISIONS.md, etc.)
    ↓
Next session picks up seamlessly
```

### Memory Layers

**Layer 1: Project Identity (CLAUDE.md)**
- What is this project?
- What are we building?
- Tech stack, architecture decisions
- Development philosophy
- **Update frequency:** Rarely (foundational)

**Layer 2: Current State (STATUS.md)**
- What are we working on RIGHT NOW?
- What's the current progress?
- What are the blockers?
- **Update frequency:** Every session

**Layer 3: Roadmap (ROADMAP.md)**
- What's next?
- What's the priority order?
- What's completed?
- **Update frequency:** Weekly or per milestone

**Layer 4: Decision History (DECISIONS.md)**
- Why did we choose X over Y?
- What alternatives were considered?
- What are the tradeoffs?
- **Update frequency:** When significant decisions are made

**Layer 5: Learning Log (JOURNAL.md)**
- What did we discover?
- What patterns worked well?
- What should we avoid?
- **Update frequency:** When meaningful learning occurs

**Layer 6: Domain Context ([directory]/CLAUDE.md)**
- How does this part of the codebase work?
- What are the conventions here?
- What should AI know when working in this directory?
- **Update frequency:** When domain patterns change

---

## Core Documents Explained

### 1. STATUS.md - Current State Tracking

**Purpose:** The "you are here" map for AI agents.

**Structure:**
```markdown
# Project Status

**Last Updated:** 2025-01-20 14:30
**Current Phase:** Milestone 2 - User Authentication
**Current Task:** Implementing Google OAuth login

## What I'm Working On

Adding Google OAuth as a login option. The core JWT authentication
is complete (Milestone 1), now expanding to support OAuth providers.

Currently implementing:
- Google OAuth callback endpoint
- Token exchange logic
- User account linking (existing users + new users)

## Recent Progress

- ✅ Set up Google Cloud project and credentials
- ✅ Added OAuth database schema (oauth_accounts table)
- ✅ Implemented /auth/google/login redirect
- ⏳ Working on /auth/google/callback (70% complete)
- ⏳ Need to add user account linking logic

## Current Blockers

None - development proceeding smoothly

## Next Steps

1. Complete callback endpoint implementation
2. Test full Google OAuth flow (login, callback, token)
3. Add account linking for existing users
4. Update ROADMAP.md with completion
5. Begin Facebook OAuth provider

## Context Links

- [OAuth Architecture](docs/oauth-architecture.md)
- [Auth System CLAUDE.md](backend/auth/CLAUDE.md)
- [API Endpoints](docs/api-design.md#auth-endpoints)
```

**When to Update:**
- ✅ **Every session** (update progress, next steps)
- ✅ **When task changes** (new focus area)
- ✅ **When blockers occur** (document impediments)
- ✅ **When blockers resolve** (clear blockers section)

**Key Principle:** Next session should read STATUS.md and immediately know where to continue.

---

### 2. ROADMAP.md - Milestone Checklists

**Purpose:** The task list and priority order.

**Structure:**
```markdown
# Roadmap

## Milestone 1: Core Authentication ✅ (Complete)

**Goal:** Users can register, log in, and manage sessions

### Features
- [x] User registration (email + password)
- [x] Email verification
- [x] Login with JWT tokens
- [x] Password reset flow
- [x] Session management
- [x] User profile endpoints

**Completed:** 2025-01-15
**Outcome:** Core auth working, ready for OAuth expansion

---

## Milestone 2: OAuth Providers ⏳ (60% complete)

**Goal:** Users can log in with Google, Facebook, GitHub

### Prerequisites
- [x] Milestone 1 complete
- [x] OAuth database schema added
- [x] OAuth architecture documented

### Google OAuth ⏳ (70% complete)
- [x] Set up Google Cloud project
- [x] Add OAuth credentials to environment
- [x] Implement /auth/google/login (redirect)
- [x] Add oauth_accounts table migration
- ⏳ Implement /auth/google/callback (in progress)
- [ ] Add account linking (existing users)
- [ ] Test full OAuth flow
- [ ] Add Google OAuth to frontend

### Facebook OAuth (Not started)
- [ ] Set up Facebook Developer account
- [ ] Configure Facebook app
- [ ] Implement /auth/facebook/login
- [ ] Implement /auth/facebook/callback
- [ ] Add account linking
- [ ] Test flow
- [ ] Add to frontend

### GitHub OAuth (Not started)
- [ ] Set up GitHub OAuth app
- [ ] Implement /auth/github/login
- [ ] Implement /auth/github/callback
- [ ] Add account linking
- [ ] Test flow
- [ ] Add to frontend

### Integration Testing
- [ ] Test all OAuth providers
- [ ] Test account linking (OAuth → existing account)
- [ ] Test account creation (OAuth → new account)
- [ ] Test multiple OAuth providers for same user
- [ ] Update documentation

---

## Milestone 3: Two-Factor Authentication (Future)

**BLOCKED UNTIL:** Milestone 2 complete

### Features
- [ ] TOTP setup (Google Authenticator, Authy)
- [ ] SMS 2FA option
- [ ] Backup codes
- [ ] Recovery flow
- [ ] Admin enforcement options
```

**When to Update:**
- ✅ **When task completes** (mark checkbox)
- ✅ **When starting new milestone** (add milestone section)
- ✅ **When priorities change** (reorder items)
- ✅ **When scope changes** (add/remove items)

**Key Principle:** ROADMAP.md is the single source of truth for "what's next."

---

### 3. DECISIONS.md - Decision Log

**Purpose:** Record WHY decisions were made (prevent re-litigation).

**Structure:**
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
- **Status:** Active, Deprecated, Superseded

---

## Decision 001: JWT Tokens for Session Management

**Date:** 2025-01-10
**Status:** ✅ Active

**Decision:**
Use JWT (JSON Web Tokens) for session management instead of server-side sessions.

**Context:**
Need to handle user authentication across API requests. Must choose between:
- Server-side sessions (store session data in database)
- JWT tokens (stateless authentication)

**Alternatives Considered:**

1. **Server-side sessions** (Redis or database)
   - Pros: Easy revocation, smaller cookies, server controls state
   - Cons: Requires Redis/DB lookup on every request, harder to scale horizontally

2. **JWT tokens** (chosen)
   - Pros: Stateless (no DB lookup), scales horizontally, works across services
   - Cons: Harder to revoke (must wait for expiry), larger token size

3. **Hybrid** (JWT + refresh token in database)
   - Pros: Best of both worlds
   - Cons: More complex, still requires some DB lookups

**Rationale:**
- Microservices architecture benefits from stateless auth
- Planning multi-service deployment (Gateway, AI Service, etc.)
- JWT enables authentication without cross-service DB calls
- Can add refresh token revocation later if needed (hybrid approach)

**Tradeoffs:**
- ❌ Can't instantly revoke JWT (must wait for expiry)
- ❌ Larger token size (stored in cookie/header)
- ✅ Zero DB lookups for auth (fast, scalable)
- ✅ Works seamlessly across services

**Implementation Details:**
- Access token expiry: 15 minutes
- Refresh token expiry: 7 days (stored in database for revocation)
- Token includes: user_id, email, roles, issued_at, expires_at

**Related:**
- See `backend/auth/jwt.py` for implementation
- See Decision 002 for refresh token strategy

---

## Decision 002: OAuth Account Linking Strategy

**Date:** 2025-01-20
**Status:** ✅ Active

**Decision:**
Allow users to link multiple OAuth providers to one account (Google + Facebook + GitHub → same user).

**Context:**
User logs in with Google, then later tries to log in with Facebook using same email.
What should happen?

**Alternatives Considered:**

1. **Separate accounts** (one account per OAuth provider)
   - Pros: Simple implementation
   - Cons: Confusing UX (same email = different accounts?), data fragmentation

2. **Auto-merge by email** (chosen)
   - Pros: Intuitive UX (same email = same account), unified user data
   - Cons: Security risk if email not verified, need linking logic

3. **Manual linking only**
   - Pros: User control, no security risk
   - Cons: Friction, most users won't link

**Rationale:**
- Better UX: Users expect same email → same account
- Unified data: User's preferences, history in one place
- Familiar pattern: Gmail, Facebook, GitHub all work this way

**Security Mitigation:**
- ONLY auto-merge if OAuth provider verified the email
- If email unverified, treat as separate account
- Allow manual unlinking in settings

**Tradeoffs:**
- ⚠️ Security risk: If attacker controls unverified email, could link to victim's account
- ✅ Mitigated by: Only merge verified emails
- ✅ Better UX for 99% of users

**Implementation Details:**
- `oauth_accounts` table links OAuth providers to user accounts
- On OAuth callback:
  1. Check if `oauth_provider` + `oauth_user_id` exists → log in existing user
  2. Check if `email` exists + email verified → link to existing account
  3. Otherwise → create new account

**Related:**
- See `backend/auth/oauth.py:link_oauth_account()`
- See Decision 001 for JWT strategy

---

## Decision 003: Milestone-Based Development (Not Timeline-Based)

**Date:** 2025-01-05
**Status:** ✅ Active

**Decision:**
Use milestone-based development (WHAT to build) instead of timeline-based (WHEN to ship).

**Context:**
This is a hobby/learning project. Need sustainable development approach that prevents burnout.

**Alternatives Considered:**

1. **Timeline-based** (e.g., "Ship in 3 months")
   - Pros: Clear deadline, external motivation
   - Cons: Stress, corner-cutting, burnout risk

2. **Milestone-based** (chosen)
   - Pros: Sustainable, focus on quality, no deadline stress
   - Cons: No external pressure (can drift)

3. **No plan** (ad-hoc development)
   - Pros: Maximum flexibility
   - Cons: Lose direction, never finish

**Rationale:**
- Hobby project (no business deadline)
- Learning is the goal (not shipping fast)
- Timeline stress kills hobby project motivation
- Milestones provide structure without stress

**Implementation:**
- ROADMAP.md defines milestones (no dates)
- "Is it fun?" decision gates between milestones
- Permission to pivot or abandon if not fun
- Progress over perfection

**Tradeoffs:**
- ❌ No deadline urgency (slower progress)
- ✅ Sustainable pace (project survived 6+ months vs. typical 2-4 weeks)
- ✅ Higher quality (no rushing)
- ✅ Better learning (time to understand)

**Results:**
- Project started: July 2024
- Still active: January 2025 (6+ months)
- Developer burnout: Zero
- Milestone completion: 92% of M1

**Related:**
- See ROADMAP.md for milestone structure
- See CLAUDE.md for "milestones not timelines" philosophy
```

**When to Add Decisions:**
- ✅ Architectural choices (JWT vs. sessions)
- ✅ Technology selections (PostgreSQL vs. MySQL)
- ✅ Design patterns (REST vs. GraphQL)
- ✅ Process decisions (milestone-based development)
- ✅ Tradeoff analysis (performance vs. simplicity)
- ❌ Trivial choices (variable names, formatting)

**Key Principle:** Future developers (including AI agents) should understand WHY, not just WHAT.

---

### 4. JOURNAL.md - Learning Documentation

**Purpose:** Capture discoveries, patterns, and lessons learned.

**Structure:**
```markdown
# Development Journal

## 2025-01-20: OAuth Account Linking Edge Case

**Discovery:**
When testing OAuth account linking, discovered that if a user:
1. Registers with email+password (email verified)
2. Later logs in with Google OAuth (same email)
3. Google's email is verified

Our system correctly links the accounts. However, if:
1. User registers with email+password (email NOT verified)
2. Logs in with Google OAuth (same email, verified)

System was creating SEPARATE accounts because we only merged if
BOTH emails were verified.

**Solution:**
Changed logic to trust OAuth provider's email verification:
- If OAuth email is verified → can link to existing account
- Don't require existing account's email to be verified
- Rationale: OAuth provider (Google) verified email ownership

**Code:**
```python
# Before (too strict)
if oauth_email_verified and existing_user.email_verified:
    link_accounts(oauth_account, existing_user)

# After (trust OAuth verification)
if oauth_email_verified:
    link_accounts(oauth_account, existing_user)
    existing_user.email_verified = True  # Trust OAuth verification
```

**Learning:**
OAuth providers are authoritative for email verification.
If Google says email is verified, trust it.

**Related:**
- Decision 002 (OAuth account linking)
- `backend/auth/oauth.py:handle_oauth_callback()`

---

## 2025-01-18: FastAPI Background Tasks for Email

**Discovery:**
Initial implementation sent verification emails synchronously:

```python
@router.post("/register")
async def register(user: UserCreate):
    new_user = await create_user(user)
    await send_verification_email(new_user.email)  # ❌ Blocks response
    return {"message": "User created"}
```

This caused 2-3 second response times (waiting for SMTP).

**Solution:**
Use FastAPI's BackgroundTasks:

```python
@router.post("/register")
async def register(user: UserCreate, background_tasks: BackgroundTasks):
    new_user = await create_user(user)
    background_tasks.add_task(send_verification_email, new_user.email)
    return {"message": "User created"}  # Instant response
```

**Results:**
- Response time: 2.8s → 0.3s (9x faster)
- User experience: Much snappier
- Email still sent reliably (background task)

**Learning:**
Any I/O operation (email, external API, image processing) should
be done in background tasks, not synchronously.

**Pattern to Reuse:**
```python
from fastapi import BackgroundTasks

@router.post("/endpoint")
async def endpoint(data: DataModel, background_tasks: BackgroundTasks):
    # Do critical work synchronously
    result = await critical_operation(data)

    # Do non-critical work in background
    background_tasks.add_task(send_email, result.email)
    background_tasks.add_task(log_analytics, result.id)

    return result  # Return immediately
```

**Related:**
- `backend/auth/email.py:send_verification_email()`
- FastAPI docs: https://fastapi.tiangolo.com/tutorial/background-tasks/

---

## 2025-01-15: Pydantic Validation Saved Us

**Discovery:**
While implementing password reset, accidentally passed user input
directly to database:

```python
# ❌ Dangerous
@router.post("/reset-password")
async def reset_password(data: dict):  # No validation!
    await db.execute(f"UPDATE users SET password = '{data['password']}'...")
```

Realized this could allow SQL injection or invalid data.

**Solution:**
Use Pydantic models for ALL request validation:

```python
# ✅ Safe
class PasswordResetRequest(BaseModel):
    token: str = Field(..., min_length=32, max_length=64)
    password: str = Field(..., min_length=8, max_length=128)

    @validator('password')
    def validate_password_strength(cls, v):
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain uppercase letter')
        if not re.search(r'[0-9]', v):
            raise ValueError('Password must contain number')
        return v

@router.post("/reset-password")
async def reset_password(data: PasswordResetRequest):
    # Data is validated, safe to use
    await update_password(data.token, data.password)
```

**Learning:**
NEVER accept raw `dict` or `request.json()` in endpoints.
Always use Pydantic models:
- Type safety
- Validation
- Documentation (auto-generated OpenAPI)
- Protection against injection

**Related:**
- All models in `backend/models/`
- FastAPI docs: https://fastapi.tiangolo.com/tutorial/body/

---

## 2025-01-10: JWT Secret Rotation is Hard

**Discovery:**
Realized we can't easily rotate JWT signing secret because:
1. Change secret → all existing tokens invalid
2. Users get logged out
3. Bad UX

**Problem:**
If secret is compromised, we're stuck:
- Keep compromised secret (security risk)
- Rotate secret (log out all users)

**Solution (Future):**
Implement key rotation with grace period:
1. Support multiple valid secrets (old + new)
2. Sign new tokens with new secret
3. Validate tokens with old OR new secret
4. After grace period (7 days), drop old secret

**Not Implemented Yet:**
Adding to Milestone 3 (security hardening).

**Learning:**
Design for key rotation from the start, or you're locked in.

**Future Work:**
```python
# Current (single secret)
SECRET_KEY = os.getenv("JWT_SECRET")

# Future (multiple secrets)
JWT_SECRETS = [
    {"key": os.getenv("JWT_SECRET_NEW"), "valid_from": "2025-01-20"},
    {"key": os.getenv("JWT_SECRET_OLD"), "valid_until": "2025-01-27"}
]
```

**Related:**
- Decision 001 (JWT strategy)
- ROADMAP.md Milestone 3 (security hardening)
```

**When to Add Journal Entries:**
- ✅ Discovered edge case
- ✅ Found better pattern
- ✅ Learned from mistake
- ✅ Performance optimization
- ✅ Security insight
- ✅ "Aha!" moments
- ❌ Routine implementation (no discovery)

**Key Principle:** Capture knowledge that would be lost otherwise.

---

### 5. CLAUDE.md - Project Instructions

**Purpose:** Provide persistent context about the project for AI agents.

**Structure:**
```markdown
# Project Instructions for AI Agents

## Project Overview

**What:** SaaS authentication service (registration, login, OAuth, 2FA)
**Tech Stack:** FastAPI (Python) + PostgreSQL + React (frontend)
**Architecture:** Microservices (Auth Service, Email Service, Analytics)

## Development Philosophy

**This is a production SaaS, not a prototype:**
- Security is paramount (no shortcuts)
- Scale-ready (design for 100K+ users)
- Well-tested (pytest for backend, Jest for frontend)
- Well-documented (OpenAPI, README per service)

## Tech Stack

**Backend:**
- Python 3.11+
- FastAPI (web framework)
- SQLAlchemy 2.0 (ORM)
- Alembic (migrations)
- PostgreSQL 15+ (database)
- Redis (sessions, cache)
- Celery (background tasks)

**Frontend:**
- React 18+
- TypeScript
- Vite (build tool)
- TanStack Query (data fetching)
- Tailwind CSS (styling)

## Architecture

**Microservices:**
```
┌─────────────┐
│   Gateway   │ :8000 (public)
└──────┬──────┘
       │
   ┌───┴────┬─────────┬──────────┐
   │        │         │          │
┌──▼───┐ ┌─▼────┐ ┌──▼─────┐ ┌─▼────────┐
│ Auth │ │Email │ │Analytics│ │ Database │
│:8001 │ │:8002 │ │:8003    │ │:5432     │
└──────┘ └──────┘ └─────────┘ └──────────┘
```

**Communication:**
- Gateway → Services: HTTP REST
- Services → Database: SQLAlchemy ORM
- Services → Redis: Direct connection
- Background jobs: Celery + Redis

## Directory Structure

```
project/
├── gateway/              # API Gateway (routing, rate limiting)
├── auth-service/         # Authentication service
│   ├── api/             # FastAPI routes
│   ├── models/          # SQLAlchemy models
│   ├── services/        # Business logic
│   ├── tests/           # Pytest tests
│   └── alembic/         # Database migrations
├── email-service/        # Email sending service
├── analytics-service/    # Usage analytics
├── frontend/            # React frontend
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── hooks/
│   │   └── api/
│   └── tests/
├── shared/              # Shared models, utilities
├── docs/                # Documentation
├── STATUS.md            # Current state (read every session)
├── ROADMAP.md           # Milestone checklists
├── DECISIONS.md         # Decision log
└── JOURNAL.md           # Learning log
```

## Development Workflow

**Starting a Session:**
1. Read `STATUS.md` (current task, blockers)
2. Read `ROADMAP.md` (what's next)
3. Read `DECISIONS.md` (why things are the way they are)
4. Read relevant `[directory]/CLAUDE.md` (domain context)
5. Implement → Test → Update STATUS.md → Commit

**Committing:**
- Run tests first: `pytest tests/`
- Descriptive messages: `feat(auth): Add Google OAuth login`
- Update STATUS.md with progress

**Testing:**
- Backend: `pytest tests/` (all tests must pass)
- Frontend: `npm test` (all tests must pass)
- Integration: `pytest tests/integration/`

## Code Standards

**Python:**
- Type hints required: `def login(email: str, password: str) -> User:`
- Docstrings for public functions
- Pydantic models for ALL request/response data
- Use `async/await` for I/O operations
- Black formatting (auto-run)
- Flake8 linting (no warnings)

**TypeScript/React:**
- Strict mode enabled
- Props typing required
- Use hooks (no class components)
- TanStack Query for API calls
- Tailwind for styling (no inline styles)

## Security Requirements

**NEVER:**
- ❌ Store passwords in plaintext (use bcrypt)
- ❌ Log sensitive data (passwords, tokens, emails)
- ❌ Use weak JWT secrets (min 256 bits)
- ❌ Skip input validation
- ❌ Trust user input

**ALWAYS:**
- ✅ Validate all inputs (Pydantic models)
- ✅ Use parameterized queries (SQLAlchemy ORM)
- ✅ Hash passwords (bcrypt, rounds=12)
- ✅ Verify email ownership (send verification code)
- ✅ Rate limit endpoints (prevent brute force)
- ✅ Use HTTPS in production

## Common Tasks

**Add new endpoint:**
1. Define Pydantic request/response models in `models/`
2. Implement route in `api/`
3. Add business logic in `services/`
4. Write tests in `tests/`
5. Update OpenAPI docs (auto-generated)
6. Test manually with curl/Postman

**Add database migration:**
```bash
cd auth-service
alembic revision --autogenerate -m "Add oauth_accounts table"
alembic upgrade head
```

**Run services:**
```bash
# Terminal 1: Auth service
cd auth-service && uvicorn main:app --reload --port 8001

# Terminal 2: Email service
cd email-service && uvicorn main:app --reload --port 8002

# Terminal 3: Gateway
cd gateway && uvicorn main:app --reload --port 8000

# Terminal 4: Frontend
cd frontend && npm run dev
```

## Decision Authority Levels

**✅ Tier 1: Implement Autonomously**
- Bug fixes
- Code refactoring (following existing patterns)
- Test writing
- Documentation updates
- Performance optimizations

**⚠️ Tier 2: Propose First**
- New features
- API design changes
- Database schema changes
- New dependencies
- Architecture changes

**🛑 Tier 3: Always Ask**
- Security-sensitive changes
- Breaking API changes
- Data migrations
- Deployment changes
- Billing/payment code

## Key Files to Reference

- `/STATUS.md` - Current state (read every session)
- `/ROADMAP.md` - What's next
- `/DECISIONS.md` - Why we chose X over Y
- `/docs/architecture.md` - System architecture
- `/docs/api-design.md` - API specifications
- `/auth-service/CLAUDE.md` - Auth service context

## Resources

- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [SQLAlchemy 2.0 Docs](https://docs.sqlalchemy.org/)
- [React Docs](https://react.dev/)
- [Our API Docs](http://localhost:8000/docs)

---

**Remember:** Read STATUS.md every session. It tells you exactly where to start.
```

**When to Update:**
- ✅ Tech stack changes
- ✅ Architecture evolves
- ✅ New conventions established
- ✅ Directory structure changes
- ✅ New resources added
- ❌ Routine code changes (keep high-level)

**Key Principle:** Provide enough context for AI agent to be productive immediately.

---

### 6. Directory-Level CLAUDE.md Files

**Purpose:** Provide domain-specific context when working in specific areas.

**Example: `backend/auth/CLAUDE.md`**

```markdown
# Auth Service Context

## Overview

This service handles:
- User registration (email + password)
- Email verification
- Login (JWT tokens)
- OAuth (Google, Facebook, GitHub)
- Password reset
- Session management

## Architecture

**Layers:**
```
API Layer (api/)
    ↓ Validates requests (Pydantic)
    ↓
Service Layer (services/)
    ↓ Business logic
    ↓
Model Layer (models/)
    ↓ Database operations (SQLAlchemy)
    ↓
PostgreSQL Database
```

## Key Files

**API Routes (`api/`):**
- `auth.py` - Registration, login, logout
- `oauth.py` - OAuth providers (Google, Facebook, GitHub)
- `password.py` - Password reset, change password
- `email.py` - Email verification, resend verification

**Services (`services/`):**
- `auth_service.py` - Core authentication logic
- `jwt_service.py` - JWT token creation, validation
- `oauth_service.py` - OAuth provider integration
- `email_service.py` - Email sending (verification, reset)

**Models (`models/`):**
- `user.py` - User model (id, email, password_hash, etc.)
- `oauth_account.py` - OAuth provider linkages
- `session.py` - User sessions (refresh tokens)

## Database Schema

**users table:**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),  -- NULL if OAuth-only user
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

**oauth_accounts table:**
```sql
CREATE TABLE oauth_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL,  -- 'google', 'facebook', 'github'
    provider_user_id VARCHAR(255) NOT NULL,
    access_token TEXT,
    refresh_token TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(provider, provider_user_id)
);
```

**sessions table:**
```sql
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    refresh_token VARCHAR(512) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## Authentication Flow

**Registration:**
```
POST /auth/register
    ↓
Validate email format, password strength (Pydantic)
    ↓
Check email not already registered
    ↓
Hash password (bcrypt, rounds=12)
    ↓
Create user (email_verified=False)
    ↓
Send verification email (background task)
    ↓
Return success message
```

**Login:**
```
POST /auth/login
    ↓
Validate credentials (email + password)
    ↓
Fetch user from database
    ↓
Verify password (bcrypt.checkpw)
    ↓
Generate JWT access token (15 min expiry)
    ↓
Generate refresh token (7 day expiry, store in DB)
    ↓
Return tokens
```

**OAuth:**
```
GET /auth/google/login
    ↓
Redirect to Google OAuth consent screen
    ↓
User approves
    ↓
Google redirects to /auth/google/callback?code=...
    ↓
Exchange code for access token (Google API)
    ↓
Fetch user info from Google (email, name)
    ↓
Check if oauth_account exists → log in existing user
Check if email exists + verified → link to existing account
Otherwise → create new user
    ↓
Generate JWT tokens
    ↓
Return tokens
```

## Security Patterns

**Password Hashing:**
```python
import bcrypt

# Hash password (registration)
password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt(rounds=12))

# Verify password (login)
is_valid = bcrypt.checkpw(password.encode('utf-8'), user.password_hash.encode('utf-8'))
```

**JWT Tokens:**
```python
from jose import jwt
import os

SECRET_KEY = os.getenv("JWT_SECRET")  # 256-bit secret
ALGORITHM = "HS256"

# Create token
payload = {
    "user_id": str(user.id),
    "email": user.email,
    "exp": datetime.utcnow() + timedelta(minutes=15)
}
token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

# Verify token
try:
    payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    user_id = payload["user_id"]
except jwt.ExpiredSignatureError:
    raise HTTPException(401, "Token expired")
except jwt.JWTError:
    raise HTTPException(401, "Invalid token")
```

**Input Validation:**
```python
from pydantic import BaseModel, EmailStr, Field, validator
import re

class RegisterRequest(BaseModel):
    email: EmailStr  # Validates email format
    password: str = Field(..., min_length=8, max_length=128)

    @validator('password')
    def validate_password_strength(cls, v):
        if not re.search(r'[A-Z]', v):
            raise ValueError('Must contain uppercase letter')
        if not re.search(r'[a-z]', v):
            raise ValueError('Must contain lowercase letter')
        if not re.search(r'[0-9]', v):
            raise ValueError('Must contain number')
        if not re.search(r'[!@#$%^&*]', v):
            raise ValueError('Must contain special character')
        return v
```

## Testing

**Run tests:**
```bash
pytest tests/test_auth.py
pytest tests/test_oauth.py
pytest tests/test_password.py
```

**Test patterns:**
```python
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_register_success():
    response = client.post("/auth/register", json={
        "email": "test@example.com",
        "password": "SecurePass123!"
    })
    assert response.status_code == 201
    assert "User created" in response.json()["message"]

def test_register_weak_password():
    response = client.post("/auth/register", json={
        "email": "test@example.com",
        "password": "weak"  # ❌ Too short, no uppercase, no numbers
    })
    assert response.status_code == 422  # Validation error
```

## Common Tasks

**Add new OAuth provider (e.g., Microsoft):**
1. Add provider config to `.env`:
   ```
   MICROSOFT_CLIENT_ID=...
   MICROSOFT_CLIENT_SECRET=...
   ```
2. Create `/auth/microsoft/login` endpoint (redirect to Microsoft)
3. Create `/auth/microsoft/callback` endpoint (handle callback)
4. Add `provider='microsoft'` support in `oauth_service.py`
5. Test full OAuth flow
6. Update docs

**Add new field to User model:**
1. Add field to `models/user.py`:
   ```python
   phone_number = Column(String(20), nullable=True)
   ```
2. Create migration:
   ```bash
   alembic revision --autogenerate -m "Add phone_number to users"
   alembic upgrade head
   ```
3. Update Pydantic schemas (`UserResponse`, etc.)
4. Update tests

## Key Decisions

- **Decision 001:** Use JWT for sessions (see `/DECISIONS.md`)
- **Decision 002:** Auto-link OAuth accounts by verified email (see `/DECISIONS.md`)

## Resources

- [FastAPI Security Docs](https://fastapi.tiangolo.com/tutorial/security/)
- [OAuth 2.0 RFC](https://datatracker.ietf.org/doc/html/rfc6749)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
```

**When to Create Directory CLAUDE.md:**
- ✅ Complex subsystem (auth, payments, etc.)
- ✅ Domain-specific patterns
- ✅ Different tech stack (e.g., frontend vs. backend)
- ✅ Onboarding documentation needed
- ❌ Trivial directories (single file, no complexity)

---

## Implementation Guide

### Step 1: Initialize Core Files

**Create project root files:**

```bash
# In your project root
touch STATUS.md
touch ROADMAP.md
touch DECISIONS.md
touch JOURNAL.md
touch CLAUDE.md
```

**Initialize each file:**

```bash
# STATUS.md
echo "# Project Status

**Last Updated:** $(date +%Y-%m-%d\ %H:%M)
**Current Phase:** Project initialization
**Current Task:** Setting up AI-Agent Memory System

## What I'm Working On

Setting up the foundational memory system files for AI-assisted development.

## Recent Progress

- ⏳ Created STATUS.md, ROADMAP.md, DECISIONS.md, JOURNAL.md, CLAUDE.md

## Current Blockers

None

## Next Steps

1. Populate ROADMAP.md with initial milestones
2. Write CLAUDE.md project overview
3. Begin Milestone 1 development
" > STATUS.md

# ROADMAP.md
echo "# Roadmap

## Milestone 1: [Your First Milestone Name]

**Goal:** [What you're trying to achieve]

### Tasks
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

---

## Milestone 2: [Future Milestone] (Not started)

**BLOCKED UNTIL:** Milestone 1 complete
" > ROADMAP.md

# DECISIONS.md
echo "# Decision Log

## Format

Each decision includes:
- **Date:** When decided
- **Decision:** What was chosen
- **Context:** Why this decision was needed
- **Alternatives:** What else was considered
- **Rationale:** Why this option was chosen
- **Tradeoffs:** What we gave up
- **Status:** Active, Deprecated, Superseded

---

## Decision 001: Use AI-Agent Memory System

**Date:** $(date +%Y-%m-%d)
**Status:** ✅ Active

**Decision:**
Adopt the AI-Agent Memory System (STATUS.md, ROADMAP.md, DECISIONS.md, etc.) for this project.

**Context:**
AI-assisted development suffers from session amnesia. Need persistent context across sessions.

**Alternatives Considered:**
1. No system (re-explain context every session)
2. Long conversation history (grows unbounded)
3. AI-Agent Memory System (chosen)

**Rationale:**
- Reduces context re-explanation
- Provides persistent memory for AI agents
- Improves session-to-session consistency
- Lightweight (markdown files)

**Tradeoffs:**
- ✅ Better AI productivity
- ✅ Faster session startup
- ⚠️ Requires discipline (must update files)

**Related:**
- See docs/AI-AGENT-MEMORY-SYSTEM.md
" > DECISIONS.md

# JOURNAL.md
echo "# Development Journal

## $(date +%Y-%m-%d): Initialized AI-Agent Memory System

**What:**
Set up STATUS.md, ROADMAP.md, DECISIONS.md, JOURNAL.md, CLAUDE.md.

**Why:**
To provide persistent context for AI-assisted development across sessions.

**Learning:**
This system reduces session startup time by eliminating context re-explanation.

**Next:**
Populate CLAUDE.md with project overview and begin Milestone 1.
" > JOURNAL.md
```

### Step 2: Write Your CLAUDE.md

**Populate with project-specific context:**

```markdown
# [Your Project Name]

## Project Overview

**What:** [1-2 sentence description]
**Tech Stack:** [Key technologies]
**Architecture:** [High-level architecture]

## Development Philosophy

[Your development approach]

## Directory Structure

\`\`\`
project/
├── [your directories]
└── ...
\`\`\`

## Development Workflow

**Starting a Session:**
1. Read STATUS.md
2. Read ROADMAP.md
3. Implement → Test → Update STATUS.md → Commit

## Code Standards

[Your coding standards]

## Decision Authority Levels

**✅ Tier 1: Implement Autonomously**
- [What AI can do without asking]

**⚠️ Tier 2: Propose First**
- [What AI should propose before implementing]

**🛑 Tier 3: Always Ask**
- [What AI must always ask about]

## Key Files to Reference

- /STATUS.md - Current state
- /ROADMAP.md - What's next
- /DECISIONS.md - Why we chose X over Y
```

### Step 3: Configure Your AI Agent

**If using Claude Code:**

Add to your global `~/.claude/CLAUDE.md`:

```markdown
## AI-Agent Memory System

**Every session, start by reading these files in order:**
1. /CLAUDE.md - Project context and instructions
2. /STATUS.md - Current state, task, blockers
3. /ROADMAP.md - What's next
4. /DECISIONS.md - Why things are the way they are

**During work:**
- Update STATUS.md with progress
- Mark ROADMAP.md items complete
- Document significant decisions in DECISIONS.md
- Capture learnings in JOURNAL.md

**At session end:**
- Update STATUS.md with current state and next steps
- Commit changes to memory files
```

**If using custom AI setup:**

Add system prompt:
```
You are an AI development assistant using the AI-Agent Memory System.

At the start of each session:
1. Read /CLAUDE.md (project context)
2. Read /STATUS.md (current state)
3. Read /ROADMAP.md (task list)
4. Read /DECISIONS.md (decision history)

During work:
- Update STATUS.md with progress
- Document decisions in DECISIONS.md
- Capture learnings in JOURNAL.md
- Mark ROADMAP.md items complete

At session end:
- Update STATUS.md with next steps
```

### Step 4: First Development Session

**Test the system:**

1. **AI reads files:**
   - CLAUDE.md → understands project
   - STATUS.md → knows current task
   - ROADMAP.md → knows what's next

2. **AI implements first task:**
   - Works on Milestone 1 first task
   - Updates STATUS.md during work
   - Documents any decisions in DECISIONS.md

3. **AI updates files:**
   - Marks ROADMAP.md checkbox when complete
   - Updates STATUS.md with progress
   - Adds JOURNAL.md entry if meaningful learning

4. **Next session:**
   - AI reads STATUS.md → continues seamlessly
   - No context re-explanation needed

### Step 5: Establish Update Rhythm

**Create habits:**

**Every session:**
- ✅ Read STATUS.md at start
- ✅ Update STATUS.md at end
- ✅ Update "Last Updated" timestamp

**Every milestone:**
- ✅ Mark ROADMAP.md items complete
- ✅ Update STATUS.md with new phase
- ✅ Review DECISIONS.md for outdated decisions

**Every significant decision:**
- ✅ Add entry to DECISIONS.md
- ✅ Link from STATUS.md if relevant

**Every meaningful discovery:**
- ✅ Add entry to JOURNAL.md
- ✅ Include code examples
- ✅ Link related decisions/docs

---

## Template Files

### Template: STATUS.md

```markdown
# Project Status

**Last Updated:** YYYY-MM-DD HH:MM
**Current Phase:** [Milestone name]
**Current Task:** [What you're working on now]

## What I'm Working On

[1-2 paragraph description of current focus]

## Recent Progress

- ✅ Completed item 1
- ✅ Completed item 2
- ⏳ In progress item 3 (70% complete)
- ⏳ Started item 4

## Current Blockers

[None / List of blockers]

## Next Steps

1. [Next immediate step]
2. [Following step]
3. [After that]

## Context Links

- [Relevant doc 1]
- [Relevant doc 2]
```

### Template: ROADMAP.md

```markdown
# Roadmap

## Milestone 1: [Name] ⏳ (40% complete)

**Goal:** [What this milestone achieves]

### Prerequisites
- [x] Prerequisite 1
- [x] Prerequisite 2

### Tasks
- [x] Completed task
- ⏳ In-progress task (60% complete)
- [ ] Pending task 1
- [ ] Pending task 2

### Decision Gate
- [ ] **[Key Decision]** - Go/No-Go for Milestone 2

---

## Milestone 2: [Name] (Not started)

**BLOCKED UNTIL:** Milestone 1 complete

### Tasks
- [ ] Task 1
- [ ] Task 2
```

### Template: DECISIONS.md

```markdown
# Decision Log

## Decision [Number]: [Decision Title]

**Date:** YYYY-MM-DD
**Status:** ✅ Active / ⚠️ Deprecated / ❌ Superseded

**Decision:**
[What was decided in 1-2 sentences]

**Context:**
[Why this decision was needed]

**Alternatives Considered:**

1. **Option 1**
   - Pros: [Benefits]
   - Cons: [Drawbacks]

2. **Option 2** (chosen)
   - Pros: [Benefits]
   - Cons: [Drawbacks]

**Rationale:**
[Why Option 2 was chosen]

**Tradeoffs:**
- ❌ [What we gave up]
- ✅ [What we gained]

**Implementation Details:**
[Technical details, code snippets]

**Related:**
- [Related decisions]
- [Related files]
```

### Template: JOURNAL.md

```markdown
# Development Journal

## YYYY-MM-DD: [Entry Title]

**Discovery:**
[What you discovered]

**Context:**
[Why this matters]

**Solution:**
[How you solved it]

**Code:**
\`\`\`[language]
[Code example]
\`\`\`

**Learning:**
[What to remember for future]

**Related:**
- [Related decisions, docs, files]
```

### Template: CLAUDE.md

```markdown
# [Project Name]

## Project Overview

**What:** [Brief description]
**Tech Stack:** [Technologies used]
**Architecture:** [High-level architecture]

## Development Philosophy

[Your development approach, values, principles]

## Directory Structure

\`\`\`
project/
├── [your structure]
\`\`\`

## Development Workflow

**Starting a Session:**
1. Read STATUS.md
2. Read ROADMAP.md
3. [Your workflow]

**Committing:**
- [Your commit standards]

## Code Standards

[Your coding standards, formatting, conventions]

## Decision Authority Levels

**✅ Tier 1: Implement Autonomously**
- [What AI can do without asking]

**⚠️ Tier 2: Propose First**
- [What AI should propose before implementing]

**🛑 Tier 3: Always Ask**
- [What AI must always ask about]

## Key Files to Reference

- /STATUS.md - Current state
- /ROADMAP.md - What's next
- /DECISIONS.md - Decision history
- /JOURNAL.md - Learnings
- [Your key docs]
```

### Template: Directory-Level CLAUDE.md

```markdown
# [Directory/Domain Name] Context

## Overview

[What this part of the codebase handles]

## Architecture

[How this domain is structured]

## Key Files

[Important files in this directory]

## [Domain-Specific Patterns]

[Patterns, conventions specific to this domain]

## Common Tasks

**[Task 1]:**
[How to do task 1]

**[Task 2]:**
[How to do task 2]

## Key Decisions

- Decision [X]: [Brief summary, link to DECISIONS.md]

## Resources

- [Relevant docs, APIs, references]
```

---

## Best Practices

### DO: Update STATUS.md Every Session

**Why:** Next session depends on accurate current state.

**How:**
- Update "Last Updated" timestamp
- Update "Current Task" if changed
- Move completed items to "Recent Progress"
- Add blockers if encountered
- Update "Next Steps"

**Bad:**
```markdown
# Last updated 2 weeks ago, completely stale
**Current Task:** Implementing auth (but you finished that and moved to OAuth)
```

**Good:**
```markdown
**Last Updated:** 2025-01-20 14:30 (today!)
**Current Task:** Implementing Facebook OAuth (70% complete)
```

### DO: Link Decisions from STATUS.md

**Why:** Helps AI find relevant context quickly.

**How:**
```markdown
## What I'm Working On

Implementing OAuth account linking. Using auto-merge by verified email
strategy (see Decision 002).

## Context Links

- [Decision 002: OAuth Account Linking](../DECISIONS.md#decision-002)
- [OAuth Architecture](docs/oauth-architecture.md)
```

### DO: Write Decisions When They Matter

**Why:** Future you will thank present you.

**When:**
- ✅ Chose one technology over another (PostgreSQL vs. MySQL)
- ✅ Chose one pattern over another (REST vs. GraphQL)
- ✅ Made architecture decision (monolith vs. microservices)
- ✅ Made security decision (JWT vs. sessions)
- ❌ Chose variable name (trivial)
- ❌ Fixed typo (trivial)

### DON'T: Let ROADMAP.md Get Stale

**Bad:**
```markdown
## Milestone 1
- [x] Task 1 (but not marked complete)
- [ ] Task 2 (actually finished last week)
- [ ] Task 3 (abandoned, no longer doing)
```

**Good:**
```markdown
## Milestone 1 ✅ Complete
- [x] Task 1
- [x] Task 2

## Milestone 2 ⏳ (60% complete)
- [x] Task 3
- ⏳ Task 4 (in progress)
- [ ] Task 5
```

### DON'T: Over-Document in JOURNAL.md

**Bad:**
```markdown
## 2025-01-20: Fixed typo in README
Changed "teh" to "the"
```

**Good:**
```markdown
## 2025-01-20: FastAPI Background Tasks for Email

**Discovery:** Sending email synchronously blocked responses (2.8s).
**Solution:** Use FastAPI BackgroundTasks (now 0.3s).
**Learning:** Any I/O operation should be background task.
**Code:** [code example]
```

**Guideline:** Only journal if:
- ✅ Meaningful learning occurred
- ✅ Future developers would benefit
- ✅ Non-obvious solution found
- ✅ Edge case discovered
- ❌ Routine implementation
- ❌ Obvious fix

### DO: Use Consistent Formatting

**Checkboxes:**
- `- [x]` = Completed
- `- ⏳` = In progress (optional: add percentage)
- `- [ ]` = Not started

**Status Indicators:**
- `✅ Complete` = Finished milestone/section
- `⏳ In Progress` = Currently working
- `❌ Blocked` = Can't proceed
- `⚠️ Deprecated` = No longer recommended

**Dates:**
- `YYYY-MM-DD HH:MM` format (2025-01-20 14:30)
- Include in STATUS.md "Last Updated"
- Include in DECISIONS.md entries
- Include in JOURNAL.md entries

### DO: Read Files in Order

**Recommended reading order for AI agents:**

1. **CLAUDE.md** - Project context (WHO are we?)
2. **STATUS.md** - Current state (WHERE are we?)
3. **ROADMAP.md** - Task list (WHAT's next?)
4. **DECISIONS.md** - Decision history (WHY are things this way?)
5. **[directory]/CLAUDE.md** - Domain context (HOW does this part work?)

**This order:**
- Builds context from general → specific
- Answers key questions in logical order
- Minimizes confusion

---

## Real-World Results

### Production Case Study: Space Adventures Game

**Project:** Sci-fi choose-your-own-adventure game (Godot + Python AI)
**Duration:** July 2024 - January 2025 (6+ months)
**AI Tool:** Claude Code as primary developer

**Metrics:**

| Metric | Without System | With System | Improvement |
|--------|----------------|-------------|-------------|
| **Project Survival** | 2-4 weeks typical | 6+ months | 3-12x longer |
| **Milestone Completion** | 30-40% typical | 92% of M1 | 2-3x higher |
| **Session Startup Time** | 15-30 min context | 2-5 min context | 3-6x faster |
| **Context Re-explanation** | Every session | Rarely | ~90% reduction |
| **Decision Consistency** | Low (re-debated) | High (logged) | ✅ Consistent |
| **Developer Burnout** | High | Zero | ✅ Sustainable |

**Key Success Factors:**

✅ **STATUS.md updated every session** (100% compliance)
- Sessions start with immediate context
- No "what was I doing?" confusion

✅ **ROADMAP.md with clear milestones** (3 milestones defined)
- Clear direction (no scope drift)
- Visible progress (92% M1 complete)
- Decision gates ("Is it fun?" gate prevents sunk cost)

✅ **DECISIONS.md captures architecture choices** (18 decisions logged)
- No re-debating settled questions
- Consistent architectural decisions
- Clear rationale for future

✅ **JOURNAL.md captures learnings** (24 entries)
- Patterns discovered and documented
- Edge cases remembered
- Future-proofing knowledge

**Developer Quote:**
> "Coming back after 2 weeks away, I read STATUS.md and was productive in 5 minutes.
> Without this system, I'd spend 30 minutes re-reading code trying to remember what I was doing."

**AI Agent Effectiveness:**
> "92% of Milestone 1 built by AI agents (Claude Code) with minimal human intervention.
> The memory system enabled consistent decision-making across dozens of sessions."

### Comparative Analysis: With vs. Without

**Scenario: Returning to project after 2-week break**

**Without AI-Agent Memory System:**
```
1. Open project (no idea where I left off)
2. Read last commit messages (vague)
3. Search code for TODOs (scattered, incomplete)
4. Try to remember architecture decisions (forget details)
5. Re-explore codebase (30 minutes)
6. Ask AI to help (AI has no context either)
7. Re-explain project to AI (15 minutes)
8. Finally start working (45 minutes wasted)

Result: 45-60 minutes to get back into flow
```

**With AI-Agent Memory System:**
```
1. Open project
2. Read STATUS.md (2 minutes)
   - Current Task: "Implementing Facebook OAuth (70% complete)"
   - Next Steps: "1. Add Facebook app credentials, 2. Test login flow"
   - Blockers: "None"
3. Read ROADMAP.md (1 minute)
   - Milestone 2: OAuth Providers (60% complete)
   - Next: Facebook OAuth, then GitHub OAuth
4. Read DECISIONS.md#Decision-002 (2 minutes)
   - Reminder: We auto-link OAuth accounts by verified email
5. Read backend/auth/CLAUDE.md (optional, if needed)
6. Start working (5 minutes total)

Result: 5 minutes to full productivity
```

**Time savings: 40-55 minutes per session**

**Typical hobby project:** 20-30 sessions over lifecycle
**Total time saved:** 13-27 hours of context re-explanation

---

## Adoption Guide

### For Solo Developers

**Best for:**
- Hobby projects (inconsistent work schedule)
- Learning projects (want to document discoveries)
- Side projects (resume after weeks away)
- AI-assisted projects (using Claude Code, GitHub Copilot, etc.)

**Quick start:**
1. Copy template files to project root
2. Populate CLAUDE.md with project overview
3. Create first ROADMAP.md milestone
4. Start first task, update STATUS.md

**Effort:**
- **Setup:** 30 minutes (one-time)
- **Maintenance:** 5 minutes per session (update STATUS.md)
- **Return on investment:** Massive (hours saved per resume)

### For Small Teams (2-5 developers)

**Best for:**
- Startup teams
- Open source projects with multiple contributors
- Freelance teams
- Remote teams (async work)

**Adoption:**
1. Team leader creates initial files
2. Establish "update STATUS.md every PR" norm
3. Use DECISIONS.md for architecture decisions (ADRs)
4. Use JOURNAL.md for onboarding new team members

**Benefits:**
- ✅ New team members onboard faster (read CLAUDE.md + STATUS.md)
- ✅ Async work easier (STATUS.md shows current state)
- ✅ Decisions documented (no "why did we do this?" confusion)
- ✅ Knowledge preserved (JOURNAL.md captures institutional knowledge)

**Team workflow:**
```
Developer A:
1. Read STATUS.md (sees what others are working on)
2. Pick task from ROADMAP.md (no conflicts)
3. Work on task
4. Update STATUS.md in PR description
5. Document significant decisions in DECISIONS.md

Developer B (next day):
1. Read STATUS.md (sees Developer A's progress)
2. Continues next task
3. No synchronous communication needed (async-friendly)
```

### For AI-Assisted Development

**Best for:**
- Claude Code users
- GitHub Copilot users
- ChatGPT/Claude for development
- Any AI-assisted coding workflow

**Integration:**

**Claude Code:**
```markdown
# In global ~/.claude/CLAUDE.md or project CLAUDE.md

## AI-Agent Memory System

**Every session:**
1. Read /CLAUDE.md → project context
2. Read /STATUS.md → current state
3. Read /ROADMAP.md → task priority
4. Read /DECISIONS.md → decision history

**During work:**
- Update STATUS.md with progress
- Mark ROADMAP.md items complete
- Document decisions in DECISIONS.md
- Capture learnings in JOURNAL.md

**At session end:**
- Update STATUS.md with next steps
- Commit memory files with code
```

**ChatGPT/Claude:**
```
[Start every conversation with]
"Read /STATUS.md and tell me what we're working on."

[AI response]
"I see we're implementing Facebook OAuth (70% complete).
 Next steps are to add Facebook app credentials and test
 the login flow. I'll continue from there."
```

**GitHub Copilot:**
- Not session-based, but benefits from CLAUDE.md context
- Reads CLAUDE.md to understand project patterns
- Suggests code following documented conventions

### For Existing Projects

**Migration strategy:**

**Week 1: Retroactive Documentation**
1. Create STATUS.md (where are we NOW?)
2. Create ROADMAP.md (what's LEFT to do?)
3. Create CLAUDE.md (basic project overview)
4. Start using immediately

**Week 2-3: Capture Decisions**
5. Review git history for major decisions
6. Document 5-10 key decisions in DECISIONS.md
7. Especially: architecture choices, technology selections

**Week 4: Establish Habits**
8. Update STATUS.md every commit/PR
9. Mark ROADMAP.md items complete
10. Add new decisions as they occur

**Don't:**
- ❌ Try to document entire project history (too much work)
- ❌ Delay using system until "perfect" (start now)
- ❌ Document every small decision (focus on significant ones)

**Do:**
- ✅ Start with minimal docs (STATUS.md + ROADMAP.md sufficient)
- ✅ Build documentation incrementally
- ✅ Focus on forward progress (not perfect retroactive docs)

### For Open Source Projects

**Benefits for OSS:**
- ✅ **Lower contribution barrier** (CLAUDE.md explains project)
- ✅ **Clear task list** (ROADMAP.md shows what needs doing)
- ✅ **Decision transparency** (DECISIONS.md explains why)
- ✅ **Onboarding docs** ([directory]/CLAUDE.md guides contributors)

**Example: First-time contributor workflow**

**Without system:**
```
1. Read README (high-level only)
2. Explore codebase (confused)
3. Ask in Discord: "How can I help?"
4. Maintainer explains (30 min back-and-forth)
5. Contributor maybe starts work
```

**With system:**
```
1. Read README (high-level)
2. Read CLAUDE.md (architecture, conventions)
3. Read ROADMAP.md (see "good first issue" tasks)
4. Read backend/CLAUDE.md for backend context
5. Pick task, start immediately
6. Submit PR with STATUS.md update
```

**Time to first contribution:**
- Without: 2-4 hours (high friction)
- With: 30-60 minutes (low friction)

**Recommended structure for OSS:**
```
project/
├── README.md          # Public-facing (users)
├── CONTRIBUTING.md    # Contribution guidelines
├── CLAUDE.md          # Project overview (contributors + AI)
├── ROADMAP.md         # Public roadmap (what's being built)
├── docs/
│   ├── DECISIONS.md   # Architecture decisions (why things are this way)
│   └── [other docs]
└── [code]
```

**Note:** STATUS.md might not be appropriate for OSS (multiple contributors),
but ROADMAP.md + DECISIONS.md + CLAUDE.md are very valuable.

---

## Advanced Patterns

### Pattern 1: Multi-Repo Projects

**Challenge:** Microservices or multi-repo projects (frontend, backend, mobile).

**Solution:** Shared memory files + repo-specific files

**Structure:**
```
repos/
├── shared-docs/              # Shared memory files
│   ├── STATUS.md            # Overall project status
│   ├── ROADMAP.md           # Cross-repo milestones
│   ├── DECISIONS.md         # Cross-cutting decisions
│   └── JOURNAL.md           # Learnings
│
├── backend/
│   ├── CLAUDE.md            # Backend-specific context
│   ├── STATUS.md            # Backend current state (optional)
│   └── [code]
│
├── frontend/
│   ├── CLAUDE.md            # Frontend-specific context
│   ├── STATUS.md            # Frontend current state (optional)
│   └── [code]
│
└── mobile/
    ├── CLAUDE.md            # Mobile-specific context
    └── [code]
```

**Reading order for AI:**
1. shared-docs/CLAUDE.md → Overall project context
2. shared-docs/STATUS.md → Overall current state
3. [repo]/CLAUDE.md → Repo-specific context
4. [repo]/STATUS.md → Repo-specific state (if exists)

**Update pattern:**
- Update shared-docs/STATUS.md for cross-repo work
- Update [repo]/STATUS.md for repo-specific work
- Update shared-docs/ROADMAP.md for milestones
- Update shared-docs/DECISIONS.md for architecture decisions

### Pattern 2: Long-Running Projects (1+ years)

**Challenge:** DECISIONS.md and JOURNAL.md grow very large.

**Solution:** Archive old entries annually.

**Structure:**
```
docs/
├── DECISIONS.md                    # Active decisions (current year)
├── JOURNAL.md                      # Active learnings (current year)
└── archive/
    ├── DECISIONS-2024.md           # Archived decisions
    ├── DECISIONS-2023.md
    ├── JOURNAL-2024.md             # Archived learnings
    └── JOURNAL-2023.md
```

**At year-end:**
1. Move DECISIONS.md → archive/DECISIONS-2024.md
2. Create new DECISIONS.md with index:
   ```markdown
   # Decision Log

   ## Active Decisions (2025)
   [Current year decisions]

   ## Archive
   - [2024 Decisions](archive/DECISIONS-2024.md)
   - [2023 Decisions](archive/DECISIONS-2023.md)
   ```

3. Same for JOURNAL.md

**Keeps files manageable** while preserving history.

### Pattern 3: Multiple AI Agents

**Challenge:** Using different AI tools (Claude Code + ChatGPT + GitHub Copilot).

**Solution:** Universal file format (markdown) works across all tools.

**Setup:**

**Claude Code:** Reads memory files automatically (configured in CLAUDE.md)

**ChatGPT:** Start every conversation with:
```
"I'm working on [project]. Please read /STATUS.md and /ROADMAP.md
 to understand the current state, then continue development."
```

**GitHub Copilot:** Uses CLAUDE.md for context, suggests code following patterns

**Cursor/Other AI IDEs:** Configure to read memory files in workspace context

**Key principle:** Memory files are tool-agnostic (plain markdown).

### Pattern 4: Decision Templates

**For common decision types, use templates:**

**Technology Selection Template:**
```markdown
## Decision [N]: [Technology] for [Use Case]

**Date:** YYYY-MM-DD
**Status:** ✅ Active

**Decision:** Use [Technology X] for [use case]

**Alternatives Considered:**
1. **[Tech A]** - [pros/cons]
2. **[Tech X]** (chosen) - [pros/cons]
3. **[Tech B]** - [pros/cons]

**Evaluation Criteria:**
- Performance: [assessment]
- Developer experience: [assessment]
- Community/ecosystem: [assessment]
- Cost: [assessment]
- Learning curve: [assessment]

**Rationale:** [Why Tech X won]

**Tradeoffs:**
- ❌ [What we gave up]
- ✅ [What we gained]

**Migration Path:** [If we need to change later]
```

**Architecture Decision Record (ADR) Template:**
```markdown
## Decision [N]: [Architecture Pattern]

**Date:** YYYY-MM-DD
**Status:** ✅ Active

**Context:**
[What forces are at play? What problem are we solving?]

**Decision:**
[What are we doing?]

**Consequences:**
- Positive: [benefits]
- Negative: [costs, risks]
- Neutral: [other effects]

**Alternatives:**
[What else did we consider?]

**Related Decisions:**
- Decision [X]
- Decision [Y]
```

### Pattern 5: "Quick Reference" Section in CLAUDE.md

**For frequently-needed commands:**

```markdown
# [Project] Quick Reference

## Common Commands

**Run dev environment:**
\`\`\`bash
docker-compose up -d
npm run dev
\`\`\`

**Run tests:**
\`\`\`bash
pytest tests/          # Backend
npm test              # Frontend
\`\`\`

**Database migrations:**
\`\`\`bash
alembic upgrade head   # Apply migrations
alembic revision --autogenerate -m "message"  # Create migration
\`\`\`

**Deploy:**
\`\`\`bash
./scripts/deploy.sh production
\`\`\`

## Frequent Patterns

**Add new API endpoint:**
1. Define Pydantic model in models/
2. Create route in api/
3. Add business logic in services/
4. Write tests in tests/
5. Update OpenAPI docs

**Add database migration:**
[steps]

## Gotchas

❌ **Don't do X** - Causes Y
✅ **Do Z instead** - Avoids Y
```

**Saves AI (and humans) from constantly searching for common patterns.**

---

## FAQ

### Q: Isn't this just documentation?

**A:** Yes, but structured specifically for AI agents.

Traditional docs:
- Written for humans (verbose, narrative)
- Often stale (not updated frequently)
- Hard to query (where's the current status?)
- No clear entry point (start reading where?)

AI-Agent Memory System:
- Written for AI + humans (structured, concise)
- Updated every session (stays current)
- Easy to query (STATUS.md = current, ROADMAP.md = next)
- Clear entry point (always read STATUS.md first)

**Key difference:** Treated as living memory, not static documentation.

### Q: How is this different from git commit messages?

**Git commits:**
- What changed (code diff)
- Low-level (per-file changes)
- Linear history (one commit after another)
- No context for "why" (unless excellent commit messages)

**AI-Agent Memory System:**
- Why it changed (DECISIONS.md)
- High-level (current state, next steps)
- Structured (STATUS, ROADMAP, DECISIONS, JOURNAL)
- Explicit context (project overview, patterns, conventions)

**Both are valuable** - commits track code changes, memory system tracks project state.

### Q: My DECISIONS.md is getting long. What do I do?

**Options:**

1. **Archive old decisions** (see Advanced Patterns)
2. **Deprecate outdated decisions** (mark as ⚠️ Deprecated)
3. **Create index at top** (Decision 001-010 = Architecture, 011-020 = Features)
4. **Split by domain** (DECISIONS-AUTH.md, DECISIONS-API.md, etc.)

**Don't:**
- ❌ Delete old decisions (they provide historical context)
- ❌ Stop adding new decisions (defeats the purpose)

**Do:**
- ✅ Mark decisions as Active / Deprecated / Superseded
- ✅ Link superseding decision ("See Decision 042")
- ✅ Keep active decisions near top (most relevant)

### Q: I'm on a team. Who updates STATUS.md?

**Options:**

**Option 1: No team STATUS.md** (each developer has own branch STATUS.md)
```
- Developer A: feature-a branch has STATUS.md for feature-a
- Developer B: feature-b branch has STATUS.md for feature-b
- Main branch: STATUS.md shows overall project state (updated by lead)
```

**Option 2: STATUS.md in PR description** (not in repo)
```
- Each PR description includes current state
- No STATUS.md file in repo (or main branch only)
- ROADMAP.md still useful (overall task list)
```

**Option 3: Team STATUS.md** (updated by last committer)
```
- Whoever commits last updates STATUS.md
- Include in PR: code changes + STATUS.md update
- Merge conflicts resolve by "most recent wins"
```

**Recommended: Option 1** (branch-specific STATUS.md, main branch for overall)

### Q: Do I need all these files?

**No! Start minimal:**

**Minimum viable:**
- STATUS.md (where am I?)
- ROADMAP.md (what's next?)

**Add when useful:**
- CLAUDE.md (when project gets complex)
- DECISIONS.md (when making significant architectural choices)
- JOURNAL.md (when discovering patterns worth remembering)
- Directory CLAUDE.md (when domain gets complex)

**Principle:** Add files when they solve a problem, not because "the system says so."

### Q: How long should each file be?

**Rough guidelines:**

- **STATUS.md:** 50-200 lines (1-2 screens)
  - If longer, you're over-documenting
  - Keep focused on current state only

- **ROADMAP.md:** 100-500 lines (2-5 screens)
  - ~3 milestones visible
  - Archive completed milestones to separate file

- **DECISIONS.md:** Grows over time
  - 50 lines per decision × N decisions
  - Archive annually if >2,000 lines

- **JOURNAL.md:** Grows over time
  - 30-100 lines per entry × N entries
  - Archive annually if >2,000 lines

- **CLAUDE.md:** 200-1,000 lines (comprehensive overview)
  - Should fit in AI context window easily
  - Link to detailed docs, don't duplicate

**If files get too long:**
- Archive old content
- Split by domain
- Link to detailed docs instead of inlining

### Q: What if I forget to update files?

**It happens! Recovery:**

1. **Read git log** (see what you did)
2. **Update STATUS.md** (current state as of now)
3. **Update ROADMAP.md** (mark items complete)
4. **Move on** (don't try to retroactively document everything)

**Prevention:**
- Habit: "Update STATUS.md before committing"
- Git hook: Remind to update STATUS.md if unchanged in 5+ commits
- Discipline: Treat memory files as important as code

**Philosophy:** Better to have 80% up-to-date memory files than 0% documentation.

### Q: Can I use this for non-AI development?

**Yes!** This system works for human-only development too.

**Benefits for humans:**
- Resume projects after weeks away (read STATUS.md)
- Onboard new team members (read CLAUDE.md)
- Understand architectural decisions (read DECISIONS.md)
- Learn from past mistakes (read JOURNAL.md)

**Human-only workflow:**
1. Read STATUS.md when resuming work
2. Update STATUS.md when finishing for the day
3. Document decisions in DECISIONS.md
4. Check off ROADMAP.md items as complete

**This is just good project hygiene** - AI agents benefit, but so do humans.

### Q: What about project management tools (Jira, Asana)?

**Can coexist:**

**Use PM tools for:**
- Team coordination
- Sprint planning
- Bug tracking
- Customer requests

**Use AI-Agent Memory System for:**
- Technical context (what/why/how)
- Architectural decisions
- Developer knowledge
- AI agent memory

**Integration:**
- Link ROADMAP.md items to Jira tickets
- Link DECISIONS.md to Jira epics (why we built X)
- Use STATUS.md for developer state, Jira for project state

**Not competing** - PM tools for project management, memory system for technical knowledge.

---

## Conclusion

**The AI-Agent Memory System solves session amnesia in AI-assisted development.**

**Core innovation:**
- Structured markdown files (STATUS, ROADMAP, DECISIONS, JOURNAL, CLAUDE.md)
- Persistent context across sessions
- Lightweight, human-readable, tool-agnostic

**Real-world results:**
- 6+ month project survival (vs. 2-4 weeks typical)
- 92% milestone completion with AI as primary developer
- 90% reduction in context re-explanation time
- Zero session-to-session context loss

**Adoption:**
- ✅ Solo developers (hobby/side projects)
- ✅ Small teams (2-5 developers)
- ✅ AI-assisted development (Claude Code, ChatGPT, Copilot)
- ✅ Open source projects (lower contribution barrier)

**Quick start:**
1. Copy template files to project root
2. Populate CLAUDE.md (30 min one-time setup)
3. Create ROADMAP.md with first milestone
4. Update STATUS.md every session (5 min habit)

**This works. Use it.**

---

## Resources

**Template Files:**
- See "Template Files" section above

**Example Implementation:**
- Space Adventures project (docs/CUTTING-EDGE-PRACTICES.md)

**Further Reading:**
- Architecture Decision Records (ADRs): https://adr.github.io/
- Zettelkasten (note-taking system): https://zettelkasten.de/
- Shape Up (Basecamp): https://basecamp.com/shapeup

**Community:**
- Share your experiences using this system
- Contribute improvements to templates
- Report what works / what doesn't

**License:**
- CC BY-SA 4.0 (use freely, attribute, share improvements)

---

**Document Version:** 1.0
**Last Updated:** 2025-01-20
**Author:** Developed for Space Adventures project, shared for community benefit
**Feedback:** [Your contact / issue tracker]

**This system is a work in progress. Your feedback improves it for everyone.**
