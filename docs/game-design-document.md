# Space Adventures - Game Design Document

**Version:** 1.0
**Date:** November 5, 2025
**Genre:** Narrative Space Adventure / Ship Building RPG
**Platform:** Desktop (Windows/Linux/Mac via Godot)
**Tone:** Serious Sci-Fi (Star Trek TNG inspired)

---

## Table of Contents
1. [High Concept](#high-concept)
2. [Core Gameplay Loop](#core-gameplay-loop)
3. [Game Phases](#game-phases)
4. [Ship Systems](#ship-systems)
5. [Progression System](#progression-system)
6. [Narrative Structure](#narrative-structure)
7. [AI Integration](#ai-integration)
8. [User Interface](#user-interface)
9. [Art Direction](#art-direction)

---

## High Concept

**Elevator Pitch:**
*"A narrative-driven space adventure where you scavenge Earth for parts to build your own starship, system by system. Once complete, embark on an AI-powered, choose-your-own-adventure journey through the cosmos, facing ethical dilemmas, alien encounters, and the unknown."*

**Core Pillars:**
1. **Meaningful Choices** - Every decision matters, both in ship design and narrative
2. **Discovery** - Uncover parts, stories, and mysteries
3. **Progression** - Build your ship from nothing to a complete vessel
4. **AI-Powered Narrative** - Dynamic storytelling that responds to player choices

---

## Core Gameplay Loop

### Phase 1: Earthbound (Ship Building)
```
Receive Mission → Explore Location → Complete Objective →
Earn Ship Part → Install Part → Unlock New Systems/Missions → Repeat
```

### Phase 2: Space Exploration
```
Receive Situation (AI-generated) → Make Choice →
See Consequences → Ship Systems React → Continue Journey
```

---

## Game Phases

### **Phase 1: Earthbound Salvage** (Estimated 8-12 hours)

**Setting:** Post-exodus Earth, 2247 AD. Most of humanity has left for the colonies. You're a skilled engineer determined to follow them, but you need to build a ship first.

**Gameplay:**
- **Hub:** Your workshop/hangar where you assemble the ship
- **Missions:** Text-based scenarios with choices (some AI-generated)
- **Locations:** Abandoned spaceports, military facilities, research stations, etc.
- **Challenges:** Puzzles, resource management, ethical choices

**Ship Systems to Build (10 Core Systems):**
1. Hull & Structure
2. Power Core (Reactor)
3. Propulsion (Impulse Engines)
4. Warp Drive
5. Life Support
6. Computer Core
7. Sensors
8. Shields
9. Weapons
10. Communication Array

**Progression Gate:**
All 10 core systems must reach Level 1 (functional) to leave Earth.

---

### **Phase 2: Space Adventure** (Estimated 12-20 hours)

**Setting:** The galaxy - multiple star systems, each with unique characteristics, civilizations, and challenges.

**Gameplay:**
- **Navigation:** Choose destinations on a star map
- **Encounters:** AI-generated situations based on location and ship capabilities
- **Ship Management:** Monitor and upgrade systems
- **Consequences:** Choices affect ship condition, resources, reputation

**Encounter Types:**
- **Exploration:** Scan anomalies, discover new phenomena
- **Diplomacy:** First contact scenarios, negotiations
- **Combat:** Strategic ship-to-ship battles (turn-based)
- **Rescue:** Distress calls, emergency situations
- **Mystery:** Investigate strange occurrences
- **Ethical Dilemmas:** Hard choices with no "right" answer

---

## Ship Systems

### System Levels
Each ship system has **5 levels** of quality:

| Level | Quality | Description |
|-------|---------|-------------|
| 0 | Not Installed | System doesn't exist |
| 1 | Functional | Basic operation, unreliable |
| 2 | Standard | Stable performance |
| 3 | Advanced | Enhanced capabilities |
| 4 | Superior | Military-grade |
| 5 | Prototype | Experimental, cutting-edge |

### System Details

#### **1. Hull & Structure**
- **Purpose:** Ship integrity, damage resistance
- **Affects:** Health points, armor rating
- **Levels:**
  - L1: Salvaged hull plates (50 HP)
  - L2: Reinforced structure (100 HP)
  - L3: Composite armor (200 HP)
  - L4: Ablative plating (350 HP)
  - L5: Regenerative hull (500 HP + slow repair)

#### **2. Power Core**
- **Purpose:** Energy generation for all systems
- **Affects:** Available power, system efficiency
- **Levels:**
  - L1: Fusion cell (100 power units)
  - L2: Deuterium reactor (200 PU)
  - L3: Matter/antimatter core (400 PU)
  - L4: Advanced M/AM reactor (700 PU)
  - L5: Zero-point energy (1000 PU + regeneration)

#### **3. Propulsion (Impulse)**
- **Purpose:** Sub-light travel, maneuverability
- **Affects:** Combat dodge, system navigation speed
- **Levels:**
  - L1: Chemical thrusters (slow)
  - L2: Ion drive (standard)
  - L3: Plasma engine (fast)
  - L4: Gravitic drive (very fast + agile)
  - L5: Inertial dampener (instant maneuvers)

#### **4. Warp Drive**
- **Purpose:** Faster-than-light travel between star systems
- **Affects:** Travel time, fuel efficiency, max range
- **Levels:**
  - L1: Warp 1 (1x light speed, nearby systems only)
  - L2: Warp 3 (9x light speed, adjacent sectors)
  - L3: Warp 5 (125x light speed, most of galaxy)
  - L4: Warp 7 (343x light speed, rapid travel)
  - L5: Warp 9 (729x light speed + transwarp corridors)

#### **5. Life Support**
- **Purpose:** Crew survival, environmental control
- **Affects:** Max crew, emergency duration, radiation protection
- **Levels:**
  - L1: Basic oxygen recycling (1 crew, 24hr emergency)
  - L2: Climate control (4 crew, 1 week)
  - L3: Advanced bio-recycling (10 crew, 1 month)
  - L4: Closed-loop system (25 crew, 6 months)
  - L5: Bio-dome (50 crew, indefinite + food production)

#### **6. Computer Core**
- **Purpose:** Ship automation, data processing, AI assistance
- **Affects:** Sensor analysis, combat targeting, auto-repair
- **Levels:**
  - L1: Basic computer (manual controls)
  - L2: Standard AI (targeting assist)
  - L3: Advanced AI (recommendations, predictions)
  - L4: Tactical AI (combat automation, optimal solutions)
  - L5: Sentient AI (companion, creative problem-solving)

#### **7. Sensors**
- **Purpose:** Detection, scanning, awareness
- **Affects:** Encounter detection range, scan quality, threat warning
- **Levels:**
  - L1: Optical sensors (short range, basic data)
  - L2: EM spectrum (medium range, composition scans)
  - L3: Subspace array (long range, detailed analysis)
  - L4: Multi-phasic sensors (very long range, cloaked ships)
  - L5: Quantum sensors (predict trajectories, hidden dangers)

#### **8. Shields**
- **Purpose:** Defense against energy weapons, radiation, impacts
- **Affects:** Damage reduction, hazard protection
- **Levels:**
  - L1: Deflector screens (25% reduction)
  - L2: Standard shields (50% reduction)
  - L3: Multi-layered shields (70% + recharge)
  - L4: Adaptive shields (85% + resist specific damage)
  - L5: Phase shields (95% + chance to deflect completely)

#### **9. Weapons**
- **Purpose:** Combat, defense, asteroid clearing
- **Affects:** Damage output, targeting options
- **Levels:**
  - L1: Laser cannon (low damage)
  - L2: Phaser array (medium damage, precise)
  - L3: Photon torpedoes (high damage, limited ammo)
  - L4: Quantum torpedoes + pulse phasers (very high damage)
  - L5: Experimental weapons (devastating + special effects)

#### **10. Communication Array**
- **Purpose:** Long-range communication, translation, diplomacy
- **Affects:** Diplomatic options, distress call range, information access
- **Levels:**
  - L1: Radio transceiver (short range, limited)
  - L2: Subspace radio (system-wide)
  - L3: Universal translator (galaxy-wide, alien languages)
  - L4: Quantum entanglement (instant, unlimited range)
  - L5: Psionic amplifier (telepathic species, emotion sensing)

---

## Progression System

### Experience & Leveling
**Player Level:** Separate from ship systems. Earned through:
- Completing missions (+50-200 XP)
- Making meaningful choices (+25 XP)
- Discovering new locations (+100 XP)
- Surviving encounters (+variable)

**Level Benefits:**
- Unlock new mission types
- Improve personal skills (Engineering, Diplomacy, Combat, Science)
- Gain narrative options (persuasion, technical solutions)

### Ship Parts & Upgrades

**Part Rarity:**
- **Common** (White): Basic functionality
- **Uncommon** (Green): Improved stats
- **Rare** (Blue): Special bonuses
- **Epic** (Purple): Unique abilities
- **Legendary** (Orange): Game-changing effects

**Installation Time:**
- Parts take in-game time to install (creates pacing)
- Can play "installation mini-games" or skip with time passage

---

## Narrative Structure

### Earthbound Narrative Arc
**Setup:** You inherit your parent's workshop and their dream of reaching the colonies.

**Key Story Beats:**
1. **The Inheritance** - Discover your parent's plans and partially-built ship frame
2. **First Flight** - Install basic systems and hover for the first time
3. **The Rival** - Another scavenger competing for the same parts
4. **Moral Choice** - Help others vs. prioritize your ship
5. **The Secret** - Discover why Earth was really abandoned
6. **Final Preparation** - Install the last system and say goodbye to Earth

### Space Narrative Arc
**Setup:** The galaxy is vast, and you're a tiny ship in an enormous universe.

**Key Story Beats:**
1. **First Jump** - The wonder and terror of warp travel
2. **First Contact** - Meet an alien species
3. **The Message** - Receive a mysterious signal from deep space
4. **Faction Conflict** - Choose sides or remain neutral
5. **The Anomaly** - Encounter something that defies explanation
6. **The Choice** - Major decision affecting the galaxy's future
7. **Endgame** - Multiple possible endings based on choices

### Dynamic Story Elements (AI-Generated)
- **Random Encounters:** 60% of space encounters are AI-generated
- **Character Dialogues:** NPCs respond dynamically to player choices
- **Consequence Chains:** AI tracks decisions and creates callbacks
- **Emergent Narratives:** Player's ship configuration affects story options

---

## AI Integration

### AI Roles
1. **Mission Generator:** Create varied salvage missions on Earth
2. **Encounter Designer:** Generate space scenarios
3. **Dialogue System:** NPC conversations and responses
4. **Consequence Engine:** Track choices and create story coherence
5. **Description Writer:** Location and event descriptions

### AI Context Management
The AI maintains awareness of:
- Current ship systems and their levels
- Player's previous major choices
- Current location and situation
- Available resources
- Active questlines

### Fallback System
- Critical story moments use pre-written content
- AI-generated content is cached and can be regenerated
- Player can "reroll" AI responses if needed (limited uses)

---

## User Interface

### Main Screens

#### **1. Workshop/Hangar (Phase 1 Hub)**
```
┌─────────────────────────────────────────────────┐
│  WORKSHOP - Earth Sector 7                      │
├─────────────────────────────────────────────────┤
│                                                  │
│      [Ship Schematic - Visual Display]          │
│                                                  │
│   Systems:                    Missions:          │
│   □ Hull [====----] 60%       ► Salvage Run     │
│   □ Power [===-----] 40%      ► Old Research    │
│   ☑ Propulsion [==========]   □ Locked          │
│   ...                                            │
│                                                  │
│   [Install Part] [View Missions] [Ship Status]  │
└─────────────────────────────────────────────────┘
```

#### **2. Ship Dashboard (Phase 2 Main Screen)**
```
┌─────────────────────────────────────────────────┐
│  U.S.S. [Player Name] - Sector Delta-4          │
├───────────────┬─────────────────────────────────┤
│   SYSTEMS     │     MAIN VIEW                   │
│               │                                  │
│ ⚡ Power: 85% │   [Star Map / Encounter View]   │
│ 🛡 Shields:90%│                                  │
│ ❤️ Hull: 100% │   Current Situation:            │
│ 🔧 All Good   │   "You detect a distress..."    │
│               │                                  │
│   CREW: 4/10  │   [Choice 1: Investigate]       │
│   FUEL: 65%   │   [Choice 2: Ignore]            │
│               │   [Choice 3: Scan First]        │
├───────────────┴─────────────────────────────────┤
│  [Navigation] [Sensors] [Engineering] [Log]     │
└─────────────────────────────────────────────────┘
```

#### **3. Mission Screen**
```
┌─────────────────────────────────────────────────┐
│  MISSION: Salvage Run - Abandoned Spaceport     │
├─────────────────────────────────────────────────┤
│                                                  │
│  Location: Kennedy Spaceport Ruins              │
│  Objective: Retrieve Warp Coil                  │
│  Difficulty: ★★☆☆☆                              │
│  Reward: Warp Drive Component (Rare)            │
│                                                  │
│  Description:                                    │
│  "The old spaceport sits silent, its launch     │
│   pads empty for decades. Sensors indicate      │
│   abandoned ships in Hangar 7..."               │
│                                                  │
│  Your Approach:                                  │
│  ○ Cautious - Scan first, slower but safer      │
│  ○ Direct - Head straight for the hangar        │
│  ○ Technical - Hack security, avoid patrols     │
│                                                  │
│  [Accept Mission] [Back]                        │
└─────────────────────────────────────────────────┘
```

#### **4. Ship Schematic View**
```
       ┌─────────────────────┐
       │    COMMUNICATION    │ L3
       └──────────┬──────────┘
                  │
      ┌───────────┴───────────┐
      │      SENSORS L4       │
      └───────────┬───────────┘
                  │
    ┌─────────────┴─────────────┐
    │       BRIDGE/CORE         │
    │      Computer: L3         │
    └─┬──────────────────────┬──┘
      │                      │
 ┌────┴────┐            ┌───┴────┐
 │ SHIELDS │            │WEAPONS │
 │   L3    │            │  L2    │
 └────┬────┘            └───┬────┘
      │                    │
 ┌────┴────────────────────┴────┐
 │       HULL & POWER CORE      │
 │    Hull: L2    Power: L3     │
 └─┬──────────────────────────┬─┘
   │                          │
┌──┴──┐                    ┌──┴──┐
│WARP │                    │ IMP │
│ L2  │                    │ L3  │
└─────┘                    └─────┘
   └──────┬────────┬──────┘
      ┌───┴────────┴───┐
      │  LIFE SUPPORT  │ L2
      └────────────────┘

[Color coded by system health/level]
```

---

## Art Direction

### Visual Style
**Mixed Approach:**
- **Schematic/Blueprint UI:** Clean, technical, Star Trek LCARS-inspired
- **ASCII Art:** For ship schematics and certain UI elements
- **Simple 2D Sprites:** Ships, items, portraits (pixel art style)
- **Color Palette:**
  - Primary: Deep space blue (#0A1128)
  - Accent: Console cyan (#00D9FF)
  - Warning: Alert orange (#FF6B35)
  - Success: System green (#52B788)
  - Neutral: Steel gray (#6C757D)

### UI Elements
- **Typography:** Monospace fonts for data, clean sans-serif for dialogue
- **Icons:** Simple, recognizable symbols for each system
- **Animations:** Minimal but meaningful (pulsing systems, scanning effects)
- **Accessibility:** High contrast, colorblind-friendly indicators

### Ship Visualization
- **Multiple Views:**
  - Schematic (ASCII/blueprint)
  - Isometric sprite (simple 2D)
  - Stats panel (detailed numbers)
- **Dynamic Updates:** Ship appearance changes based on installed systems
- **Damage States:** Visual feedback when systems are damaged

---

## Sound Design (Future Enhancement)

### Audio Categories
- **Ambient:** Ship hum, space ambience
- **UI:** Button clicks, system notifications
- **Events:** Warp jump, shields impact, alarms
- **Music:** Atmospheric tracks for different phases
  - Earth: Melancholic, industrial
  - Space: Expansive, mysterious
  - Combat: Tense, rhythmic

---

## Target Player Experience

### Core Fantasy
*"I built this ship from nothing, and now I'm exploring the galaxy in MY vessel, making MY choices, facing consequences of MY actions."*

### Emotional Journey
1. **Determination** - Early game struggle, building from scraps
2. **Achievement** - First successful system installation
3. **Wonder** - First warp jump into space
4. **Tension** - Difficult choices and dangerous situations
5. **Pride** - Ship performs in critical moment
6. **Reflection** - Endgame consequences of your path

### Player Agency
- **Ship Design:** No "correct" build - different systems enable different strategies
- **Narrative Choices:** Multiple solutions to most situations
- **Exploration:** Non-linear space travel
- **Pacing:** Player controls when to launch missions/encounters

---

## Success Metrics

### MVP Goals (Minimum Viable Product)
- [ ] 10 ship systems, each with 3+ levels
- [ ] 20+ Earth missions (mix of scripted and AI-generated)
- [ ] 5+ space encounters per star system (3 systems minimum)
- [ ] Functional save/load system
- [ ] AI integration working with both OpenAI and Ollama
- [ ] Ship dashboard with visual schematic
- [ ] 3-5 hours of gameplay to complete Phase 1
- [ ] 5-8 hours of Phase 2 content

### Full Release Goals
- [ ] All 10 systems with 5 levels each
- [ ] 50+ Earth missions
- [ ] 10+ star systems with unique characteristics
- [ ] 100+ possible encounters
- [ ] Multiple endings (5+)
- [ ] New Game+ mode (harder, new content)
- [ ] Ship customization (naming, aesthetics)
- [ ] Companion/crew system
- [ ] 20-30 hours total gameplay

---

## Risk Mitigation

| Risk | Impact | Mitigation Strategy |
|------|--------|---------------------|
| AI costs too high | High | Prioritize Ollama, cache responses, limit AI calls |
| AI generates poor content | Medium | Fallback to scripted, allow rerolls, manual review |
| Scope creep | High | Strict MVP, phased development |
| Save file corruption | Medium | Versioning, backups, validation |
| Balance issues | Low | Playtesting, flexible system values |
| Player gets stuck | Medium | Hint system, difficulty options |

---

## Next Steps

See **MVP Implementation Roadmap** document for detailed development plan.

---

**Document Status:** Draft v1.0
**Last Updated:** November 5, 2025
**Author:** Claude & Team
