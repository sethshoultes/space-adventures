# Main Menu Background Image

## How to Add the Background Image

1. **Save your DALL-E generated image** (1920x1080) as `main_menu_bg.png`

2. **Copy the image to this directory:**
   ```
   /Users/sethshoultes/Local Sites/space-adventures/godot/assets/sprites/backgrounds/main_menu_bg.png
   ```

3. **The image will automatically load** when you run the game - no further configuration needed!

## Image Specifications

- **Resolution:** 1920x1080 (exact)
- **Format:** PNG (recommended for transparency support if needed)
- **Filename:** `main_menu_bg.png` (case-sensitive)
- **Design:** Deep space with 4 planets in corners:
  - Cyan planet (bottom-left)
  - Gray planet (top-left)
  - Purple planet (top-right)
  - Orange planet (bottom-right)
  - Starfield throughout

## Fallback Behavior

If no background image is found, the main menu will use a fallback solid color background:
- Color: Dark blue-gray (#1a1d2e)
- This ensures the UI remains visible and usable

## Testing

After adding the image:
1. Launch the game
2. Check the console output for: `"Main Menu: Background image loaded"`
3. If you see `"Main Menu: No background image found, using fallback color"`, verify:
   - File exists at the exact path
   - Filename is exactly `main_menu_bg.png`
   - File permissions allow reading

## Re-importing

If you replace the image while Godot is running:
1. The new image will be imported automatically
2. Restart the scene (F5) to see changes
3. You may need to restart Godot if the image doesn't update
