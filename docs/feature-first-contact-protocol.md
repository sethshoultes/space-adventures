# First Contact Protocol System

**Priority:** Post-MVP (Phase 2)
**Phase:** Phase 2, Week 2-4
**Complexity:** High
**AI Integration:** Very High

## Overview

The First Contact Protocol System is the cornerstone of Phase 2 space exploration gameplay. When players encounter alien species, they engage in structured first contact scenarios inspired by Star Trek's thoughtful approach to meeting new civilizations. This system creates memorable diplomatic moments, meaningful choices, and lasting consequences through AI-generated alien cultures and dynamic relationship building.

## Core Concept

**Structured First Contact:**
1. **Detection** - Sensors detect alien signals/ships
2. **Analysis** - Computer Core analyzes communication attempts
3. **Translation** - Communications system attempts universal translation
4. **First Dialogue** - Initial exchange following protocol
5. **Cultural Learning** - Discover customs, values, taboos
6. **Relationship Formation** - Choices build or damage relations
7. **Long-term Consequences** - Species remembers you

**Prime Directive Dilemmas:**
- Do you help less advanced species?
- Do you share technology?
- Do you interfere in conflicts?
- Do you reveal humanity's situation?

## Design Principles

1. **Star Trek Authenticity** - Captures TNG's diplomatic approach
2. **Meaningful Choices** - Cultural mistakes have real consequences
3. **Dynamic Cultures** - AI generates unique, consistent species
4. **Long-term Relationships** - Choices echo across the game
5. **Learn and Adapt** - Build cultural knowledge database
6. **Ethical Dilemmas** - No easy answers

## Game Design

### Alien Species Framework

Each species has:

```gdscript
{
  "species_id": "species_001",
  "name": "Veltharian",
  "homeworld": "Velthara Prime",
  "first_contact_location": "Theta Sector",
  "first_contact_day": 67,

  "biology": {
    "appearance": "Tall, crystalline-skinned bipeds",
    "lifespan": 200,
    "environmental_needs": "High radiation, low gravity"
  },

  "culture": {
    "government": "Collective Council",
    "values": ["knowledge", "patience", "collective good"],
    "taboos": ["deception", "waste", "violence"],
    "communication_style": "formal, thoughtful, speaks in third person",
    "decision_making": "consensus-based, slow"
  },

  "technology": {
    "level": "advanced",  # primitive, developing, equal, advanced, far_advanced
    "specialties": ["energy manipulation", "sensors"],
    "ftl_capable": true
  },

  "disposition": {
    "initial_attitude": "curious",  # hostile, cautious, neutral, curious, friendly
    "relationship_value": 0,  # -100 to 100
    "relationship_status": "unknown",  # hostile, unfriendly, neutral, friendly, allied
    "trust": 0,  # 0 to 100
    "respect": 0  # 0 to 100
  },

  "history_with_player": {
    "total_encounters": 0,
    "positive_interactions": 0,
    "negative_interactions": 0,
    "cultural_mistakes": 0,
    "gifts_exchanged": 0,
    "promises_kept": 0,
    "promises_broken": 0,
    "major_events": []
  },

  "knowledge_unlocked": {
    "basic_info": true,
    "cultural_customs": false,
    "history": false,
    "technology": false,
    "star_charts": false,
    "exodus_knowledge": false  # Do they know about human exodus?
  },

  "trade": {
    "willing_to_trade": false,
    "desired_resources": [],
    "offered_resources": []
  },

  "unique_traits": [
    "Communicates through harmonic resonance",
    "Values patience above all else",
    "Considers time differently (thinks in centuries)"
  ]
}
```

### First Contact Stages

