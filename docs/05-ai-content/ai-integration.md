# Space Adventures - AI Integration Guide

**Version:** 1.0
**Date:** November 5, 2025
**Purpose:** AI prompt templates, integration patterns, and best practices

---

## Table of Contents
1. [AI System Overview](#ai-system-overview)
2. [Prompt Engineering](#prompt-engineering)
3. [Mission Generation](#mission-generation)
4. [Encounter Generation](#encounter-generation)
5. [Dialogue Generation](#dialogue-generation)
6. [Context Management](#context-management)
7. [Quality Control](#quality-control)
8. [Implementation Examples](#implementation-examples)

---

## AI System Overview

### Supported Providers

**OpenAI (GPT-4 / GPT-3.5-turbo)**
- **Pros:** High quality, consistent, fast
- **Cons:** Costs money (~$0.03-0.06 per generation)
- **Best for:** Production, published games

**Ollama (Llama 2, Mistral, others)**
- **Pros:** Free, private, unlimited
- **Cons:** Slower, requires good hardware, variable quality
- **Best for:** Development, local play, privacy

### Configuration

```bash
# .env file
AI_PROVIDER=ollama  # or "openai"

# OpenAI settings
OPENAI_API_KEY=sk-your-key-here
OPENAI_MODEL=gpt-4  # or gpt-3.5-turbo for cheaper

# Ollama settings
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama2  # or mistral, codellama, etc.

# Generation settings
TEMPERATURE=0.8  # 0.0-1.0, higher = more creative/random
MAX_TOKENS=1500  # Response length limit
CACHE_ENABLED=true
```

### AI Usage Strategy

**60/40 Rule:**
- 60% pre-written content (story missions, critical moments)
- 40% AI-generated content (random missions, encounters, dialogue)

**Why?**
- Maintains narrative quality and coherence
- Reduces AI costs
- AI adds replayability and variety
- Critical story beats are hand-crafted

---

## Prompt Engineering

### Core Principles

1. **System Primer**: Establish role and tone first
2. **Context**: Provide game state and relevant information
3. **Constraints**: Define format, length, and restrictions
4. **Examples**: Show desired output format
5. **Validation**: Check output against schema

### Base System Prompt

```
You are a creative writer for a serious science fiction space adventure game
inspired by Star Trek: The Next Generation. Your role is to generate missions,
encounters, and dialogue that feel meaningful, thoughtful, and fit within an
established universe.

Tone Guidelines:
- Serious but not grim
- Thoughtful ethical dilemmas
- Wonder of space exploration
- Consequences matter
- No jokes or memes
- Avoid clichés
- Character-driven moments

World Building:
- Setting: 2247 AD, post-exodus Earth and beyond
- Technology: Realistic near-future sci-fi
- Themes: Discovery, ethics, survival, humanity's place in the cosmos
- Alien species exist and are diverse in culture and biology

Your output must be valid JSON following the provided schema.
```

### Temperature Guidelines

| Task | Temperature | Reasoning |
|------|-------------|-----------|
| Mission Structure | 0.6 | Balanced creativity and coherence |
| Encounter Scenarios | 0.8 | More variety, creative situations |
| Dialogue | 0.7 | Natural but consistent personality |
| Descriptions | 0.8 | Vivid, varied imagery |
| Technical Data | 0.3 | Consistency, avoid hallucination |

---

## Mission Generation

### Full Mission Prompt Template

```python
MISSION_GENERATION_PROMPT = """
{system_prompt}

Generate a mission for a space adventure game set on post-exodus Earth in 2247 AD.

GAME STATE:
Player Level: {player_level}
Player Skills: Engineering {eng}, Diplomacy {dip}, Combat {com}, Science {sci}
Ship Systems: {ship_systems_summary}
Completed Missions: {completed_count} ({recent_mission_titles})
Current Location: Earth
Phase: Earthbound (collecting ship parts)

REQUIREMENTS:
Mission Type: {mission_type}
Reward Type: {required_reward_system} component (Level {reward_level})
Difficulty: {target_difficulty}/5
Length: 3-4 stages

CONSTRAINTS:
- Must be completable with player's current skills and systems
- Should offer multiple approaches (skill-based, system-based, or clever thinking)
- Include meaningful choice with consequences
- Fit the established world (abandoned Earth, scavenging culture)
- No space travel (player hasn't left Earth yet)
- Tone: Serious sci-fi, not comedic

MISSION STRUCTURE:
{{
  "mission_id": "generated_mission_{timestamp}",
  "title": "Evocative title (3-6 words)",
  "type": "{mission_type}",
  "location": "Specific abandoned Earth location",
  "description": "2-3 sentence mission briefing",
  "difficulty": {target_difficulty},
  "requirements": {{
    "min_level": {max(1, player_level - 1)},
    "required_systems": [],
    "completed_missions": []
  }},
  "objectives": [
    "Primary objective: {required_reward_system} component",
    "[OPTIONAL] Secondary objective"
  ],
  "stages": [
    {{
      "stage_id": "approach",
      "title": "Stage title",
      "description": "Vivid 2-4 sentence description of the situation",
      "choices": [
        {{
          "choice_id": "choice_1",
          "text": "Choice text (player perspective)",
          "requirements": {{"skill": "engineering", "skill_level": {eng}}},
          "success_chance": "skill_based or percentage",
          "consequences": {{
            "success": {{
              "text": "Success outcome (2-3 sentences)",
              "next_stage": "next_stage_id",
              "effects": ["effect_name"],
              "xp_bonus": 25
            }},
            "failure": {{
              "text": "Failure outcome (2-3 sentences)",
              "next_stage": "alternate_stage_id",
              "effects": ["different_effect"]
            }}
          }}
        }},
        {{
          "choice_id": "choice_2",
          "text": "Alternative approach",
          "requirements": {{}},
          "consequences": {{
            "text": "Outcome description",
            "next_stage": "next_stage_id"
          }}
        }}
      ]
    }},
    // 2-3 more stages following same structure
    {{
      "stage_id": "final_stage",
      "title": "Resolution",
      "description": "Final stage description",
      "choices": [
        {{
          "choice_id": "complete",
          "text": "Complete the mission",
          "consequences": {{
            "text": "Success! Mission complete.",
            "complete": true
          }}
        }}
      ]
    }}
  ],
  "rewards": {{
    "xp": {50 + (target_difficulty * 30)},
    "items": ["{required_reward_system}_{reward_rarity}"],
    "conditional_rewards": {{}}
  }}
}}

Generate the complete mission JSON now. Ensure all stage IDs are referenced correctly.
"""
```

### Mission Generation Request

```python
# python/src/api/missions.py

from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain

def generate_mission(game_state: GameState, difficulty: str, reward_type: str):
    """Generate a mission using AI"""

    # Prepare context
    context = {
        "system_prompt": BASE_SYSTEM_PROMPT,
        "player_level": game_state.player.level,
        "eng": game_state.player.skills.get("engineering", 0),
        "dip": game_state.player.skills.get("diplomacy", 0),
        "com": game_state.player.skills.get("combat", 0),
        "sci": game_state.player.skills.get("science", 0),
        "ship_systems_summary": format_systems_summary(game_state.ship),
        "completed_count": len(game_state.progress.completed_missions),
        "recent_mission_titles": get_recent_mission_titles(game_state, 3),
        "mission_type": determine_mission_type(game_state),
        "required_reward_system": reward_type,
        "reward_level": determine_reward_level(game_state, reward_type),
        "target_difficulty": difficulty_to_number(difficulty),
        "reward_rarity": calculate_rarity(difficulty),
        "timestamp": int(time.time())
    }

    # Generate
    prompt = PromptTemplate(
        input_variables=list(context.keys()),
        template=MISSION_GENERATION_PROMPT
    )

    chain = LLMChain(llm=get_llm(), prompt=prompt)
    result = chain.run(**context)

    # Parse and validate
    try:
        mission_data = json.loads(result)
        validate_mission_schema(mission_data)
        return mission_data
    except json.JSONDecodeError:
        # Fallback to template mission
        logger.error("Failed to parse AI mission, using fallback")
        return create_fallback_mission(context)
    except ValidationError as e:
        logger.error(f"AI mission failed validation: {e}")
        return create_fallback_mission(context)
```

---

## Encounter Generation

### Space Encounter Prompt

```python
ENCOUNTER_GENERATION_PROMPT = """
{system_prompt}

Generate a space encounter for a science fiction adventure game.

GAME STATE:
Player Level: {player_level}
Ship Systems: {ship_summary}
Current Location: {star_system} ({system_description})
Journey Stage: {journey_stage}
Recent Choices: {recent_choices_summary}

ENCOUNTER PARAMETERS:
Type: {encounter_type}
Tone: {tone}
Difficulty: {difficulty}/5

ENCOUNTER TYPES:
- exploration: Discover something interesting or mysterious
- diplomacy: Meet aliens or other ships, communicate
- combat: Hostile encounter requiring tactics
- rescue: Someone needs help
- mystery: Something strange that needs investigation
- moral_dilemma: Ethical choice with no clear answer

STRUCTURE:
{{
  "encounter_id": "enc_{system}_{timestamp}",
  "type": "{encounter_type}",
  "title": "Encounter title",
  "description": "3-5 sentences describing the situation. Set the scene vividly.",
  "atmosphere": "mysterious|tense|wondrous|urgent|calm",
  "choices": [
    {{
      "choice_id": "choice_1",
      "text": "Player action choice",
      "requirements": {{
        "system": "sensors",
        "level": 2
      }},
      "consequences": {{
        "type": "skill_check|combat|safe|story",
        "description": "What happens if chosen",
        "effects": ["effect_tags"],
        "rewards": ["optional_rewards"],
        "risks": ["potential_dangers"]
      }}
    }},
    // 3-5 choices total, at least one with no requirements
  ],
  "flavor_text": {{
    "sensor_reading": "Technical data if scanned",
    "ship_ai_comment": "If computer L3+, AI offers observation",
    "captain_log": "Reflective moment option"
  }}
}}

GUIDELINES:
- Make it feel meaningful, not random
- Include at least one "safe" choice and one "risky but rewarding" choice
- Consider player's ship systems when designing choices
- Create tension through description
- Avoid combat unless encounter type is combat
- For moral dilemmas, no choice should be obviously "right"

Generate the encounter JSON now.
"""
```

### Example Encounter Generations

**Exploration Encounter:**

```json
{
  "encounter_id": "enc_rigel_quantum_rift_1730854321",
  "type": "exploration",
  "title": "Quantum Rift in Rigel",
  "description": "Your sensors detect an anomaly ahead - a shimmering tear in spacetime, pulsing with exotic radiation. It defies conventional physics, existing in a state of quantum superposition. Long-range scans suggest it might be a natural wormhole, but the readings are... wrong. Something about it seems artificial. Your computer calculates it will collapse in approximately 6 hours.",
  "atmosphere": "mysterious",
  "choices": [
    {
      "choice_id": "investigate_close",
      "text": "Move in close to investigate the rift directly",
      "requirements": {
        "system": "shields",
        "level": 3
      },
      "consequences": {
        "type": "skill_check",
        "skill": "science",
        "dc": 14,
        "description": "Moving close exposes your ship to intense radiation, but your sensors gather incredible data. Science check to understand what you're seeing.",
        "success": {
          "text": "You recognize the signature - this is a manufactured quantum rift, created by technology far beyond current human capabilities. Who made this, and why? You download the data for later analysis.",
          "effects": ["quantum_data_acquired", "advanced_tech_clue"],
          "rewards": ["rare_data"],
          "xp": 150
        },
        "failure": {
          "text": "The radiation is overwhelming. Your shields hold, but you can't make sense of the readings. You retreat with only partial data.",
          "effects": ["partial_data"],
          "rewards": ["common_data"],
          "damage": 15,
          "xp": 50
        }
      }
    },
    {
      "choice_id": "scan_distance",
      "text": "Scan from a safe distance",
      "requirements": {
        "system": "sensors",
        "level": 2
      },
      "consequences": {
        "type": "safe",
        "description": "Your sensors conduct a comprehensive scan from a safe distance. You gather valuable data without risk.",
        "effects": ["quantum_signature_logged"],
        "rewards": ["uncommon_data"],
        "xp": 75
      }
    },
    {
      "choice_id": "enter_rift",
      "text": "Enter the rift - this might be a shortcut",
      "requirements": {
        "system": "shields",
        "level": 4
      },
      "consequences": {
        "type": "story",
        "description": "This is extremely dangerous. Your ship could be torn apart by quantum forces. But if it IS a wormhole...",
        "success_chance": 40,
        "success": {
          "text": "Reality bends around you. For an impossible moment, you exist in multiple places simultaneously. Then - you emerge in an entirely different star system, hundreds of light years away. Your computer is trying to determine where you are.",
          "effects": ["wormhole_used", "location_changed", "major_discovery"],
          "xp": 300,
          "special": "unlock_new_system"
        },
        "failure": {
          "text": "The rift tears at your ship. Alarms blare as systems overload. At the last moment, you're ejected back into normal space, your ship heavily damaged.",
          "effects": ["major_damage"],
          "damage": 100,
          "system_damage": ["random", "random"],
          "xp": 50
        }
      }
    },
    {
      "choice_id": "mark_and_continue",
      "text": "Mark the location and continue your journey",
      "requirements": {},
      "consequences": {
        "type": "safe",
        "description": "You log the rift's coordinates and move on. Perhaps someone else will investigate it.",
        "effects": ["rift_location_known"],
        "xp": 25
      }
    }
  ],
  "flavor_text": {
    "sensor_reading": "ANOMALY: Quantum superposition state detected. Energy signature: 10^47 watts. Classification: Unknown. WARNING: Causality violation possible.",
    "ship_ai_comment": "Captain, I am detecting technology consistent with a civilization at least Type 2 on the Kardashev scale. Recommendation: Extreme caution.",
    "captain_log": "Captain's log: We've found something extraordinary. Whatever created this has technology centuries beyond our own. I feel like we're children who've stumbled into a room full of ancient mysteries."
  }
}
```

**Moral Dilemma Encounter:**

```json
{
  "encounter_id": "enc_alpha_centauri_refugee_1730854421",
  "type": "moral_dilemma",
  "title": "The Refugee Ship",
  "description": "A distress call leads you to a battered colony ship, the 'New Hope'. Aboard are 200 refugees fleeing a dying world, their life support failing. They beg for help - food, water, medical supplies. But your own supplies are limited, and you're weeks from the nearest station. Helping them significantly would deplete your reserves, leaving you vulnerable. Their ship won't last another week. Behind them, their homeworld burns.",
  "atmosphere": "urgent",
  "choices": [
    {
      "choice_id": "give_supplies",
      "text": "Give them half your supplies - it'll be tight, but we'll both make it",
      "requirements": {},
      "consequences": {
        "type": "safe",
        "description": "You transfer supplies. The refugees are grateful beyond words. Your own journey will be harder now, but you saved 200 lives.",
        "effects": ["supplies_depleted", "refugees_saved", "good_karma"],
        "resources": {
          "food": -50,
          "water": -50,
          "medical": -30
        },
        "reputation": 50,
        "xp": 100
      }
    },
    {
      "choice_id": "minimal_help",
      "text": "Give them just enough to reach the nearest station",
      "requirements": {
        "system": "computer",
        "level": 2
      },
      "consequences": {
        "type": "safe",
        "description": "Your computer calculates the minimum supplies needed. It's risky for them, but possible. They accept reluctantly.",
        "effects": ["refugees_helped", "neutral_karma"],
        "resources": {
          "food": -20,
          "water": -20,
          "medical": -10
        },
        "reputation": 20,
        "xp": 75
      }
    },
    {
      "choice_id": "escort_them",
      "text": "Escort them to the nearest station - no supply transfer, but you'll protect them",
      "requirements": {
        "system": "weapons",
        "level": 2
      },
      "consequences": {
        "type": "story",
        "description": "The journey takes 8 days. On day 5, you encounter pirates who see the refugee ship as easy prey. You must defend them.",
        "effects": ["refugees_escorted", "good_karma", "combat_triggered"],
        "xp": 200,
        "reputation": 75
      }
    },
    {
      "choice_id": "refuse",
      "text": "I'm sorry, but I can't risk my own survival",
      "requirements": {},
      "consequences": {
        "type": "safe",
        "description": "You express regret and continue on. You don't look back, but you hear their desperate calls on the radio for a long time. The silence afterwards is worse.",
        "effects": ["refugees_abandoned", "bad_karma", "guilt"],
        "reputation": -50,
        "xp": 25,
        "psychological": "You'll remember this."
      }
    },
    {
      "choice_id": "creative_solution",
      "text": "Offer to repair their ship's life support instead",
      "requirements": {
        "skill": "engineering",
        "skill_level": 5
      },
      "consequences": {
        "type": "skill_check",
        "skill": "engineering",
        "dc": 15,
        "description": "You board their ship and attempt repairs. It's badly damaged, but maybe...",
        "success": {
          "text": "After hours of work in cramped conditions, you manage to repair their life support. They can reach a station under their own power now. They offer you what little they have in thanks.",
          "effects": ["refugees_saved", "exceptional_karma", "friendship_earned"],
          "rewards": ["refugee_gratitude_token"],
          "reputation": 100,
          "xp": 250
        },
        "failure": {
          "text": "The damage is beyond your skills. You tried, but now you must choose: give supplies or leave them?",
          "effects": ["attempt_made"],
          "xp": 50,
          "next_stage": "choice_required"
        }
      }
    }
  ],
  "flavor_text": {
    "sensor_reading": "DISTRESS CALL DETECTED. Origin: Colony ship 'New Hope'. Life support: CRITICAL. Crew: 200 souls. Time to system failure: 156 hours.",
    "ship_ai_comment": "Captain, I calculate a 73% chance we can assist them without compromising our mission. However, unforeseen complications could change that assessment.",
    "captain_log": "These are the moments that define us. Not the big heroic battles, but the quiet choice between our safety and theirs. What kind of person am I? What kind do I want to be?"
  }
}
```

---

## Dialogue Generation

### NPC Dialogue Prompt

```python
DIALOGUE_GENERATION_PROMPT = """
{system_prompt}

Generate NPC dialogue for a space adventure game.

CHARACTER:
Name: {character_name}
Species: {species}
Role: {role}
Personality: {personality_traits}
Relationship with Player: {relationship}
Current Mood: {mood}

CONTEXT:
Location: {location}
Situation: {situation}
Player's Recent Actions: {player_actions}
Conversation Topic: {topic}

PLAYER INPUT: "{player_input}"

Generate the NPC's response following these guidelines:
- Stay in character (personality, species, role)
- Reference the context and situation naturally
- Reflect the character's mood and relationship with player
- Provide 2-4 response options for the player
- Show emotion and personality, not just information
- Use dialogue tags for tone when relevant
- Keep responses 2-5 sentences

OUTPUT FORMAT:
{{
  "character": "{character_name}",
  "dialogue": "The character's spoken response",
  "emotional_tone": "curious|friendly|hostile|suspicious|sad|excited|neutral",
  "body_language": "Brief description of non-verbal communication",
  "internal_thought": "Optional: What they're thinking but not saying",
  "choices": [
    {{
      "choice_id": "response_1",
      "text": "Player response option",
      "tone": "diplomatic|aggressive|curious|humorous",
      "likely_reaction": "How NPC might react"
    }}
  ]
}}

Generate the dialogue now.
"""
```

### Dialogue Example

```json
{
  "character": "Ambassador Zelith",
  "dialogue": "Your species is... impulsive. You barely understand warp theory, yet you fling yourselves into the void without hesitation. *The ambassador's crystalline form shifts colors, pulsing with what might be amusement* Is it bravery or ignorance that drives humanity? I genuinely cannot tell, and that fascinates me.",
  "emotional_tone": "curious",
  "body_language": "The Zenari ambassador's crystalline body shifts from deep blue to warm amber, a sign of genuine interest in their culture. Their many faceted eyes catch the light as they lean slightly forward.",
  "internal_thought": "These humans remind me of our own species in our youth - reckless, passionate, stumbling toward greatness or extinction. They will either be our greatest ally or our greatest mistake.",
  "choices": [
    {
      "choice_id": "defend_humanity",
      "text": "It's neither. It's hope. We believe there's something worth finding out here.",
      "tone": "diplomatic",
      "likely_reaction": "Respect. The ambassador appreciates philosophical depth."
    },
    {
      "choice_id": "admit_fear",
      "text": "Honestly? Sometimes I think it's both. But we're learning.",
      "tone": "honest",
      "likely_reaction": "Warmth. Honesty is valued in Zenari culture."
    },
    {
      "choice_id": "challenge_them",
      "text": "And your people? Did you always have all the answers?",
      "tone": "assertive",
      "likely_reaction": "Amused. A bold response might earn their friendship."
    },
    {
      "choice_id": "deflect",
      "text": "I'd rather talk about your species. How does communication work for crystalline beings?",
      "tone": "curious",
      "likely_reaction": "Neutral. Subject change noted but not offensive."
    }
  ]
}
```

---

## Context Management

### Context Window Strategy

AI models have token limits. Manage context carefully:

**Priority Levels:**
1. **System Prompt** (always include) - ~500 tokens
2. **Current Situation** (critical) - ~200 tokens
3. **Player Stats & Ship** (important) - ~300 tokens
4. **Recent History** (useful) - ~500 tokens
5. **Full History** (ideal but often cut) - variable

**Token Budget:**
- GPT-4: 8k context (budget: 3k prompt, 5k for history/response)
- GPT-3.5: 4k context (budget: 1.5k prompt, 2.5k for history/response)
- Llama 2: 4k context (similar to GPT-3.5)

### Context Compression

```python
def create_game_context_summary(game_state: GameState) -> str:
    """Create compressed context for AI"""

    # Current state (always included)
    context = f"""
    PLAYER: Level {game_state.player.level}
    SKILLS: Eng {game_state.player.skills.engineering}, Dip {game_state.player.skills.diplomacy},
            Combat {game_state.player.skills.combat}, Science {game_state.player.skills.science}

    SHIP: {game_state.ship.name}
    SYSTEMS: Hull L{game_state.ship.systems.hull.level},
             Power L{game_state.ship.systems.power.level},
             Warp L{game_state.ship.systems.warp.level}
             [other key systems...]

    LOCATION: {game_state.current_location}
    PHASE: {"Earthbound" if game_state.progress.phase == 1 else "Space Exploration"}

    RECENT MISSIONS: {", ".join(game_state.progress.completed_missions[-3:])}

    MAJOR CHOICES:
    """

    # Add last 3 major choices
    for choice in game_state.progress.major_choices[-3:]:
        context += f"- {choice.description}\n"

    return context.strip()
```

### Conversation Memory

For multi-turn dialogues:

```python
class ConversationManager:
    def __init__(self):
        self.conversations = {}  # character_id -> message history

    def add_turn(self, character_id: str, player_msg: str, npc_msg: str):
        if character_id not in self.conversations:
            self.conversations[character_id] = []

        self.conversations[character_id].append({
            "player": player_msg,
            "npc": npc_msg,
            "timestamp": time.time()
        })

        # Keep only last 5 turns
        self.conversations[character_id] = self.conversations[character_id][-5:]

    def get_history_context(self, character_id: str) -> str:
        if character_id not in self.conversations:
            return "First conversation with this character."

        history = []
        for turn in self.conversations[character_id]:
            history.append(f"You: {turn['player']}")
            history.append(f"Them: {turn['npc']}")

        return "\n".join(history)
```

---

## Quality Control

### Validation Schema

```python
from pydantic import BaseModel, validator, Field
from typing import List, Dict, Optional

class MissionChoice(BaseModel):
    choice_id: str
    text: str = Field(..., min_length=10, max_length=200)
    requirements: Dict = {}
    consequences: Dict

    @validator('text')
    def text_must_be_action(cls, v):
        # Ensure choice text is action-oriented
        if not any(word in v.lower() for word in ['go', 'try', 'use', 'talk', 'take', 'leave']):
            raise ValueError('Choice must be an actionable statement')
        return v

class MissionStage(BaseModel):
    stage_id: str
    title: str = Field(..., min_length=3, max_length=50)
    description: str = Field(..., min_length=20, max_length=500)
    choices: List[MissionChoice] = Field(..., min_items=2, max_items=5)

class GeneratedMission(BaseModel):
    mission_id: str
    title: str
    type: str
    location: str
    description: str
    difficulty: int = Field(..., ge=1, le=5)
    stages: List[MissionStage] = Field(..., min_items=2, max_items=5)
    rewards: Dict

    @validator('type')
    def valid_mission_type(cls, v):
        valid_types = ['salvage', 'exploration', 'trade', 'rescue', 'combat', 'story']
        if v not in valid_types:
            raise ValueError(f'Invalid mission type: {v}')
        return v

def validate_mission_schema(mission_data: dict) -> bool:
    """Validate AI-generated mission against schema"""
    try:
        GeneratedMission(**mission_data)
        return True
    except ValidationError as e:
        logger.error(f"Mission validation failed: {e}")
        return False
```

### Fallback System

```python
def create_fallback_mission(context: dict) -> dict:
    """Create a simple template mission if AI fails"""

    templates = {
        "salvage": {
            "title": f"Salvage Run: {context['required_reward_system'].title()} Component",
            "description": "A routine salvage operation to retrieve needed ship parts.",
            "stages": [
                # Simple 2-stage template mission
            ]
        },
        # More templates...
    }

    mission_type = context.get('mission_type', 'salvage')
    template = templates.get(mission_type, templates['salvage'])

    # Fill in template with context
    return populate_template(template, context)
```

### Response Caching

```python
# python/src/cache/sqlite_cache.py

import sqlite3
import hashlib
import json
from datetime import datetime, timedelta

class AIResponseCache:
    def __init__(self, db_path: str = "cache.db"):
        self.conn = sqlite3.connect(db_path)
        self._create_table()

    def _create_table(self):
        self.conn.execute("""
            CREATE TABLE IF NOT EXISTS ai_cache (
                cache_key TEXT PRIMARY KEY,
                response_data TEXT,
                created_at TIMESTAMP,
                hit_count INTEGER DEFAULT 0
            )
        """)

    def get_cache_key(self, prompt: str, context: dict) -> str:
        """Generate cache key from prompt and context"""
        # Hash the prompt + relevant context
        cache_input = f"{prompt}_{json.dumps(context, sort_keys=True)}"
        return hashlib.md5(cache_input.encode()).hexdigest()

    def get(self, cache_key: str, max_age_hours: int = 24) -> Optional[dict]:
        """Retrieve cached response if not expired"""
        cursor = self.conn.execute("""
            SELECT response_data, created_at
            FROM ai_cache
            WHERE cache_key = ?
        """, (cache_key,))

        row = cursor.fetchone()
        if not row:
            return None

        response_data, created_at = row
        created_time = datetime.fromisoformat(created_at)

        # Check if expired
        if datetime.now() - created_time > timedelta(hours=max_age_hours):
            return None

        # Update hit count
        self.conn.execute("""
            UPDATE ai_cache
            SET hit_count = hit_count + 1
            WHERE cache_key = ?
        """, (cache_key,))
        self.conn.commit()

        return json.loads(response_data)

    def set(self, cache_key: str, response_data: dict):
        """Cache a new response"""
        self.conn.execute("""
            INSERT OR REPLACE INTO ai_cache (cache_key, response_data, created_at, hit_count)
            VALUES (?, ?, ?, 0)
        """, (cache_key, json.dumps(response_data), datetime.now().isoformat()))
        self.conn.commit()

    def clear_old_entries(self, days: int = 7):
        """Clean up old cache entries"""
        cutoff = datetime.now() - timedelta(days=days)
        self.conn.execute("""
            DELETE FROM ai_cache
            WHERE created_at < ?
        """, (cutoff.isoformat(),))
        self.conn.commit()
```

---

## Story Engine API Endpoints

The dynamic story engine provides dedicated endpoints for contextual narrative generation:

### Core Endpoints

- `POST /api/story/generate_narrative` - Generate stage narrative
- `POST /api/story/generate_outcome` - Generate choice outcome
- `GET /api/story/memory/{player_id}` - Get player memory context
- `GET /api/story/mission_pool` - Get side mission from pool
- `GET /api/story/world_context` - Get world state
- `DELETE /api/story/invalidate_cache` - Invalidate cached narratives

For complete API documentation, see [Story API Reference](../06-technical-reference/STORY-API-REFERENCE.md).

### Integration Pattern

```gdscript
# Godot integration example
var story_result = await StoryService.generate_narrative({
    "player_id": "player_123",
    "mission_template": mission_data,
    "stage_id": "stage_1",
    "player_state": GameState.get_player_state()
})

if story_result.success:
    display_narrative(story_result.narrative)
```

See [Godot Story Integration Guide](godot-story-integration.md) for complete integration patterns.

---

## Implementation Examples

### Complete API Endpoint

```python
# python/src/api/missions.py

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from src.ai.client import get_llm
from src.ai.prompts import MISSION_GENERATION_PROMPT
from src.cache.sqlite_cache import AIResponseCache
from src.models.game_state import GameState

router = APIRouter()
cache = AIResponseCache()

class MissionGenerationRequest(BaseModel):
    game_state: dict
    difficulty: str = "medium"
    required_reward_type: str

class MissionGenerationResponse(BaseModel):
    mission: dict
    cached: bool = False

@router.post("/generate", response_model=MissionGenerationResponse)
async def generate_mission(request: MissionGenerationRequest):
    """Generate a new mission using AI"""

    # Parse game state
    try:
        game_state = GameState(**request.game_state)
    except ValidationError as e:
        raise HTTPException(status_code=400, detail=f"Invalid game state: {e}")

    # Check cache
    cache_key = cache.get_cache_key(
        "mission",
        {
            "level": game_state.player.level,
            "reward": request.required_reward_type,
            "difficulty": request.difficulty
        }
    )

    cached_mission = cache.get(cache_key, max_age_hours=48)
    if cached_mission:
        return MissionGenerationResponse(mission=cached_mission, cached=True)

    # Generate new mission
    try:
        context = prepare_mission_context(game_state, request)
        llm = get_llm()

        # Generate
        prompt = MISSION_GENERATION_PROMPT.format(**context)
        response = llm.generate([prompt])
        mission_data = parse_and_validate_response(response.generations[0][0].text)

        # Cache it
        cache.set(cache_key, mission_data)

        return MissionGenerationResponse(mission=mission_data, cached=False)

    except Exception as e:
        logger.error(f"Mission generation failed: {e}")

        # Return fallback
        fallback = create_fallback_mission(context)
        return MissionGenerationResponse(mission=fallback, cached=False)

def prepare_mission_context(game_state: GameState, request: MissionGenerationRequest) -> dict:
    """Prepare context dictionary for prompt"""
    return {
        "system_prompt": BASE_SYSTEM_PROMPT,
        "player_level": game_state.player.level,
        "eng": game_state.player.skills.get("engineering", 0),
        "dip": game_state.player.skills.get("diplomacy", 0),
        "com": game_state.player.skills.get("combat", 0),
        "sci": game_state.player.skills.get("science", 0),
        "ship_systems_summary": format_systems_summary(game_state.ship),
        "completed_count": len(game_state.progress.completed_missions),
        "recent_mission_titles": get_recent_titles(game_state),
        "mission_type": determine_type(request.required_reward_type),
        "required_reward_system": request.required_reward_type,
        "reward_level": calculate_reward_level(game_state),
        "target_difficulty": difficulty_map[request.difficulty],
        "reward_rarity": rarity_map[request.difficulty],
        "timestamp": int(time.time())
    }
```

---

## Cost Estimation

### OpenAI Pricing (as of 2025)

**GPT-4:**
- Input: $0.03 per 1K tokens
- Output: $0.06 per 1K tokens
- Average mission: ~1.5K input, ~1K output = $0.105 per generation

**GPT-3.5-turbo:**
- Input: $0.0015 per 1K tokens
- Output: $0.002 per 1K tokens
- Average mission: ~1.5K input, ~1K output = $0.00425 per generation

**Budget Planning:**
- 10 players × 20 AI missions each = 200 generations
- GPT-4: $21
- GPT-3.5: $0.85

**Recommendation:** Use GPT-3.5-turbo for development, GPT-4 for production if budget allows.

### Ollama (Free)

- **Cost:** $0 (runs locally)
- **Trade-off:** Requires good hardware (8GB+ VRAM for good quality)
- **Speed:** 2-10 seconds per generation (hardware dependent)
- **Quality:** Good with llama2:13b or mistral

---

**Document Status:** Complete v1.0
**Last Updated:** November 5, 2025
