# Data Schema Specifications

**Version:** 1.0
**Date:** 2025-11-07
**Purpose:** Complete JSON schema specifications for economy system data files
**Milestone:** Milestone 1

---

## Table of Contents
1. [Overview](#overview)
2. [Part Files Schema](#part-files-schema)
3. [Example Parts by System](#example-parts-by-system)
4. [System Configuration Schema](#system-configuration-schema)
5. [Economy Configuration Schema](#economy-configuration-schema)
6. [Mission Rewards Schema](#mission-rewards-schema)
7. [Validation Rules](#validation-rules)
8. [File Relationships](#file-relationships)

---

## Overview

### Directory Structure
```
godot/assets/data/
├── parts/                          # Ship part definitions
│   ├── hull_parts.json
│   ├── power_parts.json
│   ├── propulsion_parts.json
│   ├── warp_parts.json
│   ├── life_support_parts.json
│   ├── computer_parts.json
│   ├── sensors_parts.json
│   ├── shields_parts.json
│   ├── weapons_parts.json
│   └── communications_parts.json
├── systems/                        # System configurations
│   └── ship_systems.json
├── economy/                        # Economy rules
│   └── economy_config.json
└── missions/                       # Mission definitions
    └── *.json                      # Individual mission files
```

### Design Principles
- **Data-Driven:** All game balance in JSON, not code
- **Extensible:** Easy to add new parts/systems
- **Validated:** Schema ensures data integrity
- **Human-Readable:** Clear structure for content creators
- **Versionable:** Git-friendly format

---

## Part Files Schema

### Base Part Schema

All part files follow this schema:

```json
{
  "version": "1.0.0",
  "system_type": "hull|power|propulsion|warp|life_support|computer|sensors|shields|weapons|communications",
  "parts": [
    {
      "id": "unique_part_id",
      "name": "Display Name",
      "description": "Flavor text describing the part (1-2 sentences)",
      "system_type": "hull",
      "level": 1,
      "rarity": "common|uncommon|rare",
      "weight": 10.0,
      "stats": {
        "key": "value"
      },
      "discovered": false,
      "story_unlock": "mission_id or null"
    }
  ]
}
```

### Field Descriptions

| Field | Type | Required | Description | Validation |
|-------|------|----------|-------------|------------|
| `id` | String | Yes | Unique identifier (system_partname_lX_rarity) | Must be unique across all parts |
| `name` | String | Yes | Display name shown to player | 3-50 characters |
| `description` | String | Yes | Flavor text and lore | 10-200 characters |
| `system_type` | String | Yes | Which system this part belongs to | Must match file name |
| `level` | Integer | Yes | System level this part enables | 1-5 |
| `rarity` | String | Yes | Rarity tier | common, uncommon, or rare |
| `weight` | Float | Yes | Inventory weight in kg | 0.1-100.0 |
| `stats` | Object | Yes | System-specific stats (see below) | Varies by system |
| `discovered` | Boolean | Yes | Whether part starts unlocked | Default: false |
| `story_unlock` | String/null | Yes | Mission ID that unlocks this part | null if discovered from start |

### Rarity Tier Guidelines

**Common (70% of parts):**
- Basic functionality
- Widely available
- Lower stats
- Most missions reward these

**Uncommon (25% of parts):**
- Improved functionality
- Moderate stats
- Specialized missions
- Some story unlocks

**Rare (5% of parts):**
- Best-in-tier stats
- Special abilities
- Story-locked
- Hard missions only

### Stat Objects by System Type

Each system has unique stats:

**Hull Stats:**
```json
"stats": {
  "max_hp": 50,
  "armor_kinetic": 5,
  "armor_energy": 0
}
```

**Power Stats:**
```json
"stats": {
  "power_output": 100,
  "efficiency": 80
}
```

**Propulsion Stats:**
```json
"stats": {
  "speed": 1.0,
  "agility": 5,
  "power_cost": 10
}
```

**Warp Stats:**
```json
"stats": {
  "warp_factor": 1,
  "range_ly": 2,
  "power_cost": 20
}
```

**Life Support Stats:**
```json
"stats": {
  "crew_capacity": 1,
  "radiation_protection": 10,
  "power_cost": 5
}
```

**Computer Stats:**
```json
"stats": {
  "processing_power": 1,
  "accuracy_bonus": 0,
  "power_cost": 5
}
```

**Sensors Stats:**
```json
"stats": {
  "range_au": 1,
  "detection_quality": 1,
  "power_cost": 5
}
```

**Shields Stats:**
```json
"stats": {
  "shield_hp": 50,
  "damage_reduction": 25,
  "recharge_rate": 5,
  "power_cost": 15
}
```

**Weapons Stats:**
```json
"stats": {
  "damage_min": 15,
  "damage_max": 25,
  "accuracy": 70,
  "power_cost": 10
}
```

**Communications Stats:**
```json
"stats": {
  "range_class": "short|system|galaxy|unlimited",
  "diplomacy_bonus": 0,
  "power_cost": 5
}
```

---

## Example Parts by System

### Hull Parts (hull_parts.json)

```json
{
  "version": "1.0.0",
  "system_type": "hull",
  "parts": [
    {
      "id": "hull_scrap_plates_l1_common",
      "name": "Scrap Hull Plates",
      "description": "Salvaged metal plates welded together. It'll hold... probably.",
      "system_type": "hull",
      "level": 1,
      "rarity": "common",
      "weight": 25.0,
      "stats": {
        "max_hp": 50,
        "armor_kinetic": 5,
        "armor_energy": 0
      },
      "discovered": false,
      "story_unlock": "tutorial_first_salvage"
    },
    {
      "id": "hull_reinforced_plates_l1_uncommon",
      "name": "Reinforced Hull Plates",
      "description": "Proper spacecraft-grade plating. Pre-exodus manufacturing quality.",
      "system_type": "hull",
      "level": 1,
      "rarity": "uncommon",
      "weight": 30.0,
      "stats": {
        "max_hp": 60,
        "armor_kinetic": 7,
        "armor_energy": 2
      },
      "discovered": false,
      "story_unlock": null
    },
    {
      "id": "hull_composite_armor_l1_rare",
      "name": "Composite Armor Plating",
      "description": "Military-grade composite armor. Whoever had this knew combat was coming.",
      "system_type": "hull",
      "level": 1,
      "rarity": "rare",
      "weight": 35.0,
      "stats": {
        "max_hp": 75,
        "armor_kinetic": 10,
        "armor_energy": 5
      },
      "discovered": false,
      "story_unlock": "mission_military_depot"
    },
    {
      "id": "hull_reinforced_structure_l2_common",
      "name": "Reinforced Hull Structure",
      "description": "Structural beams and stress-rated plating. A proper starship hull.",
      "system_type": "hull",
      "level": 2,
      "rarity": "common",
      "weight": 40.0,
      "stats": {
        "max_hp": 100,
        "armor_kinetic": 15,
        "armor_energy": 5
      },
      "discovered": false,
      "story_unlock": null
    },
    {
      "id": "hull_ablative_coating_l2_uncommon",
      "name": "Ablative-Coated Hull",
      "description": "Heat-dispersing coating that sacrifices layers to absorb energy impacts.",
      "system_type": "hull",
      "level": 2,
      "rarity": "uncommon",
      "weight": 45.0,
      "stats": {
        "max_hp": 120,
        "armor_kinetic": 18,
        "armor_energy": 10
      },
      "discovered": false,
      "story_unlock": "mission_research_facility"
    },
    {
      "id": "hull_composite_alloy_l3_common",
      "name": "Composite Alloy Hull",
      "description": "Advanced alloy combining strength and flexibility. Standard for deep-space vessels.",
      "system_type": "hull",
      "level": 3,
      "rarity": "common",
      "weight": 50.0,
      "stats": {
        "max_hp": 200,
        "armor_kinetic": 25,
        "armor_energy": 10
      },
      "discovered": false,
      "story_unlock": null
    },
    {
      "id": "hull_reactive_armor_l3_rare",
      "name": "Reactive Armor Plating",
      "description": "Explosive-reactive armor that detonates outward to deflect incoming fire.",
      "system_type": "hull",
      "level": 3,
      "rarity": "rare",
      "weight": 60.0,
      "stats": {
        "max_hp": 250,
        "armor_kinetic": 35,
        "armor_energy": 15
      },
      "discovered": false,
      "story_unlock": "mission_pirate_stronghold"
    },
    {
      "id": "hull_ablative_plating_l4_placeholder",
      "name": "Advanced Ablative Plating",
      "description": "[Placeholder for Milestone 2] Military-grade ablative armor system.",
      "system_type": "hull",
      "level": 4,
      "rarity": "uncommon",
      "weight": 70.0,
      "stats": {
        "max_hp": 350,
        "armor_kinetic": 35,
        "armor_energy": 20
      },
      "discovered": false,
      "story_unlock": null
    },
    {
      "id": "hull_regenerative_nanomesh_l5_placeholder",
      "name": "Regenerative Nano-Mesh",
      "description": "[Placeholder for Milestone 2] Self-repairing hull using nano-technology.",
      "system_type": "hull",
      "level": 5,
      "rarity": "rare",
      "weight": 80.0,
      "stats": {
        "max_hp": 500,
        "armor_kinetic": 45,
        "armor_energy": 30
      },
      "discovered": false,
      "story_unlock": null
    }
  ]
}
```

### Power Parts (power_parts.json)

```json
{
  "version": "1.0.0",
  "system_type": "power",
  "parts": [
    {
      "id": "power_fusion_cell_l1_common",
      "name": "Fusion Cell",
      "description": "Basic fusion power cell. Enough to get your systems running.",
      "system_type": "power",
      "level": 1,
      "rarity": "common",
      "weight": 20.0,
      "stats": {
        "power_output": 100,
        "efficiency": 80
      },
      "discovered": false,
      "story_unlock": "tutorial_first_salvage"
    },
    {
      "id": "power_enhanced_fusion_l1_uncommon",
      "name": "Enhanced Fusion Cell",
      "description": "Upgraded fusion cell with better magnetic containment.",
      "system_type": "power",
      "level": 1,
      "rarity": "uncommon",
      "weight": 22.0,
      "stats": {
        "power_output": 120,
        "efficiency": 85
      },
      "discovered": false,
      "story_unlock": null
    },
    {
      "id": "power_compact_reactor_l1_rare",
      "name": "Compact Reactor Core",
      "description": "Miniaturized reactor technology. Efficient and powerful.",
      "system_type": "power",
      "level": 1,
      "rarity": "rare",
      "weight": 18.0,
      "stats": {
        "power_output": 150,
        "efficiency": 90
      },
      "discovered": false,
      "story_unlock": "mission_abandoned_station"
    },
    {
      "id": "power_deuterium_reactor_l2_common",
      "name": "Deuterium Reactor",
      "description": "Standard deuterium-fueled reactor. Reliable and proven technology.",
      "system_type": "power",
      "level": 2,
      "rarity": "common",
      "weight": 35.0,
      "stats": {
        "power_output": 200,
        "efficiency": 85
      },
      "discovered": false,
      "story_unlock": null
    },
    {
      "id": "power_antimatter_core_l2_uncommon",
      "name": "Matter/Antimatter Core",
      "description": "Containment breach is catastrophic, but the power output is incredible.",
      "system_type": "power",
      "level": 2,
      "rarity": "uncommon",
      "weight": 40.0,
      "stats": {
        "power_output": 250,
        "efficiency": 88
      },
      "discovered": false,
      "story_unlock": "mission_research_facility"
    },
    {
      "id": "power_advanced_mam_l3_common",
      "name": "Advanced M/AM Reactor",
      "description": "The workhorse of modern starships. Proven antimatter technology.",
      "system_type": "power",
      "level": 3,
      "rarity": "common",
      "weight": 50.0,
      "stats": {
        "power_output": 400,
        "efficiency": 90
      },
      "discovered": false,
      "story_unlock": null
    },
    {
      "id": "power_zero_point_tap_l3_rare",
      "name": "Zero-Point Energy Tap",
      "description": "Experimental quantum technology. Draws power from vacuum fluctuations.",
      "system_type": "power",
      "level": 3,
      "rarity": "rare",
      "weight": 45.0,
      "stats": {
        "power_output": 500,
        "efficiency": 95
      },
      "discovered": false,
      "story_unlock": "mission_quantum_lab"
    }
  ]
}
```

### Propulsion Parts (propulsion_parts.json)

```json
{
  "version": "1.0.0",
  "system_type": "propulsion",
  "parts": [
    {
      "id": "propulsion_chemical_thrusters_l1_common",
      "name": "Chemical Thrusters",
      "description": "Old reliable. Chemical rockets for basic maneuvering.",
      "system_type": "propulsion",
      "level": 1,
      "rarity": "common",
      "weight": 15.0,
      "stats": {
        "speed": 1.0,
        "agility": 5,
        "power_cost": 10
      },
      "discovered": false,
      "story_unlock": "tutorial_first_salvage"
    },
    {
      "id": "propulsion_ion_drive_l1_uncommon",
      "name": "Ion Drive",
      "description": "Electric propulsion. Slow acceleration but very efficient.",
      "system_type": "propulsion",
      "level": 1,
      "rarity": "uncommon",
      "weight": 18.0,
      "stats": {
        "speed": 1.3,
        "agility": 7,
        "power_cost": 8
      },
      "discovered": false,
      "story_unlock": null
    },
    {
      "id": "propulsion_hybrid_engine_l1_rare",
      "name": "Hybrid Propulsion",
      "description": "Chemical thrust with ion efficiency. Best of both worlds.",
      "system_type": "propulsion",
      "level": 1,
      "rarity": "rare",
      "weight": 20.0,
      "stats": {
        "speed": 1.5,
        "agility": 10,
        "power_cost": 9
      },
      "discovered": false,
      "story_unlock": "mission_engine_depot"
    },
    {
      "id": "propulsion_plasma_engine_l2_common",
      "name": "Plasma Engine",
      "description": "Standard plasma propulsion. Fast and responsive.",
      "system_type": "propulsion",
      "level": 2,
      "rarity": "common",
      "weight": 25.0,
      "stats": {
        "speed": 2.0,
        "agility": 10,
        "power_cost": 15
      },
      "discovered": false,
      "story_unlock": null
    },
    {
      "id": "propulsion_magnetic_nozzle_l2_uncommon",
      "name": "Magnetic Nozzle Drive",
      "description": "Magnetically-accelerated plasma. Exceptional maneuverability.",
      "system_type": "propulsion",
      "level": 2,
      "rarity": "uncommon",
      "weight": 28.0,
      "stats": {
        "speed": 2.5,
        "agility": 18,
        "power_cost": 14
      },
      "discovered": false,
      "story_unlock": "mission_racer_cache"
    },
    {
      "id": "propulsion_gravitic_drive_l3_common",
      "name": "Gravitic Drive",
      "description": "Gravity manipulation for propulsion. Impossibly agile.",
      "system_type": "propulsion",
      "level": 3,
      "rarity": "common",
      "weight": 35.0,
      "stats": {
        "speed": 4.0,
        "agility": 18,
        "power_cost": 25
      },
      "discovered": false,
      "story_unlock": null
    },
    {
      "id": "propulsion_inertial_dampener_l3_rare",
      "name": "Inertial Dampener Drive",
      "description": "Negates inertia. Stop on a dime, turn impossibly fast.",
      "system_type": "propulsion",
      "level": 3,
      "rarity": "rare",
      "weight": 30.0,
      "stats": {
        "speed": 5.0,
        "agility": 40,
        "power_cost": 22
      },
      "discovered": false,
      "story_unlock": "mission_experimental_lab"
    }
  ]
}
```

### Warp Parts (warp_parts.json)

```json
{
  "version": "1.0.0",
  "system_type": "warp",
  "parts": [
    {
      "id": "warp_basic_core_l1_common",
      "name": "Basic Warp Core",
      "description": "Your ticket off Earth. Barely faster than light, but it counts.",
      "system_type": "warp",
      "level": 1,
      "rarity": "common",
      "weight": 50.0,
      "stats": {
        "warp_factor": 1,
        "range_ly": 2,
        "power_cost": 20
      },
      "discovered": false,
      "story_unlock": "mission_starship_graveyard"
    },
    {
      "id": "warp_enhanced_coils_l1_uncommon",
      "name": "Enhanced Warp Coils",
      "description": "Better field geometry increases efficiency and range.",
      "system_type": "warp",
      "level": 1,
      "rarity": "uncommon",
      "weight": 55.0,
      "stats": {
        "warp_factor": 1,
        "range_ly": 3,
        "power_cost": 18
      },
      "discovered": false,
      "story_unlock": null
    },
    {
      "id": "warp_dilithium_matrix_l1_rare",
      "name": "Dilithium Crystal Matrix",
      "description": "Pure dilithium crystals. Peak Warp 1 performance.",
      "system_type": "warp",
      "level": 1,
      "rarity": "rare",
      "weight": 45.0,
      "stats": {
        "warp_factor": 1,
        "range_ly": 4,
        "power_cost": 15
      },
      "discovered": false,
      "story_unlock": "mission_crystal_caves"
    },
    {
      "id": "warp_w3_drive_l2_common",
      "name": "Warp 3 Drive System",
      "description": "Now we're traveling. The close sectors open up to you.",
      "system_type": "warp",
      "level": 2,
      "rarity": "common",
      "weight": 70.0,
      "stats": {
        "warp_factor": 3,
        "range_ly": 10,
        "power_cost": 30
      },
      "discovered": false,
      "story_unlock": null
    },
    {
      "id": "warp_w5_drive_l3_common",
      "name": "Warp 5 Drive System",
      "description": "Standard deep-space warp drive. The galaxy is yours.",
      "system_type": "warp",
      "level": 3,
      "rarity": "common",
      "weight": 90.0,
      "stats": {
        "warp_factor": 5,
        "range_ly": 50,
        "power_cost": 50
      },
      "discovered": false,
      "story_unlock": null
    }
  ]
}
```

### Life Support Parts (life_support_parts.json)

```json
{
  "version": "1.0.0",
  "system_type": "life_support",
  "parts": [
    {
      "id": "life_support_basic_recycler_l1_common",
      "name": "Basic Air Recycler",
      "description": "Keeps you breathing. That's about it.",
      "system_type": "life_support",
      "level": 1,
      "rarity": "common",
      "weight": 10.0,
      "stats": {
        "crew_capacity": 1,
        "radiation_protection": 10,
        "power_cost": 5
      },
      "discovered": false,
      "story_unlock": "tutorial_first_salvage"
    },
    {
      "id": "life_support_climate_control_l2_common",
      "name": "Climate Control System",
      "description": "Temperature and humidity regulation. Much more comfortable.",
      "system_type": "life_support",
      "level": 2,
      "rarity": "common",
      "weight": 18.0,
      "stats": {
        "crew_capacity": 4,
        "radiation_protection": 30,
        "power_cost": 10
      },
      "discovered": false,
      "story_unlock": null
    },
    {
      "id": "life_support_bio_recycling_l3_common",
      "name": "Advanced Bio-Recycling",
      "description": "Closed-loop life support. Months of self-sufficiency.",
      "system_type": "life_support",
      "level": 3,
      "rarity": "common",
      "weight": 25.0,
      "stats": {
        "crew_capacity": 10,
        "radiation_protection": 50,
        "power_cost": 15
      },
      "discovered": false,
      "story_unlock": null
    }
  ]
}
```

---

## System Configuration Schema

**File:** `godot/assets/data/systems/ship_systems.json`

```json
{
  "version": "1.0.0",
  "systems": [
    {
      "system_name": "hull",
      "display_name": "Hull & Structure",
      "description": "Physical integrity and damage resistance",
      "max_level": 5,
      "milestone_1_max_level": 3,
      "compatible_parts": [
        "hull_scrap_plates_l1_common",
        "hull_reinforced_plates_l1_uncommon",
        "hull_composite_armor_l1_rare",
        "hull_reinforced_structure_l2_common",
        "hull_ablative_coating_l2_uncommon",
        "hull_composite_alloy_l3_common",
        "hull_reactive_armor_l3_rare"
      ],
      "power_costs": [0, 0, 0, 0, 10],
      "base_upgrade_costs": {
        "1": {"credits": 100, "rarity_required": "common"},
        "2": {"credits": 200, "rarity_required": "common"},
        "3": {"credits": 300, "rarity_required": "common"},
        "4": {"credits": 500, "rarity_required": "uncommon"},
        "5": {"credits": 800, "rarity_required": "rare"}
      }
    },
    {
      "system_name": "power",
      "display_name": "Power Core",
      "description": "Energy generation for all ship systems",
      "max_level": 5,
      "milestone_1_max_level": 3,
      "compatible_parts": [
        "power_fusion_cell_l1_common",
        "power_enhanced_fusion_l1_uncommon",
        "power_compact_reactor_l1_rare",
        "power_deuterium_reactor_l2_common",
        "power_antimatter_core_l2_uncommon",
        "power_advanced_mam_l3_common",
        "power_zero_point_tap_l3_rare"
      ],
      "power_costs": [0, 0, 0, 0, 0],
      "base_upgrade_costs": {
        "1": {"credits": 150, "rarity_required": "common"},
        "2": {"credits": 250, "rarity_required": "common"},
        "3": {"credits": 400, "rarity_required": "common"},
        "4": {"credits": 700, "rarity_required": "uncommon"},
        "5": {"credits": 1200, "rarity_required": "rare"}
      }
    },
    {
      "system_name": "propulsion",
      "display_name": "Propulsion (Impulse)",
      "description": "Sub-light maneuvering and combat agility",
      "max_level": 5,
      "milestone_1_max_level": 3,
      "compatible_parts": [
        "propulsion_chemical_thrusters_l1_common",
        "propulsion_ion_drive_l1_uncommon",
        "propulsion_hybrid_engine_l1_rare",
        "propulsion_plasma_engine_l2_common",
        "propulsion_magnetic_nozzle_l2_uncommon",
        "propulsion_gravitic_drive_l3_common",
        "propulsion_inertial_dampener_l3_rare"
      ],
      "power_costs": [10, 15, 25, 40, 60],
      "base_upgrade_costs": {
        "1": {"credits": 100, "rarity_required": "common"},
        "2": {"credits": 200, "rarity_required": "common"},
        "3": {"credits": 350, "rarity_required": "common"},
        "4": {"credits": 600, "rarity_required": "uncommon"},
        "5": {"credits": 1000, "rarity_required": "rare"}
      }
    }
  ]
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `system_name` | String | Internal system identifier (matches GameState key) |
| `display_name` | String | Player-facing name |
| `description` | String | Short description of system purpose |
| `max_level` | Integer | Maximum level (5) |
| `milestone_1_max_level` | Integer | Max level for current milestone (3) |
| `compatible_parts` | Array[String] | Part IDs that work with this system |
| `power_costs` | Array[Integer] | Power consumption per level [L1, L2, L3, L4, L5] |
| `base_upgrade_costs` | Object | Upgrade costs by level (credits + rarity requirement) |

---

## Economy Configuration Schema

**File:** `godot/assets/data/economy/economy_config.json`

```json
{
  "version": "1.0.0",
  "starting_state": {
    "credits": 0,
    "parts": [],
    "discovered_parts": []
  },
  "tutorial_rewards": {
    "credits": 300,
    "parts": [
      {
        "part_id": "hull_scrap_plates_l1_common",
        "quantity": 1,
        "choice": "hull"
      },
      {
        "part_id": "power_fusion_cell_l1_common",
        "quantity": 1,
        "choice": "power"
      }
    ],
    "choice_required": true,
    "choice_type": "one_of"
  },
  "upgrade_cost_formula": {
    "description": "Base cost from ship_systems.json, multiplied by rarity multiplier",
    "rarity_multipliers": {
      "common": 1.0,
      "uncommon": 1.5,
      "rare": 2.0
    }
  },
  "xp_curve": {
    "description": "XP required to reach each level (index 0 = level 1)",
    "levels": [0, 100, 250, 450, 700, 1000]
  },
  "skill_points": {
    "per_level": 2,
    "starting_points": 0,
    "max_skill_level": 10
  },
  "level_cap": {
    "milestone_1": 5,
    "milestone_2": 10,
    "milestone_3": 20
  },
  "inventory": {
    "base_capacity_kg": 100,
    "capacity_per_hull_level": 50,
    "formula": "100 + (50 * hull_level)"
  },
  "mission_reward_ranges": {
    "easy": {
      "credits": [50, 150],
      "xp": [50, 100],
      "parts": ["common"]
    },
    "medium": {
      "credits": [150, 300],
      "xp": [100, 200],
      "parts": ["common", "uncommon"]
    },
    "hard": {
      "credits": [300, 500],
      "xp": [200, 350],
      "parts": ["uncommon", "rare"]
    }
  }
}
```

---

## Mission Rewards Schema

Updated mission JSON structure for rewards:

```json
{
  "mission_id": "tutorial_first_salvage",
  "title": "First Salvage Run",
  "type": "salvage",
  "difficulty": "easy",
  "stages": [ /* ... */ ],
  "rewards": {
    "xp": 100,
    "credits": 300,
    "parts": [
      {
        "part_id": "hull_scrap_plates_l1_common",
        "quantity": 1
      }
    ],
    "choice_reward": {
      "description": "Choose your first system part",
      "options": [
        {
          "part_id": "hull_scrap_plates_l1_common",
          "quantity": 1,
          "label": "Hull Plates"
        },
        {
          "part_id": "power_fusion_cell_l1_common",
          "quantity": 1,
          "label": "Fusion Cell"
        }
      ]
    },
    "story_unlocks": [
      "power_fusion_cell_l1_common",
      "hull_scrap_plates_l1_common"
    ]
  }
}
```

---

## Validation Rules

### Part ID Format
- Pattern: `{system}_{name}_{level}_{ rarity}`
- Example: `hull_scrap_plates_l1_common`
- Must be lowercase with underscores
- Must be unique across all part files

### Weight Limits
- Minimum: 0.1 kg
- Maximum: 100.0 kg
- Precision: 1 decimal place

### Level Constraints
- Valid levels: 1, 2, 3, 4, 5
- Milestone 1: Only levels 1-3 fully defined
- Levels 4-5: Placeholder parts with "[Placeholder]" in description

### Rarity Distribution
Per system, per level:
- Common: 3+ parts (main options)
- Uncommon: 1-2 parts (better stats)
- Rare: 0-1 parts (best stats, story-locked)

### Credit Costs
- Level 1: 100-150 CR base
- Level 2: 200-300 CR base
- Level 3: 300-450 CR base
- Level 4: 500-800 CR base
- Level 5: 800-1500 CR base
- Multiply by rarity multiplier

### XP Curve
Must be monotonically increasing:
- Level 1: 0 XP
- Level 2: 100 XP total
- Level 3: 250 XP total
- Level 4: 450 XP total
- Level 5: 700 XP total
- Level 6+: 1000+ XP total

---

## File Relationships

```
economy_config.json
    ↓ (defines costs)
    ↓
ship_systems.json
    ↓ (references)
    ↓
parts/*.json
    ↑ (part_id references)
    ↑
missions/*.json
```

**Load Order:**
1. economy_config.json (configuration)
2. ship_systems.json (system definitions)
3. parts/*.json (all part definitions)
4. missions/*.json (mission content)

**Validation Flow:**
1. Validate economy_config.json schema
2. Validate ship_systems.json schema
3. Validate all parts/*.json schemas
4. Cross-reference: ship_systems.compatible_parts exist in part files
5. Cross-reference: mission rewards reference valid part IDs
6. Check: No orphaned parts (part with no system)
7. Check: No duplicate part IDs

---

## Implementation Notes

### JSON Loading (GDScript)

```gdscript
# PartRegistry._load_part_file()
func _load_part_file(file_path: String) -> Array:
    if not FileAccess.file_exists(file_path):
        push_error("Part file not found: " + file_path)
        return []

    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        push_error("Failed to open part file: " + file_path)
        return []

    var json_text = file.get_as_text()
    file.close()

    var json = JSON.new()
    var error = json.parse(json_text)

    if error != OK:
        push_error("JSON parse error in %s: %s" % [file_path, json.get_error_message()])
        return []

    var data = json.get_data()

    if not data.has("parts"):
        push_error("Invalid part file structure: " + file_path)
        return []

    return data.parts
```

### Validation Function

```gdscript
func _validate_part(part: Dictionary) -> bool:
    # Required fields
    var required = ["id", "name", "description", "system_type", "level", "rarity", "weight", "stats"]
    for field in required:
        if not part.has(field):
            push_error("Part missing required field: " + field)
            return false

    # Validate rarity
    if part.rarity not in ["common", "uncommon", "rare"]:
        push_error("Invalid rarity: " + part.rarity)
        return false

    # Validate level
    if part.level < 1 or part.level > 5:
        push_error("Invalid level: " + str(part.level))
        return false

    # Validate weight
    if part.weight < 0.1 or part.weight > 100.0:
        push_error("Invalid weight: " + str(part.weight))
        return false

    return true
```

---

**Related Documents:**
- [ECONOMY-IMPLEMENTATION-CHECKLIST.md](./ECONOMY-IMPLEMENTATION-CHECKLIST.md) - Implementation tasks
- [PART-REGISTRY-ARCHITECTURE.md](./PART-REGISTRY-ARCHITECTURE.md) - PartRegistry design
- [MIGRATION-PLAN.md](./MIGRATION-PLAN.md) - Migration strategy

**Version:** 1.0
**Last Updated:** 2025-11-07
