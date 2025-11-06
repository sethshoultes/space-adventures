# Decision Log

Record of architectural and design decisions to avoid re-litigating the same issues.

**Purpose:** Document why we chose approach X over Y so future discussions can reference this.

---

## 2024-11-06: Project Distribution Strategy

**Decision:** Open source GitHub release with BYOK (Bring Your Own Keys)

**Rationale:**
- Hobby/learning project, not commercial
- Target audience: Technical users comfortable with Docker
- Zero ongoing hosting costs
- Educational value for community
- Users control their own AI costs

**Alternatives Considered:**
1. Hosted web service (rejected: ongoing costs, maintenance burden)
2. Desktop app with bundled backend (rejected: complex packaging)
3. Pure Godot with no backend (rejected: loses microservices learning)

**Impact:**
- Users must install Docker Desktop
- Users provide own API keys or use Ollama
- No monetization needed
- Can focus on features over scalability

**Made By:** User decision (with AI recommendation)
**Status:** ✅ Decided

---

## 2024-11-06: Development Approach - Milestones vs Timeline

**Decision:** Flexible milestone-based development instead of rigid 20-week timeline

**Rationale:**
- Hobby project with no external deadline
- Learning is primary goal, not shipping
- Motivation fluctuates naturally
- Life interrupts hobby projects
- Milestones show progress without pressure

**Alternatives Considered:**
1. Keep 20-week schedule (rejected: unrealistic for hobby project)
2. No structure at all (rejected: easy to lose momentum)
3. Sprint-based (rejected: too rigid for solo hobby)

**Impact:**
- Build when motivated
- Clear goals without time pressure
- Can pause and resume easily
- Success = learning, not completion

**Made By:** User decision (with AI recommendation)
**Status:** ✅ Decided

---

## 2024-11-06: AI Agent as Primary Developer

**Decision:** AI agents (Claude Code) perform 99% of development work

**Rationale:**
- User wants to learn while building
- AI can implement while user directs
- Faster progress than solo development
- User gains oversight experience
- AI handles boilerplate, user makes creative decisions

**Alternatives Considered:**
1. User codes everything (rejected: slower, less learning scope)
2. AI codes, user reviews only (rejected: less learning engagement)
3. Pair programming approach (selected: best of both worlds)

**Impact:**
- Documentation optimized for AI agent handoff
- Clear decision authority levels
- STATUS.md as single source of truth
- Emphasis on clear specifications

**Made By:** User decision
**Status:** ✅ Decided

---

## 2024-11-06: MVP Scope Reduction

**Decision:** Start with 3 core systems, expand to 5, then 10 (instead of all 10 at once)

**Rationale:**
- Validates fun factor early (3 systems)
- Prevents overengineering before gameplay testing
- Clear progression path
- Can pivot if not fun
- Reduces Milestone 1 scope to achievable

**Systems Priority:**
1. **Milestone 1 (Proof of Concept):** Hull, Power Core, Propulsion
2. **Milestone 2 (Expansion):** Add Warp Drive, Life Support
3. **Milestone 3 (Complete):** Add remaining 5 systems

