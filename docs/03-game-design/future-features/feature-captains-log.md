# Captain's Log System

**Priority:** MVP Enhancement
**Phase:** Phase 1 Extension (Week 7) - Quick Win
**Complexity:** Low
**AI Integration:** High

## Overview

The Captain's Log is an AI-powered narrative journal that automatically chronicles the player's journey through Space Adventures. After each mission, the AI generates a "Captain's Log" entry in the player's voice, summarizing events, decisions, and their significance. This iconic Star Trek feature adds immersion, provides narrative cohesion, and creates a personalized story the player can review and share.

## Core Concept

**"Captain's Log, Stardate [date]. Today we..."**

After completing missions or experiencing significant events, the game generates a log entry that:
- Summarizes what happened in narrative form
- Reflects the player's choices and decision-making style
- Maintains consistent "voice" based on player behavior
- Creates a reviewable history of the journey
- Optionally supports text-to-speech for authentic Star Trek feel

## Design Principles

1. **Iconic Star Trek Element** - Captures the feel of Picard's log entries
2. **Player Voice** - Log reflects HOW the player plays (diplomatic, aggressive, cautious, bold)
3. **Narrative Coherence** - Helps players remember and understand their story
4. **Low Friction** - Automatic generation, optional review
5. **Shareable** - Players can export/share their journey

## Game Design

### Log Entry Types

**1. Mission Logs** (Primary)
Generated after completing any mission:
```
Captain's Log, Day 23.

We successfully salvaged reactor components from the Seattle underground
today, though not without difficult choices. When we encountered the
competing salvage team, I chose negotiation over confrontation. Marcus
questioned my decision, believing they couldn't be trusted, but the
peaceful resolution saved lives and earned us an ally.

The reactor cores are badly damaged - Dr. Chen estimates they'll need
significant repairs before installation. Still, we're one step closer
to a functional power system.

Sometimes I wonder if we're building this ship fast enough. How long
before Earth's resources run out entirely?
```

**2. Event Logs** (Secondary)
Generated for major story events:
- Recruiting first crew member
- Launching the ship (Phase 1 → Phase 2 transition)
- Discovering major story revelations
- Ship reaching milestones (all systems Level 1, etc.)
- Crew member deaths or departures

**3. Reflection Logs** (Optional)
Generated weekly or at player request:
- Summarizes progress over time period
- Reflects on overall journey
- Notes changes in approach or philosophy

### Log Entry Structure

Each entry contains:

```gdscript
{
  "log_id": "log_023",
  "stardate": "Day 23",  # In-game time
  "real_date": "2024-01-15T14:30:00Z",
  "type": "mission",  # mission, event, reflection
  "title": "Reactor Salvage - Seattle Underground",
  "entry_text": "Captain's Log, Day 23...",
  "mission_id": "mission_007",  # If applicable
  "key_choices": [
    {
      "choice_id": "negotiate_salvagers",
      "description": "Negotiated with competing salvage team",
      "alignment": "diplomatic"
    }
  ],
  "crew_mentioned": ["Marcus Rodriguez", "Dr. Sarah Chen"],
  "systems_affected": ["power"],
  "player_voice_tags": ["diplomatic", "cautious", "philosophical"],
  "morale": 65,
  "ship_status": {
    "systems_installed": 3,
    "crew_count": 2,
    "major_milestone": null
  }
}
```

### Player Voice Detection

The AI learns the player's style from choices:

**Voice Tags** (tracked in GameState):
- **Diplomatic vs Aggressive** - How they handle conflicts
- **Cautious vs Bold** - Risk tolerance
- **Pragmatic vs Idealistic** - Value system
- **Formal vs Casual** - Communication style
- **Optimistic vs Cynical** - Outlook
- **Emotional vs Logical** - Decision framework

