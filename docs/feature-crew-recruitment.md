# Crew Recruitment System

**Priority:** MVP Enhancement
**Phase:** Phase 1 Extension (Week 7-8) or Early Phase 2
**Complexity:** Medium
**AI Integration:** High

## Overview

The Crew Recruitment System adds human depth to Space Adventures by allowing players to find, recruit, and develop crew members with unique skills, personalities, and backstories. Inspired by Star Trek: TNG's focus on character-driven stories, this system creates emotional investment and strategic depth.

## Core Concept

As you scavenge Earth for ship parts, you also encounter survivors - engineers, scientists, doctors, ex-military personnel, and civilians with unique skills. Each crew member:
- Has procedurally generated backstory and personality (AI-powered)
- Contributes skills that affect mission success rates
- Has personal quests and character development
- Affects ship capabilities based on Life Support capacity
- Forms relationships and has opinions on your choices

## Design Principles

1. **Character Over Stats** - Crew members feel like people, not just numbers
2. **Meaningful Choices** - Who you recruit and who you leave behind matters
3. **Star Trek Tone** - Focus on character growth, moral dilemmas, diversity
4. **System Integration** - Tied to existing Life Support system
5. **AI-Generated Uniqueness** - Every playthrough has different crew members

## Game Design

### Crew Member Properties

```gdscript
# GDScript data structure
{
  "crew_id": "crew_001",
  "name": "Dr. Sarah Chen",
  "role": "Medical Officer",  # Primary role
  "backstory": "AI-generated biography",
  "personality": {
    "traits": ["cautious", "empathetic", "rational"],
    "voice": "formal, caring, uses medical terminology"
  },
  "skills": {
    "engineering": 2,
    "science": 7,
    "medical": 9,
    "combat": 1,
    "diplomacy": 6
  },
  "experience": 0,
  "level": 1,
  "morale": 75,  # 0-100
  "relationships": {
    "player": 50,  # -100 to 100
    "crew_002": 25,
    "crew_003": -10  # Conflicts possible
  },
  "status": "active",  # active, injured, dead
  "location": "ship",  # ship, away_team, unavailable
  "personal_quest": {
    "quest_id": "find_family",
    "stage": 2,
    "completed": false
  },
  "recruited_at": "mission_005",
  "memories": []  # Key events involving this crew member
}
```

### Crew Roles

**Primary Roles** (determine starting skill distribution):
1. **Engineer** - High engineering, moderate science
2. **Scientist** - High science, moderate engineering/medical
3. **Medical Officer** - High medical, moderate science/diplomacy
4. **Tactical Officer** - High combat, moderate engineering
5. **Diplomat** - High diplomacy, moderate science
6. **Pilot** - Balanced skills, bonus to propulsion-related tasks
7. **Survivor** - Low skills but high growth potential

### Life Support Capacity

Life Support level determines max crew:
- **Level 0:** 1 crew (player only)
- **Level 1:** 3 crew (player + 2)
- **Level 2:** 5 crew (player + 4)
- **Level 3:** 8 crew (player + 7)
- **Level 4:** 12 crew (player + 11)
- **Level 5:** 20 crew (player + 19)

**Strategic Choice:** Upgrade Life Support to recruit more crew, or focus on other systems?

### Recruitment Mechanics

#### Discovery
Crew members found through:
1. **Mission Encounters** - Specific missions feature potential recruits
2. **Random Events** - Chance encounters while scavenging
3. **Distress Calls** - New mission type: rescue survivors
4. **Faction Contacts** - Faction reputation unlocks crew introductions

#### Recruitment Choice
When encountering a potential crew member:
1. **Learn About Them** - AI-generated dialogue introducing character
2. **View Skills** - See their current capabilities
3. **Hear Their Story** - Backstory snippet (optional, reveals personality)
4. **Make Choice:**
   - Recruit them (if space available)
   - Decline (might not encounter again)
   - Defer (mark for later if you get more Life Support)

**Consequences:**
- Some crew members are time-sensitive (recruited by others if you wait)
- Declining certain crew can affect faction reputation
- Some crew come as pairs (recruit both or neither)

