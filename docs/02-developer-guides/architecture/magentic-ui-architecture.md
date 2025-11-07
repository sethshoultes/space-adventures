# Magentic UI Architecture - Multi-AI Adaptive Interface

**Purpose:** Design document for the adaptive, context-aware UI system that supports multiple AI personalities interacting simultaneously with the player and each other.

**Inspiration:** Microsoft Magentic UI + Star Trek TNG multi-agent interactions

---

## Core Concepts

### 1. **Multiple Active AI Personalities**

The game features multiple AI personalities that can be active simultaneously:

- **ATLAS** (Ship Computer): Technical data, ship status, scans, navigation
- **Companion AI** (Crew/Friend): Emotional support, personal advice, moral guidance
- **MENTOR** (Strategic AI): Tactical planning, mission strategy, risk assessment
- **CHIEF** (Engineering AI): System diagnostics, repair suggestions, technical solutions
- **Mission Narrator**: Story progression, environmental descriptions

### 2. **Context-Aware Layout**

The UI adapts based on:
- **Current activity** (mission, combat, exploration, conversation)
- **Active AI personalities** (who's speaking, who's listening)
- **Player focus** (what the player is interacting with)
- **Urgency level** (combat = compressed, relaxed = expanded)
- **Content type** (narrative, technical data, conversation, choice)

### 3. **Dynamic Element Positioning**