**Choice Tracking:**
```gdscript
# game_state.gd
var player_voice_profile: Dictionary = {
    "diplomatic_aggressive": 0,  # -100 (aggressive) to +100 (diplomatic)
    "cautious_bold": 0,           # -100 (cautious) to +100 (bold)
    "pragmatic_idealistic": 0,    # -100 (pragmatic) to +100 (idealistic)
    "formal_casual": 0,           # -100 (formal) to +100 (casual)
    "optimistic_cynical": 0,      # -100 (cynical) to +100 (optimistic)
    "emotional_logical": 0        # -100 (emotional) to +100 (logical)
}

var total_choices: int = 0

func record_choice_voice(choice_data: Dictionary) -> void:
    """Track player's voice based on their choices"""
    for tag in choice_data.voice_tags:
        match tag:
            "diplomatic":
                player_voice_profile.diplomatic_aggressive += 5
            "aggressive":
                player_voice_profile.diplomatic_aggressive -= 5
            "cautious":
                player_voice_profile.cautious_bold -= 5
            "bold":
                player_voice_profile.cautious_bold += 5
            # ... etc

    total_choices += 1

func get_voice_descriptor(axis: String) -> String:
    """Get current voice descriptor for an axis"""
    var value = player_voice_profile[axis]
    var normalized = value / float(total_choices) if total_choices > 0 else 0

    # Returns descriptors like "very diplomatic", "somewhat cautious", etc.
    match axis:
        "diplomatic_aggressive":
            if normalized > 30: return "very diplomatic"
            elif normalized > 10: return "diplomatic"
            elif normalized < -30: return "very aggressive"
            elif normalized < -10: return "aggressive"
            else: return "pragmatic"
    # ... similar for other axes
```

### Mission Data Structure Enhancement

Add voice tags to mission choices:
```json
{
  "choice_id": "choice_negotiate",
  "text": "Attempt to negotiate with the rival salvagers",
  "voice_tags": ["diplomatic", "cautious", "idealistic"],
  "consequences": { ... }
}
```

### AI Integration

#### AI Generation Endpoint

```python
# python/src/api/captains_log.py
from fastapi import APIRouter
from ..models.captains_log import LogRequest, LogEntry
from ..ai.log_generator import CaptainsLogGenerator

router = APIRouter(prefix="/api/log", tags=["captains_log"])

@router.post("/generate", response_model=LogEntry)
async def generate_log_entry(request: LogRequest):
    """
    Generate a Captain's Log entry

    Request:
    - type: "mission" | "event" | "reflection"
    - mission_data: Mission results and choices
    - game_state: Current player state
    - player_voice: Voice profile data

    Returns formatted log entry
    """
    generator = CaptainsLogGenerator()

    entry = await generator.generate(
        log_type=request.type,
        mission_data=request.mission_data,
        game_state=request.game_state,
        voice_profile=request.player_voice
    )

    return entry
```

#### Prompt Template

```python
# python/src/ai/prompts.py

CAPTAINS_LOG_PROMPT = """
You are writing a Captain's Log entry for a Star Trek-inspired space adventure game.

CONTEXT:
- Setting: Post-exodus Earth, 2187
- Player is building a ship from salvaged parts to follow humanity into space
- Tone: Serious, thoughtful, Star Trek TNG style (Picard's logs)

MISSION SUMMARY:
Title: {mission_title}
Type: {mission_type}
Outcome: {success/failure}
Key Events: {event_summary}

PLAYER CHOICES:
{choices_made_with_outcomes}

PLAYER VOICE PROFILE:
The player's decision-making style is:
- {voice_descriptor_1} (e.g., "very diplomatic")
- {voice_descriptor_2} (e.g., "somewhat cautious")
- {voice_descriptor_3} (e.g., "pragmatic")

CREW INVOLVED:
{crew_members_and_their_contributions}

CURRENT SITUATION:
- Ship Progress: {systems_complete}/{total_systems} systems
- Crew Count: {crew_count}
- Morale: {morale_level}
- Day: {in_game_day}

INSTRUCTIONS:
Write a Captain's Log entry (150-250 words) that:

1. Starts with "Captain's Log, Day {day}."
2. Summarizes the mission/event in narrative form
3. Reflects on key choices made, matching the player's voice profile
4. Includes natural thoughts/concerns that fit the player's personality
5. Mentions crew members when relevant
6. Ends with a forward-looking statement or philosophical reflection
7. Feels authentic to Star Trek TNG's tone (serious but hopeful)

STYLE GUIDELINES:
- First person perspective ("I", "we")
- Past tense for events, present/future for reflections
- Match the voice profile (if diplomatic, express diplomacy; if aggressive, show decisiveness)
- Include personal touches (doubts, hopes, questions)
- Avoid melodrama - keep it grounded
- No clichés or obvious statements

AVOID:
- Purple prose or flowery language
- Summarizing obvious game mechanics
- Breaking immersion with game terms
- Being overly positive or negative - stay balanced

Return ONLY the log entry text, starting with "Captain's Log, Day {day}."
"""

REFLECTION_LOG_PROMPT = """
You are writing a reflective Captain's Log entry for a space adventure game.

TIME PERIOD: {start_day} to {end_day} ({duration} days)

SUMMARY OF PERIOD:
- Missions Completed: {missions_completed}
- Major Achievements: {achievements}
- Setbacks: {setbacks}
- Crew Changes: {crew_changes}
- Ship Progress: {ship_progress}

PLAYER VOICE: {voice_descriptors}

INSTRUCTIONS:
Write a reflective Captain's Log entry (200-300 words) that:

1. Starts with "Captain's Log, Day {end_day}. Personal Reflection."
2. Looks back over the period
3. Identifies patterns or themes in decisions
4. Expresses growth, change, or reaffirmation of values
5. Considers the journey ahead
6. Matches player's voice and personality

Return ONLY the log entry text.
"""
```