#### Stage 1: Detection
```
╔══════════════════════════════════════════════════════════════╗
║ SENSORS ALERT                                                ║
╠══════════════════════════════════════════════════════════════╣
║ Unknown energy signature detected in Theta Sector.          ║
║                                                              ║
║ Ship AI: "Captain, I'm reading a vessel of non-human        ║
║          design. It's broadcasting what appears to be        ║
║          a communication attempt, but I can't decode it     ║
║          yet. What are your orders?"                         ║
║                                                              ║
║ Choices:                                                     ║
║ A) Approach cautiously, shields up                          ║
║ B) Attempt communication immediately                        ║
║ C) Observe from distance, gather data                       ║
║ D) Leave the area (avoid contact)                           ║
║                                                              ║
║ Required: Communications Level 2+, Sensors Level 2+         ║
╚══════════════════════════════════════════════════════════════╝
```

**Choice Consequences:**
- **Approach with shields:** Species notes defensive posture (-5 relationship)
- **Immediate communication:** Shows openness (+5 relationship)
- **Observe from distance:** Diplomatic but cautious (neutral)
- **Leave:** Avoid first contact entirely (may not encounter again)

#### Stage 2: Universal Translation
```
╔══════════════════════════════════════════════════════════════╗
║ COMMUNICATIONS - Translation in Progress                    ║
╠══════════════════════════════════════════════════════════════╣
║ Computer Core analyzing transmission...                     ║
║                                                              ║
║ Translation Quality: 65% (Communications Level 3)           ║
║                                                              ║
║ Partial Translation:                                        ║
║ "...greetings... [unknown] ...peace... [unknown] ...share   ║
║  knowledge..."                                               ║
║                                                              ║
║ Ship AI: "I can establish basic communication, but there's  ║
║          significant room for misunderstanding. Higher      ║
║          Communications system level would help."           ║
║                                                              ║
║ [Attempt Communication] [Upgrade Comms First] [Abort]       ║
╚══════════════════════════════════════════════════════════════╝
```

**Translation Quality by Communications Level:**
- **Level 1:** 40% - Many misunderstandings likely
- **Level 2:** 60% - Basic communication possible
- **Level 3:** 80% - Good communication
- **Level 4:** 95% - Excellent communication
- **Level 5:** 99% - Near-perfect translation

**Risk of Low Translation:**
- Cultural mistakes more likely
- Offensive statements possible
- Misunderstood intentions
- Diplomatic incidents

#### Stage 3: First Dialogue
```
╔══════════════════════════════════════════════════════════════╗
║ FIRST CONTACT - Species: [Unknown]                          ║
╠══════════════════════════════════════════════════════════════╣
║ Alien: "This one greets you, traveler. You are unknown to  ║
║        this one's collective. From where do you journey?"   ║
║                                                              ║
║ [Translation: 80% accurate]                                  ║
║                                                              ║
║ How do you respond?                                          ║
║                                                              ║
║ A) "I am Captain [Name] of the vessel [Ship]. We come in  ║
║     peace from Earth, seeking knowledge and friendship."    ║
║     [Diplomatic, full disclosure]                           ║
║                                                              ║
║ B) "We are explorers. Who are you, and what do you want?"  ║
║     [Direct, cautious]                                       ║
║                                                              ║
║ C) "Greetings. We are new to this region of space."        ║
║     [Vague, protective]                                      ║
║                                                              ║
║ D) "This one greets your collective. Knowledge-sharing      ║
║     brings harmony." [Mimic their speech pattern]           ║
║     [Cultural adaptation - Diplomacy check]                 ║
║                                                              ║
║ [Consult Ship AI] [Consult Crew]                           ║
╚══════════════════════════════════════════════════════════════╝
```

**Outcome Factors:**
- Player's Diplomacy skill
- Crew diplomacy skills
- Ship AI advice (if Level 3+)
- Choice alignment with species' values
- Species' initial disposition

#### Stage 4: Cultural Learning
After successful first contact, learn about the species:

