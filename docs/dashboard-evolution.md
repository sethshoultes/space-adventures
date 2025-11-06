# Space Adventures - Dashboard Evolution & Transition

**Version:** 1.0
**Date:** November 6, 2025
**Purpose:** Define how dashboards evolve as players progress from Earth to space

---

## Table of Contents
1. [Overview](#overview)
2. [Phase 1: Workshop Dashboard](#phase-1-workshop-dashboard)
3. [Phase 2: Ship Dashboard](#phase-2-ship-dashboard)
4. [The Transition Event](#the-transition-event)
5. [Shared Screens](#shared-screens)
6. [Dashboard Customization System](#dashboard-customization-system)

---

## Overview

### Two Primary Dashboards

Space Adventures features **two distinct dashboards** that correspond to the two major gameplay phases:

```
PHASE 1 (Earthbound)          →    PHASE 2 (Space Explorer)
═══════════════════════              ══════════════════════════
Workshop Dashboard                   Ship Dashboard
- Building your ship                 - Operating your ship
- Salvage missions on Earth          - Space exploration
- Parts installation                 - Encounters & combat
- Static location (workshop)         - Dynamic location (traveling)
- Goal: Get spaceworthy              - Goal: Explore the galaxy
```

### Philosophy

**Different phases require different interfaces:**
- Phase 1 is about **construction** - you're a mechanic building a ship
- Phase 2 is about **operation** - you're a captain commanding a ship

The dashboard evolves to match your role and needs.

---

## Phase 1: Workshop Dashboard

### Purpose
The Workshop Dashboard is your **construction hub** where you transform salvaged parts into a functioning starship.

### When Active
- **Start:** Game begins
- **End:** Launch into space (all 10 systems at Level 1+)
- **Duration:** ~4-6 hours of gameplay

### Screen Title
```
┌─────────────────────────────────────────────────────┐
│  WORKSHOP - Earth Sector 7          [Day 42 Post-Exodus]
```

### Key Features

**Focus on Building:**
- System installation checklist (8/10 installed ⚠️)
- Available missions to acquire parts
- Inventory of uninstalled parts
- Progress toward spaceworthiness

**Static Context:**
- Always at the workshop
- No navigation needed
- Local Earth-based missions only
- Limited to planetary operations

**UI Elements:**
1. **Player Status** - Name, rank, level, skills, credits
2. **Ship Status** - Hull HP, power, fuel, systems count
3. **Ship Schematic** - ASCII art showing installed systems
4. **Mission List** - 3-5 Earth-based salvage missions
5. **Inventory Summary** - Parts awaiting installation
6. **Navigation Bar** - Access to other screens
7. **Status Messages** - Hints and recent events

### Visual Style
- Post-exodus salvage aesthetic
- Utilitarian, workshop-like
- Earth tones and industrial colors
- "Making do with what we have" feel

**See:** `dashboard-implementation-plan.md` for complete specification

---

## Phase 2: Ship Dashboard

### Purpose
The Ship Dashboard is your **command center** for space exploration, navigation, and ship operations.

### When Active
- **Start:** First launch into space
- **End:** Game completion / ongoing
- **Duration:** Remainder of gameplay (v1.1+)

### Screen Title
```
┌─────────────────────────────────────────────────────┐
│  SS Endeavor - Explorer-class        [WARP 3] [YELLOW ALERT]
```

### Key Features

**Focus on Operations:**
- Current location and navigation
- Active encounters and threats
- Real-time ship systems monitoring
- Mission objectives and waypoints

**Dynamic Context:**
- Location changes constantly
- Star map navigation required
- Space-based encounters
- Multi-system galaxy exploration

**UI Elements:**
1. **Location Info** - Current system, sector, threat level
2. **Ship Status** - Real-time HP, power, shields, fuel
3. **Star Map** - Local system view with contacts
4. **Sensor Display** - Detected ships, anomalies, threats
5. **Active Missions** - Current objectives and waypoints
6. **Quick Actions** - Jump, scan, hail, set course
7. **Alert System** - Combat warnings, damage reports

### Visual Style
- Active starship bridge aesthetic
- LCARS-inspired (Star Trek)
- Space colors (blues, purples, stars)
- "We're a real ship now" feel

### Ship Dashboard Layout (Concept)

```
┌─────────────────────────────────────────────────────────────────────┐
│  SS Endeavor - Explorer-class             [WARP 3] [STATUS: GREEN] │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────────┐  ┌────────────────────────────────────┐  │
│  │  LOCATION            │  │  SHIP STATUS                       │  │
│  │  ══════════════      │  │  ════════════════════════════      │  │
│  │                      │  │                                    │  │
│  │  📍 Alpha Centauri   │  │  ❤️  Hull:   [████████░░] 160/200 │  │
│  │  Sector: Core        │  │  ⚡ Power:  [██████░░░░] 135/200 │  │
│  │  Coordinates: A-7    │  │  🛡️ Shields: [██████████] 150/150│  │
│  │  Threat Level: LOW   │  │  ⛽ Fuel:    [█████░░░░░] 520 LY │  │
│  │                      │  │                                    │  │
│  │  Nearest Station:    │  │  All Systems: NOMINAL              │  │
│  │  Terra Nova (2.3 AU) │  │  [System Details →]               │  │
│  └──────────────────────┘  └────────────────────────────────────┘  │
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  STAR MAP - Alpha Centauri System                             │  │
│  │  ═══════════════════════════════════════════════════════════  │  │
│  │                                                               │  │
│  │            ⭐ Alpha Centauri A (Main Sequence Star)           │  │
│  │                       ╱  │  ╲                                │  │
│  │                      ╱   │   ╲                               │  │
│  │              [Planet] [YOU] [Station]                        │  │
│  │               Terra    🚀    Terra Nova                       │  │
│  │               Prime           Outpost                         │  │
│  │                                                               │  │
│  │  SENSOR CONTACTS:                                             │  │
│  │  🔵 Friendly Ship - Merchant Freighter (2.1 AU, approaching) │  │
│  │  🟡 Unknown Signal - Source unknown (5.4 AU, stationary)     │  │
│  │  ⚪ Asteroid Field - Dense cluster (0.8 AU, caution)         │  │
│  │                                                               │  │
│  │  [Scan Area] [Set Waypoint] [Navigation Computer]            │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌─────────────────────────┐  ┌──────────────────────────────────┐  │
│  │  ACTIVE MISSIONS        │  │  QUICK ACTIONS                   │  │
│  │  ═══════════════════    │  │  ══════════════════════════════  │  │
│  │                         │  │                                  │  │
│  │  ► Survey Alpha Cent.   │  │  [Jump to Waypoint]              │  │
│  │    ⭐⭐⭐☆☆ | In Prog   │  │  [Full Impulse]                  │  │
│  │    Waypoint: ← 1.2 AU   │  │  [Scan Anomaly]                  │  │
│  │                         │  │  [Hail Contact]                  │  │
│  │  ► Trade Run to Terra   │  │  [Open Star Map]                 │  │
│  │    ⭐⭐☆☆☆ | Ready      │  │  [Emergency Warp]                │  │
│  │                         │  │                                  │  │
│  │  [Mission Log →]        │  │  Power Mgmt: [Redistribute]      │  │
│  └─────────────────────────┘  └──────────────────────────────────┘  │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │  [1] Navigation  [2] Missions  [3] Ship Systems  [4] Inventory ││
│  │  [5] Comms       [6] Sensors   [7] Save/Load    [ESC] Menu     ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                       │
│  🔔 "Captain, we're receiving a distress signal from the asteroid   │
│      field. Should I plot an intercept course?" - Ship Computer      │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

### New UI Elements (Not in Phase 1)

**Star Map:**
- Visual representation of current star system
- Planets, stations, and points of interest
- Your ship's position and heading
- Waypoints and navigation paths

**Sensor Display:**
- Real-time contact detection
- Contact classification (friendly, hostile, unknown)
- Distance and trajectory information
- Threat assessment

**Navigation Controls:**
- Quick jump to waypoints
- Set course and engage
- Emergency warp
- Impulse speed control

**Active Missions Panel:**
- Current objectives with progress
- Distance to waypoints
- Mission status (in progress, ready, completed)

**Alert System:**
- Color-coded alert status (Green, Yellow, Red)
- Combat warnings
- System damage notifications
- Proximity alerts

---

## The Transition Event

### When Transition Happens

The transition from Workshop Dashboard to Ship Dashboard occurs when:

**✅ All Requirements Met:**
1. All 10 ship systems installed (Level 1+)
2. Hull HP > 50%
3. Power Core functional
4. Warp Drive installed
5. Final mission "First Flight" completed

**⚠️ Phase Gate:**
This is the **main progression gate** between Phase 1 and Phase 2. Players cannot access space until all systems are ready.

### The Launch Sequence

**Step 1: Final Workshop Check**
```
┌─────────────────────────────────────────────┐
│  ⚠️  SHIP COMPUTER ALERT                    │
├─────────────────────────────────────────────┤
│                                             │
│  All ship systems are now operational.     │
│                                             │
│  READINESS STATUS:                          │
│  ✓ Hull Integrity:        95%              │
│  ✓ Power Core:            Online           │
│  ✓ Life Support:          Nominal          │
│  ✓ Warp Drive:            Ready            │
│  ✓ All 10 Systems:        Installed        │
│                                             │
│  You are cleared for launch.                │
│                                             │
│  Mission Available: "First Flight"          │
│  [Accept Mission]                           │
│                                             │
└─────────────────────────────────────────────┘
```

**Step 2: First Flight Mission**
- Scripted story mission
- Atmospheric test flight
- First warp jump (short distance)
- Tutorial for space controls
- Emotional moment (leave Earth behind)

**Step 3: Cutscene/Transition**
```
[Cinematic Sequence]
- Ship lifts off from workshop
- Atmospheric flight over post-exodus Earth
- Altitude climbs: 10km... 50km... 100km...
- "Engaging warp drive..."
- Stars streak by
- Arrive at first space location
- Camera zooms to ship cockpit view

[Text Overlay]
"You have left Earth behind."
"The galaxy awaits."
```

**Step 4: Ship Dashboard Activates**
- Workshop Dashboard fades out
- Ship Dashboard fades in
- New UI layout appears
- Tutorial tooltips highlight new features
- First space mission becomes available

**Step 5: Welcome to Space**
```
┌─────────────────────────────────────────────┐
│  💬 SHIP COMPUTER                           │
├─────────────────────────────────────────────┤
│                                             │
│  "Welcome aboard, Captain. I've taken the   │
│   liberty of plotting a course to the       │
│   nearest inhabited system."                │
│                                             │
│  "Your ship is fully operational. Where     │
│   would you like to explore first?"         │
│                                             │
│  [View Star Map] [Accept First Mission]    │
│                                             │
└─────────────────────────────────────────────┘
```

### No Going Back (Immediately)

**After transition:**
- Workshop Dashboard is no longer the default view
- Ship Dashboard becomes your primary interface
- Workshop is only accessible when docked at stations/planets

**BUT:**
- Players can dock at stations to access workshop-style interfaces
- Some planets have repair facilities with similar functionality
- Return to Earth is possible (but Earth is now just another location)

---

## Shared Screens

These screens are accessible from **both dashboards** with minimal differences:

### 1. Mission Select
- **Phase 1:** Shows Earth-based salvage missions
- **Phase 2:** Shows space-based encounters and missions
- **UI:** Same layout, different mission types

### 2. Mission Play
- **Both Phases:** Same choice-based narrative interface
- **Difference:** Phase 2 may include combat mechanics
- **UI:** Identical structure

### 3. Ship Systems Management
- **Phase 1:** Focus on installation and basic stats
- **Phase 2:** Focus on power distribution and repairs
- **UI:** Same screen, different emphasis

### 4. Inventory
- **Both Phases:** Same inventory management
- **Difference:** Phase 2 includes trade goods and resources
- **UI:** Identical

### 5. Save/Load
- **Both Phases:** Identical functionality
- **UI:** Same screen

### 6. Settings
- **Both Phases:** Identical functionality
- **UI:** Same screen

### 7. Ship Manual (Help)
- **Phase 1:** Focus on building and systems
- **Phase 2:** Focus on navigation and space operations
- **UI:** Same screen, content updated based on phase

---

## Dashboard Customization System

### Overview

Players can **customize the visual appearance** of their dashboards using AI-generated backgrounds. This adds personalization while maintaining functional UI elements.

### How It Works

**Step 1: Choose Style Preset**

When accessing Dashboard Customization (Settings > Appearance), players see:

```
┌─────────────────────────────────────────────────────┐
│  DASHBOARD APPEARANCE CUSTOMIZATION                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Choose a visual style for your dashboard:          │
│                                                     │
│  ○ Classic LCARS (Star Trek style)                 │
│    "Clean, functional, professional bridge UI"      │
│                                                     │
│  ○ Industrial Workshop                              │
│    "Gritty, salvaged tech, post-exodus aesthetic"   │
│                                                     │
│  ○ Holographic Future                               │
│    "Sleek holograms, advanced technology"           │
│                                                     │
│  ○ Retro Sci-Fi                                     │
│    "1970s NASA aesthetic, chunky buttons"           │
│                                                     │
│  ○ Minimalist Modern                                │
│    "Clean lines, high contrast, maximum clarity"    │
│                                                     │
│  ○ Cyberpunk Tech                                   │
│    "Neon, glitch effects, hacker aesthetic"         │
│                                                     │
│  [Generate Preview] (requires AI service)           │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Step 2: AI Generation**

When player clicks "Generate Preview":

1. **Prompt Construction:**
   - System combines preset style with functional requirements
   - Sends to AI provider (ChatGPT Vision / Google Imagen)

2. **Prompt Template Example (LCARS style):**
   ```
   Create a Star Trek LCARS-style dashboard interface background
   for a spaceship command center. The design should include:
   - Clean geometric panels and borders in orange, blue, and purple
   - Empty central areas for UI elements (don't add text)
   - Professional bridge aesthetic
   - Functional, readable layout
   - 1280x720 resolution
   - Dark background with accent colors
   - Leave space for: status panels (top), main display (center),
     navigation buttons (bottom)

   Style: Professional, futuristic, Star Trek inspired
   Mood: Serious sci-fi, command bridge
   ```

3. **Generate Two Variations:**
   - Option A: Lighter variant
   - Option B: Darker variant

4. **Processing Time:**
   - Show loading spinner: "Generating custom dashboard..."
   - Takes 3-10 seconds depending on AI provider
   - Display progress: "Rendering... 50%"

**Step 3: Preview and Select**

```
┌─────────────────────────────────────────────────────┐
│  SELECT YOUR DASHBOARD STYLE                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌────────────────────┐  ┌────────────────────┐   │
│  │                    │  │                    │   │
│  │   [Preview A]      │  │   [Preview B]      │   │
│  │                    │  │                    │   │
│  │  Option A          │  │  Option B          │   │
│  │  (Lighter)         │  │  (Darker)          │   │
│  │                    │  │                    │   │
│  └────────────────────┘  └────────────────────┘   │
│     [Select This]          [Select This]          │
│                                                     │
│  [Regenerate] [Cancel] [Use Default]               │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Step 4: Apply Background**

- Selected image becomes dashboard background
- UI elements (panels, text, buttons) render on top
- Saved to user preferences (persists across sessions)
- Can change anytime from Settings

### Technical Implementation

**AI Integration:**

```python
# python/src/api/customization.py

from fastapi import APIRouter
from pydantic import BaseModel
import openai
from PIL import Image

router = APIRouter()

class DashboardStyleRequest(BaseModel):
    style_preset: str  # "lcars", "industrial", "holographic", etc.
    resolution: str = "1280x720"
    variant: str = "both"  # "light", "dark", "both"

class DashboardStyleResponse(BaseModel):
    option_a_url: str
    option_b_url: str
    cached: bool

@router.post("/generate-dashboard-style")
async def generate_dashboard_style(request: DashboardStyleRequest):
    """Generate custom dashboard background using AI"""

    # Get style-specific prompt template
    prompt = get_style_prompt(request.style_preset)

    # Generate two variants
    if settings.IMAGE_PROVIDER == "openai":
        # Use DALL-E 3
        image_a = await generate_dalle3(prompt + " lighter variant")
        image_b = await generate_dalle3(prompt + " darker variant")
    elif settings.IMAGE_PROVIDER == "google":
        # Use Google Imagen
        image_a = await generate_imagen(prompt + " lighter variant")
        image_b = await generate_imagen(prompt + " darker variant")

    # Save to cache
    url_a = save_generated_image(image_a, "dashboard_a")
    url_b = save_generated_image(image_b, "dashboard_b")

    return DashboardStyleResponse(
        option_a_url=url_a,
        option_b_url=url_b,
        cached=False
    )

def get_style_prompt(style: str) -> str:
    """Get prompt template for specific style"""
    prompts = {
        "lcars": """
            Create a Star Trek LCARS-style dashboard interface background.
            Clean geometric panels in orange, blue, purple. Dark background.
            Empty central areas for UI. Professional bridge aesthetic.
            1280x720 resolution. No text or buttons.
        """,
        "industrial": """
            Create a gritty industrial workshop dashboard background.
            Rusty metal panels, salvaged tech, warning stripes. Dark grays,
            oranges, yellows. Post-apocalyptic aesthetic. 1280x720.
            Empty areas for UI. No text.
        """,
        "holographic": """
            Create a futuristic holographic dashboard background.
            Translucent panels, glowing edges, blue/cyan tones. Advanced
            tech aesthetic. 1280x720. Clean and sleek. No text.
        """,
        # ... more presets
    }
    return prompts.get(style, prompts["lcars"])
```

**Godot Integration:**

```gdscript
# godot/scripts/ui/dashboard_customizer.gd
extends Control

var ai_service_url = "http://localhost:8000/api/customization"

func generate_custom_background(style_preset: String):
    show_loading_spinner()

    var request_data = {
        "style_preset": style_preset,
        "resolution": "1280x720",
        "variant": "both"
    }

    var response = await AIService.post_request(
        "/customization/generate-dashboard-style",
        request_data
    )

    hide_loading_spinner()

    if response.has("option_a_url") and response.has("option_b_url"):
        show_preview_selection(response.option_a_url, response.option_b_url)
    else:
        show_error("Failed to generate dashboard style")

func apply_background(image_url: String):
    # Download image
    var texture = await download_image(image_url)

    # Apply to dashboard
    var background_sprite = get_node("Dashboard/Background")
    background_sprite.texture = texture

    # Save preference
    Settings.dashboard_background_url = image_url
    Settings.save_settings()

    show_message("Dashboard style applied!")
```

### Caching and Cost Management

**Caching Strategy:**
- Generated images cached locally
- Reuse if same style requested within 30 days
- User can force regenerate if desired

**Cost Considerations:**
- DALL-E 3: ~$0.04-0.08 per image (2 images = ~$0.10)
- Google Imagen: ~$0.02-0.05 per image (2 images = ~$0.06)
- Offer free default styles (pre-generated)
- AI generation optional for premium customization

**Free vs. Premium:**
- **Free:** 6 pre-generated style options (no AI needed)
- **Premium:** Unlimited AI generations (requires API key)
- Players provide their own API keys or use Ollama locally (free)

### Style Presets (Pre-generated Defaults)

To avoid forcing AI costs on all players, include **6 pre-made backgrounds**:

1. **Classic LCARS** - Star Trek style (default)
2. **Industrial Workshop** - Gritty salvage aesthetic
3. **Minimalist Dark** - Simple black panels
4. **Retro NASA** - 1970s control panels
5. **Holographic Blue** - Sleek future tech
6. **Cyberpunk Neon** - Glitch and neon

Players can use AI generation for **custom variations** if they want.

---

## Implementation Priority

### MVP (Phase 1 - Week 2)
- ✅ Workshop Dashboard (primary focus)
- ✅ Shared screens (Mission, Inventory, Save/Load, Settings)
- ⏸️ Ship Dashboard (deferred to v1.1)
- ⏸️ AI customization (deferred to v1.2+)

### v1.1 (Post-MVP - Weeks 7-9)
- Ship Dashboard implementation
- Transition sequence (First Flight mission)
- Phase 2 space navigation
- Basic sensor and star map

### v1.2 (Months 4-6)
- Dashboard customization system
- AI-generated backgrounds
- Style presets
- User preference saving

---

## Summary

**Two Dashboards, Two Experiences:**

| Aspect | Workshop Dashboard | Ship Dashboard |
|--------|-------------------|----------------|
| **Phase** | 1 (Earthbound) | 2 (Space) |
| **Focus** | Building | Operating |
| **Context** | Static (workshop) | Dynamic (traveling) |
| **Goal** | Get spaceworthy | Explore galaxy |
| **Duration** | 4-6 hours | Remainder of game |
| **Style** | Industrial, gritty | Bridge, professional |
| **Key Feature** | Ship schematic | Star map |

**Seamless Transition:**
- Clear progression gate (all systems Level 1)
- Emotional story moment (First Flight)
- Tutorial for new controls
- No loss of functionality (all features carry over)

**Future Customization:**
- AI-generated backgrounds (ChatGPT/Imagen)
- Multiple style presets
- Player personalization
- Optional premium feature (or free with own API key)

---

**Document Status:** Complete
**Last Updated:** November 6, 2025
**Next Steps:**
1. Implement Workshop Dashboard (Week 2)
2. Plan Ship Dashboard (v1.1)
3. Design customization system (v1.2)

The evolution continues! 🚀