#### Voice-Aware Generation

The AI adjusts tone based on player voice:

**Diplomatic Player:**
```
"When confronted by the armed salvagers, I chose dialogue over
violence. Though it cost us time and some of our findings, I
believe we made the right choice. These people are desperate,
not evil - and we may need allies more than we need enemies."
```

**Aggressive Player:**
```
"The salvagers tried to intimidate us into leaving the site.
I made it clear we wouldn't back down. Sometimes strength is
the only language desperate people understand. We secured the
site and the parts we came for."
```

**Cautious Player:**
```
"We proceeded carefully through the reactor facility, scanning
for radiation and structural weaknesses. Marcus thought I was
being paranoid, but it paid off - the floors were compromised.
Rushing in would have been fatal."
```

**Bold Player:**
```
"The reactor was too valuable to leave behind. Despite the
warnings about radiation levels, I decided we could handle it
with our current equipment. It was risky, but Fortune favors
the bold, as they say."
```

### UI/UX Design

#### Log Access

**Main Menu:**
```
╔════════════════════════════════════╗
║  SPACE ADVENTURES                  ║
╠════════════════════════════════════╣
║  [Continue Game]                   ║
║  [New Game]                        ║
║  [Load Game]                       ║
║  [Captain's Log]  ← New option     ║
║  [Settings]                        ║
║  [Quit]                            ║
╚════════════════════════════════════╝
```

**In-Game Access:**
- Pause menu → Captain's Log
- Workshop hub → Terminal/Console interface
- Hotkey: L key

#### Log Browser

```
╔══════════════════════════════════════════════════════════════════╗
║ CAPTAIN'S LOG - USS [Ship Name]                   Total: 47 Entries║
╠══════════════════════════════════════════════════════════════════╣
║ Filter: [All] [Missions] [Events] [Reflections]    Sort: [Newest]║
║                                                                    ║
║ ┌────────────────────────────────────────────────────────────┐   ║
║ │ ▼ Day 45 - Launch Day                          [MILESTONE] │   ║
║ │   Captain's Log, Day 45. Today, we launched.               │   ║
║ │   After weeks of salvaging, building, and hoping, the     │   ║
║ │   ship lifted off Earth for the first time...             │   ║
║ │   [Read Full Entry] [Export] [Text-to-Speech]             │   ║
║ └────────────────────────────────────────────────────────────┘   ║
║                                                                    ║
║ ┌────────────────────────────────────────────────────────────┐   ║
║ │ ▶ Day 44 - Final Preparations                     [EVENT]  │   ║
║ │   Preview: Tomorrow we launch. The crew is ready, the     │   ║
║ │   ship is ready, but am I ready? To leave Earth...        │   ║
║ └────────────────────────────────────────────────────────────┘   ║
║                                                                    ║
║ ┌────────────────────────────────────────────────────────────┐   ║
║ │ ▶ Day 42 - Reactor Installation               [MISSION]    │   ║
║ │   Preview: The final system is in place. Marcus and I     │   ║
║ │   spent 14 hours installing the reactor cores...          │   ║
║ └────────────────────────────────────────────────────────────┘   ║
║                                                                    ║
║ [Scroll for more entries]                                         ║
║                                                                    ║
║ [Export All] [Search] [Back to Game]                              ║
╚══════════════════════════════════════════════════════════════════╝
```

