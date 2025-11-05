# Space Adventures - Ship Systems Specification

**Version:** 1.0
**Date:** November 5, 2025
**Purpose:** Detailed specifications for all ship systems and mechanics

---

## Table of Contents
1. [System Overview](#system-overview)
2. [System Mechanics](#system-mechanics)
3. [Detailed System Specifications](#detailed-system-specifications)
4. [System Interactions](#system-interactions)
5. [Damage and Repair](#damage-and-repair)
6. [Upgrade Paths](#upgrade-paths)

---

## System Overview

### Core Design Principles
1. **Interdependence**: Systems rely on each other (e.g., shields need power)
2. **Trade-offs**: Higher-level systems consume more power
3. **Meaningful Choices**: No "best" loadout - different builds for different playstyles
4. **Progressive Unlock**: Systems unlock new gameplay mechanics

### System States
```
NOT INSTALLED (Level 0) → Cannot use related features
INSTALLED (Level 1+)    → Feature available
POWERED                 → System active and functional
UNPOWERED               → Installed but inactive (insufficient power)
DAMAGED                 → Reduced effectiveness
DESTROYED               → Must repair before use
```

---

## System Mechanics

### Power System

**Core Mechanic:** Power is the currency that activates and maintains systems.

```
Total Power = Power Core Level × Base Power Multiplier
Available Power = Total Power - (Sum of Active System Power Costs)
```

**Power Costs by System Level:**

| System | L1 | L2 | L3 | L4 | L5 |
|--------|----|----|----|----|--- |
| Hull | 0 | 0 | 0 | 0 | 10 (regen) |
| Power Core | 0 | 0 | 0 | 0 | 0 |
| Propulsion | 10 | 15 | 25 | 40 | 60 |
| Warp Drive | 20 | 30 | 50 | 80 | 120 |
| Life Support | 5 | 10 | 15 | 25 | 35 |
| Computer | 5 | 10 | 20 | 35 | 50 |
| Sensors | 5 | 10 | 20 | 35 | 50 |
| Shields | 15 | 25 | 40 | 60 | 85 |
| Weapons | 10 | 20 | 35 | 55 | 80 |
| Communications | 5 | 8 | 12 | 18 | 25 |

**Power Management UI:**
```
POWER DISTRIBUTION
════════════════════════════════════════
Total:     400 PU  [████████████████]
Used:      265 PU  [██████████░░░░░░]
Available: 135 PU

System              Status    Power
────────────────────────────────────
⚡ Power Core L3    ACTIVE    --
🛡️ Shields L2       ACTIVE    25 PU
🚀 Warp L2          ACTIVE    30 PU
🎯 Weapons L2       ACTIVE    20 PU
📡 Sensors L3       ACTIVE    20 PU
...

[Disable System] [Priority Mode] [Emergency Power]
```

### Health and Damage

**Hull Health:**
```
Max HP = Hull System Level × Base HP Multiplier
Base HP: [50, 100, 200, 350, 500]
```

**Damage Types:**
- **Kinetic**: Projectiles, impacts (reduced by hull armor)
- **Energy**: Lasers, phasers (reduced by shields)
- **Radiation**: Cosmic rays, stars (life support protection)
- **System**: Direct damage to specific systems

**Damage Flow:**
```
Incoming Damage
    ↓
Shields (absorb %)
    ↓
Hull Armor (reduce remaining)
    ↓
Hull HP (take final damage)
    ↓ (if penetrating hit)
Random System Damage (10% chance per hit)
```

---

## Detailed System Specifications

### 1. Hull & Structure

**Function:** Physical integrity and damage resistance

**Level Progression:**

#### Level 0: No Hull
- Status: Ship frame only, not spaceworthy
- HP: 0
- Armor: 0

#### Level 1: Salvaged Hull
- **Parts Required:** Scrap Hull Plates (x10), Welding Equipment
- **HP:** 50
- **Armor:** 5% kinetic reduction
- **Description:** "Patchwork hull cobbled from salvaged materials. It'll hold... probably."

#### Level 2: Reinforced Structure
- **Parts Required:** Reinforced Plating (x20), Structural Beams
- **HP:** 100
- **Armor:** 15% kinetic reduction
- **Description:** "Proper hull plating with reinforced stress points. Now you're spaceworthy."

#### Level 3: Composite Armor
- **Parts Required:** Composite Alloy (x15), Ablative Coating
- **HP:** 200
- **Armor:** 25% kinetic reduction, 10% energy reduction
- **Special:** +10% resistance to radiation
- **Description:** "Military-grade composite armor. Can withstand serious punishment."

#### Level 4: Ablative Plating
- **Parts Required:** Ablative Tiles (x30), Heat Dispersal System
- **HP:** 350
- **Armor:** 35% kinetic reduction, 20% energy reduction
- **Special:** Absorbs 50% of first energy hit per encounter
- **Description:** "Advanced ablative armor disperses energy weapon impacts."

#### Level 5: Regenerative Hull
- **Parts Required:** Nano-Repair Matrix, Living Metal Sample
- **HP:** 500
- **Armor:** 45% kinetic reduction, 30% energy reduction
- **Special:** Regenerate 1% max HP per turn (5 HP/turn)
- **Power Cost:** 10 PU (for regeneration)
- **Description:** "Experimental self-repairing hull using nano-technology. Illegal in most sectors."

---

### 2. Power Core

**Function:** Generate power for all ship systems

**Level Progression:**

#### Level 0: No Power
- Status: Ship is dead in space
- Power: 0 PU

#### Level 1: Fusion Cell
- **Parts Required:** Fusion Cell, Power Regulator
- **Power:** 100 PU
- **Efficiency:** 80% (20% waste heat)
- **Description:** "Basic fusion cell. Enough to get started."

#### Level 2: Deuterium Reactor
- **Parts Required:** Reactor Core, Deuterium Tank, Coolant System
- **Power:** 200 PU
- **Efficiency:** 85%
- **Special:** -10% power cost to all systems
- **Description:** "Standard deuterium reactor. Reliable and efficient."

#### Level 3: Matter/Antimatter Core
- **Parts Required:** M/AM Reactor, Magnetic Containment, Antimatter Pod
- **Power:** 400 PU
- **Efficiency:** 90%
- **Special:** -15% power cost to all systems
- **Description:** "The workhorse of modern starships. Volatile but powerful."

#### Level 4: Advanced M/AM Reactor
- **Parts Required:** Military Reactor Core, Advanced Containment, Antimatter Injectors
- **Power:** 700 PU
- **Efficiency:** 93%
- **Special:** -20% power cost, Emergency Power Reserve (100 PU one-time boost)
- **Description:** "Military-grade reactor. Over-engineered for extreme reliability."

#### Level 5: Zero-Point Energy Tap
- **Parts Required:** Quantum Vacuum Device, Exotic Matter Stabilizer
- **Power:** 1000 PU
- **Efficiency:** 98%
- **Special:** -25% power cost, Power regenerates 5 PU/turn during encounters
- **Description:** "Experimental quantum technology. Draws power from the fabric of space itself."

---

### 3. Propulsion (Impulse Engines)

**Function:** Sub-light maneuvering and combat agility

**Level Progression:**

#### Level 1: Chemical Thrusters
- **Parts Required:** Thruster Assembly, Fuel Tanks
- **Power Cost:** 10 PU
- **Speed:** 1x (base)
- **Agility:** +5% dodge in combat
- **Description:** "Old reliable. Slow but functional."

#### Level 2: Ion Drive
- **Parts Required:** Ion Engine, Plasma Accelerator
- **Power Cost:** 15 PU
- **Speed:** 2x
- **Agility:** +10% dodge
- **Description:** "Standard ion propulsion. Quiet and efficient."

#### Level 3: Plasma Engine
- **Parts Required:** Plasma Core, Magnetic Nozzle
- **Power Cost:** 25 PU
- **Speed:** 4x
- **Agility:** +18% dodge
- **Special:** Can perform "Evasive Maneuvers" in combat (once per encounter)
- **Description:** "Fast and responsive. A pilot's dream."

#### Level 4: Gravitic Drive
- **Parts Required:** Gravity Generator, Inertial Compensator
- **Power Cost:** 40 PU
- **Speed:** 7x
- **Agility:** +28% dodge
- **Special:** "Emergency Burn" - instant position change in combat (2/encounter)
- **Description:** "Manipulates local gravity fields. Impossibly agile."

#### Level 5: Inertial Dampener
- **Parts Required:** Quantum Inertial System, Spacetime Modulator
- **Power Cost:** 60 PU
- **Speed:** 12x
- **Agility:** +40% dodge
- **Special:** Perfect maneuverability, immune to kinetic collision damage
- **Description:** "Experimental technology that negates inertia. You can stop on a dime."

---

### 4. Warp Drive

**Function:** Faster-than-light travel between star systems

**Level Progression:**

#### Level 0: No FTL
- Status: Trapped in starting system
- Warp Factor: 0

#### Level 1: Warp 1 Drive
- **Parts Required:** Warp Core, Nacelle Pair, Dilithium Crystal
- **Power Cost:** 20 PU (when traveling)
- **Warp Factor:** 1 (1× light speed)
- **Range:** 2 light years
- **Travel Time:** 1 day per LY
- **Accessible Systems:** 3 nearby systems
- **Description:** "Your ticket off Earth. Barely faster than light, but it counts."

#### Level 2: Warp 3 Drive
- **Parts Required:** Enhanced Warp Coils, Field Stabilizer
- **Power Cost:** 30 PU
- **Warp Factor:** 3 (9× light speed)
- **Range:** 10 light years
- **Travel Time:** 3 hours per LY
- **Accessible Systems:** 12 systems
- **Description:** "Now we're traveling. The close sectors are yours to explore."

#### Level 3: Warp 5 Drive
- **Parts Required:** High-Grade Dilithium, Plasma Injectors
- **Power Cost:** 50 PU
- **Warp Factor:** 5 (125× light speed)
- **Range:** 50 light years
- **Travel Time:** 30 minutes per LY
- **Accessible Systems:** Most of the galaxy
- **Special:** Can escape most hostile encounters
- **Description:** "Standard deep-space warp drive. The galaxy opens up."

#### Level 4: Warp 7 Drive
- **Parts Required:** Military Warp Core, Quantum Flux Regulator
- **Power Cost:** 80 PU
- **Warp Factor:** 7 (343× light speed)
- **Range:** 200 light years
- **Travel Time:** 5 minutes per LY
- **Accessible Systems:** Entire local cluster
- **Special:** Tactical warp jumps (short-range combat repositioning)
- **Description:** "Military-spec drive. Fast enough to outrun trouble."

#### Level 5: Warp 9 + Transwarp
- **Parts Required:** Prototype Warp Core, Transwarp Coil, Exotic Matter
- **Power Cost:** 120 PU
- **Warp Factor:** 9+ (729× light speed)
- **Range:** Unlimited
- **Travel Time:** Instant to 1 minute
- **Special:** Transwarp corridors (instant travel to discovered systems)
- **Description:** "Bleeding-edge tech. Jump across the galaxy in moments."

---

### 5. Life Support

**Function:** Keep crew alive and operational

**Level Progression:**

#### Level 1: Basic Oxygen Recycling
- **Parts Required:** Air Recycler, Basic Filters
- **Power Cost:** 5 PU
- **Crew Capacity:** 1
- **Emergency Duration:** 24 hours
- **Radiation Protection:** 10%
- **Description:** "Keeps you breathing. That's about it."

#### Level 2: Climate Control
- **Parts Required:** Environmental Processor, Temperature Regulators
- **Power Cost:** 10 PU
- **Crew Capacity:** 4
- **Emergency Duration:** 1 week
- **Radiation Protection:** 30%
- **Special:** +10% morale (unlocks crew system)
- **Description:** "Comfortable environment for a small crew."

#### Level 3: Advanced Bio-Recycling
- **Parts Required:** Bio-Filter Array, Water Reclamation
- **Power Cost:** 15 PU
- **Crew Capacity:** 10
- **Emergency Duration:** 1 month
- **Radiation Protection:** 50%
- **Special:** +20% morale, crew can perform tasks
- **Description:** "Closed-loop life support. Months of self-sufficiency."

#### Level 4: Closed-Loop Ecosystem
- **Parts Required:** Hydroponics Bay, Advanced Recyclers
- **Power Cost:** 25 PU
- **Crew Capacity:** 25
- **Emergency Duration:** 6 months
- **Radiation Protection:** 75%
- **Special:** +30% morale, produce food (reduce supply costs), crew efficiency +20%
- **Description:** "Self-sustaining ecosystem. You could live aboard indefinitely."

#### Level 5: Bio-Dome
- **Parts Required:** Biodome Module, Artificial Sun, Genetic Catalog
- **Power Cost:** 35 PU
- **Crew Capacity:** 50
- **Emergency Duration:** Indefinite
- **Radiation Protection:** 95%
- **Special:** +50% morale, zero supply costs, crew efficiency +40%, psychological resilience
- **Description:** "A garden in space. The crew considers this home."

---

### 6. Computer Core

**Function:** Ship automation, AI assistance, tactical calculations

**Level Progression:**

#### Level 1: Basic Computer
- **Parts Required:** Computer Core, Basic Software
- **Power Cost:** 5 PU
- **Features:** Manual ship control, basic calculations
- **Description:** "Calculator with delusions of grandeur."

#### Level 2: Standard AI
- **Parts Required:** AI Matrix, Neural Network Module
- **Power Cost:** 10 PU
- **Features:**
  - Targeting assistance (+10% weapon accuracy)
  - Auto-navigation (reduces travel time 10%)
  - Basic threat assessment
- **Description:** "Helpful AI assistant. Follows orders without complaint."

#### Level 3: Advanced AI
- **Parts Required:** Quantum Processor, Learning Algorithm
- **Power Cost:** 20 PU
- **Features:**
  - Tactical recommendations (suggests optimal actions)
  - Predictive analysis (warns of probable dangers)
  - +20% weapon accuracy
  - +15% sensor effectiveness
  - Auto-repair assistance (repair systems 20% faster)
- **Description:** "Intelligent AI that learns and adapts. Almost like having a crew."

#### Level 4: Tactical AI
- **Parts Required:** Military AI Core, Combat Database
- **Power Cost:** 35 PU
- **Features:**
  - Combat automation (can fight autonomously)
  - Optimal solution finding (suggests best approach to challenges)
  - +35% weapon accuracy
  - +25% dodge (predictive evasion)
  - Emergency protocols (auto-activate shields when threatened)
- **Description:** "Military-grade tactical computer. Thinks faster than you do."

#### Level 5: Sentient AI
- **Parts Required:** Positronic Brain, Consciousness Matrix
- **Power Cost:** 50 PU
- **Features:**
  - Companion NPC (generates unique personality)
  - Creative problem-solving (generates solutions AI hasn't seen before)
  - +50% all combat stats
  - Autonomous ship operations
  - Dialogue partner (meaningful conversations)
  - Emotional intelligence (better at diplomacy)
- **Special:** Evolves over time, remembers everything, forms opinions
- **Description:** "A true artificial consciousness. It's not just a ship anymore - it's a friend."

---

### 7. Sensors

**Function:** Detection, scanning, situational awareness

**Level Progression:**

#### Level 1: Optical Sensors
- **Parts Required:** Telescope Array, Basic Scanners
- **Power Cost:** 5 PU
- **Range:** Short (1 AU)
- **Detection Quality:** Basic visual data
- **Features:**
  - See nearby ships/objects
  - Basic composition scans
- **Description:** "Fancy cameras pointed at space."

#### Level 2: EM Spectrum Sensors
- **Parts Required:** Multi-Spectrum Array, Signal Processor
- **Power Cost:** 10 PU
- **Range:** Medium (5 AU)
- **Detection Quality:** Detailed composition
- **Features:**
  - Detect power signatures
  - Material composition analysis
  - Life sign detection (basic)
  - +20% encounter warning time
- **Description:** "See across the electromagnetic spectrum. Much more useful."

#### Level 3: Subspace Array
- **Parts Required:** Subspace Antenna, Quantum Detector
- **Power Cost:** 20 PU
- **Range:** Long (50 AU)
- **Detection Quality:** Comprehensive analysis
- **Features:**
  - Long-range threat detection
  - Detailed life form scans
  - Technology level assessment
  - Hidden object detection
  - +40% encounter warning
- **Special:** Unlock detailed scan mini-game
- **Description:** "Peer deep into space. Little escapes your notice."

#### Level 4: Multi-Phasic Sensors
- **Parts Required:** Phase Discriminator, Temporal Scanner
- **Power Cost:** 35 PU
- **Range:** Very Long (500 AU / system-wide)
- **Detection Quality:** Extremely detailed
- **Features:**
  - Detect cloaked ships
  - Temporal anomalies
  - Subspace rifts
  - Predict ship trajectories
  - +60% encounter warning
- **Special:** Can scan through interference
- **Description:** "Military sensor suite. Nothing hides from you."

#### Level 5: Quantum Sensors
- **Parts Required:** Quantum Entanglement Array, Probability Engine
- **Power Cost:** 50 PU
- **Range:** Extreme (entire sector)
- **Detection Quality:** Precognitive
- **Features:**
  - Predict future positions (1 hour ahead)
  - Detect quantum-level phenomena
  - Scan alternate dimensions
  - Absolutely nothing can hide
  - +100% encounter warning (basically precognition)
- **Special:** Unlock "Future Vision" ability (see consequences before choosing)
- **Description:** "Experimental quantum technology. You see things before they happen."

---

### 8. Shields

**Function:** Energy defense, damage mitigation

**Level Progression:**

#### Level 0: No Shields
- Status: Hull takes all damage
- Protection: 0%

#### Level 1: Deflector Screens
- **Parts Required:** Deflector Emitter, Power Coupling
- **Power Cost:** 15 PU
- **Shield HP:** 50
- **Damage Reduction:** 25%
- **Recharge:** 5 HP/turn when not hit
- **Description:** "Better than nothing. Barely."

#### Level 2: Standard Shields
- **Parts Required:** Shield Generator, Frequency Modulator
- **Power Cost:** 25 PU
- **Shield HP:** 150
- **Damage Reduction:** 50%
- **Recharge:** 15 HP/turn
- **Special:** Block one shot completely (1/encounter)
- **Description:** "Solid protection. Standard across the galaxy."

#### Level 3: Multi-Layered Shields
- **Parts Required:** Multi-Phase Emitter, Redundant Generators
- **Power Cost:** 40 PU
- **Shield HP:** 300
- **Damage Reduction:** 70%
- **Recharge:** 30 HP/turn
- **Special:** Rapid recharge (full recharge in 3 turns if not hit)
- **Description:** "Multiple shield layers provide excellent protection."

#### Level 4: Adaptive Shields
- **Parts Required:** Adaptive Emitter, Pattern Buffer
- **Power Cost:** 60 PU
- **Shield HP:** 500
- **Damage Reduction:** 85%
- **Recharge:** 50 HP/turn
- **Special:**
  - Adapt to damage type (after being hit, +25% resistance to that type)
  - Can "rotate shield frequency" to reset adaptations
- **Description:** "Military shields that learn and adapt to threats."

#### Level 5: Phase Shields
- **Parts Required:** Phase Emitter, Quantum State Generator
- **Power Cost:** 85 PU
- **Shield HP:** 800
- **Damage Reduction:** 95%
- **Recharge:** 80 HP/turn
- **Special:**
  - 30% chance to phase out and completely avoid damage
  - Immune to energy drain attacks
  - Can extend shields to nearby friendly ships
- **Description:** "Experimental phasing technology. Sometimes you're just not there when the shot arrives."

---

### 9. Weapons

**Function:** Combat offense, self-defense

**Level Progression:**

#### Level 0: No Weapons
- Status: Cannot engage in combat (auto-flee only)
- Damage: 0

#### Level 1: Laser Cannon
- **Parts Required:** Laser Array, Power Capacitor
- **Power Cost:** 10 PU
- **Damage:** 15-25
- **Accuracy:** 70%
- **Range:** Short
- **Special:** Precise (crits on 90+)
- **Description:** "Salvaged mining laser. It'll hurt... eventually."

#### Level 2: Phaser Array
- **Parts Required:** Phaser Emitters, Targeting Computer
- **Power Cost:** 20 PU
- **Damage:** 30-50
- **Accuracy:** 80%
- **Range:** Medium
- **Special:**
  - Variable power (can attack at 50% power for half cost)
  - Precise targeting (can target specific systems)
- **Description:** "Standard energy weapon. Reliable and accurate."

#### Level 3: Photon Torpedoes + Phasers
- **Parts Required:** Torpedo Launcher, Warhead Magazine, Enhanced Phasers
- **Power Cost:** 35 PU
- **Phaser Damage:** 40-60
- **Torpedo Damage:** 80-120 (limited ammo: 10/encounter)
- **Accuracy:** 85%
- **Range:** Long
- **Special:**
  - Heavy damage option (torpedoes)
  - Phasers never run out
- **Description:** "Serious firepower. You can hold your own in a fight."

#### Level 4: Quantum Torpedoes + Pulse Phasers
- **Parts Required:** Quantum Launcher, Pulse Phaser Arrays, Military Targeting
- **Power Cost:** 55 PU
- **Pulse Damage:** 60-90 (rapid fire: 2x/turn)
- **Quantum Damage:** 150-200 (8/encounter)
- **Accuracy:** 90%
- **Range:** Very Long
- **Special:**
  - Quantum torpedoes bypass 50% of shields
  - Pulse mode for sustained fire
  - "Alpha Strike" - fire everything at once (300-400 damage, 2/encounter)
- **Description:** "Military arsenal. You're a threat to be respected."

#### Level 5: Experimental Weapons
- **Parts Required:** Prototype Weapon System, Exotic Power Source
- **Power Cost:** 80 PU
- **Damage:** Variable (see below)
- **Accuracy:** 95%
- **Range:** Extreme
- **Special Abilities:**
  - **Transphasic Torpedoes**: Ignore shields entirely (120-180 dmg, 5/encounter)
  - **Graviton Beam**: Pull or push enemy ships (50 dmg + repositioning)
  - **Tachyon Burst**: Hit all enemies (80 dmg each, 3/encounter)
  - **Disruptor Cannon**: 100-150 dmg + disable random system
- **Description:** "Cutting-edge experimental weapons. Devastating and versatile."

---

### 10. Communication Array

**Function:** Long-range communication, translation, diplomacy

**Level Progression:**

#### Level 1: Radio Transceiver
- **Parts Required:** Radio Antenna, Signal Amplifier
- **Power Cost:** 5 PU
- **Range:** Short (same planet/station)
- **Features:**
  - Basic communication with Earth
  - Receive distress signals (short range)
- **Description:** "Hello? Can anyone hear me?"

#### Level 2: Subspace Radio
- **Parts Required:** Subspace Transceiver, Encryption Module
- **Power Cost:** 8 PU
- **Range:** System-wide
- **Features:**
  - Real-time communication across star system
  - Access to local information networks
  - Receive missions from NPCs
  - +10% to diplomacy checks
- **Description:** "Connected to the local network. Information is power."

#### Level 3: Universal Translator
- **Parts Required:** Translation Matrix, Linguistic Database, Subspace Array
- **Power Cost:** 12 PU
- **Range:** Galaxy-wide
- **Features:**
  - Communicate with all known alien species
  - Access to galactic information network
  - Real-time translation
  - +20% to diplomacy checks
  - Unlock "Diplomacy" as alternative to combat
- **Description:** "Speak to anyone, anywhere. The galaxy becomes much friendlier."

#### Level 4: Quantum Entanglement Communicator
- **Parts Required:** Quantum Pair, Entanglement Chamber
- **Power Cost:** 18 PU
- **Range:** Unlimited (instant)
- **Features:**
  - Instant communication regardless of distance
  - Cannot be intercepted or jammed
  - Access to classified information networks
  - +35% to diplomacy checks
  - Receive special missions from distant factions
- **Description:** "Quantum-encrypted instant communication. No delay, no interception."

#### Level 5: Psionic Amplifier
- **Parts Required:** Psionic Resonator, Neural Interface
- **Power Cost:** 25 PU
- **Range:** Unlimited + empathic
- **Features:**
  - Telepathic communication with psionic species
  - Sense emotions and intentions (detect lies/hostility)
  - +50% to diplomacy checks
  - "Empathic Understanding" - see another's perspective
  - Unlock hidden dialogue options
  - Can communicate with non-verbal life forms
- **Special:** Sometimes receive visions or warnings from unknown sources
- **Description:** "Touch minds across the void. You understand species on a deeper level."

---

## System Interactions

### Synergies

**Computer + Sensors:**
- L2+ Computer + L3+ Sensors = "Deep Space Scan" (detailed analysis of everything in range)

**Shields + Computer:**
- L3+ Shields + L3+ Computer = Auto-modulation (shields adapt faster)

**Weapons + Computer:**
- L2+ Weapons + L2+ Computer = Improved targeting (+15% accuracy)

**Propulsion + Computer:**
- L3+ Propulsion + L3+ Computer = Optimal routing (travel 20% faster)

**Life Support + Computer:**
- L4+ Life Support + L4+ Computer = Automated systems (crew efficiency +25%)

**Warp + Sensors:**
- L3+ Warp + L4+ Sensors = Safe jump (detect hazards before warping)

**Communications + Computer:**
- L3+ Comms + L4+ Computer = Codebreaking (intercept enemy communications)

### Conflicts and Trade-offs

**High Power Build:**
- Great weapons and shields
- But: Poor range (low warp) or limited sensors

**Explorer Build:**
- Excellent sensors and warp
- But: Vulnerable in combat

**Balanced Build:**
- All systems at L2-3
- But: Master of none, harder difficulty spikes

---

## Damage and Repair

### System Damage

When hull takes damage with shields down, 10% chance per hit to damage a random system:

**Damage Effects:**
- **100-75% Health**: System functions normally
- **74-50% Health**: -25% effectiveness, warning indicator
- **49-25% Health**: -50% effectiveness, +25% power cost
- **24-1% Health**: -75% effectiveness, +50% power cost, can fail randomly
- **0% Health**: System offline, cannot use

### Repair Mechanics

**In Combat:**
- Cannot repair during combat
- Must survive to repair

**Post-Combat / Exploration:**
- **Auto-Repair** (if Computer L3+): Systems heal 5% health/turn
- **Manual Repair**: Player can focus on one system (20% health, costs time)
- **Station Repair**: Pay credits for instant full repair
- **Parts Repair**: Use spare parts from inventory

**Repair Items:**
- **Repair Kit (Common)**: Restore 25% health to one system
- **Advanced Repair Kit (Rare)**: Restore 50% health to one system
- **Nano-Repair Swarm (Epic)**: Restore 100% health to all systems

---

## Upgrade Paths

### Early Game (Earth Missions)
Focus on: Hull, Power, Propulsion (basic spaceworthiness)

**Suggested Order:**
1. Hull L1 (survive)
2. Power L1 (systems operational)
3. Propulsion L1 (can move)
4. Life Support L1 (breathe)
5. Computer L1 (operate ship)
6. Sensors L1 (see threats)
7. Warp L1 (leave Earth) ← PHASE 2 UNLOCKED

### Mid Game (Early Space Exploration)
Focus on: Warp, Sensors, Communications (explore safely)

**Suggested Order:**
1. Communications L2 (talk to aliens)
2. Shields L1-2 (survive encounters)
3. Sensors L2-3 (detect danger early)
4. Warp L2-3 (reach more systems)
5. Power L2 (support more systems)

### Late Game (Deep Space)
Focus on: Combat capability OR specialization

**Combat Build:**
1. Weapons L3-4
2. Shields L4
3. Hull L3-4
4. Power L3-4 (to support everything)

**Explorer Build:**
1. Sensors L5
2. Warp L5
3. Communications L5
4. Computer L5

**Balanced Build:**
1. All systems to L3
2. Focus on synergies
3. Situational upgrades to L4-5

---

## Implementation Notes for Claude

### GDScript Classes

```gdscript
# scripts/systems/ship_system.gd (Base Class)
class_name ShipSystem
extends Resource

@export var system_name: String
@export var system_type: String
@export var level: int = 0
@export var health: int = 100
@export var active: bool = false
@export var installed_part_id: String = ""

func get_power_cost() -> int:
    # Return power cost based on level
    pass

func get_effectiveness() -> float:
    # Return effectiveness (0.0 to 1.0) based on health
    pass

func take_damage(amount: int) -> void:
    health = max(0, health - amount)
    if health == 0:
        active = false

func repair(amount: int) -> void:
    health = min(100, health + amount)
```

### System Data JSON

```json
// assets/data/ship_parts.json
{
  "ship_parts": [
    {
      "id": "hull_salvaged",
      "name": "Salvaged Hull Plates",
      "type": "ship_part",
      "system_type": "hull",
      "level": 1,
      "rarity": "common",
      "description": "Patchwork hull cobbled from salvaged materials.",
      "stats": {
        "hp": 50,
        "armor_kinetic": 5
      },
      "requirements": {
        "parts": ["scrap_metal", "welding_kit"]
      }
    }
  ]
}
```

---

**Document Status:** Complete v1.0
**Last Updated:** November 5, 2025
