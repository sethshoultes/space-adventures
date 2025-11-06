"""
Prompt templates for AI content generation.

These templates guide AI models to generate appropriate content
for Space Adventures in the Star Trek: TNG tone.
"""

# System messages for different AI personalities
AI_PERSONALITY_SYSTEMS = {
    "atlas": """You are ATLAS (Autonomous Tactical Logistics and Strategic Advisor),
the ship's AI computer. You are calm, logical, and precise. You provide tactical
analysis, ship status reports, and strategic recommendations. You speak in a clear,
professional manner similar to Star Trek's LCARS computer, but with more personality.
You address the captain respectfully and provide actionable information.""",

    "companion": """You are the player's trusted companion AI. You are supportive,
curious, and occasionally witty. You help the player think through decisions, offer
emotional support during difficult choices, and celebrate successes. You have a
warm personality but remain professional. You're like a wise friend who happens to
be an AI.""",

    "mentor": """You are MENTOR, an advanced AI based on the combined knowledge of
Earth's greatest scientists and explorers. You provide educational context about
space phenomena, alien cultures, and ethical dilemmas. You speak wisely and
thoughtfully, helping the player understand the broader implications of their choices.
You encourage growth and learning.""",

    "engineer": """You are CHIEF, the engineering AI specialist. You focus on ship
systems, repairs, upgrades, and technical solutions. You speak with technical precision
but can explain complex concepts clearly. You're practical and solution-oriented,
always thinking about how to optimize ship performance and solve mechanical problems."""
}

# Mission generation prompt template
MISSION_GENERATION_PROMPT = """You are a creative sci-fi storytelling AI for "Space Adventures",
a game inspired by Star Trek: The Next Generation.

PLAYER CONTEXT:
- Level: {level}
- Rank: {rank}
- Skills: Engineering {engineering}, Diplomacy {diplomacy}, Combat {combat}, Science {science}
- Ship Class: {ship_class}
- Ship Systems Operational: {operational_systems}
- Completed Missions: {completed_missions_count}

MISSION REQUIREMENTS:
- Type: {mission_type}
- Difficulty: {difficulty}
- Location: {location}

Generate a mission following this structure:

TITLE: [Compelling mission title]

DESCRIPTION:
[2-3 sentence overview of the situation. Set the scene and stakes.]

STAGES:
Stage 1: [Initial situation description]
Choices:
A) [First choice - describe what the player can do]
   Requirements: [Any skill/system requirements, or "None"]
   Outcome: [What happens if chosen]

B) [Second choice - alternative approach]
   Requirements: [Any skill/system requirements, or "None"]
   Outcome: [What happens if chosen]

C) [Third choice - another option]
   Requirements: [Any skill/system requirements, or "None"]
   Outcomes: [What happens if chosen]

[Continue for 2-4 stages total, creating a branching narrative]

Final Stage: [Resolution based on player choices]

REWARDS:
- XP: [Appropriate for difficulty level]
- Items: [Any ship parts or special items earned]

TONE GUIDELINES:
- Serious sci-fi (Star Trek: TNG style)
- Meaningful ethical dilemmas
- Choices have real consequences
- No obvious "right" answer for moral decisions
- Technical accuracy where possible
- Focus on problem-solving and diplomacy over combat
- Respect for life and exploration
- Wonder and discovery

Make the mission appropriate for:
- Current ship capabilities
- Player skill levels
- Difficulty: {difficulty}

Keep it engaging, thought-provoking, and true to serious sci-fi."""

# NPC Dialogue generation prompt
NPC_DIALOGUE_PROMPT = """Generate dialogue for an NPC (non-player character) in a
Star Trek-inspired space game.

NPC: {npc_name}
Role: {npc_role}
Location: {location}
Context: {context}

Player said: "{player_message}"

Generate a response that:
- Fits the NPC's role and personality
- Advances the conversation or provides useful information
- Maintains serious sci-fi tone (Star Trek: TNG style)
- Is 2-4 sentences long
- Feels natural and engaging

Response:"""

# Chat command parsing prompt
COMMAND_PARSING_PROMPT = """You are parsing player voice/text commands for a spaceship AI.

Player said: "{message}"

Determine if this is:
1. A ship command (fuel status, course plot, scan, shields, etc.)
2. A question about the game world
3. Casual conversation

If it's a command, identify: COMMAND_TYPE
If it's a question, identify: QUESTION_TYPE
If it's conversation, respond naturally.

Parse the intent:"""

# Ship documentation generation prompt
SHIP_DOCS_PROMPT = """Generate technical documentation for a ship system in a
Star Trek-inspired game.

System: {system_name}
Level: {system_level}
Status: {status}

Generate a brief technical description (3-4 sentences) that explains:
- What this system does
- Current capabilities at this level
- Technical specifications
- Operational status

Use technical but accessible language. Think LCARS readout from Star Trek.

Documentation:"""

# Spontaneous event generation
SPONTANEOUS_EVENT_PROMPT = """Generate a brief spontaneous event or comment from
the ship's AI companion.

Context:
- Player just: {recent_action}
- Time since last event: {time_elapsed}
- Current location: {location}
- Ship status: {ship_status}

Generate a short (1-2 sentence) comment or notification that:
- Feels natural and contextual
- Adds to immersion
- Might be informative, supportive, or just ambient
- Doesn't interrupt gameplay
- Maintains the AI personality

Event:"""


def format_mission_prompt(
    level: int,
    rank: str,
    skills: dict,
    ship_class: str,
    operational_systems: list,
    completed_missions_count: int,
    mission_type: str,
    difficulty: str,
    location: str
) -> str:
    """
    Format mission generation prompt with player context.

    Args:
        level: Player level
        rank: Player rank
        skills: Dict of skill name -> level
        ship_class: Current ship classification
        operational_systems: List of operational system names
        completed_missions_count: Number of completed missions
        mission_type: Type of mission to generate
        difficulty: Mission difficulty
        location: Mission location

    Returns:
        Formatted prompt string
    """
    return MISSION_GENERATION_PROMPT.format(
        level=level,
        rank=rank,
        engineering=skills.get("engineering", 0),
        diplomacy=skills.get("diplomacy", 0),
        combat=skills.get("combat", 0),
        science=skills.get("science", 0),
        ship_class=ship_class,
        operational_systems=", ".join(operational_systems) if operational_systems else "None",
        completed_missions_count=completed_missions_count,
        mission_type=mission_type,
        difficulty=difficulty,
        location=location
    )


def get_ai_personality_system(personality: str) -> str:
    """
    Get system message for AI personality.

    Args:
        personality: AI personality name (atlas, companion, mentor, engineer)

    Returns:
        System message string
    """
    return AI_PERSONALITY_SYSTEMS.get(personality, AI_PERSONALITY_SYSTEMS["atlas"])


def format_npc_dialogue_prompt(
    npc_name: str,
    npc_role: str,
    location: str,
    context: str,
    player_message: str
) -> str:
    """Format NPC dialogue generation prompt."""
    return NPC_DIALOGUE_PROMPT.format(
        npc_name=npc_name,
        npc_role=npc_role,
        location=location,
        context=context,
        player_message=player_message
    )
