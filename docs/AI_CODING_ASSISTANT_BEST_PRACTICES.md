# AI Coding Assistant: Best Practices & Effective Prompting

**A practical guide to maximizing productivity when working with AI coding assistants**

---

## Table of Contents

1. [Core Principles](#core-principles)
2. [Prompt Patterns That Work](#prompt-patterns-that-work)
3. [Workflow Strategies](#workflow-strategies)
4. [Common Pitfalls to Avoid](#common-pitfalls-to-avoid)
5. [Real-World Examples](#real-world-examples)
6. [Measuring Success](#measuring-success)

---

## Core Principles

### 1. **Clarity Over Cleverness**

AI assistants respond best to clear, specific requests. Avoid vague language.

**❌ Vague:**
```
"Make the code better"
"Add some tests"
"Improve performance"
```

**✅ Clear:**
```
"Refactor the authentication logic to use JWT tokens instead of sessions"
"Add unit tests for the UserService class covering edge cases: null input, duplicate emails, invalid formats"
"Optimize the database query in getUserOrders() - currently taking 3+ seconds with 10k records"
```

### 2. **Trust + Boundaries**

Define **WHAT** you want, let the AI determine **HOW**.

**❌ Micromanaging:**
```
"Create a function called validateEmail that uses regex pattern /^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/
and returns a boolean, put it on line 45 of utils.js"
```

**✅ Trusting with boundaries:**
```
"Add email validation to the user registration form. Must handle:
- Standard email formats
- International domains
- Return clear error messages
Follow existing validation patterns in validators/"
```

### 3. **Incremental Progress**

Break large tasks into smaller, verifiable steps. Confirm completion before proceeding.

**Workflow:**
1. Request Task A → Verify → Confirm
2. Request Task B → Verify → Confirm
3. Request Task C → Verify → Confirm

Not:
1. Request Tasks A, B, C, D, E → Hope everything works

---

## Prompt Patterns That Work

### Pattern 1: **Numbered Multi-Task Requests** ⭐

Use numbered lists for parallel or sequential work.

**Format:**
```
1. [First concrete task]
2. [Second concrete task]
3. [Third concrete task]

[Optional: Context or constraints]
```

**Example:**
```
1. Create a REST API endpoint for user registration (POST /api/auth/register)
2. Add input validation using Joi schema
3. Write integration tests covering success and error cases

Use Express.js and follow existing patterns in auth/login.js
```

**Why it works:**
- Clear task boundaries
- Measurable deliverables
- Easy to verify completion
- Enables parallel work (if supported)

### Pattern 2: **The Confirmation Pattern**

Use simple confirmations to maintain momentum after AI completes a task.

**Example Exchange:**
```
AI: "I've implemented the user registration endpoint. Should I proceed with adding tests?"
You: "yes"
AI: [Immediately begins next task without re-explaining context]
```

**Why it works:**
- Eliminates repetitive re-explaining
- High development velocity
- Clear go/no-go decisions
- Reduces cognitive load

### Pattern 3: **Problem-First Bug Reports**

Describe symptoms, not assumed solutions.

**❌ Solution-first:**
```
"I think the database connection string is wrong, can you change it to use port 5432?"
```

**✅ Problem-first:**
```
"The application crashes on startup with error: 'Connection refused - ECONNREFUSED 127.0.0.1:3306'
Expected: Should connect to PostgreSQL database
Actual: Attempting connection to MySQL port

Here's the error log: [paste error]"
```

**Why it works:**
- AI can diagnose root cause
- May find deeper issues you missed
- Avoids implementing wrong fixes
- Faster resolution

### Pattern 4: **Scope Boundary Specification**

Provide specific counts, names, or limits.

**❌ Unbounded:**
```
"Add some API endpoints"
"Create test files"
"Implement features"
```

**✅ Bounded:**
```
"Add 3 API endpoints: GET /users, POST /users, DELETE /users/:id"
"Create test files for UserController (5 tests) and AuthService (8 tests)"
"Implement the following 4 features from roadmap.md: [list features]"
```

**Why it works:**
- Clear completion criteria
- Prevents scope creep
- Easier to estimate effort
- Enables accurate progress tracking

### Pattern 5: **Context-Rich Initialization**

Start sessions with comprehensive context.

**Template:**
```
Current state: [What's been done]
Current goal: [What you're working on]
Current blocker: [What's preventing progress, if any]

Architecture: [Brief tech stack overview]
Relevant files: [List key files AI should know about]

Task: [Specific request]
```

**Example:**
```
Current state: User authentication implemented, database schema created
Current goal: Implementing user profile management
Current blocker: None

Architecture: Node.js + Express + PostgreSQL + Jest
Relevant files:
- src/routes/auth.js (authentication patterns)
- src/models/User.js (user model)
- tests/auth.test.js (test patterns)

Task: Create user profile endpoints (GET, PUT) following existing auth patterns
```

**Why it works:**
- AI has full context immediately
- Maintains consistency with existing code
- Reduces back-and-forth questions
- Faster initial response

### Pattern 6: **The Testing Integration Pattern**

Always include testing in your request.

**Format:**
```
[Implementation request]

Include:
- Unit tests for core logic
- Integration tests for API endpoints
- Error case coverage

Follow existing test patterns in tests/
```

**Example:**
```
Implement password reset functionality:
1. POST /api/auth/reset-password (send email)
2. POST /api/auth/reset-password/confirm (set new password)

Include:
- Unit tests for token generation/validation
- Integration tests for both endpoints
- Test cases: valid token, expired token, invalid token, missing fields

Follow patterns in tests/auth.test.js
```

**Why it works:**
- Ensures code quality from the start
- Catches bugs immediately
- Documents expected behavior
- Reduces technical debt

---

## Workflow Strategies

### Strategy 1: **Parallel Development** (When Supported)

If your AI assistant supports parallel execution, use it aggressively.

**Request Format:**
```
I need these 3 independent tasks completed:

1. [Task A - no dependencies]
2. [Task B - no dependencies]
3. [Task C - no dependencies]

These can be done in parallel.
```

**Example:**
```
I need these 4 components completed:

1. Create UserService class (src/services/user.js)
2. Create ProductService class (src/services/product.js)
3. Create OrderService class (src/services/order.js)
4. Write tests for all three services

These are independent and can be done in parallel.
```

**When to use:**
- Creating multiple similar components
- Writing tests for existing code
- Implementing independent features
- Documentation tasks

**When NOT to use:**
- Tasks have dependencies (A must finish before B starts)
- Shared file modifications (will cause conflicts)
- Sequential debugging (need results from step 1 to proceed)

### Strategy 2: **Iterative Refinement**

Start with basic implementation, then refine.

**Phase 1: Core Functionality**
```
"Create a basic user authentication system with login/logout"
```

**Phase 2: Enhancement**
```
"Add password reset functionality to the existing auth system"
```

**Phase 3: Polish**
```
"Add rate limiting to auth endpoints (max 5 attempts per 15 minutes)"
```

**Phase 4: Hardening**
```
"Add comprehensive error handling and security headers to auth system"
```

**Why it works:**
- Each phase is testable
- Early feedback on approach
- Can pivot if direction is wrong
- Maintains working code at each step

### Strategy 3: **Documentation-Driven Development**

Write documentation first, implement second.

**Step 1: Request Documentation**
```
"Create API documentation for a user management system with endpoints:
- POST /users (create)
- GET /users/:id (read)
- PUT /users/:id (update)
- DELETE /users/:id (delete)

Include: request/response schemas, error codes, authentication requirements"
```

**Step 2: Review & Approve**
[Review the documentation, make adjustments]

**Step 3: Request Implementation**
```
"Implement the user management API according to the documentation we just created"
```

**Why it works:**
- Forces clear thinking about requirements
- Easier to review documentation than code
- Implementation has clear specification
- Documentation exists from day 1

### Strategy 4: **The Test-First Workflow**

Request tests before implementation (TDD approach).

**Step 1: Request Tests**
```
"Write tests for a user registration function that should:
- Accept email, password, name
- Validate email format
- Require password length >= 8 characters
- Check for duplicate emails
- Return user object on success or error message on failure

Don't implement the function yet, just write the tests."
```

**Step 2: Review Tests**
[Ensure tests cover all cases]

**Step 3: Request Implementation**
```
"Now implement the user registration function to make these tests pass"
```

**Why it works:**
- Tests define exact requirements
- Implementation is verifiable immediately
- Reduces over-engineering
- True test-driven development

---

## Common Pitfalls to Avoid

### Pitfall 1: **The Vague Request**

**Problem:**
```
"Make the code better"
"Fix the bugs"
"Improve security"
```

**Why it fails:**
- No measurable outcome
- AI must guess your intent
- Results may not match expectations

**Solution:**
```
"Refactor the UserController to follow single-responsibility principle - extract database logic into UserRepository"
"Fix the bug where login fails with error 'Cannot read property id of undefined' when email doesn't exist"
"Add input sanitization to all form endpoints to prevent XSS attacks"
```

### Pitfall 2: **The Everything Request**

**Problem:**
```
"Build a complete e-commerce system with user auth, product catalog, shopping cart,
payment processing, order management, admin dashboard, email notifications, and analytics"
```

**Why it fails:**
- Overwhelming scope
- Impossible to verify
- High chance of errors
- Difficult to debug

**Solution:**
Break into phases:
```
Phase 1: "Create basic user authentication (register, login, logout)"
[Verify Phase 1]

Phase 2: "Add product catalog with CRUD operations"
[Verify Phase 2]

Phase 3: "Implement shopping cart functionality"
[And so on...]
```

### Pitfall 3: **The Assumption Trap**

**Problem:**
```
"The database connection must be failing, change the connection string"
```

**Why it fails:**
- Assumption may be wrong
- Wastes time implementing wrong fix
- Masks real issue

**Solution:**
```
"Application fails to start with error: [paste error]
What's the root cause and how should we fix it?"
```

### Pitfall 4: **The No-Context Request**

**Problem:**
```
[Starting new session]
"Add error handling"
```

**Why it fails:**
- AI doesn't know which file, function, or error types
- May violate existing patterns
- Inconsistent with codebase style

**Solution:**
```
[Starting new session]

Context: Node.js/Express API, existing auth system in src/auth/
Current pattern: Using try-catch with custom AppError class

Task: Add error handling to the new payment processing endpoints in src/routes/payments.js
Follow the existing pattern from src/routes/auth.js
```

### Pitfall 5: **The Missing Verification**

**Problem:**
```
AI: "I've completed tasks 1, 2, and 3"
You: "Great! Now do tasks 4, 5, and 6"
[Later discover task 2 was broken, now tasks 4-6 built on broken foundation]
```

**Why it fails:**
- Errors compound
- Hard to debug multiple layers
- Wastes time building on broken code

**Solution:**
```
AI: "I've completed tasks 1, 2, and 3"
You: [Test/verify tasks 1-3]
You: "Task 2 has an issue: [describe]. Task 1 and 3 work great."
AI: [Fixes task 2]
You: [Verify fix]
You: "Perfect! Now do tasks 4, 5, and 6"
```

---

## Real-World Examples

### Example 1: Building a REST API

**Effective Approach:**

```
Session 1:
"Create a REST API skeleton with Express.js:
1. Basic server setup (port 3000)
2. Health check endpoint (GET /health)
3. Error handling middleware
4. Request logging middleware

Use industry-standard patterns."

[Verify server starts, health check works]
"yes"

"Now add user authentication:
1. POST /auth/register (email, password)
2. POST /auth/login (returns JWT)
3. Middleware to verify JWT
4. Include bcrypt for password hashing

Follow existing project structure."

[Verify auth works]
"yes"

"Add user profile endpoints:
1. GET /users/:id (requires auth)
2. PUT /users/:id (requires auth, owner only)
3. Include input validation with Joi

Follow existing auth patterns."
```

**Result:** Clean, tested, incremental build with verification at each step.

### Example 2: Debugging Production Issue

**Effective Approach:**

```
"Production issue report:

Environment: Node.js v18, PostgreSQL 14, deployed on AWS
Symptom: API returns 500 error intermittently (roughly 5% of requests)
Error: 'Connection pool exhausted'
Observed: Happens during traffic spikes (>100 req/sec)

Context:
- Connection pool set to 10 connections
- Average query time: 50ms
- No connection cleanup in older code

Logs: [paste relevant logs]

Questions:
1. What's the root cause?
2. What's the recommended fix?
3. How can we prevent this in the future?"
```

**Result:** AI can diagnose (pool too small + connection leaks), recommend fix (increase pool size + add connection cleanup), and suggest prevention (connection monitoring + load testing).

### Example 3: Adding New Feature

**Effective Approach:**

```
"I need to add a 'favorites' feature where users can save products.

Requirements:
- Users can favorite/unfavorite products
- Users can view their list of favorites
- Must be performant (thousands of users, thousands of products)

Database: PostgreSQL
Current schema: users table, products table exist

Task:
1. Design the database schema (propose before implementing)
2. Create API endpoints (specify endpoints)
3. Add to existing UserService and ProductService
4. Write tests

What schema do you recommend?"

[Review schema proposal]
"Looks good, proceed with implementation"

[AI implements]
[Verify functionality]
"Perfect, now let's add pagination to the favorites list endpoint. Max 50 items per page."
```

**Result:** Collaborative design, clear implementation, iterative enhancement.

### Example 4: Refactoring Legacy Code

**Effective Approach:**

```
"I need to refactor the legacy authentication code.

Current state:
- All logic in one 500-line file (src/auth.js)
- No separation of concerns
- Hard to test
- Uses callbacks instead of promises

Goal:
- Extract into logical modules
- Make testable
- Convert to async/await
- Don't break existing functionality

Step 1: Analyze the current code and propose a refactoring plan.
Show me the proposed structure before implementing."

[AI proposes structure]
"Good, but let's also separate JWT logic into its own module. Update the plan."

[AI updates plan]
"Perfect. Implement the refactoring step by step:
1. Create new module structure (empty files with exports)
2. Move authentication logic
3. Move JWT logic
4. Update imports in dependent files
5. Add tests for each module

After each step, I'll verify before continuing."
```

**Result:** Safe, incremental refactoring with verification at each step.

---

## Measuring Success

### Productivity Metrics

Track these to measure effectiveness:

1. **Tasks Completed Per Session**
   - Before optimization: 1-2 tasks
   - After optimization: 5-10+ tasks

2. **Code Quality**
   - Lines of code written
   - Test coverage percentage
   - Bugs found in review vs. production

3. **Iteration Speed**
   - Time from request to working code
   - Number of back-and-forth clarifications needed

4. **Context Retention**
   - How often you repeat the same information
   - How well AI maintains consistency with existing code

### Quality Indicators

**High-Quality Session:**
- ✅ Clear, specific requests
- ✅ Each task verified before proceeding
- ✅ Minimal back-and-forth clarifications
- ✅ Code follows existing patterns
- ✅ Tests included automatically
- ✅ Documentation updated

**Low-Quality Session:**
- ❌ Vague requests requiring multiple clarifications
- ❌ Discovered broken code several steps later
- ❌ Code doesn't match existing style
- ❌ Forgot to include tests
- ❌ Documentation missing or outdated

### ROI Calculation

**Time Saved Example:**

Traditional approach to adding a feature:
- Research: 30 minutes
- Implementation: 2 hours
- Testing: 1 hour
- Documentation: 30 minutes
- **Total: 4 hours**

AI-assisted approach:
- Request with clear requirements: 5 minutes
- AI implementation: 15 minutes
- Human review + verification: 20 minutes
- Iterations/fixes: 20 minutes
- **Total: 1 hour**

**3x productivity increase** with proper prompting technique.

---

## Advanced Techniques

### Technique 1: **The Specification Template**

Create reusable templates for common requests.

**Template:**
```
Feature: [Feature name]

Requirements:
- [Functional requirement 1]
- [Functional requirement 2]
- [Non-functional requirement]

Technical constraints:
- [Constraint 1]
- [Constraint 2]

Acceptance criteria:
- [ ] [Criterion 1]
- [ ] [Criterion 2]

Files to modify: [List files]
Follow patterns from: [Reference file]
```

**Usage:**
Fill in the blanks, paste to AI, get consistent results.

### Technique 2: **The Context Snapshot**

Create a project context file that you paste at session start.

**Example: PROJECT_CONTEXT.md**
```markdown
# Project Context

**Tech Stack:** Node.js 18, Express 4, PostgreSQL 14, Jest 29
**Architecture:** RESTful API with MVC pattern
**Auth:** JWT tokens, bcrypt password hashing
**Database:** TypeORM with migrations

**Key Files:**
- src/server.js - Entry point
- src/routes/ - API routes
- src/controllers/ - Request handlers
- src/services/ - Business logic
- src/models/ - Database models
- src/middleware/ - Express middleware
- tests/ - Jest tests

**Patterns to Follow:**
- Controllers are thin, delegate to services
- Services contain business logic
- Use async/await, not callbacks
- All endpoints have tests
- Use custom AppError for errors

**Current Sprint:** User management features
```

Paste this at the start of each session for instant context.

### Technique 3: **The Rubber Duck Technique** (with AI)

Before implementing, ask AI to explain the approach.

```
"Before implementing the user authentication system, explain:
1. What approach you would take
2. What potential issues you foresee
3. What architectural decisions need to be made

Then we'll decide on the approach together before coding."
```

This catches potential issues before implementation.

### Technique 4: **The Diff Review Pattern**

For large changes, request summary before implementation.

```
"I need to refactor the payment processing system.

Before making changes, provide:
1. List of files that will be modified
2. Summary of changes for each file
3. Any breaking changes
4. Testing strategy

Then I'll approve before you proceed."
```

Prevents unwanted surprises in large refactors.

---

## Workflow Cheat Sheet

### Starting a Session

1. ✅ Provide context (tech stack, current state)
2. ✅ State clear goal
3. ✅ Specify boundaries (files, scope, constraints)
4. ✅ Request specific first task

### During Implementation

1. ✅ Use numbered task lists
2. ✅ Verify each task before proceeding
3. ✅ Use "yes" for continuations
4. ✅ Describe problems, not solutions
5. ✅ Request tests with implementation

### Code Review

1. ✅ Check code follows existing patterns
2. ✅ Verify tests are included
3. ✅ Run code locally
4. ✅ Confirm documentation updated
5. ✅ Provide feedback on issues

### Ending a Session

1. ✅ Summarize what was completed
2. ✅ Note any pending tasks
3. ✅ Document decisions made
4. ✅ Update project tracking

---

## Language-Agnostic Principles

These patterns work regardless of programming language:

### Universal Patterns

**1. Specificity**
- ✅ Works in Python: "Add type hints to all functions in user_service.py"
- ✅ Works in Java: "Add generics to the Repository<T> interface"
- ✅ Works in JavaScript: "Add JSDoc comments to all exported functions"

**2. Incremental Development**
- ✅ Works in any language: Build → Verify → Continue
- ✅ Works in any framework: Core → Features → Polish

**3. Testing Integration**
- ✅ Python: "Include pytest tests"
- ✅ Java: "Include JUnit 5 tests"
- ✅ JavaScript: "Include Jest tests"
- ✅ Go: "Include testing package tests"

**4. Context Awareness**
- ✅ All languages benefit from: tech stack, file structure, patterns to follow

---

## Conclusion

Effective AI-assisted development comes down to:

1. **Clear Communication** - Specific, bounded requests
2. **Trust + Verification** - Let AI implement, but verify each step
3. **Incremental Progress** - Small tasks, frequent verification
4. **Context Sharing** - Provide comprehensive background
5. **Pattern Recognition** - Learn what works, repeat it

The difference between:
- **Amateur**: "Make it work" → Hours of back-and-forth
- **Professional**: "Implement X following pattern Y with tests covering Z" → Working code in minutes

Master these patterns, and you'll achieve **3-10x productivity gains** compared to traditional development or poorly-prompted AI assistance.

---

## Appendix: Quick Reference

### The Perfect Request Template

```
Context: [Tech stack, current state, relevant files]

Task: [Specific, bounded request]

Requirements:
1. [Requirement 1]
2. [Requirement 2]
3. [Requirement 3]

Include:
- Tests following [existing test pattern]
- Error handling
- Documentation

Follow existing patterns in: [reference file]
```

### The Debugging Template

```
Problem: [Specific symptom]

Expected behavior: [What should happen]
Actual behavior: [What is happening]

Environment:
- [Relevant system info]
- [Versions]

Error message: [Paste exact error]

What I've tried:
- [Attempt 1 - result]
- [Attempt 2 - result]

Relevant code: [File and line numbers or paste snippet]
```

### The Feature Request Template

```
Feature: [Name]

User story: As a [user type], I want to [action] so that [benefit]

Requirements:
- [Must have 1]
- [Must have 2]
- [Nice to have 1]

Technical constraints:
- [Constraint 1]
- [Constraint 2]

Acceptance criteria:
- [ ] [Testable criterion 1]
- [ ] [Testable criterion 2]
```

---

**Document Version:** 1.0
**Based on:** Real-world project achieving 20,000+ lines of production code in a single session
**License:** MIT - Feel free to share, modify, and use in your projects
