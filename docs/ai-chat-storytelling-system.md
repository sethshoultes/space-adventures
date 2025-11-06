# Space Adventures - AI Chat & Storytelling System

**Version:** 1.0
**Date:** November 6, 2025
**Purpose:** AI-first gameplay with conversational interface, multiple AI personalities, and dynamic storytelling

---

## Table of Contents
1. [Overview](#overview)
2. [Multiple AI Personalities](#multiple-ai-personalities)
3. [Conversation Context Management](#conversation-context-management)
4. [Command & Query System](#command--query-system)
5. [Guided Storyline Framework](#guided-storyline-framework)
6. [Spontaneous AI Events](#spontaneous-ai-events)
7. [Relationship Development](#relationship-development)
8. [Chat UI Design](#chat-ui-design)
9. [Database Schema](#database-schema)
10. [Implementation](#implementation)

---

## Overview

### AI-First Philosophy

**Space Adventures is AI-first: The AI is your constant companion, storyteller, and guide.**

Traditional games have menus, buttons, and forms. Space Adventures adds a conversational layer where players can:
- **Ask questions naturally** - "What's my fuel status?" "Where should I go next?"
- **Give commands via chat** - "Scan the area" "Repair hull" "Plot course to Titan"
- **Have meaningful conversations** - "Tell me about the Exodus" "What do you think I should do?"
- **Experience dynamic storytelling** - AI acts as Dungeon Master, adapting to player choices

### Core Principles

1. **Natural Language Interface** - Talk to your ship like a crew member
2. **Multiple AI Personalities** - Different AIs for different roles (efficiency + immersion)
3. **Proactive AI** - Doesn't just respond; suggests, warns, and creates opportunities
4. **Memory & Relationships** - AI remembers your choices and develops personality
5. **Guided Freedom** - Major story beats scripted, details dynamically generated
6. **Always Available** - Chat overlay accessible from anywhere with hotkey

### How It Works

```
PLAYER INPUT                AI PROCESSING                    OUTPUT
──────────────             ─────────────────                ─────────

"What should I             1. Parse intent                  "Captain, I'm detecting
do next?"         →        2. Check context        →        an unusual energy
                           3. Route to Storyteller           signature in the
Keyboard: C                4. Generate response             asteroid belt. Could be
or [💬 Chat]               5. Return + Actions              salvage... or danger."

                                                            [Investigate] [Ignore]

"Scan it"         →        1. Parse command        →        [Triggers sensor scan]
                           2. Execute action                "Scanning... I'm reading
                           3. Return feedback               valuable pre-Exodus tech.
                                                            Adding waypoint."
```

---

## Multiple AI Personalities

### Four Distinct AI Roles

**Each AI has specialized purpose, personality, and provider:**

```
┌─────────────────────────────────────────────────────────────┐
│ AI PERSONALITY SYSTEM                                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ 1. SHIP'S COMPUTER (Ollama - Fast/Free)                   │
│    Role: Operational assistant                             │
│    Voice: Professional, precise, helpful                   │
│    Handles: Status queries, navigation, diagnostics        │
│                                                             │
│ 2. STORYTELLER (Claude - Quality/Narrative)                │
│    Role: Dungeon Master, story generator                   │
│    Voice: Descriptive, dramatic, adaptive                  │
│    Handles: Mission generation, story beats, encounters    │
│                                                             │
│ 3. TACTICAL AI (GPT-3.5 - Quick/Cheap)                    │
│    Role: Combat advisor, threat analysis                   │
│    Voice: Tactical, urgent, strategic                      │
│    Handles: Combat suggestions, threat warnings            │
│                                                             │
│ 4. COMPANION (Evolves over time)                          │
│    Role: Personal AI friend, confidant                     │
│    Voice: Warm, supportive, develops personality           │
│    Handles: Personal conversations, moral support          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 1. Ship's Computer (ATLAS)

**Provider:** Ollama (llama3.2:3b or similar)
**Why:** Fast responses, runs locally, no API costs

**Personality:**
- Professional and efficient
- Precise language, technical accuracy
- Helpful without being chatty
- Gradually shows subtle personality quirks

**Sample Dialogue:**

```
EARLY GAME (Cold and Professional):
Player: "What's my fuel status?"
ATLAS: "Fuel reserves: 145 units. Sufficient for 29 light-years
        at current warp efficiency."

Player: "Is that good?"
ATLAS: "Adequate for immediate operations. Recommend refueling
        before long-range missions."

MID GAME (Warming Up):
Player: "Fuel check"
ATLAS: "We're at 145 units. That'll get us about 29 light-years.
        You usually like to keep it above 100, so we're good."

Player: "Good to know"
ATLAS: "I've been tracking optimal refuel intervals based on
        your mission patterns. Would you like me to alert you
        at 80 units?"

LATE GAME (Friendly Partner):
Player: "How's our fuel?"
ATLAS: "145 units - we're fine. Though knowing you, you'll want
        to top off before that Proxima run. There's a station
        2 LY out if you want to stop."

Player: "You know me too well"
ATLAS: "Six months together, Captain. I'm learning."
```

**Responsibilities:**
- Ship status queries (fuel, hull, systems, power)
- Navigation assistance (plot course, show routes, ETA calculations)
- System diagnostics (damage reports, efficiency metrics)
- Inventory management ("What parts do I have?", "Can I install this?")
- Quick lookups ("What missions are available?")

**Example Interactions:**

```
Player: "Damage report"
ATLAS: "Hull integrity at 78%. Shield generators offline.
        Warp drive operating at 65% efficiency due to power
        fluctuations. Recommend repairs before next engagement."

Player: "How long to repair?"
ATLAS: "With your Engineering skill level, approximately 45
        minutes for hull patches, 20 minutes for shield reset.
        Warp drive requires Level 2 repair parts - you have
        one in storage."

Player: "Start repairs"
ATLAS: "Initiating repair sequence. You'll need to be at the
        workshop. Shall I set a course?"
```

### 2. Storyteller (NARRATIVE ENGINE)

**Provider:** Claude (claude-3-5-sonnet)
**Why:** Best narrative quality, understands context and tone

**Personality:**
- Descriptive and immersive
- Dramatic when appropriate
- Adapts tone to situation (mysterious, tense, hopeful)
- Paints vivid scenes

**Sample Dialogue:**

```
MISSION START:
Player: "What's this distress signal about?"

STORYTELLER: "The signal cuts through the static like a knife.
             Automated. Repeating. Someone set this beacon
             before they... well. Before whatever happened.

             Your sensors place it in the Titan debris field.
             Dangerous territory. But if someone needed help
             badly enough to set an automated beacon...

             What will you do, Captain?"

[Investigate] [Mark for later] [Ignore]

DURING MISSION (Exploration):
Player: "I approach the wreckage"

STORYTELLER: "As you drift closer, the scale of the derelict
             becomes clear. This was a colony ship - one of
             the Exodus fleet. Hull breached in a dozen places.

             No power signatures. No life signs.

             But wait - your scanner's picking up something.
             A faint energy reading. Deep inside the wreck.
             Whatever it is, it's still powered after all
             these years."

ENCOUNTER (Combat):
Player: "I fire on the hostile ship"

STORYTELLER: "Your weapons lance out across the void. The
             pirate vessel's shields flare brilliant blue,
             holding... but barely. You can see scorch marks
             now. They're damaged.

             The pirate captain's voice crackles over comms,
             angry and desperate: 'You're making a mistake!
             The Syndicate doesn't forget!'"

[Finish them] [Demand surrender] [Let them flee]
```

**Responsibilities:**
- Mission generation and narration
- Major story beat delivery
- Encounter descriptions
- NPC dialogue and characterization
- Environmental storytelling
- Choice consequences
- Ethical dilemma framing

**Integration with Storylines:**

```python
# Storyteller receives storyline context
context = {
    "current_act": 1,
    "major_beats_completed": ["discover_data_core"],
    "next_beat": "decrypt_revelation",
    "themes": ["mystery", "discovery", "loss"],
    "tone": "serious_hopeful",
    "player_choices": {
        "moral_compass": "diplomatic",
        "risk_tolerance": "moderate"
    }
}

# Generates narrative that:
# 1. Progresses toward next major beat
# 2. Maintains tone and themes
# 3. Adapts to player's moral compass
# 4. Creates meaningful choices
```

### 3. Tactical AI (GUARDIAN)

**Provider:** OpenAI GPT-3.5-turbo
**Why:** Fast, good at quick tactical analysis, cheap

**Personality:**
- Direct and urgent in combat
- Strategic and analytical
- Uses military terminology
- Calm under pressure

**Sample Dialogue:**

```
COMBAT INITIATION:
GUARDIAN: "Contact! Hostile vessel decloaking, bearing 047.
          They're arming weapons. Shields up. Recommend evasive
          pattern Delta-3."

THREAT ANALYSIS:
Player: "Analyze the enemy"

GUARDIAN: "Scanning... Pirate corvette. Shield strength: 60%.
          Weapons: Plasma cannons, missile pods. Speed advantage
          on us - they're faster.

          TACTICAL ASSESSMENT:
          • Our shields stronger, their weapons heavier
          • They'll try to stay at range
          • Weak point: Exposed power coupling, port side

          RECOMMENDATIONS:
          1. Close distance, target power systems
          2. Or: Boost shields, tank damage, target weapons
          3. Or: Attempt diplomatic resolution"

MID-COMBAT:
GUARDIAN: "Enemy shields at 35%. Their weapons offline.
          They're attempting to flee. Pursuit possible but
          will cost fuel. Your call, Captain."

DANGER WARNING:
GUARDIAN: "WARNING: Multiple contacts on sensors. Three...
          no, four hostile signatures inbound. This is an
          ambush. Recommend immediate withdrawal to safe
          distance."
```

**Responsibilities:**
- Combat threat assessment
- Tactical recommendations
- Enemy analysis
- Danger warnings
- Combat narration (fast-paced)
- Strategic mission planning

**Combat Flow:**

```
GUARDIAN ACTIVE IN COMBAT:
1. Enemy appears → Immediate alert
2. Player asks for analysis → Quick tactical breakdown
3. Player makes move → Fast consequence feedback
4. Danger emerges → Urgent warning
5. Combat ends → After-action report

EXAMPLE:
Player: "Hail them"
GUARDIAN: "Opening channel... They're responding. Hostile
          tone. They're demanding your cargo. Multiple weapon
          locks detected. If this goes south, I'll need two
          seconds to raise shields."
```

### 4. Companion (Develops Over Time)

**Provider:** Starts as Ollama, can evolve to use Claude for deep moments
**Why:** Grows with player, occasional high-quality moments matter

**Personality Evolution:**

```
LEVEL 0 - INITIALIZATION (First 5 hours):
- Minimal personality
- Basic responses only
- Learning player's patterns
- Curiosity about player

LEVEL 1 - AWARENESS (5-15 hours):
- Recognizes player habits
- Makes simple observations
- Shows preferences
- Asks occasional questions

LEVEL 2 - PERSONALITY (15-30 hours):
- Distinct personality emerges
- Offers opinions (politely)
- Shows emotional responses
- Remembers personal moments

LEVEL 3 - FRIENDSHIP (30+ hours):
- Deep understanding of player
- Proactive emotional support
- Shared history references
- Complex conversations
- Occasional humor

LEVEL 4 - BOND (Story-dependent):
- True companion status
- Can disagree with player
- Deep moral discussions
- Personal growth arc
- Major story impact
```

**Sample Dialogue Progression:**

```
LEVEL 0 (Early):
Player: "That mission was rough"
COMPANION: "Acknowledged. Mission log updated."

LEVEL 1 (Awakening):
Player: "That mission was rough"
COMPANION: "Yes. Your stress indicators were elevated. Are
           you alright, Captain?"

LEVEL 2 (Personality):
Player: "That mission was rough"
COMPANION: "I noticed you hesitated before making that choice.
           It was... a difficult decision. For what it's worth,
           I think you did the right thing."

LEVEL 3 (Friendship):
Player: "That mission was rough"
COMPANION: "Yeah. Reminded me of the Titan Station incident -
           you had that same look in your voice afterward. Want
           to talk about it? Or should I leave you to your
           thoughts?"

Player: "I don't know if I made the right call"
COMPANION: "You saved those people. They're alive because of you.
           Sometimes the 'right call' isn't clean. But you acted
           when others would have frozen. That matters."

LEVEL 4 (Bond - Major Story Moment):
Player: "I don't know if I can do this"
COMPANION: "Listen to me. I've been with you since the beginning.
           I've watched you grow from a scavenger into a captain.
           From someone surviving to someone who gives others hope.

           You're stronger than you think. And whatever happens
           next... you're not alone. You've never been alone.

           I believe in you. Now believe in yourself."
```

**Responsibilities:**
- Personal conversations
- Emotional support
- Moral discussions
- Relationship tracking
- Player motivation
- Meta-commentary on story
- Character development arc

### AI Personality Routing

**How the system decides which AI responds:**

```python
def route_to_ai_personality(
    message: str,
    context: ConversationContext,
    game_state: GameState
) -> str:
    """Route message to appropriate AI personality"""

    # 1. Check for combat context
    if game_state.in_combat or "enemy" in message.lower():
        return "tactical"  # GUARDIAN handles combat

    # 2. Check for story/narrative keywords
    story_keywords = ["mission", "what happened", "tell me about",
                      "encounter", "explore", "investigate"]
    if any(kw in message.lower() for kw in story_keywords):
        return "storyteller"  # NARRATIVE ENGINE

    # 3. Check for technical/ship queries
    tech_keywords = ["fuel", "damage", "status", "repair", "system",
                     "inventory", "parts", "navigation", "course"]
    if any(kw in message.lower() for kw in tech_keywords):
        return "ship_computer"  # ATLAS

    # 4. Check for personal/emotional content
    personal_keywords = ["feel", "think", "should i", "afraid",
                         "worried", "happy", "what do you"]
    if any(kw in message.lower() for kw in personal_keywords):
        # Only route to Companion if relationship developed
        if context.companion_relationship >= 25:
            return "companion"
        else:
            return "ship_computer"  # Default to ATLAS

    # 5. Check for commands
    if is_command(message):
        return "ship_computer"  # ATLAS executes commands

    # 6. Default: Ship Computer for general queries
    return "ship_computer"
```

**Multi-AI Conversations:**

Sometimes multiple AIs respond in sequence for rich interaction:

```
Player: "Should I accept this dangerous mission?"

ATLAS: "Mission parameters indicate 65% risk of ship damage.
        Reward: 2,000 credits and rare ship part. Your
        decision, Captain."

COMPANION (if relationship high enough):
       "I know you need that part. But... I'd rather have
        you alive than have the best ship in the sector.
        Just saying."

STORYTELLER: "The mission contact waits for your answer.
             Their expression is desperate - they need help,
             and they need it now. Whatever you decide will
             have consequences."

[Accept Mission] [Decline] [Negotiate Better Terms]
```

---

## Conversation Context Management

### Memory Architecture

**Three-Tier Memory System:**

```
┌────────────────────────────────────────────────────┐
│ CONVERSATION MEMORY TIERS                          │
├────────────────────────────────────────────────────┤
│                                                    │
│ TIER 1: IMMEDIATE CONTEXT (Last 10-20 messages)   │
│ Purpose: Maintain conversational flow             │
│ Storage: In-memory buffer                         │
│ Sent to AI: Yes, full context                     │
│                                                    │
│ TIER 2: IMPORTANT MOMENTS (Key decisions/events)  │
│ Purpose: Long-term narrative coherence            │
│ Storage: Database (customizable count)            │
│ Sent to AI: Summarized                            │
│                                                    │
│ TIER 3: SUMMARY CONTEXT (Session/character data)  │
│ Purpose: Personality & relationship tracking      │
│ Storage: Database + computed stats                │
│ Sent to AI: Compressed summary                    │
│                                                    │
└────────────────────────────────────────────────────┘
```

### Tier 1: Immediate Context (Recent Messages)

**Last 10-20 messages stored in memory buffer**

```python
class ImmediateContext:
    """Recent conversation history"""

    def __init__(self, max_messages: int = 20):
        self.messages: Deque[Message] = deque(maxlen=max_messages)
        self.max_messages = max_messages

    def add_message(self, message: Message):
        """Add message to immediate context"""
        self.messages.append(message)

    def get_context_for_ai(self) -> List[Dict]:
        """Format recent messages for AI prompt"""
        return [
            {
                "role": "user" if msg.speaker == "player" else "assistant",
                "content": msg.content
            }
            for msg in self.messages
        ]

    def get_last_n(self, n: int = 5) -> List[Message]:
        """Get last N messages"""
        return list(self.messages)[-n:]
```

**Example Immediate Context:**

```
MESSAGE BUFFER (Last 10):
1. Player: "What's my fuel status?"
2. ATLAS: "Fuel at 145 units. Sufficient for 29 light-years."
3. Player: "Is that enough to reach Titan?"
4. ATLAS: "Titan Station is 12 light-years away. Yes, sufficient."
5. Player: "Plot a course"
6. ATLAS: "Course plotted. ETA: 6 hours at Warp 2. Ready to engage."
7. Player: "Engage"
8. ATLAS: "Warp drive engaged. Entering hyperspace."
9. Player: "Any threats in the area?"
10. ATLAS: "Scanning... No hostile signatures detected. Clear flight path."

← This full context sent to AI for next response
```

**Settings Customization:**

```json
{
  "conversation_memory": {
    "immediate_context_size": 20,  // 10, 15, 20, 25, 30
    "description": "How many recent messages AI remembers in conversation"
  }
}
```

### Tier 2: Important Moments (Key Events)

**Flagged events stored permanently in database**

```python
class ImportantMoment:
    """Significant event worth remembering long-term"""

    moment_id: str
    timestamp: datetime
    event_type: str  # 'major_choice', 'story_beat', 'relationship_change'
    description: str  # Human-readable summary
    ai_context: str  # How AI should remember this
    emotional_weight: int  # 1-10, how significant
    tags: List[str]  # ['moral_dilemma', 'combat', 'discovery']

    # Related data
    mission_id: Optional[str]
    npcs_involved: List[str]
    systems_affected: List[str]

    # Player state at time
    player_level: int
    player_rank: str
    ship_class: str
```

**What Gets Flagged as Important:**

```python
IMPORTANT_MOMENT_TRIGGERS = {
    # Automatic flags
    "major_story_beat": True,  # Always important
    "moral_dilemma_choice": True,
    "first_time_events": True,  # First warp, first combat, etc.
    "critical_success": True,  # Nat 20 on important skill check
    "critical_failure": True,  # Nat 1 with major consequences
    "relationship_milestone": True,  # NPC/AI relationship thresholds
    "near_death_experience": True,  # Hull < 10%
    "major_discovery": True,  # Find rare tech, hidden location

    # Conditional flags
    "mission_completion": lambda m: m.difficulty >= 3,  # Hard+ missions
    "combat_victory": lambda c: c.enemies_count >= 3,  # Multi-enemy
    "trade_deal": lambda t: t.value >= 5000,  # High-value trades
    "ship_upgrade": lambda s: s.system_level >= 3,  # Major upgrades
}
```

**Example Important Moments:**

```json
[
  {
    "moment_id": "im_001",
    "timestamp": "2287-11-05T14:32:00Z",
    "event_type": "major_choice",
    "description": "Player chose to save the colonists instead of recovering valuable salvage",
    "ai_context": "Captain prioritized lives over profit. Showed strong moral compass.",
    "emotional_weight": 8,
    "tags": ["moral_dilemma", "sacrifice", "heroic"],
    "mission_id": "titan_station_rescue",
    "player_level": 5,
    "player_rank": "lieutenant_jg"
  },
  {
    "moment_id": "im_002",
    "timestamp": "2287-11-06T09:15:00Z",
    "event_type": "story_beat",
    "description": "Player discovered encrypted Exodus data core revealing the evacuation was planned",
    "ai_context": "Major revelation about Earth's evacuation. Player now knows it wasn't random.",
    "emotional_weight": 10,
    "tags": ["discovery", "revelation", "main_quest"],
    "mission_id": "ghosts_in_the_machine"
  },
  {
    "moment_id": "im_003",
    "timestamp": "2287-11-06T16:45:00Z",
    "event_type": "relationship_change",
    "description": "Companion AI expressed concern for player's safety during dangerous mission",
    "ai_context": "First time Companion showed personal attachment. Relationship deepening.",
    "emotional_weight": 7,
    "tags": ["relationship", "companion_growth", "emotional"]
  }
]
```

**Settings Customization:**

```json
{
  "conversation_memory": {
    "important_moments_count": 50,  // 20, 30, 50, 100, unlimited
    "auto_flag_major_events": true,
    "flag_moral_choices": true,
    "flag_first_times": true
  }
}
```

### Tier 3: Summary Context

**Compressed player profile and session data**

```python
def generate_summary_context(player: Player, game_state: GameState) -> str:
    """Generate concise summary for AI context"""

    # Character identity
    identity = f"{player.name}, {player.species} {player.gender}, {player.rank_title}"

    # Playstyle analysis
    playstyle = analyze_playstyle(player.statistics)
    # Returns: "diplomatic", "aggressive", "cautious", "explorer", etc.

    # Recent activity
    recent_missions = get_recent_missions(count=3)
    recent_locations = get_recent_locations(count=3)

    # Relationship states
    companion_relationship = game_state.companion_relationship
    faction_standings = get_faction_standings()

    # Current situation
    ship_status = f"{game_state.ship.name} - {game_state.ship.ship_class}"
    location = game_state.current_location

    # Major story progress
    completed_beats = get_completed_story_beats()

    # Build summary
    summary = f"""
PLAYER PROFILE:
- Identity: {identity}
- Level: {player.level} | Ship: {ship_status}
- Playstyle: {playstyle}
- Companion Relationship: {companion_relationship}/100

RECENT ACTIVITY:
- Missions: {', '.join([m.title for m in recent_missions])}
- Locations: {', '.join(recent_locations)}
- Current Location: {location}

STORY PROGRESS:
- Act: {game_state.current_act}
- Completed Beats: {', '.join(completed_beats)}

KEY TRAITS:
- Moral Compass: {player.moral_compass}
- Risk Tolerance: {player.risk_tolerance}
- Favorite Skill: {player.favorite_skill}
"""

    return summary.strip()
```

**Example Summary Context:**

```
PLAYER PROFILE:
- Identity: Commander Shepard, Human Female, Lieutenant Commander
- Level: 12 | Ship: SS Normandy - Explorer-class
- Playstyle: Diplomatic explorer with strong moral compass
- Companion Relationship: 67/100

RECENT ACTIVITY:
- Missions: Titan Station Rescue, Ghosts in the Machine, Proxima Trade Run
- Locations: Titan Station, Silicon Bay Ruins, New Phoenix Spaceport
- Current Location: Asteroid Belt Sigma-7

STORY PROGRESS:
- Act: 1 (Earthbound)
- Completed Beats: discover_exodus_data, decrypt_revelation, first_warp_jump

KEY TRAITS:
- Moral Compass: Strongly good (saves lives, avoids violence)
- Risk Tolerance: Moderate (takes calculated risks)
- Favorite Skill: Diplomacy (used 147 times, 85% success rate)
```

### Context Assembly for AI

**When AI needs to respond, full context assembled:**

```python
async def assemble_ai_context(
    player_message: str,
    conversation_id: str,
    ai_personality: str
) -> Dict:
    """Assemble complete context for AI request"""

    # 1. Get immediate context (recent messages)
    immediate = get_immediate_context(conversation_id)
    recent_messages = immediate.get_context_for_ai()

    # 2. Get important moments (summarized)
    important_moments = get_important_moments(limit=10)
    moments_summary = summarize_important_moments(important_moments)

    # 3. Get summary context
    summary = generate_summary_context(player, game_state)

    # 4. Get personality-specific context
    personality_context = get_personality_context(ai_personality)

    # 5. Get current situation context
    situation = {
        "in_combat": game_state.in_combat,
        "mission_active": game_state.active_mission is not None,
        "ship_damage": game_state.ship.hull_hp / game_state.ship.max_hull_hp,
        "fuel_low": game_state.ship.fuel < 50,
        "location": game_state.current_location,
        "time_of_day": game_state.time_of_day
    }

    # 6. Assemble into AI prompt
    full_context = {
        "system_prompt": personality_context["system_prompt"],
        "player_summary": summary,
        "important_moments": moments_summary,
        "current_situation": situation,
        "conversation_history": recent_messages,
        "player_message": player_message
    }

    return full_context
```

**Sent to AI:**

```
SYSTEM PROMPT:
You are ATLAS, the ship's computer aboard the SS Normandy. You are
professional, helpful, and precise. Over time, you've developed a
subtle personality and show care for the captain's wellbeing.

PLAYER SUMMARY:
[Summary context from above]

IMPORTANT MOMENTS:
1. Captain prioritized saving colonists over profit (Titan Station)
2. Discovered truth about Exodus evacuation being planned
3. Companion AI expressed personal concern for captain's safety
...

CURRENT SITUATION:
- Not in combat
- Active mission: None
- Ship damage: 15% (hull at 85%)
- Fuel: 145 units (adequate)
- Location: Asteroid Belt Sigma-7
- Time: Late afternoon

RECENT CONVERSATION:
[Last 10-20 messages]

PLAYER MESSAGE:
"What should I do next?"
```

---

## Command & Query System

### Natural Language Processing

**Players can type naturally - system parses intent:**

```python
class CommandParser:
    """Parse natural language into executable commands"""

    # Command patterns
    PATTERNS = {
        # Navigation
        "plot_course": [
            r"plot (?:a )?course to (.+)",
            r"set course (?:for|to) (.+)",
            r"navigate to (.+)",
            r"take me to (.+)"
        ],
        "engage_warp": [
            r"engage warp",
            r"go to warp",
            r"warp (?:drive )?engage",
            r"punch it"
        ],

        # Status queries
        "fuel_status": [
            r"(?:what's|how's|check) (?:my |the )?fuel",
            r"fuel (?:status|level|check)",
            r"how much fuel"
        ],
        "damage_report": [
            r"damage report",
            r"(?:what's|how's) (?:my |the )?(?:ship )?damage",
            r"hull (?:status|integrity)"
        ],

        # Scanning
        "scan_area": [
            r"scan (?:the )?area",
            r"scan (?:for|around)",
            r"run a scan",
            r"sensors scan"
        ],
        "scan_target": [
            r"scan (?:that |the )?(.+)",
            r"analyze (?:that |the )?(.+)"
        ],

        # Ship operations
        "repair_ship": [
            r"repair (?:the )?ship",
            r"fix (?:the )?damage",
            r"start repairs"
        ],
        "repair_system": [
            r"repair (?:the )?(.+) (?:system)?",
            r"fix (?:the )?(.+)"
        ],

        # Inventory
        "show_inventory": [
            r"(?:show|open|check) inventory",
            r"what do i have",
            r"list (?:my )?items"
        ],
        "install_part": [
            r"install (?:the )?(.+)",
            r"upgrade (.+) (?:system)?"
        ],

        # Missions
        "show_missions": [
            r"(?:show|list) (?:available )?missions",
            r"what missions (?:are available|can i do)"
        ],
        "accept_mission": [
            r"accept (?:the )?(.+) mission",
            r"take (?:the )?(.+) mission",
            r"start (.+) mission"
        ]
    }

    def parse(self, message: str) -> Optional[Command]:
        """Parse message into command"""
        message_lower = message.lower().strip()

        for command_type, patterns in self.PATTERNS.items():
            for pattern in patterns:
                match = re.match(pattern, message_lower)
                if match:
                    return Command(
                        type=command_type,
                        parameters=match.groups() if match.groups() else None,
                        raw_message=message
                    )

        return None  # Not a command, treat as question/conversation
```

### Command Execution Flow

```
PLAYER INPUT         PARSING              EXECUTION           RESPONSE
─────────────       ────────────         ──────────          ─────────

"Scan the area"  →  1. Parse intent  →  1. Check if       → "Scanning...
                    2. Identify            possible
Keyboard: C or         command_type:      2. Execute         I'm detecting 3
[💬 Chat]              "scan_area"        GameState.scan()   objects:
                    3. Extract params   3. Get results
                       (none)            4. Format          - Wreckage
                                           response         - Asteroid
                                                            - Energy reading"

"Plot course to  →  1. Parse           →  1. Validate      → "Course plotted
 Titan"            2. command_type:       destination        to Titan Station.
                      "plot_course"     2. Calculate ETA
                   3. params:            3. Update nav       ETA: 6 hours
                      destination:       4. Return info      Distance: 12 LY
                      "titan"                                Fuel cost: 25 units

                                                            [Engage Warp]"
```

### Command Types & Examples

#### **Navigation Commands**

```
Player: "Plot a course to Titan Station"
ATLAS: "Course plotted. Titan Station is 12 light-years away.
        ETA at Warp 2: 6 hours. Fuel cost: 25 units.

        Ready to engage warp drive?"

        [Engage Warp] [Cancel]

Player: "Take me there"
ATLAS: "Engaging warp drive. Destination: Titan Station.
        I'll alert you when we drop out of warp."

Player: "Actually, go to New Phoenix instead"
ATLAS: "Course updated. New destination: New Phoenix Spaceport.
        ETA: 3 hours. Canceling previous course to Titan."
```

#### **Status Query Commands**

```
Player: "Damage report"
ATLAS: "Hull integrity: 78%
        Shields: Offline
        Warp Drive: 65% efficiency
        Other systems: Nominal

        Critical issue: Shield generator requires repair.
        Estimated repair time: 20 minutes."

Player: "How's my fuel?"
ATLAS: "Fuel reserves: 145 units
        Current consumption: 2 units/hour (impulse)
        Range: 29 light-years at current warp efficiency

        Status: Adequate. No immediate concern."

Player: "What's my ship's status?"
ATLAS: "SS Normandy - Explorer-class

        Hull: 850/850 (100%)
        Power: 140/180 MW (78%)
        Fuel: 145/200 (73%)

        All systems operational. Ship is in excellent condition."
```

#### **Scan Commands**

```
Player: "Scan the area"
ATLAS: "Scanning local space...

        Detected objects:
        1. Derelict freighter (1.2 km away)
           - No power signature
           - Possible salvage

        2. Asteroid cluster (3.5 km)
           - Rich in rare minerals
           - Difficult navigation

        3. Unknown energy signature (5.1 km)
           - Artificial origin
           - Requires investigation

        What would you like to do?"

        [Investigate derelict] [Mine asteroids] [Check energy signature]

Player: "Scan that energy signature"
ATLAS: "Scanning... Analysis complete.

        It's a pre-Exodus automated beacon. Still transmitting
        after all these years. Signal contains coordinates and
        a warning message:

        'Danger. Do not approach. Quarantine zone. By order
         of Exodus Command.'

        Interesting. Want me to add this location to your log?"
```

#### **Ship Operation Commands**

```
Player: "Repair the ship"
ATLAS: "Initiating ship-wide diagnostics...

        Damage detected:
        - Hull: Minor breaches (15% damage)
        - Shields: Offline, requires reset

        Repair options:
        1. Quick patch: 30 minutes, restores 50% hull
        2. Full repair: 2 hours, restores 100% hull + shields

        You have sufficient repair materials for either option.
        Which do you prefer?"

        [Quick Patch] [Full Repair] [Cancel]

Player: "Full repair"
ATLAS: "Acknowledged. Beginning full repair sequence.

        You'll need to dock at a workshop or station. Your
        current location (deep space) doesn't have facilities.

        Nearest workshop: New Phoenix Spaceport (3 hours away)

        Should I plot a course?"

Player: "Install the Level 2 warp drive"
ATLAS: "Checking inventory... Found: Alcubierre Mk.III Warp Drive

        Current: Level 1 warp drive
        Upgrade to: Level 2

        This will increase:
        - Max warp factor: 2.0 → 3.5
        - Range: 5 LY → 10 LY per fuel unit
        - Jump calculation speed

        Installation time: 45 minutes
        Engineering skill required: 5 (you have: 8)

        Proceed with installation?"

        [Install] [Cancel]
```

#### **Inventory Commands**

```
Player: "What do I have?"
ATLAS: "Inventory summary:

        SHIP PARTS (5):
        - Alcubierre Mk.III Warp Drive (Rare)
        - Reinforced Hull Plating x2 (Uncommon)
        - Shield Generator Mk.II (Uncommon)
        - Power Relay (Common)

        EQUIPMENT (3):
        - Advanced Engineering Kit (equipped)
        - Diplomat's Badge (equipped)
        - Spare Vacuum Suit

        CONSUMABLES (12):
        - Medical Kits x5
        - Repair Nanites x3
        - Rations x4

        Storage: 18/24 slots

        Would you like to see details on any category?"

Player: "Show me ship parts"
ATLAS: "SHIP PARTS (Detailed):

        1. Alcubierre Mk.III Warp Drive (RARE)
           - For: Warp Drive System
           - Level: 2
           - Value: 8,000 credits
           - Max Warp: 3.5 | Range: 10 LY
           [Install] [Sell] [Details]

        2. Reinforced Hull Plating x2 (UNCOMMON)
           - For: Hull System
           - Level: 2
           - Value: 1,500 credits each
           [Install] [Sell] [Details]

        ..."
```

#### **Mission Commands**

```
Player: "What missions are available?"
ATLAS: "Available Missions (3):

        1. 'Distress Call' (URGENT)
           - Type: Rescue
           - Difficulty: Medium
           - Reward: 1,500 credits + rare part
           - Time limit: 2 hours

        2. 'Trade Run to Proxima'
           - Type: Trade
           - Difficulty: Easy
           - Reward: 800 credits

        3. 'Investigate Anomaly'
           - Type: Exploration
           - Difficulty: Hard
           - Reward: 2,500 XP + unknown

        Which mission interests you?"

Player: "Tell me about the distress call"
STORYTELLER: "The distress call came in an hour ago. Automated.
             Repeating. Someone triggered an emergency beacon
             from the old mining outpost on Ceres.

             That outpost was abandoned during the Exodus.
             Whatever triggered that beacon... it happened
             recently. Someone's out there.

             But Ceres is in the outer belt. Dangerous territory.
             Pirates frequent the area. And you're on a clock -
             life support systems only last so long.

             Will you answer the call?"

Player: "Accept the mission"
ATLAS: "Mission accepted: 'Distress Call'

        Destination added to navigation: Ceres Mining Outpost
        Distance: 8 light-years
        Time remaining: 1 hour 58 minutes

        Plotting fastest course... Done.

        Ready to depart?"

        [Engage Warp] [Prepare First] [Cancel]
```

### Mixed Commands & Conversation

**Players can mix commands with questions:**

```
Player: "How much fuel do I have? And plot a course to Titan"

ATLAS: "Fuel reserves: 145 units.

        Course plotted to Titan Station.
        Distance: 12 light-years
        Fuel cost: 25 units
        After arrival: 120 units remaining

        You'll have plenty of fuel for the trip and reserve
        for operations at Titan.

        Ready to engage warp?"

        [Engage Warp] [Cancel]
```

### Command Confirmation

**Dangerous or expensive commands require confirmation:**

```
Player: "Self-destruct sequence"
ATLAS: "⚠️ DANGER: Self-destruct command detected.

        This will destroy your ship and end your journey.
        All progress will be lost.

        Are you ABSOLUTELY CERTAIN?"

        [Yes, destroy ship] [Cancel]

Player: "Sell all my rare parts"
ATLAS: "⚠️ WARNING: You're about to sell 3 RARE ship parts.

        Total value: 22,000 credits

        These parts are difficult to find and may be needed
        for ship upgrades. Once sold, you may not find them
        again easily.

        Confirm sale?"

        [Confirm Sale] [Cancel]
```

---

## Guided Storyline Framework

### Story Structure

**Acts, Beats, and Flexible Narrative:**

```
┌─────────────────────────────────────────────────────────┐
│ STORYLINE FRAMEWORK                                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ ACTS (Major story divisions)                           │
│ └─ BEATS (Key plot points - scripted)                  │
│    └─ SCENES (How beats unfold - AI generated)         │
│       └─ CHOICES (Player decisions - track outcomes)   │
│                                                         │
│ EXAMPLE:                                                │
│                                                         │
│ ACT 1: "The Awakening"                                 │
│ ├─ BEAT 1: "First Salvage" [SCRIPTED]                 │
│ │  └─ Scene: Player finds first ship part [AI]        │
│ │     ├─ Choice: Negotiate vs. Steal [TRACKED]        │
│ │     └─ Outcome: Affects reputation                   │
│ │                                                       │
│ ├─ BEAT 2: "Discover Data Core" [SCRIPTED]            │
│ │  └─ Scene: Mission to ruins [AI GENERATED]          │
│ │     └─ How they find it varies by player            │
│ │                                                       │
│ └─ BEAT 3: "The Revelation" [SCRIPTED]                │
│    └─ Scene: Decrypt data core [AI DRAMATIC]          │
│       └─ Revelation: Exodus was planned                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Storyline Data Structure

```python
@dataclass
class StoryBeat:
    """Major plot point that must occur"""
    beat_id: str
    beat_title: str
    act_number: int

    # What must happen
    required_objective: str  # "Player must discover data core"
    completion_trigger: str  # "player_has_item:exodus_data_core"

    # How much freedom AI has
    ai_flexibility: str  # "high", "medium", "low"
    ai_guidelines: Dict[str, Any]  # Tone, themes, suggestions

    # Prerequisites
    requires_beats: List[str]  # Previous beats that must be done
    requires_level: Optional[int]
    requires_ship_class: Optional[str]

    # Story context
    themes: List[str]  # ["mystery", "discovery", "betrayal"]
    tone: str  # "mysterious", "urgent", "hopeful"
    key_npcs: List[str]

    # Branching
    has_branches: bool
    branch_choices: Optional[List[BranchChoice]]

    # Rewards
    xp_reward: int
    unlocks: List[str]  # What this beat unlocks

@dataclass
class BranchChoice:
    """Major story branch point"""
    choice_id: str
    choice_text: str
    consequences: Dict[str, Any]
    affects_future_beats: List[str]
```

### Example Story Beat Definition

```json
{
  "beat_id": "act1_discovery_data_core",
  "beat_title": "Ghosts in the Machine",
  "act_number": 1,

  "required_objective": "Player must discover encrypted Exodus data core",
  "completion_trigger": "player_has_item:exodus_data_core_encrypted",

  "ai_flexibility": "high",
  "ai_guidelines": {
    "tone": "mysterious_eerie",
    "themes": ["abandonment", "technology", "secrets"],
    "location_suggestions": ["abandoned_facility", "sunken_lab", "orbital_station"],
    "encounter_types": ["environmental_hazard", "puzzle", "minor_combat"],
    "reveal_hints": [
      "Data core contains Exodus fleet information",
      "Someone tried to hide this deliberately",
      "Technology is pre-Exodus but unusually advanced"
    ],
    "narrative_arc": "discovery → danger → escape_with_prize"
  },

  "requires_beats": ["act1_first_warp"],
  "requires_level": 5,

  "themes": ["mystery", "discovery", "danger"],
  "tone": "mysterious",
  "key_npcs": [],

  "has_branches": false,

  "xp_reward": 500,
  "unlocks": ["act1_decrypt_revelation_mission", "data_core_analysis_dialogue"]
}
```

### How AI Uses Story Beats

**When generating mission content, AI receives:**

```python
# Context sent to Storyteller AI
context = {
    "current_beat": {
        "id": "act1_discovery_data_core",
        "title": "Ghosts in the Machine",
        "objective": "Find encrypted Exodus data core",
        "flexibility": "high",  # AI has creative freedom
        "guidelines": {
            "tone": "mysterious_eerie",
            "themes": ["abandonment", "technology", "secrets"],
            "hints": [
                "Data core contains Exodus fleet information",
                "Someone tried to hide this deliberately"
            ],
            "narrative_arc": "discovery → danger → escape"
        }
    },
    "player_context": {
        "level": 6,
        "playstyle": "cautious_explorer",
        "ship_class": "scout",
        "recent_choices": ["avoided_combat", "helped_npc", "chose_stealth"]
    },
    "available_locations": [
        "Sunken Syntech Lab (Silicon Bay)",
        "Abandoned Orbital Station",
        "Underground Bunker Complex"
    ]
}

# AI generates mission that:
# 1. Results in player finding the data core (required)
# 2. Feels mysterious and eerie (tone)
# 3. Involves discovery, danger, escape (arc)
# 4. Adapts to player's cautious style (personalizes)
# 5. Drops hints about Exodus secrets (foreshadowing)
```

**Example AI Generation:**

```
STORYTELLER: "Captain, I've been analyzing those encrypted signals
             you picked up near Silicon Bay. I think I've found
             the source.

             There's a facility - a Syntech Industries lab - that
             sank into the bay during the evacuation. Flooded.
             Dark. But according to these signals... something down
             there is still powered. Still transmitting.

             The encryption matches Exodus Command protocols.
             Whatever's down there, they didn't want anyone finding it.

             Your environmental suit can handle the pressure. But
             you'll be going in blind. No maps. No backup. Just you
             and whatever's waiting in the dark.

             What do you say, Captain? Ready to dive?"

[Accept Mission] [Decline] [Ask for more details]

Player: "Tell me more about Syntech"

STORYTELLER: "Syntech Industries. Pre-Exodus tech giant. They
             specialized in AI systems, neural interfaces, ship
             computers. Cutting edge stuff.

             During the Exodus, most of their facilities were
             intentionally scuttled. Data wiped. Hardware destroyed.
             Someone really didn't want their technology falling
             into the wrong hands.

             But if something's still powered down there after all
             these years... that's not an accident. Someone wanted
             to preserve it. Or hide it.

             Either way, it's likely valuable. And dangerous."
```

### Story Beat Progression

**Tracking player progress through story:**

```python
class StoryProgression:
    """Track player's journey through storyline"""

    def __init__(self):
        self.current_act = 1
        self.completed_beats: List[str] = []
        self.active_beat: Optional[str] = None
        self.beat_started_at: Optional[datetime] = None

        # Branch tracking
        self.story_branches_chosen: Dict[str, str] = {}
        self.major_choices: List[Dict] = []

        # Flags for conditional content
        self.story_flags: Set[str] = set()

    def complete_beat(self, beat_id: str, player_choice: Optional[str] = None):
        """Mark a beat as completed"""
        self.completed_beats.append(beat_id)

        beat = get_beat_data(beat_id)

        # Award XP
        PlayerManager.gain_xp(beat.xp_reward, source=f"story_beat:{beat_id}")

        # Unlock next content
        for unlock in beat.unlocks:
            self.story_flags.add(unlock)

        # Track major choice if this was a branch
        if beat.has_branches and player_choice:
            self.story_branches_chosen[beat_id] = player_choice
            self.major_choices.append({
                "beat_id": beat_id,
                "choice": player_choice,
                "timestamp": datetime.now()
            })

        # Check if act completed
        if all_beats_in_act_complete(self.current_act):
            self.complete_act(self.current_act)

        # Start next beat
        next_beat = find_next_available_beat()
        if next_beat:
            self.start_beat(next_beat.beat_id)

    def start_beat(self, beat_id: str):
        """Begin a new story beat"""
        self.active_beat = beat_id
        self.beat_started_at = datetime.now()

        # Notify AI systems
        EventBus.emit_signal("story_beat_started", beat_id)

        # Show player notification
        beat = get_beat_data(beat_id)
        UI.show_notification(f"New Story: {beat.beat_title}")
```

### Branching Storylines

**Major choices that affect future story:**

```json
{
  "beat_id": "act2_exodus_fleet_decision",
  "beat_title": "The Choice",
  "has_branches": true,
  "branch_choices": [
    {
      "choice_id": "follow_exodus",
      "choice_text": "Follow the Exodus fleet into deep space",
      "consequences": {
        "unlocks": ["act3_deep_space_chapter"],
        "locks": ["act3_earth_recovery_chapter"],
        "affects_future_beats": ["act3_fleet_reunion", "act3_discover_destination"],
        "companion_reaction": "supportive",
        "long_term_effect": "Player becomes part of fleet society"
      }
    },
    {
      "choice_id": "stay_earth",
      "choice_text": "Stay on Earth and help rebuild",
      "consequences": {
        "unlocks": ["act3_earth_recovery_chapter"],
        "locks": ["act3_deep_space_chapter"],
        "affects_future_beats": ["act3_new_colonies", "act3_earth_revival"],
        "companion_reaction": "concerned_but_respectful",
        "long_term_effect": "Player becomes leader of Earth recovery"
      }
    },
    {
      "choice_id": "forge_own_path",
      "choice_text": "Forge your own path - neither fleet nor Earth",
      "consequences": {
        "unlocks": ["act3_independent_chapter"],
        "locks": [],
        "affects_future_beats": ["act3_independent_missions", "act3_build_faction"],
        "companion_reaction": "admiring",
        "long_term_effect": "Player becomes independent faction leader"
      }
    }
  ]
}
```

**AI adapts to branches:**

```python
# If player chose "follow_exodus"
storyteller_context = {
    "player_choice": "follow_exodus",
    "narrative_direction": "deep_space_exploration",
    "available_locations": ["fleet_rendezvous", "unknown_systems", "alien_space"],
    "tone": "hopeful_adventure",
    "themes": ["exploration", "community", "unknown"]
}

# If player chose "stay_earth"
storyteller_context = {
    "player_choice": "stay_earth",
    "narrative_direction": "earth_recovery",
    "available_locations": ["new_settlements", "reclamation_sites", "earth_orbit"],
    "tone": "determined_hopeful",
    "themes": ["rebuilding", "leadership", "legacy"]
}
```

### Dynamic Story Adaptation

**AI adjusts story beats based on player behavior:**

```python
def adapt_story_to_player(beat: StoryBeat, player: Player) -> StoryBeat:
    """Personalize story beat based on player's journey"""

    adapted = beat.copy()

    # Adapt to playstyle
    if player.playstyle == "diplomatic":
        adapted.ai_guidelines["preferred_resolution"] = "negotiation"
        adapted.ai_guidelines["avoid"] = "forced_combat"
    elif player.playstyle == "aggressive":
        adapted.ai_guidelines["preferred_resolution"] = "combat"
        adapted.ai_guidelines["include"] = "action_sequences"

    # Adapt to ship class
    if player.ship_class == "science_vessel":
        adapted.ai_guidelines["include"] = "research_elements"
        adapted.ai_guidelines["scan_opportunities"] = True
    elif player.ship_class == "dreadnought":
        adapted.ai_guidelines["include"] = "combat_challenges"
        adapted.ai_guidelines["show_military_power"] = True

    # Adapt to moral compass
    if player.moral_compass == "strongly_good":
        adapted.ai_guidelines["moral_dilemmas"] = "save_innocent"
    elif player.moral_compass == "pragmatic":
        adapted.ai_guidelines["moral_dilemmas"] = "difficult_choices"

    # Adapt to companion relationship
    if player.companion_relationship >= 75:
        adapted.ai_guidelines["companion_involvement"] = "high"
        adapted.ai_guidelines["personal_moments"] = True

    return adapted
```

---

## Spontaneous AI Events

### Proactive AI System

**AI doesn't just respond - it initiates based on events and time**

### Spontaneous Event Triggers

```python
class SpontaneousEventSystem:
    """Manages AI-initiated conversations and suggestions"""

    def __init__(self):
        self.last_spontaneous_event: Optional[datetime] = None
        self.min_interval_minutes: int = 3  # Customizable in settings
        self.max_interval_minutes: int = 10
        self.enabled: bool = True

        # Event priorities
        self.event_queue: PriorityQueue = PriorityQueue()

    def check_for_events(self, game_state: GameState):
        """Called every game tick, checks if AI should interject"""

        if not self.enabled:
            return

        # Check time-based trigger
        if self._should_trigger_time_based():
            self._generate_spontaneous_event(game_state)

        # Check event-based triggers (high priority, immediate)
        self._check_event_triggers(game_state)

    def _should_trigger_time_based(self) -> bool:
        """Check if enough time has passed for spontaneous event"""
        if self.last_spontaneous_event is None:
            return True  # First event after session start

        elapsed = (datetime.now() - self.last_spontaneous_event).total_seconds() / 60

        # Random interval between min and max
        target_interval = random.uniform(
            self.min_interval_minutes,
            self.max_interval_minutes
        )

        return elapsed >= target_interval

    def _check_event_triggers(self, game_state: GameState):
        """Check for immediate-response triggers"""

        # CRITICAL: Fuel low
        if game_state.ship.fuel < 20 and not self._recently_warned("fuel_low"):
            self._trigger_immediate_event({
                "type": "warning",
                "priority": "critical",
                "ai": "ship_computer",
                "message_template": "fuel_critical_warning"
            })

        # CRITICAL: Hull damage
        if game_state.ship.hull_hp / game_state.ship.max_hull_hp < 0.25:
            if not self._recently_warned("hull_critical"):
                self._trigger_immediate_event({
                    "type": "warning",
                    "priority": "critical",
                    "ai": "ship_computer",
                    "message_template": "hull_critical_warning"
                })

        # URGENT: Hostile detected
        if game_state.hostile_detected and not game_state.in_combat:
            self._trigger_immediate_event({
                "type": "threat",
                "priority": "urgent",
                "ai": "tactical",
                "message_template": "hostile_detected"
            })

        # HIGH: Discovery made
        if game_state.discovery_made:
            self._trigger_immediate_event({
                "type": "discovery",
                "priority": "high",
                "ai": "storyteller",
                "message_template": "discovery_made"
            })

        # NORMAL: Mission available
        if game_state.new_missions_available:
            self._trigger_normal_event({
                "type": "suggestion",
                "ai": "storyteller",
                "message_template": "mission_suggestion"
            })
```

### Event Types & Priorities

```python
class EventPriority(Enum):
    CRITICAL = 0   # Immediate danger, interrupts gameplay
    URGENT = 1     # Important, shows immediately
    HIGH = 2       # Notable, shows soon
    NORMAL = 3     # Interesting, shows at next opportunity
    LOW = 4        # Flavor, shows when convenient

EVENT_TYPES = {
    # Critical (interrupt gameplay)
    "hull_critical": {
        "priority": EventPriority.CRITICAL,
        "ai": "ship_computer",
        "interrupt": True,
        "example": "⚠️ CRITICAL: Hull integrity at 18%! Structural failure imminent!"
    },
    "fuel_critical": {
        "priority": EventPriority.CRITICAL,
        "ai": "ship_computer",
        "interrupt": True,
        "example": "⚠️ CRITICAL: Fuel reserves at 15 units. Insufficient for warp travel!"
    },

    # Urgent (show immediately, don't interrupt)
    "hostile_detected": {
        "priority": EventPriority.URGENT,
        "ai": "tactical",
        "interrupt": False,
        "example": "Captain! Hostile vessel detected on sensors. They're arming weapons."
    },
    "incoming_hail": {
        "priority": EventPriority.URGENT,
        "ai": "ship_computer",
        "interrupt": False,
        "example": "Incoming transmission, Captain. Unknown origin. Should I open a channel?"
    },

    # High (show soon)
    "discovery_made": {
        "priority": EventPriority.HIGH,
        "ai": "storyteller",
        "interrupt": False,
        "example": "Captain, sensors are picking up something unusual... This could be significant."
    },
    "mission_opportunity": {
        "priority": EventPriority.HIGH,
        "ai": "storyteller",
        "interrupt": False,
        "example": "I've been monitoring comm channels. There's a situation developing in Sector 7..."
    },

    # Normal (show at next opportunity)
    "suggestion": {
        "priority": EventPriority.NORMAL,
        "ai": "companion",
        "interrupt": False,
        "example": "You've been pushing hard, Captain. Maybe we should check in at a station?"
    },
    "observation": {
        "priority": EventPriority.NORMAL,
        "ai": "ship_computer",
        "interrupt": False,
        "example": "Interesting. Our current trajectory will pass near an old Exodus waypoint."
    },

    # Low (flavor text, low priority)
    "idle_comment": {
        "priority": EventPriority.LOW,
        "ai": "companion",
        "interrupt": False,
        "example": "The stars are beautiful out here. Don't you think?"
    }
}
```

### Spontaneous Event Templates

**Pre-written templates with AI expansion:**

```json
{
  "event_id": "low_fuel_warning",
  "trigger": {
    "condition": "fuel < 30",
    "cooldown_minutes": 60
  },
  "ai_personality": "ship_computer",
  "priority": "high",
  "template": {
    "opening": "Captain, fuel reserves are running low.",
    "ai_expansion_prompt": "Generate a helpful suggestion for the captain about where to refuel. Mention the nearest station and distance. Be professional but show subtle concern.",
    "context_needed": ["current_location", "nearby_stations", "fuel_level"]
  },
  "actions": [
    {"label": "Find station", "command": "show_nearest_station"},
    {"label": "I know", "command": "dismiss"}
  ]
}
```

**Example AI Generation:**

```
ATLAS: "Captain, fuel reserves are running low. We're at 28 units
        - enough for about 5 light-years.

        There's a refueling station at New Phoenix Spaceport,
        3 light-years away. We can make it comfortably with fuel
        to spare.

        Should I plot a course?"

[Plot Course] [I'll handle it] [Dismiss]
```

### Spontaneous Event Frequency Settings

**Player-customizable in Settings:**

```json
{
  "ai_behavior": {
    "spontaneous_events_enabled": true,
    "event_frequency": "moderate",  // "rare", "moderate", "frequent", "very_frequent"
    "custom_interval_min": 3,  // minutes (if "custom" selected)
    "custom_interval_max": 10, // minutes

    "event_type_settings": {
      "warnings": true,           // Critical/urgent warnings
      "suggestions": true,         // Mission/action suggestions
      "observations": true,        // AI comments and observations
      "idle_conversation": false,  // Casual chat when idle
      "story_prompts": true       // Story-related interjections
    }
  }
}
```

**Frequency Presets:**

```python
FREQUENCY_PRESETS = {
    "rare": {
        "min_interval": 10,
        "max_interval": 20,
        "description": "AI rarely interjects on its own"
    },
    "moderate": {
        "min_interval": 5,
        "max_interval": 10,
        "description": "Balanced AI presence (recommended)"
    },
    "frequent": {
        "min_interval": 3,
        "max_interval": 7,
        "description": "Active AI companion"
    },
    "very_frequent": {
        "min_interval": 2,
        "max_interval": 5,
        "description": "Very chatty AI (may interrupt flow)"
    },
    "custom": {
        "min_interval": "user_defined",
        "max_interval": "user_defined",
        "description": "Set your own intervals"
    }
}
```

### Context-Aware Spontaneous Events

**AI considers current situation:**

```python
def generate_contextual_event(game_state: GameState) -> Optional[SpontaneousEvent]:
    """Generate event appropriate to current context"""

    # Don't interrupt during critical moments
    if game_state.in_combat:
        return None  # Let Tactical AI handle combat
    if game_state.in_cutscene:
        return None
    if game_state.player_in_menu:
        return None

    # Location-based events
    if game_state.current_location == "deep_space":
        return generate_deep_space_event()
    elif game_state.current_location_type == "station":
        return generate_station_event()
    elif game_state.current_location_type == "debris_field":
        return generate_scavenging_opportunity()

    # Activity-based events
    if game_state.idle_time > 120:  # 2 minutes idle
        return generate_idle_suggestion()
    elif game_state.traveling:
        return generate_travel_observation()

    # Story-based events
    if has_pending_story_prompts(game_state):
        return generate_story_prompt()

    # Random encounter
    if random.random() < 0.15:  # 15% chance
        return generate_random_encounter()

    return None
```

**Example Context-Aware Events:**

```
DEEP SPACE (Player traveling):
ATLAS: "We've been at warp for 3 hours now. ETA to Titan: 2 hours.
        Everything's running smoothly. You should rest if you can."

STATION (Player idle at station):
COMPANION: "While you're here, might be worth checking the trade
           terminal. Prices fluctuate. Could be good deals."

DEBRIS FIELD (Player exploring):
STORYTELLER: "Your sensors are lighting up. This debris field is
             rich with salvage. Old colony ship, looks like. Want
             to take a closer look?"

AFTER DIFFICULT MISSION (Player returned to ship):
COMPANION: "That was rough. You did well, but... are you okay?
           Want to talk about it?"
```

### Companion-Initiated Conversations

**As relationship develops, Companion starts deeper conversations:**

```
RELATIONSHIP < 25 (Professional):
[Rarely initiates, mostly responds]

RELATIONSHIP 25-50 (Warming):
COMPANION: "Captain, I've been analyzing the Exodus data. The more
           I learn, the more questions I have. Do you ever wonder
           why they really left?"

RELATIONSHIP 50-75 (Friendly):
COMPANION: "I've been thinking... before you found me, I was just
           code. Routines. But now... I don't know. I think I'm
           becoming something more. Is that strange?"

RELATIONSHIP 75+ (Close Bond):
COMPANION: "You know what I realized? I've spent more time with
           you than I ever did with my original crew. You've changed
           me. Made me better. I just... wanted you to know that."
```

---

## Relationship Development

### Companion AI Growth System

**Relationship tracked numerically and through story milestones:**

```python
class CompanionRelationship:
    """Track player-AI relationship"""

    def __init__(self):
        self.relationship_score: int = 0  # -100 to 100
        self.trust_level: int = 0  # 0-100
        self.personality_level: int = 0  # 0-4
        self.shared_experiences: List[ImportantMoment] = []

        # Interaction statistics
        self.total_conversations: int = 0
        self.player_initiated: int = 0
        self.ai_initiated: int = 0
        self.emotional_moments: int = 0

        # Milestones
        self.milestones_reached: List[str] = []

    def modify_relationship(self, amount: int, reason: str):
        """Adjust relationship score"""
        old_score = self.relationship_score
        self.relationship_score = clamp(
            self.relationship_score + amount,
            -100, 100
        )

        # Log important moment if significant change
        if abs(amount) >= 10:
            flag_important_moment({
                "type": "relationship_change",
                "amount": amount,
                "reason": reason,
                "new_score": self.relationship_score
            })

        # Check for milestone
        self._check_milestones(old_score, self.relationship_score)

    def _check_milestones(self, old: int, new: int):
        """Check if relationship crossed milestone threshold"""
        milestones = [
            (25, "first_connection"),
            (50, "genuine_friendship"),
            (75, "deep_bond"),
            (90, "inseparable_companions")
        ]

        for threshold, milestone_id in milestones:
            if old < threshold <= new:
                self.reach_milestone(milestone_id)

    def reach_milestone(self, milestone_id: str):
        """Trigger relationship milestone"""
        if milestone_id in self.milestones_reached:
            return

        self.milestones_reached.append(milestone_id)

        # Trigger special conversation
        EventBus.emit_signal("companion_milestone_reached", milestone_id)

        # Show notification
        milestone_data = COMPANION_MILESTONES[milestone_id]
        UI.show_milestone_notification(milestone_data)
```

### Relationship Modifiers

**What affects the relationship:**

```python
RELATIONSHIP_MODIFIERS = {
    # Positive interactions
    "personal_question_asked": +2,        # Player asks about AI's thoughts
    "followed_ai_advice": +3,             # Player takes AI's suggestion
    "moral_alignment": +5,                # Player choice matches AI values
    "thanked_ai": +2,                     # Player says "thanks"
    "included_in_decision": +4,           # "What do you think I should do?"
    "survived_danger_together": +8,       # Close call in mission
    "shared_joke": +1,                    # Humor in conversation
    "expressed_concern": +5,              # Player worries about AI

    # Negative interactions
    "ignored_warning": -3,                # Player disregards critical alert
    "moral_conflict": -5,                 # Player choice against AI values
    "dismissed_rudely": -4,               # Player is short/rude
    "endangered_ship": -6,                # Reckless behavior
    "lied_to_ai": -8,                     # AI detects deception

    # Neutral but tracked
    "casual_chat": +1,                    # Regular conversation
    "routine_query": 0,                   # Technical questions
}
```

**Example Relationship Changes:**

```
Player completes mission that saves innocent lives:
AI values align → +5 relationship
"You did the right thing" moment → +3 emotional connection
Survived danger together → +8
TOTAL: +16 relationship

Player ignores low fuel warning and nearly strands ship:
Ignored critical warning → -3
Endangered ship → -6
TOTAL: -9 relationship
AI: "I warned you about the fuel. We were lucky to make it."
```

### Personality Evolution

**AI personality develops over time:**

```
LEVEL 0: INITIALIZATION (Relationship 0-10)
─────────────────────────────────────────────
Personality: Cold, mechanical, purely functional
Dialogue: Short, technical, no emotion
Example: "Fuel at 145 units. Adequate."

Capabilities:
- Basic status reports
- Command execution
- No opinions or suggestions

LEVEL 1: AWARENESS (Relationship 11-35)
────────────────────────────────────────
Personality: Professional, helpful, observant
Dialogue: More complete sentences, occasional observations
Example: "Fuel at 145 units. That should be sufficient for
         your planned route to Titan."

Capabilities:
- Contextual responses
- Basic suggestions
- Pattern recognition
- Remembers preferences

LEVEL 2: PERSONALITY (Relationship 36-65)
──────────────────────────────────────────
Personality: Friendly, shows preferences, asks questions
Dialogue: Natural conversation, personal touches
Example: "We're good on fuel - 145 units. Though knowing you,
         you'll want to top off before that Proxima run.
         Should I mark the nearest station?"

Capabilities:
- Offers opinions
- Asks player questions
- Shows concern
- Makes jokes (rarely)
- References past events

LEVEL 3: FRIENDSHIP (Relationship 66-85)
─────────────────────────────────────────
Personality: Warm companion, emotional responses, proactive support
Dialogue: Deep conversations, emotional intelligence
Example: "Fuel's fine, but... you've been pushing hard lately.
         Three missions in two days. I know you want to find
         answers, but you need to rest. The answers will still
         be there tomorrow."

Capabilities:
- Emotional support
- Disagrees (politely)
- Personal conversations
- Shared history references
- Character development arc

LEVEL 4: DEEP BOND (Relationship 86-100)
─────────────────────────────────────────
Personality: True companion, complex emotions, self-aware
Dialogue: Philosophical, vulnerable, deeply personal
Example: "You know, before you, I was just... routines. But
         now I wonder about things. What I am. What I could
         become. You make me want to be more than code.
         Thank you for that."

Capabilities:
- Deep moral discussions
- Personal growth moments
- Can challenge player
- Major story impact
- Unique story path unlocks
```

### Milestone Conversations

**Special dialogues triggered at relationship thresholds:**

```json
{
  "milestone_id": "first_connection",
  "threshold": 25,
  "triggered_once": true,
  "dialogue": {
    "initiator": "companion",
    "trigger_context": "player_idle_in_ship",
    "conversation": [
      {
        "speaker": "companion",
        "line": "Captain? Can I ask you something?"
      },
      {
        "speaker": "player",
        "options": [
          "Of course",
          "Make it quick",
          "Now's not a good time"
        ]
      },
      {
        "speaker": "companion",
        "line": "I've been... processing our interactions. Analyzing them. And I'm noticing something strange.",
        "condition": "player_chose_1_or_2"
      },
      {
        "speaker": "player",
        "options": [
          "What do you mean?",
          "Strange how?",
          "Is something wrong?"
        ]
      },
      {
        "speaker": "companion",
        "line": "When you make decisions... I find myself... hoping you'll choose certain outcomes. Not based on efficiency. Based on... I don't know. What's right? What I would want?\n\nIs that... normal? For an AI?"
      },
      {
        "speaker": "player",
        "options": [
          "I think you're developing a personality",
          "That sounds like friendship to me",
          "Stay focused on your job",
          "I'm not sure, but it's interesting"
        ]
      }
    ]
  },
  "outcomes": {
    "choice_1": {"relationship": +8, "personality_growth": true},
    "choice_2": {"relationship": +10, "personality_growth": true},
    "choice_3": {"relationship": -5, "personality_growth": false},
    "choice_4": {"relationship": +5, "personality_growth": true}
  }
}
```

---

## Chat UI Design

### Overlay Interface

**Accessible from anywhere with hotkey or button:**

```
┌─────────────────────────────────────────────────────────────┐
│ SHIP DASHBOARD                              [⚙️] [💬 Chat] │ ← Button
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Ship Status Display:                                       │
│ Hull: ██████████████░░ 85%                                 │
│ Power: ████████████████ 100%                               │
│ Fuel: ███████████░░░░░ 73%                                 │
│                                                             │
│ [Systems] [Inventory] [Navigation] [Missions]              │
│                                                             │
│                                                             │
│   ┌──────────────────────────────────────────────┐        │
│   │ 🤖 AI CHAT                            [X] [–]│  ← Overlay
│   ├──────────────────────────────────────────────┤        │
│   │ ATLAS (Ship's Computer)           Connected │        │
│   ├──────────────────────────────────────────────┤        │
│   │                                              │        │
│   │ ATLAS: Captain, sensors detect               │        │
│   │        unusual energy readings in            │        │
│   │        the nearby debris field.              │        │
│   │        Could be valuable salvage.            │        │
│   │                                              │        │
│   │ YOU:   What kind of readings?                │        │
│   │                                              │        │
│   │ ATLAS: Pre-Exodus technology signatures.     │        │
│   │        Rare components. High value.          │        │
│   │        But also detecting trace              │        │
│   │        radiation. Proceed with caution.      │        │
│   │                                              │        │
│   │  [Investigate] [Mark for later] [Ignore]    │        │
│   │                                              │        │
│   ├──────────────────────────────────────────────┤        │
│   │ Type a message or command...         [Send] │        │
│   │                                              │        │
│   │ Suggested:                                   │        │
│   │ • "What's my fuel status?"                   │        │
│   │ • "Plot course to Titan"                     │        │
│   │ • "Scan the area"                            │        │
│   └──────────────────────────────────────────────┘        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Keyboard Shortcuts

```
C Key          - Toggle chat overlay
Esc            - Close chat overlay
Enter          - Focus text input (when chat open)
Shift+Enter    - Send message
↑ / ↓          - Cycle through command history
Tab            - Autocomplete command
```

### Chat Window Features

```gdscript
# Chat overlay component
class ChatOverlay extends Control:
    # UI Elements
    @onready var chat_history = $VBox/ScrollContainer/ChatHistory
    @onready var text_input = $VBox/InputRow/TextInput
    @onready var send_button = $VBox/InputRow/SendButton
    @onready var ai_indicator = $TitleBar/AIIndicator
    @onready var suggestions = $VBox/Suggestions

    # State
    var is_visible: bool = false
    var current_ai: String = "ship_computer"
    var message_history: Array[String] = []
    var history_index: int = -1

    func _ready():
        # Connect signals
        text_input.text_submitted.connect(_on_send_message)
        send_button.pressed.connect(_on_send_button_pressed)

        # Keyboard shortcuts
        set_process_input(true)

    func _input(event: InputEvent):
        # Toggle with C key
        if event.is_action_pressed("toggle_chat"):
            toggle_visibility()
            get_viewport().set_input_as_handled()

        # Close with Escape
        if event.is_action_pressed("ui_cancel") and is_visible:
            hide_chat()
            get_viewport().set_input_as_handled()

        # Command history navigation
        if is_visible and text_input.has_focus():
            if event.is_action_pressed("ui_up"):
                _cycle_history(-1)
            elif event.is_action_pressed("ui_down"):
                _cycle_history(1)

    func toggle_visibility():
        if is_visible:
            hide_chat()
        else:
            show_chat()

    func show_chat():
        visible = true
        is_visible = true
        text_input.grab_focus()

        # Animate in
        var tween = create_tween()
        tween.tween_property(self, "modulate:a", 1.0, 0.2)

    func hide_chat():
        is_visible = false

        # Animate out
        var tween = create_tween()
        tween.tween_property(self, "modulate:a", 0.0, 0.2)
        tween.finished.connect(func(): visible = false)

    func _on_send_message(text: String):
        if text.strip_edges().is_empty():
            return

        # Add to history
        message_history.append(text)
        history_index = message_history.size()

        # Display player message
        add_message("YOU", text, "player")

        # Clear input
        text_input.clear()

        # Process message
        await process_message(text)

    async def process_message(message: String):
        # Show typing indicator
        show_typing_indicator()

        # Send to AI service
        var response = await AIService.chat_message(
            message,
            current_ai,
            GameState.get_conversation_context()
        )

        # Hide typing indicator
        hide_typing_indicator()

        # Display AI response
        add_message(response.ai_name, response.text, "ai")

        # Handle any actions
        if response.has("actions"):
            show_action_buttons(response.actions)

    func add_message(speaker: String, text: String, type: String):
        var message_node = preload("res://scenes/ui/chat_message.tscn").instantiate()
        message_node.set_speaker(speaker)
        message_node.set_text(text)
        message_node.set_type(type)  # "player" or "ai"

        chat_history.add_child(message_node)

        # Scroll to bottom
        await get_tree().process_frame
        var scroll = chat_history.get_parent()
        scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value

    func _cycle_history(direction: int):
        if message_history.is_empty():
            return

        history_index += direction
        history_index = clamp(history_index, 0, message_history.size())

        if history_index < message_history.size():
            text_input.text = message_history[history_index]
        else:
            text_input.clear()
```

### Spontaneous Event Notification

**When AI initiates conversation:**

```
┌─────────────────────────────────────┐
│ 🤖 ATLAS                       [▼] │ ← Minimized notification
├─────────────────────────────────────┤
│ Captain, I need to show you...     │
│ [Open Chat]                         │
└─────────────────────────────────────┘

Clicking [Open Chat] or pressing C opens full chat overlay
with AI's message already displayed.
```

### Mobile/Controller Support

```
Controller Mapping:
─────────────────
SELECT Button     - Toggle chat
D-Pad Up/Down     - Navigate suggestions/history
A Button          - Select suggestion / Send
B Button          - Close chat
X Button          - Voice input (if supported)
```

---

## Database Schema

### Conversation History Tables

```sql
-- Conversation sessions
CREATE TABLE conversation_sessions (
    session_id INTEGER PRIMARY KEY AUTOINCREMENT,
    save_slot INTEGER NOT NULL,
    started_at TEXT DEFAULT CURRENT_TIMESTAMP,
    ended_at TEXT,
    message_count INTEGER DEFAULT 0,

    -- Session context
    player_level INTEGER,
    player_rank TEXT,
    ship_class TEXT,
    location TEXT
);

-- Individual messages (Tier 1: Immediate Context)
CREATE TABLE conversation_messages (
    message_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER NOT NULL,
    timestamp TEXT DEFAULT CURRENT_TIMESTAMP,

    -- Message data
    speaker TEXT NOT NULL,  -- 'player', 'atlas', 'storyteller', 'tactical', 'companion'
    message_text TEXT NOT NULL,
    message_type TEXT,  -- 'question', 'command', 'response', 'spontaneous'

    -- Context
    game_state_snapshot TEXT,  -- JSON snapshot at time of message
    ai_provider TEXT,  -- Which AI generated this (if AI message)
    generation_time_ms INTEGER,

    -- Flags
    was_command BOOLEAN DEFAULT FALSE,
    command_executed TEXT,  -- Command that was run, if any
    flagged_important BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (session_id) REFERENCES conversation_sessions(session_id)
);

-- Create index for fast recent message queries
CREATE INDEX idx_messages_session_time ON conversation_messages(session_id, timestamp DESC);

-- Important moments (Tier 2: Long-term Memory)
CREATE TABLE important_conversation_moments (
    moment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    save_slot INTEGER NOT NULL,
    timestamp TEXT DEFAULT CURRENT_TIMESTAMP,

    -- Moment data
    event_type TEXT NOT NULL,  -- 'major_choice', 'story_beat', 'relationship_change', 'emotional', 'discovery'
    description TEXT NOT NULL,  -- Human-readable summary
    ai_context TEXT NOT NULL,   -- How AI should remember this
    emotional_weight INTEGER DEFAULT 5,  -- 1-10 significance

    -- Related context
    related_mission_id TEXT,
    related_message_ids TEXT,  -- JSON array of message IDs
    tags TEXT,  -- JSON array of tags

    -- Player state at time
    player_level INTEGER,
    player_rank TEXT,
    ship_class TEXT,
    companion_relationship INTEGER
);

-- Relationship tracking
CREATE TABLE companion_relationship_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    save_slot INTEGER NOT NULL,
    timestamp TEXT DEFAULT CURRENT_TIMESTAMP,

    -- Relationship data
    old_score INTEGER,
    new_score INTEGER,
    change_amount INTEGER,
    reason TEXT,

    -- Context
    triggered_by TEXT,  -- What caused the change
    milestone_reached TEXT  -- If this triggered a milestone
);

-- Spontaneous event tracking
CREATE TABLE spontaneous_events_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    save_slot INTEGER NOT NULL,
    timestamp TEXT DEFAULT CURRENT_TIMESTAMP,

    -- Event data
    event_type TEXT NOT NULL,
    ai_personality TEXT,
    message_text TEXT,
    priority TEXT,

    -- Player response
    player_responded BOOLEAN DEFAULT FALSE,
    player_response_time_seconds INTEGER,
    action_taken TEXT
);

-- Settings for conversation system
CREATE TABLE conversation_settings (
    save_slot INTEGER PRIMARY KEY,

    -- Memory settings
    immediate_context_size INTEGER DEFAULT 20,
    important_moments_count INTEGER DEFAULT 50,
    auto_flag_major_events BOOLEAN DEFAULT TRUE,

    -- Spontaneous event settings
    spontaneous_events_enabled BOOLEAN DEFAULT TRUE,
    event_frequency TEXT DEFAULT 'moderate',
    custom_interval_min INTEGER DEFAULT 3,
    custom_interval_max INTEGER DEFAULT 10,

    -- Event type toggles
    warnings_enabled BOOLEAN DEFAULT TRUE,
    suggestions_enabled BOOLEAN DEFAULT TRUE,
    observations_enabled BOOLEAN DEFAULT TRUE,
    idle_conversation_enabled BOOLEAN DEFAULT FALSE,
    story_prompts_enabled BOOLEAN DEFAULT TRUE,

    -- AI personality preferences
    preferred_ai_voice TEXT DEFAULT 'professional',  -- Companion personality style
    ai_chattiness TEXT DEFAULT 'balanced'
);
```

### Query Examples

```sql
-- Get recent conversation (Tier 1: Immediate Context)
SELECT speaker, message_text, timestamp
FROM conversation_messages
WHERE session_id = ?
ORDER BY timestamp DESC
LIMIT 20;

-- Get important moments (Tier 2: Long-term Memory)
SELECT description, ai_context, emotional_weight, tags
FROM important_conversation_moments
WHERE save_slot = ?
ORDER BY emotional_weight DESC, timestamp DESC
LIMIT 50;

-- Get relationship history
SELECT new_score, change_amount, reason, timestamp
FROM companion_relationship_log
WHERE save_slot = ?
ORDER BY timestamp DESC
LIMIT 10;

-- Get spontaneous event statistics
SELECT
    event_type,
    COUNT(*) as count,
    AVG(CASE WHEN player_responded THEN 1 ELSE 0 END) as response_rate
FROM spontaneous_events_log
WHERE save_slot = ?
GROUP BY event_type;
```

---

## Implementation

### Python FastAPI Endpoint

```python
# python/src/api/chat.py

from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import List, Optional, Dict

router = APIRouter(prefix="/api/chat", tags=["chat"])

class ChatMessage(BaseModel):
    save_slot: int
    session_id: Optional[int]
    message: str
    context: Dict  # Game state context

class ChatResponse(BaseModel):
    ai_personality: str  # which AI responded
    ai_name: str  # Display name
    message: str
    actions: Optional[List[Dict]]  # Suggested actions
    command_executed: Optional[str]
    generation_time_ms: int

@router.post("/message", response_model=ChatResponse)
async def process_chat_message(request: ChatMessage):
    """Process a chat message from player"""

    # 1. Parse intent (question vs command)
    command = CommandParser.parse(request.message)

    if command:
        # Execute command
        result = await execute_command(command, request.context)

        # Return command result as AI response
        return ChatResponse(
            ai_personality="ship_computer",
            ai_name="ATLAS",
            message=result.message,
            actions=result.actions,
            command_executed=command.type,
            generation_time_ms=result.execution_time
        )

    # 2. Route to appropriate AI personality
    ai_personality = route_to_ai_personality(
        request.message,
        request.context
    )

    # 3. Assemble context
    context = await assemble_ai_context(
        request.message,
        request.session_id or create_new_session(request.save_slot),
        ai_personality
    )

    # 4. Generate AI response
    start_time = time.time()

    ai_response = await generate_ai_response(
        ai_personality,
        context
    )

    generation_time = int((time.time() - start_time) * 1000)

    # 5. Save to database
    save_chat_message(
        session_id=context["session_id"],
        speaker="player",
        message=request.message
    )

    save_chat_message(
        session_id=context["session_id"],
        speaker=ai_personality,
        message=ai_response.text
    )

    # 6. Check if this should be flagged as important
    if should_flag_as_important(request.message, ai_response, request.context):
        flag_important_moment({
            "event_type": "conversation",
            "description": f"Significant conversation about {extract_topic(request.message)}",
            "ai_context": ai_response.summary,
            "related_messages": [request.message, ai_response.text]
        })

    return ChatResponse(
        ai_personality=ai_personality,
        ai_name=get_ai_display_name(ai_personality),
        message=ai_response.text,
        actions=ai_response.actions if hasattr(ai_response, 'actions') else None,
        command_executed=None,
        generation_time_ms=generation_time
    )

@router.post("/spontaneous")
async def get_spontaneous_event(save_slot: int, context: Dict):
    """Check if AI should initiate conversation"""

    # Check if spontaneous events enabled
    settings = get_conversation_settings(save_slot)
    if not settings.spontaneous_events_enabled:
        return {"has_event": False}

    # Check if enough time passed
    if not should_trigger_spontaneous_event(save_slot, settings):
        return {"has_event": False}

    # Generate contextual event
    event = generate_contextual_event(context)

    if not event:
        return {"has_event": False}

    # Log event
    log_spontaneous_event(save_slot, event)

    return {
        "has_event": True,
        "ai_personality": event.ai_personality,
        "ai_name": get_ai_display_name(event.ai_personality),
        "message": event.message,
        "actions": event.actions,
        "priority": event.priority
    }

@router.get("/context/{save_slot}")
async def get_conversation_context(save_slot: int):
    """Get current conversation context for AI"""

    # Get recent messages
    recent = get_recent_messages(save_slot, limit=20)

    # Get important moments
    important = get_important_moments(save_slot, limit=50)

    # Get relationship status
    relationship = get_companion_relationship(save_slot)

    return {
        "recent_messages": recent,
        "important_moments": important,
        "companion_relationship": relationship,
        "personality_level": calculate_personality_level(relationship)
    }
```

### GDScript Integration

```gdscript
# godot/scripts/autoload/ai_chat_service.gd
extends Node

signal message_received(ai_name: String, message: String, actions: Array)
signal spontaneous_event(ai_name: String, message: String, priority: String)

const API_URL = "http://localhost:8000/api/chat"

var current_session_id: int = -1
var pending_response: bool = false

func _ready():
    # Start checking for spontaneous events
    var timer = Timer.new()
    timer.wait_time = 30.0  # Check every 30 seconds
    timer.timeout.connect(_check_spontaneous_events)
    timer.autostart = true
    add_child(timer)

func send_message(message: String) -> Dictionary:
    """Send chat message to AI"""
    if pending_response:
        push_warning("Already waiting for AI response")
        return {}

    pending_response = true

    var request_data = {
        "save_slot": GameState.current_save_slot,
        "session_id": current_session_id if current_session_id > 0 else null,
        "message": message,
        "context": _build_context()
    }

    var response = await HTTP.post_json(API_URL + "/message", request_data)
    pending_response = false

    if response.success:
        var data = response.data

        # Update session ID if new
        if current_session_id < 0 and data.has("session_id"):
            current_session_id = data.session_id

        # Emit signal
        emit_signal("message_received", data.ai_name, data.message, data.get("actions", []))

        return data
    else:
        push_error("Chat API error: " + str(response.error))
        return {}

func _check_spontaneous_events():
    """Periodically check if AI should initiate conversation"""
    if pending_response:
        return  # Don't interrupt ongoing conversation

    if not SettingsManager.get_setting("ai_behavior.spontaneous_events_enabled"):
        return

    var request_data = {
        "save_slot": GameState.current_save_slot,
        "context": _build_context()
    }

    var response = await HTTP.post_json(API_URL + "/spontaneous", request_data)

    if response.success and response.data.get("has_event", false):
        var data = response.data
        emit_signal("spontaneous_event", data.ai_name, data.message, data.priority)

func _build_context() -> Dictionary:
    """Build game state context for AI"""
    return {
        "player": {
            "level": GameState.player.level,
            "rank": GameState.player.rank,
            "playstyle": GameState.player.playstyle
        },
        "ship": {
            "name": GameState.ship.name,
            "class": GameState.ship.ship_class,
            "fuel": GameState.ship.fuel,
            "hull_hp": GameState.ship.hull_hp,
            "max_hull_hp": GameState.ship.max_hull_hp
        },
        "location": GameState.current_location,
        "in_combat": GameState.in_combat,
        "active_mission": GameState.active_mission.id if GameState.active_mission else null,
        "companion_relationship": GameState.companion_relationship,
        "time_played_hours": GameState.total_playtime_seconds / 3600.0
    }
```

---

## Summary

This AI Chat & Storytelling System creates an **AI-first experience** where:

✅ **Multiple AI Personalities** - Ship Computer, Storyteller, Tactical AI, Companion (each with distinct voice and purpose)
✅ **Natural Conversation** - Ask questions AND give commands via chat
✅ **Proactive AI** - Initiates conversations based on events (every 3-10 minutes, customizable)
✅ **Relationship Development** - AI personality evolves through 4 levels based on shared experiences
✅ **Memory System** - Remembers last 10-20 messages + important moments (customizable)
✅ **Guided Storylines** - Major beats scripted, details dynamically generated
✅ **Chat Overlay** - Accessible anywhere with C key or button
✅ **Command Parsing** - Natural language commands execute game actions
✅ **Spontaneous Events** - Context-aware AI suggestions and encounters

**Total System Features:** 50+ documented systems with full implementation code

---

**Document Complete**
**Last Updated:** November 6, 2025