**Alternatives Considered:**
1. All 10 systems at once (rejected: too much before testing fun)
2. Start with 1 system (rejected: can't test gameplay loop)
3. 5 systems first (rejected: still too much for validation)

**Impact:**
- Milestone 1 is 2-3 weeks instead of 6-8 weeks
- Can test game loop faster
- Clear decision point: continue or pivot?

**Made By:** AI recommendation, user accepted
**Status:** ✅ Decided

---

## 2024-11-05: NCC-1701 Port Registry System

**Decision:** Use Star Trek-themed ports (17010-17099) instead of standard ports (8000-8100)

**Rationale:**
- Avoids conflicts with common development ports
- Memorable (Star Trek theme fits game)
- Educational (teaches port management)
- Professional practice (custom port ranges)
- Fun Easter egg for Star Trek fans

**Port Assignments:**
- 17010: Gateway (NCC-1701-0 / USS Enterprise)
- 17011: AI Service (NCC-1701-1)
- 17012: Whisper Service (NCC-1701-2) [optional]
- 17014: Redis (NCC-1701-4)

**Alternatives Considered:**
1. Standard ports 8000-8003 (rejected: conflicts likely)
2. Random high ports (rejected: not memorable)
3. Sequential 3000-3003 (rejected: still conflicts)

**Impact:**
- Lower conflict probability
- Clear documentation need (users must know ports)
- Professional appearance

**Made By:** AI Agent (autonomous)
**Status:** ✅ Decided, Implemented

---

## 2024-11-05: Microservices Architecture for Single-Player Game

**Decision:** Use microservices (Gateway, AI Service, Redis) despite being single-player

**Rationale:**
- **Primary:** Learning experience (microservices are marketable skill)
- **Secondary:** Clean separation of concerns
- **Tertiary:** Impressive portfolio piece
- Educational value > perfect architecture for use case

**Alternatives Considered:**
1. Monolithic backend (rejected: less learning value)
2. Pure Godot (rejected: can't learn backend patterns)
3. Serverless functions (rejected: more complex locally)

**Impact:**
- More complex setup (Docker required)
- Better learning experience
- Easier to explain in portfolio/interviews
- Teaches real-world patterns

**Trade-offs Accepted:**
- Higher barrier to entry for players
- More moving parts to manage
- Overkill for single-player game

**Made By:** Original design decision
**Status:** ✅ Decided, Implemented

---

## 2024-11-05: Godot Autoload Singletons (5 Core)

**Decision:** Use 5 autoload singletons for core functionality

**Rationale:**
- Godot best practice for global systems
- Clean separation of concerns (SOLID)
- Persistent across scenes
- Easy to access from anywhere
- Testable independently

**Singletons:**
1. **ServiceManager** - HTTP client for backend
2. **GameState** - Central data store (no logic)
3. **SaveManager** - Persistence layer
4. **EventBus** - Decoupled communication (50+ signals)
5. **AIService** - AI content generation client

**Alternatives Considered:**
1. Single "Game" singleton (rejected: violates SRP)
2. Scene-based managers (rejected: lose state between scenes)
3. More than 5 singletons (rejected: diminishing returns)

**Impact:**
- Clear boundaries
- Easy to find functionality
- Follows Godot conventions
- Testable architecture

**Made By:** AI Agent (autonomous, following best practices)
**Status:** ✅ Decided, Implemented

---

## 2024-11-05: JSON Save Format (Not Binary)

**Decision:** Use JSON for save files instead of binary format

**Rationale:**
- Human-readable (easy debugging)
- Version migration possible (can parse and upgrade)
- Cross-platform compatible
- Easy to edit for testing
- Standard format

**Alternatives Considered:**
1. Binary format (rejected: hard to debug, version migration complex)
2. SQLite database (rejected: overkill for save data)
3. Godot's built-in Resource (rejected: less portable)

**Impact:**
- Slightly larger file size (acceptable)
- Easy to debug save issues
- Can hand-edit for testing
- Future-proof for updates

**Made By:** AI Agent (autonomous, following best practices)
**Status:** ✅ Decided, Implemented

---

## 2024-11-05: Multiple AI Provider Support

**Decision:** Support Claude, OpenAI, and Ollama (all three)

**Rationale:**
- Educational value (learn multiple APIs)
- User choice (different preferences/budgets)
- Fallback options (if one provider has issues)
- Open source flexibility
- Ollama for privacy/offline

**Alternatives Considered:**
1. Claude only (simpler but less flexible)
2. OpenAI only (most common but less interesting)
3. Add providers incrementally (rejected: better to design for multi-provider from start)

**Impact:**
- More integration complexity
- More testing needed
- More flexible for users
- Better learning experience

**Trade-offs Accepted:**
- 3× the API integration work
- Prompt optimization per provider
- More edge cases to handle

**Made By:** User decision
**Status:** ✅ Decided, Partially Implemented

---

## Template for New Decisions

```markdown
## [Date]: [Decision Title]

**Decision:** [What was decided]

**Rationale:**
- [Why this approach]
- [Key factors]
- [Benefits]

**Alternatives Considered:**
1. [Option A] (rejected: [reason])
2. [Option B] (rejected: [reason])
3. [Option C] (selected: [reason])

**Impact:**
- [What changes]
- [What stays same]
- [Trade-offs]

**Made By:** [User decision / AI recommendation / AI autonomous]
**Status:** ✅ Decided / 🔨 Implementing / ⏸️ Deferred
```

---

## How to Use This Log

**Before making a decision:**
1. Check if we've already decided this
2. Reference the decision and rationale
3. Don't re-litigate unless circumstances changed

**When making a new decision:**
1. Document it here
2. Include rationale and alternatives
3. Note who decided and why

**When circumstances change:**
1. Update the decision status
2. Add a note about why it changed
3. Create new decision entry if significant

---

**AI Agent:** Add new decisions as they're made. Reference existing decisions to avoid rehashing. Update STATUS.md when decisions impact current work.
