# UI Graphics: Batch Generation Workflow

**Version:** 1.0
**Date:** November 6, 2025
**Purpose:** Efficient workflows for generating multiple UI assets quickly
**Goal:** Generate 20-30 assets in a single work session

---

## Table of Contents
1. [ChatGPT Batch Workflow](#chatgpt-batch-workflow)
2. [Stable Diffusion Batch Scripts](#stable-diffusion-batch-scripts)
3. [Asset Organization System](#asset-organization-system)
4. [Quality Control Workflow](#quality-control-workflow)
5. [Automation Scripts](#automation-scripts)

---

## ChatGPT Batch Workflow

### Session Setup Template

**Start every ChatGPT session with this initialization:**

```
I'm creating UI assets for a space adventure game. Please remember these requirements for all assets in this session:

PROJECT CONTEXT:
- Game: Space Adventures (Star Trek TNG inspired space game)
- Platform: Godot 4.2+ game engine
- Base Resolution: 1280x720

MANDATORY STYLE REQUIREMENTS:
- Aesthetic: Star Trek LCARS meets retro sci-fi
- Color Palette:
  * Primary: LCARS Orange (#FF9900)
  * Secondary: LCARS Blue (#9999FF)
  * Tertiary: LCARS Purple (#CC99CC)
  * Backgrounds: Deep space black (#0A0E1A), Panel gray (#1A1F2E)
  * Status colors: Green (#2EC4B6), Yellow (#FFB627), Red (#E63946)
- Tone: Professional, serious sci-fi, functional design

TECHNICAL REQUIREMENTS:
- Format: PNG (ALWAYS)
- Color Mode: RGB or RGBA (with alpha channel when transparency needed)
- DPI: 72 (screen optimized)
- Quality: Professional, clean edges, no artifacts

CRITICAL RULES:
1. NEVER include text, words, letters, or numbers in generated images
2. Leave text areas as solid colored rectangles
3. When transparency specified, use PNG alpha channel
4. Follow exact dimensions specified
5. Use exact hex color codes provided

Please confirm you understand these standards and will apply them to all assets I request in this conversation.
```

**ChatGPT will confirm. Then proceed with batch requests.**

### Batch Request Template 1: Button Set

**Generate all button variations in one request:**

```
Generate 5 LCARS-style buttons in a single image, arranged vertically with 10px spacing. Each button is a rounded rectangle (pill shape), 200x60 pixels. Show all in NORMAL state (not hover/pressed). Colors from top to bottom:

1. Primary Orange (#FF9900) - standard actions
2. Secondary Blue (#9999FF) - secondary actions
3. Success Green (#2EC4B6) - confirm/success
4. Warning Yellow (#FFB627) - caution actions
5. Danger Red (#E63946) - destructive actions

Each button:
- Solid fill with subtle vertical gradient (10% lighter top, 10% darker bottom)
- 2px border in darker shade of same color
- Fully opaque (no transparency)
- NO TEXT - solid colored shape only

Total image size: 200 x 330 pixels (5 buttons plus spacing)
Export as PNG, fully opaque.
```

**Result:** All 5 button colors in one image, slice apart later

### Batch Request Template 2: Panel Set

```
Generate 3 information panel variations in a single image, arranged horizontally with 20px spacing. All panels use LCARS aesthetic with semi-transparent backgrounds.

Panel 1 - Square Panel (300x300):
- Top header bar (40px) in LCARS orange, fully opaque
- Main area: 70% transparent dark gray (#1A1F2E)
- 2px blue border (#9999FF), fully opaque
- Corner brackets in orange

Panel 2 - Wide Panel (400x200):
- Same styling as Panel 1
- Wider proportions for horizontal data

Panel 3 - Tall Panel (200x400):
- Same styling as Panel 1
- Vertical proportions for navigation

All panels: Semi-transparent backgrounds (70% transparency), opaque borders and accents.
Total image size: 940 x 400 pixels (includes spacing)
Export as PNG with alpha channel for transparency.
```

**Result:** 3 panel variations in one image

### Batch Request Template 3: Status Indicator Set

```
Create a comprehensive status indicator set in a single organized image:

TOP ROW - Status Bars (5 variations, each 300x40, 10px spacing):
1. Health bar - Red (#E63946) fill, 40% transparent container
2. Shield bar - Cyan (#48CAE4) fill, 40% transparent container
3. Power bar - Yellow (#FFB627) fill, 40% transparent container
4. Fuel bar - Orange (#FF9900) fill, 40% transparent container
5. Energy bar - Blue (#2E8BC0) fill, 40% transparent container

All bars show at 60% fill capacity. Container background is semi-transparent (40%), fill is opaque.

BOTTOM ROW - Alert Indicators (3 variations, each 150x60, 10px spacing):
1. Green Alert - Green border (#2EC4B6), subtle glow, 50% transparent interior
2. Yellow Alert - Yellow border (#FFB627), pulsing glow, 50% transparent interior
3. Red Alert - Red border (#E63946), strong glow, 50% transparent interior

Arrange in 2 rows. Total size: 1530 x 110 pixels
Export as PNG with alpha channel for multi-level transparency.
```

**Result:** All status indicators in one organized sheet

### Batch Request Template 4: Frame Set

```
Generate 4 display frames in a 2x2 grid layout:

TOP LEFT - Viewscreen Frame (600x400):
- LCARS style border frame, 40px thick
- Orange and blue accent panels on sides
- Center COMPLETELY TRANSPARENT (alpha = 0)
- Corner decorative elements

TOP RIGHT - Mission Frame (600x400):
- Cinematic frame, thin elegant border (12px)
- Blue-gray gradient border
- Center COMPLETELY TRANSPARENT (alpha = 0)
- Small orange corner accents

BOTTOM LEFT - Window Portal (400x400):
- Circular frame (360px diameter circle)
- Industrial aesthetic with bolts
- Center COMPLETELY TRANSPARENT (alpha = 0)
- Metallic gray frame, opaque

BOTTOM RIGHT - Data Display (600x400):
- Technical display frame
- Grid lines in background (very subtle, 10% opacity)
- Orange corner brackets
- Center area for data (80% transparent)

All frames: centers transparent for viewing content behind them.
Total grid: 1220 x 820 pixels (includes 10px spacing)
Export as PNG with alpha channel.
```

**Result:** 4 different frame types in one sheet

---

## Stable Diffusion Batch Scripts

### Python Batch Generation Script

**For users running Stable Diffusion locally:**

```python
# batch_ui_generate.py
from diffusers import StableDiffusionXLPipeline
import torch
from PIL import Image
import json

# Configuration
CONFIG = {
    "model": "stabilityai/stable-diffusion-xl-base-1.0",
    "style_base": "Star Trek LCARS, retro sci-fi, professional, clean design",
    "negative": "text, words, letters, numbers, realistic photo, lens flare, blur",
    "steps": 50,
    "guidance": 7.5,
    "device": "cuda" if torch.cuda.is_available() else "cpu"
}

# Load model once
print("Loading model...")
pipe = StableDiffusionXLPipeline.from_pretrained(
    CONFIG["model"],
    torch_dtype=torch.float16,
    use_safetensors=True
)
pipe.to(CONFIG["device"])

# Asset definitions
ASSETS = {
    "buttons": [
        {
            "name": "lcars_button_primary_states",
            "prompt": f"{CONFIG['style_base']}, LCARS button, 3 states, orange #FF9900, rounded rectangle pill shape, 200x60 each, normal/hover/pressed, horizontal layout, solid fill, gradient, no text",
            "width": 620,
            "height": 60
        },
        {
            "name": "lcars_button_large",
            "prompt": f"{CONFIG['style_base']}, large LCARS button, orange #FF9900, rounded rectangle, 400x80, solid fill, gradient, no text",
            "width": 400,
            "height": 80
        }
    ],
    "panels": [
        {
            "name": "panel_info_standard",
            "prompt": f"{CONFIG['style_base']}, information panel, 400x250, orange header bar, semi-transparent dark gray background, blue borders, corner accents, no text",
            "width": 400,
            "height": 250
        },
        {
            "name": "panel_info_wide",
            "prompt": f"{CONFIG['style_base']}, wide information panel, 800x200, orange header, transparent background, blue borders, no text",
            "width": 800,
            "height": 200
        }
    ],
    "frames": [
        {
            "name": "frame_viewscreen_main",
            "prompt": f"{CONFIG['style_base']}, viewscreen frame, LCARS style borders, orange and blue accents, 1280x720, thick frame, hollow transparent center, no text",
            "width": 1280,
            "height": 720
        }
    ]
}

def generate_asset(asset_def, category):
    """Generate a single asset"""
    print(f"\nGenerating {category}/{asset_def['name']}...")

    image = pipe(
        prompt=asset_def["prompt"],
        negative_prompt=CONFIG["negative"],
        num_inference_steps=CONFIG["steps"],
        guidance_scale=CONFIG["guidance"],
        width=asset_def["width"],
        height=asset_def["height"]
    ).images[0]

    # Save
    output_path = f"godot/assets/ui/{category}/{asset_def['name']}.png"
    image.save(output_path)
    print(f"Saved: {output_path}")

    return output_path

def generate_all():
    """Generate all assets in batch"""
    generated = []

    for category, assets in ASSETS.items():
        print(f"\n=== Generating {category} ===")
        for asset in assets:
            path = generate_asset(asset, category)
            generated.append(path)

    # Save generation log
    with open("generation_log.json", "w") as f:
        json.dump({
            "generated": generated,
            "config": CONFIG,
            "total": len(generated)
        }, f, indent=2)

    print(f"\n✓ Generated {len(generated)} assets")
    print("See generation_log.json for details")

if __name__ == "__main__":
    generate_all()
```

**Usage:**
```bash
python batch_ui_generate.py
# Wait 10-30 minutes depending on GPU
# All assets generated to godot/assets/ui/
```

---

## Asset Organization System

### Directory Structure

```
godot/assets/ui/
├── _catalog/
│   ├── asset_index.md              ← Master list of all assets
│   ├── generation_log.json         ← Generation history
│   └── thumbnails/                 ← Preview thumbnails
├── backgrounds/
│   ├── workshop_dashboard.png
│   ├── ship_dashboard.png
│   └── README.md
├── buttons/
│   ├── lcars_button_primary_states.png
│   ├── lcars_button_large.png
│   ├── button_colors.png           ← All color variations in one sheet
│   └── README.md
├── frames/
│   ├── frame_viewscreen_main.png
│   ├── frame_mission_display.png
│   └── README.md
├── panels/
│   ├── panel_info_standard.png
│   ├── panel_info_wide.png
│   └── README.md
├── indicators/
│   ├── status_bars.png             ← All bars in one sheet
│   ├── alert_indicators.png
│   └── README.md
└── overlays/
    ├── loading_overlay.png
    ├── tooltip_backgrounds.png
    └── README.md
```

### Asset Index Template

**Create `godot/assets/ui/_catalog/asset_index.md`:**

```markdown
# UI Asset Catalog

**Last Updated:** [DATE]
**Total Assets:** [COUNT]

## Buttons

| File | Size | Type | States | Colors | Status |
|------|------|------|--------|--------|--------|
| lcars_button_primary_states.png | 620x60 | Button Set | 3 (N/H/P) | Orange | ✓ Done |
| lcars_button_large.png | 400x80 | Single | 1 (Normal) | Orange | ✓ Done |
| button_colors.png | 200x330 | Button Set | 1 (Normal) | 5 colors | ✓ Done |

## Panels

| File | Size | Type | Transparency | Purpose | Status |
|------|------|------|--------------|---------|--------|
| panel_info_standard.png | 400x250 | Info Panel | 70% BG | General info | ✓ Done |
| panel_info_wide.png | 800x200 | Info Panel | 70% BG | Wide data | ✓ Done |

## Frames

| File | Size | Type | Transparency | Purpose | Status |
|------|------|------|--------------|---------|--------|
| frame_viewscreen_main.png | 1280x720 | Display Frame | 100% center | Space view | ✓ Done |
| frame_mission_display.png | 768x512 | Display Frame | 100% center | Mission art | ✓ Done |

## Status Indicators

| File | Size | Type | Variants | Purpose | Status |
|------|------|------|----------|---------|--------|
| status_bars.png | 300x230 | Bar Set | 5 colors | HP/Power/etc | ✓ Done |
| alert_indicators.png | 480x60 | Indicator Set | 3 states | Ship alerts | ✓ Done |

## Backgrounds

| File | Size | Type | Phase | Status |
|------|------|------|-------|--------|
| workshop_dashboard.png | 1280x720 | Background | Phase 1 | ✓ Done |
| ship_dashboard.png | 1280x720 | Background | Phase 2 | ⏸ Deferred |

---

## Generation Notes

### Successful Prompts
- Button generation works best with emphasis on "pill shape"
- Frames need strong "COMPLETELY TRANSPARENT center" emphasis
- Status bars need explicit "container 40% transparent, fill opaque"

### Issues Encountered
- [Document any generation problems and solutions]

### Iteration History
- Button set v1: Had text, regenerated with stronger negative prompt
- Viewscreen frame v1: Center wasn't transparent, fixed in GIMP
```

### README Template (Per Directory)

**Example `godot/assets/ui/buttons/README.md`:**

```markdown
# Buttons

**Generated:** November 6, 2025
**Tool:** ChatGPT DALL-E 3
**Source Prompts:** ui-graphics-copy-paste-prompts.md

## Assets in this Directory

### lcars_button_primary_states.png
- **Size:** 620x60 pixels
- **Contains:** 3 button states (normal, hover, pressed)
- **Color:** LCARS Orange (#FF9900)
- **Usage:** Primary action buttons
- **Slice regions:**
  - Normal: (0, 0, 200, 60)
  - Hover: (210, 0, 200, 60)
  - Pressed: (420, 0, 200, 60)

### lcars_button_large.png
- **Size:** 400x80 pixels
- **Contains:** Single large button (normal state)
- **Color:** LCARS Orange (#FF9900)
- **Usage:** Prominent actions like "START MISSION", "LAUNCH"

### button_colors.png
- **Size:** 200x330 pixels
- **Contains:** 5 button colors (all normal state)
- **Colors:** Orange, Blue, Green, Yellow, Red
- **Slice regions:**
  - Orange: (0, 0, 200, 60)
  - Blue: (0, 70, 200, 60)
  - Green: (0, 140, 200, 60)
  - Yellow: (0, 210, 200, 60)
  - Red: (0, 280, 200, 60)

## Implementation Example

```gdscript
# Load button texture
var button_texture = load("res://assets/ui/buttons/lcars_button_primary_states.png")

# Create atlas for each state
var normal_atlas = AtlasTexture.new()
normal_atlas.atlas = button_texture
normal_atlas.region = Rect2(0, 0, 200, 60)

var hover_atlas = AtlasTexture.new()
hover_atlas.atlas = button_texture
hover_atlas.region = Rect2(210, 0, 200, 60)

var pressed_atlas = AtlasTexture.new()
pressed_atlas.atlas = button_texture
pressed_atlas.region = Rect2(420, 0, 200, 60)

# Apply to button
$Button.texture_normal = normal_atlas
$Button.texture_hover = hover_atlas
$Button.texture_pressed = pressed_atlas
```

## Variations Needed

- [ ] Small buttons (120x40)
- [ ] Icon buttons (60x60 square)
- [ ] Toggle buttons (on/off states)
- [ ] Disabled state (grayed out)
```

---

## Quality Control Workflow

### Batch Review Process

**After generating 5-10 assets, review all at once:**

#### 1. Create Review Sheet

```bash
# review_assets.sh
#!/bin/bash

echo "# Asset Review - $(date)" > review.md
echo "" >> review.md

for file in godot/assets/ui/*/*.png; do
    echo "## $(basename $file)" >> review.md
    echo "- **Path:** $file" >> review.md
    echo "- **Size:** $(identify -format "%wx%h" "$file")" >> review.md
    echo "- **File Size:** $(du -h "$file" | cut -f1)" >> review.md
    echo "- **Has Alpha:** $(identify -format "%A" "$file")" >> review.md
    echo "" >> review.md
    echo "**Preview:**" >> review.md
    echo "![$(basename $file)]($file)" >> review.md
    echo "" >> review.md
    echo "**Status:** [ ] Approved [ ] Needs Revision" >> review.md
    echo "**Notes:**" >> review.md
    echo "" >> review.md
done
```

#### 2. Visual Inspection Checklist

For each asset, check:

```
□ Correct dimensions (matches specification)
□ Correct file format (PNG)
□ Transparency where specified (use checkerboard background)
□ Colors match hex codes (eyedropper tool)
□ No text rendered (should be solid shapes only)
□ Clean edges (no pixelation or blur)
□ Consistent style with other assets
□ File size reasonable (<500KB, most <200KB)
□ Filename follows convention
```

#### 3. Technical Validation Script

```python
# validate_assets.py
from PIL import Image
import os
import json

SPECS = {
    "buttons/lcars_button_primary_states.png": {
        "dimensions": (620, 60),
        "mode": "RGB",
        "max_size_kb": 300
    },
    "frames/frame_viewscreen_main.png": {
        "dimensions": (1280, 720),
        "mode": "RGBA",  # Must have alpha
        "max_size_kb": 500
    },
    # Add more specs
}

def validate_asset(path, spec):
    """Validate a single asset against spec"""
    errors = []

    # Check exists
    if not os.path.exists(path):
        return [f"File not found: {path}"]

    # Open image
    img = Image.open(path)

    # Check dimensions
    if img.size != spec["dimensions"]:
        errors.append(f"Wrong size: {img.size}, expected {spec['dimensions']}")

    # Check mode (RGB vs RGBA)
    if img.mode != spec["mode"]:
        errors.append(f"Wrong mode: {img.mode}, expected {spec['mode']}")

    # Check file size
    size_kb = os.path.getsize(path) / 1024
    if size_kb > spec["max_size_kb"]:
        errors.append(f"Too large: {size_kb:.1f}KB, max {spec['max_size_kb']}KB")

    return errors

def validate_all():
    """Validate all assets"""
    results = {}

    for asset_path, spec in SPECS.items():
        full_path = f"godot/assets/ui/{asset_path}"
        errors = validate_asset(full_path, spec)
        results[asset_path] = {
            "valid": len(errors) == 0,
            "errors": errors
        }

    # Print results
    passed = sum(1 for r in results.values() if r["valid"])
    total = len(results)

    print(f"\nValidation Results: {passed}/{total} passed\n")

    for asset, result in results.items():
        status = "✓" if result["valid"] else "✗"
        print(f"{status} {asset}")
        for error in result["errors"]:
            print(f"  - {error}")

    # Save report
    with open("validation_report.json", "w") as f:
        json.dump(results, f, indent=2)

    return passed == total

if __name__ == "__main__":
    all_valid = validate_all()
    exit(0 if all_valid else 1)
```

**Usage:**
```bash
python validate_assets.py
# Outputs validation report
# Exit code 0 if all pass, 1 if any fail
```

---

## Automation Scripts

### Auto-Organize Downloaded Assets

```bash
#!/bin/bash
# organize_downloads.sh
# Run this after downloading assets from ChatGPT

DOWNLOAD_DIR=~/Downloads
ASSET_DIR=godot/assets/ui

echo "Organizing UI assets from Downloads..."

# Buttons
mv "$DOWNLOAD_DIR"/*button*.png "$ASSET_DIR/buttons/" 2>/dev/null
echo "✓ Organized buttons"

# Panels
mv "$DOWNLOAD_DIR"/*panel*.png "$ASSET_DIR/panels/" 2>/dev/null
echo "✓ Organized panels"

# Frames
mv "$DOWNLOAD_DIR"/*frame*.png "$ASSET_DIR/frames/" 2>/dev/null
mv "$DOWNLOAD_DIR"/*viewscreen*.png "$ASSET_DIR/frames/" 2>/dev/null
echo "✓ Organized frames"

# Indicators
mv "$DOWNLOAD_DIR"/*status*.png "$ASSET_DIR/indicators/" 2>/dev/null
mv "$DOWNLOAD_DIR"/*alert*.png "$ASSET_DIR/indicators/" 2>/dev/null
echo "✓ Organized indicators"

# Backgrounds
mv "$DOWNLOAD_DIR"/*dashboard*.png "$ASSET_DIR/backgrounds/" 2>/dev/null
mv "$DOWNLOAD_DIR"/*background*.png "$ASSET_DIR/backgrounds/" 2>/dev/null
echo "✓ Organized backgrounds"

# Update catalog
echo "Updating asset catalog..."
ls -lh "$ASSET_DIR"/*/*.png > "$ASSET_DIR/_catalog/file_list.txt"

echo "✓ Done! Assets organized."
```

### Batch Thumbnail Generator

```python
# generate_thumbnails.py
from PIL import Image
import os

INPUT_DIR = "godot/assets/ui"
OUTPUT_DIR = "godot/assets/ui/_catalog/thumbnails"
THUMB_SIZE = (200, 200)

os.makedirs(OUTPUT_DIR, exist_ok=True)

for root, dirs, files in os.walk(INPUT_DIR):
    for file in files:
        if file.endswith(".png") and "_catalog" not in root:
            input_path = os.path.join(root, file)
            output_path = os.path.join(OUTPUT_DIR, file)

            # Create thumbnail
            img = Image.open(input_path)
            img.thumbnail(THUMB_SIZE, Image.Resampling.LANCZOS)
            img.save(output_path)

            print(f"✓ {file}")

print(f"\nGenerated thumbnails in {OUTPUT_DIR}")
```

---

## Time Estimates

### ChatGPT Batch Generation

**With prepared prompts:**
- Setup conversation: 2 minutes
- 5 button variations: 5 minutes (1 request)
- 3 panel variations: 3 minutes (1 request)
- 4 frame types: 4 minutes (1 request)
- 6 indicator variations: 6 minutes (1 request)
- **Total: ~20 minutes for 18 assets**

**With iterations (likely):**
- Add 30-50% time for regenerations: ~30 minutes total

### Stable Diffusion Batch

**Local generation:**
- 1 asset: 30-60 seconds
- 20 assets batch: 10-20 minutes (unattended)
- Quality review: 10 minutes
- **Total: ~30 minutes (mostly automated)**

### Organization & QA

- Download and organize: 5 minutes
- Visual inspection (20 assets): 10 minutes
- Technical validation: 2 minutes
- Update catalog: 3 minutes
- **Total: ~20 minutes**

### Full Session

**Generate 20-30 assets in one sitting:**
- Generation: 30 minutes
- Organization: 5 minutes
- Quality control: 15 minutes
- Testing in Godot: 20 minutes
- **Total: ~70 minutes (1-1.5 hours)**

---

## Best Practices

1. **Work in batches** - Generate 5-10 related assets at once
2. **Use consistent sessions** - Same ChatGPT conversation maintains style
3. **Validate immediately** - Check assets right after generation
4. **Organize as you go** - Don't let downloads pile up
5. **Test frequently** - Import into Godot every batch
6. **Document everything** - Update catalog and README files
7. **Version control** - Commit batches of working assets
8. **Keep prompts** - Save successful prompts for variations

---

**Document Status:** Ready for batch asset generation
**Created:** November 6, 2025
**Next:** Start with ChatGPT batch workflow for fastest results!
