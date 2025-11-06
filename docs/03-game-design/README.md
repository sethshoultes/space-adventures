# Game Design Documentation

**Purpose:** Complete game design specifications, mechanics, and systems.

## Directory Structure

### [core-systems/](./core-systems/)
Fundamental game mechanics and progression systems.

### [ship-systems/](./ship-systems/)
The 10 core ship systems and ship classification.

### [content-systems/](./content-systems/)
Mission framework and crew management.

### [future-features/](./future-features/)
Planned features and enhancements for future development phases.

## Overview

This directory contains all game design documentation for Space Adventures. It defines the rules, mechanics, and content structure that make up the game experience.

## Quick Navigation

### Core Game Mechanics
- **[Game Design Document](./core-systems/game-design-document.md)** - Core game loop and vision
- **[Player Progression](./core-systems/player-progression-system.md)** - XP, levels, ranks, skills
- **[Resources & Survival](./core-systems/resources-survival.md)** - Resource mechanics

### Ship Systems
- **[Ship Systems](./ship-systems/ship-systems.md)** - 10 core systems (levels 0-5)
- **[Ship Classification](./ship-systems/ship-classification-system.md)** - 10 ship classes
- **[Ship Documentation](./ship-systems/ship-documentation.md)** - Complete specifications

### Content & Missions
- **[Mission Framework](./content-systems/mission-framework.md)** - Mission structure and types
- **[Crew System](./content-systems/crew-companion-system.md)** - Crew management

### Future Features
- **[Future Features Index](./future-features/)** - Planned enhancements and future phases
- **[Captain's Log](./future-features/feature-captains-log.md)** - AI-powered journey journal (Phase 1 Extension)
- **[Ship Personality](./future-features/feature-ship-personality.md)** - Evolving AI companion (Phase 1 Extension)
- **[First Contact Protocol](./future-features/feature-first-contact-protocol.md)** - Alien diplomacy (Phase 2)
- **[Feature Backlog](./future-features/feature-backlog.md)** - Unprioritized ideas

## Game Overview

### Core Concept
A narrative-driven space adventure where players:
1. **Phase 1:** Scavenge post-exodus Earth for ship parts
2. **Build:** Construct starship system by system
3. **Phase 2:** Launch into space and explore the galaxy
4. **Experience:** AI-powered dynamic narrative

### Design Pillars

**1. Meaningful Choices**
- Every decision has consequences
- No "correct" path - multiple valid approaches
- Choices affect story, relationships, and ship capabilities

**2. Progressive Building**
- Start with broken ship systems
- Gradually unlock and upgrade
- Ship grows with player skill

**3. Narrative Focus**
- 60% scripted content (quality story)
- 40% AI-generated (variety and replayability)
- Star Trek TNG tone: serious, hopeful, ethical

**4. Exploration & Discovery**
- Uncover Earth's history
- Discover alien technologies
- Build relationships with AI personalities

## The 10 Ship Systems

1. **Hull** - Ship integrity and HP
2. **Power Core** - Energy generation
3. **Propulsion** - Sub-light engines
4. **Warp Drive** - FTL travel (required for space)
5. **Life Support** - Crew survival
6. **Computer Core** - AI assistance
7. **Sensors** - Detection and scanning
8. **Shields** - Damage mitigation
9. **Weapons** - Combat capability
10. **Communications** - Long-range comms

**Each system:** Levels 0-5, unique mechanics, power consumption

## Ship Classes

Based on system configuration:
1. Scout - Fast, minimal systems
2. Courier - Transport focus
3. Frigate - Balanced combat
4. Science Vessel - Research focus
5. Destroyer - Heavy combat
6. Cruiser - All-around capable
7. Heavy Cruiser - Advanced multi-role
8. Explorer - Long-range exploration
9. Dreadnought - Maximum combat
10. Support Vessel - Specialized support

## Mission Types

1. **Salvage** - Recover ship parts
2. **Exploration** - Discover locations
3. **Trade** - Exchange resources
4. **Rescue** - Help others
5. **Combat** - Tactical engagement
6. **Story** - Narrative-driven

## Progression Systems

**Player:**
- XP from missions and discoveries
- 10 levels (Cadet to Admiral)
- 4 skills (Engineering, Diplomacy, Combat, Science)
- Rank promotions

**Ship:**
- System upgrades (Level 0 → 5)
- Power management
- Ship class determination
- Cosmetic customization

**Story:**
- Phase 1: Earth salvage operations
- Transition: Achieve Level 1 in all systems
- Phase 2: Space exploration

## Related Documentation

- **Architecture:** [../02-developer-guides/architecture/technical-architecture.md](../02-developer-guides/architecture/technical-architecture.md)
- **AI Integration:** [../05-ai-content/ai-integration.md](../05-ai-content/ai-integration.md)
- **Testing:** [../01-user-guides/testing/TESTING-GUIDE.md](../01-user-guides/testing/TESTING-GUIDE.md)

## For Developers

**Implementing game systems:**
1. Read relevant design document
2. Understand mechanics and formulas
3. Implement in Godot (GDScript)
4. Test thoroughly
5. Balance and tune

**Adding content:**
1. Follow mission framework
2. Use AI integration for variety
3. Maintain Star Trek TNG tone
4. Test all paths and choices

## For Designers

**Creating missions:**
1. Review mission-framework.md
2. Use standard JSON schema
3. Balance difficulty and rewards
4. Test all choice paths
5. Integrate with progression

**Balancing systems:**
1. Review ship-systems.md formulas
2. Test edge cases
3. Ensure progression feels good
4. Adjust power costs if needed

---

**Navigation:**
- [📚 Documentation Index](../README.md)
- [🤖 AI Agent Context](../CLAUDE.md)
- [🎮 Project Root](../../)
