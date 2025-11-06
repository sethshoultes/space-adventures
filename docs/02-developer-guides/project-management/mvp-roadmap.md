# Space Adventures - MVP Implementation Roadmap

**Version:** 1.0
**Date:** November 5, 2025
**Timeline:** 6 weeks to MVP
**Goal:** Playable Phase 1 (Earthbound) with core systems

---

## MVP Scope

### What's Included in MVP
✅ All 10 ship systems (3 levels each)
✅ Save/load system
✅ 15+ missions (10 scripted, 5+ AI-generated)
✅ Ship dashboard with schematic view
✅ AI integration (OpenAI + Ollama support)
✅ Phase 1 complete (Earth to launch)
✅ Core UI (workshop, mission select, mission play)
✅ 4-6 hours of gameplay

### What's Deferred to Post-MVP
⏸️ Phase 2 (Space exploration)
⏸️ Advanced graphics/animations
⏸️ Sound effects and music
⏸️ Systems beyond Level 3
⏸️ Complex combat mechanics
⏸️ Multiple endings

---

## Week-by-Week Plan

### **Week 1: Foundation**

#### **Day 1-2: Project Setup**
- [x] Initialize Git repository
- [ ] Create Godot project (4.2+)
- [ ] Set up Python virtual environment
- [ ] Install dependencies (FastAPI, LangChain, etc.)
- [ ] Create project folder structure
- [ ] Set up .env configuration
- [ ] Write README and setup instructions
- [ ] Test Godot ↔ Python communication

**Deliverable:** Empty project structure, both systems communicating

**Files to Create:**
```
godot/project.godot
godot/scenes/test_scene.tscn
python/requirements.txt
python/src/main.py
python/.env.example
README.md
```

#### **Day 3-4: Core Data Systems**
- [ ] Create GameState singleton (GDScript)
- [ ] Implement ShipSystem base class
- [ ] Create data models (Python Pydantic)
- [ ] Write ship_parts.json
- [ ] Implement JSON loading system
- [ ] Test data serialization

**Deliverable:** Game state management working, data loads correctly

**Files to Create:**
```
godot/scripts/autoload/game_state.gd
godot/scripts/systems/ship_system.gd
godot/assets/data/ship_parts.json
python/src/models/game_state.py
python/src/models/ship.py
```

#### **Day 5-7: Save System**
- [ ] Implement SaveManager (GDScript)
- [ ] Create save/load functions
- [ ] Test save file generation
- [ ] Implement save slot management
- [ ] Add save file validation
- [ ] Test save/load roundtrip

**Deliverable:** Can save and load game state to/from JSON

**Files to Create:**
```
godot/scripts/autoload/save_manager.gd
godot/saves/.gitkeep
```

**Test Plan:**
1. Create game state with test data
2. Save to file
3. Load from file
4. Verify all data matches

---

### **Week 2: Ship Systems & Workshop UI**

#### **Day 8-9: Ship System Implementation**
- [ ] Implement Hull system
- [ ] Implement Power system
- [ ] Implement Propulsion system
- [ ] Implement Warp system
- [ ] Test system level progression
- [ ] Test power management

**Deliverable:** 4 core systems working with levels 0-3

**Files to Create:**
```
godot/scripts/systems/hull_system.gd
godot/scripts/systems/power_system.gd
godot/scripts/systems/propulsion_system.gd
godot/scripts/systems/warp_system.gd
```

#### **Day 10-12: Workshop UI**
- [ ] Create workshop scene
- [ ] Implement ship schematic view (ASCII art)
- [ ] Create system status display
- [ ] Add part installation UI
- [ ] Create mission list UI
- [ ] Test UI navigation

**Deliverable:** Workshop hub is functional and navigable

**Files to Create:**
```
godot/scenes/workshop.tscn
godot/scripts/ui/workshop_ui.gd
godot/scripts/ui/schematic_view.gd
godot/assets/fonts/mono_font.ttf
```

**UI Mockup:**
```
┌─────────────────────────────────────────────┐
│  WORKSHOP - Earth Sector 7                  │
├─────────────────────────────────────────────┤
│                                              │
│      [Ship Schematic ASCII Art]              │
│                                              │
│   Systems:              Missions:            │
│   ☐ Hull [====----]     ► First Flight       │
│   ☐ Power [==------]    ► Power Up           │
│   ☐ Propulsion [-]      ☐ Locked            │
│                                              │
│   [Parts] [Missions] [Ship] [Save] [Quit]   │
└─────────────────────────────────────────────┘
```