#### Full Entry View

```
╔══════════════════════════════════════════════════════════════════╗
║ CAPTAIN'S LOG                                              Day 42 ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                    ║
║ Captain's Log, Day 42.                                            ║
║                                                                    ║
║ The final system is in place. Marcus and I spent fourteen hours  ║
║ installing the reactor cores we salvaged from Seattle. Dr. Chen   ║
║ insisted we take breaks to avoid radiation exposure, and for once ║
║ I listened. The woman's caution has saved us more times than I    ║
║ can count.                                                         ║
║                                                                    ║
║ With the power core operational, every system on the ship now     ║
║ has the energy it needs. It's remarkable to stand in the workshop ║
║ and see what was once scattered junk transformed into something   ║
║ capable of leaving Earth's gravity well.                          ║
║                                                                    ║
║ Tomorrow we'll run final system checks. If all goes well, we      ║
║ launch in three days.                                              ║
║                                                                    ║
║ I should feel triumphant, but instead I find myself thinking of   ║
║ the salvagers we met at the reactor site - the ones who helped    ║
║ us instead of fighting us. They're still down there, still        ║
║ struggling. We're leaving them behind.                            ║
║                                                                    ║
║ Is that what heroes do?                                            ║
║                                                                    ║
║ ──────────────────────────────────────────────────────────────    ║
║ Mission: Reactor Installation                                      ║
║ Outcome: Success                                                   ║
║ Crew: Marcus Rodriguez, Dr. Sarah Chen                            ║
║ Ship Status: 10/10 systems installed                              ║
║                                                                    ║
║ [🔊 Play Audio] [📄 Export] [← Previous] [Next →] [Close]         ║
╚══════════════════════════════════════════════════════════════════╝
```

#### Post-Mission Log Generation

```
╔═══════════════════════════════════════════════════════╗
║ MISSION COMPLETE                                      ║
╠═══════════════════════════════════════════════════════╣
║                                                       ║
║ ✓ Reactor Installation                               ║
║ ✓ XP Earned: 150                                     ║
║ ✓ Items Acquired: Reactor Core x2                    ║
║                                                       ║
║ ┌───────────────────────────────────────────────┐   ║
║ │ 📝 Generating Captain's Log entry...          │   ║
║ │    [████████░░] 80%                            │   ║
║ └───────────────────────────────────────────────┘   ║
║                                                       ║
║ [Skip] [Continue]                                    ║
╚═══════════════════════════════════════════════════════╝

↓ After generation ↓

╔═══════════════════════════════════════════════════════╗
║ CAPTAIN'S LOG ENTRY                                   ║
╠═══════════════════════════════════════════════════════╣
║                                                       ║
║ Captain's Log, Day 42.                               ║
║                                                       ║
║ The final system is in place. Marcus and I spent...  ║
║ [Preview of first ~100 words]                        ║
║                                                       ║
║ [Read Full Entry] [Continue]                         ║
╚═══════════════════════════════════════════════════════╝
```

**Player Options:**
1. **Read Full Entry** - Opens full log view
2. **Continue** - Save log and return to game
3. **Skip** - During generation, skip AI generation and continue (no log created)

### Technical Implementation

#### Data Models