### Skill System

#### Skill Application
Crew skills affect:
1. **Mission Success Rates** - Crew assigned to missions add skill bonuses
2. **System Efficiency** - Engineer assigned to Power Core boosts output
3. **Event Outcomes** - Skill checks can use player OR best crew skill
4. **Workshop Speed** - Engineers reduce system upgrade time (if implemented)

#### Skill Growth
Crew members gain XP when:
- Participating in missions
- Using skills in events
- Completing their personal quests
- Training (new mechanic - spend time to boost skills)

**Level Up:** Every 500 XP, crew member levels up and gains:
- +1 to primary skill
- +1 to chosen secondary skill
- Possible new ability/trait

### Morale System

**Morale Range:** 0-100
- **High Morale (75-100):** +10% skill effectiveness, positive interactions
- **Normal Morale (40-74):** No modifiers
- **Low Morale (15-39):** -10% skill effectiveness, occasional complaints
- **Critical Morale (0-14):** -25% effectiveness, risk of leaving

**Morale Affected By:**
- Player choices in missions (+/- based on crew personality)
- Ship conditions (damaged ship = lower morale)
- Successful missions (+5 morale)
- Failed missions (-10 morale)
- Crew member deaths (-20 morale for all crew)
- Personal quest progress (+15 morale)
- Long periods without missions (-2 per week, optional rest mechanic)

**Morale Management:**
- Talk to crew members (dialogue options)
- Complete personal quests
- Make choices aligned with crew values
- Rest periods between dangerous missions

### Personal Quests

Each crew member has a personal quest tied to their backstory:

**Quest Types:**
1. **Lost Family** - Find/contact separated loved ones
2. **Redemption** - Make amends for past mistakes
3. **Expertise** - Recover research/data from old facility
4. **Justice** - Resolve past wrong or injustice
5. **Mystery** - Solve personal mystery (identity, past, etc.)
6. **Legacy** - Preserve something from their old life

**Quest Structure:**
- 3-5 stages, unlocked through main story progress
- Optional but rewarding (morale boost, skill unlock, unique item)
- Can fail if certain choices made or crew member dies
- Some quests interconnect (crew members help each other)

**Example: Dr. Sarah Chen - "Lost Family" Quest**
1. **Stage 1:** Sarah mentions her daughter was in Seattle during evacuation
2. **Stage 2:** Find Seattle refugee records (requires Computer Core 2+)
3. **Stage 3:** Records indicate daughter went to Exodus Ship "Horizon"
4. **Stage 4:** Discover Horizon's last known trajectory
5. **Stage 5:** Decision - Try to follow Horizon (Phase 2 content) or accept loss
   - **Choice A:** Promise to search (ongoing quest in space phase)
   - **Choice B:** Help Sarah find closure (morale boost, unlocks new ability)

### Relationship System

#### Player-Crew Relationships
- Range: -100 (hostile) to +100 (loyal)
- Affected by: Choices, dialogue, mission outcomes, personal quest attention
- Effects:
  - High relationship: Bonus skills, special dialogue, loyalty in crisis
  - Low relationship: Reduced effectiveness, may leave, won't volunteer for danger

#### Crew-Crew Relationships
- Some crew members naturally get along or clash
- Relationships evolve based on shared experiences
- Effects:
  - Positive: Bonus when working together
  - Negative: Penalty when on same mission
  - Neutral: No effect

