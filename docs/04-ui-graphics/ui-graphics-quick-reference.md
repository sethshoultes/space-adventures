# UI Graphics Quick Reference Card

**Purpose:** Fast reference for common UI asset generation
**Use:** Quick lookup while generating assets

---

## Most Common Assets (Priority Order)

### 1. Main Dashboard Background
**Size:** 1280x720 | **Transparency:** Opaque
```
Workshop (Phase 1): Industrial, gritty, rust colors, metal panels
Ship Bridge (Phase 2): LCARS, clean, space colors, professional
```

### 2. LCARS Button (Standard)
**Size:** 200x60 | **Transparency:** Opaque | **States:** Normal/Hover/Pressed
```
Rounded rectangle, solid orange (#FF9900), gradient, no text
Generate 3 states side-by-side (620x60 total)
```

### 3. Information Panel
**Size:** 400x250 | **Transparency:** 70% background, opaque borders
```
Orange header bar, semi-transparent content, blue borders
Leave text areas empty, corner accents
```

### 4. Ship Viewscreen Frame
**Size:** 1280x720 | **Transparency:** Center 100% transparent
```
LCARS frame, thick borders, orange/blue accents
Completely hollow center for content display
```

### 5. Status Bar (Health/Shields/Power)
**Size:** 300x40 | **Transparency:** 40% container, opaque fill
```
Rounded container, colored fill bar, 5 color variations
Red (health), cyan (shields), yellow (power), orange (fuel), blue (energy)
```

---

## Color Palette Reference

```
PRIMARY ACCENT:
#FF9900 - LCARS Orange (buttons, highlights)
#9999FF - LCARS Blue (accents)
#CC99CC - LCARS Purple (tertiary)

BACKGROUNDS:
#0A0E1A - Deep Space Black
#1A1F2E - Panel Gray
#2E4C6D - Border Blue

STATUS COLORS:
#2EC4B6 - Success Green
#FFB627 - Warning Yellow
#E63946 - Danger Red
#48CAE4 - Info Cyan

WORKSHOP (Phase 1):
#B85C00 - Rust Orange
#4A3C2A - Industrial Brown
#FFD700 - Warning Yellow

SHIP BRIDGE (Phase 2):
#0A1628 - Deep Space Blue
#2D1B4E - Space Purple
#00F5FF - Cyan Accent
```

---

## Standard Dimensions

```
FULL SCREEN:
1280x720 - Dashboard backgrounds, full overlays

LARGE PANELS:
900x600  - Main content panels
800x600  - Ship schematic display
768x512  - Mission image frames

MEDIUM PANELS:
400x250  - Info panels
300x600  - Side navigation
600x400  - Modal dialogs

BUTTONS:
400x80   - Large button
200x60   - Standard button (MOST COMMON)
120x40   - Small button

ICONS & BADGES:
128x128  - Large icons
64x64    - Standard icons
48x48    - Badges, difficulty stars
32x32    - Small indicators

STATUS BARS:
300x40   - Standard status bar
600x20   - Progress bar
```

---

## Transparency Guide

```
FULLY TRANSPARENT (alpha = 0):
- Window/screen centers
- Placeholder text areas
- Content display areas
- Button interiors

SEMI-TRANSPARENT (20-80% opacity):
- Panel backgrounds: 70% transparent
- Overlay backgrounds: 50% transparent
- Tooltips: 85% transparent
- Console overlays: 40% transparent

FULLY OPAQUE (alpha = 255):
- Borders and frames
- Accent bars
- Button backgrounds
- Icons and badges
```

---

## Common Prompt Patterns

### Basic Panel Pattern
```
Create a [SIZE] information panel in LCARS style.
Semi-transparent dark background (70% opacity), blue borders (2px),
orange header bar, corner accents, no text.
PNG with alpha channel. [WIDTH]x[HEIGHT] pixels.
```

### Basic Button Pattern
```
Create LCARS button, rounded rectangle [SIZE].
Generate 3 states: normal (orange), hover (bright), pressed (dark).
Solid fill, subtle gradient, no text. PNG opaque.
```

### Basic Frame Pattern
```
Create [TYPE] frame, [SIZE] pixels.
Thick borders with LCARS accents, center completely transparent.
Professional sci-fi style. PNG with transparency.
```

