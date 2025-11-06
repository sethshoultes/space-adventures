# Architecture & Design Patterns Lessons

**Lessons learned about software architecture, design patterns, and system design decisions.**

---

## 2024-11-06: When Microservices Make Sense (And When They Don't)

**Context:** Designing architecture for single-player narrative game with AI generation.

**Problem:** Microservices are trendy, but are they appropriate for a single-player game that runs locally? What's the right trade-off?

**Solution:** For this project, microservices make sense **as a learning exercise**, not for technical requirements.

**Technical Reality:**
```
❌ What microservices DON'T provide here:
- Independent scaling (single player = no scaling needed)
- Team independence (solo developer)
- Technology diversity (all Python anyway)
- Fault isolation (if one service down, game breaks)
- Deploy independence (Docker Compose deploys all together)

✅ What microservices DO provide here:
- **Learning experience** (marketable skill)
- Clean separation of concerns
- Portfolio demonstration piece
- Real-world pattern practice
- Easier to explain in interviews
```

**The Decision:**
```markdown
For commercial product: ❌ Overkill, use monolith
For hobby/learning: ✅ Perfect, teaches valuable patterns
```

**Architecture:**
```
Gateway (17010) - Request routing, health aggregation
    ↓
AI Service (17011) - Content generation, caching
    ↓
Redis (17014) - Response caching (24h TTL)

Optional:
Whisper Service (17012) - Voice transcription
```

**Why This Matters:**
- **Honest assessment:** Recognize when pattern is educational vs optimal
- **Learning value:** Microservices teach distributed systems concepts
- **Portfolio:** Shows understanding of architecture trade-offs
- **Interviews:** Can discuss "when would you NOT use microservices?"