**Python (Pydantic):**
```python
from pydantic import BaseModel, Field
from typing import List, Optional, Dict
from datetime import datetime

class PlayerVoiceProfile(BaseModel):
    diplomatic_aggressive: int = 0  # -100 to 100
    cautious_bold: int = 0
    pragmatic_idealistic: int = 0
    formal_casual: int = 0
    optimistic_cynical: int = 0
    emotional_logical: int = 0
    total_choices: int = 0

    def get_descriptors(self) -> Dict[str, str]:
        """Get voice descriptors for each axis"""
        descriptors = {}
        for axis in ["diplomatic_aggressive", "cautious_bold",
                     "pragmatic_idealistic", "formal_casual",
                     "optimistic_cynical", "emotional_logical"]:
            value = getattr(self, axis)
            normalized = value / self.total_choices if self.total_choices > 0 else 0
            descriptors[axis] = self._get_descriptor(axis, normalized)
        return descriptors

    def _get_descriptor(self, axis: str, value: float) -> str:
        # Returns descriptors like "very diplomatic", "somewhat cautious"
        # Implementation details...
        pass

class KeyChoice(BaseModel):
    choice_id: str
    description: str
    outcome: str
    alignment: str  # diplomatic, aggressive, cautious, etc.

class LogEntry(BaseModel):
    log_id: str
    stardate: str  # "Day 42"
    real_date: datetime
    type: str  # mission, event, reflection
    title: str
    entry_text: str
    mission_id: Optional[str] = None
    key_choices: List[KeyChoice] = []
    crew_mentioned: List[str] = []
    systems_affected: List[str] = []
    player_voice_tags: List[str] = []
    morale: int
    ship_status: Dict

class LogRequest(BaseModel):
    type: str
    mission_data: Optional[Dict] = None
    event_data: Optional[Dict] = None
    game_state: Dict
    player_voice: PlayerVoiceProfile
```

**GDScript:**
```gdscript
# captains_log.gd
class_name CaptainsLog
extends Node

signal log_entry_generated(entry: Dictionary)
signal log_generation_failed(error: String)

var log_entries: Array[Dictionary] = []
var is_generating: bool = false

func generate_mission_log(mission_result: Dictionary) -> void:
    """Generate log entry for completed mission"""
    if is_generating:
        push_warning("Log generation already in progress")
        return

    is_generating = true

    var request_data = {
        "type": "mission",
        "mission_data": mission_result,
        "game_state": GameState.to_dict(),
        "player_voice": GameState.player_voice_profile
    }

    var response = await AIService.request_post("/api/log/generate", request_data)

    is_generating = false

    if response.success:
        var entry = response.data
        entry.log_id = "log_%03d" % (log_entries.size() + 1)
        log_entries.append(entry)
        emit_signal("log_entry_generated", entry)
        SaveManager.save_logs()
    else:
        emit_signal("log_generation_failed", response.error)

func generate_event_log(event_type: String, event_data: Dictionary) -> void:
    """Generate log entry for major event"""
    # Similar to mission log
    pass

func generate_reflection_log(days_range: Dictionary) -> void:
    """Generate reflective log entry"""
    # Similar structure
    pass

func get_all_logs() -> Array[Dictionary]:
    return log_entries

func get_logs_by_type(type: String) -> Array[Dictionary]:
    return log_entries.filter(func(e): return e.type == type)

func get_log(log_id: String) -> Dictionary:
    for entry in log_entries:
        if entry.log_id == log_id:
            return entry
    return {}

func export_log(log_id: String, format: String = "txt") -> String:
    """Export log entry to text format"""
    var entry = get_log(log_id)
    if entry.is_empty():
        return ""

    match format:
        "txt":
            return _format_as_text(entry)
        "markdown":
            return _format_as_markdown(entry)
        _:
            return entry.entry_text

func export_all_logs(format: String = "txt") -> String:
    """Export all logs as single document"""
    var output = ""
    if format == "markdown":
        output = "# Captain's Log - USS %s\n\n" % GameState.ship.name

    for entry in log_entries:
        output += export_log(entry.log_id, format) + "\n\n"

    return output

func _format_as_text(entry: Dictionary) -> String:
    var text = "CAPTAIN'S LOG - %s\n" % entry.stardate
    text += "=" * 50 + "\n\n"
    text += entry.entry_text + "\n\n"
    text += "Mission: %s\n" % entry.title
    if entry.has("mission_id"):
        text += "ID: %s\n" % entry.mission_id
    text += "Crew: %s\n" % ", ".join(entry.crew_mentioned)
    return text

func _format_as_markdown(entry: Dictionary) -> String:
    var md = "## %s - %s\n\n" % [entry.stardate, entry.title]
    md += entry.entry_text + "\n\n"
    md += "---\n"
    md += "**Mission:** %s  \n" % entry.title
    md += "**Crew:** %s  \n" % ", ".join(entry.crew_mentioned)
    return md
```