### Basic Overlay Pattern
```
Create [SIZE] overlay with [TRANSPARENCY]% transparent background.
[COLOR] borders, [FEATURES]. Professional design.
PNG with alpha channel.
```

---

## Essential Negative Prompts

**Always include when generating UI:**
```
no text, no words, no letters, no numbers, no labels,
no realistic photos, no lens flare, no blur,
no watermark, no signature, no modern CGI
```

---

## Quick Transparency Fix (GIMP)

```bash
1. Open PNG in GIMP
2. Layer > Transparency > Add Alpha Channel
3. Select > By Color > Click area to make transparent
4. Press Delete
5. File > Export As > PNG (32-bit RGBA)
```

---

## File Naming Convention

```
[category]_[type]_[variant]_[state].png

Examples:
button_lcars_primary_normal.png
panel_info_wide_default.png
frame_viewscreen_large.png
indicator_health_bar.png
```

---

## Priority Generation Order

**Week 1-2 (Critical):**
1. Workshop dashboard background
2. LCARS buttons (all colors)
3. Information panels (3 sizes)
4. Navigation menu panel
5. Status bars (5 colors)

**Week 3 (Important):**
6. Ship viewscreen frame
7. Mission display frame
8. Modal dialogs (3 types)
9. Alert indicators (3 states)
10. Level badges (0-5)

**Week 4 (Nice to Have):**
11. Ship bridge background
12. Console overlays
13. Window/portal frames
14. Tooltips
15. Context menus

---

## Testing Checklist

```
□ Correct dimensions
□ PNG format with alpha channel
□ Transparency in correct areas
□ Colors match palette
□ Clean edges (no artifacts)
□ File size < 500KB
□ Imports correctly in Godot
□ Looks good against different backgrounds
□ Matches style of other UI elements
```

---

## AI Tool Quick Commands

**ChatGPT DALL-E:**
```
"Generate as PNG with transparency" - Add to every prompt
"Center area fully transparent" - For frames
"Multiple states side by side" - For buttons
```

**Stable Diffusion:**
```
--no text words letters
--format png
--alpha_channel true
```

**Midjourney:**
```
--v 6 --style raw --no text words
```

---

## Common Fixes

**Problem:** Text rendered in image
**Fix:** Regenerate with stronger "no text" emphasis, or manually remove in GIMP

**Problem:** Transparency not working
**Fix:** Export as PNG-24 with alpha channel, verify in GIMP

**Problem:** Colors too bright/dark
**Fix:** Adjust in GIMP: Colors > Hue-Saturation or Brightness-Contrast

**Problem:** Borders too thick/thin
**Fix:** Scale image or regenerate with specific pixel measurements

**Problem:** File size too large
**Fix:** Optimize with `pngcrush -rem alla -reduce file.png`

---

## One-Line Prompts for Speed

**Standard Button:**
```
LCARS button 200x60, 3 states, orange, rounded, gradient, no text, PNG
```

**Info Panel:**
```
Panel 400x250, LCARS style, 70% transparent, orange header, blue border, PNG alpha
```

**Viewscreen Frame:**
```
Frame 1280x720, LCARS style, thick borders, orange accents, center transparent, PNG
```

**Status Bar:**
```
Status bar 300x40, rounded, colored fill, 40% transparent container, PNG alpha
```

---

## Asset Count Estimate

```
MINIMUM VIABLE (MVP):
- 2 dashboard backgrounds
- 12 button variations (3 states × 4 colors)
- 6 panel types (3 sizes × 2 styles)
- 4 frame types
- 10 status indicators
TOTAL: ~35-40 core assets

FULL GAME:
- 6 dashboard backgrounds (including custom variations)
- 24 button variations
- 12 panel variations
- 8 frame types
- 20 status indicators
- 15 icons and badges
TOTAL: ~85-100 assets
```

---

## Emergency Fallback

**If AI generation fails, use placeholder:**
```gdscript
# Godot can generate simple colored rectangles as fallback
var placeholder = ColorRect.new()
placeholder.color = Color("#FF9900")  # LCARS orange
placeholder.size = Vector2(200, 60)
```

---

**Generated:** November 6, 2025
**For:** Space Adventures UI Asset Creation
**See Also:** ui-graphics-prompt-guide.md (detailed prompts)