**When to Use Microservices:**
- Large teams (multiple teams, independent work)
- Different technologies (Python + Go + Java)
- Independent scaling needs (some services need 100× capacity)
- Independent deployment (teams ship on own schedule)
- Fault isolation critical (service failure doesn't cascade)

**When to Use Monolith:**
- Small team (1-5 developers)
- Simple domain (CRUD app, basic workflow)
- Tight coupling (features need same data)
- Performance critical (network calls add latency)
- **Hobby project where speed > architecture** (most cases!)

**Key Insight:**
> "Perfect architecture for wrong reason is still wrong. This project uses microservices for learning, not because it's technically optimal. That's OK if you're honest about it."

**Resources:**
- Martin Fowler on Microservices: https://martinfowler.com/articles/microservices.html
- When NOT to use microservices: https://www.youtube.com/watch?v=y8OnoxKotPQ

**Related Patterns:** Monolithic architecture, distributed systems, trade-off analysis

---

## 2024-11-05: SOLID Principles in Practice - GameState Example

**Context:** Designing Godot singletons for game state management.

**Problem:** Initial design had GameState doing everything: storing data, calculating power, managing upgrades, saving/loading. 800+ line god object violating every SOLID principle.

**Solution:** Apply SOLID principles to break into focused classes.

**Single Responsibility Principle (SRP):**
```gdscript
# ❌ BAD - GameState does everything
class_name GameState
var player: Dictionary
var ship: Dictionary

func calculate_total_power() -> int: ...  # ❌ Calculation logic
func save_game(slot: int): ...            # ❌ Persistence logic
func upgrade_system(name: String): ...    # ❌ Game logic
func render_ship_ui(): ...                # ❌ UI logic

# ✅ GOOD - Each class has ONE reason to change
# GameState.gd - Only stores data
var player: Dictionary
var ship: Dictionary
func to_dict() -> Dictionary: return {"player": player, "ship": ship}

# PowerCalculator.gd - Only calculates power
static func calculate_total_power(systems: Dictionary) -> int: ...

# SaveManager.gd - Only handles persistence
func save_game(slot: int): ...
func load_game(slot: int): ...

# SystemManager.gd - Only handles system upgrades
func upgrade_system(name: String) -> bool: ...
func can_upgrade(name: String) -> bool: ...
```

**Open/Closed Principle (OCP):**
```gdscript
# ✅ Open for extension, closed for modification
class_name ShipSystem
var level: int
var health: int

func get_power_cost() -> int:
    return 0  # Override in subclass

# Extend, don't modify
class_name WarpSystem extends ShipSystem
func get_power_cost() -> int:
    return [20, 30, 50, 80, 120][level]

# Add new system types without changing base class
class_name SensorSystem extends ShipSystem
func get_power_cost() -> int:
    return [15, 25, 40, 60, 90][level]
```

**Liskov Substitution Principle (LSP):**
```gdscript
# Any ShipSystem subclass works here
func install_system(system: ShipSystem) -> void:
    system.health = 100
    system.active = true
    GameState.ship.systems[system.name] = system
    EventBus.system_installed.emit(system.name)

# Works for HullSystem, PowerSystem, WarpSystem, etc.
install_system(HullSystem.new())
install_system(WarpSystem.new())
```

**Interface Segregation Principle (ISP):**
```gdscript
# ❌ BAD - Fat interface
class_name ShipSystem
func upgrade(): pass
func repair(): pass
func take_damage(amount: int): pass
func fire_weapons(): pass  # ❌ Only WeaponSystem needs this
func scan(): pass          # ❌ Only SensorSystem needs this

# ✅ GOOD - Small, focused interfaces
class_name Upgradeable
func upgrade() -> bool: pass
func can_upgrade() -> bool: pass

class_name Damageable
func take_damage(amount: int): pass
func repair(amount: int): pass

# Systems implement only what they need
class_name HullSystem extends ShipSystem, Damageable
# Has take_damage/repair, but NOT fire_weapons

class_name WeaponSystem extends ShipSystem, Damageable
# Has take_damage/repair AND fire_weapons
```

**Dependency Inversion Principle (DIP):**
```python
# ❌ BAD - Depends on concrete class
class ContentGenerator:
    def __init__(self):
        self.client = OpenAI(api_key=...)  # ❌ Tightly coupled

# ✅ GOOD - Depends on abstraction
class ContentGenerator:
    def __init__(self, provider: AIProvider):  # Abstract interface
        self.provider = provider  # Can be OpenAI, Claude, Ollama

# Usage
provider = create_provider(config)  # Factory decides concrete type
generator = ContentGenerator(provider)
```

**Why This Matters:**
- **Maintainability:** Changes isolated to single class
- **Testability:** Mock interfaces, test in isolation
- **Extensibility:** Add features without modifying existing code
- **Readability:** Each class has clear, focused purpose

**When to Apply:**
- Always for classes > 200 lines
- When class has multiple reasons to change
- When adding features requires modifying existing code
- When testing requires mocking complex dependencies

**When NOT to Over-Apply:**
- Don't create abstraction until you need it (YAGNI)
- Don't split 50-line classes unnecessarily
- Don't create interfaces for single implementation
- Balance: principles guide, don't dictate

**Resources:**
- SOLID Principles: https://en.wikipedia.org/wiki/SOLID
- Robert C. Martin (Uncle Bob) Clean Code
- Refactoring Guru: https://refactoring.guru/design-patterns

**Related Patterns:** Separation of concerns, design patterns, clean architecture

---

## Template for New Lessons

```markdown
## [Date]: [Lesson Title]

**Context:** [What were you building?]

**Problem:** [What architectural challenge did you face?]

**Solution:** [What pattern or principle did you apply?]

**Code Example:**
```gdscript/python
# Show the pattern with actual code
```

**Why This Matters:** [Why should future-you care?]

**When to Apply:** [Situations where this pattern fits]

**When NOT to Apply:** [Situations where simpler approach is better]

**Resources:** [Links to articles, books, etc.]

**Related Patterns:** [Cross-references]
```

---

## Topics to Document (As We Learn)

**Design Patterns:**
- [ ] Singleton (autoload) - when appropriate
- [ ] Factory pattern - creating systems
- [ ] Strategy pattern - AI providers
- [ ] Observer pattern - EventBus
- [ ] State pattern - game states
- [ ] Command pattern - undo/redo

**Architecture Patterns:**
- [ ] Layered architecture (UI → Logic → Data)
- [ ] Event-driven architecture
- [ ] API design (REST principles)
- [ ] Separation of concerns
- [ ] Domain-driven design concepts

**SOLID in Practice:**
- [ ] Refactoring examples (before/after)
- [ ] When to stop refactoring (good enough)
- [ ] Balancing SOLID with YAGNI
- [ ] Code review checklist for SOLID

**System Design:**
- [ ] Caching strategies and trade-offs
- [ ] Error handling patterns
- [ ] Logging and debugging strategies
- [ ] Performance optimization patterns
- [ ] Scalability considerations

**Testing Strategies:**
- [ ] Unit test patterns
- [ ] Integration test patterns
- [ ] Mocking strategies
- [ ] Test data management
- [ ] When manual testing is appropriate

**Decision-Making:**
- [ ] How to evaluate trade-offs
- [ ] When to choose simple over perfect
- [ ] Premature optimization examples
- [ ] Technical debt management

---

**AI Agent:** Add lessons here as you make architectural decisions, apply design patterns, or refactor code. Focus on the "why" behind decisions, not just the "what."