```
╔══════════════════════════════════════════════════════════════╗
║ CULTURAL DATABASE - Veltharian                              ║
╠══════════════════════════════════════════════════════════════╣
║ Basic Information: [UNLOCKED]                               ║
║ • Crystalline-skinned bipeds                                ║
║ • High-radiation environment natives                        ║
║ • FTL-capable, advanced technology                          ║
║                                                              ║
║ Cultural Customs: [LOCKED - Requires more interaction]      ║
║ • ???                                                        ║
║                                                              ║
║ History: [LOCKED]                                           ║
║ Technology: [LOCKED]                                        ║
║ Star Charts: [LOCKED]                                       ║
║                                                              ║
║ KNOWN CUSTOMS:                                               ║
║ ✓ Speak in third person (shows respect for collective)     ║
║ ✓ Value patience and thoughtful responses                   ║
║                                                              ║
║ KNOWN TABOOS:                                                ║
║ ⚠ Avoid deception (highly offensive)                       ║
║                                                              ║
║ Relationship: Curious (+15)                                 ║
║ Trust: Low (25/100)                                         ║
║ Respect: Moderate (40/100)                                  ║
╚══════════════════════════════════════════════════════════════╝
```

**Knowledge Unlocking:**
- **Basic Info:** Automatic after first contact
- **Cultural Customs:** Learn through successful interactions
- **History:** Requires friendly relationship (50+)
- **Technology:** Requires allied status (75+)
- **Star Charts:** Trade/alliance benefit
- **Exodus Knowledge:** Some species may know about humanity's exodus

### Cultural Customs System

Each species has 3-5 important customs/taboos:

**Example: Veltharian Customs**

1. **Third Person Speech** (Shows respect for collective)
   - If player mimics: +10 respect
   - If player uses "I" excessively: Slight concern

2. **Thoughtful Pauses** (Rushing shows disrespect)
   - If player waits for them to finish: +5 respect
   - If player interrupts or rushes: -10 respect

3. **Gift of Knowledge** (Most valued exchange)
   - If player shares information: +15 relationship
   - If player withholds when asked: -10 relationship

**Example: K'vari Customs (Different Species)**

1. **Strength Display** (Show capability, earn respect)
   - If player demonstrates ship strength: +10 respect
   - If player appears weak: -10 respect

2. **Direct Communication** (Flowery language = weakness)
   - If player speaks directly: +5 relationship
   - If player uses diplomatic language: -5 respect

3. **Challenge Acceptance** (Refusing = cowardice)
   - If player accepts challenges: +20 respect
   - If player declines: -15 respect, possible hostility

### First Contact Missions

**Mission Types:**

**1. Initial Contact**
- First meeting with species
- Establish communication
- Learn basic cultural info
- Form initial relationship

**2. Cultural Exchange**
- Deep dive into species culture
- Share human culture
- Build understanding
- Unlock trade/cooperation

**3. Diplomatic Crisis**
- Cultural misunderstanding occurs
- Player must repair relationship
- High stakes, permanent consequences
- Tests understanding of species

**4. Alliance Formation**
- Species offers formal alliance
- Requires high relationship (75+)
- Grants major benefits (technology, star charts, safe harbor)
- Creates long-term ally

**5. Prime Directive Dilemma**
- Less advanced species needs help
- Player must decide: help or observe
- Violating Prime Directive has consequences
- Moral complexity, no "right" answer

**Example Mission: "The Question of Interference"**