#### GameState Integration

```gdscript
# game_state.gd additions

# Player voice tracking
var player_voice_profile: Dictionary = {
    "diplomatic_aggressive": 0,
    "cautious_bold": 0,
    "pragmatic_idealistic": 0,
    "formal_casual": 0,
    "optimistic_cynical": 0,
    "emotional_logical": 0
}
var total_choices: int = 0

# Captain's Log
var captains_log_enabled: bool = true  # Can be toggled in settings
var auto_generate_logs: bool = true
var show_log_after_mission: bool = true

func record_choice_voice(choice_data: Dictionary) -> void:
    """Track player voice from choices"""
    if not choice_data.has("voice_tags"):
        return

    for tag in choice_data.voice_tags:
        match tag:
            "diplomatic": player_voice_profile.diplomatic_aggressive += 5
            "aggressive": player_voice_profile.diplomatic_aggressive -= 5
            "cautious": player_voice_profile.cautious_bold -= 5
            "bold": player_voice_profile.cautious_bold += 5
            "pragmatic": player_voice_profile.pragmatic_idealistic -= 5
            "idealistic": player_voice_profile.pragmatic_idealistic += 5
            "formal": player_voice_profile.formal_casual -= 5
            "casual": player_voice_profile.formal_casual += 5
            "optimistic": player_voice_profile.optimistic_cynical += 5
            "cynical": player_voice_profile.optimistic_cynical -= 5
            "emotional": player_voice_profile.emotional_logical -= 5
            "logical": player_voice_profile.emotional_logical += 5

    total_choices += 1
```

#### Save Integration

```gdscript
# save_manager.gd additions

func save_game(slot: int) -> bool:
    var save_data = {
        "version": SAVE_VERSION,
        "timestamp": Time.get_datetime_string_from_system(),
        "game_state": GameState.to_dict(),
        "captains_log": CaptainsLog.get_all_logs()  # Include logs
    }

    # ... save to file

func load_game(slot: int) -> bool:
    # ... load from file

    if save_data.has("captains_log"):
        CaptainsLog.log_entries = save_data.captains_log
```

### Optional: Text-to-Speech

For maximum Star Trek immersion, add TTS narration:

**Implementation:**
```gdscript
# log_narrator.gd
class_name LogNarrator
extends Node

var tts_enabled: bool = false
var voice: AudioStream = null

func narrate_log(entry: Dictionary) -> void:
    """Convert log entry to speech"""
    if not tts_enabled:
        return

    # Option 1: Use Godot's built-in TTS (if available)
    if DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
        DisplayServer.tts_speak(entry.entry_text, DisplayServer.TTS_VOICE_MALE_DEEP)

    # Option 2: Use external TTS API
    # var audio = await generate_tts_audio(entry.entry_text)
    # play_audio(audio)

func stop_narration() -> void:
    if DisplayServer.tts_is_speaking():
        DisplayServer.tts_stop()
```

**TTS Settings:**
```
╔═══════════════════════════════════════╗
║ CAPTAIN'S LOG SETTINGS                ║
╠═══════════════════════════════════════╣
║ [✓] Enable Captain's Log              ║
║ [✓] Auto-generate after missions      ║
║ [✓] Show log preview                  ║
║ [ ] Enable text-to-speech narration   ║
║                                       ║
║ Voice: [Male Deep ▼]                  ║
║ Speed: [Normal ▼]                     ║
║                                       ║
║ [Save] [Cancel]                       ║
╚═══════════════════════════════════════╝
```

### Export Functionality

**Export Options:**
1. **Single Entry** - Export as .txt or .md
2. **All Entries** - Export complete log as single document
3. **Date Range** - Export logs from specific period
4. **Share Format** - Formatted for sharing on social media

