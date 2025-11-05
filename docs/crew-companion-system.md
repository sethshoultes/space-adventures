# Space Adventures - Crew & Companion System

**Version:** 1.0
**Date:** November 5, 2025
**Purpose:** Optional crew/companion system with player choice

---

## Table of Contents
1. [Overview](#overview)
2. [Design Philosophy](#design-philosophy)
3. [Crew Member Structure](#crew-member-structure)
4. [Recruitment System](#recruitment-system)
5. [Crew Abilities & Bonuses](#crew-abilities--bonuses)
6. [Relationship System](#relationship-system)
7. [Crew Management UI](#crew-management-ui)
8. [Implementation](#implementation)

---

## Overview

### Core Concept

**Player Choice:** Solo captain OR build a crew team

**Philosophy:**
- Completely optional - solo play is fully viable
- Crew adds depth, not requirement
- Each crew member has personality, skills, and story
- Maximum 4 crew members (manageable, not overwhelming)
- Crew members are characters, not just stat bonuses

### When to Introduce

**Phase 1 (Earthbound):**
- Meet potential crew members during missions
- Build relationships before leaving Earth
- Optional recruitment before launch

**Phase 2 (Space):**
- Additional crew can be recruited at stations
- Crew becomes more valuable in deep space
- Crew-specific missions unlock

---

## Design Philosophy

### Solo vs Crew Balance

**Solo Captain Advantages:**
- Keep all rewards for yourself
- Make all decisions independently
- No crew conflicts or drama
- Lower resource consumption (food, water)
- Stealth missions easier

**Crew Team Advantages:**
- Skill bonuses (+10% per crew member in their specialty)
- Auto-repair systems (if engineer aboard)
- Better diplomacy options (if diplomat aboard)
- Combat advantage (if security officer aboard)
- Emotional story moments
- Unlock crew-specific missions

**Balance:** Neither path is "better" - just different playstyles

---

## Crew Member Structure

### Data Model

```python
# python/src/models/crew.py

from pydantic import BaseModel, Field
from typing import List, Dict, Optional
from enum import Enum

class CrewRole(str, Enum):
    ENGINEER = "engineer"
    PILOT = "pilot"
    SCIENTIST = "scientist"
    MEDIC = "medic"
    DIPLOMAT = "diplomat"
    SECURITY = "security"
    OPERATIONS = "operations"

class CrewMemberState(str, Enum):
    AVAILABLE = "available"          # Can be recruited
    RECRUITED = "recruited"          # On your ship
    UNAVAILABLE = "unavailable"      # Not met yet
    DECEASED = "deceased"            # Died in mission
    LEFT = "left"                    # Left the crew

class CrewMember(BaseModel):
    crew_id: str
    name: str
    species: str = "human"
    role: CrewRole
    age: int
    background: str

    # Stats
    primary_skill: str              # "engineering", "diplomacy", etc.
    skill_level: int = Field(ge=1, le=10)
    secondary_skills: Dict[str, int] = {}

    # Personality
    personality_traits: List[str]   # ["pragmatic", "loyal", "cautious"]
    likes: List[str]                # What they approve of
    dislikes: List[str]             # What they disapprove of

    # Story
    personal_quest: Optional[str] = None
    backstory: str
    motivation: str                 # Why they want to join

    # Relationship
    relationship_level: int = 0     # -100 to 100
    loyalty: int = 50              # 0-100, affects staying/leaving
    trust: int = 50                # Affects mission performance

    # State
    state: CrewMemberState = CrewMemberState.AVAILABLE
    first_met_mission: Optional[str] = None
    recruitment_mission: Optional[str] = None
    location: str = "earth"

    # Visuals
    portrait_path: Optional[str] = None
    description: str
    voice_style: str = "neutral"   # For dialogue generation

    # Gameplay
    station_assignment: Optional[str] = None  # Which ship station
    morale: int = 75               # 0-100
    injured: bool = False
    injury_severity: int = 0       # 0-100
```

### GDScript Equivalent

```gdscript
# godot/scripts/crew/crew_member.gd
class_name CrewMember
extends Resource

enum Role {ENGINEER, PILOT, SCIENTIST, MEDIC, DIPLOMAT, SECURITY, OPERATIONS}
enum State {AVAILABLE, RECRUITED, UNAVAILABLE, DECEASED, LEFT}

@export var crew_id: String
@export var member_name: String
@export var species: String = "human"
@export var role: Role
@export var age: int

# Stats
@export var primary_skill: String
@export var skill_level: int = 1
@export var secondary_skills: Dictionary = {}

# Personality
@export var personality_traits: Array[String] = []
@export var likes: Array[String] = []
@export var dislikes: Array[String] = []

# Story
@export var personal_quest: String = ""
@export var backstory: String = ""
@export var motivation: String = ""

# Relationship
@export var relationship_level: int = 0
@export var loyalty: int = 50
@export var trust: int = 50

# State
@export var state: State = State.AVAILABLE
@export var portrait_path: String = ""

# Gameplay
@export var morale: int = 75
@export var injured: bool = false

func get_skill_bonus(skill_name: String) -> int:
    """Get crew member's bonus for a skill"""
    if skill_name == primary_skill:
        return skill_level
    elif skill_name in secondary_skills:
        return secondary_skills[skill_name]
    return 0

func approve_action(action_type: String) -> int:
    """Check if crew member approves of an action (+/-relationship)"""
    if action_type in likes:
        return 10
    elif action_type in dislikes:
        return -15
    return 0

func can_perform_task(task_difficulty: int) -> bool:
    """Check if crew member can handle a task"""
    return skill_level >= task_difficulty and not injured
```

---

## Recruitment System

### Crew Roster (MVP)

**Available Crew Members (Phase 1):**

#### 1. **Sarah Chen** - Engineer
```json
{
  "crew_id": "sarah_chen",
  "name": "Sarah Chen",
  "species": "human",
  "role": "engineer",
  "age": 32,
  "primary_skill": "engineering",
  "skill_level": 7,
  "personality_traits": ["optimistic", "resourceful", "detail-oriented"],
  "likes": ["helping others", "technical solutions", "efficiency"],
  "dislikes": ["violence", "waste", "shortcuts"],
  "backstory": "Former orbital station engineer. Lost her job when Earth exodus began. Stayed behind to help stragglers.",
  "motivation": "Believes humanity's best days are ahead, wants to be part of rebuilding",
  "first_met_mission": "mission_003_power_up",
  "recruitment_conditions": {
    "complete_mission": "mission_003_power_up",
    "player_level": 2,
    "relationship": 20
  }
}
```

#### 2. **Marcus Reed** - Pilot/Rival
```json
{
  "crew_id": "marcus_reed",
  "name": "Marcus Reed",
  "species": "human",
  "role": "pilot",
  "age": 45,
  "primary_skill": "combat",
  "skill_level": 6,
  "secondary_skills": {"engineering": 4},
  "personality_traits": ["gruff", "competitive", "secretly loyal"],
  "likes": ["directness", "competence", "fair competition"],
  "dislikes": ["betrayal", "cowardice", "excuses"],
  "backstory": "Rival scavenger. Ex-military pilot. Cynical about the exodus but respects skill.",
  "motivation": "Nowhere else to go. Recognizes you're the best bet for survival.",
  "first_met_mission": "mission_005_the_rival",
  "recruitment_conditions": {
    "complete_mission": "mission_010_marcus_helps",
    "player_level": 4,
    "relationship": 30,
    "choice_required": "spare_marcus_ship"
  }
}
```

#### 3. **Dr. Amara Okafor** - Scientist/Medic
```json
{
  "crew_id": "amara_okafor",
  "name": "Dr. Amara Okafor",
  "species": "human",
  "role": "scientist",
  "age": 38,
  "primary_skill": "science",
  "skill_level": 8,
  "secondary_skills": {"diplomacy": 5},
  "personality_traits": ["curious", "ethical", "thoughtful"],
  "likes": ["discovery", "ethical behavior", "knowledge"],
  "dislikes": ["cruelty", "ignorance", "rushing"],
  "backstory": "Xenobiologist who stayed to study post-exodus ecosystem changes.",
  "motivation": "Wants to discover what's really out there in the galaxy",
  "first_met_mission": "mission_007_research_station",
  "recruitment_conditions": {
    "complete_mission": "mission_007_research_station",
    "player_level": 3,
    "relationship": 25,
    "ship_systems": {"sensors": 2}
  }
}
```

#### 4. **Zara Vel** - Alien Diplomat (Phase 2)
```json
{
  "crew_id": "zara_vel",
  "name": "Zara Vel",
  "species": "zenari",
  "role": "diplomat",
  "age": 247,
  "primary_skill": "diplomacy",
  "skill_level": 9,
  "secondary_skills": {"science": 6},
  "personality_traits": ["patient", "enigmatic", "wise"],
  "likes": ["cultural exchange", "peaceful solutions", "honesty"],
  "dislikes": ["aggression", "deception", "haste"],
  "backstory": "Zenari ambassador fascinated by humanity. Wants to understand your species.",
  "motivation": "Study humanity and guide them in the galactic community",
  "first_met_mission": "space_encounter_first_contact",
  "recruitment_conditions": {
    "phase": 2,
    "player_level": 5,
    "relationship": 40,
    "reputation": {"zenari": 50}
  }
}
```

### Recruitment Flow

```gdscript
# godot/scripts/crew/crew_manager.gd
extends Node

var available_crew: Array[CrewMember] = []
var recruited_crew: Array[CrewMember] = []
var max_crew_size: int = 4

func _ready():
    load_crew_roster()
    GameState.connect("mission_completed", _check_recruitment_opportunities)

func load_crew_roster():
    var crew_data = load_json("res://assets/data/crew_roster.json")
    for member_data in crew_data:
        var crew = CrewMember.new()
        # Populate crew member
        available_crew.append(crew)

func check_recruitment_available(crew: CrewMember) -> bool:
    """Check if crew member can be recruited"""

    # Already recruited or unavailable
    if crew.state != CrewMember.State.AVAILABLE:
        return false

    # Crew is full
    if len(recruited_crew) >= max_crew_size:
        return false

    # Check conditions
    var conditions = get_recruitment_conditions(crew.crew_id)

    # Mission requirement
    if conditions.has("complete_mission"):
        if not conditions.complete_mission in GameState.progress.completed_missions:
            return false

    # Level requirement
    if conditions.has("player_level"):
        if GameState.player.level < conditions.player_level:
            return false

    # Relationship requirement
    if conditions.has("relationship"):
        if crew.relationship_level < conditions.relationship:
            return false

    # Choice requirement
    if conditions.has("choice_required"):
        if not check_player_made_choice(conditions.choice_required):
            return false

    return true

func offer_recruitment(crew: CrewMember):
    """Offer crew member to join"""
    var dialog = RecruitmentDialog.new()
    dialog.setup(crew)
    dialog.accepted.connect(_recruit_crew_member.bind(crew))
    dialog.rejected.connect(_reject_crew_member.bind(crew))
    get_tree().root.add_child(dialog)
    dialog.popup_centered()

func _recruit_crew_member(crew: CrewMember):
    crew.state = CrewMember.State.RECRUITED
    recruited_crew.append(crew)

    # Remove from available
    available_crew.erase(crew)

    # Trigger welcome event
    EventBus.emit_signal("crew_member_joined", crew)

    # Show welcome message
    show_crew_joined_notification(crew)

func _reject_crew_member(crew: CrewMember):
    # Crew member's feelings may be hurt
    crew.relationship_level -= 10
    crew.loyalty -= 5

func dismiss_crew_member(crew: CrewMember):
    """Remove crew member from ship"""
    crew.state = CrewMember.State.LEFT
    recruited_crew.erase(crew)

    EventBus.emit_signal("crew_member_left", crew)
```

---

## Crew Abilities & Bonuses

### Passive Bonuses

**Engineer (Sarah Chen):**
- +10% to engineering skill checks
- Systems repair 25% faster
- 10% reduction in power consumption
- Can perform emergency repairs during missions

**Pilot (Marcus Reed):**
- +10% dodge chance in combat
- +15% faster travel speed
- Can perform evasive maneuvers
- Better escape chance from hostile encounters

**Scientist (Dr. Okafor):**
- +10% to science skill checks
- Sensors gain +1 effective level
- Scan speed increased 20%
- Can analyze anomalies for extra data

**Diplomat (Zara Vel):**
- +15% to diplomacy checks
- 10% better trade prices
- Higher reputation gains
- Unlock diplomatic solutions in conflicts

### Active Abilities

```gdscript
class CrewAbility:
    var ability_id: String
    var name: String
    var description: String
    var cooldown: int = 0  # Turns
    var current_cooldown: int = 0

    func can_use() -> bool:
        return current_cooldown == 0

    func use(context: Dictionary) -> Dictionary:
        # Implement ability effect
        current_cooldown = cooldown
        return {"success": true}
```

**Examples:**

**Emergency Repair (Engineer):**
```gdscript
func emergency_repair() -> void:
    """Repair 25% of all damaged systems instantly"""
    for system in GameState.ship.systems.values():
        if system.health < 100:
            system.health = min(100, system.health + 25)
    # Cooldown: 5 missions
```

**Evasive Maneuvers (Pilot):**
```gdscript
func evasive_maneuvers() -> void:
    """Avoid next incoming attack"""
    add_buff("dodge_next_attack", 1)
    # Cooldown: 3 encounters
```

**Deep Scan (Scientist):**
```gdscript
func deep_scan(target: String) -> Dictionary:
    """Reveal all information about a target"""
    return {
        "detailed_info": true,
        "hidden_secrets": true,
        "optimal_approach": "suggested_strategy"
    }
    # Cooldown: 2 scans
```

---

## Relationship System

### Relationship Levels

```
-100 to -51:  Hostile (will leave at next opportunity)
 -50 to -1:   Unfriendly (may leave, poor performance)
   0 to 24:   Neutral (professional)
  25 to 49:   Friendly (good performance)
  50 to 74:   Close (very loyal, bonus performance)
  75 to 100:  Best Friends (maximum loyalty, unlock personal quest)
```

### Gaining/Losing Relationship

**Gain relationship:**
- Complete missions successfully (+5)
- Make choices they approve of (+10)
- Talk to them regularly (+2)
- Complete their personal quest (+50)
- Give them gifts (+5 to +15)
- Assign them to tasks they enjoy (+3)

**Lose relationship:**
- Make choices they disapprove of (-15)
- Ignore them for long periods (-5)
- Get them injured in missions (-20)
- Betray their trust (-50)
- Dismiss them from crew (-100)

### Personal Quests

Each crew member has a personal storyline:

**Sarah Chen - "The Message":**
- Her mentor sent a final message before leaving Earth
- Locate the beacon and retrieve it
- Unlocks: Enhanced engineering ability, max loyalty

**Marcus Reed - "Redemption":**
- Confronted by his past military actions
- Choose to help him make amends or hide
- Unlocks: Combat veteran bonus, crew mission expertise

**Dr. Okafor - "The Discovery":**
- Find evidence of pre-human alien life on Earth
- Scientific breakthrough that changes everything
- Unlocks: Advanced scanning, alien artifact analysis

**Zara Vel - "Cultural Bridge":**
- Help her write a comprehensive guide to humanity
- Document your choices and reasoning
- Unlocks: Galactic reputation boost, diplomatic immunity

---

## Crew Management UI

### Crew Roster Screen

```
┌──────────────────────────────────────────────────┐
│  CREW ROSTER                                     │
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌─────────────────┐  ┌─────────────────┐      │
│  │  [Portrait]     │  │  [Portrait]     │      │
│  │  Sarah Chen     │  │  Marcus Reed    │      │
│  │  Engineer       │  │  Pilot          │      │
│  │  ────────────   │  │  ────────────   │      │
│  │  ❤️❤️❤️❤️❤️ 85%   │  │  ❤️❤️❤️ 55%      │      │
│  │  Engineering: 7 │  │  Combat: 6      │      │
│  │  Morale: High   │  │  Morale: Good   │      │
│  │  [Talk][Info]   │  │  [Talk][Info]   │      │
│  └─────────────────┘  └─────────────────┘      │
│                                                  │
│  Available Positions:                           │
│  ☐ Scientist     ☐ Diplomat                     │
│                                                  │
│  [Recruit New Crew] [Assign Stations] [Back]   │
└──────────────────────────────────────────────────┘
```

### Crew Conversation

```
┌──────────────────────────────────────────────────┐
│  CONVERSATION - Sarah Chen                       │
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌────────────┐                                 │
│  │ [Portrait] │  "I've been thinking about that │
│  │            │   power core. We could optimize │
│  │ Sarah Chen │   the plasma flow for another    │
│  │            │   10% efficiency. Want me to     │
│  │            │   take a look?"                  │
│  └────────────┘                                 │
│                                                  │
│  Your response:                                  │
│  ○ "Absolutely, go for it." [+5 relationship]   │
│  ○ "Not right now, focus on hull repairs."      │
│  ○ "What's the risk?" [Info]                    │
│  ○ "Tell me about yourself." [Personal]         │
│                                                  │
│  Relationship: ❤️❤️❤️❤️❤️ 85% (Close)            │
│  Personal Quest: [The Message] Available!       │
│                                                  │
│  [Continue] [End Conversation]                  │
└──────────────────────────────────────────────────┘
```

### Station Assignment

```
┌──────────────────────────────────────────────────┐
│  STATION ASSIGNMENTS                             │
├──────────────────────────────────────────────────┤
│                                                  │
│      BRIDGE STATIONS                            │
│                                                  │
│  [Helm]          ← Marcus Reed (Pilot)          │
│  [Engineering]   ← Sarah Chen (Engineer)        │
│  [Science]       ← Dr. Okafor (Scientist)       │
│  [Operations]    ← [Empty]                      │
│                                                  │
│  Current Bonuses:                               │
│  ⚡ Engineering: +10% efficiency                │
│  🎯 Combat: +15% dodge                          │
│  🔬 Sensors: +1 effective level                 │
│                                                  │
│  [Auto-Assign] [Clear All] [Apply]             │
└──────────────────────────────────────────────────┘
```

---

## Implementation

### Integration with Existing Systems

**GameState Extension:**
```gdscript
# Add to game_state.gd
var crew: Dictionary = {
    "max_size": 4,
    "members": [],  # Array of CrewMember
    "available": [],  # Crew members you've met but not recruited
}

func get_crew_skill_bonus(skill_name: String) -> int:
    """Get total crew bonus for a skill"""
    var total_bonus = 0
    for member in crew.members:
        total_bonus += member.get_skill_bonus(skill_name)
    return total_bonus

func get_crew_by_role(role: String) -> CrewMember:
    """Find crew member with specific role"""
    for member in crew.members:
        if CrewMember.Role.keys()[member.role] == role.to_upper():
            return member
    return null
```

**Mission Integration:**
```gdscript
# Crew can comment on missions
func get_crew_opinion(mission: Dictionary) -> Array:
    """Get crew opinions on a mission"""
    var opinions = []
    for member in GameState.crew.members:
        var opinion = member.evaluate_mission(mission)
        if opinion != "":
            opinions.append({
                "crew_member": member.member_name,
                "opinion": opinion
            })
    return opinions
```

**AI Dialogue Generation:**
```python
# python/src/api/crew_dialogue.py

@router.post("/crew/dialogue")
async def generate_crew_dialogue(request: CrewDialogueRequest):
    """Generate dynamic crew dialogue"""
    context = f"""
    Crew Member: {request.crew_member.name}
    Personality: {", ".join(request.crew_member.personality_traits)}
    Relationship: {request.crew_member.relationship_level}/100
    Situation: {request.situation}

    Generate a response this crew member would say given their personality
    and current relationship level with the captain.
    """

    dialogue = await ai_client.generate(context)
    return {"dialogue": dialogue}
```

---

**Document Status:** Complete v1.0
**Last Updated:** November 5, 2025