```
╔══════════════════════════════════════════════════════════════╗
║ MISSION: The Question of Interference                       ║
╠══════════════════════════════════════════════════════════════╣
║ You've discovered the Torvan, a pre-warp species facing    ║
║ extinction from an approaching asteroid. They lack the      ║
║ technology to detect or stop it.                            ║
║                                                              ║
║ Dr. Chen: "We could easily deflect the asteroid. It would  ║
║           save millions of lives."                          ║
║                                                              ║
║ Ship AI: "But that would violate the Prime Directive -     ║
║          revealing advanced technology to a pre-warp        ║
║          civilization. The Federation had good reasons      ║
║          for that rule."                                     ║
║                                                              ║
║ Marcus: "Since when do we follow Federation rules? They    ║
║         left us behind."                                    ║
║                                                              ║
║ What do you do?                                              ║
║                                                              ║
║ A) Deflect the asteroid covertly (save them, violate       ║
║    Prime Directive)                                          ║
║    • Consequences: ???                                       ║
║                                                              ║
║ B) Contact them, offer help openly (violate Prime          ║
║    Directive, but honestly)                                  ║
║    • Consequences: Alter their development                  ║
║                                                              ║
║ C) Observe and allow natural events (follow Prime          ║
║    Directive)                                                ║
║    • Consequences: Millions die, you carry that weight      ║
║                                                              ║
║ D) Anonymous warning (give them a chance without direct    ║
║    contact)                                                  ║
║    • Consequences: Uncertain success, middle path           ║
║                                                              ║
║ [Consult Crew] [Consult Ship AI] [Cultural Database]       ║
╚══════════════════════════════════════════════════════════════╝
```

**Consequences:**

**Choice A (Covert Help):**
- Torvan survive, never know about you
- Ship AI questions your ethics
- Crew divided on whether it was right
- Later encounter: Advanced species notices your interference, angry

**Choice B (Open Contact):**
- Torvan survive, worship you as gods (uncomfortable)
- Drastically alter their development path
- Later missions: Deal with consequences of uplifted species
- Some crew approve (Chen), others concerned (AI)

**Choice C (Prime Directive):**
- Torvan go extinct
- Heavy emotional toll on crew (-20 morale)
- Ship AI approves logically but struggles with emotions
- Later encounter: Find Torvan ruins, question your choice
- Some advanced species respect your restraint

**Choice D (Anonymous Warning):**
- 60% chance Torvan figure it out and survive
- If they survive: Grateful but confused
- Middle ground, least certain
- Crew has mixed feelings

### Relationship Mechanics

**Relationship Value:** -100 (war) to +100 (close ally)

**Relationship Stages:**
- **-100 to -50:** Hostile (will attack on sight)
- **-49 to -20:** Unfriendly (avoid contact, may threaten)
- **-19 to +19:** Neutral (cautious, transactional)
- **+20 to +49:** Friendly (willing to help, trade)
- **+50 to +74:** Allied (share information, assistance)
- **+75 to +100:** Close Ally (full cooperation, technology sharing)

**Relationship Changes:**

**Positive Actions:**
- Successful diplomatic exchange: +5 to +10
- Respecting cultural customs: +5 to +15
- Keeping promises: +10
- Sharing knowledge: +10 to +20
- Providing assistance: +15 to +25
- Defending them from threats: +20 to +30

**Negative Actions:**
- Cultural mistakes (minor): -5
- Cultural taboos (major): -15 to -30
- Breaking promises: -20
- Deception discovered: -25
- Aggression: -30 to -50
- Attacking them: -60 to -100 (war)

**Trust & Respect:**
Separate from relationship value:

- **Trust:** Built through consistency, honesty, promise-keeping
  - Required for technology sharing
  - Required for strategic information

- **Respect:** Earned through capability, wisdom, cultural understanding
  - Required for alliances
  - Required for certain trade deals

### AI-Generated Species

**Species Generation Endpoint:**

```python
@router.post("/api/first_contact/generate_species")
async def generate_alien_species(request: SpeciesGenerationRequest):
    """
    Generate a unique alien species with:
    - Biology and appearance
    - Culture, values, taboos
    - Government and society
    - Technology level
    - Communication style
    - Initial disposition
    """
```

**Generation Prompt Template:**

