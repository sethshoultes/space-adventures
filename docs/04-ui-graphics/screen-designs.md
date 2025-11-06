# Space Adventures - Core Screen Designs

**Version:** 1.0
**Date:** November 6, 2025
**Purpose:** Complete UI/UX specifications for all game screens
**Status:** Ready for Implementation

---

## Table of Contents
1. [Overview](#overview)
2. [Mission Select Screen](#mission-select-screen)
3. [Mission Play Screen](#mission-play-screen)
4. [Ship Systems Management Screen](#ship-systems-management-screen)
5. [Inventory Management Screen](#inventory-management-screen)
6. [Save/Load Screen](#saveload-screen)
7. [Settings Screen](#settings-screen)
8. [Ship Manual Screen](#ship-manual-screen)
9. [Design Principles](#design-principles)
10. [Technical Specifications](#technical-specifications)

---

## Overview

### Screen Hierarchy

```
MAIN MENU
    ↓
Workshop/Ship Dashboard (Hub)
    ├─→ Mission Select → Mission Play → Results
    ├─→ Ship Systems Management
    ├─→ Inventory Management
    ├─→ Save/Load
    ├─→ Settings
    └─→ Ship Manual (Help)
```

### Common Elements

All screens share these elements:
- **Header bar** - Screen title and context
- **Back button** - Return to dashboard (ESC or [←] button)
- **Consistent theme** - Same fonts, colors, styling
- **Keyboard shortcuts** - Quick navigation
- **Status indicators** - Show player/ship critical stats

### Design Philosophy

**Consistency:**
- Same visual language across all screens
- Predictable navigation patterns
- Familiar interaction paradigms

**Clarity:**
- Clear labels and descriptions
- Obvious call-to-action buttons
- Visual hierarchy (important info stands out)

**Efficiency:**
- Minimal clicks to achieve goals
- Keyboard shortcuts for power users
- Quick actions for common tasks

---

## Mission Select Screen

### Purpose
Browse available missions, view details, and select which mission to undertake.

### Layout (1280x720)

```
┌─────────────────────────────────────────────────────────────────────┐
│  [←] MISSION SELECT                          Player Lv5 | 2,450₡   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────────────┐  ┌──────────────────────────────────┐│
│  │  AVAILABLE MISSIONS      │  │  MISSION DETAILS                 ││
│  │  ═══════════════════════ │  │  ═══════════════════════════════ ││
│  │                          │  │                                  ││
│  │  ► First Flight          │  │  FIRST FLIGHT                    ││
│  │    ★★☆☆☆ | Warp Part    │  │  ════════════                    ││
│  │    Earth · Spaceport     │  │                                  ││
│  │                          │  │  Location: Kennedy Spaceport     ││
│  │  ⚡ Power Struggle       │  │  Difficulty: ★★☆☆☆ (Medium)     ││
│  │    ★★★☆☆ | Power Core   │  │  Type: Salvage Mission           ││
│  │    Earth · Military Base │  │                                  ││
│  │                          │  │  DESCRIPTION:                    ││
│  │  The Rival               │  │  Intelligence suggests an intact ││
│  │    ★★★★☆ | Rare Parts   │  │  warp coil remains in Hangar 7  ││
│  │    Earth · Underground   │  │  of the abandoned spaceport.    ││
│  │                          │  │  Security drones may still be   ││
│  │  🔒 Rescue Operation     │  │  active. Caution advised.       ││
│  │    Requires: Level 7     │  │                                  ││
│  │                          │  │  OBJECTIVES:                     ││
│  │  🔒 Military Convoy      │  │  • Reach Hangar 7                ││
│  │    Requires: Combat 5    │  │  • Bypass security               ││
│  │                          │  │  • Retrieve warp coil            ││
│  │                          │  │  • Return to workshop            ││
│  │  Filter: [All Types ▼]  │  │                                  ││
│  │  Sort: [Difficulty ▼]   │  │  REWARDS:                        ││
│  │                          │  │  ⚙️  Warp Coil (Uncommon)        ││
│  │  [5 missions shown]      │  │  ⚡ 150 XP                       ││
│  │                          │  │  💰 +300 Credits                ││
│  │                          │  │                                  ││
│  │                          │  │  REQUIREMENTS:                   ││
│  │                          │  │  ✓ Player Level 3+               ││
│  │                          │  │  ✓ No special equipment          ││
│  │                          │  │                                  ││
│  │                          │  │  Estimated Time: 15-20 minutes   ││
│  │                          │  │                                  ││
│  │                          │  │  [START MISSION] [BACK]          ││
│  │                          │  │                                  ││
│  └──────────────────────────┘  └──────────────────────────────────┘│
│                                                                       │
│  💬 "Commander, I recommend the First Flight mission. The warp coil │
│      is critical for our launch preparations." - Ship Computer       │
│                                                                       │
│  [ESC] Back to Dashboard        [ENTER] Start Selected Mission      │
└───────────────────────────────────────────────────────────────────────┘
```

### Features

**Mission List Panel (Left):**
- Shows 5-10 missions at once (scrollable)
- Each mission entry shows:
  - Mission title
  - Difficulty (1-5 stars)
  - Primary reward type (icon)
  - Location
  - Lock icon if requirements not met
- Visual indicators:
  - ► = Available and ready
  - ⚡ = Currently selected
  - 🔒 = Locked (show requirement on hover)
  - ✓ = Completed (in mission history view)

**Mission Details Panel (Right):**
- Full mission information
- Expandable description
- Clear objectives list
- Guaranteed rewards shown
- Requirements checklist
- Estimated time
- Start button (prominent)

**Filtering & Sorting:**
- Filter by mission type (All, Salvage, Trade, Combat, Story)
- Sort by: Difficulty, Reward, Location, XP
- Search by keyword (future feature)

**Keyboard Navigation:**
- ↑/↓ - Navigate mission list
- Enter - Select/Start mission
- ESC - Back to dashboard
- Tab - Switch between panels

### Phase Differences

**Phase 1 (Workshop Dashboard):**
- Missions focused on Earth locations
- Salvage, trade, and rescue missions
- Short missions (10-30 minutes)
- Rewards: ship parts

**Phase 2 (Ship Dashboard):**
- Missions across multiple star systems
- Exploration, diplomacy, and combat missions
- Longer missions (30-60 minutes)
- Rewards: resources, data, alien tech

---

## Mission Play Screen

### Purpose
Execute the selected mission through choice-based narrative gameplay.

### Layout - Story Stage (1280x720)

```
┌─────────────────────────────────────────────────────────────────────┐
│  MISSION: First Flight                                   Stage 2/4  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  📍 KENNEDY SPACEPORT - HANGAR 7                              │  │
│  │                                                               │  │
│  │  [Generated Image / Scene Art]                                │  │
│  │                                                               │  │
│  │  (Optional: AI-generated location image shown here)           │  │
│  │                                                               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  SITUATION                                                    │  │
│  │  ═════════                                                    │  │
│  │                                                               │  │
│  │  You approach the rusted gates of Hangar 7. The massive      │  │
│  │  structure looms before you, its walls scarred by decades    │  │
│  │  of neglect. Your scanner picks up faint power signatures    │  │
│  │  inside—the security drones are still active.                │  │
│  │                                                               │  │
│  │  Through a crack in the door, you spot the warp coil         │  │
│  │  mounted on an old transport vessel. It's intact, but        │  │
│  │  getting to it won't be easy. Three drones patrol the        │  │
│  │  hangar in a predictable pattern.                            │  │
│  │                                                               │  │
│  │  How do you proceed?                                          │  │
│  │                                                               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  YOUR CHOICES                                                 │  │
│  │  ════════════                                                 │  │
│  │                                                               │  │
│  │  [A] Hack the security terminal                              │  │
│  │      🔧 Requires: Engineering 3 (You have: 7) ✓              │  │
│  │      Disable the drones remotely. Safe but time-consuming.   │  │
│  │                                                               │  │
│  │  [B] Sneak past the drones                                   │  │
│  │      No requirements                                          │  │
│  │      Wait for the patrol pattern and slip through. Risky.    │  │
│  │                                                               │  │
│  │  [C] Disable the drones by force                             │  │
│  │      ⚔️ Requires: Combat 2 (You have: 5) ✓                   │  │
│  │      Destroy them with your plasma cutter. Loud and messy.   │  │
│  │                                                               │  │
│  │  [D] Find another entrance                                   │  │
│  │      💬 Requires: Diplomacy 4 (You have: 4) ✓                │  │
│  │      Talk to the local scavenger for intel on a back door.   │  │
│  │                                                               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  💬 "The hacking approach has a 95% success rate based on your      │
│      current Engineering skill." - Ship Computer                     │
│                                                                       │
│  [A] [B] [C] [D] - Make Choice    [ESC] - Mission Menu (Pause)      │
└───────────────────────────────────────────────────────────────────────┘
```

### Layout - Skill Check Result

```
┌─────────────────────────────────────────────────────────────────────┐
│  MISSION: First Flight                                   Stage 2/4  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  🎲 SKILL CHECK: ENGINEERING                                  │  │
│  │  ═════════════════════════════════════════════════════════    │  │
│  │                                                               │  │
│  │  Difficulty: Medium (DC 12)                                   │  │
│  │  Your Skill: Engineering 7                                    │  │
│  │  Bonus: +5 (skill bonus)                                      │  │
│  │                                                               │  │
│  │  Rolling... [██████████] 14 + 5 = 19                         │  │
│  │                                                               │  │
│  │  ✅ SUCCESS!                                                  │  │
│  │                                                               │  │
│  │  You quickly interface with the security terminal. The       │  │
│  │  encryption is outdated—child's play for someone with your   │  │
│  │  experience. Within minutes, you've disabled all three        │  │
│  │  drones and unlocked the hangar doors.                       │  │
│  │                                                               │  │
│  │  The warp coil is yours for the taking.                      │  │
│  │                                                               │  │
│  │  +25 XP (skill check bonus)                                   │  │
│  │                                                               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  [CONTINUE →]                                                        │
└───────────────────────────────────────────────────────────────────────┘
```

### Features

**Narrative Panel:**
- Rich text description of current situation
- Location header with icon
- Optional AI-generated scene image (future feature)
- Scrollable for long descriptions

**Choice System:**
- 2-5 choices per stage
- Color-coded skill requirements:
  - ✓ Green = You meet requirement
  - ⚠️ Yellow = Close but might fail
  - ✗ Red = Don't meet requirement
- Consequence preview on hover
- Clear labeling (A, B, C, D for keyboard)

**Skill Checks:**
- Visual dice roll animation
- Show difficulty class (DC)
- Show your skill modifier
- Clear success/failure indication
- Bonus XP for successful checks

**Progress Tracking:**
- Stage counter (2/4)
- Mission objectives checklist (sidebar)
- Can save mid-mission
- Can abandon mission (with consequences)

### Mission Flow

```
Mission Start
    ↓
Stage 1 (Introduction)
    ↓
Player Choice
    ↓
Skill Check (if applicable)
    ↓
Consequence/Result
    ↓
Stage 2 (Middle)
    ↓
Player Choice
    ↓
...
    ↓
Final Stage (Conclusion)
    ↓
Mission Complete
    ↓
Rewards Screen
    ↓
Return to Dashboard
```

### Pause Menu (ESC)

```
┌─────────────────────────────────┐
│  MISSION PAUSED                 │
├─────────────────────────────────┤
│                                 │
│  [Resume Mission]               │
│  [View Objectives]              │
│  [Save Progress]                │
│  [Abandon Mission]              │
│  [Return to Dashboard]          │
│                                 │
└─────────────────────────────────┘
```

---

## Ship Systems Management Screen

### Purpose
Detailed view and management of all 10 ship systems. Install parts, distribute power, repair damage.

### Layout (1280x720)

```
┌─────────────────────────────────────────────────────────────────────┐
│  [←] SHIP SYSTEMS MANAGEMENT             SS Endeavor - Scout-class  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────────┐  ┌────────────────────────────────────┐  │
│  │  SYSTEM LIST         │  │  SYSTEM DETAILS: POWER CORE        │  │
│  │  ═══════════         │  │  ═══════════════════════════════   │  │
│  │                      │  │                                    │  │
│  │  ⚡ Power Core  L2   │  │  Level 2: Deuterium Reactor        │  │
│  │    [██████████] 100% │  │  Status: ✓ ONLINE                  │  │
│  │                      │  │  Health: [██████████] 100%         │  │
│  │  🛡️ Hull        L2   │  │                                    │  │
│  │    [████████░░] 85%  │  │  POWER OUTPUT:                     │  │
│  │                      │  │  200 PU (Power Units)              │  │
│  │  🚀 Propulsion  L2   │  │  Efficiency: 85%                   │  │
│  │    [██████████] 100% │  │                                    │  │
│  │                      │  │  INSTALLED PART:                   │  │
│  │  🌀 Warp Drive  L1   │  │  ⚙️ Deuterium Reactor Core         │  │
│  │    [██████████] 100% │  │  Rarity: Uncommon                  │  │
│  │                      │  │  Condition: Excellent              │  │
│  │  💨 Life Support L1  │  │                                    │  │
│  │    [██████████] 100% │  │  CAPABILITIES:                     │  │
│  │                      │  │  • Supports up to 4 systems        │  │
│  │  💻 Computer    L2   │  │  • -10% power cost to all systems  │  │
│  │    [██████████] 100% │  │  • Stable energy output            │  │
│  │                      │  │                                    │  │
│  │  📡 Sensors     L2   │  │  UPGRADE PATH:                     │  │
│  │    [██████████] 100% │  │  Next Level (L3): M/AM Reactor     │  │
│  │                      │  │  Requirements:                     │  │
│  │  🛡️ Shields     L1   │  │  • Matter/Antimatter Core          │  │
│  │    [██████████] 100% │  │  • Magnetic Containment            │  │
│  │                      │  │  • Antimatter Pod                  │  │
│  │  ⚔️ Weapons     L0   │  │                                    │  │
│  │    [NOT INSTALLED]   │  │  Benefits:                         │  │
│  │                      │  │  • +200 PU (400 total)             │  │
│  │  📞 Comms       L2   │  │  • 90% efficiency (-15% cost)      │  │
│  │    [██████████] 100% │  │                                    │  │
│  │                      │  │  [UPGRADE] (parts available)       │  │
│  │                      │  │  [REPAIR] (not needed)             │  │
│  │                      │  │  [DEACTIVATE] (save power)         │  │
│  └──────────────────────┘  └────────────────────────────────────┘  │
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  POWER MANAGEMENT                                             │  │
│  │  ════════════════                                             │  │
│  │                                                               │  │
│  │  Total Power: 200 PU  |  Used: 135 PU  |  Available: 65 PU   │  │
│  │                                                               │  │
│  │  Power Distribution:                                          │  │
│  │  🛡️ Hull:          0 PU  ████                                │  │
│  │  🚀 Propulsion:   15 PU  ██████                              │  │
│  │  🌀 Warp Drive:   20 PU  ████████                            │  │
│  │  💨 Life Support:  5 PU  ██                                  │  │
│  │  💻 Computer:     10 PU  ████                                │  │
│  │  📡 Sensors:      10 PU  ████                                │  │
│  │  🛡️ Shields:      15 PU  ██████                              │  │
│  │  📞 Comms:         8 PU  ███                                 │  │
│  │                                                               │  │
│  │  [OPTIMIZE POWER] [PRIORITY MODE] [EMERGENCY SHUTDOWN]       │  │
│  │                                                               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  💬 "Power distribution is efficient. All systems operating within  │
│      normal parameters." - Ship Computer                             │
│                                                                       │
│  [TAB] Switch System    [SPACE] Quick Actions    [ESC] Back          │
└───────────────────────────────────────────────────────────────────────┘
```

### Features

**System List (Left):**
- All 10 systems shown with icons
- Current level (L0-L5)
- Health bar (visual indicator)
- Status icons:
  - ✓ = Online and healthy
  - ⚠️ = Damaged or low power
  - ✗ = Offline or not installed
  - ○ = Installed but unpowered
- Click to view details

**System Details (Right):**
- Current level and name
- Status and health
- Installed part information
- Current capabilities
- Upgrade path with requirements
- Action buttons (Upgrade, Repair, Deactivate)

**Power Management Panel (Bottom):**
- Total power generation
- Power consumption breakdown
- Visual bars showing distribution
- Quick action buttons:
  - **Optimize Power** - Auto-balance for efficiency
  - **Priority Mode** - Focus power on critical systems
  - **Emergency Shutdown** - Disable non-essential systems

**Quick Actions:**
- **Install Part** - Select from inventory
- **Auto-Repair All** - Use repair kits on all damaged systems
- **Power Preset** - Load saved power configuration
- **Export Build** - Share ship configuration (future)

### System Detail Modal (Popup)

When clicking "View Details" on a system:

```
┌─────────────────────────────────────────┐
│  WARP DRIVE - LEVEL 1                   │
├─────────────────────────────────────────┤
│                                         │
│  Status: ONLINE                         │
│  Health: 100%                           │
│  Power Cost: 20 PU                      │
│                                         │
│  STATISTICS:                            │
│  Warp Factor: 1 (1× light speed)       │
│  Range: 2 light years                  │
│  Travel Time: 1 day per LY             │
│  Accessible Systems: 3 nearby          │
│                                         │
│  INSTALLED PART:                        │
│  Warp Core Mk1 (Common)                │
│  Condition: Good (92%)                  │
│  Acquired: Day 12                       │
│                                         │
│  UPGRADE OPTIONS:                       │
│  Level 2: Warp 3 Drive                 │
│  Requires:                              │
│  • Enhanced Warp Coils (Have: ✓)       │
│  • Field Stabilizer (Have: ✗)          │
│                                         │
│  [UPGRADE] [REPAIR] [UNINSTALL] [CLOSE]│
│                                         │
└─────────────────────────────────────────┘
```

---

## Inventory Management Screen

### Purpose
View, organize, and manage all items including ship parts, equipment, resources, and quest items.

### Layout (1280x720)

```
┌─────────────────────────────────────────────────────────────────────┐
│  [←] INVENTORY                              Capacity: 28/40 (70%)   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────┐  ┌────────────────────────────────────────────┐  │
│  │  CATEGORIES  │  │  ITEMS - SHIP PARTS (12 items)             │  │
│  │  ══════════  │  │  ══════════════════════════════════════════ │  │
│  │              │  │                                            │  │
│  │  ⚙️ Ship     │  │  ┌──────────────┐  ┌──────────────┐       │  │
│  │    Parts (12)│  │  │ Reinforced   │  │ Enhanced     │       │  │
│  │              │  │  │ Hull Plating │  │ Sensors      │       │  │
│  │  🎒 Equipment│  │  │              │  │              │       │  │
│  │    (5)       │  │  │ Uncommon     │  │ Rare         │       │  │
│  │              │  │  │ Hull L2      │  │ Sensors L3   │       │  │
│  │  📦 Resources│  │  │              │  │              │       │  │
│  │    (8)       │  │  │ [INSTALL]    │  │ [INSTALL]    │       │  │
│  │              │  │  └──────────────┘  └──────────────┘       │  │
│  │  📜 Quest    │  │                                            │  │
│  │    Items (3) │  │  ┌──────────────┐  ┌──────────────┐       │  │
│  │              │  │  │ Shield       │  │ Warp Coil    │       │  │
│  │  🗑️ Junk     │  │  │ Generator    │  │ Mk2          │       │  │
│  │    (0)       │  │  │              │  │              │       │  │
│  │              │  │  │ Uncommon     │  │ Common       │       │  │
│  │              │  │  │ Shields L2   │  │ Warp L1      │       │  │
│  │              │  │  │              │  │              │       │  │
│  │              │  │  │ [INSTALL]    │  │ [INSTALL]    │       │  │
│  │              │  │  └──────────────┘  └──────────────┘       │  │
│  │  Filter:     │  │                                            │  │
│  │  [All ▼]     │  │  (Grid continues with more items...)       │  │
│  │              │  │                                            │  │
│  │  Sort:       │  │  ┌─────────────────────────────────────┐  │  │
│  │  [Name ▼]    │  │  │ [Auto-Install Best Parts]           │  │  │
│  │              │  │  │ [Sort by Level] [Show Only Usable]  │  │  │
│  └──────────────┘  │  └─────────────────────────────────────┘  │  │
│                    └────────────────────────────────────────────┘  │
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  ITEM DETAILS: REINFORCED HULL PLATING                        │  │
│  │  ═══════════════════════════════════════════════════════════  │  │
│  │                                                               │  │
│  │  Type: Ship Part (Hull System)                                │  │
│  │  Rarity: Uncommon                                             │  │
│  │  Level: 2                                                     │  │
│  │  Condition: Excellent (98%)                                   │  │
│  │                                                               │  │
│  │  STATS:                                                       │  │
│  │  • Max HP: +50 (100 total)                                    │  │
│  │  • Armor: 15% kinetic reduction                              │  │
│  │  • Weight: Medium                                             │  │
│  │                                                               │  │
│  │  DESCRIPTION:                                                 │  │
│  │  Proper hull plating with reinforced stress points. Salvaged │  │
│  │  from a decommissioned patrol vessel. Shows minimal wear.    │  │
│  │                                                               │  │
│  │  Acquired: Day 8 (Mission: "Power Struggle")                 │  │
│  │  Value: 450 credits                                           │  │
│  │                                                               │  │
│  │  [INSTALL ON SHIP] [SELL] [DROP] [DETAILS]                   │  │
│  │                                                               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  💬 "The reinforced hull plating would significantly improve our    │
│      survivability. I recommend installation." - Ship Computer       │
│                                                                       │
│  [1-5] Category    [SPACE] Quick Install    [DEL] Drop    [ESC] Back│
└───────────────────────────────────────────────────────────────────────┘
```

### Features

**Category Sidebar (Left):**
- **Ship Parts** (⚙️) - Parts for all 10 systems
- **Equipment** (🎒) - Personal gear (future: affects player stats)
- **Resources** (📦) - Consumables, materials, fuel
- **Quest Items** (📜) - Story-important items
- **Junk** (🗑️) - Sellable trash
- Item count per category

**Item Grid (Center):**
- Card-based layout (2-4 items per row)
- Each card shows:
  - Item icon/image
  - Item name
  - Rarity (color-coded border)
  - System type and level (for parts)
  - Primary action button (Install/Use/Equip)
- Scrollable for large inventories
- Drag-and-drop to organize (future)

**Item Details Panel (Bottom):**
- Full item information
- Stats and effects
- Description and lore
- Acquisition info (where/when obtained)
- Value (for selling)
- Action buttons (Install, Sell, Drop, Details)

**Quick Actions:**
- **Auto-Install Best** - Automatically install highest-level parts
- **Sell All Junk** - Quick cleanup
- **Sort** - By name, rarity, level, recent
- **Filter** - Show only usable, show only parts, etc.

**Storage Management:**
- Two-tier inventory system (from player-progression-system.md):
  - **Player Equipment** (4 slots) - What you carry
  - **Ship Storage** (16-32 slots) - Bulk storage
- Move items between player and ship
- Visual capacity indicator
- Warning when near full

### Item Rarity Color Coding

```
Common     - Gray border, white text
Uncommon   - Green border
Rare       - Blue border, glowing
Epic       - Purple border, glowing
Legendary  - Orange/gold border, animated glow
Quest      - Yellow border, special icon
```

---

## Save/Load Screen

### Purpose
Save current game state to slots and load previously saved games.

### Layout (1280x720)

```
┌─────────────────────────────────────────────────────────────────────┐
│  [←] SAVE / LOAD GAME                                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────── [SAVE] ──────────┐  ┌──────── [LOAD] ────────┐       │
│  │                              │  │                        │       │
│  └──────────────────────────────┘  └────────────────────────┘       │
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  SAVE SLOTS                                                   │  │
│  │  ══════════                                                   │  │
│  │                                                               │  │
│  │  ┌─────────────────────────────────────────────────────┐     │  │
│  │  │  SLOT 1: "Endeavor - First Flight"                  │     │  │
│  │  │  ─────────────────────────────────────────────────  │     │  │
│  │  │                                                     │     │  │
│  │  │  [Thumbnail: Ship schematic or location image]     │     │  │
│  │  │                                                     │     │  │
│  │  │  Player: Cmdr. Elena Ward                           │     │  │
│  │  │  Level: 5  |  Rank: Lieutenant                     │     │  │
│  │  │  Ship: SS Endeavor (Scout-class)                   │     │  │
│  │  │  Systems: 8/10 Installed                           │     │  │
│  │  │  Location: Workshop - Earth Sector 7               │     │  │
│  │  │  Playtime: 4h 23m                                  │     │  │
│  │  │  Saved: Nov 6, 2025 - 14:32                        │     │  │
│  │  │                                                     │     │  │
│  │  │  [SAVE] [LOAD] [DELETE] [EXPORT]                   │     │  │
│  │  └─────────────────────────────────────────────────────┘     │  │
│  │                                                               │  │
│  │  ┌─────────────────────────────────────────────────────┐     │  │
│  │  │  SLOT 2: "Phoenix Rising"                           │     │  │
│  │  │  ─────────────────────────────────────────────────  │     │  │
│  │  │                                                     │     │  │
│  │  │  [Thumbnail]                                        │     │  │
│  │  │                                                     │     │  │
│  │  │  Player: Capt. Marcus Chen                          │     │  │
│  │  │  Level: 12  |  Rank: Commander                     │     │  │
│  │  │  Ship: SS Phoenix (Destroyer-class)                │     │  │
│  │  │  Systems: 10/10 Installed                          │     │  │
│  │  │  Location: Alpha Centauri System                   │     │  │
│  │  │  Playtime: 12h 8m                                  │     │  │
│  │  │  Saved: Nov 5, 2025 - 09:15                        │     │  │
│  │  │                                                     │     │  │
│  │  │  [SAVE] [LOAD] [DELETE] [EXPORT]                   │     │  │
│  │  └─────────────────────────────────────────────────────┘     │  │
│  │                                                               │  │
│  │  ┌─────────────────────────────────────────────────────┐     │  │
│  │  │  SLOT 3: [EMPTY]                                    │     │  │
│  │  │  ─────────────────────────────────────────────────  │     │  │
│  │  │                                                     │     │  │
│  │  │  No save data                                       │     │  │
│  │  │                                                     │     │  │
│  │  │  [NEW GAME]                                         │     │  │
│  │  └─────────────────────────────────────────────────────┘     │  │
│  │                                                               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ⚠️  WARNING: Overwriting a save slot cannot be undone!             │
│                                                                       │
│  [F5] Quick Save    [F9] Quick Load    [ESC] Back                   │
└───────────────────────────────────────────────────────────────────────┘
```

### Features

**Save/Load Tabs:**
- Toggle between Save mode and Load mode
- Same slot layout, different actions highlighted

**Save Slot Cards:**
- Thumbnail image (ship schematic or location screenshot)
- Player name and stats
- Ship name and class
- Progression info (systems installed, phase)
- Current location
- Total playtime
- Last saved timestamp
- Action buttons

**Actions:**
- **SAVE** - Overwrite this slot with current game
- **LOAD** - Load this save file
- **DELETE** - Permanently delete save (with confirmation)
- **EXPORT** - Export save file to share (future)
- **IMPORT** - Import someone else's save (future)

**Quick Save/Load:**
- F5 - Quick save to last used slot
- F9 - Quick load from last used slot
- Confirmation prompt before overwriting
- Auto-save slot (cannot be deleted)

**Confirmation Dialogs:**

Save confirmation:
```
┌─────────────────────────────────┐
│  CONFIRM SAVE                   │
├─────────────────────────────────┤
│                                 │
│  Overwrite Slot 1?              │
│  "Endeavor - First Flight"      │
│                                 │
│  Current progress will be saved │
│  and previous save will be lost.│
│                                 │
│  [SAVE] [CANCEL]                │
│                                 │
└─────────────────────────────────┘
```

Delete confirmation:
```
┌─────────────────────────────────┐
│  ⚠️  DELETE SAVE FILE           │
├─────────────────────────────────┤
│                                 │
│  Permanently delete Slot 2?     │
│  "Phoenix Rising"               │
│                                 │
│  This cannot be undone!         │
│                                 │
│  Type DELETE to confirm:        │
│  [________________]             │
│                                 │
│  [DELETE] [CANCEL]              │
│                                 │
└─────────────────────────────────┘
```

### Cloud Save (Future)

```
┌─────────────────────────────────┐
│  CLOUD SAVE (FUTURE)            │
├─────────────────────────────────┤
│                                 │
│  ☁️  Sync with Cloud            │
│                                 │
│  Last synced: 2 hours ago       │
│  Cloud saves: 3/3 slots used    │
│                                 │
│  [UPLOAD] [DOWNLOAD] [MANAGE]  │
│                                 │
└─────────────────────────────────┘
```

---

## Settings Screen

### Purpose
Configure game settings, AI providers, visual preferences, and controls.

### Layout (1280x720)

```
┌─────────────────────────────────────────────────────────────────────┐
│  [←] SETTINGS                                                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────┐  ┌────────────────────────────────────────────┐  │
│  │  CATEGORIES  │  │  GENERAL SETTINGS                          │  │
│  │  ══════════  │  │  ════════════════════════════════════════  │  │
│  │              │  │                                            │  │
│  │  ⚙️ General  │  │  Difficulty:  [Normal ▼]                  │  │
│  │              │  │  - Easy: Forgiving skill checks           │  │
│  │  🎨 Display  │  │  - Normal: Balanced challenge             │  │
│  │              │  │  - Hard: Punishing failures               │  │
│  │  🔊 Audio    │  │                                            │  │
│  │              │  │  Auto-Save:  [Enabled ✓]                  │  │
│  │  🎮 Controls │  │  Interval: [5 minutes ▼]                  │  │
│  │              │  │                                            │  │
│  │  🤖 AI Setup │  │  Tutorial Hints: [Enabled ✓]              │  │
│  │              │  │                                            │  │
│  │  🎨 Custom   │  │  Text Speed: [Fast ▼]                     │  │
│  │    Dashboards│  │  - Instant, Fast, Normal, Slow            │  │
│  │              │  │                                            │  │
│  │  📊 Advanced │  │  Skip Cutscenes: [Disabled ☐]             │  │
│  │              │  │                                            │  │
│  │              │  │  Confirm Destructive Actions: [Enabled ✓] │  │
│  │              │  │                                            │  │
│  │              │  │  Language: [English ▼]                     │  │
│  │              │  │                                            │  │
│  │              │  │  [RESET TO DEFAULTS]                       │  │
│  │              │  │                                            │  │
│  └──────────────┘  └────────────────────────────────────────────┘  │
│                                                                       │
│  ⚠️  Some settings require restart to take effect                   │
│                                                                       │
│  [APPLY] [CANCEL] [ESC] Back                                        │
└───────────────────────────────────────────────────────────────────────┘
```

### Settings Categories

#### 1. General Settings
- Difficulty (Easy, Normal, Hard)
- Auto-save (On/Off, Interval)
- Tutorial hints (On/Off)
- Text speed (Instant, Fast, Normal, Slow)
- Skip cutscenes (On/Off)
- Confirm destructive actions (On/Off)
- Language

#### 2. Display Settings
```
┌────────────────────────────────────────────┐
│  DISPLAY SETTINGS                          │
│  ════════════════════════════════════════  │
│                                            │
│  Resolution: [1920x1080 ▼]                │
│  - 1280x720 (HD)                          │
│  - 1920x1080 (Full HD)                    │
│  - 2560x1440 (2K)                         │
│  - 3840x2160 (4K)                         │
│                                            │
│  Display Mode: [Fullscreen ▼]             │
│  - Windowed                                │
│  - Fullscreen                              │
│  - Borderless Window                       │
│                                            │
│  VSync: [Enabled ✓]                       │
│                                            │
│  FPS Limit: [60 FPS ▼]                    │
│  - Unlimited, 120, 60, 30                 │
│                                            │
│  UI Scale: [100% ▼]                       │
│  - 75%, 100%, 125%, 150%                  │
│                                            │
│  Colorblind Mode: [None ▼]                │
│  - None, Protanopia, Deuteranopia,        │
│    Tritanopia                              │
│                                            │
│  High Contrast: [Disabled ☐]              │
│                                            │
│  Show FPS Counter: [Disabled ☐]           │
│                                            │
└────────────────────────────────────────────┘
```

#### 3. Audio Settings
```
┌────────────────────────────────────────────┐
│  AUDIO SETTINGS                            │
│  ════════════════════════════════════════  │
│                                            │
│  Master Volume: [████████░░] 80%          │
│                                            │
│  Music Volume:  [██████░░░░] 60%          │
│                                            │
│  SFX Volume:    [████████░░] 80%          │
│                                            │
│  Voice Volume:  [██████████] 100%         │
│  (AI-generated narration - future)         │
│                                            │
│  Mute When Unfocused: [Enabled ✓]        │
│                                            │
│  Audio Device: [Default ▼]                │
│                                            │
└────────────────────────────────────────────┘
```

#### 4. Controls Settings
```
┌────────────────────────────────────────────┐
│  CONTROLS SETTINGS                         │
│  ════════════════════════════════════════  │
│                                            │
│  Control Scheme: [Keyboard + Mouse ▼]     │
│  - Keyboard + Mouse                        │
│  - Gamepad (Xbox)                          │
│  - Gamepad (PlayStation)                   │
│  - Custom                                  │
│                                            │
│  KEY BINDINGS:                             │
│                                            │
│  Ship Systems:    [1]    [REBIND]         │
│  Missions:        [2]    [REBIND]         │
│  Inventory:       [3]    [REBIND]         │
│  Save/Load:       [4]    [REBIND]         │
│  Settings:        [5]    [REBIND]         │
│  Ship Manual:     [6]    [REBIND]         │
│  Main Menu:       [ESC]  [REBIND]         │
│  Quick Save:      [F5]   [REBIND]         │
│  Quick Load:      [F9]   [REBIND]         │
│                                            │
│  [RESET TO DEFAULTS]                       │
│                                            │
└────────────────────────────────────────────┘
```

#### 5. AI Setup (Important!)
```
┌────────────────────────────────────────────┐
│  AI PROVIDER SETUP                         │
│  ════════════════════════════════════════  │
│                                            │
│  Primary Provider: [Ollama (Local) ▼]     │
│  - OpenAI (Cloud - requires API key)      │
│  - Anthropic Claude (Cloud - requires key)│
│  - Google Gemini (Cloud - requires key)   │
│  - Ollama (Local - free)                  │
│                                            │
│  ┌──────────────────────────────────────┐ │
│  │  OLLAMA CONFIGURATION                │ │
│  │  ════════════════════════════════    │ │
│  │                                      │ │
│  │  Status: ✓ Connected                │ │
│  │  URL: http://localhost:11434        │ │
│  │                                      │ │
│  │  Model: [llama2 ▼]                  │ │
│  │  - llama2 (7B)                      │ │
│  │  - llama2:13b                       │ │
│  │  - codellama                        │ │
│  │  - mistral                          │ │
│  │                                      │ │
│  │  Temperature: [0.8] (creativity)    │ │
│  │                                      │ │
│  │  [TEST CONNECTION]                   │ │
│  │                                      │ │
│  └──────────────────────────────────────┘ │
│                                            │
│  TASK-SPECIFIC PROVIDERS:                 │
│  (Use different AI for different tasks)   │
│                                            │
│  Story Generation:   [Ollama ▼]           │
│  Quick Responses:    [Ollama ▼]           │
│  Image Generation:   [Disabled ▼]         │
│  Voice Transcription:[Disabled ▼]         │
│                                            │
│  AI Generation Cache: [Enabled ✓]        │
│  Cache Duration: [24 hours ▼]            │
│                                            │
│  [ADVANCED AI SETTINGS →]                 │
│                                            │
└────────────────────────────────────────────┘
```

**OpenAI Configuration:**
```
┌──────────────────────────────────────┐
│  OPENAI CONFIGURATION                │
│  ════════════════════════════════    │
│                                      │
│  API Key: [sk-***************]      │
│  Status: ✓ Valid (verified)        │
│                                      │
│  Model: [gpt-4 ▼]                   │
│  - gpt-3.5-turbo (Faster, cheaper) │
│  - gpt-4 (Better quality)          │
│  - gpt-4-turbo                     │
│                                      │
│  Temperature: [0.8]                 │
│  Max Tokens: [2000]                 │
│                                      │
│  Usage This Month:                  │
│  Tokens: 45,230 (~$0.23)           │
│  Requests: 127                      │
│                                      │
│  [VERIFY KEY] [USAGE DETAILS]       │
│                                      │
└──────────────────────────────────────┘
```

#### 6. Custom Dashboards
```
┌────────────────────────────────────────────┐
│  DASHBOARD CUSTOMIZATION                   │
│  ════════════════════════════════════════  │
│                                            │
│  Current Style: Classic LCARS              │
│                                            │
│  ┌──────────────────────────────────────┐ │
│  │  [Thumbnail of current dashboard]    │ │
│  └──────────────────────────────────────┘ │
│                                            │
│  PRESET STYLES (Free):                    │
│  ○ Classic LCARS (Star Trek)              │
│  ○ Industrial Workshop                     │
│  ○ Minimalist Dark                         │
│  ○ Retro NASA                              │
│  ○ Holographic Blue                        │
│  ○ Cyberpunk Neon                          │
│                                            │
│  AI-GENERATED CUSTOM (Requires AI):       │
│  [GENERATE CUSTOM STYLE]                   │
│                                            │
│  Provider: [OpenAI DALL-E 3 ▼]            │
│  Estimated cost: ~$0.10                    │
│                                            │
│  See "Dashboard Evolution" docs for        │
│  full customization guide.                 │
│                                            │
└────────────────────────────────────────────┘
```

#### 7. Advanced Settings
```
┌────────────────────────────────────────────┐
│  ADVANCED SETTINGS                         │
│  ════════════════════════════════════════  │
│                                            │
│  ⚠️  Only change if you know what you're   │
│     doing!                                 │
│                                            │
│  Debug Mode: [Disabled ☐]                 │
│  Show Console: [Disabled ☐]               │
│  Log Level: [Info ▼]                      │
│                                            │
│  Data Location:                            │
│  /home/user/.local/space-adventures/      │
│  [OPEN FOLDER]                             │
│                                            │
│  Cache Management:                         │
│  AI Response Cache: 142 MB                 │
│  Image Cache: 38 MB                        │
│  [CLEAR CACHE]                             │
│                                            │
│  Database:                                 │
│  Global DB: Connected (PostgreSQL)         │
│  Save DB: 3 slots, 5.2 MB total           │
│  [BACKUP DATABASE] [RESTORE]               │
│                                            │
│  Performance:                              │
│  Multi-threading: [Enabled ✓]            │
│  Async Loading: [Enabled ✓]              │
│  Texture Compression: [Enabled ✓]        │
│                                            │
│  [RESET ALL SETTINGS TO DEFAULT]           │
│                                            │
└────────────────────────────────────────────┘
```

---

## Ship Manual Screen

### Purpose
In-game help system with tutorials, system explanations, and game mechanics documentation.

### Layout (1280x720)

```
┌─────────────────────────────────────────────────────────────────────┐
│  [←] SHIP MANUAL                                        [SEARCH 🔍] │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────┐  ┌────────────────────────────────────────┐  │
│  │  TABLE OF        │  │  SHIP SYSTEMS OVERVIEW                 │  │
│  │  CONTENTS        │  │  ═══════════════════════════════════   │  │
│  │  ═══════════     │  │                                        │  │
│  │                  │  │  Your ship consists of 10 core systems │  │
│  │  Getting Started │  │  that work together to keep you alive  │  │
│  │  ├─ Tutorial     │  │  and operational. Each system can be   │  │
│  │  ├─ Controls     │  │  upgraded from Level 0 (not installed) │  │
│  │  └─ First Steps  │  │  to Level 5 (advanced technology).     │  │
│  │                  │  │                                        │  │
│  │  Ship Systems    │  │  THE 10 SHIP SYSTEMS:                  │  │
│  │  ├─ Hull         │  │                                        │  │
│  │  ├─ Power Core   │  │  1. HULL & STRUCTURE                   │  │
│  │  ├─ Propulsion   │  │     Physical integrity and HP          │  │
│  │  ├─ Warp Drive   │  │     Determines survivability           │  │
│  │  ├─ Life Support │  │                                        │  │
│  │  ├─ Computer     │  │  2. POWER CORE                         │  │
│  │  ├─ Sensors      │  │     Energy generation                  │  │
│  │  ├─ Shields      │  │     Powers all other systems           │  │
│  │  ├─ Weapons      │  │                                        │  │
│  │  └─ Comms        │  │  3. PROPULSION (Impulse Engines)       │  │
│  │                  │  │     Sub-light maneuvering              │  │
│  │  Gameplay        │  │     Affects dodge and combat agility   │  │
│  │  ├─ Missions     │  │                                        │  │
│  │  ├─ Skills       │  │  4. WARP DRIVE                         │  │
│  │  ├─ Progression  │  │     Faster-than-light travel           │  │
│  │  ├─ Combat       │  │     Required to leave Earth orbit      │  │
│  │  └─ Trading      │  │                                        │  │
│  │                  │  │  [Continue reading...]                 │  │
│  │  Ship Classes    │  │                                        │  │
│  │  ├─ Overview     │  │  ┌──────────────────────────────────┐ │  │
│  │  ├─ Scout        │  │  │  Quick Links:                    │ │  │
│  │  ├─ Explorer     │  │  │  • Power Management Guide        │ │  │
│  │  └─ (more...)    │  │  │  • System Upgrade Paths          │ │  │
│  │                  │  │  │  • System Interactions           │ │  │
│  │  Lore & Story    │  │  └──────────────────────────────────┘ │  │
│  │  ├─ The Exodus   │  │                                        │  │
│  │  ├─ Earth Today  │  │  [NEXT PAGE →]  [PREVIOUS PAGE ←]     │  │
│  │  └─ Factions     │  │                                        │  │
│  │                  │  │                                        │  │
│  │  Reference       │  │                                        │  │
│  │  ├─ Controls     │  │                                        │  │
│  │  ├─ Items        │  │                                        │  │
│  │  └─ Glossary     │  │                                        │  │
│  └──────────────────┘  └────────────────────────────────────────┘  │
│                                                                       │
│  [TAB] Next Section    [SHIFT+TAB] Previous    [ESC] Back            │
└───────────────────────────────────────────────────────────────────────┘
```

### Features

**Table of Contents (Left):**
- Hierarchical navigation
- Expandable/collapsible sections
- Click to jump to section
- Current section highlighted
- Search filtering (shows matching sections)

**Content Panel (Right):**
- Rich text formatting
- Images and diagrams
- Code examples (for modding, future)
- Tables and charts
- Hyperlinks to related topics
- Pagination for long sections

**Search Function:**
- Full-text search across all manual
- Highlights matches
- Jump to results
- Filter table of contents

**Quick Links:**
- Jump to commonly accessed topics
- Recent pages visited
- Bookmarks (future)

### Content Sections

**1. Getting Started:**
- Tutorial walkthrough
- Controls reference
- First mission guide
- UI explanation

**2. Ship Systems:**
- Detailed explanation of each of the 10 systems
- Level progression tables
- Power consumption charts
- Upgrade requirements
- System synergies

**3. Gameplay:**
- Mission types explained
- Skill system guide
- XP and leveling
- Combat mechanics (Phase 2)
- Trading and economy (Phase 2)

**4. Ship Classes:**
- Classification system explained
- All 10 ship classes detailed
- Requirements and bonuses
- Build recommendations

**5. Lore & Story:**
- The Exodus event
- Post-Exodus Earth
- Known factions
- Timeline of events
- Character backgrounds (if relevant)

**6. Reference:**
- Complete controls list
- Item database
- Glossary of terms
- Tips and tricks
- FAQ

### Dynamic Content

Content updates based on game progress:
- Tutorials marked complete when done
- New sections unlock as features are discovered
- Spoiler warnings for story content
- "NEW" badges on recently added content

---

## Design Principles

### Consistency

**Visual Consistency:**
- All screens use the same theme and color palette
- Headers, buttons, and panels follow consistent styling
- Icons are from the same icon set
- Fonts are consistent (monospace for data, sans-serif for text)

**Behavioral Consistency:**
- ESC always goes back
- Enter/Space confirms actions
- Tab cycles through elements
- Arrow keys navigate lists
- Consistent placement (e.g., action buttons always bottom-right)

**Terminology Consistency:**
- "Systems" not "modules" or "components"
- "Credits" not "money" or "currency"
- "Mission" not "quest" or "job"
- "Ship" not "vessel" or "craft" (except for dramatic effect)

### Clarity

**Clear Hierarchy:**
- Most important info is largest/brightest
- Secondary info is smaller/dimmer
- Tertiary info is collapsed or hidden until needed

**Obvious Actions:**
- Buttons clearly labeled with verbs
- Icons supplemented with text labels
- Hover states indicate interactivity
- Disabled states are visually distinct

**Feedback:**
- Actions provide immediate visual feedback
- Success/failure clearly indicated
- Loading states shown for async operations
- Errors explained with actionable solutions

### Efficiency

**Minimal Clicks:**
- Most actions achievable in 1-3 clicks
- Common actions have shortcuts
- Quick action buttons for frequent tasks
- Batch operations where appropriate

**Keyboard Support:**
- All navigation possible via keyboard
- Shortcuts for power users
- Tab order logical and consistent
- Number keys for quick selection

**Smart Defaults:**
- Auto-select best option when obvious
- Remember last selection
- Suggest next logical action
- Pre-fill forms with sensible values

---

## Technical Specifications

### File Structure

```
godot/scenes/
├─ mission_select.tscn
├─ mission_play.tscn
├─ ship_systems.tscn
├─ inventory.tscn
├─ save_load.tscn
├─ settings.tscn
└─ ship_manual.tscn

godot/scripts/ui/
├─ mission_select_ui.gd
├─ mission_play_ui.gd
├─ ship_systems_ui.gd
├─ inventory_ui.gd
├─ save_load_ui.gd
├─ settings_ui.gd
└─ ship_manual_ui.gd

godot/assets/data/
├─ manual_content.json      # Ship manual text content
├─ settings_defaults.json   # Default settings
└─ keybindings.json        # Default key mappings
```

### Common UI Components (Shared)

Create reusable UI components:

```
godot/scenes/ui/components/
├─ panel_header.tscn        # Standard panel header
├─ action_button.tscn       # Styled button
├─ progress_bar.tscn        # Custom progress bar
├─ item_card.tscn           # Inventory item card
├─ system_card.tscn         # Ship system card
├─ mission_card.tscn        # Mission list item
├─ tooltip.tscn             # Hover tooltip
├─ modal_dialog.tscn        # Popup dialog
└─ dropdown_menu.tscn       # Dropdown selector
```

### Theme System

All screens use the shared theme:

```gdscript
# godot/themes/space_adventures_theme.tres

# Color Palette
primary_blue: #2E8BC0
secondary_blue: #B1D4E0
accent_yellow: #FFC857
success_teal: #2EC4B6
warning_orange: #FFB627
danger_red: #E63946
bg_dark: #0F1C2E
bg_panel: rgba(15, 28, 46, 0.95)
text_normal: #E8F1F2
text_dim: #8FA3AD

# Fonts
font_header: Roboto Bold 24pt
font_title: Roboto Bold 18pt
font_normal: Roboto Regular 16pt
font_small: Roboto Regular 14pt
font_mono: Roboto Mono Regular 16pt

# Components
button_normal: StyleBoxFlat (bg_panel, border: primary_blue)
button_hover: StyleBoxFlat (bg_panel, border: accent_yellow, glow)
button_pressed: StyleBoxFlat (darker, border: primary_blue, inset)
panel_default: StyleBoxFlat (bg_panel, border: primary_blue, rounded corners)
```

### Performance Targets

**All Screens:**
- Load time: <300ms
- Frame rate: 60 FPS minimum
- Smooth transitions: <200ms
- Responsive input: <50ms

**Inventory Screen:**
- Handle 500+ items without lag
- Grid rendering optimized
- Lazy loading for large inventories

**Mission Play Screen:**
- Rich text rendering optimized
- Image loading async with placeholders
- Smooth text scrolling

---

## Implementation Priority

### MVP (Week 2-3)

**Critical Path:**
1. ✅ Workshop Dashboard (Week 2, Days 10-12)
2. ⬜ Mission Select (Week 3, Day 15)
3. ⬜ Mission Play (Week 3, Days 17-19)
4. ⬜ Ship Systems (Week 2, Days 8-9 + Week 3)
5. ⬜ Inventory (Week 2, Days 13-14)
6. ⬜ Save/Load (Week 1, Days 5-7 + Week 3)
7. ⬜ Settings (Week 3 or Week 5)
8. ⬜ Ship Manual (Week 5, optional for MVP)

### Post-MVP (v1.1+)

**Enhancements:**
- Ship Dashboard (Phase 2)
- Advanced filtering and sorting
- Drag-and-drop inventory management
- Custom key bindings editor
- Achievement tracking screen
- Statistics screen
- Mission history viewer

---

## Summary

This document provides complete specifications for all 7 core game screens:

1. **Mission Select** - Browse and choose missions
2. **Mission Play** - Execute choice-based narrative missions
3. **Ship Systems** - Manage and upgrade all 10 ship systems
4. **Inventory** - Organize items and ship parts
5. **Save/Load** - Manage save game slots
6. **Settings** - Configure game, AI providers, and preferences
7. **Ship Manual** - In-game help and documentation

All screens follow consistent design principles:
- Visual consistency (same theme, colors, fonts)
- Clear hierarchy (important info stands out)
- Efficient navigation (minimal clicks, keyboard support)
- Smart defaults and helpful feedback

Ready for implementation starting Week 2! 🚀

---

**Document Status:** Complete and Ready for Implementation
**Last Updated:** November 6, 2025
**Next Steps:** Begin implementation per MVP roadmap
**Dependencies:** Workshop Dashboard, GameState, SaveManager, EventBus

Let's build these screens! 🎮
