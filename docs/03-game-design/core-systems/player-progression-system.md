# Space Adventures - Player Progression & Profile System

**Version:** 1.0
**Date:** November 6, 2025
**Purpose:** Complete player progression, ranking, attributes, inventory, and profile systems

---

## Table of Contents
1. [Overview](#overview)
2. [Database Architecture](#database-architecture)
3. [Player Ranks & Progression](#player-ranks--progression)
4. [Experience (XP) System](#experience-xp-system)
5. [Character Attributes & Skills](#character-attributes--skills)
6. [Items & Inventory System](#items--inventory-system)
7. [Player Profile & Dashboard](#player-profile--dashboard)
8. [Implementation](#implementation)

---

## Overview

### Design Philosophy

**Player Identity:**
- Players create a unique character with name, species, appearance
- Progress from novice scavenger to legendary commander
- Earn ranks through achievements and mission success
- Collect items and equipment that enhance capabilities
- Build reputation and unlock new opportunities

**Progression Goals:**
- **Short-term**: Complete missions, gain XP, level up skills
- **Medium-term**: Achieve next rank, unlock new mission types
- **Long-term**: Build ultimate ship, reach Admiral rank, become legend

### System Integration

This system integrates with:
- **Ship Building** - Player level affects available parts and missions
- **Missions** - XP gained from mission completion
- **Ship Classification** - Rank affects ship classification benefits
- **NPCs** - Rank influences NPC reactions and dialogue options
- **Crew System** - Higher rank allows recruiting better crew

---

## Database Architecture

### Dual Database Design

**Why Two Databases?**

```
GLOBAL DATABASE (PostgreSQL)          LOCAL DATABASE (SQLite per save)
├─ Settings & Configuration           ├─ Player Character
├─ API Keys (encrypted)               ├─ Current Ship State
├─ Visual Preferences                 ├─ Inventory & Items
├─ Multi-Provider AI Config           ├─ Mission Progress
└─ Usage Statistics                   ├─ Discovered Locations
                                      └─ Story Choices Made
```

**Benefits:**
- Settings persist across all save files
- Each save slot has independent character/progress
- API keys stored centrally and securely
- Can have multiple characters with same settings

### Database Schema

#### **Global Database (PostgreSQL) - Python Service**

```sql
-- Settings storage
CREATE TABLE global_settings (
    setting_key VARCHAR(255) PRIMARY KEY,
    setting_value JSONB NOT NULL,
    category VARCHAR(50) NOT NULL,  -- 'general', 'ai_providers', 'visuals', etc.
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- API key storage (encrypted)
CREATE TABLE api_keys (
    provider_name VARCHAR(50) PRIMARY KEY,
    encrypted_key TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_validated TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Usage tracking for cost monitoring
CREATE TABLE ai_usage_log (
    id SERIAL PRIMARY KEY,
    provider_name VARCHAR(50) NOT NULL,
    task_type VARCHAR(50) NOT NULL,
    tokens_used INTEGER,
    estimated_cost DECIMAL(10, 4),
    session_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Visual style presets
CREATE TABLE visual_presets (
    preset_name VARCHAR(50) PRIMARY KEY,
    base_prompt TEXT,
    negative_prompt TEXT,
    settings JSONB,  -- resolution, inference_steps, etc.
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User preferences (across all saves)
CREATE TABLE user_preferences (
    user_id INTEGER PRIMARY KEY DEFAULT 1,  -- Single user for now
    preferred_providers JSONB,  -- {story: "claude", quick: "ollama", ...}
    ui_preferences JSONB,  -- theme, font size, etc.
    last_login TIMESTAMP,
    total_playtime_hours DECIMAL(10, 2) DEFAULT 0
);
```

#### **Local Database (SQLite per save) - Godot**

```sql
-- Player character data
CREATE TABLE player_character (
    id INTEGER PRIMARY KEY DEFAULT 1,  -- Single player per save
    name TEXT NOT NULL,
    species TEXT DEFAULT 'human',
    gender TEXT,
    appearance_data TEXT,  -- JSON for portrait/customization

    -- Progression
    current_rank TEXT DEFAULT 'ensign',
    level INTEGER DEFAULT 1,
    total_xp INTEGER DEFAULT 0,
    xp_to_next_level INTEGER DEFAULT 100,

    -- Attributes
    intellect INTEGER DEFAULT 5,
    charisma INTEGER DEFAULT 5,
    resilience INTEGER DEFAULT 5,

    -- Skills
    engineering_skill INTEGER DEFAULT 0,
    diplomacy_skill INTEGER DEFAULT 0,
    combat_skill INTEGER DEFAULT 0,
    science_skill INTEGER DEFAULT 0,

    -- Resources
    credits INTEGER DEFAULT 500,

    -- Metadata
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    last_played TEXT,
    total_playtime_seconds INTEGER DEFAULT 0
);

-- Ship state (current configuration)
CREATE TABLE ship_state (
    id INTEGER PRIMARY KEY DEFAULT 1,
    ship_name TEXT DEFAULT 'Unnamed Vessel',
    ship_class TEXT DEFAULT 'unclassified',
    designation TEXT DEFAULT 'SS Unnamed - Unclassified',

    -- Systems (JSON for flexibility)
    systems_data TEXT NOT NULL,  -- JSON of all 10 systems

    -- Stats
    hull_hp INTEGER DEFAULT 0,
    max_hull_hp INTEGER DEFAULT 0,
    power_available INTEGER DEFAULT 0,
    power_total INTEGER DEFAULT 0,

    fuel INTEGER DEFAULT 100,

    last_modified TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Inventory items (unified table for all items)
CREATE TABLE inventory_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    item_id TEXT NOT NULL,  -- e.g., "hull_plating_mk2"
    item_type TEXT NOT NULL,  -- 'ship_part', 'equipment', 'consumable', 'quest'
    item_name TEXT NOT NULL,
    item_rarity TEXT,  -- 'common', 'uncommon', 'rare', 'legendary'
    quantity INTEGER DEFAULT 1,

    -- Item stats (JSON)
    stats_data TEXT,  -- {bonus_engineering: 2, durability: 100}

    -- Location tracking
    location TEXT DEFAULT 'ship_storage',  -- 'ship_storage', 'equipped', 'installed'
    equipped_slot TEXT,  -- If location='equipped': 'tool', 'armor', 'accessory_1', 'accessory_2'

    acquired_date TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Index for faster location queries
CREATE INDEX idx_inventory_location ON inventory_items(location);

-- Equipped items view (for convenience)
CREATE VIEW equipped_items AS
    SELECT * FROM inventory_items
    WHERE location = 'equipped';

-- Ship storage view (for convenience)
CREATE VIEW ship_storage AS
    SELECT * FROM inventory_items
    WHERE location = 'ship_storage';

-- Installed ship parts view
CREATE VIEW installed_parts AS
    SELECT * FROM inventory_items
    WHERE location = 'installed';

-- Mission progress
CREATE TABLE mission_progress (
    mission_id TEXT PRIMARY KEY,
    mission_type TEXT NOT NULL,
    status TEXT DEFAULT 'available',  -- 'available', 'active', 'completed', 'failed'
    current_stage TEXT,
    completion_percentage INTEGER DEFAULT 0,
    times_attempted INTEGER DEFAULT 0,
    started_at TEXT,
    completed_at TEXT,

    -- Mission-specific data
    mission_data TEXT  -- JSON for dynamic data
);

-- Completed missions log
CREATE TABLE completed_missions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mission_id TEXT NOT NULL,
    mission_type TEXT,
    xp_earned INTEGER,
    credits_earned INTEGER,
    items_earned TEXT,  -- JSON array of item IDs
    choices_made TEXT,  -- JSON array of choice IDs
    outcome TEXT,  -- 'success', 'partial', 'failure'
    completed_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Discovered locations
CREATE TABLE discovered_locations (
    location_id TEXT PRIMARY KEY,
    location_name TEXT NOT NULL,
    location_type TEXT,  -- 'city', 'spaceport', 'facility', 'danger_zone'
    coordinates TEXT,
    discovered_at TEXT DEFAULT CURRENT_TIMESTAMP,
    visit_count INTEGER DEFAULT 0
);

-- Major story choices
CREATE TABLE story_choices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    choice_id TEXT NOT NULL,
    mission_id TEXT,
    choice_text TEXT,
    consequences TEXT,  -- JSON describing what happened
    made_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Relationships (NPCs, factions)
CREATE TABLE relationships (
    entity_id TEXT PRIMARY KEY,
    entity_type TEXT,  -- 'npc', 'faction', 'organization'
    entity_name TEXT NOT NULL,
    relationship_level INTEGER DEFAULT 0,  -- -100 to 100
    reputation TEXT DEFAULT 'neutral',  -- 'enemy', 'unfriendly', 'neutral', 'friendly', 'ally'
    met_at TEXT DEFAULT CURRENT_TIMESTAMP,
    last_interaction TEXT
);

-- Achievements
CREATE TABLE achievements (
    achievement_id TEXT PRIMARY KEY,
    achievement_name TEXT NOT NULL,
    achievement_description TEXT,
    unlocked_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Statistics tracking
CREATE TABLE player_statistics (
    stat_key TEXT PRIMARY KEY,
    stat_value INTEGER DEFAULT 0,
    last_updated TEXT DEFAULT CURRENT_TIMESTAMP
);
```

### Database Access Pattern

```python
# Python service accesses PostgreSQL
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "postgresql://user:password@localhost:5432/space_adventures"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)

def get_global_setting(key: str):
    session = SessionLocal()
    result = session.query(GlobalSettings).filter_by(setting_key=key).first()
    return result.setting_value if result else None
```

```gdscript
# Godot accesses SQLite
var db_path = "user://saves/save_slot_1.db"
var db = SQLite.new()
db.path = db_path
db.open_db()

func get_player_data():
    db.query("SELECT * FROM player_character WHERE id = 1")
    return db.query_result[0] if db.query_result.size() > 0 else null
```

---

## Player Ranks & Progression

### Rank System

**Post-Exodus Honor Ranks** (inspired by Starfleet)

In the post-Exodus world, the traditional Starfleet is gone, but survivors still honor the old rank structure. Independent spacers earn "honorary ranks" through achievement and reputation.

| Rank | Level Req. | Total XP | Unlocks |
|------|-----------|----------|---------|
| **Cadet** | 1 | 0 | Tutorial missions, basic parts |
| **Ensign** | 3 | 500 | Standard missions, common parts |
| **Lieutenant Junior Grade** | 5 | 1,500 | Intermediate missions, trade unlocked |
| **Lieutenant** | 8 | 3,500 | Advanced missions, uncommon parts |
| **Lieutenant Commander** | 12 | 7,000 | Specialist missions, crew recruitment |
| **Commander** | 16 | 12,000 | High-risk missions, rare parts |
| **Captain** | 20 | 20,000 | Command missions, legendary parts available |
| **Commodore** | 25 | 35,000 | Fleet operations (post-MVP), faction leadership |
| **Rear Admiral** | 30 | 55,000 | Strategic operations, major story branches |
| **Admiral** | 35 | 85,000 | Ultimate missions, unique ship configurations |

**Notes:**
- **Level** = Character level (1-35+)
- **Total XP** = Cumulative experience required
- Each rank brings tangible benefits and story progression

### Rank Benefits

**Per-Rank Bonuses:**

```gdscript
const RANK_BENEFITS = {
    "cadet": {
        "title": "Cadet",
        "bonus_credits_per_mission": 0,
        "max_crew_size": 1,
        "unlocks": ["tutorial_missions"]
    },
    "ensign": {
        "title": "Ensign",
        "bonus_credits_per_mission": 50,
        "max_crew_size": 2,
        "trade_discount": 0.05,
        "unlocks": ["standard_missions", "workshop_upgrades"]
    },
    "lieutenant_jg": {
        "title": "Lieutenant (Junior Grade)",
        "bonus_credits_per_mission": 100,
        "max_crew_size": 3,
        "trade_discount": 0.10,
        "unlocks": ["intermediate_missions", "trading_routes"]
    },
    "lieutenant": {
        "title": "Lieutenant",
        "bonus_credits_per_mission": 150,
        "max_crew_size": 4,
        "trade_discount": 0.15,
        "xp_bonus": 0.10,  # +10% XP from missions
        "unlocks": ["advanced_missions", "rare_parts_access"]
    },
    "lt_commander": {
        "title": "Lieutenant Commander",
        "bonus_credits_per_mission": 250,
        "max_crew_size": 6,
        "trade_discount": 0.20,
        "xp_bonus": 0.15,
        "unlocks": ["specialist_missions", "crew_recruitment", "reputation_system"]
    },
    "commander": {
        "title": "Commander",
        "bonus_credits_per_mission": 400,
        "max_crew_size": 8,
        "trade_discount": 0.25,
        "xp_bonus": 0.20,
        "unlocks": ["high_risk_missions", "faction_quests", "rare_parts_guaranteed"]
    },
    "captain": {
        "title": "Captain",
        "bonus_credits_per_mission": 600,
        "max_crew_size": 12,
        "trade_discount": 0.30,
        "xp_bonus": 0.25,
        "unlocks": ["command_missions", "legendary_parts", "ship_naming_prestige"]
    },
    "commodore": {
        "title": "Commodore",
        "bonus_credits_per_mission": 1000,
        "max_crew_size": 16,
        "trade_discount": 0.35,
        "xp_bonus": 0.30,
        "unlocks": ["fleet_operations", "faction_leadership", "unique_missions"]
    },
    "rear_admiral": {
        "title": "Rear Admiral",
        "bonus_credits_per_mission": 1500,
        "max_crew_size": 20,
        "trade_discount": 0.40,
        "xp_bonus": 0.35,
        "unlocks": ["strategic_operations", "major_story_branches", "elite_missions"]
    },
    "admiral": {
        "title": "Admiral",
        "bonus_credits_per_mission": 2500,
        "max_crew_size": 30,
        "trade_discount": 0.50,
        "xp_bonus": 0.50,
        "unlocks": ["ultimate_missions", "legendary_status", "game_ending_choices"]
    }
}
```

### Rank-Up Ceremony

```
┌────────────────────────────────────────────────┐
│ 🎖️  RANK PROMOTION                            │
├────────────────────────────────────────────────┤
│                                                │
│ CONGRATULATIONS, LIEUTENANT!                   │
│                                                │
│ Through your achievements and dedication to    │
│ the recovery efforts, you have earned the      │
│ honorary rank of Lieutenant.                   │
│                                                │
│ Previous Rank: Ensign                          │
│ New Rank: Lieutenant (Junior Grade)           │
│                                                │
│ NEW BENEFITS:                                  │
│ • +100 credits per mission                     │
│ • 10% trade discount                           │
│ • Crew capacity increased to 3                 │
│ • Intermediate missions now available          │
│ • Trading routes unlocked                      │
│                                                │
│ "The measure of a person is not how they       │
│  handle success, but how they rise from        │
│  failure. You've proven yourself."             │
│                                                │
│ [Accept Promotion]                             │
│                                                │
└────────────────────────────────────────────────┘
```

---

## Experience (XP) System

### XP Sources

```python
XP_SOURCES = {
    # Missions
    "mission_salvage_easy": 50,
    "mission_salvage_medium": 100,
    "mission_salvage_hard": 200,
    "mission_exploration": 75,
    "mission_combat_victory": 150,
    "mission_story_major": 300,
    "mission_perfect_completion": 50,  # Bonus for no failures

    # Discovery
    "discover_location": 25,
    "discover_rare_location": 100,
    "scan_anomaly": 30,
    "first_contact": 200,

    # Ship Building
    "install_system_first_time": 50,
    "upgrade_system": 25,
    "achieve_ship_class": 150,

    # Skills
    "successful_skill_check_hard": 10,
    "successful_skill_check_critical": 25,

    # Social
    "improve_relationship": 20,
    "ally_with_faction": 150,
    "resolve_conflict_peacefully": 100,

    # Milestones
    "complete_10_missions": 200,
    "complete_50_missions": 500,
    "reach_level_10": 500,
    "build_first_complete_ship": 300,
}
```

### XP Calculation

**Base XP from missions:**
```python
def calculate_mission_xp(mission: Mission, outcome: str, player_level: int) -> int:
    # Base XP by mission difficulty
    base_xp = {
        1: 50,   # Easy
        2: 100,  # Medium
        3: 200,  # Hard
        4: 350,  # Very Hard
        5: 500   # Extreme
    }[mission.difficulty]

    # Outcome multiplier
    outcome_multiplier = {
        "success": 1.0,
        "partial": 0.7,
        "failure": 0.3
    }[outcome]

    # Level scaling (missions scale to player level)
    level_bonus = player_level * 5

    # Calculate
    total_xp = int((base_xp + level_bonus) * outcome_multiplier)

    return total_xp
```

### Leveling Curve

**XP Required per Level:**

```python
def xp_for_level(level: int) -> int:
    """
    Progressive curve that slows down at higher levels
    Level 1→2: 100 XP
    Level 2→3: 150 XP
    Level 10→11: 750 XP
    Level 20→21: 1,750 XP
    """
    if level <= 1:
        return 100

    # Formula: base + (level * multiplier) + (level^1.5 * scale)
    base = 100
    linear = level * 25
    exponential = int((level ** 1.5) * 10)

    return base + linear + exponential

def total_xp_for_level(target_level: int) -> int:
    """Total cumulative XP to reach a level"""
    total = 0
    for lvl in range(1, target_level):
        total += xp_for_level(lvl)
    return total
```

**Level Chart (1-35):**

| Level | XP Needed | Total XP | Avg. Missions Needed | Milestone |
|-------|-----------|----------|---------------------|-----------|
| 1 → 2 | 100 | 100 | 1-2 | Starting rank: Cadet |
| 2 → 3 | 150 | 250 | 2-3 | - |
| 3 → 4 | 200 | 450 | 4-5 | **Rank: Ensign** |
| 5 → 6 | 300 | 1,500 | 12-15 | **Rank: Lt. JG** |
| 8 → 9 | 500 | 3,500 | 25-30 | **Rank: Lieutenant** |
| 12 → 13 | 900 | 7,000 | 45-50 | **Rank: Lt. Commander** |
| 16 → 17 | 1,400 | 12,000 | 70-80 | **Rank: Commander** |
| 20 → 21 | 2,000 | 20,000 | 110-120 | **Rank: Captain** |
| 25 → 26 | 3,000 | 35,000 | 180-200 | **Rank: Commodore** |
| 30 → 31 | 4,500 | 55,000 | 270-300 | **Rank: Rear Admiral** |
| 35 | - | 85,000 | 400+ | **Rank: Admiral** |

**Notes:**
- MVP targets Level 1-15 (Cadet → Lt. Commander)
- Post-MVP extends to Level 35+ (Admiral and beyond)
- Average mission gives 100-150 XP at mid-levels

---

## Character Attributes & Skills

### Three Core Attributes

**Attributes are foundational traits that influence multiple skills:**

```python
ATTRIBUTES = {
    "intellect": {
        "name": "Intellect",
        "description": "Mental acuity, problem-solving, technical knowledge",
        "affects": ["engineering", "science", "computer_use"],
        "starting_value": 5,
        "max_value": 20
    },
    "charisma": {
        "name": "Charisma",
        "description": "Persuasiveness, leadership, social interaction",
        "affects": ["diplomacy", "negotiation", "crew_morale"],
        "starting_value": 5,
        "max_value": 20
    },
    "resilience": {
        "name": "Resilience",
        "description": "Physical endurance, combat ability, stress resistance",
        "affects": ["combat", "survival", "damage_resistance"],
        "starting_value": 5,
        "max_value": 20
    }
}
```

**Attribute Points:**
- Start with 15 total attribute points (5/5/5)
- Gain 1 attribute point every 2 levels
- Can redistribute at character creation

**Attribute Effects:**

```gdscript
func get_skill_bonus(skill_name: String, player_data: Dictionary) -> int:
    var base_skill = player_data.get(skill_name + "_skill", 0)
    var attribute_bonus = 0

    match skill_name:
        "engineering", "science":
            attribute_bonus = floor(player_data.intellect / 2)
        "diplomacy":
            attribute_bonus = floor(player_data.charisma / 2)
        "combat":
            attribute_bonus = floor(player_data.resilience / 2)

    return base_skill + attribute_bonus
```

### Four Core Skills

**Skills from game-design-document.md (already defined):**

1. **Engineering** (affected by Intellect)
   - Ship repairs and modifications
   - Technical problem-solving
   - Hacking and system manipulation

2. **Diplomacy** (affected by Charisma)
   - Negotiation and persuasion
   - Conflict resolution
   - NPC interactions

3. **Combat** (affected by Resilience)
   - Tactical combat decisions
   - Weapon accuracy
   - Defensive maneuvers

4. **Science** (affected by Intellect)
   - Analyzing anomalies
   - Research and discovery
   - Medical knowledge

**Skill Progression:**
- Skills start at 0, max at 20
- Gain skill points from:
  - Using the skill successfully (learning by doing)
  - Level-up rewards (1 skill point per level)
  - Training missions
  - Crew teaching (if crew system active)

**Skill Check Formula:**

```python
def skill_check(
    skill_name: str,
    player: Player,
    difficulty: int,  # DC (Difficulty Class) 1-20
    allow_critical: bool = True
) -> dict:
    """
    Perform a skill check
    Returns: {success: bool, critical: bool, roll: int, total: int}
    """
    # Calculate total skill
    skill_level = getattr(player, f"{skill_name}_skill")
    attribute_bonus = get_attribute_bonus(skill_name, player)
    total_skill = skill_level + attribute_bonus

    # Roll d20 (simulate with random 1-20)
    roll = random.randint(1, 20)

    # Critical success/failure
    if allow_critical:
        if roll == 20:
            return {"success": True, "critical": True, "roll": roll, "total": roll + total_skill}
        elif roll == 1:
            return {"success": False, "critical": False, "roll": roll, "total": roll + total_skill}

    # Normal check
    total = roll + total_skill
    success = total >= difficulty

    return {"success": success, "critical": False, "roll": roll, "total": total}
```

---

## Items & Inventory System

### Item Categories

```python
class ItemType(str, Enum):
    SHIP_PART = "ship_part"          # Parts for ship systems
    EQUIPMENT = "equipment"          # Personal gear (tools, armor)
    CONSUMABLE = "consumable"        # Med kits, rations, repair supplies
    QUEST = "quest"                  # Mission-specific items
    RESOURCE = "resource"            # Raw materials
    TRADE_GOOD = "trade_good"        # Items for trading
    COLLECTIBLE = "collectible"      # Lore items, artifacts

class ItemRarity(str, Enum):
    COMMON = "common"                # Gray
    UNCOMMON = "uncommon"            # Green
    RARE = "rare"                    # Blue
    LEGENDARY = "legendary"          # Purple
    UNIQUE = "unique"                # Orange (one-of-a-kind)
```

### Item Data Structure

```gdscript
# Base item structure
var item = {
    "item_id": "reinforced_hull_plating_mk3",
    "item_type": "ship_part",
    "item_name": "Reinforced Hull Plating Mk.III",
    "item_rarity": "rare",
    "description": "Military-grade hull reinforcement salvaged from a derelict destroyer.",

    # System-specific (for ship parts)
    "system_type": "hull",
    "system_level": 3,

    # Stats/bonuses
    "stats": {
        "hull_hp_bonus": 500,
        "armor_rating": 25
    },

    # Economy
    "base_value": 2500,
    "weight": 50,
    "stackable": false,

    # Requirements
    "requirements": {
        "player_level": 8,
        "engineering_skill": 5
    },

    # Metadata
    "acquired_location": "Titan Station Ruins",
    "acquired_date": "2287-11-05",
    "quantity": 1
}
```

### Equipment Slots

**Player can equip items for bonuses:**

```
┌────────────────────────────────────────┐
│ EQUIPMENT                              │
├────────────────────────────────────────┤
│                                        │
│ 🔧 Tool:                              │
│ [Advanced Engineering Kit]             │
│ +3 Engineering skill                   │
│                                        │
│ 🛡️ Armor:                             │
│ [Reinforced Vacuum Suit]               │
│ +2 Resilience, +50 HP                  │
│                                        │
│ 📿 Accessory 1:                       │
│ [Diplomat's Badge]                     │
│ +2 Charisma                            │
│                                        │
│ 📿 Accessory 2:                       │
│ [Neural Interface]                     │
│ +2 Intellect, -1 Resilience            │
│                                        │
└────────────────────────────────────────┘
```

**Equipment Slots:**
1. **Tool** - Engineering tools, scanner devices, weapons
2. **Armor** - Environmental suits, protective gear
3. **Accessory 1** - Badges, communicators, data pads
4. **Accessory 2** - Neural implants, augmentations

### Example Items

#### **Ship Parts** (already defined in ship-systems.md)

```gdscript
{
    "item_id": "alcubierre_mk2_drive",
    "item_type": "ship_part",
    "item_name": "Alcubierre Mk.II Warp Drive",
    "item_rarity": "uncommon",
    "system_type": "warp",
    "system_level": 1,
    "base_value": 5000
}
```

#### **Equipment Items**

```gdscript
# TOOL - Engineering Kit
{
    "item_id": "advanced_engineering_kit",
    "item_type": "equipment",
    "equipment_slot": "tool",
    "item_name": "Advanced Engineering Kit",
    "item_rarity": "rare",
    "description": "Professional-grade tools for ship repairs and modifications.",
    "stats": {
        "engineering_bonus": 3,
        "repair_speed": 1.25  # 25% faster repairs
    },
    "base_value": 1500,
    "requirements": {"engineering_skill": 5}
}

# ARMOR - Vacuum Suit
{
    "item_id": "reinforced_vacuum_suit",
    "item_type": "equipment",
    "equipment_slot": "armor",
    "item_name": "Reinforced Vacuum Suit",
    "item_rarity": "uncommon",
    "description": "Heavy-duty suit for hostile environments and combat situations.",
    "stats": {
        "resilience_bonus": 2,
        "max_hp_bonus": 50,
        "environmental_protection": true
    },
    "base_value": 800
}

# ACCESSORY - Diplomat's Badge
{
    "item_id": "diplomats_badge",
    "item_type": "equipment",
    "equipment_slot": "accessory",
    "item_name": "Diplomat's Badge",
    "item_rarity": "rare",
    "description": "Pre-Exodus diplomatic credentials. Still commands respect.",
    "stats": {
        "charisma_bonus": 2,
        "negotiation_discount": 0.10
    },
    "base_value": 2000
}
```

#### **Consumable Items**

```gdscript
# Medical Kit
{
    "item_id": "medkit_advanced",
    "item_type": "consumable",
    "item_name": "Advanced Medical Kit",
    "item_rarity": "uncommon",
    "description": "Restores 100 HP. Can be used during missions.",
    "stats": {
        "heal_amount": 100,
        "cures_status": ["poisoned", "injured"]
    },
    "stackable": true,
    "max_stack": 10,
    "base_value": 150
}

# Repair Nanites
{
    "item_id": "repair_nanites",
    "item_type": "consumable",
    "item_name": "Repair Nanites",
    "item_rarity": "rare",
    "description": "Repairs 25% of a ship system's health instantly.",
    "stats": {
        "repair_percentage": 0.25
    },
    "stackable": true,
    "max_stack": 5,
    "base_value": 500
}
```

#### **Quest Items**

```gdscript
{
    "item_id": "encrypted_data_core",
    "item_type": "quest",
    "item_name": "Encrypted Data Core",
    "item_rarity": "unique",
    "description": "A data core from the Exodus fleet. Requires decryption.",
    "quest_id": "ghosts_in_the_machine",
    "cannot_drop": true,
    "cannot_sell": true,
    "base_value": 0
}
```

### Inventory Management

**Two-Tier Inventory System:**

1. **Player Equipment** - What the player carries on their person (3-4 slots)
2. **Ship Storage** - Bulk storage aboard the ship (16-32 slots)

```gdscript
# PLAYER EQUIPMENT - Small, portable items only
const PLAYER_EQUIPMENT_SLOTS = 4
# Slots: tool, armor, accessory_1, accessory_2

# SHIP STORAGE - Bulk item storage
const BASE_SHIP_STORAGE = 16  # 16 slots base
const MAX_SHIP_STORAGE = 32   # Upgradeable with cargo bay improvements

func get_ship_storage_capacity() -> int:
    """Calculate ship's storage capacity based on systems"""
    var base = BASE_SHIP_STORAGE
    var ship = GameState.ship

    # Life Support system level adds storage (crew quarters = storage space)
    if ship.systems.has("life_support"):
        base += ship.systems.life_support.level * 2  # +2 slots per level

    # Computer Core helps with inventory management
    if ship.systems.has("computer") and ship.systems.computer.level >= 3:
        base += 4  # Advanced logistics management

    # Ship class bonus
    if GameState.ship.ship_class == "support_vessel":
        base += 8  # Support vessels have extra cargo space

    return min(base, MAX_SHIP_STORAGE)  # Cap at 32

func can_add_to_ship_storage(item: Dictionary, quantity: int = 1) -> bool:
    """Check if item can be added to ship storage"""
    var ship_inventory = get_ship_storage_items()
    var capacity = get_ship_storage_capacity()

    # Check if stackable
    if item.get("stackable", false):
        # Find existing stack
        for stored_item in ship_inventory:
            if stored_item.item_id == item.item_id:
                var max_stack = item.get("max_stack", 99)
                if stored_item.quantity + quantity <= max_stack:
                    return true  # Can add to existing stack

    # Check for free slots
    var used_slots = ship_inventory.size()
    if used_slots + 1 > capacity:
        return false  # Ship storage full

    return true

func can_equip_item(item: Dictionary, slot: String) -> bool:
    """Check if item can be equipped to player"""
    # Item must be equipment type
    if item.item_type != "equipment":
        return false

    # Item must match slot
    if item.equipment_slot != slot and item.equipment_slot != "accessory":
        return false

    # Check requirements
    if item.has("requirements"):
        var reqs = item.requirements
        if reqs.has("player_level") and GameState.player.level < reqs.player_level:
            return false
        # Check skill requirements...

    return true
```

#### Dynamic Item Swapping

```gdscript
# Transfer item from ship storage to player equipment
func equip_from_ship(item_id: String, equipment_slot: String) -> bool:
    """Move item from ship storage to player equipment"""
    var item = find_item_in_ship_storage(item_id)
    if not item:
        return false

    if not can_equip_item(item, equipment_slot):
        UI.show_error("Cannot equip this item")
        return false

    # Get currently equipped item in that slot
    var current_equipped = get_equipped_item(equipment_slot)

    # If slot occupied, move current item to ship storage
    if current_equipped:
        if not can_add_to_ship_storage(current_equipped):
            UI.show_error("Ship storage full - cannot swap items")
            return false
        unequip_to_ship(current_equipped, equipment_slot)

    # Remove from ship storage
    remove_from_ship_storage(item_id)

    # Equip to player
    equip_item(item, equipment_slot)

    return true

func unequip_to_ship(item: Dictionary, equipment_slot: String) -> bool:
    """Move item from player equipment to ship storage"""
    if not can_add_to_ship_storage(item):
        UI.show_error("Ship storage full")
        return false

    # Unequip from player
    unequip_item(equipment_slot)

    # Add to ship storage
    add_to_ship_storage(item)

    return true

func auto_store_new_item(item: Dictionary) -> String:
    """
    Automatically decide where to store a newly acquired item
    Returns: "equipped", "ship_storage", or "dropped"
    """
    # Quest items always go to ship storage
    if item.item_type == "quest":
        if can_add_to_ship_storage(item):
            add_to_ship_storage(item)
            return "ship_storage"

    # Equipment items - check if better than current
    if item.item_type == "equipment":
        var slot = item.equipment_slot
        var current = get_equipped_item(slot)

        # If slot empty and item can be equipped, equip it
        if not current and can_equip_item(item, slot):
            equip_item(item, slot)
            return "equipped"

        # If better than current, offer to swap
        if current and is_item_better(item, current):
            # Auto-equip if settings allow, otherwise store
            if SettingsManager.get_setting("gameplay.auto_equip_better"):
                equip_from_ship(item.item_id, slot)
                return "equipped"

    # Default: add to ship storage
    if can_add_to_ship_storage(item):
        add_to_ship_storage(item)
        return "ship_storage"

    # Storage full - prompt player
    UI.show_inventory_full_dialog(item)
    return "dropped"

func is_item_better(new_item: Dictionary, current_item: Dictionary) -> bool:
    """Compare two items to determine which is better"""
    # Simple comparison based on total stat bonuses
    var new_total = sum_item_stats(new_item)
    var current_total = sum_item_stats(current_item)
    return new_total > current_total
```

### Two-Tier Inventory UI

**Dual-Panel Inventory Screen:**

```
┌─────────────────────────────────────────────────────────────────────┐
│ INVENTORY MANAGEMENT                                    [X] Close   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│ ┌─────────────────────────────┬─────────────────────────────────┐ │
│ │ PLAYER EQUIPMENT (4 slots)  │ SHIP STORAGE (18/24 slots)      │ │
│ ├─────────────────────────────┼─────────────────────────────────┤ │
│ │                             │                                 │ │
│ │ 🔧 TOOL                     │ [🔧][⚔️][🛡️][📦][📦][📦]        │ │
│ │ ┌─────────────────────────┐ │ [📦][📦][💊][💊][⚡][⚡][⚡]      │ │
│ │ │ Advanced Engineering Kit │ │ [📿][📿][📿][🔑][📜][📜]        │ │
│ │ │ Rare                    │ │ [ ][ ][ ][ ][ ][ ]            │ │
│ │ │ +3 Engineering          │ │                                 │ │
│ │ │ Repair Speed +25%       │ │ ← Drag items to/from ship     │ │
│ │ └─────────────────────────┘ │                                 │ │
│ │ [Unequip to Ship]           │ FILTERS:                        │ │
│ │                             │ ☑ All  □ Parts  □ Equipment    │ │
│ │ 🛡️ ARMOR                    │ □ Consumables  □ Quest Items   │ │
│ │ ┌─────────────────────────┐ │                                 │ │
│ │ │ Reinforced Vacuum Suit  │ │ SELECTED ITEM:                  │ │
│ │ │ Uncommon                │ │ ┌─────────────────────────────┐ │ │
│ │ │ +2 Resilience          │ │ │ Alcubierre Mk.II Warp Drive │ │ │
│ │ │ +50 HP                  │ │ │ Ship Part - Uncommon        │ │ │
│ │ └─────────────────────────┘ │ │ Warp System Level 1         │ │ │
│ │ [Unequip to Ship]           │ │ Value: 5,000¢               │ │ │
│ │                             │ │                             │ │ │
│ │ 📿 ACCESSORY 1              │ │ "Pre-Exodus FTL drive core."│ │ │
│ │ ┌─────────────────────────┐ │ └─────────────────────────────┘ │ │
│ │ │ Diplomat's Badge        │ │                                 │ │
│ │ │ Rare                    │ │ [Install on Ship]               │ │
│ │ │ +2 Charisma             │ │ [Drop Item]                     │ │
│ │ │ -10% Trade Prices       │ │                                 │ │
│ │ └─────────────────────────┘ │                                 │ │
│ │ [Unequip to Ship]           │                                 │ │
│ │                             │                                 │ │
│ │ 📿 ACCESSORY 2              │                                 │ │
│ │ ┌─────────────────────────┐ │                                 │ │
│ │ │ [Empty Slot]            │ │                                 │ │
│ │ │                         │ │                                 │ │
│ │ │ Drag item from ship →  │ │                                 │ │
│ │ └─────────────────────────┘ │                                 │ │
│ │                             │                                 │ │
│ └─────────────────────────────┴─────────────────────────────────┘ │
│                                                                     │
│ CURRENT BONUSES (from equipped items):                              │
│ +3 Engineering  +2 Resilience  +2 Charisma  +50 HP                 │
│                                                                     │
│ SHIP STORAGE CAPACITY: 18 / 24 slots                               │
│ └─ Base: 16  +4 (Life Support Lv2)  +4 (Computer Lv3)             │
│                                                                     │
│ [Sort Ship Storage ▼]  [Sell Items]  [Transfer All Consumables]   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Interaction Flow:**

1. **Drag & Drop** - Click and drag items between ship storage and player equipment
2. **Auto-Swap** - Dragging to occupied slot automatically moves old item to ship storage
3. **Capacity Warning** - Visual indicator when storage nearly full (yellow at 80%, red at 100%)
4. **Quick Actions** - Right-click item for context menu (Equip, Use, Drop, Sell)
5. **Filters** - Filter ship storage by item type for easier navigation

**Mobile/Controller Support:**
- Use D-pad to navigate between slots
- A button to select/equip
- B button to unequip/return to ship
- X button for quick actions menu
- Y button for item details

**Storage Full Dialog:**

```
┌──────────────────────────────────────────────┐
│ ⚠️  SHIP STORAGE FULL                       │
├──────────────────────────────────────────────┤
│                                              │
│ Cannot add: Advanced Medical Kit            │
│                                              │
│ Your ship storage is full (24/24 slots).    │
│                                              │
│ What would you like to do?                  │
│                                              │
│ ○ Drop item (lose forever)                  │
│ ○ Swap with existing item                   │
│ ○ Cancel (don't pick up)                    │
│                                              │
│ [Select Swap Target ▼]                      │
│                                              │
│ Tip: Upgrade Life Support or Computer Core  │
│ to increase ship storage capacity.          │
│                                              │
│           [Confirm]  [Cancel]                │
│                                              │
└──────────────────────────────────────────────┘
```

---

## Player Profile & Dashboard

### Profile Data Structure

```gdscript
# Complete player profile
var player_profile = {
    # Identity
    "name": "Commander Shepard",
    "species": "human",
    "gender": "female",
    "appearance": {
        "portrait_id": "human_female_02",
        "skin_tone": 3,
        "hair_style": "short",
        "hair_color": "brown"
    },

    # Progression
    "level": 12,
    "rank": "lt_commander",
    "rank_title": "Lieutenant Commander",
    "current_xp": 7450,
    "xp_to_next_level": 900,

    # Attributes
    "intellect": 8,
    "charisma": 12,
    "resilience": 10,

    # Skills
    "engineering_skill": 8,
    "diplomacy_skill": 15,
    "combat_skill": 6,
    "science_skill": 10,

    # Resources
    "credits": 45000,
    "fuel": 180,

    # Statistics
    "missions_completed": 67,
    "locations_discovered": 23,
    "enemies_defeated": 14,
    "total_playtime_hours": 28.5,
    "favorite_mission_type": "diplomacy",

    # Current Status
    "ship_name": "SS Normandy",
    "ship_class": "explorer",
    "crew_size": 6,
    "current_location": "New Phoenix Spaceport"
}
```

### Dashboard UI Design

```
┌─────────────────────────────────────────────────────────────┐
│ PLAYER PROFILE                                  [Settings] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌──────────┐                                               │
│ │ [PORTRAIT]│  Commander Shepard                            │
│ │          │  Human Female                                 │
│ │          │  Lieutenant Commander                         │
│ └──────────┘  Level 12 Explorer-class Captain              │
│                                                             │
│ ════════════════════════════════════════════════════════   │
│                                                             │
│ PROGRESSION                                                 │
│ ─────────────────                                          │
│ XP: 7,450 / 8,350  [████████████░░░░] (89%)               │
│ Next Level: 900 XP remaining                               │
│                                                             │
│ Rank: Lieutenant Commander                                  │
│ Next Rank: Commander (Level 16, 4 levels to go)           │
│                                                             │
│ ════════════════════════════════════════════════════════   │
│                                                             │
│ ATTRIBUTES          SKILLS                                  │
│ ─────────────       ──────────────                         │
│ Intellect:    8     Engineering:   8 (+4 INT)   = 12      │
│ Charisma:    12     Diplomacy:    15 (+6 CHA)   = 21      │
│ Resilience:  10     Combat:        6 (+5 RES)   = 11      │
│                     Science:      10 (+4 INT)   = 14      │
│                                                             │
│ [+] Attribute points available: 1                          │
│                                                             │
│ ════════════════════════════════════════════════════════   │
│                                                             │
│ EQUIPMENT                                                   │
│ ─────────────────                                          │
│ 🔧 Tool:      [Advanced Engineering Kit] (+3 ENG)         │
│ 🛡️ Armor:     [Reinforced Vacuum Suit] (+2 RES, +50 HP)   │
│ 📿 Access 1:  [Diplomat's Badge] (+2 CHA)                 │
│ 📿 Access 2:  [Empty]                                      │
│                                                             │
│ Total Bonus: +3 ENG, +2 CHA, +2 RES, +50 HP               │
│                                                             │
│ ════════════════════════════════════════════════════════   │
│                                                             │
│ RESOURCES & INVENTORY                                       │
│ ───────────────────────────                                │
│ Credits:     45,000 ¢                                      │
│ Fuel:        180 / 200 units                               │
│ Inventory:   34 / 50 slots    Weight: 680 / 1000 kg       │
│                                                             │
│ [View Full Inventory]                                      │
│                                                             │
│ ════════════════════════════════════════════════════════   │
│                                                             │
│ CURRENT SHIP                                                │
│ ───────────────────                                        │
│ SS Normandy - Explorer-class                               │
│ Hull: 850/850    Power: 140/180 MW                        │
│ Systems: 10/10 installed    Crew: 6/12                    │
│                                                             │
│ [View Ship Details]                                        │
│                                                             │
│ ════════════════════════════════════════════════════════   │
│                                                             │
│ STATISTICS                                                  │
│ ───────────────                                            │
│ Missions Completed:       67                               │
│ Locations Discovered:     23                               │
│ Systems Explored:         8                                │
│ Enemies Defeated:         14                               │
│ Credits Earned (Total):   127,000 ¢                        │
│ Total Playtime:           28h 32m                          │
│                                                             │
│ Favorite Mission Type:    Diplomacy                        │
│ Most Used Skill:          Diplomacy (147 checks)           │
│                                                             │
│ ════════════════════════════════════════════════════════   │
│                                                             │
│ ACHIEVEMENTS              Recent: [Admiral's Honor] 🏆     │
│ ───────────────────                                        │
│ 23 / 50 Unlocked                                           │
│                                                             │
│ [View All Achievements]                                    │
│                                                             │
│ ════════════════════════════════════════════════════════   │
│                                                             │
│ [Edit Profile] [View Ship Manual] [View Mission Log]      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Character Creation Screen

```
┌─────────────────────────────────────────────────────────────┐
│ CHARACTER CREATION                              Step 1 of 4 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ BASIC INFORMATION                                           │
│ ───────────────────                                         │
│                                                             │
│ Name: [_____________________]                              │
│                                                             │
│ Species: ○ Human  ○ Andorian  ○ Vulcan  ○ Trill            │
│                                                             │
│ Gender:  ○ Male   ○ Female    ○ Non-binary                 │
│                                                             │
│ ════════════════════════════════════════════════════════   │
│                                                             │
│ APPEARANCE                                                  │
│ ───────────────                                            │
│                                                             │
│ ┌──────────┐                                               │
│ │          │  Portrait: [< Previous | Next >]              │
│ │ PORTRAIT │                                               │
│ │          │  Skin Tone:  [▓▓▓▓▒▒▒▒▒▒] Slider              │
│ └──────────┘                                               │
│              Hair Style: [Short ▼]                         │
│              Hair Color: [Brown ▼]                         │
│                                                             │
│ ════════════════════════════════════════════════════════   │
│                                                             │
│                              [Cancel]  [Next: Attributes >]│
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ CHARACTER CREATION                              Step 2 of 4 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ATTRIBUTES                                                  │
│ ───────────────                                            │
│                                                             │
│ Distribute 15 points among your core attributes.           │
│ Minimum 3, Maximum 10 per attribute.                       │
│                                                             │
│ Points Remaining: 0 / 15                                   │
│                                                             │
│ ┌─────────────────────────────────────────────────────┐   │
│ │ Intellect:  [6]  [-][+]                             │   │
│ │ Mental acuity, problem-solving, technical knowledge │   │
│ │ → Affects: Engineering, Science, Computer skills    │   │
│ └─────────────────────────────────────────────────────┘   │
│                                                             │
│ ┌─────────────────────────────────────────────────────┐   │
│ │ Charisma:   [7]  [-][+]                             │   │
│ │ Persuasiveness, leadership, social interaction      │   │
│ │ → Affects: Diplomacy, Negotiation, Crew morale      │   │
│ └─────────────────────────────────────────────────────┘   │
│                                                             │
│ ┌─────────────────────────────────────────────────────┐   │
│ │ Resilience: [2]  [-][+]                             │   │
│ │ Physical endurance, combat ability, stress resistance│   │
│ │ → Affects: Combat, Survival, Damage resistance      │   │
│ └─────────────────────────────────────────────────────┘   │
│                                                             │
│ ════════════════════════════════════════════════════════   │
│                                                             │
│ PRESET BUILDS:                                              │
│ [Engineer] [Diplomat] [Soldier] [Scientist] [Balanced]    │
│                                                             │
│                              [< Back]  [Next: Background >]│
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ CHARACTER CREATION                              Step 3 of 4 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ BACKGROUND                                                  │
│ ───────────────                                            │
│                                                             │
│ Choose your character's background. This affects your      │
│ starting skills and initial mission options.               │
│                                                             │
│ ┌─────────────────────────────────────────────────────┐   │
│ │ ○ ENGINEER - Former ship mechanic                   │   │
│ │   Starting bonus: +3 Engineering                    │   │
│ │   Starting item: Basic Engineering Kit              │   │
│ └─────────────────────────────────────────────────────┘   │
│                                                             │
│ ┌─────────────────────────────────────────────────────┐   │
│ │ ● DIPLOMAT - Evacuation coordinator                 │   │
│ │   Starting bonus: +3 Diplomacy                      │   │
│ │   Starting item: Diplomat's Badge                   │   │
│ └─────────────────────────────────────────────────────┘   │
│                                                             │
│ ┌─────────────────────────────────────────────────────┐   │
│ │ ○ SOLDIER - Security officer                        │   │
│ │   Starting bonus: +3 Combat                         │   │
│ │   Starting item: Pulse Pistol                       │   │
│ └─────────────────────────────────────────────────────┘   │
│                                                             │
│ ┌─────────────────────────────────────────────────────┐   │
│ │ ○ SCIENTIST - Research specialist                   │   │
│ │   Starting bonus: +3 Science                        │   │
│ │   Starting item: Advanced Scanner                   │   │
│ └─────────────────────────────────────────────────────┘   │
│                                                             │
│                              [< Back]  [Next: Confirm >]   │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ CHARACTER CREATION                              Step 4 of 4 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ CONFIRM YOUR CHARACTER                                      │
│ ───────────────────────────                                │
│                                                             │
│ ┌──────────┐                                               │
│ │          │  Name:       Commander Shepard                │
│ │ PORTRAIT │  Species:    Human                            │
│ │          │  Gender:     Female                           │
│ └──────────┘  Background: Diplomat                         │
│                                                             │
│ ════════════════════════════════════════════════════════   │
│                                                             │
│ STARTING STATS                                              │
│ ───────────────────                                        │
│                                                             │
│ Attributes:                                                 │
│ • Intellect: 6                                             │
│ • Charisma: 7                                              │
│ • Resilience: 2                                            │
│                                                             │
│ Skills:                                                     │
│ • Engineering: 0                                           │
│ • Diplomacy: 3 (background bonus)                          │
│ • Combat: 0                                                │
│ • Science: 0                                               │
│                                                             │
│ Starting Equipment:                                         │
│ • Diplomat's Badge (+2 Charisma)                           │
│ • Basic Vacuum Suit                                        │
│ • 500 Credits                                              │
│                                                             │
│ ════════════════════════════════════════════════════════   │
│                                                             │
│ Ready to begin your journey?                               │
│                                                             │
│                   [< Back]  [BEGIN GAME]                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation

### GDScript Implementation

```gdscript
# godot/scripts/autoload/player_manager.gd
extends Node

signal level_up(new_level: int)
signal rank_up(new_rank: String)
signal xp_gained(amount: int)
signal attribute_changed(attribute: String, new_value: int)
signal skill_improved(skill: String, new_value: int)

var db: SQLite
var db_path: String

func _ready():
    # Initialize database connection for current save
    var save_slot = GameState.current_save_slot
    db_path = "user://saves/save_slot_%d.db" % save_slot
    db = SQLite.new()
    db.path = db_path
    db.open_db()

    # Create tables if they don't exist
    create_tables()

func create_tables():
    """Create all necessary database tables"""
    # Player character table
    db.query("""
        CREATE TABLE IF NOT EXISTS player_character (
            id INTEGER PRIMARY KEY DEFAULT 1,
            name TEXT NOT NULL,
            species TEXT DEFAULT 'human',
            gender TEXT,
            appearance_data TEXT,
            current_rank TEXT DEFAULT 'cadet',
            level INTEGER DEFAULT 1,
            total_xp INTEGER DEFAULT 0,
            xp_to_next_level INTEGER DEFAULT 100,
            intellect INTEGER DEFAULT 5,
            charisma INTEGER DEFAULT 5,
            resilience INTEGER DEFAULT 5,
            engineering_skill INTEGER DEFAULT 0,
            diplomacy_skill INTEGER DEFAULT 0,
            combat_skill INTEGER DEFAULT 0,
            science_skill INTEGER DEFAULT 0,
            credits INTEGER DEFAULT 500,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            last_played TEXT,
            total_playtime_seconds INTEGER DEFAULT 0
        )
    """)

    # Inventory table
    db.query("""
        CREATE TABLE IF NOT EXISTS inventory_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_id TEXT NOT NULL,
            item_type TEXT NOT NULL,
            item_name TEXT NOT NULL,
            item_rarity TEXT,
            quantity INTEGER DEFAULT 1,
            stats_data TEXT,
            is_equipped BOOLEAN DEFAULT FALSE,
            is_installed BOOLEAN DEFAULT FALSE,
            acquired_date TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)

    # ... other tables (ship_state, missions, etc.)

func gain_xp(amount: int, source: String = ""):
    """Award XP and check for level up"""
    var player = get_player_data()

    # Apply rank XP bonus
    var rank_bonus = get_rank_xp_bonus(player.current_rank)
    var final_amount = int(amount * (1.0 + rank_bonus))

    player.total_xp += final_amount
    emit_signal("xp_gained", final_amount)

    # Check for level up
    while player.total_xp >= get_total_xp_for_level(player.level + 1):
        level_up(player)

    # Save changes
    save_player_data(player)

func level_up(player: Dictionary):
    """Level up the player"""
    player.level += 1

    # Award attribute point every 2 levels
    if player.level % 2 == 0:
        GameState.pending_attribute_points += 1

    # Award skill point
    GameState.pending_skill_points += 1

    # Check for rank up
    var new_rank = get_rank_for_level(player.level)
    if new_rank != player.current_rank:
        rank_up(player, new_rank)

    emit_signal("level_up", player.level)

func rank_up(player: Dictionary, new_rank: String):
    """Promote player to new rank"""
    player.current_rank = new_rank
    emit_signal("rank_up", new_rank)

    # Show rank up ceremony
    UI.show_rank_up_ceremony(new_rank)

func get_skill_total(skill_name: String) -> int:
    """Get total skill value (base + attribute bonus + equipment)"""
    var player = get_player_data()
    var base_skill = player.get(skill_name + "_skill", 0)
    var attribute_bonus = get_attribute_bonus_for_skill(skill_name, player)
    var equipment_bonus = get_equipment_bonus(skill_name)

    return base_skill + attribute_bonus + equipment_bonus

func get_attribute_bonus_for_skill(skill_name: String, player: Dictionary) -> int:
    """Calculate attribute bonus for a skill"""
    match skill_name:
        "engineering", "science":
            return int(player.intellect / 2.0)
        "diplomacy":
            return int(player.charisma / 2.0)
        "combat":
            return int(player.resilience / 2.0)
    return 0

func perform_skill_check(skill_name: String, difficulty: int) -> Dictionary:
    """
    Perform a skill check
    Returns: {success: bool, critical: bool, roll: int, total: int}
    """
    var skill_total = get_skill_total(skill_name)
    var roll = randi() % 20 + 1  # 1-20

    # Critical success
    if roll == 20:
        return {
            "success": true,
            "critical": true,
            "roll": roll,
            "total": roll + skill_total
        }

    # Critical failure
    if roll == 1:
        return {
            "success": false,
            "critical": false,
            "roll": roll,
            "total": roll + skill_total
        }

    # Normal check
    var total = roll + skill_total
    var success = total >= difficulty

    # Small chance to improve skill on use
    if success and randf() < 0.1:  # 10% chance
        improve_skill(skill_name, 1)

    return {
        "success": success,
        "critical": false,
        "roll": roll,
        "total": total
    }

func get_player_data() -> Dictionary:
    """Get current player data from database"""
    db.query("SELECT * FROM player_character WHERE id = 1")
    if db.query_result.size() > 0:
        return db.query_result[0]
    return {}

func save_player_data(player: Dictionary):
    """Save player data to database"""
    db.query("""
        UPDATE player_character SET
            name = ?,
            level = ?,
            total_xp = ?,
            current_rank = ?,
            intellect = ?,
            charisma = ?,
            resilience = ?,
            engineering_skill = ?,
            diplomacy_skill = ?,
            combat_skill = ?,
            science_skill = ?,
            credits = ?,
            last_played = ?
        WHERE id = 1
    """, [
        player.name, player.level, player.total_xp, player.current_rank,
        player.intellect, player.charisma, player.resilience,
        player.engineering_skill, player.diplomacy_skill,
        player.combat_skill, player.science_skill, player.credits,
        Time.get_datetime_string_from_system()
    ])
```

### Python API Endpoints

```python
# python/src/api/player.py

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Optional

router = APIRouter(prefix="/api/player", tags=["player"])

class XPGainRequest(BaseModel):
    save_slot: int
    xp_amount: int
    source: str

class XPGainResponse(BaseModel):
    new_total_xp: int
    new_level: int
    leveled_up: bool
    new_rank: Optional[str] = None
    rank_changed: bool

@router.post("/gain_xp", response_model=XPGainResponse)
async def award_xp(request: XPGainRequest):
    """
    Award XP to player and process level/rank changes
    """
    # This could be used for server-side validation
    # Or for online leaderboards in post-MVP
    pass

class SkillCheckRequest(BaseModel):
    skill_name: str
    difficulty: int
    player_stats: Dict

class SkillCheckResponse(BaseModel):
    success: bool
    critical: bool
    roll: int
    total: int
    message: str

@router.post("/skill_check", response_model=SkillCheckResponse)
async def perform_skill_check(request: SkillCheckRequest):
    """
    Server-side skill check (for validation/anti-cheat)
    """
    import random

    skill_value = request.player_stats.get(f"{request.skill_name}_skill", 0)
    attribute_bonus = calculate_attribute_bonus(
        request.skill_name,
        request.player_stats
    )
    total_skill = skill_value + attribute_bonus

    roll = random.randint(1, 20)
    total = roll + total_skill

    critical = roll == 20
    success = total >= request.difficulty or critical

    if critical:
        message = "Critical success!"
    elif roll == 1:
        message = "Critical failure!"
    elif success:
        message = f"Success! (rolled {roll} + {total_skill} = {total} vs DC {request.difficulty})"
    else:
        message = f"Failure. (rolled {roll} + {total_skill} = {total} vs DC {request.difficulty})"

    return SkillCheckResponse(
        success=success,
        critical=critical,
        roll=roll,
        total=total,
        message=message
    )
```

---

## Achievement System

### Overview

The achievement system tracks player accomplishments and provides additional progression goals beyond levels and ship systems. Achievements unlock automatically based on gameplay events and persist across save/load cycles.

**Key Features:**
- 15 achievements tracking major milestones
- Auto-unlock on gameplay events
- EventBus signal integration for UI notifications
- Full save/load support
- Extensible architecture for future additions

### Achievement Categories

#### Progression Achievements (6 achievements)

| Achievement ID | Name | Description | Unlock Condition |
|----------------|------|-------------|------------------|
| `first_mission` | First Steps | Complete your first mission | Complete 1 mission |
| `five_missions` | Mission Runner | Complete 5 missions | Complete 5 missions |
| `ten_missions` | Mission Master | Complete 10 missions | Complete 10 missions |
| `level_3` | Rising Star | Reach level 3 | Player level ≥ 3 |
| `level_5` | Experienced Explorer | Reach level 5 | Player level ≥ 5 |
| `level_10` | Veteran Commander | Reach level 10 | Player level ≥ 10 |

**Milestone Tracking:**
- Level 1-3: 2 achievements (level_3)
- Level 4-5: 1 achievement (level_5)
- Level 6-10: 1 achievement (level_10)
- Missions: 3 achievements (1, 5, 10 missions)

#### Ship System Achievements (3 achievements)

| Achievement ID | Name | Description | Unlock Condition |
|----------------|------|-------------|------------------|
| `first_upgrade` | Engineer's Touch | Upgrade your first ship system | Install any system at level 1+ |
| `ten_systems` | Complete Ship | Unlock all 10 ship systems | All 10 systems at level 1+ |
| `all_systems_level_1` | Launch Ready | Bring all ship systems to Level 1 | All 10 systems exactly at level 1 |

**Significance:**
- `first_upgrade`: Celebrates first step in ship building
- `ten_systems`: Major milestone - ship fully functional
- `all_systems_level_1`: Phase 2 unlock condition (leave Earth)

#### Economy Achievements (2 achievements)

| Achievement ID | Name | Description | Unlock Condition |
|----------------|------|-------------|------------------|
| `credits_1000` | Entrepreneur | Collect 1000 credits | Total credits ≥ 1000 |
| `credits_5000` | Wealthy Trader | Collect 5000 credits | Total credits ≥ 5000 |

**Economic Context:**
- 1000 credits: ~3-4 missions worth, significant savings
- 5000 credits: ~10-15 missions, substantial wealth
- Tracks total credits earned, not current balance

#### Skill Achievements (2 achievements)

| Achievement ID | Name | Description | Unlock Condition |
|----------------|------|-------------|------------------|
| `skill_master` | Skill Master | Raise any skill to level 10 | Any skill ≥ 10 |
| `ten_successful_checks` | Lucky Streak | Successfully pass 10 skill checks | 10+ successful skill checks |

**Skill Investment Rewards:**
- `skill_master`: Recognizes specialization (max skill in Milestone 1)
- `ten_successful_checks`: Celebrates player skill usage

#### Discovery Achievements (2 achievements)

| Achievement ID | Name | Description | Unlock Condition |
|----------------|------|-------------|------------------|
| `ten_parts` | Scavenger | Discover 10 different ship parts | 10+ parts discovered |
| `twenty_parts` | Master Scavenger | Discover 20 different ship parts | 20+ parts discovered |

**Discovery Tracking:**
- Tied to `discovered_parts` mission rewards
- Encourages exploration and optional content
- Recognizes thorough players

### Achievement Integration with Progression

**Automatic Unlock Triggers:**

| Game Event | Triggered Function | Achievements Checked |
|------------|-------------------|---------------------|
| Player levels up | `GameState.add_xp()` | Level achievements |
| Credits added | `GameState.add_credits()` | Credit achievements |
| Mission completed | `GameState.complete_mission()` | Mission count achievements |
| System installed | `GameState.install_system()` | System achievements |
| Skill increased | `GameState.increase_skill()` | Skill achievements |
| Part discovered | `EventBus.part_discovered` | Discovery achievements |
| Skill check passed | `GameState.record_skill_check_success()` | Skill check achievements |

**Example: Mission Completion Achievement Flow**

```gdscript
# In MissionManager when mission completes
func complete_mission(mission_id: String, outcome: String):
    # Award rewards
    award_mission_rewards(mission)

    # Mark mission complete
    GameState.completed_missions.append(mission_id)

    # Trigger achievement checks (automatic)
    # GameState checks:
    # - first_mission (1 mission)
    # - five_missions (5 missions)
    # - ten_missions (10 missions)

    # If achievement unlocks, EventBus.achievement_unlocked emits
    # UI automatically shows achievement notification
```

### Achievement Milestones Table

**Expected Achievement Unlocks by Player Level:**

| Player Level | Expected Achievements | Cumulative Total |
|--------------|----------------------|------------------|
| 1-2 | first_mission, first_upgrade, ten_successful_checks | 3 |
| 3 | level_3, five_missions, credits_1000, ten_parts | 7 |
| 4-5 | level_5, ten_missions | 9 |
| 6-9 | credits_5000, twenty_parts, skill_master | 12 |
| 10 | level_10, ten_systems, all_systems_level_1 | 15 |

**Achievement Completion Rate:**
- Level 3: ~45% achievements (7/15)
- Level 5: ~60% achievements (9/15)
- Level 10: 100% achievements (15/15) if thorough

### UI Notification System

**Achievement Unlock Flow:**

1. **Condition Met:** Player completes qualifying action
2. **Auto-Check:** GameState checks achievement conditions
3. **Unlock:** If unlocked, `GameState.unlock_achievement()` called
4. **Signal Emitted:** `EventBus.achievement_unlocked(achievement_id, data)` fires
5. **UI Notification:** Achievement popup appears
6. **Persistence:** Achievement saved with game state

**Example Achievement Popup:**

```
┌────────────────────────────────────────┐
│  🏆 ACHIEVEMENT UNLOCKED!              │
├────────────────────────────────────────┤
│                                        │
│  Rising Star                           │
│  Reach level 3                         │
│                                        │
│  Your skills are growing. The galaxy   │
│  awaits your exploration.              │
│                                        │
│  [Continue]                            │
│                                        │
└────────────────────────────────────────┘
```

### Achievement Progress Tracking

**Player Profile Achievement Display:**

```
┌──────────────────────────────────────────┐
│ ACHIEVEMENTS: 7 / 15 Unlocked (47%)      │
├──────────────────────────────────────────┤
│                                          │
│ ✅ First Steps - Complete first mission │
│ ✅ Rising Star - Reach level 3          │
│ ✅ Engineer's Touch - First upgrade     │
│ ✅ Mission Runner - 5 missions          │
│ ✅ Lucky Streak - 10 skill checks       │
│ ✅ Scavenger - 10 parts discovered      │
│ ✅ Entrepreneur - 1000 credits          │
│                                          │
│ 🔒 Experienced Explorer - Reach level 5 │
│ 🔒 Mission Master - 10 missions         │
│ 🔒 Veteran Commander - Reach level 10   │
│ 🔒 Complete Ship - 10 systems unlocked  │
│ 🔒 Launch Ready - All systems Level 1   │
│ 🔒 Wealthy Trader - 5000 credits        │
│ 🔒 Skill Master - Skill level 10        │
│ 🔒 Master Scavenger - 20 parts          │
│                                          │
│ [View Locked] [Sort by Category]        │
│                                          │
└──────────────────────────────────────────┘
```

**Progress API:**

```gdscript
# Get achievement progress summary
var progress = GameState.get_achievement_progress()
print("Unlocked: %d/%d (%.1f%%)" % [
    progress.unlocked,
    progress.total,
    progress.percentage
])

# Get all achievements
var all_achievements = GameState.get_all_achievements()

# Get only unlocked achievements
var unlocked = GameState.get_unlocked_achievements()
```

### Future Achievement Expansions

**Potential Phase 2 Achievements:**

**Exploration Achievements:**
- `first_warp_jump` - Jump to warp for the first time
- `five_systems_explored` - Visit 5 different star systems
- `discover_anomaly` - Discover your first anomaly

**Combat Achievements:**
- `first_victory` - Win your first ship combat
- `perfect_defense` - Win combat without taking damage
- `ace_pilot` - Win 10 ship combats

**Social Achievements:**
- `allied_faction` - Reach Allied status with a faction
- `master_diplomat` - Resolve 10 conflicts peacefully
- `first_crew_member` - Recruit your first crew member

**Ship Class Achievements:**
- `scout_class` - Build your first Scout-class ship
- `dreadnought_class` - Build a Dreadnought-class ship
- `legendary_ship` - Install all Level 5 systems

**Technical Implementation:**

See **[Achievement System Documentation](../../ACHIEVEMENTS.md)** for:
- Complete API reference
- Code examples
- Testing procedures
- Save/load integration
- Adding new achievements

---

**Document Complete**
**Total Length:** ~2,100 lines | 28,000+ words
**Last Updated:** November 7, 2025
**Related Documentation:**
- [Achievement System](../../ACHIEVEMENTS.md) - Technical implementation
- [Mission Framework](../content-systems/mission-framework.md) - Mission rewards
- [Ship Systems](../ship-systems/ship-systems.md) - System upgrades
- [Mission Reward Guidelines](../content-systems/mission-reward-guidelines.md) - Balancing
