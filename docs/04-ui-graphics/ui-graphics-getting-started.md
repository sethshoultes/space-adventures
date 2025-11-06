# UI Graphics Generation: Getting Started Tutorial

**Version:** 1.0
**Date:** November 6, 2025
**Purpose:** Step-by-step tutorial for generating your first UI assets
**Time Required:** 1-2 hours for first 10 essential assets

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Your First Asset: LCARS Button](#your-first-asset-lcars-button)
3. [Essential Assets Order](#essential-assets-order)
4. [Week 1 Asset Generation Plan](#week-1-asset-generation-plan)
5. [Testing in Godot](#testing-in-godot)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Tools You'll Need

**AI Generation Tool (Choose One):**
- ✅ **ChatGPT Plus** ($20/month) - DALL-E 3 built-in, best for beginners
- ✅ **Midjourney** ($10-30/month) - High quality, requires Discord
- ✅ **Stable Diffusion** (Free) - Local generation, requires GPU

**Image Editing (Optional but Recommended):**
- ✅ **GIMP** (Free) - For transparency fixes and adjustments
- ✅ **Photoshop** (Paid) - Alternative to GIMP

**Testing:**
- ✅ **Godot 4.2+** - To test assets in the actual game engine

### Setup Your Workspace

```bash
# Create directory structure
cd space-adventures
mkdir -p godot/assets/ui/{backgrounds,frames,buttons,panels,indicators,overlays}
mkdir -p godot/assets/ui/temp  # For review before finalizing

# Open documentation
code docs/ui-graphics-copy-paste-prompts.md  # Keep this open for reference
```

---

## Your First Asset: LCARS Button

Let's generate your first UI asset step-by-step.

### Step 1: Copy the Prompt

Open `docs/ui-graphics-copy-paste-prompts.md` and find **Section 4A: Standard LCARS Button (3 States)**

Copy this entire prompt:
```
Create a Star Trek LCARS-style button showing all 3 interaction states side by side horizontally. Each button is a rounded rectangle (pill shape) size 200x60 pixels. Generate these states from left to right with 10 pixels spacing between them:

1. NORMAL STATE: Solid LCARS orange (#FF9900) fill with subtle vertical gradient (lighter at top). 2-pixel border in darker orange (#CC7700).

2. HOVER STATE: Brighter yellow-orange (#FFB627) fill with glowing effect. Border glows subtly.

3. PRESSED STATE: Darker orange (#CC7700) fill with slight inset shadow effect suggesting depression.

All buttons are fully opaque (no transparency - PNG alpha = 255). Clean professional appearance. NO TEXT - leave as solid colored shapes for text overlay by game engine. Total image size: 620x60 pixels (3 buttons plus spacing). Export as standard opaque PNG.

Style: LCARS buttons, Star Trek TNG inspired, clean design
Colors: Orange (#FF9900) normal, bright yellow (#FFB627) hover, dark orange (#CC7700) pressed
Format: PNG 620x60, fully opaque, 3 states in one image
```

### Step 2: Generate with ChatGPT

1. Open ChatGPT Plus (must have DALL-E 3 access)
2. Start a new conversation
3. Type: "I need you to generate a UI asset for a game. Here are the exact specifications:"
4. Paste the entire prompt
5. Add: "Please generate this as PNG with the exact dimensions specified."
6. Press Enter

**ChatGPT will:**
- Generate the image
- Show you a preview
- Provide a download link

### Step 3: Download and Review

1. **Click download** - Save as `lcars_button_states_v1.png`
2. **Open in image viewer** - Check dimensions (should be 620x60)
3. **Review the output:**
   - ✅ Are there 3 buttons side by side?
   - ✅ Is the first button orange (#FF9900)?
   - ✅ Is the second button brighter/yellow?
   - ✅ Is the third button darker?
   - ✅ Are they rounded rectangles (pill shape)?
   - ✅ Is there NO TEXT in the buttons?
   - ✅ Size approximately 620x60 pixels?

### Step 4: Check Technical Specs

**Open in GIMP to verify:**
```
File > Open > lcars_button_states_v1.png

Check in GIMP:
- Image > Image Properties
  - Should show: 620x60 pixels
  - Mode should be: RGB (it's okay if no alpha channel for opaque buttons)

View actual size: View > Zoom > 1:1 (100%)
```

### Step 5: If Iteration Needed

**If something isn't right:**

**Problem:** Buttons have text on them
**Solution:** Reply to ChatGPT: "Please regenerate without any text, letters, or words. Leave the buttons as solid colored shapes only."

**Problem:** Colors are wrong
**Solution:** Reply: "Please adjust the colors to exactly: #FF9900 for normal, #FFB627 for hover, #CC7700 for pressed."

**Problem:** Size is wrong
**Solution:** Reply: "Please regenerate at exactly 620 pixels wide by 60 pixels tall."

### Step 6: Finalize and Save

Once you're happy:
```bash
# Move to final location
mv lcars_button_states_v1.png godot/assets/ui/buttons/lcars_button_primary_states.png

# Create note for yourself
echo "Generated: $(date)" > godot/assets/ui/buttons/README.md
echo "Source: ui-graphics-copy-paste-prompts.md Section 4A" >> godot/assets/ui/buttons/README.md
```

### Step 7: Test in Godot

Create a simple test scene:

```gdscript
# test_button.gd
extends Control

@onready var button_texture = load("res://assets/ui/buttons/lcars_button_primary_states.png")

func _ready():
    var button = TextureButton.new()

    # Create AtlasTexture for each state
    var normal_atlas = AtlasTexture.new()
    normal_atlas.atlas = button_texture
    normal_atlas.region = Rect2(0, 0, 200, 60)  # First button

    var hover_atlas = AtlasTexture.new()
    hover_atlas.atlas = button_texture
    hover_atlas.region = Rect2(210, 0, 200, 60)  # Second button

    var pressed_atlas = AtlasTexture.new()
    pressed_atlas.atlas = button_texture
    pressed_atlas.region = Rect2(420, 0, 200, 60)  # Third button

    button.texture_normal = normal_atlas
    button.texture_hover = hover_atlas
    button.texture_pressed = pressed_atlas

    # Add label
    var label = Label.new()
    label.text = "START MISSION"
    label.position = Vector2(50, 20)
    button.add_child(label)

    add_child(button)
    button.position = Vector2(100, 100)
```

**Test it:**
1. Run the scene in Godot (F6)
2. Hover over button - should change to bright yellow
3. Click button - should darken
4. Release - should return to normal

🎉 **Congratulations!** You've generated and implemented your first UI asset!

---

## Essential Assets Order

Now that you know the process, generate these assets in priority order.

### Priority 1: Core Buttons (Day 1, ~30 minutes)

**Generate these button sets:**

1. ✅ **LCARS Button Primary (Orange)** - Just completed!
2. **LCARS Button Secondary (Blue)**
   - Use Section 4C prompt, generate just the blue variation
   - Save as: `lcars_button_secondary_states.png`

3. **LCARS Button Success (Green)**
   - Use Section 4C prompt, generate just the green variation
   - Save as: `lcars_button_success_states.png`

4. **LCARS Button Danger (Red)**
   - Use Section 4C prompt, generate just the red variation
   - Save as: `lcars_button_danger_states.png`

5. **Large Action Button**
   - Use Section 4B prompt
   - Save as: `lcars_button_large_primary.png`

**Why these first?** Buttons are used everywhere in the UI. Get them done and you can start building interactive screens immediately.

### Priority 2: Information Panels (Day 1, ~45 minutes)

6. **Standard Info Panel (400x250)**
   - Use Section from `ui-graphics-prompt-guide.md` #8
   - Save as: `panel_info_standard.png`

7. **Wide Panel (800x200)**
   - Modify dimensions in prompt
   - Save as: `panel_info_wide.png`

8. **Side Panel (300x600)**
   - Modify dimensions in prompt
   - Save as: `panel_side_navigation.png`

### Priority 3: Ship Windows (Day 2, ~1 hour)

9. **Main Viewscreen Frame**
   - Use Section 1A from copy-paste prompts
   - Save as: `frame_viewscreen_main.png`
   - **Critical:** Test transparency! Center MUST be fully transparent

10. **Mission Display Frame**
    - Use Section 6A from copy-paste prompts
    - Save as: `frame_mission_display.png`

### Priority 4: Status Indicators (Day 2, ~45 minutes)

11. **Status Bar Set (5 colors)**
    - Use Section 5A from copy-paste prompts
    - Save as: `indicator_status_bars.png`

12. **Alert Status Indicators**
    - Use Section 5B from copy-paste prompts
    - Save as: `indicator_alert_status.png`

### Priority 5: Backgrounds (Day 3, ~1.5 hours)

13. **Workshop Dashboard Background**
    - Use Section 3A from copy-paste prompts
    - This may need 2-3 iterations to get right
    - Save as: `background_workshop_dashboard.png`

14. **Ship Bridge Background (if needed for testing)**
    - Can defer to Phase 2 implementation
    - Use Section from dashboard prompts

---

## Week 1 Asset Generation Plan

### Day 1: Buttons & Panels (3 hours)
```
Morning (1.5 hours):
□ Generate all 5 button variations
□ Test each in Godot test scene
□ Fix any issues

Afternoon (1.5 hours):
□ Generate 3 panel variations
□ Test transparency in Godot
□ Create panel demo scene
```

### Day 2: Frames & Indicators (3 hours)
```
Morning (1.5 hours):
□ Generate viewscreen frame
□ Test transparency with space background
□ Generate mission display frame
□ Fix any transparency issues in GIMP

Afternoon (1.5 hours):
□ Generate status bar set
□ Generate alert indicators
□ Test in Godot with dynamic values
□ Create status indicator demo
```

### Day 3: Backgrounds & Polish (4 hours)
```
Morning (2 hours):
□ Generate workshop dashboard background
□ Review and iterate if needed
□ Test in full dashboard mock-up

Afternoon (2 hours):
□ Review all assets for consistency
□ Fix any issues
□ Create asset catalog document
□ Organize files properly
```

### Days 4-5: Additional Assets (6 hours)
```
Generate as needed:
□ Modal dialogs (3 types)
□ Tooltips
□ Loading overlays
□ Context menus
□ Special effects
```

---

## Testing in Godot

### Quick Test Scene Template

Create this reusable test scene:

```gdscript
# ui_asset_tester.gd
extends Control

var test_asset_path: String = ""

func _ready():
    # Test any asset by changing the path
    test_asset_path = "res://assets/ui/buttons/lcars_button_primary_states.png"
    load_and_display()

func load_and_display():
    var texture = load(test_asset_path)

    # Display full image
    var texture_rect = TextureRect.new()
    texture_rect.texture = texture
    texture_rect.position = Vector2(50, 50)
    add_child(texture_rect)

    # Add info label
    var info = Label.new()
    info.text = "Asset: %s\nSize: %dx%d" % [
        test_asset_path.get_file(),
        texture.get_width(),
        texture.get_height()
    ]
    info.position = Vector2(50, 150)
    add_child(info)

    # Add checkered background to test transparency
    var bg = ColorRect.new()
    bg.color = Color(0.2, 0.2, 0.2)
    bg.size = Vector2(1280, 720)
    bg.z_index = -1
    add_child(bg)
```

### Testing Transparency

**For assets that should have transparency:**

```gdscript
# transparency_test.gd
extends Control

func _ready():
    # Load asset to test
    var asset = load("res://assets/ui/frames/frame_viewscreen_main.png")

    # Create test setup
    var bg_space = TextureRect.new()
    bg_space.texture = load("res://assets/backgrounds/space_stars.png")  # Space background
    bg_space.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
    bg_space.size = Vector2(1280, 720)
    add_child(bg_space)

    # Overlay frame on top
    var frame = TextureRect.new()
    frame.texture = asset
    frame.size = Vector2(1280, 720)
    add_child(frame)

    # You should see space through the center of the frame
    # If you see white/black instead, transparency is wrong
```

### Asset Verification Checklist

Create this scene to verify all assets:

```gdscript
# asset_verification.gd
extends Control

var assets_to_verify = [
    "res://assets/ui/buttons/lcars_button_primary_states.png",
    "res://assets/ui/panels/panel_info_standard.png",
    "res://assets/ui/frames/frame_viewscreen_main.png",
    # Add more as you generate them
]

func _ready():
    var y_pos = 10
    for asset_path in assets_to_verify:
        if FileAccess.file_exists(asset_path):
            create_asset_preview(asset_path, y_pos)
            y_pos += 150
        else:
            print("MISSING: ", asset_path)

func create_asset_preview(path: String, y: int):
    var texture = load(path)

    # Preview
    var preview = TextureRect.new()
    preview.texture = texture
    preview.position = Vector2(10, y)
    preview.custom_minimum_size = Vector2(200, 100)
    preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
    add_child(preview)

    # Info
    var label = Label.new()
    label.text = "%s\n%dx%d\n%.1f KB" % [
        path.get_file(),
        texture.get_width(),
        texture.get_height(),
        float(FileAccess.get_file_as_bytes(path).size()) / 1024.0
    ]
    label.position = Vector2(220, y)
    add_child(label)

    # Status
    var status = Label.new()
    status.text = "✓ OK"
    status.modulate = Color.GREEN
    status.position = Vector2(400, y)
    add_child(status)
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: AI Generated Text in Image

**Symptom:** Words or letters appear on buttons/panels
**Solution:**
```
1. Emphasize in prompt: "NO TEXT, NO WORDS, NO LETTERS"
2. Add to negative prompt: "text, words, letters, numbers, labels"
3. If still happening, manually remove in GIMP:
   - Use Clone tool to paint over text
   - Or regenerate with even stronger emphasis
```

#### Issue 2: Wrong Colors

**Symptom:** Colors don't match hex codes specified
**Solution:**
```
1. In GIMP: Colors > Hue-Saturation
2. Adjust hue slider until color matches
3. Or use Color > Map > Color Exchange to replace colors
4. Better: Regenerate with emphasis on exact hex codes
```

#### Issue 3: Transparency Not Working

**Symptom:** Center should be transparent but shows white/black
**Solution:**
```
Fix in GIMP:
1. Open PNG
2. Right-click layer > Add Alpha Channel (if not present)
3. Select > By Color > Click the center area
4. Edit > Clear (or press Delete)
5. Verify: Layer > Transparency > Threshold Alpha
6. Export as PNG-24 with alpha channel
```

#### Issue 4: Size is Wrong

**Symptom:** Image is not the specified dimensions
**Solution:**
```
In GIMP:
1. Image > Scale Image
2. Set exact dimensions (e.g., 620x60)
3. Interpolation: Cubic (best quality)
4. Export

Prevention: Emphasize dimensions in prompt:
"MUST BE EXACTLY 620 pixels wide by 60 pixels tall"
```

#### Issue 5: File Too Large

**Symptom:** PNG file is over 1MB (target is <500KB)
**Solution:**
```
Command line optimization:
pngcrush -rem alla -reduce input.png output.png

Or in GIMP:
File > Export As > PNG
- Compression level: 9
- Save background color: unchecked
- Save resolution: unchecked
```

#### Issue 6: Looks Wrong in Godot

**Symptom:** Asset looks fine in image viewer but wrong in Godot
**Solution:**
```
1. Check import settings in Godot:
   - Right-click asset in FileSystem
   - Reimport tab
   - Ensure "Compress" is appropriate
   - Click "Reimport"

2. Check texture filter:
   - In script: texture.filter = Texture.FILTER_NEAREST (for pixel art)
   - Or: texture.filter = Texture.FILTER_LINEAR (for smooth)
```

---

## Batch Generation Tips

### Use ChatGPT Memory

**First message to ChatGPT:**
```
I'm generating UI assets for a space game. Please remember these standards for all assets I request:

Style: Star Trek LCARS, retro sci-fi
Colors: Orange (#FF9900), Blue (#9999FF), Purple (#CC99CC), Dark backgrounds (#0A0E1A, #1A1F2E)
Format: Always PNG
Transparency: When specified, MUST have alpha channel
Text: Never include text, words, or letters
Quality: Professional, clean, serious tone

Confirm you understand and will apply these to all future requests in this conversation.
```

Then you can use shorter prompts like:
```
"Generate a button, 200x60, normal/hover/pressed states, orange color scheme"
```

### Track Your Progress

Create a checklist file:

```markdown
# UI Asset Generation Progress

## Week 1 - Essential Assets

### Buttons
- [x] Primary LCARS button (orange) - lcars_button_primary_states.png
- [x] Secondary button (blue) - lcars_button_secondary_states.png
- [ ] Success button (green)
- [ ] Danger button (red)
- [ ] Large action button

### Panels
- [ ] Info panel standard (400x250)
- [ ] Info panel wide (800x200)
- [ ] Side navigation panel (300x600)

### Frames
- [ ] Main viewscreen frame (1280x720)
- [ ] Mission display frame (768x512)

### Indicators
- [ ] Status bars (5 colors)
- [ ] Alert status (3 states)

### Backgrounds
- [ ] Workshop dashboard (1280x720)

## Week 2 - Additional Assets
...
```

---

## Next Steps

After completing Week 1 assets:

1. **Review consistency** - Do all assets look like they belong together?
2. **Create demo scenes** - Build example UI layouts using your assets
3. **Document variations** - Note which prompts worked best
4. **Generate variations** - Create additional size variations as needed
5. **Move to Week 2 assets** - Continue with lower priority elements

---

## Resources

**Reference Documents:**
- `ui-graphics-prompt-guide.md` - Detailed prompts with explanations
- `ui-graphics-copy-paste-prompts.md` - Ready-to-use prompts
- `ui-graphics-quick-reference.md` - Fast lookup

**Test Files:**
- Create `godot/test_scenes/ui_asset_test.tscn` - For testing assets
- Create `godot/test_scenes/transparency_test.tscn` - For checking transparency

**Organization:**
```
godot/assets/ui/
├── _GENERATION_LOG.md          ← Track what you've generated
├── _PROMPTS_USED.md            ← Save successful prompts
├── backgrounds/
├── buttons/
├── frames/
├── panels/
├── indicators/
└── overlays/
```

---

## Success Metrics

**Week 1 Complete When:**
- ✅ 5+ button variations generated and tested
- ✅ 3+ panel variations with proper transparency
- ✅ 2+ frame types with working transparency
- ✅ Status indicators functional
- ✅ At least 1 background (workshop)
- ✅ All assets tested in Godot
- ✅ Asset catalog created

**You're Ready to Build UI When:**
- You can create buttons that respond to interaction
- Panels overlay correctly on backgrounds
- Frames show content through transparent centers
- Status bars update dynamically
- The style feels consistent across all assets

---

**Good luck with your asset generation! 🎨🚀**

**Need help?** Refer back to the detailed prompt guide or quick reference.

**Document Created:** November 6, 2025
**Ready to Start:** Follow Day 1 plan above!