```
You are creating an alien species for a Star Trek-inspired space exploration game.

REQUIREMENTS:
- Original, creative species (not from Star Trek canon)
- Internally consistent culture and biology
- Clear values and taboos
- Unique communication style or custom
- Appropriate technology level for story

CONTEXT:
Player is exploring {sector_name} sector.
Player's ship classification: {ship_class}
Story phase: {early/mid/late game}

TECHNOLOGY LEVEL: {primitive/developing/equal/advanced/far_advanced}

TONE:
- Serious sci-fi (Star Trek TNG style)
- Thoughtful, not cliché
- Cultural depth, not stereotypes
- Interesting moral complexity

Generate an alien species with:

1. BASIC INFO
   - Species name
   - Homeworld name
   - Appearance (2-3 sentences)
   - Biology highlights (lifespan, environmental needs, unique traits)

2. CULTURE
   - Government type
   - Core values (3-5)
   - Major taboos (2-4)
   - Communication style
   - Decision-making approach
   - Unique cultural practice

3. TECHNOLOGY
   - Overall level
   - Specialties (what they're good at)
   - Notable achievements
   - FTL capability

4. DISPOSITION
   - Initial attitude toward strangers (and why)
   - What they value in other species
   - What they distrust

5. UNIQUE HOOK
   - One memorable, unique aspect of this species
   - Something that makes them stand out

Return JSON format matching SpeciesData schema.
```

**Example Generated Species:**

**The Lumina:**
- **Biology:** Bioluminescent aquatic beings who evolved in deep ocean trenches
- **Culture:** Value silence and observation; consider speech crude
- **Communication:** Bioluminescent patterns + minimal vocalization
- **Unique Hook:** "Speak" through changing light patterns on their skin
- **Taboo:** Loud noises are physically painful and deeply offensive
- **Technology:** Advanced biotechnology, living ships

**The Thane Collective:**
- **Biology:** Hive-minded insectoid species
- **Culture:** Individual identity subordinate to collective good
- **Communication:** Pheromones + verbal (translated to language)
- **Unique Hook:** Decisions made by pheromone-based voting (instant democracy)
- **Taboo:** Individualism seen as illness
- **Technology:** Advanced coordination, swarm tactics

### Dialogue Generation

**First Contact Dialogue:**
```python
@router.post("/api/first_contact/generate_dialogue")
async def generate_first_contact_dialogue(request: DialogueRequest):
    """
    Generate alien dialogue that:
    - Matches species communication style
    - Reflects cultural values
    - Responds to player's choices
    - Shows appropriate disposition
    - Reveals cultural information naturally
    """
```

**Prompt considers:**
- Species communication style
- Current relationship value
- Player's previous choices
- Cultural customs (respect/violation)
- Translation quality

**Example Dialogue (Veltharian, friendly):**
```
"This one is pleased by your careful approach. The collective has observed
many travelers, but few show the patience you demonstrate. Tell this one -
what drives your people across the stars? This one senses a great journey
behind your presence here."
```

**Example Dialogue (Veltharian, offended):**
```
"This one... struggles to comprehend your haste. Perhaps your kind does not
value thoughtful discourse? This one will withdraw. The collective must
deliberate on whether further contact serves harmony."
```

### Technical Implementation

#### Data Models

