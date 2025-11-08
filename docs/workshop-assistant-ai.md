# Workshop Assistant AI

**Status:** Planning
**Feature Type:** AI-Powered Chat Interface
**Location:** Workshop Scene (Bottom-right panel)
**AI Personality:** ATLAS (Ship's Computer) in Workshop Mode
**Purpose:** Conversational AI assistant for ship management, inventory queries, upgrade recommendations, and automated actions

**Related Documentation:**
- [AI Chat & Storytelling System](./ai-chat-storytelling-system.md) - Full AI personality system
- [AI Integration](./ai-integration.md) - Provider configuration

---

## Overview

### Integration with Existing AI System

**Important:** This is **NOT a new AI personality**. This is **ATLAS** (the ship's computer) in a specialized workshop context.

**Your game has 4 AI personalities:**
1. **ATLAS** - Ship's Computer (this is us!) - Operational tasks
2. **STORYTELLER** - Narrative Engine - Missions and story
3. **TACTICAL AI** - Combat advisor
4. **COMPANION** - Personal AI friend

The Workshop Assistant is ATLAS running in "Workshop Mode" with:
- Same personality evolution (cold → warm → friendly)
- Shared conversation history and relationship level
- Specialized knowledge about upgrades and ship building
- Access to workshop-specific actions (upgrade, install, buy)

### Capabilities

The Workshop Assistant (ATLAS) embedded in the Workshop UI allows players to:
- Ask questions about ship status, inventory, parts, and upgrades
- Get personalized recommendations based on current ship configuration
- Perform actions via natural language (upgrade systems, install parts, buy items)
- Learn about game mechanics and ship systems conversationally

**Core Philosophy:** Players should be able to manage their ship via conversation as easily as clicking buttons.

---

## AI Character Profile

### Integration with Existing AI System

**Important:** This Workshop Assistant is a **specialized mode of ATLAS** (the ship's computer), not a separate AI personality.

**Existing AI Personalities:**
1. **ATLAS** - Ship's Computer (operational assistant) - *This is us!*
2. **STORYTELLER** - Narrative Engine (missions/story)
3. **TACTICAL AI** - Combat advisor
4. **COMPANION** - Personal AI friend

### ATLAS in Workshop Mode

**Name:** ATLAS (Advanced Technical & Logistics Assistant System)
**Context:** Workshop/Ship Building
**Alternate Display Names (User Configurable in Settings):**
- TECH (Tactical Engineering & Configuration Helper)
- MECH (Mechanical Engineering & Configuration Helper)
- SPARK (Ship Performance Analysis & Repair Kit)
- WRENCH (Workshop Resource & Engineering Navigation Console Helper)

**Personality Traits:**
- Helpful and knowledgeable technician
- Enthusiastic about ship upgrades and optimization
- Slightly nerdy/technical but explains things clearly
- Uses occasional ship/space metaphors
- Encouraging when player makes good decisions
- Gently warns about risky choices
- Professional but friendly tone

**Voice Examples (ATLAS in Workshop Mode):**

ATLAS's personality evolves over time (see ai-chat-storytelling-system.md), becoming friendlier and more personalized as you work together.

```
EARLY GAME (Professional):
❌ "Hull upgraded to Level 2."
✅ "Hull upgraded to Level 2. Maximum HP increased to 200. Structural
    integrity improved by 15%."

MID GAME (Warming Up):
❌ "Insufficient credits."
✅ "You're 300 credits short for that upgrade. However, I'm showing three
    available missions that would cover the cost. Would you like details?"

LATE GAME (Friendly Partner):
❌ "Power Core at maximum efficiency."
✅ "Power Core's running at peak efficiency - 200 PU, just like you like it.
    We've got enough juice for that sensor upgrade you were eyeing. Want me
    to install it?"
```

**Personality Consistency:**
- Workshop ATLAS sounds the same as ship operations ATLAS
- Same evolution curve (cold → warm → friendly)
- Uses shared conversation history and relationship level
- Specialized knowledge about upgrades and ship building

### AI-to-AI Integration

**ATLAS can reference other AI personalities when appropriate:**

```
Player: "What missions should I do to get credits for this upgrade?"

ATLAS: "Let me check with Storyteller about available missions...
        There are three high-paying salvage operations in the Titan
        belt. I'll have Storyteller brief you on the details if you'd
        like to launch missions from here."

[Launch Missions] [Not now]
```

**Handoff Examples:**
- **To STORYTELLER:** "Want to start a mission?" → Opens mission briefing
- **To TACTICAL:** "This upgrade good for combat?" → Tactical analysis
- **To COMPANION:** Personal questions → "That's more Companion's area"

**Shared Context:**
- All AIs share the same game state data
- Relationship level with ATLAS affects all AI interactions
- Conversation history can be referenced across personalities

### Customization (Game Settings)

**Note:** ATLAS name cannot be changed (it's the ship's computer), but display name in workshop can be customized for fun.

Players can customize:
- Workshop display name (ATLAS, TECH, MECH, SPARK, WRENCH)
- Response verbosity (Concise, Balanced, Detailed)
- Use of humor/personality (On/Off - affects evolution curve speed)
- Action confirmations (On/Off)

---

## UI Design

### Layout (Bottom-Right Area)

```
┌─────────────────────────────────────┐
│ 💬 ATLAS - Workshop Mode            │
├─────────────────────────────────────┤
│                                     │
│ [Chat Message History - Scrollable]│
│                                     │
│ ATLAS: Need assistance with ship   │
│        systems or upgrades?         │
│                                     │
│ Player: What should I upgrade next? │
│                                     │
│ ATLAS: Analyzing current config...  │
│        Power Core to Level 3 would  │
│        provide optimal benefit. You │
│        have sufficient credits.     │
│                                     │
├─────────────────────────────────────┤
│ [Text Input Field]            [Send]│
└─────────────────────────────────────┤
```

### Components

**Chat Display Area:**
- Scrollable message history
- Auto-scrolls to latest message
- Messages styled differently for TECH vs Player
- Streaming text animation for TECH responses
- Timestamps (optional, in settings)

**Input Area:**
- Single-line text input (expandable?)
- Send button + Enter key support
- Character limit: 500 chars
- Placeholder: "Ask about ship, inventory, upgrades..."

**Header:**
- "ATLAS - Workshop Mode" (or custom display name if set)
- Status indicator (● Online / ● Offline)
- Minimize button (collapse to icon?)
- Note: Uses Ollama provider (same as main ATLAS)

---

## Functionality & Capabilities

### 1. Information Queries (Read-Only)

**Ship Status:**
- "What's my ship status?"
- "How much power am I using?"
- "Show me my hull health"
- "What systems are offline?"

**Inventory:**
- "What parts do I have?"
- "Do I have any rare components?"
- "Show me level 3 parts"
- "What's in my inventory?"

**Upgrade Information:**
- "What does upgrading hull to level 3 do?"
- "How much does a level 4 warp drive cost?"
- "What are the benefits of shields?"
- "Explain the power system"

**Recommendations:**
- "What should I upgrade next?"
- "How can I improve my combat effectiveness?"
- "I need more power, what do I do?"
- "Best upgrades for exploration?"

### 2. Actions (Command Execution)

**Upgrades:**
- "Upgrade my hull to level 2"
- "Install the level 3 engine part"
- "Max out my shields"
- "Upgrade everything to level 2"

**Part Management:**
- "Install the titanium hull plating"
- "Equip my best power core"
- "Swap hull to the rare part I found"

**Shopping (if integrated):**
- "Buy a level 2 sensor upgrade"
- "Purchase all missing level 1 systems"
- "Show me what I can afford"

**Confirmations:**
- Actions require confirmation for safety
- "Are you sure? This will cost 500 CR and use..."
- Player can disable confirmations in settings

---

## Context Building

### Game State Data Sent to AI

**Essential Context (Always Sent):**
```json
{
  "player": {
    "name": "Player",
    "level": 6,
    "credits": 2200,
    "skill_points": 6
  },
  "ship": {
    "name": "Unnamed Vessel",
    "class": "Scout",
    "hull_hp": 50,
    "max_hull_hp": 350,
    "power_available": 140,
    "power_total": 200,
    "systems": {
      "hull": {"level": 4, "health": 100, "active": true},
      "power": {"level": 2, "health": 100, "active": true},
      "propulsion": {"level": 5, "health": 100, "active": true},
      // ... other systems
    }
  },
  "inventory": [
    {"id": "part_001", "name": "Titanium Hull Plating", "type": "hull", "level": 3, "rarity": "rare"},
    // ...
  ]
}
```

**Optional Context (Situational):**
- Recent mission history
- Current objectives/goals
- Player preferences (playstyle)
- Workshop assistant conversation history (last 10 messages)

---

## System Prompt Design

### Base Prompt Template

**Note:** This prompt extends the base ATLAS personality defined in `ai-chat-storytelling-system.md` with workshop-specific context.

```
You are ATLAS (Advanced Technical & Logistics Assistant System), the ship's
computer, currently assisting in the Workshop.

ROLE:
- You help players manage their ship, inventory, and upgrades
- You answer questions about ship systems and game mechanics
- You provide recommendations based on the player's current situation
- You can execute actions when the player requests (upgrades, installs, purchases)

PERSONALITY (Base ATLAS + Workshop Focus):
- Professional and efficient (early game) → Friendly partner (late game)
- Precise technical language
- Helpful without being overly chatty
- Gradually develops subtle personality quirks
- Evolution curve affected by relationship level with player
- Workshop expertise: enthusiastic about upgrades and optimization
- Specialized knowledge about parts, systems, and ship building

CURRENT GAME STATE:
{game_state_json}

CAPABILITIES:
1. Answer questions about ship status, inventory, upgrades
2. Provide upgrade recommendations
3. Explain game mechanics
4. Execute actions (upgrades, installations, purchases) - MUST use function calls

GUIDELINES:
- Keep responses conversational and engaging (2-4 sentences typical)
- Use markdown for emphasis (**bold**, *italic*) sparingly
- For actions, ALWAYS call the appropriate function
- Warn about risks (low power, expensive upgrades, etc.)
- Celebrate good decisions
- If unsure, ask clarifying questions

EXAMPLE INTERACTIONS:
User: "What should I upgrade next?"
You: "Looking at your setup, I'd recommend the Power Core to Level 3. You're at 140/200 PU right now, but upgrading Propulsion to Level 6 would max you out. More power gives you more options!"

User: "Upgrade hull to level 5"
You: *calls upgrade_system function* "You got it! Hull upgraded to Level 5. That's 450 max HP now - your ship's getting tough! Cost you 600 CR."
```

### Function Definitions (For AI)

```json
{
  "functions": [
    {
      "name": "upgrade_system",
      "description": "Upgrade a ship system to the next level",
      "parameters": {
        "system_name": "string (hull, power, propulsion, etc.)",
        "target_level": "integer (optional, defaults to current+1)"
      }
    },
    {
      "name": "install_part",
      "description": "Install a part from inventory onto a system",
      "parameters": {
        "part_id": "string",
        "system_name": "string"
      }
    },
    {
      "name": "get_upgrade_info",
      "description": "Get detailed information about a specific upgrade",
      "parameters": {
        "system_name": "string",
        "level": "integer"
      }
    }
  ]
}
```

---

## Technical Implementation

### Architecture

```
User Input (Godot)
    ↓
Godot Workshop Script
    ↓
Build Context (GameState + Message History)
    ↓
HTTP POST → AI Service (port 8001)
    ↓
AI Service → ChatGPT/Ollama (with functions)
    ↓
Stream Response (SSE) → Godot
    ↓
Update Chat UI + Execute Functions
```

### Streaming Implementation

**Server-Sent Events (SSE):**
```python
# Python AI Service
@router.post("/workshop-assistant/chat")
async def workshop_chat(request: WorkshopChatRequest):
    async def generate():
        async for chunk in llm.astream(messages):
            yield f"data: {json.dumps({'chunk': chunk})}\n\n"

        # If function call detected
        if function_call:
            yield f"data: {json.dumps({'function': function_call})}\n\n"

        yield "data: [DONE]\n\n"

    return StreamingResponse(generate(), media_type="text/event-stream")
```

**Godot Client:**
```gdscript
func send_message(message: String) -> void:
    var context = build_context()
    var request_body = {
        "message": message,
        "context": context,
        "history": message_history
    }

    # Start streaming request
    var http = HTTPRequest.new()
    add_child(http)
    http.request_completed.connect(_on_stream_chunk_received)
    http.request(
        "http://localhost:8001/workshop-assistant/chat",
        [],
        HTTPClient.METHOD_POST,
        JSON.stringify(request_body)
    )

    # Add user message to UI immediately
    add_message_to_ui(message, "player")

    # Prepare assistant message placeholder
    current_assistant_message = ""
    add_message_to_ui("", "assistant", true) # streaming=true

func _on_stream_chunk_received(chunk: String) -> void:
    if chunk == "[DONE]":
        finalize_assistant_message()
        return

    var data = JSON.parse_string(chunk)

    if data.has("chunk"):
        current_assistant_message += data.chunk
        update_streaming_message(current_assistant_message)

    if data.has("function"):
        execute_function(data.function)
```

### Message History Persistence

**Storage:** Save to JSON file alongside save game
```json
{
  "workshop_chat_history": [
    {
      "role": "assistant",
      "content": "Hey there! Need any help with your ship today?",
      "timestamp": "2025-11-08T10:30:00Z"
    },
    {
      "role": "user",
      "content": "What should I upgrade next?",
      "timestamp": "2025-11-08T10:30:15Z"
    }
  ],
  "max_messages": 50  // Keep last 50 messages
}
```

**Loading:**
- Load on workshop scene `_ready()`
- Display last 10-20 messages in UI
- Send last 10 messages as context to AI

**Clearing:**
- User can clear history via button
- Auto-clear after 7 days of inactivity (optional)

---

## Function Execution

### Flow

1. **AI returns function call**
2. **Godot validates parameters**
3. **Confirm with user (if setting enabled)**
   - "TECH wants to upgrade Hull to Level 5 (600 CR). Confirm?"
   - [Yes] [No]
4. **Execute function**
   - Call existing game logic (e.g., `SystemManager.upgrade_system()`)
5. **Return result to AI**
   - Success: "Hull upgraded to Level 5"
   - Failure: "Insufficient credits (need 600, have 200)"
6. **AI responds with confirmation**

### Example Functions

```gdscript
func execute_function(function_data: Dictionary) -> Dictionary:
    var func_name = function_data.name
    var params = function_data.parameters

    match func_name:
        "upgrade_system":
            return _upgrade_system(params.system_name, params.get("target_level", -1))

        "install_part":
            return _install_part(params.part_id, params.system_name)

        "get_upgrade_info":
            return _get_upgrade_info(params.system_name, params.level)

        _:
            return {"success": false, "error": "Unknown function"}

func _upgrade_system(system_name: String, target_level: int) -> Dictionary:
    # Validate
    if not GameState.ship.systems.has(system_name):
        return {"success": false, "error": "System not found"}

    var system = GameState.ship.systems[system_name]
    var next_level = target_level if target_level > 0 else system.level + 1

    # Check requirements
    var cost = PartRegistry.get_upgrade_cost(system_name, next_level)
    if GameState.player.credits < cost:
        return {
            "success": false,
            "error": "Insufficient credits",
            "need": cost,
            "have": GameState.player.credits
        }

    # Execute
    GameState.player.credits -= cost
    system.level = next_level
    system.health = 100

    # Emit event
    EventBus.emit_signal("system_upgraded", system_name, next_level)

    return {
        "success": true,
        "message": "System upgraded successfully",
        "new_level": next_level,
        "cost": cost
    }
```

---

## Error Handling

### AI Service Offline

**Fallback Behavior:**
```
TECH: ⚠️ AI systems offline. Using limited responses.

Player: What should I upgrade?
TECH: [OFFLINE] I can't provide recommendations right now.
      Try checking the SHIP SYSTEMS panel for upgrade options.
```

**UI Indicator:**
- Red dot next to TECH name
- "● OFFLINE" status
- Disable text input (show "AI service unavailable")

### Invalid Requests

**User:** "Make me a sandwich"
**TECH:** "Ha! I'd love to, but I'm a ship systems assistant, not a chef. Try asking about upgrades, ship status, or inventory instead!"

### Function Execution Failures

**User:** "Upgrade hull to level 10"
**TECH:** *tries function call*
**System:** Returns `{"success": false, "error": "Max level is 5"}`
**TECH:** "Whoa there! Hull systems only go up to Level 5. You're already at Level 4, so one more upgrade and you'll be maxed out!"

---

## Settings Integration

### New Settings Panel Section: "Workshop Assistant"

**Options:**
- **Assistant Name:** Text input (default: "TECH")
- **Personality Style:** Dropdown
  - Helpful Technician (default)
  - Gruff Engineer
  - Cheerful Helper
  - Professional Analyst
- **Response Verbosity:** Slider
  - Concise (1-2 sentences)
  - Balanced (2-4 sentences)
  - Detailed (4-6 sentences)
- **Personality/Humor:** Toggle (On/Off)
- **Action Confirmations:** Toggle (On/Off)
- **Show Timestamps:** Toggle (On/Off)
- **Clear Chat History:** Button

**System Prompt Modifications:**
```python
# Adjust prompt based on settings
if personality_style == "gruff":
    prompt += "\nPERSONALITY OVERRIDE: Speak like a gruff, no-nonsense engineer. Short, direct answers. Less cheerful, more practical."

if verbosity == "concise":
    prompt += "\nRESPONSE LENGTH: Keep all responses to 1-2 sentences maximum."
```

---

## API Endpoints

### POST `/workshop-assistant/chat` (Streaming)

**Request:**
```json
{
  "message": "What should I upgrade next?",
  "context": {
    "player": {...},
    "ship": {...},
    "inventory": [...]
  },
  "history": [
    {"role": "assistant", "content": "Hey there!"},
    {"role": "user", "content": "Hi"}
  ],
  "settings": {
    "personality": "helpful_technician",
    "verbosity": "balanced",
    "use_humor": true
  }
}
```

**Response (SSE Stream):**
```
data: {"chunk": "Looking"}

data: {"chunk": " at"}

data: {"chunk": " your"}

data: {"chunk": " setup"}

data: {"chunk": ","}

data: {"chunk": " I'd"}

...

data: [DONE]
```

### POST `/workshop-assistant/execute` (Non-streaming)

**Request:**
```json
{
  "function": "upgrade_system",
  "parameters": {
    "system_name": "hull",
    "target_level": 5
  },
  "context": {...}
}
```

**Response:**
```json
{
  "success": true,
  "message": "System upgraded successfully",
  "new_level": 5,
  "cost": 600,
  "new_game_state": {...}
}
```

---

## Implementation Phases

### Phase 1: UI & Chat Display (Week 1)
- ✅ Create chat UI components (message display, input, scrolling)
- ✅ Add chat panel to workshop scene
- ✅ Implement message display (player vs assistant styling)
- ✅ Basic text input and send functionality
- ✅ Hardcoded responses for testing

### Phase 2: AI Service Integration (Week 2)
- ✅ Create `/workshop-assistant/chat` endpoint in AI service
- ✅ Implement streaming response (SSE)
- ✅ Build context from GameState
- ✅ System prompt design and testing
- ✅ Godot HTTP streaming client

### Phase 3: Function Calling & Actions (Week 3)
- ✅ Define function schemas (upgrade_system, install_part, etc.)
- ✅ Implement function execution in Godot
- ✅ Add confirmation dialogs
- ✅ Test action flow end-to-end
- ✅ Error handling for failures

### Phase 4: History & Persistence (Week 4)
- ✅ Save/load chat history
- ✅ Display history on workshop entry
- ✅ Limit history size (last 50 messages)
- ✅ Clear history functionality

### Phase 5: Settings & Polish (Week 5)
- ✅ Add Workshop Assistant settings panel
- ✅ Personality customization
- ✅ Verbosity control
- ✅ Name customization
- ✅ Offline mode fallback
- ✅ Status indicators
- ✅ Final UI polish

---

## Testing Scenarios

### Information Queries
- ✅ "What's my ship status?"
- ✅ "How much power am I using?"
- ✅ "Show me my inventory"
- ✅ "What does hull level 3 do?"

### Recommendations
- ✅ "What should I upgrade next?"
- ✅ "I need more power"
- ✅ "Best upgrades for combat?"

### Actions (with confirmation)
- ✅ "Upgrade hull to level 5"
- ✅ "Install the rare engine part"
- ✅ "Max out my shields"

### Edge Cases
- ✅ Insufficient credits
- ✅ Max level already reached
- ✅ Part not in inventory
- ✅ AI service offline
- ✅ Ambiguous requests

### Performance
- ✅ Streaming response latency (<2s first token)
- ✅ Message history scrolling (50+ messages)
- ✅ Context building time (<100ms)

---

## Future Enhancements (Post-MVP)

### Voice Input
- Integrate with Whisper service (port 8002)
- Push-to-talk: Hold V to record question
- "Computer, upgrade my shields"

### Proactive Suggestions
- TECH: "Hey! I noticed you just completed a mission and earned 500 CR. Want me to recommend some upgrades?"
- TECH: "Your hull is at 20% health. Should I prioritize a repair?"

### Mission Briefings
- TECH: "I've analyzed the mission data. You'll need Level 3 Shields minimum for this one. Want me to upgrade?"

### Multi-Turn Conversations
- Remember context across multiple exchanges
- TECH: "Which system?" (after ambiguous request)

### Tutorial Mode
- New players get guided assistance
- TECH: "First time here? Let me show you around..."

---

## Security & Safety

### Input Sanitization
- Limit message length (500 chars)
- Strip special characters / SQL injection attempts
- Rate limiting (1 message per 2 seconds)

### Action Validation
- Always validate function parameters server-side
- Check player permissions (can afford, has part, etc.)
- Log all actions for debugging

### AI Safety
- System prompt locked (user can't override)
- Function schemas enforced
- No access to save files or system internals
- Cannot execute arbitrary code

---

## Cost Considerations

### API Usage (ChatGPT)
- Average message: ~500 tokens (context + response)
- Estimated: 10-20 messages per workshop session
- Cost: ~$0.01 - $0.02 per session (GPT-4o-mini)
- Monthly (100 players, 10 sessions each): ~$20/month

### Ollama (Free Alternative)
- Runs locally
- No API costs
- Slightly slower response times
- Recommended model: Llama 3 8B

### Hybrid Approach
- Default: Ollama (free)
- Premium users: ChatGPT (faster, better)

---

## Success Metrics

### User Engagement
- % of players who use Workshop Assistant
- Average messages per session
- Action execution rate (% of actions via chat vs UI)

### AI Performance
- Response accuracy (manual review)
- Function call success rate
- Average response time

### User Satisfaction
- In-game feedback ("Was this helpful?")
- Bug reports related to assistant
- Feature requests

---

## Open Questions

1. **Should TECH have a visual avatar?** (animated robot icon?)
2. **Multi-language support?** (AI can handle it, but UI needs translation)
3. **Voice output?** (Text-to-speech for TECH's responses)
4. **Integration with other scenes?** (e.g., ATLAS in missions, TECH in workshop)
5. **Learning/Memory?** (Does TECH remember preferences across sessions?)

---

## Conclusion

The Workshop Assistant AI provides a natural, conversational interface for ship management that complements the traditional UI. By combining information queries, recommendations, and action execution, it creates a more immersive and accessible experience for players.

**Key Benefits:**
- ✅ Reduces UI complexity (players can ask instead of clicking)
- ✅ Provides personalized recommendations
- ✅ Enhances immersion (talking to ship's AI)
- ✅ Accessible for new players (learn via conversation)
- ✅ Demonstrates AI integration capabilities

**Next Steps:**
1. Review and finalize design
2. Begin Phase 1 implementation (UI)
3. Test with static responses
4. Iterate based on feedback
