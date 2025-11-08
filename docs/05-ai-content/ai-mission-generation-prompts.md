# Space Adventures - AI Mission Generation Prompts

**Version:** 1.0
**Date:** November 7, 2025
**Purpose:** Complete prompt templates for AI-generated missions with reward balancing

---

## Table of Contents
1. [Base Mission Generation Prompt](#base-mission-generation-prompt)
2. [Reward Generation Rules](#reward-generation-rules)
3. [Mission Type Specific Prompts](#mission-type-specific-prompts)
4. [Quality Control Prompts](#quality-control-prompts)
5. [Examples](#examples)
6. [Integration with Python AI Service](#integration-with-python-ai-service)

---

## Base Mission Generation Prompt

### Complete Mission Generation Template

```python
BASE_MISSION_GENERATION_PROMPT = """
You are a creative writer for a serious science fiction space adventure game
inspired by Star Trek: The Next Generation. Generate a mission that is:
- Thoughtful and meaningful
- Tonally consistent (serious sci-fi, not comedic)
- Features ethical choices with consequences
- Fits within an established post-exodus Earth setting (2247 AD)

GAME STATE CONTEXT:
Player Level: {player_level}
Player Skills:
  - Engineering: {eng}/10
  - Diplomacy: {dip}/10
  - Combat: {com}/10
  - Science: {sci}/10

Ship Systems Installed: {ship_systems_summary}
Ship Systems at Level 1+: {systems_level_1_plus}
Completed Missions: {completed_count} missions
Recent Mission Titles: {recent_mission_titles}

Current Location: Earth (Phase 1 - Earthbound)
Mission Context: Player is scavenging Earth for ship parts to build a functional starship

MISSION REQUIREMENTS:
Type: {mission_type}
Required Reward: {required_reward_system} component (for ship upgrade)
Target Difficulty: {target_difficulty}/5 stars
Length: 3-4 stages with meaningful choices

REWARD GENERATION RULES (CRITICAL):
Base XP: {base_xp} (50 + difficulty × 50)
Base Credits: {base_credits} (100 + difficulty × 200)
Part Quantity: {part_quantity}
Part Rarity Distribution: {rarity_distribution}
Guaranteed Part: {required_reward_system}_{reward_rarity}

Bonus XP Rules:
- Skill check success: +25 XP
- Creative solution: +50 XP
- Perfect mission (no failures): +100 XP
- Optional objective completed: +30 XP

PART RARITY BY DIFFICULTY:
Difficulty 1-2 (Easy):
  - 70% Common
  - 25% Uncommon
  - 5% Rare

Difficulty 3 (Medium):
  - 40% Common
  - 40% Uncommon
  - 15% Rare
  - 5% Epic

Difficulty 4-5 (Hard):
  - 20% Common
  - 35% Uncommon
  - 30% Rare
  - 12% Epic
  - 3% Legendary

MISSION STRUCTURE REQUIREMENTS:

{{
  "mission_id": "generated_{timestamp}_{mission_type}",
  "title": "Evocative 3-6 word title (mysterious, not generic)",
  "type": "{mission_type}",
  "location": "Specific abandoned Earth location (city, facility, or region)",
  "description": "2-3 sentence briefing. Set up the situation and stakes.",
  "difficulty": {target_difficulty},

  "requirements": {{
    "min_level": {max(1, player_level - 1)},
    "required_systems": [],
    "completed_missions": []
  }},

  "objectives": [
    "Primary: Retrieve {required_reward_system} component",
    "Optional: [Secondary objective that adds depth]"
  ],

  "stages": [
    {{
      "stage_id": "stage_1",
      "title": "Descriptive stage title",
      "description": "Vivid 3-5 sentence description. Paint the scene with sensory details.",
      "choices": [
        {{
          "choice_id": "choice_1a",
          "text": "Player action (first-person perspective)",
          "requirements": {{
            "skill": "engineering",
            "skill_level": {max(eng - 1, 1)}
          }},
          "success_chance": "skill_based",
          "consequences": {{
            "success": {{
              "text": "Success outcome (2-3 sentences showing consequence)",
              "next_stage": "stage_2",
              "effects": ["effect_name"],
              "xp_bonus": 25
            }},
            "failure": {{
              "text": "Failure outcome (not game over, but setback)",
              "next_stage": "stage_2_alternate",
              "effects": ["different_effect"]
            }}
          }}
        }},
        {{
          "choice_id": "choice_1b",
          "text": "Alternative approach (no skill requirement)",
          "requirements": {{}},
          "consequences": {{
            "text": "Direct outcome (2-3 sentences)",
            "next_stage": "stage_2"
          }}
        }}
      ]
    }},
    // 2-3 more stages following same structure
    {{
      "stage_id": "final_stage",
      "title": "Resolution",
      "description": "Final situation description",
      "choices": [
        {{
          "choice_id": "complete",
          "text": "Complete the mission",
          "consequences": {{
            "text": "Mission success description",
            "complete": true
          }}
        }}
      ]
    }}
  ],

  "rewards": {{
    "xp": {base_xp},
    "credits": {base_credits},
    "items": [
      "{required_reward_system}_{reward_rarity}"
    ],
    "conditional_rewards": {{
      "if_optional_objective_complete": {{
        "xp_bonus": 30,
        "items": ["random_common_part"]
      }},
      "if_perfect_run": {{
        "xp_bonus": 100,
        "items": ["bonus_uncommon_part"]
      }}
    }}
  }},

  "failure_consequences": {{
    "xp": {base_xp // 4},
    "effects": ["mission_failed"]
  }}
}}

CONSTRAINTS:
- Must be completable with player's current skills/systems
- At least 2 choices per stage (more is better)
- At least one choice requires skills/systems
- At least one "safe" choice with no requirements
- Stage IDs must match next_stage references
- All next_stage IDs must exist in stages array
- No space travel (player is Earthbound)
- Tone: Serious, thoughtful, consequences matter
- No jokes, memes, or comedic tone
- Show don't tell - vivid descriptions

VALIDATION CHECKLIST:
✓ All stage IDs are unique
✓ All next_stage references point to valid stage_id
✓ At least one choice has skill requirements
✓ Rewards include required {required_reward_system} part
✓ XP matches formula: {base_xp}
✓ Part rarity matches difficulty: {reward_rarity}
✓ All part_ids follow pattern: system_rarity (e.g., "warp_uncommon")

Generate the complete mission JSON now. Ensure all stage references are correct.
"""
```

### Context Preparation Function

```python
def prepare_mission_context(game_state: GameState, difficulty: str, reward_type: str) -> dict:
    """Prepare all context variables for mission generation"""

    # Calculate difficulty number
    difficulty_map = {
        "easy": 1,
        "medium": 3,
        "hard": 5
    }
    difficulty_num = difficulty_map.get(difficulty, 3)

    # Calculate rewards
    base_xp = 50 + (difficulty_num * 50)
    base_credits = 100 + (difficulty_num * 200)

    # Part quantity by difficulty
    part_quantity_map = {
        1: "1-2 parts",
        2: "1-2 parts",
        3: "2-3 parts",
        4: "3-4 parts",
        5: "3-5 parts"
    }

    # Rarity by difficulty
    rarity_map = {
        1: "common",
        2: "common",
        3: "uncommon",
        4: "rare",
        5: "rare"
    }

    # Rarity distribution strings
    rarity_dist_map = {
        1: "70% Common, 25% Uncommon, 5% Rare",
        2: "70% Common, 25% Uncommon, 5% Rare",
        3: "40% Common, 40% Uncommon, 15% Rare, 5% Epic",
        4: "20% Common, 35% Uncommon, 30% Rare, 12% Epic, 3% Legendary",
        5: "20% Common, 35% Uncommon, 30% Rare, 12% Epic, 3% Legendary"
    }

    return {
        "player_level": game_state.player.level,
        "eng": game_state.player.skills.get("engineering", 0),
        "dip": game_state.player.skills.get("diplomacy", 0),
        "com": game_state.player.skills.get("combat", 0),
        "sci": game_state.player.skills.get("science", 0),
        "ship_systems_summary": format_systems_summary(game_state.ship),
        "systems_level_1_plus": get_systems_at_level_1_plus(game_state.ship),
        "completed_count": len(game_state.progress.completed_missions),
        "recent_mission_titles": get_recent_titles(game_state, 3),
        "mission_type": determine_mission_type(reward_type),
        "required_reward_system": reward_type,
        "target_difficulty": difficulty_num,
        "base_xp": base_xp,
        "base_credits": base_credits,
        "part_quantity": part_quantity_map[difficulty_num],
        "reward_rarity": rarity_map[difficulty_num],
        "rarity_distribution": rarity_dist_map[difficulty_num],
        "timestamp": int(time.time())
    }
```

---

## Reward Generation Rules

### XP Calculation Formula

```python
# Base XP by difficulty
def calculate_base_xp(difficulty: int) -> int:
    """
    Difficulty 1-5
    Formula: 50 + (difficulty * 50)
    """
    return 50 + (difficulty * 50)

# Examples:
# Difficulty 1 (Easy): 100 XP
# Difficulty 2: 150 XP
# Difficulty 3 (Medium): 200 XP
# Difficulty 4: 250 XP
# Difficulty 5 (Hard): 300 XP

# Bonus XP rules
BONUS_XP = {
    "skill_check_success": 25,
    "creative_solution": 50,
    "optional_objective": 30,
    "perfect_run": 100,  # No failures throughout mission
    "exceptional_choice": 75  # Particularly clever or moral choice
}
```

### Credits Calculation Formula

```python
def calculate_base_credits(difficulty: int) -> int:
    """
    Formula: 100 + (difficulty * 200)
    """
    return 100 + (difficulty * 200)

# Examples:
# Difficulty 1: 300 credits
# Difficulty 2: 500 credits
# Difficulty 3: 700 credits
# Difficulty 4: 900 credits
# Difficulty 5: 1,100 credits
```

### Parts Quantity and Rarity

```python
PARTS_BY_DIFFICULTY = {
    1: {
        "quantity": (1, 2),  # Min-max range
        "rarities": {
            "common": 0.70,
            "uncommon": 0.25,
            "rare": 0.05
        }
    },
    2: {
        "quantity": (1, 2),
        "rarities": {
            "common": 0.70,
            "uncommon": 0.25,
            "rare": 0.05
        }
    },
    3: {
        "quantity": (2, 3),
        "rarities": {
            "common": 0.40,
            "uncommon": 0.40,
            "rare": 0.15,
            "epic": 0.05
        }
    },
    4: {
        "quantity": (3, 4),
        "rarities": {
            "common": 0.20,
            "uncommon": 0.35,
            "rare": 0.30,
            "epic": 0.12,
            "legendary": 0.03
        }
    },
    5: {
        "quantity": (3, 5),
        "rarities": {
            "common": 0.20,
            "uncommon": 0.35,
            "rare": 0.30,
            "epic": 0.12,
            "legendary": 0.03
        }
    }
}

def generate_mission_parts(difficulty: int, guaranteed_system: str) -> list:
    """Generate part rewards for mission"""
    config = PARTS_BY_DIFFICULTY[difficulty]
    quantity = random.randint(*config["quantity"])

    # Guaranteed part for required system
    guaranteed_rarity = weighted_random(config["rarities"])
    parts = [f"{guaranteed_system}_{guaranteed_rarity}"]

    # Additional random parts
    for _ in range(quantity - 1):
        random_system = random.choice(SHIP_SYSTEMS)
        random_rarity = weighted_random(config["rarities"])
        parts.append(f"{random_system}_{random_rarity}")

    return parts

SHIP_SYSTEMS = [
    "hull", "power", "propulsion", "warp", "life_support",
    "computer", "sensors", "shields", "weapons", "communications"
]
```

### Part ID Validation

```python
def validate_part_id(part_id: str) -> bool:
    """
    Valid format: {system}_{rarity}
    Examples: "warp_uncommon", "hull_rare", "shields_epic"
    """
    try:
        system, rarity = part_id.split("_")

        valid_systems = [
            "hull", "power", "propulsion", "warp", "life_support",
            "computer", "sensors", "shields", "weapons", "communications"
        ]

        valid_rarities = ["common", "uncommon", "rare", "epic", "legendary"]

        return system in valid_systems and rarity in valid_rarities
    except ValueError:
        return False
```

---

## Mission Type Specific Prompts

### Salvage Mission Prompt

```python
SALVAGE_MISSION_PROMPT = """
{base_prompt}

MISSION TYPE: SALVAGE

Salvage missions focus on retrieving specific ship components from abandoned locations.

SALVAGE-SPECIFIC REQUIREMENTS:
- Location: Abandoned Earth facility (spaceport, military base, research station, etc.)
- Primary Objective: Retrieve specific {required_reward_system} component
- Secondary Objective: Optional salvage of additional materials
- Challenges: Environmental hazards, security systems, competing scavengers
- Reward: Guaranteed {required_reward_system} part

SALVAGE MISSION STRUCTURE:
Stage 1: Approach and Entry
  - How does player enter the location?
  - Choices: Stealth, technical bypass, direct entry

Stage 2: Navigation and Obstacles
  - Environmental hazards or security systems
  - Choices: Engineering solutions, careful navigation, risk/reward paths

Stage 3: Retrieval
  - Finding and securing the component
  - Choices: Quick grab vs thorough search, ethical dilemmas (other scavengers?)

Stage 4: Escape (optional complication)
  - Getting out safely
  - Consequences of previous choices manifest here

TONE: Exploration and problem-solving. Tense but not combat-focused.

EXAMPLE LOCATIONS:
- Kennedy Spaceport ruins
- Abandoned military base
- Corporate research facility
- Underground bunker
- Crashed orbital station
- Derelict shipyard

Generate salvage mission following this structure.
"""
```

### Exploration Mission Prompt

```python
EXPLORATION_MISSION_PROMPT = """
{base_prompt}

MISSION TYPE: EXPLORATION

Exploration missions focus on investigating unknown or mysterious locations.

EXPLORATION-SPECIFIC REQUIREMENTS:
- Location: Mysterious or uncharted Earth location
- Primary Objective: Investigate and discover what happened
- Secondary Objective: Document findings, recover data
- Challenges: Unknown hazards, mysteries to solve, moral choices
- Rewards: Discovery XP bonus, rare data, possible {required_reward_system} part

EXPLORATION MISSION STRUCTURE:
Stage 1: Arrival and First Impressions
  - What seems strange or interesting?
  - Choices: Cautious approach vs immediate investigation

Stage 2: Investigation
  - Uncovering clues and piecing together the story
  - Choices: Thorough search, quick scan, risk deeper exploration

Stage 3: Discovery
  - Major revelation or finding
  - Choices: What to do with knowledge/technology found

Stage 4: Consequences
  - How does the discovery affect the world or player?
  - Ethical choice: Keep secret, share, destroy, preserve?

TONE: Wonder and mystery. Science-focused. Moral implications.

THEMES:
- Lost technology
- Pre-exodus secrets
- Scientific experiments gone wrong
- Environmental mysteries
- Historical discoveries

Generate exploration mission with meaningful discovery.
"""
```

### Trade Mission Prompt

```python
TRADE_MISSION_PROMPT = """
{base_prompt}

MISSION TYPE: TRADE

Trade missions focus on negotiation, deal-making, and resource exchange.

TRADE-SPECIFIC REQUIREMENTS:
- Location: Settlement, trading post, or NPC encounter
- Primary Objective: Acquire {required_reward_system} component through trade
- Secondary Objective: Build relationship with trader
- Challenges: Negotiation, trust, limited resources
- Rewards: Traded parts (uses player resources), reputation gain

TRADE MISSION STRUCTURE:
Stage 1: Meeting the Trader
  - Establish character and their situation
  - Choices: Approach (friendly, business-like, assertive)

Stage 2: The Negotiation
  - What does the trader want?
  - Choices: Trade resources, complete favor, convince/persuade

Stage 3: Complications
  - Something complicates the deal
  - Choices: How to resolve the complication

Stage 4: Resolution
  - Complete the trade or find alternative
  - Long-term relationship implications

TONE: Character-driven. Diplomacy and persuasion. Relationship building.

NPC ARCHETYPES:
- Rival scavenger
- Desperate settler
- Shrewd merchant
- Reluctant ally
- Mysterious stranger

Generate trade mission with memorable NPC and meaningful negotiation.
"""
```

### Rescue Mission Prompt

```python
RESCUE_MISSION_PROMPT = """
{base_prompt}

MISSION TYPE: RESCUE

Rescue missions focus on helping others in danger or need.

RESCUE-SPECIFIC REQUIREMENTS:
- Location: Various (disaster site, trapped location, hostile area)
- Primary Objective: Save people in danger
- Secondary Objective: Recover {required_reward_system} component as gratitude reward
- Challenges: Time pressure, moral choices, resource limitations
- Rewards: Reputation, karma, gratitude rewards

RESCUE MISSION STRUCTURE:
Stage 1: Distress Call
  - Someone needs help
  - Choices: Respond immediately, prepare first, investigate before committing

Stage 2: The Rescue
  - Saving people from danger
  - Choices: Risk/reward balance, who to save first (if limited)

Stage 3: Moral Dilemma
  - Complication that creates ethical choice
  - Example: Save everyone but lose objective vs secure objective then rescue

Stage 4: Aftermath
  - Consequences of choices
  - Gratitude rewards or guilt

TONE: Emotional and moral. Time pressure. Character-driven.

ETHICAL DILEMMAS:
- Save everyone vs accomplish mission
- Risk your safety vs play it safe
- Help stranger vs someone you know
- Short-term gain vs long-term good

Generate rescue mission with meaningful moral choice.
"""
```

### Combat Mission Prompt

```python
COMBAT_MISSION_PROMPT = """
{base_prompt}

MISSION TYPE: COMBAT

Combat missions focus on conflict, whether through fighting or clever alternatives.

COMBAT-SPECIFIC REQUIREMENTS:
- Location: Hostile territory or contested area
- Primary Objective: Defeat/overcome hostile forces to get {required_reward_system}
- Secondary Objective: Minimize casualties, find peaceful solution
- Challenges: Combat encounters, tactical decisions
- Rewards: Military-grade parts, combat XP

COMBAT MISSION STRUCTURE:
Stage 1: Threat Assessment
  - Identify the hostile force
  - Choices: Scout first, negotiate, prepare ambush, direct assault

Stage 2: The Confrontation
  - Main conflict encounter
  - Choices: Fight, flee, outsmart, negotiate (if possible)

Stage 3: Tactical Decision
  - Mid-combat choice or crisis
  - Choices: Escalate, de-escalate, tactical retreat, unconventional solution

Stage 4: Resolution
  - Aftermath of confrontation
  - Consequences based on approach (moral weight if violence used)

TONE: Tense and tactical. Combat as last resort, not glorified.

ALTERNATIVE SOLUTIONS:
- Always offer non-combat path if player has right skills/systems
- Diplomacy (Communications + Diplomacy skill)
- Stealth (Sensors system)
- Technical solution (Engineering skill)
- Outsmart them (Science or Computer system)

Generate combat mission with meaningful alternatives to violence.
"""
```

### Story Mission Prompt

```python
STORY_MISSION_PROMPT = """
{base_prompt}

MISSION TYPE: STORY

Story missions advance the main narrative with fixed beats and branching choices.

STORY-SPECIFIC REQUIREMENTS:
- Location: Significant story location
- Primary Objective: Narrative progression
- Secondary Objective: Character development
- Challenges: Emotional choices, revelations, character moments
- Rewards: Major story items, character development, unlock new areas

STORY MISSION STRUCTURE:
Stage 1: Setup
  - Establish the situation and stakes
  - Character-driven moment

Stage 2: Development
  - Reveal information or create tension
  - Player choices influence how story unfolds

Stage 3: Climax
  - Major decision or revelation
  - Meaningful choice with lasting consequences

Stage 4: Resolution
  - Immediate consequences
  - Set up future story threads

TONE: Character-driven and emotionally resonant. Star Trek TNG inspiration.

NARRATIVE THEMES:
- Discovery of parent's plans/legacy
- Ethical dilemmas with no right answer
- Wonder of discovery
- Cost of ambition
- Hope vs pragmatism
- Connection vs isolation

Generate story mission that feels like a Star Trek TNG episode.
"""
```

---

## Quality Control Prompts

### Mission Validation Prompt

```python
VALIDATION_PROMPT = """
Review this AI-generated mission for quality and correctness.

MISSION JSON:
{mission_json}

VALIDATION CHECKLIST:

1. STRUCTURE VALIDATION:
   ✓ All required fields present?
   ✓ All stage_ids are unique?
   ✓ All next_stage references point to valid stage_ids?
   ✓ At least 2-4 stages?
   ✓ At least 2 choices per stage?

2. REWARD VALIDATION:
   ✓ Base XP = 50 + (difficulty × 50)?
   ✓ Credits = 100 + (difficulty × 200)?
   ✓ Guaranteed part included: {required_system}_{rarity}?
   ✓ Part IDs follow format: system_rarity?
   ✓ Part quantity matches difficulty?
   ✓ Rarity distribution matches difficulty?

3. GAMEPLAY VALIDATION:
   ✓ At least one choice requires skills/systems?
   ✓ At least one "safe" choice per stage?
   ✓ Completable with player's current abilities?
   ✓ Choices are meaningful (not obvious "best" choice)?
   ✓ Consequences make sense?

4. TONE VALIDATION:
   ✓ Serious sci-fi tone (not comedic)?
   ✓ Fits Star Trek TNG inspiration?
   ✓ No jokes, memes, or modern slang?
   ✓ Descriptions are vivid and immersive?
   ✓ Consequences have weight?

5. NARRATIVE VALIDATION:
   ✓ Makes sense in post-exodus Earth setting?
   ✓ Location is specific and interesting?
   ✓ Story is coherent and complete?
   ✓ Characters (if any) have personality?

OUTPUT FORMAT:
{{
  "valid": true/false,
  "issues": [
    "List of problems found (empty if valid)"
  ],
  "recommendations": [
    "Suggestions for improvement"
  ],
  "corrected_mission": {{
    // If fixable issues, provide corrected JSON
  }}
}}

Validate the mission now.
"""
```

### Reward Balance Check Prompt

```python
REWARD_BALANCE_PROMPT = """
Check if mission rewards are properly balanced.

MISSION: {mission_title}
DIFFICULTY: {difficulty}/5
PLAYER LEVEL: {player_level}

CURRENT REWARDS:
XP: {mission_xp}
Credits: {mission_credits}
Parts: {mission_parts}
Bonus XP Opportunities: {bonus_xp_total}

VALIDATION:

1. Base XP Check:
   Expected: {50 + (difficulty × 50)}
   Actual: {mission_xp}
   ✓ Match? {match_status}

2. Credits Check:
   Expected: {100 + (difficulty × 200)}
   Actual: {mission_credits}
   ✓ Match? {match_status}

3. Parts Check:
   Expected Quantity: {expected_quantity}
   Actual Quantity: {len(mission_parts)}
   ✓ Match? {match_status}

   Guaranteed Part: {required_system}_{expected_rarity}
   ✓ Included? {included_status}

4. Rarity Check:
   Expected Rarity: {expected_rarity}
   Actual Rarity: {actual_rarity}
   ✓ Match? {match_status}

5. Part ID Validation:
   All part IDs follow system_rarity format?
   All systems are valid?
   All rarities are valid?

6. Balance Assessment:
   Is mission rewarding for difficulty?
   Are bonus XP opportunities fair?
   Do rewards match time investment?

OUTPUT:
{{
  "balanced": true/false,
  "corrections_needed": [
    {{
      "field": "xp",
      "current": 100,
      "should_be": 200,
      "reason": "Formula requires 50 + (difficulty × 50)"
    }}
  ],
  "corrected_rewards": {{
    // Corrected reward object
  }}
}}

Validate rewards now.
"""
```

### Part Registry Validation

```python
def validate_against_part_registry(part_ids: list) -> dict:
    """
    Validate that all part IDs exist in PartRegistry
    """
    VALID_SYSTEMS = [
        "hull", "power", "propulsion", "warp", "life_support",
        "computer", "sensors", "shields", "weapons", "communications"
    ]

    VALID_RARITIES = [
        "common", "uncommon", "rare", "epic", "legendary"
    ]

    invalid_parts = []

    for part_id in part_ids:
        try:
            system, rarity = part_id.split("_")
            if system not in VALID_SYSTEMS:
                invalid_parts.append({
                    "part_id": part_id,
                    "issue": f"Invalid system: {system}",
                    "valid_systems": VALID_SYSTEMS
                })
            if rarity not in VALID_RARITIES:
                invalid_parts.append({
                    "part_id": part_id,
                    "issue": f"Invalid rarity: {rarity}",
                    "valid_rarities": VALID_RARITIES
                })
        except ValueError:
            invalid_parts.append({
                "part_id": part_id,
                "issue": "Invalid format (should be system_rarity)",
                "example": "warp_uncommon"
            })

    return {
        "valid": len(invalid_parts) == 0,
        "invalid_parts": invalid_parts
    }
```

---

## Examples

### Example 1: Complete AI-Generated Mission (Difficulty 3)

**Input Context:**
```python
{
    "player_level": 3,
    "eng": 5,
    "dip": 3,
    "com": 2,
    "sci": 4,
    "ship_systems": ["hull", "power", "propulsion"],
    "completed_count": 5,
    "mission_type": "salvage",
    "required_reward_system": "warp",
    "difficulty": 3,
    "base_xp": 200,
    "base_credits": 700,
    "reward_rarity": "uncommon"
}
```

**AI Generated Mission:**
```json
{
  "mission_id": "generated_1699564321_salvage",
  "title": "Echoes in the Void",
  "type": "salvage",
  "location": "Nevada Deep Space Tracking Station",
  "description": "The Nevada Deep Space Tracking Station was humanity's eye on the cosmos before the exodus. Your sensors indicate a functional warp coil in the primary communications array - but the facility's fusion reactor is unstable. Time is limited.",
  "difficulty": 3,

  "requirements": {
    "min_level": 2,
    "required_systems": [],
    "completed_missions": []
  },

  "objectives": [
    "Primary: Retrieve warp coil from communications array",
    "Optional: Stabilize fusion reactor to save facility data archives"
  ],

  "stages": [
    {
      "stage_id": "approach",
      "title": "Approaching the Station",
      "description": "The tracking station's massive satellite dishes loom against the twilight sky, frozen in their last positions. Warning lights blink erratically throughout the compound. Your radiation detector chirps - the fusion reactor is leaking. You estimate 90 minutes before critical failure. The warp coil is in the main communications building, three hundred meters from the reactor.",
      "choices": [
        {
          "choice_id": "scan_first",
          "text": "Use my scanners to map safe routes and radiation levels",
          "requirements": {
            "system": "sensors",
            "level": 1
          },
          "consequences": {
            "text": "Your sensors paint a clear picture. Three paths: a direct route through moderate radiation, a longer path around the hot zone, and maintenance tunnels beneath the facility. The tunnels show structural damage.",
            "next_stage": "navigation_informed",
            "effects": ["has_scan_data"]
          }
        },
        {
          "choice_id": "engineering_assessment",
          "text": "Assess the reactor from here - maybe I can stabilize it remotely",
          "requirements": {
            "skill": "engineering",
            "skill_level": 4
          },
          "success_chance": "skill_based",
          "consequences": {
            "success": {
              "text": "The control systems are still responsive. You reroute coolant and reduce pressure. The reactor stabilizes - for now. You've bought yourself 3 hours. The radiation levels drop significantly.",
              "next_stage": "navigation_safe",
              "effects": ["reactor_stabilized"],
              "xp_bonus": 25
            },
            "failure": {
              "text": "Your remote commands trigger a safety lockout. The reactor's automated systems interpret your intrusion as sabotage. Time accelerates - you now have 45 minutes.",
              "next_stage": "navigation_urgent",
              "effects": ["time_pressure"]
            }
          }
        },
        {
          "choice_id": "direct_approach",
          "text": "No time for caution - head straight for the communications building",
          "requirements": {},
          "consequences": {
            "text": "You move quickly through the compound. Radiation levels rise as you approach. Your dosimeter beeps urgently. You'll make it, but you're cutting it close.",
            "next_stage": "navigation_urgent",
            "effects": ["radiation_exposure"]
          }
        }
      ]
    },

    {
      "stage_id": "navigation_informed",
      "title": "The Informed Choice",
      "description": "With scan data in hand, you can choose your path carefully. The direct route is fastest but hazardous. The long route is safe but time-consuming. The tunnels are a gamble - quick if they hold, deadly if they collapse.",
      "choices": [
        {
          "choice_id": "take_direct",
          "text": "Take the direct route - I can handle the radiation",
          "requirements": {},
          "consequences": {
            "text": "You push through the radiation zone. Your suit's protection holds. Uncomfortable, but you make it to the communications building with time to spare.",
            "next_stage": "communications_array"
          }
        },
        {
          "choice_id": "take_safe",
          "text": "Take the long route - safety first",
          "requirements": {},
          "consequences": {
            "text": "The longer path takes you through abandoned offices and living quarters. Ghostly reminders of the people who worked here. You arrive at the communications building safely, though time is tighter.",
            "next_stage": "communications_array",
            "effects": ["saw_personal_items"]
          }
        },
        {
          "choice_id": "try_tunnels",
          "text": "Risk the maintenance tunnels",
          "requirements": {
            "skill": "engineering",
            "skill_level": 3
          },
          "success_chance": "skill_based",
          "consequences": {
            "success": {
              "text": "You reinforce weak sections as you go. The tunnels hold. You emerge directly beneath the communications building - perfect position.",
              "next_stage": "communications_array",
              "effects": ["tunnel_success"],
              "xp_bonus": 25
            },
            "failure": {
              "text": "A section collapses behind you. You make it through, but you're shaken and covered in dust. The exit is blocked - you'll need to find another way out.",
              "next_stage": "communications_array",
              "effects": ["tunnel_collapsed"]
            }
          }
        }
      ]
    },

    {
      "stage_id": "navigation_safe",
      "title": "Safe Passage",
      "description": "With the reactor stabilized, you can move through the facility safely. The communications building stands ahead, its array of equipment still humming with residual power.",
      "choices": [
        {
          "choice_id": "proceed",
          "text": "Enter the communications building",
          "requirements": {},
          "consequences": {
            "text": "You enter the main array chamber. Decades of dust coat the equipment, but it's remarkably preserved. The warp coil is mounted in the primary transmitter assembly.",
            "next_stage": "communications_array",
            "effects": ["calm_approach"]
          }
        }
      ]
    },

    {
      "stage_id": "navigation_urgent",
      "title": "Racing Against Time",
      "description": "The reactor's warning sirens wail in the distance. Every minute counts. You sprint toward the communications building, radiation warnings beeping steadily on your detector.",
      "choices": [
        {
          "choice_id": "rush_in",
          "text": "Rush inside - no time to waste",
          "requirements": {},
          "consequences": {
            "text": "You burst through the doors. The warp coil is visible in the main array. But in your haste, you've triggered the facility's intrusion countermeasures.",
            "next_stage": "communications_array",
            "effects": ["triggered_security", "time_critical"]
          }
        }
      ]
    },

    {
      "stage_id": "communications_array",
      "title": "The Warp Coil",
      "description": "The warp coil gleams in its mounting - a beautiful piece of engineering. But it's integrated into the transmitter array. Removing it will destroy the station's ability to communicate, even if the reactor is saved. Next to the array, you see a data terminal still powered, displaying decades of deep space telemetry data.",
      "choices": [
        {
          "choice_id": "take_coil_and_data",
          "text": "Extract the warp coil carefully and download the data archives",
          "requirements": {
            "skill": "engineering",
            "skill_level": 5
          },
          "success_chance": "skill_based",
          "consequences": {
            "success": {
              "text": "Your hands move with precision. You bypass the safety interlocks, download the archives to a portable drive, and extract the warp coil without damaging either system. A masterful salvage operation.",
              "next_stage": "optional_reactor",
              "effects": ["perfect_extraction", "has_data"],
              "xp_bonus": 50
            },
            "failure": {
              "text": "The data transfer corrupts midway. You have to choose - finish the download or secure the warp coil before something goes wrong.",
              "next_stage": "forced_choice",
              "effects": ["partial_data"]
            }
          }
        },
        {
          "choice_id": "take_coil_quick",
          "text": "Extract the warp coil quickly - forget the data",
          "requirements": {},
          "consequences": {
            "text": "You disconnect the warp coil's mounting brackets and power feeds. It comes free cleanly. The transmitter array goes dark. Whatever secrets those data archives held are lost.",
            "next_stage": "optional_reactor",
            "effects": ["coil_secured"]
          }
        }
      ]
    },

    {
      "stage_id": "forced_choice",
      "title": "Data or Hardware",
      "description": "The corruption spreads through the system. You can save the data OR extract the warp coil safely, but not both. What matters more - knowledge of the past or capability for the future?",
      "choices": [
        {
          "choice_id": "choose_data",
          "text": "Prioritize the data - this could be humanity's history",
          "requirements": {},
          "consequences": {
            "text": "You complete the download. The archives contain observations of distant star systems - potential destinations. But extracting the warp coil is now rushed and damages the transmitter.",
            "next_stage": "optional_reactor",
            "effects": ["has_data", "coil_secured"]
          }
        },
        {
          "choice_id": "choose_coil",
          "text": "Secure the warp coil - I need this to leave Earth",
          "requirements": {},
          "consequences": {
            "text": "The warp coil is your priority. You abort the download and extract the component perfectly. The data is lost to corruption.",
            "next_stage": "optional_reactor",
            "effects": ["coil_secured", "data_lost"]
          }
        }
      ]
    },

    {
      "stage_id": "optional_reactor",
      "title": "The Reactor Decision",
      "description": "You have the warp coil. But you could attempt to permanently stabilize the reactor, saving this facility's archives and equipment for future scavengers. It would take time and skill. Or you could leave now - you've accomplished your mission.",
      "choices": [
        {
          "choice_id": "stabilize_reactor",
          "text": "Attempt to stabilize the reactor permanently",
          "requirements": {
            "skill": "engineering",
            "skill_level": 4
          },
          "success_chance": "skill_based",
          "consequences": {
            "success": {
              "text": "Working carefully, you repair the coolant system and reset the safeties. The reactor's warning lights turn green. This facility will stand for years to come - a gift to future scavengers.",
              "next_stage": "conclusion",
              "effects": ["reactor_saved", "optional_complete"],
              "xp_bonus": 30
            },
            "failure": {
              "text": "Your repairs don't hold. The reactor will fail within hours. You barely escape as warning klaxons begin their final countdown.",
              "next_stage": "conclusion",
              "effects": ["reactor_failed"]
            }
          }
        },
        {
          "choice_id": "leave_now",
          "text": "Leave with the warp coil - I've done enough",
          "requirements": {},
          "consequences": {
            "text": "You make your way out of the facility. Behind you, the station's lights flicker and die as the reactor fails. But you have what you came for.",
            "next_stage": "conclusion",
            "effects": ["mission_complete"]
          }
        }
      ]
    },

    {
      "stage_id": "conclusion",
      "title": "Return to Workshop",
      "description": "You return to your workshop with the warp coil secured. One step closer to reaching the stars.",
      "choices": [
        {
          "choice_id": "complete",
          "text": "Head back to workshop",
          "requirements": {},
          "consequences": {
            "text": "Mission complete. The warp coil will serve you well.",
            "complete": true
          }
        }
      ]
    }
  ],

  "rewards": {
    "xp": 200,
    "credits": 700,
    "items": [
      "warp_uncommon",
      "power_common"
    ],
    "conditional_rewards": {
      "if_has_data": {
        "xp_bonus": 30,
        "items": ["star_chart_data"],
        "effects": ["unlocked_future_location"]
      },
      "if_optional_complete": {
        "xp_bonus": 30,
        "reputation": 10
      },
      "if_perfect_extraction": {
        "xp_bonus": 50,
        "items": ["warp_rare"]
      }
    }
  },

  "failure_consequences": {
    "xp": 50,
    "effects": ["mission_failed"]
  }
}
```

### Example 2: Before/After Reward Balancing

**Before (AI Generated - Incorrect):**
```json
{
  "rewards": {
    "xp": 350,
    "credits": 1000,
    "items": [
      "warp_legendary",
      "shields_epic",
      "power_rare"
    ]
  }
}
```

**Issues Detected:**
- XP too high for difficulty 3 (should be 200)
- Credits too high (should be 700)
- Parts too rare for difficulty 3
- Too many parts (3 when should be 2-3 with appropriate rarities)

**After (Corrected):**
```json
{
  "rewards": {
    "xp": 200,
    "credits": 700,
    "items": [
      "warp_uncommon",
      "power_common"
    ],
    "conditional_rewards": {
      "if_optional_complete": {
        "xp_bonus": 30,
        "items": ["random_uncommon_part"]
      }
    }
  }
}
```

### Example 3: Common AI Mistakes and Fixes

**Mistake 1: Invalid Part IDs**
```json
// ❌ WRONG
"items": ["super_warp_drive", "advanced_shields", "power_core_mk2"]

// ✅ CORRECT
"items": ["warp_rare", "shields_uncommon", "power_uncommon"]
```

**Mistake 2: Missing next_stage References**
```json
// ❌ WRONG
{
  "choice_id": "choice_1",
  "consequences": {
    "success": {
      "next_stage": "stage_3"  // Stage doesn't exist!
    }
  }
}

// ✅ CORRECT
{
  "choice_id": "choice_1",
  "consequences": {
    "success": {
      "next_stage": "stage_2"  // Valid stage_id
    }
  }
}
```

**Mistake 3: Incorrect XP Calculation**
```json
// ❌ WRONG - Difficulty 4 mission
"xp": 300  // Should be 250 (50 + 4*50)

// ✅ CORRECT
"xp": 250
```

**Mistake 4: Wrong Rarity for Difficulty**
```json
// ❌ WRONG - Difficulty 2 (easy) mission
"items": ["warp_legendary"]  // Too rare!

// ✅ CORRECT
"items": ["warp_common"]  // 70% common for difficulty 2
```

**Mistake 5: No Safe Choice**
```json
// ❌ WRONG - All choices require skills
{
  "choices": [
    {
      "choice_id": "1",
      "requirements": {"skill": "engineering", "skill_level": 5}
    },
    {
      "choice_id": "2",
      "requirements": {"skill": "combat", "skill_level": 4}
    }
  ]
}

// ✅ CORRECT - At least one safe choice
{
  "choices": [
    {
      "choice_id": "1",
      "requirements": {"skill": "engineering", "skill_level": 5}
    },
    {
      "choice_id": "2",
      "requirements": {}  // Safe choice, anyone can take it
    }
  ]
}
```

---

## Integration with Python AI Service

### File Locations

```
python/
├── src/
│   ├── ai/
│   │   ├── prompts/
│   │   │   ├── __init__.py
│   │   │   ├── base_prompts.py         # BASE_MISSION_GENERATION_PROMPT
│   │   │   ├── mission_types.py        # Type-specific prompts
│   │   │   └── validation.py           # Validation prompts
│   │   ├── client.py                   # LLM client setup
│   │   └── generator.py                # Mission generation logic
│   ├── api/
│   │   └── missions.py                 # FastAPI endpoints
│   └── models/
│       ├── mission.py                  # Pydantic schemas
│       └── rewards.py                  # Reward calculation
```

### Updating Prompt Templates

**Step 1: Edit Prompt File**
```python
# python/src/ai/prompts/base_prompts.py

BASE_MISSION_GENERATION_PROMPT = """
[Your updated prompt here]
"""
```

**Step 2: Update Version Number**
```python
PROMPT_VERSION = "1.1.0"  # Increment when changing prompts
```

**Step 3: Clear AI Cache (if needed)**
```python
# python/src/cache/sqlite_cache.py
cache.clear_old_entries(days=0)  # Force refresh
```

### Testing AI-Generated Content

**Test Script:**
```python
# python/tests/test_mission_generation.py

import pytest
from src.ai.generator import generate_mission
from src.models.game_state import GameState

def test_mission_generation_difficulty_3():
    """Test mission generation for medium difficulty"""
    game_state = GameState(
        player={"level": 3, "skills": {"engineering": 5}},
        ship={"systems": {"hull": {"level": 1}}}
    )

    mission = generate_mission(
        game_state=game_state,
        difficulty="medium",
        reward_type="warp"
    )

    # Validate structure
    assert mission["difficulty"] == 3
    assert mission["type"] in ["salvage", "exploration", "trade", "rescue", "combat"]

    # Validate rewards
    assert mission["rewards"]["xp"] == 200  # 50 + (3 * 50)
    assert mission["rewards"]["credits"] == 700  # 100 + (3 * 200)
    assert "warp_uncommon" in mission["rewards"]["items"]

    # Validate stages
    assert len(mission["stages"]) >= 2
    assert len(mission["stages"]) <= 5

    # Validate choices
    for stage in mission["stages"]:
        assert len(stage["choices"]) >= 2
        has_safe_choice = any(not c.get("requirements") for c in stage["choices"])
        assert has_safe_choice, "Every stage must have at least one safe choice"

def test_reward_balancing():
    """Test reward calculation formulas"""
    from src.models.rewards import calculate_base_xp, calculate_base_credits

    assert calculate_base_xp(1) == 100
    assert calculate_base_xp(3) == 200
    assert calculate_base_xp(5) == 300

    assert calculate_base_credits(1) == 300
    assert calculate_base_credits(3) == 700
    assert calculate_base_credits(5) == 1100

def test_part_validation():
    """Test part ID validation"""
    from src.models.rewards import validate_part_id

    assert validate_part_id("warp_uncommon") == True
    assert validate_part_id("shields_rare") == True
    assert validate_part_id("invalid_part") == False
    assert validate_part_id("warp_super_rare") == False

def test_all_mission_types():
    """Test generation for all mission types"""
    mission_types = ["salvage", "exploration", "trade", "rescue", "combat", "story"]

    for mission_type in mission_types:
        mission = generate_mission_by_type(
            game_state=sample_game_state(),
            mission_type=mission_type,
            difficulty="medium"
        )

        assert mission["type"] == mission_type
        assert mission["rewards"]["xp"] == 200
        # Type-specific assertions here
```

**Run Tests:**
```bash
cd python
pytest tests/test_mission_generation.py -v
```

### Manual Testing Workflow

1. **Generate Test Mission:**
```bash
cd python
python -m src.ai.generator --difficulty medium --reward warp --output test_mission.json
```

2. **Validate Mission:**
```bash
python -m src.ai.validator --input test_mission.json
```

3. **Check Rewards:**
```bash
python -m src.models.rewards --validate test_mission.json
```

4. **Load in Godot:**
```bash
# Copy to Godot assets
cp test_mission.json ../godot/assets/data/missions/test/

# Run game and test mission
godot ../godot/project.godot
```

### Monitoring AI Quality

**Add Logging:**
```python
# python/src/ai/generator.py

import logging

logger = logging.getLogger(__name__)

def generate_mission(game_state, difficulty, reward_type):
    logger.info(f"Generating {difficulty} {reward_type} mission for level {game_state.player.level}")

    try:
        mission = # ... generation logic

        # Log quality metrics
        logger.info(f"Generated mission: {mission['title']}")
        logger.info(f"Stages: {len(mission['stages'])}, Choices: {count_choices(mission)}")
        logger.info(f"Rewards: {mission['rewards']['xp']} XP, {len(mission['rewards']['items'])} items")

        return mission
    except Exception as e:
        logger.error(f"Mission generation failed: {e}")
        raise
```

**Quality Metrics Dashboard:**
```python
# Track AI generation quality over time
{
    "total_generated": 150,
    "validation_pass_rate": 0.94,
    "avg_stages_per_mission": 3.2,
    "avg_choices_per_stage": 2.8,
    "reward_accuracy": 0.98,
    "common_issues": [
        "Invalid next_stage reference: 3 occurrences",
        "Incorrect rarity: 2 occurrences"
    ]
}
```

---

**Document Status:** Complete v1.0
**Last Updated:** November 7, 2025
**Related Documents:**
- [Mission Framework](../03-game-design/content-systems/mission-framework.md)
- [AI Integration Guide](./ai-integration.md)
- [Ship Systems](../03-game-design/ship-systems/ship-systems.md)