**Python:**
```python
from pydantic import BaseModel, Field
from typing import List, Dict, Optional
from enum import Enum

class TechLevel(str, Enum):
    PRIMITIVE = "primitive"  # Pre-industrial
    DEVELOPING = "developing"  # Industrial to early space
    EQUAL = "equal"  # Similar to player
    ADVANCED = "advanced"  # Beyond player
    FAR_ADVANCED = "far_advanced"  # Significantly beyond

class Disposition(str, Enum):
    HOSTILE = "hostile"
    CAUTIOUS = "cautious"
    NEUTRAL = "neutral"
    CURIOUS = "curious"
    FRIENDLY = "friendly"

class RelationshipStatus(str, Enum):
    WAR = "war"
    HOSTILE = "hostile"
    UNFRIENDLY = "unfriendly"
    NEUTRAL = "neutral"
    FRIENDLY = "friendly"
    ALLIED = "allied"
    CLOSE_ALLY = "close_ally"

class AlienBiology(BaseModel):
    appearance: str
    lifespan: int  # in Earth years
    environmental_needs: str
    unique_traits: List[str] = []

class AlienCulture(BaseModel):
    government: str
    values: List[str] = Field(..., min_items=3, max_items=5)
    taboos: List[str] = Field(..., min_items=2, max_items=4)
    communication_style: str
    decision_making: str
    unique_practices: List[str] = []

class AlienTechnology(BaseModel):
    level: TechLevel
    specialties: List[str] = []
    ftl_capable: bool = False
    notable_achievements: List[str] = []

class AlienDisposition(BaseModel):
    initial_attitude: Disposition
    relationship_value: int = Field(0, ge=-100, le=100)
    relationship_status: RelationshipStatus = RelationshipStatus.NEUTRAL
    trust: int = Field(0, ge=0, le=100)
    respect: int = Field(0, ge=0, le=100)

class AlienHistory(BaseModel):
    total_encounters: int = 0
    positive_interactions: int = 0
    negative_interactions: int = 0
    cultural_mistakes: int = 0
    gifts_exchanged: int = 0
    promises_kept: int = 0
    promises_broken: int = 0
    major_events: List[Dict] = []

class AlienKnowledge(BaseModel):
    basic_info: bool = False
    cultural_customs: bool = False
    history: bool = False
    technology: bool = False
    star_charts: bool = False
    exodus_knowledge: bool = False

class AlienSpecies(BaseModel):
    species_id: str
    name: str
    homeworld: str
    first_contact_location: str
    first_contact_day: Optional[int] = None

    biology: AlienBiology
    culture: AlienCulture
    technology: AlienTechnology
    disposition: AlienDisposition

    history_with_player: AlienHistory = AlienHistory()
    knowledge_unlocked: AlienKnowledge = AlienKnowledge()

    unique_hook: str  # Memorable aspect of species

    def adjust_relationship(self, amount: int, reason: str) -> None:
        """Adjust relationship value and update status"""
        self.disposition.relationship_value = max(-100, min(100,
            self.disposition.relationship_value + amount))

        # Update status based on value
        val = self.disposition.relationship_value
        if val >= 75:
            self.disposition.relationship_status = RelationshipStatus.CLOSE_ALLY
        elif val >= 50:
            self.disposition.relationship_status = RelationshipStatus.ALLIED
        elif val >= 20:
            self.disposition.relationship_status = RelationshipStatus.FRIENDLY
        elif val >= -19:
            self.disposition.relationship_status = RelationshipStatus.NEUTRAL
        elif val >= -49:
            self.disposition.relationship_status = RelationshipStatus.UNFRIENDLY
        elif val >= -99:
            self.disposition.relationship_status = RelationshipStatus.HOSTILE
        else:
            self.disposition.relationship_status = RelationshipStatus.WAR

        # Record event
        self.history_with_player.major_events.append({
            "type": "relationship_change",
            "amount": amount,
            "reason": reason,
            "new_value": self.disposition.relationship_value
        })

    def record_interaction(self, positive: bool, cultural_mistake: bool = False) -> None:
        """Record an interaction with this species"""
        self.history_with_player.total_encounters += 1
        if positive:
            self.history_with_player.positive_interactions += 1
        else:
            self.history_with_player.negative_interactions += 1
        if cultural_mistake:
            self.history_with_player.cultural_mistakes += 1
```

