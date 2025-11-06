# Space Adventures - Mission Framework

**Version:** 1.0
**Date:** November 5, 2025
**Purpose:** Define mission structure, progression, and implementation

---

## Table of Contents
1. [Mission System Overview](#mission-system-overview)
2. [Mission Types](#mission-types)
3. [Mission Structure](#mission-structure)
4. [Progression and Gating](#progression-and-gating)
5. [Encounter System](#encounter-system)
6. [Reward System](#reward-system)
7. [Implementation Guide](#implementation-guide)

---

## Mission System Overview

### Core Principles
1. **Choices Matter**: Every mission has multiple approaches
2. **Skill-Based**: Player skills unlock different options
3. **Progressive Rewards**: Better skills → better outcomes
4. **Narrative Coherence**: Missions feel connected to the world
5. **Mix of Content**: 50% scripted, 50% AI-generated

### Mission Flow

```
WORKSHOP HUB
    ↓
Select Mission
    ↓
Read Briefing
    ↓
Choose Approach
    ↓
Mission Stages (2-4 stages)
    ├→ Make Choices
    ├→ Skill Checks
    ├→ Consequences
    └→ Possible Failure Points
    ↓
Mission Complete/Failed
    ↓
Rewards + XP
    ↓
Return to Workshop
    ↓
Install Parts / Level Up
    ↓
New Missions Unlock
```

---

## Mission Types

### 1. Salvage Missions
**Goal:** Retrieve specific ship parts from locations

**Structure:**
- Location: Abandoned site (spaceport, military base, research station)
- Objective: Find and retrieve a specific part
- Challenges: Security, environmental hazards, other scavengers
- Reward: Ship part (guaranteed)

**Example: "The Spaceport Ruins"**
```
Location: Kennedy Spaceport
Objective: Retrieve Warp Coil from Hangar 7
Difficulty: ★★☆☆☆

Stages:
1. Approach (choose how to enter)
2. Navigate hangar (deal with obstacles)
3. Retrieve part (solve puzzle/challenge)
4. Escape (optional complication)

Choices:
- Cautious approach (safer, slower)
- Direct approach (risky, faster)
- Technical approach (requires Engineering skill)
```

### 2. Exploration Missions
**Goal:** Investigate unknown locations, discover secrets

**Structure:**
- Location: Mysterious or uncharted area
- Objective: Explore and report findings
- Challenges: Unknown threats, environmental hazards
- Reward: Information, rare items, XP

**Example: "The Silent Laboratory"**
```
Location: Abandoned Research Facility
Objective: Investigate what happened
Difficulty: ★★★☆☆

Discovery: Scientists were researching experimental technology
         before evacuation

Choices Impact:
- Destroy research (safe, moral)
- Take research data (risky, valuable)
- Upload to network (ethical dilemma)
```

### 3. Trade Missions
**Goal:** Negotiate deals, acquire resources through exchange

**Structure:**
- Location: Settlement, trading post
- Objective: Trade for needed parts/resources
- Challenges: Negotiation, limited resources, trust
- Reward: Parts through trade (no combat)

**Example: "The Scavenger's Deal"**
```
Location: Wasteland Trading Post
Objective: Trade for Power Regulator

NPC: Marcus, rival scavenger
Challenge: He wants something you have OR
          Convince him you need it more OR
          Find what he needs first

Outcomes:
- Trade items (lose resources, gain part)
- Convince him (Diplomacy check, better deal)
- Complete his quest first (earn trust, best reward)
```

### 4. Rescue/Assistance Missions
**Goal:** Help others in need

**Structure:**
- Location: Various
- Objective: Save people, provide aid
- Challenges: Time pressure, moral choices
- Reward: Reputation, gratitude rewards, karma

**Example: "Trapped Miners"**
```
Location: Collapsed Mine
Objective: Rescue trapped miners

Complication: You need a part from the mine for your ship

Choices:
- Rescue first, forget the part (moral, lose reward)
- Get part first, then rescue (risky, miners might die)
- Find solution that does both (requires high Engineering)

Consequences: Your choice affects NPC relationships and
             future mission availability
```

### 5. Combat Missions (Mid-Late Game)
**Goal:** Defend against or attack hostile forces

**Structure:**
- Location: Various
- Objective: Defeat enemies or survive encounter
- Challenges: Ship combat, tactical decisions
- Reward: Military-grade parts, combat experience

**Example: "Pirate Ambush"**
```
Location: Asteroid Field
Objective: Survive or defeat pirates

Combat Options:
- Fight (requires Weapons L2+)
- Flee (requires Propulsion L2+)
- Negotiate (requires Comms L2+, Diplomacy skill)
- Hide (requires Sensors L2+)

Outcome varies by approach and systems
```

### 6. Story Missions (Scripted)
**Goal:** Advance main narrative

**Structure:**
- Fixed content, branching choices
- Character-driven moments
- Major revelations
- Permanent consequences

**Example: "The Inheritance"**
```
Mission: First mission, learn about your parent's plans

Fixed beats:
- Discover workshop
- Find parent's logs
- Learn about the ship project
- Choose to continue or abandon their dream

This sets player motivation and tone
```

---

## Mission Structure

### Standard Mission Template

```json
{
  "mission_id": "unique_id",
  "title": "Mission Name",
  "type": "salvage|exploration|trade|rescue|combat|story",
  "location": "location_name",
  "description": "Brief overview",
  "difficulty": 1-5,
  "requirements": {
    "min_level": 1,
    "required_systems": [],
    "completed_missions": []
  },
  "objectives": [
    "Primary objective text",
    "Optional objective text"
  ],
  "stages": [
    {
      "stage_id": "stage_1",
      "description": "What's happening in this stage",
      "choices": [
        {
          "choice_id": "choice_a",
          "text": "Choice text",
          "requirements": {
            "skill": "engineering",
            "skill_level": 3
          },
          "consequences": {
            "success": {
              "next_stage": "stage_2a",
              "effects": ["positive_outcome"],
              "rewards": []
            },
            "failure": {
              "next_stage": "stage_2_fail",
              "effects": ["negative_outcome"],
              "penalties": []
            }
          }
        }
      ]
    }
  ],
  "rewards": {
    "xp": 100,
    "items": ["item_id"],
    "reputation": 10,
    "unlocks": ["new_mission_id"]
  },
  "failure_consequences": {
    "xp": 25,
    "effects": ["reputation_loss"]
  }
}
```

### Stage Types

#### **Approach Stage**
First stage, sets up the situation

```
"You arrive at the location. How do you proceed?"

Choices:
- Cautious (scan first, gather info)
- Direct (go straight in)
- Technical (use skills to bypass)
- Social (talk your way in)
```

#### **Challenge Stage**
Core mission content, test player skills/systems

```
"You encounter [obstacle]. What do you do?"

Challenges:
- Skill check (Engineering, Science, Combat, Diplomacy)
- System check (requires certain ship system)
- Resource check (consume items)
- Time pressure (must decide quickly)
```

#### **Resolution Stage**
Climax or final choice

```
"You've reached [objective]. Final decision:"

Consequences:
- Success outcomes (got what you came for)
- Failure outcomes (things went wrong)
- Moral choice (what's the right thing to do?)
```

#### **Escape Stage** (optional)
Complications during exit

```
"On your way out, something happens..."

Complication types:
- Pursuit (chase sequence)
- Collapse (escaping hazard)
- Confrontation (face consequences)
- Revelation (learn something new)
```

---

## Progression and Gating

### Earth Phase Progression

**Act 1: Getting Started (Systems 1-3)**
- Missions: 5-8 missions
- Focus: Hull, Power, Propulsion
- Difficulty: ★☆☆☆☆ to ★★☆☆☆
- Narrative: Learn the basics, meet key NPCs

**Key Missions:**
1. "The Inheritance" (Story) → Discover workshop
2. "First Flight" → Install Hull L1, test it
3. "Power Up" → Find power core
4. "Learning to Fly" → Install propulsion

**Act 2: Building the Ship (Systems 4-7)**
- Missions: 10-15 missions
- Focus: Warp, Life Support, Computer, Sensors
- Difficulty: ★★☆☆☆ to ★★★☆☆
- Narrative: Prepare for space, choices become meaningful

**Key Missions:**
5. "The Rival" (Story) → Meet competing scavenger
6. "The Trade" → Learn about negotiation
7. "Echoes of the Past" → Discover why Earth was abandoned
8. "Warp Trial" → Critical mission to get warp drive

**Act 3: Final Preparations (Systems 8-10)**
- Missions: 8-12 missions
- Focus: Shields, Weapons, Communications
- Difficulty: ★★★☆☆ to ★★★★☆
- Narrative: High stakes, preparing to leave Earth forever

**Key Missions:**
9. "The Last Stand" (Story) → Defend your workshop
10. "Final Goodbyes" (Story) → Say farewell to Earth
11. "Launch Day" (Story) → First warp jump

### Unlock Requirements

**Basic Missions:**
- Available from start
- No requirements
- Tutorial content

**Skill-Locked Missions:**
- Require minimum skill level
- Example: Engineering 5 unlocks "Advanced Salvage"

**System-Locked Missions:**
- Require certain ship systems
- Example: Sensors L2 unlocks "Long-Range Detection"

**Story-Locked Missions:**
- Require previous missions completed
- Example: Complete "The Rival" to unlock "Rival's Revenge"

**Reputation-Locked Missions:**
- Require good standing with NPCs/factions
- Example: Help 5 people → unlock "Community Leader"

### Phase 2 Unlock

**Requirements to Launch:**
All 10 core systems must be at least Level 1:
- ✓ Hull L1+
- ✓ Power L1+
- ✓ Propulsion L1+
- ✓ Warp L1+
- ✓ Life Support L1+
- ✓ Computer L1+
- ✓ Sensors L1+
- ✓ Shields L1+
- ✓ Weapons L1+
- ✓ Communications L1+

**Launch Mission:** "Escape Velocity" (Story)
- Cinematic first warp jump
- Leave Earth's orbit
- Tutorial for space phase
- Emotional goodbye

---

## Encounter System (Space Phase)

### Random Encounters

When traveling or exploring, player has encounters based on location and ship sensors.

**Encounter Frequency:**
- Low Sensors: 40% chance per travel
- Medium Sensors: 25% chance (see more, avoid more)
- High Sensors: 15% chance (almost always avoidable)

### Encounter Types

#### **Distress Calls**
```
"You receive a distress signal from nearby..."

Type: Rescue mission
Choices:
- Respond (investigation/combat/rescue)
- Ignore (karma penalty, guilt)
- Scan first (gather info, requires Sensors)

Outcomes:
- Real distress → rescue people, earn gratitude
- Trap → ambush, combat
- False signal → mystery to investigate
```

#### **Hostile Encounters**
```
"Unidentified ships approach on an intercept course..."

Type: Combat or diplomacy
Choices:
- Fight (requires weapons)
- Flee (requires propulsion/warp)
- Hail them (requires communications)
- Hide (requires stealth tech)

Outcomes vary by choice and systems
```

#### **Anomalies**
```
"Sensors detect something unusual ahead..."

Type: Exploration/science
Choices:
- Investigate closely (risky, high reward)
- Scan from distance (safe, moderate reward)
- Mark and continue (zero risk, no reward)
- Call for help (requires communications)

Discoveries:
- Scientific phenomenon (XP, data)
- Ancient technology (rare parts)
- Spatial hazard (damage)
- Secret location (unlock new area)
```

#### **First Contact**
```
"You encounter a ship of unknown origin..."

Type: Diplomacy/story
Choices:
- Peaceful approach (diplomacy check)
- Defensive posture (neutral)
- Aggressive scan (hostile)

Outcomes:
- New faction relations
- Trade opportunities
- Cultural exchange
- Conflict
```

#### **Moral Dilemmas**
```
"You witness [situation]. Do you intervene?"

Examples:
- Pirates attacking a freighter
- Scientists conducting unethical experiments
- Refugees fleeing persecution
- Ship dumping toxic waste

Choices affect:
- Karma/reputation
- Faction relations
- Future encounters
- Narrative branches
```

### Encounter Difficulty Scaling

**Early Space (Warp 1-2):**
- Encounters: Mostly safe, educational
- Combat: Weak enemies, can flee
- Rewards: Common parts, XP

**Mid Space (Warp 3-4):**
- Encounters: Mixed danger
- Combat: Challenging fights
- Rewards: Rare parts, faction standing

**Deep Space (Warp 5+):**
- Encounters: Dangerous, high stakes
- Combat: Deadly enemies, tactics required
- Rewards: Legendary parts, major story beats

---

## Reward System

### Experience Points (XP)

**XP Sources:**
- Complete mission: 50-200 XP
- Skill check success: +25 XP
- Discover location: +100 XP
- Win combat: +50-150 XP
- Make meaningful choice: +25 XP

**Level Up:**
- Level 2: 200 XP
- Level 3: 500 XP
- Level 4: 1000 XP
- Level 5: 2000 XP
- Each level: ×2 previous

**Level Benefits:**
- +2 skill points to distribute
- +5% to all checks
- Unlock new mission types
- Better rewards in missions

### Ship Parts

**Rarity Distribution:**
- Common (White): 50% of drops
- Uncommon (Green): 30% of drops
- Rare (Blue): 15% of drops
- Epic (Purple): 4% of drops
- Legendary (Orange): 1% of drops

**Guaranteed Rewards:**
- Story missions: Always give required parts for progression
- Optional missions: Random quality, higher difficulty → better chance

### Reputation System

**Factions (Space Phase):**
- Federation (explorers, diplomats)
- Traders Guild (merchants, information)
- Independent Colonies (settlers, diverse)
- Scientific Collective (researchers, technology)
- Free Captains (pirates, freedom)

**Reputation Levels:**
- Hostile: -100 to -51
- Unfriendly: -50 to -1
- Neutral: 0 to 49
- Friendly: 50 to 99
- Allied: 100+

**Reputation Effects:**
- Unlock faction missions
- Better trade prices
- Access to exclusive parts
- Emergency assistance
- Story implications

### Karma System

**Karma Points:**
- Earned through moral choices
- Good karma: Help others, ethical choices
- Bad karma: Selfish choices, harm others
- Neutral: Pragmatic, balanced

**Karma Effects:**
- Affects NPC reactions
- Unlocks special encounters
- Influences ending
- No "wrong" path, just consequences

---

## Implementation Guide

### Mission Manager (GDScript)

```gdscript
# scripts/missions/mission_manager.gd
extends Node

var available_missions: Array = []
var active_mission: Dictionary = {}
var completed_missions: Array = []

func _ready():
    load_missions()

func load_missions():
    # Load from JSON files
    var scripted = load_scripted_missions()
    var generated = generate_ai_missions()
    available_missions = scripted + generated
    filter_available_missions()

func filter_available_missions():
    # Filter by requirements
    available_missions = available_missions.filter(func(m):
        return meets_requirements(m)
    )

func meets_requirements(mission: Dictionary) -> bool:
    var req = mission.get("requirements", {})

    # Check level
    if req.get("min_level", 0) > GameState.player.level:
        return false

    # Check systems
    for sys in req.get("required_systems", []):
        if GameState.ship.systems[sys].level < 1:
            return false

    # Check completed missions
    for mission_id in req.get("completed_missions", []):
        if not mission_id in completed_missions:
            return false

    return true

func start_mission(mission_id: String):
    for mission in available_missions:
        if mission.id == mission_id:
            active_mission = mission.duplicate(true)
            active_mission.current_stage = 0
            get_tree().change_scene_to_file("res://scenes/mission_play.tscn")
            break

func advance_stage(choice_id: String):
    var stage = active_mission.stages[active_mission.current_stage]
    var choice = find_choice(stage, choice_id)

    # Check requirements
    if not meets_choice_requirements(choice):
        return "FAIL"

    # Apply consequences
    var result = apply_consequences(choice)

    # Advance or complete
    if result.has("next_stage"):
        active_mission.current_stage = find_stage_index(result.next_stage)
        return "CONTINUE"
    else:
        complete_mission(result)
        return "COMPLETE"

func complete_mission(result: Dictionary):
    # Award rewards
    GameState.player.xp += active_mission.rewards.xp
    for item_id in active_mission.rewards.items:
        GameState.add_to_inventory(item_id)

    # Mark complete
    completed_missions.append(active_mission.id)
    GameState.progress.completed_missions = completed_missions

    # Unlock new missions
    for unlock in active_mission.rewards.get("unlocks", []):
        unlock_mission(unlock)

    # Return to workshop
    active_mission = {}
    get_tree().change_scene_to_file("res://scenes/workshop.tscn")
```

### Mission JSON Structure

```json
{
  "mission_id": "kennedy_spaceport_salvage",
  "title": "Echoes in Hangar 7",
  "type": "salvage",
  "location": "Kennedy Spaceport Ruins",
  "description": "Abandoned decades ago, Kennedy Spaceport still holds valuable tech. Your sensors indicate a warp coil in Hangar 7, but security drones still patrol.",
  "difficulty": 2,
  "requirements": {
    "min_level": 1,
    "required_systems": [],
    "completed_missions": ["first_flight"]
  },
  "objectives": [
    "Retrieve warp coil from Hangar 7",
    "[OPTIONAL] Disable security without destroying drones"
  ],
  "stages": [
    {
      "stage_id": "approach",
      "title": "Approaching the Spaceport",
      "description": "The rusted gates of Kennedy Spaceport loom ahead. Collapsed towers and overgrown runways tell the story of rapid abandonment. Your destination is Hangar 7, visible in the distance. Security drones patrol in predictable patterns.",
      "image": "spaceport_exterior",
      "choices": [
        {
          "choice_id": "hack_gate",
          "text": "Hack the security terminal at the gate",
          "requirements": {
            "skill": "engineering",
            "skill_level": 3
          },
          "success_chance": "skill_based",
          "consequences": {
            "success": {
              "text": "The terminal flickers to life. Ancient security protocols are no match for your skills. The drones power down, marking you as 'authorized personnel'.",
              "next_stage": "inside_safe",
              "effects": ["drones_disabled"],
              "xp_bonus": 25
            },
            "failure": {
              "text": "Your attempt triggers a security alert. The drones converge on your position!",
              "next_stage": "inside_combat",
              "effects": ["drones_alerted"]
            }
          }
        },
        {
          "choice_id": "sneak",
          "text": "Wait for patrol pattern, then sneak past",
          "requirements": {},
          "success_chance": 70,
          "consequences": {
            "success": {
              "text": "Timing your movement carefully, you slip past the patrol. The hangar door stands ahead, unguarded.",
              "next_stage": "inside_safe"
            },
            "failure": {
              "text": "A drone's searchlight sweeps across you. Detected!",
              "next_stage": "inside_detected"
            }
          }
        },
        {
          "choice_id": "direct",
          "text": "Just walk in. They're old drones, probably non-functional",
          "requirements": {},
          "consequences": {
            "text": "The drones power up immediately, weapons charging. They're very functional.",
            "next_stage": "inside_combat"
          }
        }
      ]
    },
    {
      "stage_id": "inside_safe",
      "title": "Inside Hangar 7",
      "description": "Hangar 7 is a vast, echoing space. Skeletal remains of ships long since stripped for parts hang from the ceiling. Your scanner pings - the warp coil is in the maintenance office at the far end. But the office is locked.",
      "image": "hangar_interior",
      "choices": [
        {
          "choice_id": "force_door",
          "text": "Force the door open",
          "requirements": {},
          "consequences": {
            "text": "The door crashes open. The warp coil is there - but the noise echoes through the hangar.",
            "next_stage": "retrieve_coil",
            "effects": ["noise_made"]
          }
        },
        {
          "choice_id": "pick_lock",
          "text": "Pick the lock quietly",
          "requirements": {
            "skill": "engineering",
            "skill_level": 2
          },
          "consequences": {
            "success": {
              "text": "Click. The lock opens smoothly. Inside, the warp coil gleams, perfectly preserved.",
              "next_stage": "retrieve_coil",
              "xp_bonus": 15
            },
            "failure": {
              "text": "The lock snaps. You're in, but the sound echoes.",
              "next_stage": "retrieve_coil",
              "effects": ["noise_made"]
            }
          }
        }
      ]
    },
    {
      "stage_id": "retrieve_coil",
      "title": "The Warp Coil",
      "description": "The warp coil is magnificent - clearly high-quality. But you notice something else: a personal log datapad belonging to one of the last engineers here.",
      "image": "warp_coil",
      "choices": [
        {
          "choice_id": "take_both",
          "text": "Take the warp coil and the datapad",
          "requirements": {},
          "consequences": {
            "text": "You secure both items. The datapad might contain valuable information.",
            "next_stage": "escape",
            "effects": ["got_datapad"]
          }
        },
        {
          "choice_id": "just_coil",
          "text": "Just take the warp coil",
          "requirements": {},
          "consequences": {
            "text": "You grab the coil. Time to leave.",
            "next_stage": "escape"
          }
        }
      ]
    },
    {
      "stage_id": "escape",
      "title": "Time to Go",
      "description": "Mission accomplished. You head for the exit.",
      "conditional_text": {
        "if_noise_made": "But as you leave the office, you hear the whir of drone rotors. They heard you.",
        "if_drones_disabled": "The drones remain inactive as you walk out. A clean operation.",
        "default": "The coast is clear. You slip out unnoticed."
      },
      "choices": [
        {
          "choice_id": "leave",
          "text": "Head back to your workshop",
          "requirements": {},
          "consequences": {
            "text": "You make it back safely. Time to install this beauty.",
            "complete": true
          }
        }
      ]
    }
  ],
  "rewards": {
    "xp": 150,
    "items": ["warp_coil_uncommon"],
    "conditional_rewards": {
      "if_got_datapad": {
        "effects": ["unlock_story_clue"],
        "xp_bonus": 50
      },
      "if_drones_disabled": {
        "reputation": 10,
        "xp_bonus": 25
      }
    }
  }
}
```

---

## AI Generation Integration

### Mission Generation Prompt

```python
# See ai-integration.md for full prompt templates

MISSION_PROMPT = """
Generate a mission for a space adventure game.

Game Context:
- Player Level: {player_level}
- Installed Systems: {systems}
- Location: Earth, post-exodus
- Tone: Serious sci-fi (Star Trek TNG)
- Completed Missions: {completed_missions}

Required Reward: {reward_type} (ship part)

Generate a mission with:
1. Title (evocative, mysterious)
2. Type: salvage, exploration, trade, or rescue
3. Description (2-3 sentences)
4. 2-3 stages with meaningful choices
5. Outcomes that reflect player's skills/systems
6. Appropriate difficulty rating

The mission should feel unique but fit the established world.
Format as JSON following the mission template.
"""
```

### Quality Control

**AI-Generated Missions:**
1. Always reviewed by mission validator
2. Must fit JSON schema
3. Rewards balanced automatically
4. Player can "reroll" if unsatisfying (max 3x per session)

---

**Document Status:** Complete v1.0
**Last Updated:** November 5, 2025
