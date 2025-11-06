# Space Adventures - Ship Classification System

**Version:** 1.0
**Date:** November 5, 2025
**Purpose:** Ship class recognition system based on player's build configuration

---

## Table of Contents
1. [Overview](#overview)
2. [How Classification Works](#how-classification-works)
3. [Ship Classes](#ship-classes)
4. [Classification Requirements](#classification-requirements)
5. [Class Benefits](#class-benefits)
6. [Recognition System](#recognition-system)
7. [Multi-Classing](#multi-classing)
8. [Implementation](#implementation)

---

## Overview

### Design Philosophy

**Goal-Oriented Building:**
- Players can aim to build specific ship classes based on their playstyle
- Each class has clear requirements and benefits
- Classification provides sense of achievement and identity
- Encourages build diversity and replayability

**Inspired by Star Trek:**
- Ship classes based on Starfleet vessel designations
- Each class reflects a specialized role or purpose
- Classes range from small scouts to heavy explorers
- Balanced for post-Exodus Earth setting (salvaged tech era)

### What is Ship Classification?

Your ship's **class** is determined by its system configuration. As you install and upgrade systems, your ship may qualify for official classification. Each class represents a specialized role:

- **Scout** - Fast, agile, light on resources
- **Courier** - Speed-focused transport and communication
- **Frigate** - Light combat and patrol vessel
- **Science Vessel** - Research and exploration specialist
- **Destroyer** - Medium combat vessel
- **Cruiser** - Balanced general-purpose ship
- **Heavy Cruiser** - Combat-focused with strong defenses
- **Explorer** - Long-range deep space exploration
- **Dreadnought** - Maximum firepower and armor
- **Support Vessel** - Logistics and repair capabilities

---

## How Classification Works

### Classification Check

The game automatically checks if your ship qualifies for a class whenever you:
- Install or upgrade a system
- Complete a major mission
- Manually request classification from Ship Computer

### Requirements

Each class has **minimum requirements** across the 10 systems:
```
Requirements format:
- Required Systems: [systems that MUST be installed]
- System Level Minimums: [specific levels for key systems]
- Power Budget: [power generation vs consumption ratio]
- Special Conditions: [any unique requirements]
```

### Recognition

When your ship meets all requirements for a class:
1. **Ship Computer notification** - "Classification criteria met: [Class Name]"
2. **Official designation** - Your ship receives class designation (e.g., "SS Endeavor - Explorer-class")
3. **Unlock benefits** - Class-specific bonuses and abilities
4. **Update ship manual** - New section added describing your ship's class
5. **Achievement unlocked** - Recorded in player progress

---

## Ship Classes

### 1. Scout-Class

**Role:** Fast reconnaissance and data gathering

**Description:**
Scouts are small, agile vessels optimized for speed and sensor range. They sacrifice combat capability and crew comfort for maneuverability and the ability to quickly survey unknown territory. Scouts excel at avoiding danger rather than confronting it.

**Ideal For:** Players who prefer stealth, exploration, and avoiding combat

**Requirements:**
```yaml
Required Systems:
  - Hull (minimum Level 1)
  - Power Core (minimum Level 1)
  - Propulsion (minimum Level 2) ★
  - Warp Drive (minimum Level 1)
  - Life Support (minimum Level 1)
  - Computer Core (minimum Level 1)
  - Sensors (minimum Level 2) ★

Optional Systems:
  - Shields, Weapons, Communications (any level or none)

Special Conditions:
  - Propulsion OR Sensors must be Level 2+
  - Power consumption ≤ 60% of generation (efficient)
  - No system can be Level 4+ (compact design)
```

**Class Bonuses:**
- **+25% Propulsion efficiency** - Reduced fuel consumption for sub-light travel
- **+50% Sensor range** - Detect threats and opportunities from farther away
- **Evasion bonus** - +15% chance to avoid combat encounters
- **Fast scanning** - Complete sensor scans 30% faster

**Recognition Message:**
> "Ship configuration analyzed. Classification: **SCOUT-CLASS**. Your vessel's emphasis on sensors and maneuverability qualifies it for reconnaissance operations. Recommended deployment: forward survey missions, threat assessment, and rapid-response scouting."

---

### 2. Courier-Class

**Role:** Rapid transport and time-critical deliveries

**Description:**
Couriers prioritize speed above all else. With powerful engines and minimal auxiliary systems, these ships are built to get from Point A to Point B as quickly as possible. Used for urgent cargo delivery, VIP transport, and critical communications relay.

**Ideal For:** Players who want the fastest ship possible

**Requirements:**
```yaml
Required Systems:
  - Hull (minimum Level 1)
  - Power Core (minimum Level 2) ★
  - Propulsion (minimum Level 3) ★
  - Warp Drive (minimum Level 2) ★
  - Life Support (minimum Level 1)
  - Communications (minimum Level 2) ★

Optional Systems:
  - Computer Core, Sensors, Shields, Weapons (any level or none)

Special Conditions:
  - Propulsion + Warp Drive combined levels ≥ 5
  - Communications Level 2+ (for coordination)
  - Total installed systems ≤ 8 (lightweight build)
```

**Class Bonuses:**
- **+40% Warp speed** - Faster interstellar travel
- **+30% Impulse speed** - Faster sub-light speed
- **Priority docking** - Reduced wait times at stations
- **Express missions** - Access to time-critical high-paying courier missions
- **Fuel efficiency** - 20% reduction in fuel consumption

**Recognition Message:**
> "Ship configuration analyzed. Classification: **COURIER-CLASS**. Your vessel's exceptional propulsion systems and streamlined design qualify it for priority transport operations. Recommended deployment: urgent cargo delivery, emergency medical transport, diplomatic courier service."

---

### 3. Frigate-Class

**Role:** Light patrol and combat operations

**Description:**
Frigates are the smallest vessels classified as "warships." They combine modest firepower with good speed and shields, making them effective for patrol, escort, and anti-piracy operations. Frigates can't match larger warships in a direct fight but excel at hit-and-run tactics.

**Ideal For:** Players who want combat capability without heavy investment

**Requirements:**
```yaml
Required Systems:
  - Hull (minimum Level 2) ★
  - Power Core (minimum Level 2) ★
  - Propulsion (minimum Level 2)
  - Warp Drive (minimum Level 1)
  - Life Support (minimum Level 1)
  - Computer Core (minimum Level 2)
  - Shields (minimum Level 2) ★
  - Weapons (minimum Level 2) ★

Optional Systems:
  - Sensors, Communications (any level or none)

Special Conditions:
  - Weapons + Shields combined levels ≥ 4
  - Hull Level 2+ (combat-rated structure)
  - Power generation ≥ 80 MW
```

**Class Bonuses:**
- **Combat bonus** - +10% weapon damage, +10% shield strength
- **Tactical systems** - Improved targeting and threat assessment
- **Patrol efficiency** - 25% faster mission completion for patrol missions
- **Escort capability** - Can accept NPC escort missions

**Recognition Message:**
> "Ship configuration analyzed. Classification: **FRIGATE-CLASS**. Your vessel's balanced combination of weapons, shields, and maneuverability qualifies it for light combat operations. Recommended deployment: system patrol, convoy escort, pirate interdiction."

---

### 4. Science Vessel-Class

**Role:** Research, analysis, and scientific missions

**Description:**
Science vessels are floating laboratories equipped with cutting-edge sensors and computer systems. They're designed to study anomalies, analyze alien artifacts, and conduct long-term research missions. While lightly armed, their advanced systems make them invaluable for first-contact scenarios and stellar phenomena investigation.

**Ideal For:** Players who love discovery and solving mysteries

**Requirements:**
```yaml
Required Systems:
  - Hull (minimum Level 2)
  - Power Core (minimum Level 2)
  - Propulsion (minimum Level 1)
  - Warp Drive (minimum Level 2)
  - Life Support (minimum Level 2) ★
  - Computer Core (minimum Level 3) ★★
  - Sensors (minimum Level 3) ★★
  - Communications (minimum Level 2)

Optional Systems:
  - Shields, Weapons (any level or none)

Special Conditions:
  - Computer Core + Sensors combined levels ≥ 6
  - Life Support Level 2+ (long-term missions)
  - Must have ALL 10 systems installed
```

**Class Bonuses:**
- **Research bonus** - +50% XP from science missions
- **Advanced scanning** - Can identify rare materials and hidden caches
- **Data analysis** - 40% faster Computer Core calculations
- **Scientific authority** - Access to exclusive research contracts
- **Anomaly detection** - Automatically detect nearby phenomena

**Recognition Message:**
> "Ship configuration analyzed. Classification: **SCIENCE VESSEL-CLASS**. Your vessel's sophisticated sensor arrays and advanced computer systems qualify it for scientific research operations. Recommended deployment: stellar phenomena analysis, xenoarchaeology, first contact support."

---

### 5. Destroyer-Class

**Role:** Medium combat operations and tactical superiority

**Description:**
Destroyers are dedicated combat vessels with significant firepower and protection. Larger and more powerful than frigates, destroyers can engage multiple targets simultaneously and withstand sustained combat. They're the backbone of any defensive fleet.

**Ideal For:** Players who want strong combat capabilities

**Requirements:**
```yaml
Required Systems:
  - Hull (minimum Level 3) ★★
  - Power Core (minimum Level 3) ★★
  - Propulsion (minimum Level 2)
  - Warp Drive (minimum Level 2)
  - Life Support (minimum Level 2)
  - Computer Core (minimum Level 2)
  - Shields (minimum Level 3) ★★
  - Weapons (minimum Level 3) ★★

Optional Systems:
  - Sensors, Communications (any level)

Special Conditions:
  - Weapons + Shields combined levels ≥ 6
  - Hull Level 3+ (reinforced structure)
  - Power generation ≥ 120 MW
  - Must have ALL 10 systems installed
```

**Class Bonuses:**
- **Combat superiority** - +20% weapon damage, +20% shield strength
- **Multi-target systems** - Can engage 2 enemies simultaneously
- **Armor rating** - Take 15% less hull damage
- **Tactical command** - Can lead small combat groups
- **Intimidation** - Some enemies will flee without fighting

**Recognition Message:**
> "Ship configuration analyzed. Classification: **DESTROYER-CLASS**. Your vessel's substantial weapons arrays and defensive systems qualify it for frontline combat operations. Recommended deployment: fleet combat, system defense, hostile territory penetration."

---

### 6. Cruiser-Class

**Role:** General-purpose operations and long-duration missions

**Description:**
Cruisers are the quintessential "jack of all trades" starship. With balanced systems across all categories, cruisers can handle exploration, combat, diplomacy, and trade with equal competence. They're reliable, versatile, and can adapt to any mission type.

**Ideal For:** Players who want a balanced, flexible ship

**Requirements:**
```yaml
Required Systems:
  - Hull (minimum Level 2)
  - Power Core (minimum Level 2)
  - Propulsion (minimum Level 2)
  - Warp Drive (minimum Level 2)
  - Life Support (minimum Level 2)
  - Computer Core (minimum Level 2)
  - Sensors (minimum Level 2)
  - Shields (minimum Level 2)
  - Weapons (minimum Level 2)
  - Communications (minimum Level 2)

Special Conditions:
  - ALL 10 systems installed
  - ALL systems at Level 2+
  - No single system more than 2 levels higher than any other
  - Total system levels ≥ 25
```

**Class Bonuses:**
- **Versatility** - +10% effectiveness in ALL mission types
- **Resource efficiency** - 15% reduction in repair costs and fuel usage
- **Crew morale** - Balanced systems improve crew effectiveness (+10% all skills)
- **Mission variety** - Access to all mission types
- **Reliability** - Systems 25% less likely to malfunction

**Recognition Message:**
> "Ship configuration analyzed. Classification: **CRUISER-CLASS**. Your vessel's balanced system configuration qualifies it for general-purpose operations. Recommended deployment: independent patrol, multi-role missions, frontier operations requiring adaptability."

---

### 7. Heavy Cruiser-Class

**Role:** Heavy combat with extended operational range

**Description:**
Heavy cruisers combine cruiser versatility with destroyer-level firepower. These powerful vessels can both fight and explore, making them ideal for missions in hostile territory. Heavy cruisers are expensive to operate but provide unmatched capability in dangerous space.

**Ideal For:** Players who want combat power without sacrificing utility

**Requirements:**
```yaml
Required Systems:
  - Hull (minimum Level 3) ★★
  - Power Core (minimum Level 3) ★★
  - Propulsion (minimum Level 2)
  - Warp Drive (minimum Level 3) ★★
  - Life Support (minimum Level 3)
  - Computer Core (minimum Level 3)
  - Sensors (minimum Level 2)
  - Shields (minimum Level 3) ★★
  - Weapons (minimum Level 3) ★★
  - Communications (minimum Level 2)

Special Conditions:
  - ALL 10 systems installed
  - Hull + Power + Shields + Weapons all Level 3+
  - Total system levels ≥ 30
  - Power generation ≥ 150 MW
```

**Class Bonuses:**
- **Heavy combat** - +25% weapon damage, +25% shield strength
- **Endurance** - +50% mission duration before needing resupply
- **Command authority** - Can coordinate multiple ships in combat
- **Priority target** - Some enemies will focus on you (protect weaker allies)
- **Reduced maintenance** - Systems last 30% longer between repairs

**Recognition Message:**
> "Ship configuration analyzed. Classification: **HEAVY CRUISER-CLASS**. Your vessel's formidable combat capability combined with extended operational range qualifies it for independent heavy operations. Recommended deployment: deep space patrol, high-risk missions, fleet command operations."

---

### 8. Explorer-Class

**Role:** Long-range deep space exploration and first contact

**Description:**
Explorers represent humanity's drive to seek out new worlds and civilizations. These ships are built for multi-year missions into uncharted space, with advanced sensors, powerful warp drives, and comprehensive scientific capabilities. Explorers are the vanguard of discovery.

**Ideal For:** Players who want to go where no one has gone before

**Requirements:**
```yaml
Required Systems:
  - Hull (minimum Level 3)
  - Power Core (minimum Level 3)
  - Propulsion (minimum Level 2)
  - Warp Drive (minimum Level 4) ★★★
  - Life Support (minimum Level 3) ★★
  - Computer Core (minimum Level 3) ★★
  - Sensors (minimum Level 4) ★★★
  - Shields (minimum Level 2)
  - Weapons (minimum Level 2)
  - Communications (minimum Level 3) ★★

Special Conditions:
  - Warp Drive Level 4+ (extended range FTL)
  - Sensors Level 4+ (deep space scanning)
  - Life Support Level 3+ (long-duration support)
  - ALL 10 systems installed
  - Total system levels ≥ 32
```

**Class Bonuses:**
- **Extended range** - +100% Warp Drive range per fuel unit
- **Deep space sensors** - Detect phenomena and systems from extreme distance
- **First contact protocols** - +25% success in diplomatic missions
- **Explorer's privilege** - Can name discovered systems/phenomena
- **Scientific prestige** - Double XP from exploration and science missions
- **Resource prospecting** - Can detect rare resources from orbit

**Recognition Message:**
> "Ship configuration analyzed. Classification: **EXPLORER-CLASS**. Your vessel's exceptional warp capability and sensor range qualify it for deep space exploration. Recommended deployment: uncharted territory survey, first contact missions, extended-range scientific exploration. Your ship represents humanity's finest tradition of discovery."

---

### 9. Dreadnought-Class

**Role:** Maximum firepower and survivability

**Description:**
Dreadnoughts are the ultimate expression of military power. These massive warships mount overwhelming firepower and nearly impenetrable defenses. Building a dreadnought requires extensive resources and technical expertise, but the result is a ship that can face any threat.

**Ideal For:** Players who want to dominate through military might

**Requirements:**
```yaml
Required Systems:
  - Hull (minimum Level 4) ★★★
  - Power Core (minimum Level 4) ★★★
  - Propulsion (minimum Level 3)
  - Warp Drive (minimum Level 3)
  - Life Support (minimum Level 3)
  - Computer Core (minimum Level 3)
  - Sensors (minimum Level 3)
  - Shields (minimum Level 4) ★★★
  - Weapons (minimum Level 4) ★★★
  - Communications (minimum Level 3)

Special Conditions:
  - Hull Level 4+ (maximum structural integrity)
  - Weapons Level 4+ (heavy armament)
  - Shields Level 4+ (advanced protection)
  - Power Core Level 4+ (massive power generation)
  - ALL 10 systems installed
  - Total system levels ≥ 38
  - Power generation ≥ 200 MW
```

**Class Bonuses:**
- **Overwhelming firepower** - +40% weapon damage
- **Superior defense** - +40% shield strength, +25% armor
- **Multi-target engagement** - Can engage 3 enemies simultaneously
- **Area denial** - Enemies less likely to engage in your presence
- **Combat supremacy** - +50% XP from combat missions
- **Intimidating presence** - Some factions will negotiate rather than fight
- **Heavy weapons access** - Can equip special heavy weapon systems

**Recognition Message:**
> "Ship configuration analyzed. Classification: **DREADNOUGHT-CLASS**. Your vessel's exceptional combat systems qualify it as a capital-class warship. WARNING: Operating a vessel of this classification may affect diplomatic relations. Recommended deployment: major threat response, territory defense, show-of-force operations."

---

### 10. Support Vessel-Class

**Role:** Logistics, repair, and fleet support operations

**Description:**
Support vessels are the unsung heroes of spacefaring civilization. While not glamorous, these ships keep fleets operational through repair capabilities, cargo transport, and resource management. Support vessels excel at long-term missions where sustainability matters more than combat power.

**Ideal For:** Players who prefer resource management and support roles

**Requirements:**
```yaml
Required Systems:
  - Hull (minimum Level 2)
  - Power Core (minimum Level 3) ★★
  - Propulsion (minimum Level 2)
  - Warp Drive (minimum Level 2)
  - Life Support (minimum Level 3) ★★
  - Computer Core (minimum Level 3) ★★
  - Sensors (minimum Level 2)
  - Shields (minimum Level 2)
  - Communications (minimum Level 3) ★★

Optional Systems:
  - Weapons (any level or none)

Special Conditions:
  - Life Support Level 3+ (extended crew capacity)
  - Computer Core Level 3+ (logistics management)
  - Power Core Level 3+ (support operations)
  - Resource capacity ≥ 200 units (cargo)
  - Can be missing Weapons system
```

**Class Bonuses:**
- **Resource efficiency** - 30% reduction in all resource consumption
- **Repair capability** - Can repair systems in the field (50% effectiveness)
- **Extended supplies** - +100% inventory capacity
- **Logistics mastery** - 25% better prices when trading
- **Support operations** - Can resupply other ships (if crew system active)
- **Salvage expertise** - Find 30% more materials when salvaging

**Recognition Message:**
> "Ship configuration analyzed. Classification: **SUPPORT VESSEL-CLASS**. Your vessel's emphasis on logistics and sustainability qualifies it for fleet support operations. Recommended deployment: long-duration missions, resource transport, fleet maintenance operations, frontier colony support."

---

## Classification Requirements

### Summary Table

| Class | Minimum Level | Key Systems | Power Req. | Special |
|-------|--------------|-------------|------------|---------|
| **Scout** | 12 total | Propulsion 2, Sensors 2 | 60 MW | Power efficiency ≤60% |
| **Courier** | 14 total | Propulsion 3, Warp 2, Comms 2 | 80 MW | Prop+Warp ≥5 levels |
| **Frigate** | 16 total | Hull 2, Weapons 2, Shields 2 | 80 MW | Wpn+Shld ≥4 levels |
| **Science** | 20 total | Computer 3, Sensors 3 | 100 MW | All 10 systems, Comp+Sens ≥6 |
| **Destroyer** | 24 total | Hull 3, Weapons 3, Shields 3 | 120 MW | All 10 systems, Wpn+Shld ≥6 |
| **Cruiser** | 25 total | All systems Level 2 | 100 MW | All 10 systems, balanced build |
| **Heavy Cruiser** | 30 total | Hull/Pwr/Shld/Wpn all 3+ | 150 MW | All 10 systems |
| **Explorer** | 32 total | Warp 4, Sensors 4, Life 3 | 140 MW | All 10 systems |
| **Dreadnought** | 38 total | Hull/Pwr/Shld/Wpn all 4+ | 200 MW | All 10 systems, max combat |
| **Support** | 22 total | Power 3, Life 3, Comp 3, Comms 3 | 100 MW | High capacity, low combat |

**Notes:**
- "Total levels" = sum of all system levels (e.g., all Level 2 = 20 total)
- Key Systems = must be at stated level minimum
- Power Req. = minimum power generation from Power Core
- All classes require basic ship operation (Hull 1, Power 1, Life 1 minimum)

---

## Class Benefits

### Passive Bonuses

**All classes provide:**
- Unique ship designation (shown in UI)
- Achievement unlock and recognition
- Class-specific stat bonuses (detailed in each class section)
- Updated ship manual with class information

### Active Abilities

**Some classes unlock special abilities:**

**Scout-Class:**
- **Stealth Scan** - Scan without being detected (once per mission)

**Courier-Class:**
- **Emergency Boost** - +50% speed for 30 seconds (2x per mission, cooldown 10 minutes)

**Frigate-Class:**
- **Tactical Strike** - Precise weapon strike with +50% accuracy (3x per combat)

**Science Vessel:**
- **Deep Analysis** - Reveal all enemy stats and weaknesses (unlimited, 1 minute cooldown)

**Destroyer-Class:**
- **Broadside** - Fire all weapons simultaneously at multiple targets (2x per combat)

**Cruiser-Class:**
- **Adaptability** - Temporarily boost any one system by 1 level (lasts 10 minutes, 1x per mission)

**Heavy Cruiser:**
- **Fleet Command** - Coordinate allied ships for +25% effectiveness (requires crew/allies)

**Explorer-Class:**
- **Long-Range Scan** - Scan adjacent star systems without traveling (unlimited, costs fuel)

**Dreadnought-Class:**
- **Overwhelming Force** - +100% damage for 15 seconds (1x per combat, dramatic effect)

**Support Vessel:**
- **Emergency Repairs** - Repair 25% hull damage mid-mission (2x per mission)

---

## Recognition System

### Classification Process

```gdscript
# Classification check flow
func check_ship_classification():
    var current_config = get_ship_configuration()
    var qualifying_classes = []

    for ship_class in SHIP_CLASSES:
        if meets_requirements(current_config, ship_class):
            qualifying_classes.append(ship_class)

    if qualifying_classes.size() > 0:
        return select_best_match(qualifying_classes)
    else:
        return "UNCLASSIFIED"
```

### Classification Tiers

Ships progress through tiers as they're built:

**Tier 0: Unclassified**
- Less than 7 systems installed
- Does not meet any class requirements
- Designation: "SS [Name] - Unclassified"

**Tier 1: Basic Classifications**
- Scout, Courier, Frigate (12-16 total levels)
- Early-game achievable
- Basic bonuses and recognition

**Tier 2: Specialized Classifications**
- Science Vessel, Destroyer, Cruiser, Support (20-25 total levels)
- Mid-game achievements
- Significant bonuses and special abilities

**Tier 3: Advanced Classifications**
- Heavy Cruiser, Explorer (30-32 total levels)
- Late-game achievements
- Major bonuses and prestigious recognition

**Tier 4: Elite Classifications**
- Dreadnought (38+ total levels)
- End-game achievement
- Maximum bonuses and legendary status

### Recognition Ceremony

When a ship achieves classification:

```
┌──────────────────────────────────────────────────┐
│ ⚠️  SHIP COMPUTER ALERT                          │
├──────────────────────────────────────────────────┤
│                                                  │
│ Ship system configuration analysis complete.    │
│                                                  │
│ CLASSIFICATION CRITERIA MET:                    │
│ ▸ EXPLORER-CLASS                                │
│                                                  │
│ Your vessel now qualifies for official          │
│ classification as an Explorer-class starship.   │
│                                                  │
│ NEW DESIGNATION:                                 │
│ SS Endeavor - Explorer-class                    │
│                                                  │
│ CLASS BONUSES UNLOCKED:                          │
│ • Extended range (+100% warp efficiency)        │
│ • Deep space sensors                            │
│ • First contact protocols (+25% diplomacy)      │
│ • Explorer's privilege (naming rights)          │
│ • Scientific prestige (2x XP science missions)  │
│                                                  │
│ [View Ship Manual] [Accept Classification]      │
│                                                  │
└──────────────────────────────────────────────────┘
```

### Ship Designation Format

```
SS [Ship Name] - [Class]-class

Examples:
- SS Endeavor - Explorer-class
- SS Defiant - Destroyer-class
- SS Enterprise - Heavy Cruiser-class
- SS Voyager - Explorer-class
- SS Phoenix - Scout-class
```

**SS = Salvage Ship** (post-Exodus era designation for civilian-built vessels)

Alternative prefixes players might earn:
- **ISS** (Independent Space Ship) - Achieved by completing 50 missions
- **FSS** (Free Space Ship) - Achieved by helping 10 colonies
- **ESS** (Exploration Space Ship) - Achieved by discovering 20 systems (Phase 2)

---

## Multi-Classing

### Qualifying for Multiple Classes

**A ship can meet requirements for multiple classes simultaneously.**

Example: A ship with all Level 3 systems qualifies for:
- Cruiser (all systems Level 2+, balanced)
- Heavy Cruiser (Hull/Power/Shields/Weapons Level 3+)
- Destroyer (Weapons/Shields Level 3+, all systems installed)

### Primary Classification

**The game selects the "best" match based on priority:**

1. **Highest Tier** - Advanced classes take priority over basic
2. **Most Specialized** - Specific builds (Explorer, Dreadnought) over generic (Cruiser)
3. **Player Choice** - If multiple same-tier classes qualify, player chooses

**Priority Order (highest to lowest):**
1. Dreadnought (Tier 4)
2. Explorer (Tier 3)
3. Heavy Cruiser (Tier 3)
4. Science Vessel (Tier 2)
5. Destroyer (Tier 2)
6. Cruiser (Tier 2)
7. Support Vessel (Tier 2)
8. Frigate (Tier 1)
9. Courier (Tier 1)
10. Scout (Tier 1)

### Reclass Option

**Players can manually choose a different qualifying class:**

```
Your ship qualifies for:
○ Heavy Cruiser-class (recommended)
○ Cruiser-class
○ Destroyer-class

[Select Classification]
```

**Note:** Can reclass at any time by accessing Ship Computer, but achievements are only awarded once per class on first achievement.

---

## Implementation

### Data Structure

```gdscript
# godot/scripts/autoload/ship_classification.gd
extends Node

const SHIP_CLASSES = {
    "scout": {
        "name": "Scout-class",
        "tier": 1,
        "description": "Fast reconnaissance and data gathering",
        "requirements": {
            "systems_required": ["hull", "power", "propulsion", "warp", "life_support", "computer", "sensors"],
            "min_levels": {
                "propulsion": 2,
                "sensors": 2
            },
            "power_min": 60,
            "special": {
                "power_efficiency": 0.60,  # power used / power available <= 60%
                "max_level_any_system": 3  # no system above Level 3
            }
        },
        "bonuses": {
            "propulsion_efficiency": 1.25,
            "sensor_range": 1.50,
            "evasion": 0.15,
            "scan_speed": 0.70  # 30% faster = 0.70x time
        },
        "abilities": ["stealth_scan"]
    },

    # ... other classes
}

func get_qualifying_classes(ship_state: Dictionary) -> Array:
    """Check which classes the current ship configuration qualifies for"""
    var qualifying = []

    for class_id in SHIP_CLASSES:
        if check_class_requirements(ship_state, class_id):
            qualifying.append(class_id)

    return qualifying

func check_class_requirements(ship_state: Dictionary, class_id: String) -> bool:
    """Check if ship meets all requirements for a class"""
    var class_data = SHIP_CLASSES[class_id]
    var reqs = class_data.requirements
    var ship = ship_state.ship

    # Check required systems installed
    for sys in reqs.systems_required:
        if not ship.systems.has(sys) or ship.systems[sys].level == 0:
            return false

    # Check minimum levels
    for sys in reqs.min_levels:
        if ship.systems[sys].level < reqs.min_levels[sys]:
            return false

    # Check power requirement
    if ship.power_total < reqs.power_min:
        return false

    # Check special conditions
    if reqs.has("special"):
        if not check_special_conditions(ship, reqs.special):
            return false

    return true

func select_best_classification(qualifying_classes: Array) -> String:
    """Select the best classification from multiple qualifying classes"""
    if qualifying_classes.size() == 0:
        return "unclassified"

    # Sort by tier (highest first), then by priority
    qualifying_classes.sort_custom(func(a, b):
        var tier_a = SHIP_CLASSES[a].tier
        var tier_b = SHIP_CLASSES[b].tier
        if tier_a != tier_b:
            return tier_a > tier_b
        return get_class_priority(a) < get_class_priority(b)
    )

    return qualifying_classes[0]

func get_class_priority(class_id: String) -> int:
    """Priority order for classification selection"""
    var priority_order = [
        "dreadnought", "explorer", "heavy_cruiser",
        "science_vessel", "destroyer", "cruiser", "support_vessel",
        "frigate", "courier", "scout"
    ]
    return priority_order.find(class_id)

func apply_class_bonuses(class_id: String):
    """Apply bonuses for the current classification"""
    if class_id == "unclassified":
        return

    var class_data = SHIP_CLASSES[class_id]
    var bonuses = class_data.bonuses

    # Store bonuses in GameState for easy access
    GameState.active_class = class_id
    GameState.class_bonuses = bonuses.duplicate()

    # Update ship designation
    var ship_name = GameState.ship.name
    GameState.ship.designation = "SS %s - %s" % [ship_name, class_data.name]

    # Emit signal for UI updates
    EventBus.emit_signal("ship_classified", class_id, class_data.name)
```

### Python API Endpoint

```python
# python/src/api/classification.py

from fastapi import APIRouter
from pydantic import BaseModel
from typing import Dict, List, Optional

router = APIRouter(prefix="/api/classification", tags=["classification"])

class ClassificationRequest(BaseModel):
    ship_state: Dict

class ClassificationResponse(BaseModel):
    current_class: str
    qualifying_classes: List[str]
    class_info: Dict
    bonuses: Dict
    can_reclass: bool
    alternative_classes: List[str]

@router.post("/check", response_model=ClassificationResponse)
async def check_classification(request: ClassificationRequest):
    """
    Check current ship classification and qualifying alternatives
    """
    from ..game.ship_classification import ShipClassification

    classifier = ShipClassification()
    qualifying = classifier.get_qualifying_classes(request.ship_state)

    if not qualifying:
        return ClassificationResponse(
            current_class="unclassified",
            qualifying_classes=[],
            class_info={},
            bonuses={},
            can_reclass=False,
            alternative_classes=[]
        )

    best_class = classifier.select_best_classification(qualifying)
    class_info = classifier.get_class_info(best_class)
    bonuses = class_info["bonuses"]

    # Alternative classes (same tier or one tier below)
    alternatives = [c for c in qualifying if c != best_class]

    return ClassificationResponse(
        current_class=best_class,
        qualifying_classes=qualifying,
        class_info=class_info,
        bonuses=bonuses,
        can_reclass=len(alternatives) > 0,
        alternative_classes=alternatives
    )

@router.post("/reclass/{class_id}")
async def reclass_ship(class_id: str, ship_state: Dict):
    """Manually change ship classification to a qualifying class"""
    # Verify ship qualifies for requested class
    # Apply new classification
    # Return updated state
    pass
```

### UI Integration

```gdscript
# Ship Status UI showing classification
┌────────────────────────────────────────┐
│ SHIP STATUS                            │
├────────────────────────────────────────┤
│                                        │
│ SS Endeavor - Explorer-class           │
│ ════════════════════════════════════   │
│                                        │
│ Classification: EXPLORER-CLASS         │
│ Tier: 3 (Advanced)                    │
│                                        │
│ Active Bonuses:                        │
│ • Extended range (+100%)               │
│ • Deep space sensors                   │
│ • First contact protocols (+25%)       │
│                                        │
│ [View Class Details]                   │
│ [Reclass Options] (2 available)        │
│                                        │
└────────────────────────────────────────┘
```

---

## Design Notes

### Balance Considerations

1. **No class is strictly better** - Each serves different playstyles
2. **Early classes are achievable** - Players can get Scout/Courier with minimal investment
3. **Elite classes require commitment** - Dreadnought/Explorer need significant resources
4. **Replayability** - Different classes encourage different build paths

### Integration with Existing Systems

**Ship Systems (ship-systems.md):**
- Classification uses existing system levels
- Bonuses stack with system capabilities
- No new systems required

**Mission Framework (mission-framework.md):**
- Some missions require specific classifications
- Class bonuses affect mission success rates
- Class-specific mission types unlock

**Resources (resources-survival.md):**
- Higher-tier classes have higher maintenance costs
- Class bonuses affect resource consumption
- Some classes get resource efficiency bonuses

**Crew System (crew-companion-system.md):**
- Classification affects crew morale
- Some classes enable crew-specific abilities
- Crew size recommendations per class

---

**Document Complete**
**Last Updated:** November 5, 2025
