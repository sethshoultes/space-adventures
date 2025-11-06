# Space Adventures - UI Graphics Generation Prompt Guide

**Version:** 1.0
**Date:** November 6, 2025
**Purpose:** Complete prompt guide for generating UI graphics with proper transparency and styling
**Status:** Ready for Asset Generation

---

## Table of Contents
1. [Overview](#overview)
2. [Technical Requirements](#technical-requirements)
3. [Base Style Guidelines](#base-style-guidelines)
4. [Ship HUD & Window Elements](#ship-hud--window-elements)
5. [Button & Menu Components](#button--menu-components)
6. [Panel & Container Elements](#panel--container-elements)
7. [Dashboard Backgrounds](#dashboard-backgrounds)
8. [Mission & Location Frames](#mission--location-frames)
9. [Status Indicators & Badges](#status-indicators--badges)
10. [Overlay & Modal Elements](#overlay--modal-elements)
11. [Quality Control Checklist](#quality-control-checklist)

---

## Overview

### Purpose

This guide provides detailed prompts for generating all UI graphics for Space Adventures. Each prompt is designed to produce assets with:
- **Proper transparency** (PNG with alpha channel)
- **Consistent style** (Star Trek LCARS / retro sci-fi aesthetic)
- **Correct dimensions** (optimized for 1280x720 base resolution)
- **Placeholder areas** for buttons, text, and interactive elements

### Design Philosophy

**Star Trek TNG Aesthetic:**
- Clean geometric shapes
- Bold accent colors (orange, blue, purple)
- Professional bridge interface look
- Functional over decorative
- Serious sci-fi tone

**Retro Sci-Fi Elements:**
- Pixel art influences (not full pixel art)
- 16-bit inspired color palettes
- Terminal/console aesthetics
- Minimalist but functional

---

## Technical Requirements

### File Specifications

```yaml
Format: PNG
Color Mode: RGBA (with alpha channel)
Bit Depth: 32-bit (8-bit per channel + 8-bit alpha)
Color Profile: sRGB

Base Resolution: 1280x720 (HD)
DPI: 72 (screen optimized)

Compression: PNG optimization enabled
File Size Target: <500KB per asset (most <200KB)
```

### Transparency Guidelines

**Fully Transparent Areas:**
- Center areas where UI content will be displayed
- Areas designated for text, buttons, menus
- Window interiors (for space/sky backgrounds)
- Button interior spaces

**Semi-Transparent Areas (20-60% opacity):**
- Background panels (to show space/sky behind)
- Overlay frames
- Shadow effects
- Ambient glow effects

**Opaque Areas (100% opacity):**
- Border lines and frames
- Accent elements (LCARS-style colored bars)
- Icon graphics
- Critical UI indicators

### Dimension Standards

```
Full Screen Elements:
- Dashboard backgrounds: 1280x720
- Full overlays: 1280x720

Large Panels:
- Main content panels: 900x600
- Ship schematic display: 800x600
- Mission image frames: 768x512

Medium Elements:
- Button panels: 200x50 to 400x80
- Status panels: 400x200
- Side panels: 300x600

Small Elements:
- Icons: 64x64, 128x128
- Badges: 48x48
- Indicators: 32x32 to 96x96
```

---

## Base Style Guidelines

### Color Palette

**Primary Colors:**
```
LCARS Orange: #FF9900 (primary accent)
LCARS Blue: #9999FF (secondary accent)
LCARS Purple: #CC99CC (tertiary accent)
LCARS Peach: #FFCC99 (highlight)
```

**Neutral Colors:**
```
Deep Space Black: #0A0E1A (background)
Panel Gray: #1A1F2E (secondary background)
Border Blue: #2E4C6D (borders and lines)
Text White: #E8F1F2 (primary text areas)
```

**Status Colors:**
```
Success Green: #2EC4B6
Warning Yellow: #FFB627
Alert Orange: #FF6B35
Danger Red: #E63946
Info Cyan: #48CAE4
```

**Phase-Specific:**
```
Workshop (Phase 1):
- Earth tones: browns, rust orange, industrial yellow
- Gritty aesthetic: grays, dark blues

Ship Bridge (Phase 2):
- Space colors: deep blues, purples, starlight whites
- Professional: clean cyans, structured grays
```

### Typography Placeholders

**When generating UI elements with text areas:**
- Leave text areas as solid colored rectangles (matching panel color)
- Do NOT generate actual text (Godot will render text)
- Use placeholder bars to indicate text placement
- Example: horizontal bars of varying lengths for multiple text lines

```
Good Text Placeholder:
████████████████████  (Title area)
████████████  (Short line)
████████████████  (Medium line)

Bad Text Placeholder:
ACTUAL WORDS HERE  (Godot will render text, not the image)
```

---

## Ship HUD & Window Elements

### 1. Ship Viewscreen Frame (Main Display)

**Purpose:** Frame for viewing space, missions, or external views

**Prompt:**
```
Create a futuristic spaceship viewscreen frame in Star Trek LCARS style.
The design should be:
- Rounded rectangular frame with thick geometric borders
- LCARS orange and blue accent panels on sides
- Corner elements with angular cuts
- Central area completely transparent (PNG alpha = 0)
- Border thickness: 40-60 pixels
- Angular decorative elements in corners
- Professional bridge aesthetic
- 1280x720 resolution
- No text, no buttons inside frame
- Frame only, hollow center for displaying content behind

Style: Clean, professional, Star Trek inspired, serious sci-fi
Colors: Deep space black borders, LCARS orange accents, blue highlights
Format: PNG with full transparency in center viewing area
```

**Variations Needed:**
- Standard viewscreen (1280x720)
- Mini viewscreen (800x600)
- Mission display frame (768x512)

### 2. Ship Console Panel Overlay

**Purpose:** Semi-transparent overlay for ship status displays

**Prompt:**
```
Create a semi-transparent holographic ship console panel overlay in Star Trek style.
The design should be:
- Geometric panel layout with angular sections
- 40% transparency overall (alpha = 102)
- LCARS-style colored accent bars (fully opaque)
- Corner brackets and border lines (fully opaque)
- Center areas with subtle gradient (20-40% opacity)
- Divided into 3-4 sections for different data
- Clean geometric separators between sections
- 1280x720 resolution
- Leave text areas as empty semi-transparent rectangles
- Professional bridge console aesthetic

Style: Holographic, semi-transparent, LCARS inspired
Colors: Blue-cyan tones with orange accents, subtle gradients
Transparency: 40% base, 100% for accent lines and borders
Format: PNG with alpha channel, varying transparency levels
```

### 3. Ship Window/Portal Frame

**Purpose:** Frame for looking out into space or planetary views

**Prompt:**
```
Create a spaceship window portal frame with industrial sci-fi aesthetic.
The design should be:
- Oval or rounded rectangular shape
- Thick metallic frame with bolts/rivets detail
- Interior completely transparent (PNG alpha = 0)
- Frame suggests thick hull plating
- Subtle inner shadow on frame edges
- Optional: small warning labels or hazard stripes on frame
- Size: 900x600 center viewing area
- Frame thickness: 80-120 pixels
- Serious, functional design
- No glass texture (fully transparent interior)

Style: Industrial sci-fi, functional, sturdy construction
Colors: Metallic grays, dark blues, subtle orange hazard stripes
Details: Bolts, panel lines, wear and tear acceptable
Format: PNG with full transparency inside frame
```

**Variations:**
- Round porthole (800x800)
- Wide observation window (1200x400)
- Emergency viewport (600x400)

### 4. Tactical Display Overlay

**Purpose:** Heads-up display for ship combat/navigation

**Prompt:**
```
Create a minimal tactical HUD overlay for spaceship operations.
The design should be:
- Corner brackets in all four corners (thin, angular)
- Targeting reticle in center (crosshair style, thin lines)
- Edge indicators (small arrows or bars along edges)
- 90% transparent base (alpha = 26)
- All HUD elements fully opaque (alpha = 255)
- Minimal, non-intrusive design
- Clean lines, no clutter
- 1280x720 resolution
- Cyan/blue color scheme
- Professional military aesthetic

Style: Minimal HUD, tactical display, clean and functional
Colors: Bright cyan for targeting, blue for indicators
Transparency: 90% transparent base, 100% opaque HUD elements
Format: PNG with high transparency, only HUD graphics visible
```

---

## Button & Menu Components

### 5. LCARS-Style Button (Standard)

**Purpose:** Primary action buttons throughout UI

**Prompt:**
```
Create a Star Trek LCARS-style button in multiple states.
Generate 3 variations in a single image (side by side):
1. Normal state - LCARS orange
2. Hover state - LCARS yellow/bright orange with glow
3. Pressed state - darker orange with inset shadow

Each button should be:
- Rounded rectangular shape with rounded ends (pill shape)
- Solid fill color (no transparency on button itself)
- Subtle gradient (lighter at top, slightly darker at bottom)
- Size: 200x60 pixels each
- 2-3 pixel border in darker shade
- Optional: small corner accent line
- No text (leave solid color for text overlay)
- Professional, clean appearance

Style: LCARS button, Star Trek TNG inspired, clean design
Colors: Orange (#FF9900) normal, bright yellow hover, dark orange pressed
Format: PNG, 620x60 (3 buttons with 10px spacing), opaque buttons
```

**Variations Needed:**
- Large button: 400x80
- Medium button: 200x60
- Small button: 120x40
- Wide button: 300x50

**Color Variations:**
- Primary: LCARS orange
- Secondary: LCARS blue
- Success: Green
- Warning: Yellow
- Danger: Red

### 6. Navigation Menu Panel

**Purpose:** Side navigation with multiple menu items

**Prompt:**
```
Create a vertical navigation menu panel in LCARS style.
The design should be:
- Vertical panel: 280x600 pixels
- 6 button slots stacked vertically
- Each slot: rounded rectangle with space for text
- Alternating accent colors (orange, blue, purple)
- Small icon area on left of each slot (64x64 transparent square)
- Subtle separators between buttons (thin lines)
- Panel background: 80% transparent dark gray
- Button slots: fully opaque with LCARS colors
- Professional, organized layout
- No actual text or icons (leave areas empty/placeholder)

Style: LCARS navigation menu, organized, clean
Colors: Mix of LCARS orange, blue, purple for button slots
Transparency: 80% transparent background, 100% opaque buttons
Format: PNG with alpha channel, structured layout
```

### 7. Dropdown Menu Container

**Purpose:** Dropdown selection menus

**Prompt:**
```
Create a dropdown menu container in modern sci-fi style.
The design should be:
- Rectangular container: 300x200 pixels
- Rounded corners (10px radius)
- Semi-transparent dark background (60% opacity)
- Thin border (2px) in cyan/blue
- Divided into 5 equal rows for menu items
- Each row has subtle hover highlight area (slightly lighter)
- Small arrow indicators on right side of each row
- Clean, minimal design
- No text (leave as solid areas for text rendering)

Style: Modern sci-fi dropdown, clean and functional
Colors: Dark background (#1A1F2E, 60% opacity), cyan borders
Format: PNG with alpha channel, layered transparency
```

---

## Panel & Container Elements

### 8. Information Panel (Status Display)

**Purpose:** Display ship stats, mission info, inventory data

**Prompt:**
```
Create a modular information panel with LCARS aesthetic.
The design should be:
- Rectangular panel: 400x250 pixels
- Header bar at top (40px height) in LCARS orange
- Main content area with 70% transparent dark background
- Subtle borders (2px) in blue
- Corner accents (small angular elements in corners)
- Divided into 3 sections vertically
- Each section has left accent bar (8px wide, colored)
- Professional, organized appearance
- No text (leave areas for text rendering)

Style: LCARS information panel, organized sections
Colors: Orange header, blue borders, semi-transparent background
Transparency: Header opaque, content 70% transparent
Format: PNG with alpha channel, structured layout
```

**Variations:**
- Wide panel: 800x200
- Tall panel: 300x600
- Square panel: 400x400
- Full panel: 900x600

### 9. Ship Schematic Display Frame

**Purpose:** Frame for displaying ship system diagrams

**Prompt:**
```
Create a technical display frame for ship schematics.
The design should be:
- Square frame: 800x800 pixels
- Grid lines in background (20px spacing, very subtle, 10% opacity)
- Corner brackets (bold, angular, orange)
- Thin border lines (2px, cyan)
- Technical aesthetic (blueprints/engineering vibe)
- Center area for ship diagram (mostly transparent)
- Small measurement indicators on edges (tick marks)
- Professional technical display
- No actual schematic (frame only)

Style: Technical display, engineering blueprint aesthetic
Colors: Dark background with cyan grid, orange corners
Transparency: Background 80% transparent, grid 10%, borders opaque
Format: PNG with alpha channel, technical styling
```

### 10. Modal Dialog Box

**Purpose:** Pop-up dialogs for confirmations, alerts, messages

**Prompt:**
```
Create a modal dialog box in sci-fi style.
The design should be:
- Centered rectangle: 600x400 pixels
- Rounded corners (15px radius)
- Semi-transparent background (50% opacity)
- Prominent border (4px) that glows slightly
- Header section at top (60px height, colored based on type)
- Content area in middle (transparent for text)
- Button area at bottom (80px height)
- Shadow effect around entire modal (subtle, 20px blur)
- Professional, attention-grabbing design
- No text or buttons (frame/container only)

Generate 3 color variations in separate images:
1. Info modal - blue header and border
2. Warning modal - yellow/orange header and border
3. Error modal - red header and border

Style: Modern sci-fi modal dialog, clean and prominent
Colors: Varies by type (blue/yellow/red)
Transparency: 50% content area, opaque header and borders
Format: PNG with alpha channel and shadow effect
```

---

## Dashboard Backgrounds

### 11. Workshop Dashboard Background (Phase 1)

**Purpose:** Background for Earth workshop interface

**Prompt:**
```
Create a dashboard background for a post-apocalyptic spaceship workshop.
The design should be:
- Full resolution: 1280x720
- Industrial workshop aesthetic
- Rusty metal panels with rivets
- Warning stripes (yellow/black) in corners
- Dark, gritty atmosphere
- Subtle texture (scratches, wear)
- Color palette: dark grays, browns, rust orange
- Center area slightly darker for content visibility
- Edges with more detail, center cleaner
- No text, no buttons
- Vignette effect (darker at edges)
- Post-exodus, salvage operation feel

Style: Industrial, gritty, post-apocalyptic workshop
Colors: Dark grays (#2A2A2A), rust orange (#B85C00), warning yellow
Mood: Serious, utilitarian, "making do with what we have"
Format: PNG, fully opaque (no transparency for backgrounds)
```

### 12. Ship Bridge Dashboard Background (Phase 2)

**Purpose:** Background for space operations interface

**Prompt:**
```
Create a professional starship bridge dashboard background.
The design should be:
- Full resolution: 1280x720
- Star Trek LCARS inspired
- Clean geometric panels
- Deep space aesthetic
- Color palette: deep blues (#0A1628), purples (#2D1B4E)
- LCARS-style colored accent bars on edges
- Professional bridge command center feel
- Subtle star field in background (very subtle, 5% opacity)
- Organized, structured layout
- No text, buttons only as placeholder shapes
- Modern, advanced technology appearance

Style: Star Trek LCARS, professional bridge, clean and organized
Colors: Deep space black/blue, LCARS orange/blue accents
Mood: Professional, capable, "we're a real ship now"
Format: PNG, fully opaque background with integrated UI elements
```

### 13. Customizable Dashboard Frame

**Purpose:** Base frame for AI-generated custom backgrounds

**Prompt:**
```
Create a modular dashboard frame that overlays on custom backgrounds.
The design should be:
- Full resolution: 1280x720
- Only border elements (no background fill)
- Corner frames and edge accents
- Top header bar area (80px height, semi-transparent)
- Bottom button bar area (60px height, semi-transparent)
- Side panel indicators (left 40px, right 40px)
- All interior areas fully transparent (alpha = 0)
- Clean, minimal frame design
- Compatible with any background behind it
- LCARS-style accent elements
- Professional appearance

Style: Minimal overlay frame, compatible with any background
Colors: LCARS orange accents, semi-transparent panels
Transparency: Center 100% transparent, panels 60% transparent
Format: PNG with heavy use of transparency, overlay design
```

---

## Mission & Location Frames

### 14. Mission Image Display Frame

**Purpose:** Frame for showing AI-generated mission location art

**Prompt:**
```
Create a stylish frame for displaying mission location images.
The design should be:
- Rectangular frame: 768x512 (16:9 aspect ratio)
- Cinematic appearance (like a movie screen)
- Subtle border (10px) with gradient
- Corner elements (small decorative accents)
- Optional: scan line effect overlay (very subtle, 5% opacity)
- Interior completely transparent (for image display)
- Professional, immersive design
- Enhances without distracting from content
- Optional: small indicator lights in corners (colored dots)

Style: Cinematic display frame, immersive, professional
Colors: Dark frame (#1A1A1A) with cyan/blue accent gradient
Transparency: Interior 100% transparent, frame opaque
Format: PNG with transparent center for image display
```

### 15. Mission Stage Indicator

**Purpose:** Show progress through mission stages

**Prompt:**
```
Create a horizontal mission progress indicator.
The design should be:
- Horizontal bar: 600x80 pixels
- 5 circular nodes connected by lines
- Each node: 60px diameter circle
- Connecting lines: 4px thick, between nodes
- Generate 3 states per node:
  * Completed: filled circle, green
  * Current: pulsing circle, orange/yellow
  * Upcoming: empty circle outline, gray
- Sci-fi aesthetic with subtle glow on active elements
- Professional, clean design
- No text (nodes are visual only)

Style: Sci-fi progress indicator, clean and modern
Colors: Green (completed), orange (active), gray (pending)
Effects: Subtle glow on active state
Format: PNG with transparency, modular design
```

---

## Status Indicators & Badges

### 16. Health/Shield Status Bar

**Purpose:** Visual representation of HP, shields, power, etc.

**Prompt:**
```
Create a modular status bar component.
The design should be:
- Horizontal bar: 300x40 pixels
- Rounded rectangle container (5px border)
- Interior fill area (represents current value)
- Generate 5 color variations:
  * Health (red): #E63946
  * Shields (cyan): #48CAE4
  * Power (yellow): #FFB627
  * Fuel (orange): #FF9900
  * Energy (blue): #2E8BC0
- Container: dark border, semi-transparent background (40%)
- Fill: solid color with subtle horizontal gradient
- End caps slightly rounded
- Professional, readable design
- Optional: subtle segments/ticks every 20%

Style: Modern status bar, clear and readable
Colors: Varies by type (see list above)
Transparency: Container 40% transparent, fill 100% opaque
Format: PNG with alpha channel, 1500x40 (all variations side by side)
```

### 17. System Level Badge

**Purpose:** Show ship system level (0-5)

**Prompt:**
```
Create system level badges for ship systems display.
Generate 6 variations for levels 0-5:

Each badge should be:
- Hexagonal shape: 80x80 pixels
- Large number in center (the level)
- Background color indicates level:
  * Level 0: Gray, offline appearance
  * Level 1: Green, basic
  * Level 2: Blue, improved
  * Level 3: Purple, advanced
  * Level 4: Orange, superior
  * Level 5: Gold, maximum
- Subtle border (3px)
- Small glow effect
- Professional, clear design
- Number as colored rectangle (Godot will render actual number)

Style: Hexagonal badge, color-coded by level
Colors: Varies by level (gray to gold progression)
Format: PNG, 510x80 (all 6 levels in one image with spacing)
```

### 18. Mission Difficulty Stars

**Purpose:** Visual representation of mission difficulty (1-5 stars)

**Prompt:**
```
Create star rating icons for mission difficulty display.
The design should be:
- 5-pointed star shape
- Size: 48x48 pixels per star
- Generate 2 states:
  * Filled star: solid orange/yellow, glowing
  * Empty star: outline only, gray
- Pixel art inspired but clean
- Slight glow effect on filled stars
- Professional appearance
- Arrange horizontally: 5 stars total

Generate full set showing all combinations:
- 1 star (1 filled, 4 empty)
- 2 stars (2 filled, 3 empty)
- 3 stars (3 filled, 2 empty)
- 4 stars (4 filled, 1 empty)
- 5 stars (5 filled, 0 empty)

Style: Clean star icons, color-coded difficulty
Colors: Orange/yellow filled (#FFB627), gray empty (#4A4A4A)
Format: PNG, 260x48 per difficulty rating (includes spacing)
```

### 19. Alert Status Indicator

**Purpose:** Show ship alert status (Green/Yellow/Red)

**Prompt:**
```
Create alert status indicator lights for ship dashboard.
Generate 3 alert levels:

Each indicator should be:
- Rounded rectangle: 150x60 pixels
- Colored border (6px thick) that glows
- Semi-transparent interior (50% opacity)
- Small circular "light" in corner that blinks
- Professional, clear design

Alert levels:
1. Green Alert: Normal operations
   - Green border (#2EC4B6)
   - Subtle green glow
   - Calm appearance

2. Yellow Alert: Caution/Warning
   - Yellow border (#FFB627)
   - Pulsing yellow glow
   - Attention-grabbing

3. Red Alert: Danger/Combat
   - Red border (#E63946)
   - Strong red glow with pulse
   - Urgent appearance

Style: Alert indicator, clear status communication
Colors: Green/Yellow/Red based on alert level
Effects: Subtle glow, more intense at higher alert
Format: PNG with alpha channel, 480x60 (all 3 alerts)
```

---

## Overlay & Modal Elements

### 20. Loading Screen Overlay

**Purpose:** Full-screen overlay during loading/generation

**Prompt:**
```
Create a loading screen overlay with sci-fi aesthetic.
The design should be:
- Full resolution: 1280x720
- Dark semi-transparent background (70% opacity)
- Center area for loading indicator (400x400 transparent space)
- Subtle animated scan lines (horizontal, subtle, 5% opacity)
- Corner decorative elements (small, orange accents)
- Professional, non-intrusive design
- Optional: progress bar area at bottom (600x20 space)
- Vignette effect (darker at edges)

Style: Sci-fi loading overlay, professional and subtle
Colors: Dark background (#0A0E1A, 70% opacity), orange accents
Transparency: 70% background, 100% transparent center area
Format: PNG with alpha channel, overlay design
```

### 21. Tooltip Background

**Purpose:** Small popup tooltips for UI elements

**Prompt:**
```
Create tooltip popup backgrounds in multiple sizes.
Each tooltip should be:
- Rounded rectangle (10px radius corners)
- Semi-transparent dark background (85% opacity)
- Thin border (2px) in cyan/blue
- Small arrow/pointer on edge (indicating what it points to)
- Shadow effect (subtle, 10px blur)
- Professional, readable design

Generate 3 sizes:
- Small: 200x80
- Medium: 300x120
- Large: 400x160

Style: Modern tooltip, clean and readable
Colors: Dark background (#1A1F2E, 85% opacity), cyan border
Format: PNG with alpha channel and shadow, 920x160 (all sizes)
```

### 22. Context Menu Panel

**Purpose:** Right-click or action menu popup

**Prompt:**
```
Create a context menu panel for item/action selection.
The design should be:
- Vertical rectangle: 250x200 pixels (flexible height)
- Rounded corners (8px radius)
- Semi-transparent dark background (80% opacity)
- Thin border (2px) in blue
- Divided into 5 rows for menu items
- Each row: 250x40 pixels
- Hover highlight area (slightly lighter background)
- Small icon space on left (32x32)
- Text area in center
- Separator lines between items (thin, 1px, 20% opacity)
- Professional, organized design

Style: Context menu, clean and organized
Colors: Dark background (#1A1F2E, 80% opacity), blue border
Transparency: 80% background, 100% opaque borders
Format: PNG with alpha channel, structured layout
```

---

## Quality Control Checklist

### Before Approving Generated Asset

**Technical Checks:**
- [ ] Correct file format (PNG)
- [ ] Alpha channel present (32-bit RGBA)
- [ ] Correct dimensions per specification
- [ ] File size reasonable (<500KB)
- [ ] No compression artifacts
- [ ] Properly optimized

**Transparency Checks:**
- [ ] Designated transparent areas fully transparent (alpha = 0)
- [ ] Semi-transparent areas have correct opacity
- [ ] Borders and accents fully opaque
- [ ] No unintended transparency or opacity

**Style Checks:**
- [ ] Matches Star Trek LCARS / retro sci-fi aesthetic
- [ ] Color palette consistent with guidelines
- [ ] Professional, serious tone (not cartoonish)
- [ ] Clean, functional design
- [ ] Appropriate mood for context (workshop vs bridge)

**Functionality Checks:**
- [ ] Placeholder areas clearly defined
- [ ] No text rendered (areas left for Godot)
- [ ] Button states distinct and clear
- [ ] Interactive areas obvious
- [ ] Compatible with intended use case

**Consistency Checks:**
- [ ] Matches other UI elements in set
- [ ] Border thickness consistent
- [ ] Corner radius consistent where applicable
- [ ] Color usage consistent
- [ ] Scale and proportions consistent

---

## Usage Instructions

### For Image Generation Tools

**ChatGPT DALL-E 3:**
```
Use the detailed prompts above directly with ChatGPT.
Request PNG format with transparency.
Specify dimensions explicitly.
May require iteration for proper transparency.
```

**Stable Diffusion:**
```
Add negative prompts: "no text, no words, no letters, no labels"
Use ControlNet for precise layouts
Enable alpha channel in output settings
May need manual transparency editing in GIMP/Photoshop
```

**Midjourney:**
```
Append "--v 6 --style raw" for better control
Use "--no text, words, letters" in prompt
Export PNG format
Transparency may need manual editing
```

### Post-Processing

**Required for most AI outputs:**
1. Open in GIMP or Photoshop
2. Add alpha channel if missing (Layer > Transparency > Add Alpha Channel)
3. Select and delete areas that should be transparent
4. Verify semi-transparent areas have correct opacity
5. Export as PNG-24 with alpha channel
6. Optimize with pngcrush or similar tool

### Integration with Godot

```gdscript
# Load generated asset
var ui_panel = load("res://assets/ui/panels/info_panel.png")

# Apply to TextureRect
$Panel/Background.texture = ui_panel

# For buttons with multiple states, use AtlasTexture
var button_atlas = AtlasTexture.new()
button_atlas.atlas = load("res://assets/ui/buttons/lcars_button_states.png")
button_atlas.region = Rect2(0, 0, 200, 60)  # Normal state
$Button.texture_normal = button_atlas
```

---

## Example Generation Workflow

### Step-by-Step: Generating Ship Viewscreen Frame

1. **Copy prompt** from "Ship HUD & Window Elements" section (#1)
2. **Submit to AI tool** (ChatGPT, Stable Diffusion, Midjourney)
3. **Review output:**
   - Check dimensions (1280x720)
   - Verify center is transparent
   - Check border quality and color
4. **If needed, iterate:**
   - "Make borders thicker"
   - "Add more orange accents"
   - "Ensure center is fully transparent"
5. **Post-process:**
   - Open in GIMP
   - Select center area with "Select by Color"
   - Delete to ensure 100% transparency
   - Verify borders are crisp
6. **Export:**
   - File > Export As > PNG
   - Options: 32-bit RGBA, no interlacing
   - Save to: `godot/assets/ui/frames/viewscreen_frame.png`
7. **Test in Godot:**
   - Import and check in engine
   - Verify transparency works correctly
   - Test with content behind it
8. **Approve and commit** to repository

---

## Prompt Templates for Custom Variations

### Template: Panel with Custom Size

```
Create a [STYLE] information panel in [AESTHETIC] style.
The design should be:
- Rectangular panel: [WIDTH]x[HEIGHT] pixels
- [HEADER/NO HEADER] at top ([HEIGHT]px) in [COLOR]
- Main content area with [TRANSPARENCY]% transparent [COLOR] background
- Borders ([WIDTH]px) in [COLOR]
- Corner accents ([DESCRIPTION])
- [SECTIONS] sections [ORIENTATION]
- Professional, organized appearance
- No text (leave areas for text rendering)

Style: [STYLE DESCRIPTION]
Colors: [COLOR PALETTE]
Transparency: [TRANSPARENCY DETAILS]
Format: PNG with alpha channel
```

### Template: Button with Custom Colors

```
Create a [STYLE] button in multiple states.
Generate 3 variations: normal, hover, pressed.

Each button should be:
- [SHAPE] shape
- Size: [WIDTH]x[HEIGHT] pixels
- Color scheme: [COLOR] normal, [COLOR] hover, [COLOR] pressed
- [ADDITIONAL DETAILS]
- No text (solid color area for text overlay)

Style: [STYLE DESCRIPTION]
Colors: [COLOR SPECIFICATIONS]
Format: PNG, [TOTAL WIDTH]x[HEIGHT] (all states with spacing)
```

---

## Asset Organization

### Directory Structure

```
godot/assets/ui/
├── backgrounds/
│   ├── workshop_dashboard.png
│   ├── ship_dashboard.png
│   └── custom_frames/
├── frames/
│   ├── viewscreen_frame.png
│   ├── console_overlay.png
│   ├── window_portal.png
│   └── mission_frame.png
├── buttons/
│   ├── lcars_button_states.png
│   ├── button_large.png
│   ├── button_colors/
│   └── button_icons/
├── panels/
│   ├── info_panel.png
│   ├── status_panel.png
│   ├── navigation_menu.png
│   └── modal_dialog.png
├── indicators/
│   ├── status_bars.png
│   ├── level_badges.png
│   ├── alert_indicators.png
│   └── progress_indicators.png
└── overlays/
    ├── loading_overlay.png
    ├── tooltip_backgrounds.png
    └── context_menu.png
```

### Naming Conventions

```
Format: [category]_[type]_[variant]_[state].png

Examples:
button_lcars_primary_normal.png
button_lcars_primary_hover.png
panel_info_wide_standard.png
frame_viewscreen_large_default.png
indicator_health_bar_full.png
overlay_loading_screen_default.png
```

---

## Summary

This guide provides **complete prompts for 22+ UI element types** covering:

✅ Ship HUD elements with proper transparency
✅ Buttons and menus in LCARS style
✅ Panels and containers for data display
✅ Dashboard backgrounds for both phases
✅ Mission and location frames
✅ Status indicators and badges
✅ Overlays and modal elements

**Key Principles:**
- **PNG with alpha channel** for transparency
- **LCARS/Star Trek aesthetic** for consistency
- **Placeholder areas** for dynamic content
- **Proper dimensions** for 1280x720 base resolution
- **Professional, serious tone** throughout

**Next Steps:**
1. Generate assets using provided prompts
2. Review and iterate as needed
3. Post-process for proper transparency
4. Import into Godot and test
5. Commit approved assets to repository

---

**Document Status:** Complete and Ready for Asset Generation
**Last Updated:** November 6, 2025
**Related Documents:**
- screen-designs.md (UI layouts)
- dashboard-evolution.md (dashboard specs)
- visual-features.md (visual system architecture)

Let's create beautiful UI graphics! 🎨🚀