**GDScript:**
```gdscript
# alien_species.gd
class_name AlienSpecies
extends Resource

@export var species_id: String
@export var species_name: String
@export var homeworld: String
@export var first_contact_location: String
@export var first_contact_day: int = 0

# Culture and biology stored as dictionaries
@export var biology: Dictionary = {}
@export var culture: Dictionary = {}
@export var technology: Dictionary = {}
@export var disposition: Dictionary = {
    "initial_attitude": "neutral",
    "relationship_value": 0,
    "relationship_status": "neutral",
    "trust": 0,
    "respect": 0
}

@export var history_with_player: Dictionary = {
    "total_encounters": 0,
    "positive_interactions": 0,
    "negative_interactions": 0,
    "cultural_mistakes": 0,
    "promises_kept": 0,
    "promises_broken": 0,
    "major_events": []
}

@export var knowledge_unlocked: Dictionary = {
    "basic_info": false,
    "cultural_customs": false,
    "history": false,
    "technology": false,
    "star_charts": false,
    "exodus_knowledge": false
}

@export var unique_hook: String = ""

func adjust_relationship(amount: int, reason: String) -> void:
    """Adjust relationship and update status"""
    disposition.relationship_value = clamp(
        disposition.relationship_value + amount,
        -100, 100
    )

    # Update status
    var val = disposition.relationship_value
    if val >= 75:
        disposition.relationship_status = "close_ally"
    elif val >= 50:
        disposition.relationship_status = "allied"
    elif val >= 20:
        disposition.relationship_status = "friendly"
    elif val >= -19:
        disposition.relationship_status = "neutral"
    elif val >= -49:
        disposition.relationship_status = "unfriendly"
    elif val >= -99:
        disposition.relationship_status = "hostile"
    else:
        disposition.relationship_status = "war"

    # Record event
    history_with_player.major_events.append({
        "type": "relationship_change",
        "amount": amount,
        "reason": reason,
        "new_value": val,
        "day": GameState.current_day
    })

    EventBus.emit_signal("species_relationship_changed", species_id, val)

func record_interaction(positive: bool, cultural_mistake: bool = false) -> void:
    history_with_player.total_encounters += 1
    if positive:
        history_with_player.positive_interactions += 1
    else:
        history_with_player.negative_interactions += 1
    if cultural_mistake:
        history_with_player.cultural_mistakes += 1

func unlock_knowledge(category: String) -> void:
    if knowledge_unlocked.has(category):
        knowledge_unlocked[category] = true
        EventBus.emit_signal("species_knowledge_unlocked", species_id, category)

func to_dict() -> Dictionary:
    return {
        "species_id": species_id,
        "species_name": species_name,
        "homeworld": homeworld,
        "first_contact_location": first_contact_location,
        "first_contact_day": first_contact_day,
        "biology": biology,
        "culture": culture,
        "technology": technology,
        "disposition": disposition,
        "history_with_player": history_with_player,
        "knowledge_unlocked": knowledge_unlocked,
        "unique_hook": unique_hook
    }

static func from_dict(data: Dictionary) -> AlienSpecies:
    var species = AlienSpecies.new()
    species.species_id = data.species_id
    species.species_name = data.species_name
    species.homeworld = data.homeworld
    species.first_contact_location = data.first_contact_location
    species.first_contact_day = data.first_contact_day
    species.biology = data.biology
    species.culture = data.culture
    species.technology = data.technology
    species.disposition = data.disposition
    species.history_with_player = data.history_with_player
    species.knowledge_unlocked = data.knowledge_unlocked
    species.unique_hook = data.unique_hook
    return species
```

### UI Design

**Species Database:**
```
╔══════════════════════════════════════════════════════════════╗
║ SPECIES DATABASE                              Known: 7/???   ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║ [Veltharian] ████░ Allied (72)                              ║
║ [Lumina]     ███░░ Friendly (45)                            ║
║ [K'vari]     ██░░░ Neutral (12)                             ║
║ [Thane]      █░░░░ Unfriendly (-28)                         ║
║ [Unknown]    ?     First contact pending                    ║
║                                                              ║
║ Select species for details...                               ║
╚══════════════════════════════════════════════════════════════╝
```