Elements don't have fixed positions. They move, resize, and reorganize based on:
- Priority (what's most important right now)
- Relationships (who's talking to whom)
- Screen real estate (optimize space usage)
- Attention flow (guide player's eye naturally)

---

## UI States & Layouts

### **State 1: Mission Narrative Focus** (Default)
```
┌─────────────────────────────────────────────────────────┐
│ Mission Title & Location                                 │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  Main Narrative Panel (70% height)                       │
│  • Stage description                                     │
│  • Flowing text, easy to read                           │
│  • Result text morphs in/out                            │
│                                                           │
├─────────────────────────────────────────────────────────┤
│  Choice Buttons (when available)                         │
└─────────────────────────────────────────────────────────┘

┌──────────┐ ┌──────────┐ ┌──────────┐
│ ATLAS    │ │ Companion│ │ MENTOR   │
│ (quiet)  │ │ (quiet)  │ │ (quiet)  │
│ [icon]   │ │ [icon]   │ │ [icon]   │
└──────────┘ └──────────┘ └──────────┘
    ↑ Minimized AI presence at bottom
```

**Characteristics:**
- Narrative has primary focus
- AI personalities minimized but present
- Clean, distraction-free reading
- Choices prominent when available

---

### **State 2: AI Interjection** (AI offers input)
```
┌─────────────────────────────────────────────────────────┐
│ Mission Title & Location                                 │
├────────────────────────────┬────────────────────────────┤
│                            │                             │
│  Main Narrative            │  ATLAS (Active)            │
│  (50%)                     │  (50%)                     │
│  • Compressed but readable │  "Captain, I'm detecting  │
│                            │   unusual energy readings  │
│                            │   from the workshop."      │
│                            │                             │
│                            │  [Dismiss] [Ask More]      │
├────────────────────────────┴────────────────────────────┤
│  Choice Buttons (when available)                         │
└─────────────────────────────────────────────────────────┘

┌──────────┐ ┌──────────┐
│ Companion│ │ MENTOR   │
│ (quiet)  │ │ (quiet)  │
└──────────┘ └──────────┘
```

**Characteristics:**
- AI panel slides in from right
- Narrative compresses but remains visible
- AI has speech bubble/card
- Player can dismiss or engage further

---

### **State 3: Multi-AI Conversation** (AI personalities debate)
```
┌─────────────────────────────────────────────────────────┐
│ Mission Context (compressed, 20%)                        │
│ "You're in the workshop, considering your next move..." │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │
│  │ ATLAS       │    │ Companion   │    │ MENTOR      │ │
│  │ (technical) │◄──►│ (emotional) │◄──►│ (strategic) │ │
│  │             │    │             │    │             │ │
│  │ "Structural │    │ "But the   │    │ "We need   │ │
│  │  integrity  │    │  scavengers│    │  those     │ │
│  │  is sound." │    │  seem      │    │  systems." │ │
│  └─────────────┘    │  desperate"│    └─────────────┘ │
│                     └─────────────┘                    │
│                                                           │
│  [Let them discuss] [Interject] [Make decision]          │
└─────────────────────────────────────────────────────────┘
```

**Characteristics:**
- Mission context minimized to top
- Three AI panels in conversation
- Visual indicators show who's talking to whom
- Player can observe or interject

---

### **State 4: Player-AI Conversation** (Direct dialogue)
```
┌─────────────────────────────────────────────────────────┐
│ Conversation with ATLAS                                  │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────────────────────────────────────────┐    │
│  │ ATLAS Avatar & Status                            │    │
│  │ [Ship Computer - Online]                         │    │
│  ├─────────────────────────────────────────────────┤    │
│  │                                                   │    │
│  │ Conversation History (scrollable):               │    │
│  │                                                   │    │
│  │ You: "What's the ship's status?"                 │    │
│  │                                                   │    │
│  │ ATLAS: "Hull integrity at 100%, power core      │    │
│  │ generating 200 PU with 15 PU consumption..."    │    │
│  │                                                   │    │
│  └─────────────────────────────────────────────────┘    │
│                                                           │
│  [Text Input] ───────────────────────── [Send]          │
│                                                           │
│  Quick Questions:                                         │
│  [Ship Status] [Navigation] [Systems] [Back to Mission] │
└─────────────────────────────────────────────────────────┘
```

**Characteristics:**
- Full-screen conversation mode
- Mission context hidden but accessible
- Chat history preserved
- Quick question buttons for common queries

---

## Component Architecture

### **1. AIPersonalityManager** (Singleton)

```gdscript
extends Node
class_name AIPersonalityManager

# Active AI personalities
var active_personalities: Dictionary = {
    "atlas": { "active": true, "presence": 0.2, "state": "quiet" },
    "companion": { "active": false, "presence": 0.0, "state": "inactive" },
    "mentor": { "active": false, "presence": 0.0, "state": "inactive" },
    "chief": { "active": false, "presence": 0.0, "state": "inactive" }
}

# Current UI state
enum UIState {
    NARRATIVE_FOCUS,      # Mission story primary
    AI_INTERJECTION,      # One AI speaking
    MULTI_AI_DISCUSSION,  # Multiple AIs conversing
    PLAYER_AI_CHAT,       # Direct conversation
    COMBAT_COMPRESSED     # Combat mode (minimal UI)
}

var current_state: UIState = UIState.NARRATIVE_FOCUS

# Methods
func activate_ai(personality: String, presence_level: float)
func deactivate_ai(personality: String)
func ai_interject(personality: String, message: String, context: Dictionary)
func start_ai_discussion(participants: Array, topic: String)
func transition_ui_state(new_state: UIState, duration: float)
```

---

### **2. AdaptiveLayoutManager** (Singleton)

```gdscript
extends Node
class_name AdaptiveLayoutManager

# Layout configuration
var layout_config: Dictionary = {
    "narrative_weight": 1.0,    # How much space narrative gets
    "ai_panels": [],             # Active AI panels
    "transition_speed": 0.3      # Animation duration
}

# Methods
func calculate_layout(ui_state: UIState, active_ais: Array) -> Dictionary
func animate_transition(from_layout: Dictionary, to_layout: Dictionary)
func prioritize_content(content_items: Array) -> Array
func optimize_space(available_rect: Rect2, required_elements: Array)
```

---

### **3. AIPanel** (Scene Component)

Individual panel for each AI personality:

```gdscript
extends PanelContainer
class_name AIPanel

@export var personality_name: String = ""
@export var personality_color: Color = Color.WHITE

var current_state: String = "quiet"  # quiet, speaking, listening, inactive

# Visual states
func set_quiet()      # Minimized icon
func set_speaking()   # Expanded with speech
func set_listening()  # Visible, attentive
func set_inactive()   # Hidden/faded

# Animation
func morph_to_state(new_state: String, duration: float)
```

---

### **4. NarrativePanel** (Main Story Display)

Adaptive panel that morphs based on context:

```gdscript
extends PanelContainer
class_name NarrativePanel

# Content management
func display_stage(stage_data: Dictionary)
func display_result(result_text: String, color: Color)
func morph_content(from_text: String, to_text: String, duration: float)
func compress_to_context(summary: String)
func expand_to_full()
```

---

## AI Interjection System

### **Trigger Conditions:**

AIs can interject based on:

1. **Mission Events:**
   - Player makes risky choice → Companion warns
   - Technical scan needed → ATLAS offers data
   - Strategic decision → MENTOR suggests approach

2. **Environmental Context:**
   - Ship damage → CHIEF comments
   - Unknown location → ATLAS provides info
   - Moral dilemma → Companion reacts

3. **AI Personality Traits:**
   - ATLAS: Factual, helpful, proactive
   - Companion: Emotional, protective, reactive
   - MENTOR: Strategic, analytical, advisory
   - CHIEF: Technical, solution-focused

### **Interjection Flow:**

```
1. Mission stage loads
2. AIPersonalityManager analyzes context
3. Relevant AI triggers interjection check
4. If triggered:
   a. Pause narrative flow
   b. Transition to AI_INTERJECTION state
   c. AI panel slides in with message
   d. Player can: [Dismiss] [Ask More] [Engage]
5. Resume narrative or enter conversation
```

---

## Implementation Priority

### **Phase 1: Core Adaptive System** (Week 1)
- [ ] AIPersonalityManager singleton
- [ ] AdaptiveLayoutManager singleton
- [ ] Basic state transitions (NARRATIVE_FOCUS ↔ AI_INTERJECTION)
- [ ] AIPanel component with morph animations

### **Phase 2: Multi-AI Interactions** (Week 2)
- [ ] MULTI_AI_DISCUSSION state
- [ ] AI-AI conversation system
- [ ] Dynamic layout reconfiguration
- [ ] Context compression/expansion

### **Phase 3: Player Conversations** (Week 3)
- [ ] PLAYER_AI_CHAT state
- [ ] Full conversation UI
- [ ] Chat history and context
- [ ] Integration with AIService

### **Phase 4: Context Intelligence** (Week 4)
- [ ] AI interjection triggers based on mission events
- [ ] Priority system for multiple simultaneous interjections
- [ ] Smart content summarization
- [ ] Performance optimization

---

## Technical Considerations

### **Performance:**
- Tween-based animations (lightweight)
- Panel pooling (reuse AI panels)
- Lazy loading (only render visible content)
- Debounce rapid state changes

### **Accessibility:**
- Clear visual hierarchy at all times
- Smooth transitions (no jarring jumps)
- Color-coded AI personalities
- Text always readable (never occluded)

### **Scalability:**
- Easy to add new AI personalities
- Layout system handles 2-5 AIs dynamically
- Modular panel components
- State machine extensible

---

## Example Scenario: Multi-AI Mission Experience

**Setup:** Player is in "The Inheritance" mission, workshop contested stage.

```
1. NARRATIVE FOCUS:
   "Two scavengers block your path. They claim the workshop."

2. ATLAS INTERJECTS (scan):
   [Slides in] "Scanning... Two humanoid life signs. Armed: plasma
   cutter and projectile weapon. No hostile intent detected yet."

3. Player: [Ask More] "What are my options?"

4. MULTI-AI DISCUSSION (triggered):

   ATLAS: "Diplomatic approach viable. Workshop biometric lock
          requires your DNA—they cannot access it without you."

   Companion: "They look desperate. Maybe they just need help.
              Sharing could work."

   MENTOR: "Tactically, you have leverage. The workshop is yours.
           But making enemies this early could complicate future
           salvage operations."

5. Player chooses: "Offer to split the salvage 50/50"

6. NARRATIVE FOCUS (result):
   "The woman considers, then nods. 'Fair enough. You open it,
    we split it. But if there's a ship frame, that's yours.'"

7. COMPANION REACTS:
   [Quick interjection] "Good call. You made an ally today."

8. Continue mission...
```

**UI Experience:**
- Smooth transitions between states
- Never loses narrative thread
- AIs feel like crew members, not UI elements
- Player always in control
- Context preserved throughout

---

## Future Enhancements

- **Voice Acting:** AI personalities with unique voices
- **Visual Avatars:** Animated character portraits
- **Gesture System:** AIs can express emotions visually
- **Relationship System:** AIs remember past interactions
- **Learning Behavior:** AIs adapt to player preferences
- **Split-Screen Mode:** Multiple activities simultaneously

---

**Status:** Architecture Defined
**Next:** Begin Phase 1 implementation
**Owner:** AI Development Team