#### **Day 13-14: Inventory System**
- [ ] Implement inventory management
- [ ] Create part item class
- [ ] Add/remove items from inventory
- [ ] Display inventory UI
- [ ] Test part installation from inventory

**Deliverable:** Can collect and manage ship parts

---

### **Week 3: Mission System**

#### **Day 15-16: Mission Framework**
- [ ] Create Mission base class
- [ ] Implement MissionManager
- [ ] Mission loading from JSON
- [ ] Mission requirement checking
- [ ] Mission state tracking
- [ ] Test mission flow

**Deliverable:** Mission system architecture complete

**Files to Create:**
```
godot/scripts/missions/mission.gd
godot/scripts/missions/mission_manager.gd
godot/scripts/autoload/event_bus.gd
```

#### **Day 17-19: Mission UI**
- [ ] Create mission select scene
- [ ] Create mission play scene
- [ ] Implement choice UI
- [ ] Implement stage progression
- [ ] Add mission completion screen
- [ ] Test full mission playthrough

**Deliverable:** Can play through a complete mission

**Files to Create:**
```
godot/scenes/mission_select.tscn
godot/scenes/mission_play.tscn
godot/scripts/ui/mission_ui.gd
```

#### **Day 20-21: Write Scripted Missions**
- [ ] Write mission_001_inheritance.json (story)
- [ ] Write mission_002_first_flight.json
- [ ] Write mission_003_power_up.json
- [ ] Write mission_004_learning_to_fly.json
- [ ] Write mission_005_the_rival.json (story)
- [ ] Test all missions
- [ ] Balance rewards and difficulty

**Deliverable:** 5 playable scripted missions

**Files to Create:**
```
godot/assets/data/missions/mission_001_inheritance.json
godot/assets/data/missions/mission_002_first_flight.json
... (etc)
```

---

### **Week 4: AI Integration**

#### **Day 22-23: Python AI Service**
- [ ] Set up FastAPI server
- [ ] Create AI client (LangChain)
- [ ] Implement OpenAI integration
- [ ] Implement Ollama integration
- [ ] Test both AI providers
- [ ] Create health check endpoint

**Deliverable:** AI service running and responding

**Files to Create:**
```
python/src/main.py
python/src/ai/client.py
python/src/ai/prompts.py
python/requirements.txt
python/.env
```

**Test:**
```bash
# Start server
python python/src/main.py

# Test endpoint
curl http://localhost:8000/health
```

#### **Day 24-25: Mission Generation**
- [ ] Write mission generation prompt
- [ ] Implement /api/missions/generate endpoint
- [ ] Create response validation
- [ ] Implement fallback system
- [ ] Test mission generation
- [ ] Tune prompt quality

**Deliverable:** AI can generate valid missions

**Files to Create:**
```
python/src/api/missions.py
python/src/models/mission.py
python/tests/test_mission_generation.py
```

#### **Day 26-27: Godot AI Integration**
- [ ] Create AIService singleton (GDScript)
- [ ] Implement HTTP request handling
- [ ] Connect to Python service
- [ ] Test AI mission generation from Godot
- [ ] Add loading indicator
- [ ] Handle errors gracefully

**Deliverable:** Godot can request and receive AI missions

**Files to Create:**
```
godot/scripts/autoload/ai_service.gd
godot/scenes/ui/loading_indicator.tscn
```

#### **Day 28: Response Caching**
- [ ] Implement SQLite cache
- [ ] Add cache invalidation
- [ ] Test cache performance
- [ ] Add cache statistics

**Deliverable:** AI responses are cached and reused

**Files to Create:**
```
python/src/cache/sqlite_cache.py
```

---

### **Week 5: Polish & Content**

#### **Day 29-30: Remaining Systems**
- [ ] Implement Life Support system
- [ ] Implement Computer system
- [ ] Implement Sensors system
- [ ] Implement Shields system
- [ ] Implement Weapons system
- [ ] Implement Communications system
- [ ] Test all 10 systems

**Deliverable:** All 10 ship systems functional

**Files to Create:**
```
godot/scripts/systems/life_support_system.gd
godot/scripts/systems/computer_system.gd
... (etc)
```

#### **Day 31-32: More Scripted Missions**
- [ ] Write missions 6-10
- [ ] Focus on variety (trade, rescue, exploration)
- [ ] Ensure progression unlocks
- [ ] Test mission chains
- [ ] Balance XP and rewards

**Deliverable:** 10 total scripted missions