**Species Detail View:**
```
╔══════════════════════════════════════════════════════════════╗
║ SPECIES: Veltharian                    Relationship: ████░ 72 ║
║ Status: Allied | Trust: 68 | Respect: 75                    ║
╠══════════════════════════════════════════════════════════════╣
║ BIOLOGY: [UNLOCKED]                                         ║
║ Tall, crystalline-skinned bipeds from high-radiation        ║
║ environments. Lifespan ~200 years. Their skin refracts      ║
║ light in beautiful patterns.                                 ║
║                                                              ║
║ CULTURE: [UNLOCKED]                                         ║
║ Collective Council government. Value knowledge, patience,   ║
║ and collective good above individual desires.               ║
║                                                              ║
║ Known Customs:                                               ║
║ ✓ Speak in third person (respect for collective)           ║
║ ✓ Value patience - rushing is offensive                     ║
║ ✓ Share knowledge freely (most valued gift)                 ║
║                                                              ║
║ Known Taboos:                                                ║
║ ⚠ Deception (extremely offensive, may end relationship)    ║
║ ⚠ Waste (shows disrespect for resources)                   ║
║ ⚠ Violence (only in absolute necessity)                    ║
║                                                              ║
║ TECHNOLOGY: [UNLOCKED]                                      ║
║ Advanced energy manipulation and sensor technology.         ║
║ FTL-capable. Specialize in harmonizing energy fields.      ║
║                                                              ║
║ HISTORY WITH YOU:                                           ║
║ • First contact: Day 67, Theta Sector                       ║
║ • Total encounters: 12                                      ║
║ • Cultural mistakes: 1 (early misunderstanding)            ║
║ • Promises kept: 3/3                                        ║
║ • Technology shared: Energy shield harmonics                ║
║                                                              ║
║ AVAILABLE:                                                   ║
║ [Trade] [Request Aid] [Share Information] [Back]           ║
╚══════════════════════════════════════════════════════════════╝
```

### Balance & Progression

**Species Encounter Rate:**
- Early Phase 2: 1-2 species
- Mid Phase 2: 4-6 species
- Late Phase 2: 8-12 species
- Not all species are friendly
- Some species know each other (politics!)

**Benefits of Alliances:**
- **Friendly (20-49):** Trade access, safe harbor
- **Allied (50-74):** Technology sharing, strategic info, missions
- **Close Ally (75-100):** Advanced tech, full cooperation, combat support

**Consequences of Hostility:**
- **Unfriendly (-20 to -49):** Avoid you, warn others
- **Hostile (-50 to -99):** May attack, block trade routes
- **War (-100):** Active combat, allies may join them

## Testing Checklist

- [ ] Species generation creates consistent cultures
- [ ] First contact protocol flows correctly
- [ ] Translation quality affects outcomes
- [ ] Cultural customs recognized/violated properly
- [ ] Relationship values adjust correctly
- [ ] Knowledge unlocking works
- [ ] Species database displays correctly
- [ ] Dialogue matches species personality
- [ ] Long-term consequences persist
- [ ] Save/load preserves species data

## Implementation Timeline

**Phase 2, Week 2-4 (3 weeks)**

**Week 2:** Foundation
- Species data models
- Generation endpoints
- Basic first contact flow

**Week 3:** Mechanics
- Cultural customs system
- Relationship tracking
- Knowledge database

**Week 4:** Content & Polish
- Multiple species examples
- First contact missions
- UI implementation
- Testing

## Future Enhancements

1. **Alien Crew Members** - Recruit aliens
2. **Interspecies Conflicts** - Mediate disputes
3. **Galactic Politics** - Complex alliance web
4. **Cultural Festivals** - Special events
5. **Language Learning** - Learn without translator
6. **Hybrid Technology** - Combine alien tech

## References

**Star Trek Episodes:**
- TNG "Darmok" - Communication challenges
- TNG "First Contact" - Prime Directive dilemmas
- TNG "The Measure of a Man" - Sentience questions
- DS9 "In the Pale Moonlight" - Ethical compromises

---

**Next Steps:**
1. Approve design
2. Prototype species generation
3. Create first contact flow
4. Test cultural mechanics
5. Build species database UI