**Export Dialog:**
```
╔═══════════════════════════════════════════╗
║ EXPORT CAPTAIN'S LOG                      ║
╠═══════════════════════════════════════════╣
║ Export: ⦿ Current Entry                   ║
║         ○ All Entries                     ║
║         ○ Date Range                      ║
║                                           ║
║ Format: ⦿ Plain Text (.txt)               ║
║         ○ Markdown (.md)                  ║
║         ○ Share Format                    ║
║                                           ║
║ Location: [Browse...]                     ║
║ /home/user/Documents/captains_log.txt     ║
║                                           ║
║ [Export] [Cancel]                         ║
╚═══════════════════════════════════════════╝
```

### Balance & Settings

**Generation Frequency:**
- **Always:** After every mission (default)
- **Major Only:** Only major missions and events
- **Manual:** Player triggers generation manually
- **Disabled:** No automatic generation

**Preview Options:**
- **Full Preview:** Show entire log after generation
- **Brief Preview:** Show first ~100 words
- **No Preview:** Save directly, read later

**Player Control:**
- Can regenerate log entry if unsatisfied (limited to 2-3 times)
- Can edit log entries manually
- Can delete entries
- Can disable system entirely

### Testing Checklist

**Generation:**
- [ ] Mission logs generate correctly
- [ ] Event logs generate for milestones
- [ ] Reflection logs work
- [ ] Voice profile affects tone
- [ ] Different choices produce different log styles

**Voice Detection:**
- [ ] Diplomatic choices increase diplomatic score
- [ ] Aggressive choices increase aggressive score
- [ ] Voice descriptors accurate
- [ ] Mixed playstyles handled well

**UI:**
- [ ] Log browser displays entries
- [ ] Full entry view readable
- [ ] Filter and sort work
- [ ] Export functions correctly

**Integration:**
- [ ] Logs generated after missions
- [ ] Event logs trigger at milestones
- [ ] Save/load preserves logs
- [ ] No performance issues

**Content Quality:**
- [ ] Logs feel authentic to Star Trek
- [ ] Entries match player voice
- [ ] Good variety in tone/content
- [ ] No repetitive phrasing

## Implementation Timeline

**Week 1: Foundation (5 days)**
- Day 1: Data models and voice tracking
- Day 2: AI prompt templates and endpoint
- Day 3: Basic log generation integration
- Day 4: Log browser UI
- Day 5: Save/load integration and testing

**Optional Week 2: Polish (3 days)**
- Day 1: Export functionality
- Day 2: Text-to-speech integration
- Day 3: Settings and refinement

**Total: 5 days minimum, 8 days with polish**

This is the fastest MVP enhancement - high impact for low effort!

## Future Enhancements

**Post-MVP:**
1. **Voice Variety** - Multiple TTS voices to choose from
2. **Audio Logs** - Record your own voice (microphone input)
3. **Visual Logs** - Include screenshots from missions
4. **Log Themes** - Different formatting styles
5. **Shareable Cards** - Generate shareable images with log excerpts
6. **Community Logs** - Optional sharing platform
7. **Historical Analysis** - AI summary of entire playthrough

## References

**Star Trek Inspiration:**
- Captain Picard's thoughtful, philosophical logs
- Captain Kirk's dramatic, action-focused logs
- Sisko's personal, conflicted logs
- Janeway's determined, exploratory logs

**Format Examples:**

**Picard Style (Thoughtful):**
> "Captain's Log, Stardate 47622.1. The away team has returned from the planet's surface with troubling news. It seems our presence, however well-intentioned, has disrupted a delicate cultural balance. I am reminded that even our best efforts to help can sometimes cause harm. The question before us now is whether we have a moral obligation to repair what we have broken, or whether further interference would only compound our error."

**Kirk Style (Action):**
> "Captain's Log, Stardate 3134.0. The Enterprise has encountered a massive energy field of unknown origin. Our sensors are useless, communications are down, and we're being pulled deeper into the phenomenon. If we can't break free in the next six hours, the ship will be crushed. But giving up has never been our way. We'll find a solution - we always do."

---

**Next Steps:**
1. Approve design
2. Create voice tracking system
3. Develop AI prompts
4. Build basic UI
5. Test with various playstyles