#### **Day 33-34: Visual Polish**
- [ ] Improve ship schematic visualization
- [ ] Add system icons
- [ ] Create better UI styling
- [ ] Add color-coded status indicators
- [ ] Improve readability
- [ ] Test on different screen sizes

**Deliverable:** UI looks polished and professional

**Files to Create:**
```
godot/assets/sprites/icons/hull_icon.png
godot/assets/sprites/icons/power_icon.png
... (etc)
godot/themes/main_theme.tres
```

#### **Day 35: Tutorial & Onboarding**
- [ ] Create main menu
- [ ] Add new game flow
- [ ] Create tutorial tooltips
- [ ] Write tutorial mission (The Inheritance)
- [ ] Test new player experience

**Deliverable:** New players understand how to play

**Files to Create:**
```
godot/scenes/main_menu.tscn
godot/scripts/ui/tutorial_manager.gd
```

---

### **Week 6: Testing & Finalization**

#### **Day 36-37: Progression Testing**
- [ ] Play through entire Phase 1
- [ ] Test all 10 systems unlock correctly
- [ ] Verify launch requirements work
- [ ] Test save/load at various points
- [ ] Check for softlocks
- [ ] Balance difficulty curve

**Deliverable:** Complete progression tested and balanced

#### **Day 38-39: Bug Fixing**
- [ ] Fix critical bugs
- [ ] Fix UI issues
- [ ] Improve error handling
- [ ] Polish edge cases
- [ ] Test on multiple platforms

**Deliverable:** Stable, bug-free experience

#### **Day 40-41: AI Content Testing**
- [ ] Generate 20 AI missions
- [ ] Review quality
- [ ] Tune prompts if needed
- [ ] Test AI mission variety
- [ ] Ensure AI missions are beatable

**Deliverable:** AI-generated content is high quality

#### **Day 42: Final Polish & Documentation**
- [ ] Write player-facing README
- [ ] Create setup instructions
- [ ] Add in-game credits
- [ ] Final playtesting session
- [ ] Create build for distribution (optional)

**Deliverable:** MVP ready to share!

---

## Implementation Checklist

### Core Features
- [ ] 10 ship systems with 3 levels each
- [ ] Save/load system
- [ ] Workshop hub
- [ ] Ship schematic visualization
- [ ] Inventory management
- [ ] Mission system (select, play, complete)
- [ ] 10 scripted missions
- [ ] AI mission generation (5+ missions)
- [ ] AI service (OpenAI + Ollama)
- [ ] XP and leveling system
- [ ] Skill system (Engineering, Diplomacy, Combat, Science)
- [ ] Launch requirements gate

### UI Screens
- [ ] Main menu
- [ ] Workshop/Hub
- [ ] Mission select
- [ ] Mission play
- [ ] Ship status/schematic
- [ ] Inventory
- [ ] Save/load menu
- [ ] Settings

### Polish
- [ ] Tutorial/first mission
- [ ] Visual polish (icons, colors, styling)
- [ ] Error handling
- [ ] Loading indicators
- [ ] Keyboard shortcuts
- [ ] Controller support (optional)

---

## Testing Strategy

### Unit Tests (Python)
```python
# python/tests/test_ai.py
def test_mission_generation():
    """Test that AI generates valid missions"""
    pass

def test_cache_system():
    """Test response caching"""
    pass

def test_validation():
    """Test mission schema validation"""
    pass
```

### Integration Tests
- [ ] Test Godot → Python communication
- [ ] Test save/load roundtrip
- [ ] Test mission flow end-to-end
- [ ] Test AI generation pipeline

### Manual Playtesting
- [ ] Complete playthrough (record time)
- [ ] Test all choices in each mission
- [ ] Try to break the game (softlock testing)
- [ ] Test with different builds (high Engineering vs. Combat)

---

## Development Guidelines

### Git Workflow
```bash
# Feature branches
git checkout -b feature/ship-systems
git checkout -b feature/mission-framework
git checkout -b feature/ai-integration

# Commit often
git commit -m "feat: Add hull system implementation"
git commit -m "fix: Save file not loading correctly"
git commit -m "docs: Update ship systems spec"

# Merge to main when feature is complete and tested
git checkout main
git merge feature/ship-systems
```

### Code Standards

**GDScript:**
- Use snake_case for variables and functions
- Use PascalCase for classes
- Add type hints: `var health: int = 100`
- Comment complex logic
- Keep functions under 50 lines

**Python:**
- Follow PEP 8
- Use type hints
- Write docstrings for all functions
- Keep functions pure when possible
- Test all API endpoints