**Relationship Events:**
- Crew members may ask you to mediate disputes
- Friendships form and provide story moments
- Romances possible between crew (not involving player - they're the captain)

### AI Integration

#### AI-Generated Content

**1. Crew Member Generation**
```python
# Python AI service endpoint
@router.post("/api/crew/generate")
async def generate_crew_member(
    role: str,
    context: GameStateContext
) -> CrewMember:
    """
    Generate unique crew member with:
    - Name (appropriate to role/setting)
    - Backstory (2-3 paragraphs)
    - Personality traits (3-5 traits)
    - Voice/speaking style
    - Personal quest seed
    """
```

**Prompt Template:**
```
You are generating a crew member for a Star Trek-inspired space adventure game.

SETTING: Post-exodus Earth, 2187. Humanity fled Earth due to [exodus reason].
Player is scavenging to build a ship and follow them.

ROLE: {role}
PLAYER LEVEL: {player_level}
GAME PHASE: {phase}

Generate a crew member with:
1. Name (diverse, realistic)
2. Age (25-65)
3. Backstory (how they survived, why they stayed/were left behind, 2-3 paragraphs)
4. Personality (3-5 traits: cautious/bold, optimistic/cynical, formal/casual, etc.)
5. Voice (how they speak - examples: "technical jargon", "dark humor", "inspirational")
6. Personal quest idea (what do they want to resolve before leaving Earth?)
7. Skills justification (why do they have their skill levels?)

TONE: Serious, character-driven, Star Trek TNG style (hopeful but realistic)
AVOID: Stereotypes, overly tragic backstories, chosen one narratives

Return JSON format:
{
  "name": "...",
  "age": 45,
  "backstory": "...",
  "personality": ["trait1", "trait2", ...],
  "voice": "...",
  "personal_quest_seed": "...",
  "suggested_skills": {"engineering": 5, ...}
}
```

**2. Crew Dialogue**
```python
@router.post("/api/crew/dialogue")
async def generate_crew_dialogue(
    crew_member: CrewMember,
    situation: str,
    context: GameStateContext
) -> DialogueResponse:
    """
    Generate dialogue consistent with crew member's:
    - Personality
    - Voice
    - Current morale
    - Relationship with player
    - Recent events/memories
    """
```

**3. Personal Quest Content**
```python
@router.post("/api/crew/quest_stage")
async def generate_quest_stage(
    crew_member: CrewMember,
    quest_stage: int,
    context: GameStateContext
) -> QuestStageContent:
    """
    Generate next stage of personal quest with:
    - Quest objective
    - Dialogue
    - Choices
    - Rewards
    """
```

#### Caching Strategy
- Crew member generation: Cache forever (unique per crew_id)
- Dialogue: Cache per situation + morale bracket (reduce variance)
- Quest content: Cache per stage (consistent experience)

### UI/UX Design

#### Crew Roster Screen
```
╔══════════════════════════════════════════════════════════════╗
║ CREW ROSTER                        Life Support: 5/8 (Lvl 2) ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║ [Portrait] Dr. Sarah Chen                     Morale: ████░ 85%║
║            Medical Officer | Level 3                         ║
║            Skills: ENG:2 SCI:7 MED:9 COM:1 DIP:6           ║
║            Status: Active | Relationship: ████░░ Trusted    ║
║            Quest: "Lost Family" - Stage 3/5                  ║
║            [View Details] [Talk] [Assign Mission]           ║
║                                                              ║
║ [Portrait] Marcus Rodriguez                   Morale: ███░░ 60%║
║            Engineer | Level 2                                ║
║            Skills: ENG:8 SCI:4 MED:1 COM:3 DIP:2           ║
║            Status: Active | Relationship: ███░░░ Friendly   ║
║            Quest: "Redemption" - Stage 1/4                   ║
║            [View Details] [Talk] [Assign Mission]           ║
║                                                              ║
║ [Empty Slot] - Upgrade Life Support to recruit more crew    ║
║                                                              ║
║ [Recruit New] [Manage Assignments] [View Relationships]     ║
╚══════════════════════════════════════════════════════════════╝
```

#### Crew Detail View
```
╔══════════════════════════════════════════════════════════════╗
║ Dr. Sarah Chen - Medical Officer                            ║
╠══════════════════════════════════════════════════════════════╣
║ [Portrait]    Age: 42                                        ║
║               Recruited: Mission 005 (Day 23)                ║
║               Level: 3 (XP: 750/1500)                        ║
║                                                              ║
║ BACKSTORY:                                                   ║
║ Dr. Chen was the chief medical officer at Seattle General   ║
║ Hospital when the exodus began. In the chaos, she stayed    ║
║ behind to treat wounded, losing contact with her daughter   ║
║ who evacuated separately. Now she searches Earth's ruins    ║
║ for any trace of her family...                              ║
║                                                              ║
║ PERSONALITY: Cautious, Empathetic, Rational                  ║
║ VOICE: Formal and caring, uses medical terminology          ║
║                                                              ║
║ SKILLS:                                                      ║
║   Engineering: ██░░░░░░░░ 2                                  ║
║   Science:     ███████░░░ 7                                  ║
║   Medical:     █████████░ 9                                  ║
║   Combat:      █░░░░░░░░░ 1                                  ║
║   Diplomacy:   ██████░░░░ 6                                  ║
║                                                              ║
║ MORALE: ████░ 85% (High - recent quest progress)            ║
║ RELATIONSHIP: ████░░ 75/100 (Trusted)                        ║
║                                                              ║
║ PERSONAL QUEST: "Lost Family" (Stage 3/5)                    ║
║ > Found Seattle refugee records                              ║
║ > Next: Investigate Exodus Ship "Horizon"                    ║
║ [Continue Quest]                                             ║
║                                                              ║
║ MEMORIES: (Recent significant events)                        ║
║ • Saved your life during medical emergency (Mission 012)    ║
║ • You helped find her daughter's records (Quest Stage 2)    ║
║ • Disagreed with your aggressive choice (Mission 008)       ║
║                                                              ║
║ [Talk to Sarah] [Assign to Mission] [Back to Roster]        ║
╚══════════════════════════════════════════════════════════════╝
```

#### Mission Assignment
When selecting mission, show:
```
Mission: "Reactor Salvage"
Difficulty: ██████░░░░ 6/10
Required Skills: Engineering 5+, Science 3+

Assign Crew:
[ ] Marcus Rodriguez (ENG:8, SCI:4) ✓ Meets requirements
[✓] Dr. Sarah Chen (ENG:2, SCI:7) ✗ Engineering too low
[ ] You (ENG:4, SCI:5) ✓ Meets requirements

Success Chance: 75% (Marcus + You)
                50% (Sarah + You) - Engineering risk
                90% (Marcus + Sarah + You) - Full team

Note: Dr. Chen's morale may suffer if left behind (prefers to contribute)

[Confirm Team] [Cancel]
```

### Technical Implementation

#### Data Models

**Python (Pydantic):**
```python
from pydantic import BaseModel, Field
from typing import List, Dict, Optional

class CrewPersonality(BaseModel):
    traits: List[str] = Field(..., min_items=3, max_items=5)
    voice: str

class CrewSkills(BaseModel):
    engineering: int = Field(ge=0, le=10)
    science: int = Field(ge=0, le=10)
    medical: int = Field(ge=0, le=10)
    combat: int = Field(ge=0, le=10)
    diplomacy: int = Field(ge=0, le=10)

class PersonalQuest(BaseModel):
    quest_id: str
    title: str
    type: str  # lost_family, redemption, etc.
    stage: int
    max_stages: int
    completed: bool
    description: str

class CrewMember(BaseModel):
    crew_id: str
    name: str
    age: int = Field(ge=18, le=80)
    role: str
    backstory: str
    personality: CrewPersonality
    skills: CrewSkills
    experience: int = 0
    level: int = 1
    morale: int = Field(ge=0, le=100, default=75)
    relationships: Dict[str, int] = {}  # crew_id or "player" -> relationship value
    status: str = "active"  # active, injured, dead
    location: str = "ship"  # ship, away_team, unavailable
    personal_quest: Optional[PersonalQuest] = None
    recruited_at: str  # mission_id or event_id
    memories: List[Dict] = []  # {event_type, description, impact}

class CrewRoster(BaseModel):
    crew_members: List[CrewMember]
    max_capacity: int

    def get_active_crew(self) -> List[CrewMember]:
        return [c for c in self.crew_members if c.status == "active"]

    def has_space(self) -> bool:
        return len(self.crew_members) < self.max_capacity

    def get_best_skill(self, skill_name: str) -> int:
        """Get highest skill value among active crew"""
        active = self.get_active_crew()
        if not active:
            return 0
        return max(getattr(c.skills, skill_name) for c in active)
```

**GDScript:**
```gdscript
# crew_member.gd
class_name CrewMember
extends Resource

@export var crew_id: String
@export var name: String
@export var age: int
@export var role: String
@export var backstory: String
@export var personality: Dictionary  # {traits: [], voice: ""}
@export var skills: Dictionary  # {engineering: 0, science: 0, ...}
@export var experience: int = 0
@export var level: int = 1
@export var morale: int = 75
@export var relationships: Dictionary = {}  # {crew_id: value}
@export var status: String = "active"
@export var location: String = "ship"
@export var personal_quest: Dictionary = {}
@export var recruited_at: String
@export var memories: Array = []

func get_skill(skill_name: String) -> int:
    return skills.get(skill_name, 0)

func add_experience(amount: int) -> bool:
    """Returns true if leveled up"""
    experience += amount
    var xp_for_next = level * 500
    if experience >= xp_for_next:
        level += 1
        return true
    return false

func adjust_morale(amount: int, reason: String = "") -> void:
    morale = clamp(morale + amount, 0, 100)
    if reason:
        memories.append({
            "type": "morale_change",
            "reason": reason,
            "amount": amount
        })

func adjust_relationship(target_id: String, amount: int) -> void:
    var current = relationships.get(target_id, 0)
    relationships[target_id] = clamp(current + amount, -100, 100)

func to_dict() -> Dictionary:
    return {
        "crew_id": crew_id,
        "name": name,
        "age": age,
        "role": role,
        "backstory": backstory,
        "personality": personality,
        "skills": skills,
        "experience": experience,
        "level": level,
        "morale": morale,
        "relationships": relationships,
        "status": status,
        "location": location,
        "personal_quest": personal_quest,
        "recruited_at": recruited_at,
        "memories": memories
    }

static func from_dict(data: Dictionary) -> CrewMember:
    var crew = CrewMember.new()
    crew.crew_id = data.crew_id
    crew.name = data.name
    crew.age = data.age
    crew.role = data.role
    crew.backstory = data.backstory
    crew.personality = data.personality
    crew.skills = data.skills
    crew.experience = data.experience
    crew.level = data.level
    crew.morale = data.morale
    crew.relationships = data.relationships
    crew.status = data.status
    crew.location = data.location
    crew.personal_quest = data.personal_quest
    crew.recruited_at = data.recruited_at
    crew.memories = data.memories
    return crew
```

#### GameState Integration

Add to `GameState` singleton:
```gdscript
# game_state.gd
var crew_roster: Array[CrewMember] = []
var max_crew_capacity: int = 1  # Calculated from Life Support level

func get_max_crew_capacity() -> int:
    var life_support_level = ship.systems.life_support.level
    match life_support_level:
        0: return 1
        1: return 3
        2: return 5
        3: return 8
        4: return 12
        5: return 20
        _: return 1

func add_crew_member(crew: CrewMember) -> bool:
    max_crew_capacity = get_max_crew_capacity()
    if crew_roster.size() >= max_crew_capacity:
        return false
    crew_roster.append(crew)
    EventBus.emit_signal("crew_recruited", crew)
    return true

func remove_crew_member(crew_id: String) -> void:
    for i in range(crew_roster.size()):
        if crew_roster[i].crew_id == crew_id:
            var crew = crew_roster[i]
            crew_roster.remove_at(i)
            EventBus.emit_signal("crew_left", crew)
            break

func get_crew_member(crew_id: String) -> CrewMember:
    for crew in crew_roster:
        if crew.crew_id == crew_id:
            return crew
    return null

func get_best_crew_skill(skill_name: String) -> int:
    """Get highest skill value among active crew (including player)"""
    var best = player.skills.get(skill_name, 0)
    for crew in crew_roster:
        if crew.status == "active":
            best = max(best, crew.get_skill(skill_name))
    return best

func adjust_all_crew_morale(amount: int, reason: String = "") -> void:
    """Adjust morale for all crew members"""
    for crew in crew_roster:
        if crew.status == "active":
            crew.adjust_morale(amount, reason)
```

#### API Endpoints

**1. Generate Crew Member**
```python
# python/src/api/crew.py
from fastapi import APIRouter, HTTPException
from ..models.crew import CrewMember, CrewGenerationRequest
from ..ai.crew_generator import CrewGenerator

router = APIRouter(prefix="/api/crew", tags=["crew"])

@router.post("/generate", response_model=CrewMember)
async def generate_crew_member(request: CrewGenerationRequest):
    """
    Generate a unique crew member with AI

    Request:
    - role: str (engineer, scientist, medical, etc.)
    - context: GameStateContext

    Returns CrewMember with unique:
    - Name, backstory, personality
    - Skills appropriate to role
    - Personal quest seed
    """
    generator = CrewGenerator()
    crew = await generator.generate(
        role=request.role,
        context=request.context
    )

    # Cache the generated crew member
    await cache_crew_member(crew)

    return crew
```

**2. Generate Crew Dialogue**
```python
@router.post("/dialogue", response_model=DialogueResponse)
async def generate_crew_dialogue(request: DialogueRequest):
    """
    Generate contextual dialogue for crew member

    Request:
    - crew_member: CrewMember
    - situation: str (greeting, mission_brief, personal_talk, etc.)
    - context: GameStateContext

    Returns dialogue lines consistent with personality
    """
    generator = CrewGenerator()
    dialogue = await generator.generate_dialogue(
        crew=request.crew_member,
        situation=request.situation,
        context=request.context
    )

    return dialogue
```

**3. Generate Quest Stage**
```python
@router.post("/quest/stage", response_model=QuestStageContent)
async def generate_quest_stage(request: QuestStageRequest):
    """
    Generate next stage of crew member's personal quest

    Request:
    - crew_member: CrewMember
    - stage_number: int
    - context: GameStateContext

    Returns quest stage with objective, dialogue, choices
    """
    generator = CrewGenerator()
    quest_stage = await generator.generate_quest_stage(
        crew=request.crew_member,
        stage=request.stage_number,
        context=request.context
    )

    return quest_stage
```

### Mission Integration

Crew members affect missions in three ways:

**1. Skill Bonuses**
```gdscript
# mission_manager.gd
func calculate_success_chance(mission: Mission, assigned_crew: Array[CrewMember]) -> float:
    var base_chance = mission.base_success_chance

    # Check required skills
    for req in mission.requirements:
        var best_skill = 0
        # Check assigned crew
        for crew in assigned_crew:
            best_skill = max(best_skill, crew.get_skill(req.skill_name))

        # Bonus/penalty based on skill level
        if best_skill >= req.required_level:
            base_chance += 10.0 * (best_skill - req.required_level + 1)
        else:
            base_chance -= 15.0 * (req.required_level - best_skill)

    return clamp(base_chance, 5.0, 95.0)
```

**2. Dialogue Options**
Crew members can be mentioned or participate in mission dialogue:
```json
{
  "choice_id": "choice_medical_help",
  "text": "Have Dr. Chen examine the survivor",
  "requirements": {
    "crew_present": "crew_medical_officer",
    "crew_skill": {"medical": 5}
  },
  "consequences": {
    "success_rate": 0.9,
    "crew_relationship_bonus": 10,
    "unique_outcome": "medical_save"
  }
}
```

**3. Morale Consequences**
After mission, adjust crew morale based on:
- Mission success/failure
- Alignment with their personality
- Whether their skills were utilized
- Outcome of choices

```gdscript
func apply_mission_morale_effects(mission_result: Dictionary) -> void:
    for crew in GameState.crew_roster:
        var morale_change = 0

        # Success/failure
        if mission_result.success:
            morale_change += 5
        else:
            morale_change -= 10

        # Personality alignment
        for choice in mission_result.choices_made:
            if choice.aligns_with_trait in crew.personality.traits:
                morale_change += 3
            elif choice.conflicts_with_trait in crew.personality.traits:
                morale_change -= 5

        # Skill utilization
        if crew.crew_id in mission_result.assigned_crew:
            morale_change += 2  # Glad to contribute

        crew.adjust_morale(morale_change, "Mission: " + mission_result.title)
```

### Balance & Progression

**Early Game (Phase 1 Start):**
- Player solo, Life Support Level 0 (capacity: 1)
- First crew recruited around Mission 3-5
- Initial crew have modest skills (3-5 in primary)

**Mid Game (Phase 1 End):**
- Life Support Level 2-3 (capacity: 5-8)
- 3-5 crew members recruited
- Crew skills 5-7, some personal quests completed
- Ship capability significantly enhanced by crew

**Late Game (Phase 2+):**
- Life Support Level 4-5 (capacity: 12-20)
- Diverse crew covering all skill areas
- Veteran crew with skills 8-10
- Complex crew dynamics and relationships

**Skill Scaling:**
- Crew member skills start 1-6 based on role
- Player skills remain meaningful (you're the captain, not obsolete)
- Best crew in each area: 2-3 points above player in specialty
- Crew provide options, not replacements

### Testing Checklist

**Crew Generation:**
- [ ] Generate crew for all 7 roles
- [ ] Verify unique names and backstories
- [ ] Check personality traits are varied
- [ ] Ensure skills match role expectations

**Recruitment:**
- [ ] Can recruit up to Life Support capacity
- [ ] Cannot recruit beyond capacity
- [ ] Declining crew works correctly
- [ ] Recruited crew appears in roster

**Skill System:**
- [ ] Crew skills apply to mission calculations
- [ ] Best skill selection works correctly
- [ ] XP gain and level-up functional
- [ ] Skill improvement on level-up

**Morale:**
- [ ] Morale affects skill effectiveness
- [ ] Mission outcomes adjust morale
- [ ] Personality conflicts affect morale
- [ ] Low morale triggers warnings

**Relationships:**
- [ ] Player-crew relationship tracks correctly
- [ ] Choices affect relationships appropriately
- [ ] Crew-crew relationships form
- [ ] High/low relationships have visible effects

**Personal Quests:**
- [ ] Each crew member has unique quest
- [ ] Quest stages unlock properly
- [ ] Quest completion rewards work
- [ ] Failed quests handle gracefully

**Save/Load:**
- [ ] Crew roster saves correctly
- [ ] All crew data persists
- [ ] Load restores crew state accurately

**UI:**
- [ ] Crew roster displays correctly
- [ ] Crew details show all info
- [ ] Mission assignment works
- [ ] Relationship view functional

## Implementation Timeline

**Week 1: Foundation**
- Day 1-2: Data models (Python + GDScript)
- Day 3-4: AI crew generation endpoint
- Day 5: Basic crew roster UI
- Day 6-7: Save/load integration

**Week 2: Core Systems**
- Day 1-2: Recruitment flow
- Day 3-4: Skill application to missions
- Day 5: Morale system
- Day 6-7: Relationship tracking

**Week 3: Content & Polish**
- Day 1-3: Personal quest framework
- Day 4-5: Crew dialogue system
- Day 6-7: UI polish and testing

**Total: 3 weeks** (can be compressed to 2 weeks if needed)

## Future Enhancements

**Post-MVP Additions:**
1. **Crew Specializations** - Unlock special abilities at high levels
2. **Crew Injuries** - Medical system, recovery time
3. **Crew Training** - Spend time to boost specific skills
4. **Crew Quarters** - Upgradeable, affects morale
5. **Crew Portraits** - AI-generated character art (Stable Diffusion)
6. **Voice Lines** - Text-to-speech for key dialogue (optional)
7. **Crew Permadeath Mode** - Hardcore difficulty option
8. **Crew Legacy** - Deceased crew remembered in memorials

## References

**Star Trek Inspiration:**
- TNG focus on crew relationships and character growth
- Medical officer (Beverly Crusher), Engineer (Geordi La Forge), etc.
- Personal episodes (Data's humanity quest, Worf's honor, etc.)
- Crew loyalty and found family themes

**Game Inspirations:**
- FTL: Faster Than Light (crew management, permadeath stakes)
- Mass Effect (crew loyalty missions, relationship system)
- Rimworld (personality traits, skill growth)
- Wildermyth (procedural character generation, legacy)

---

**Next Steps:**
1. Review and approve design
2. Create data model prototypes
3. Test AI crew generation
4. Build basic UI mockup
5. Integrate with existing mission system