### Daily Development Routine
1. **Review** yesterday's work
2. **Plan** today's tasks (2-3 specific goals)
3. **Implement** features
4. **Test** as you go
5. **Commit** working code
6. **Document** any design decisions

---

## Milestone Markers

### Week 1 Milestone: "Foundation Complete"
✅ Project structure exists
✅ Godot and Python communicate
✅ Save/load system works
✅ Game state management functional

**Demo:** Show saving/loading game state

---

### Week 2 Milestone: "Ship Systems Online"
✅ All 10 ship systems implemented
✅ Workshop UI functional
✅ Can install parts and see ship grow

**Demo:** Install parts, show ship schematic updating

---

### Week 3 Milestone: "Missions Playable"
✅ Mission system complete
✅ 5 scripted missions written
✅ Can play through a full mission

**Demo:** Complete a mission end-to-end

---

### Week 4 Milestone: "AI Integration"
✅ Python AI service running
✅ AI can generate missions
✅ Godot can request AI content
✅ Response caching works

**Demo:** Generate and play an AI mission

---

### Week 5 Milestone: "Content Complete"
✅ All systems implemented
✅ 10 scripted missions
✅ AI generates varied content
✅ Visual polish applied

**Demo:** Show variety of content and polish

---

### Week 6 Milestone: "MVP READY"
✅ Full Phase 1 playable (4-6 hours)
✅ All features functional
✅ Tested and balanced
✅ Bugs fixed
✅ Ready to share

**Demo:** Full playthrough from start to launch

---

## Risk Management

### High Risk Items

| Risk | Impact | Mitigation | Status |
|------|--------|------------|--------|
| AI quality too low | High | Use GPT-4, tune prompts, fallbacks | ⚠️ Monitor |
| Scope creep | High | Stick to MVP, defer Phase 2 | ⚠️ Strict |
| Godot-Python communication issues | Medium | Test early, use simple REST | ✅ Tested |
| Save file corruption | Medium | Validation, versioning, backups | ⏳ Pending |
| Performance issues | Low | Profile early, optimize later | ⏳ Pending |

### Contingency Plans

**If AI isn't working by Week 4:**
- Use only scripted missions (write 20 instead of 10)
- Add simple randomization to scripted content
- Defer AI to post-MVP

**If behind schedule by Week 4:**
- Reduce scripted missions to 8
- Reduce system levels to 2 per system
- Defer polish to post-MVP

**If behind schedule by Week 5:**
- Cut visual polish
- Focus on core functionality only
- Release "bare bones" MVP, polish in v1.1

---

## Post-MVP Roadmap (Future)

### Version 1.1 (Weeks 7-9)
- [ ] Phase 2: Space Exploration (5 star systems)
- [ ] Basic combat system
- [ ] 20 space encounters
- [ ] Ship upgrades to Level 4-5

### Version 1.2 (Weeks 10-12)
- [ ] Advanced graphics
- [ ] Sound effects and music
- [ ] More alien species
- [ ] 10 more star systems
- [ ] Multiple endings

### Version 2.0 (Months 4-6)
- [ ] Full galaxy (50+ systems)
- [ ] Crew system
- [ ] Ship customization (aesthetics)
- [ ] New Game+
- [ ] Mod support

---

## Success Criteria

### MVP is considered successful if:
✅ Phase 1 is completable (all 10 systems to L1)
✅ 4-6 hours of engaging gameplay
✅ AI generates quality content 70%+ of the time
✅ Save/load works reliably
✅ No critical bugs or softlocks
✅ Players understand the mechanics
✅ Player choices feel meaningful

### MVP is considered EXCELLENT if:
🌟 8+ hours of content
🌟 Players want to replay with different choices
🌟 AI content is indistinguishable from scripted
🌟 UI is polished and intuitive
🌟 Performance is smooth on modest hardware
🌟 Players ask for Phase 2

---

## Resources Needed

### Software
- Godot Engine 4.2+ (free)
- Python 3.10+ (free)
- VS Code or similar (free)
- Git (free)

### Hardware
- Development machine (any modern laptop)
- For Ollama: 16GB+ RAM, 8GB+ VRAM recommended

### Services
- OpenAI API key (optional, ~$5-10 for testing)
- GitHub for version control (free)

### Time
- **Solo development:** 6 weeks full-time OR 12 weeks part-time
- **With AI assistance:** Same timeline, but with code help

---

**Document Status:** Complete v1.0
**Last Updated:** November 5, 2025
**Estimated MVP Delivery:** Week 6 (Day 42)

Good luck! You've got this. 🚀
