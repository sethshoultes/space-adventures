# Space Adventures - Visual Features & AI Image Generation

**Version:** 1.0
**Date:** November 5, 2025
**Purpose:** Comprehensive visual system design with AI image generation

---

## Table of Contents
1. [Overview](#overview)
2. [AI Image Generation Architecture](#ai-image-generation-architecture)
3. [Galaxy Map System](#galaxy-map-system)
4. [Mission Location Visuals](#mission-location-visuals)
5. [Ship Visualization](#ship-visualization)
6. [Character Portraits](#character-portraits)
7. [Space Phenomena](#space-phenomena)
8. [UI Enhancement](#ui-enhancement)
9. [Implementation Plan](#implementation-plan)

---

## Overview

### Visual Philosophy

**Art Style:** Cohesive retro sci-fi aesthetic combining:
- **Pixel art** for UI elements and icons
- **AI-generated illustrations** for locations, characters, and phenomena
- **ASCII/Terminal style** for ship schematics and technical displays
- **Clean modern UI** for menus and interfaces

**Style Prompt Base:**
```
"retro sci-fi, pixel art style, 16-bit aesthetic, Star Trek TNG inspired,
serious tone, detailed, cohesive color palette (deep blues, cyans, oranges),
no lens flare, no modern CGI look"
```

### Budget & Timeline

**Budget:** Unlimited AI generation credits
**Timeline:** Integrated into MVP (Weeks 1-6)
**Image Count (MVP):** ~150-200 unique images
- 30 mission locations
- 20 character portraits
- 15 space phenomena
- 10 ship variants
- 25 UI illustrations

**Post-MVP:** Dynamic generation at runtime for truly infinite variety

---

## AI Image Generation Architecture

### Technology Stack

**Primary:** Stable Diffusion (local or API)
- **Why:** Best control, consistent style, can run locally
- **Model:** Stable Diffusion XL with LoRA for pixel art style
- **Alternative:** DALL-E 3 for higher quality, MidJourney for artistic

**Python Service Integration:**
```python
# python/src/ai/image_generation.py

from diffusers import StableDiffusionXLPipeline
import torch
from PIL import Image
from typing import Optional
import hashlib
import os

class ImageGenerator:
    def __init__(self):
        self.model = self._load_model()
        self.cache_dir = "generated_images/cache"
        self.style_base = "retro sci-fi, pixel art, 16-bit, Star Trek inspired"

    def _load_model(self):
        """Load Stable Diffusion model"""
        model = StableDiffusionXLPipeline.from_pretrained(
            "stabilityai/stable-diffusion-xl-base-1.0",
            torch_dtype=torch.float16,
            use_safetensors=True
        )
        model.to("cuda" if torch.cuda.is_available() else "cpu")
        return model

    async def generate_location(
        self,
        description: str,
        mission_type: str,
        difficulty: int,
        seed: Optional[int] = None
    ) -> str:
        """Generate mission location image"""

        # Build comprehensive prompt
        prompt = self._build_location_prompt(description, mission_type, difficulty)

        # Check cache
        cache_key = self._get_cache_key(prompt, seed)
        cached_path = self._check_cache(cache_key)
        if cached_path:
            return cached_path

        # Generate image
        image = self.model(
            prompt=prompt,
            negative_prompt=self._get_negative_prompt(),
            num_inference_steps=50,
            guidance_scale=7.5,
            width=768,
            height=512,
            generator=torch.Generator().manual_seed(seed) if seed else None
        ).images[0]

        # Save and cache
        image_path = self._save_image(image, cache_key)
        return image_path

    def _build_location_prompt(
        self,
        description: str,
        mission_type: str,
        difficulty: int
    ) -> str:
        """Build detailed prompt for location"""

        mood_map = {
            1: "well-lit, safe atmosphere",
            2: "slightly ominous, some decay",
            3: "dangerous, dark shadows, hazardous",
            4: "very dangerous, hostile environment",
            5: "extremely dangerous, apocalyptic"
        }

        type_details = {
            "salvage": "abandoned, derelict, rusted metal, scattered debris",
            "exploration": "mysterious, unknown, strange technology",
            "trade": "busy marketplace, diverse aliens, colorful stalls",
            "rescue": "emergency, damaged systems, danger signs",
            "combat": "militaristic, defensive positions, weapons visible",
            "story": "cinematic, dramatic lighting, important atmosphere"
        }

        return f"{self.style_base}, {description}, {type_details.get(mission_type, '')}, {mood_map.get(difficulty, '')}, detailed environment, no characters, establishing shot"

    def _get_negative_prompt(self) -> str:
        """What to avoid in generation"""
        return "blurry, low quality, modern CGI, lens flare, chromatic aberration, photorealistic, ugly, distorted, duplicate, watermark, signature, text"

    async def generate_character_portrait(
        self,
        name: str,
        species: str,
        description: str,
        personality: str,
        role: str
    ) -> str:
        """Generate NPC/crew member portrait"""

        prompt = f"{self.style_base}, character portrait, {species}, {description}, {personality} expression, {role}, headshot, pixel art portrait, detailed face, Star Trek TNG style uniform, no background"

        cache_key = self._get_cache_key(prompt)
        cached = self._check_cache(cache_key)
        if cached:
            return cached

        image = self.model(
            prompt=prompt,
            negative_prompt=self._get_negative_prompt() + ", multiple heads, multiple faces, body",
            num_inference_steps=50,
            guidance_scale=8.0,
            width=512,
            height=512
        ).images[0]

        return self._save_image(image, cache_key)

    async def generate_ship_exterior(
        self,
        ship_name: str,
        systems: dict,
        ship_class: str = "custom"
    ) -> str:
        """Generate ship exterior based on installed systems"""

        # Analyze ship configuration
        ship_desc = self._describe_ship_from_systems(systems)

        prompt = f"{self.style_base}, spaceship exterior, {ship_class} class vessel, {ship_desc}, detailed starship design, isometric view, pixel art, clean design, no background, white background"

        cache_key = self._get_cache_key(prompt)
        cached = self._check_cache(cache_key)
        if cached:
            return cached

        image = self.model(
            prompt=prompt,
            negative_prompt=self._get_negative_prompt(),
            num_inference_steps=60,
            guidance_scale=7.0,
            width=768,
            height=768
        ).images[0]

        return self._save_image(image, cache_key)

    def _describe_ship_from_systems(self, systems: dict) -> str:
        """Generate ship description from installed systems"""
        desc_parts = []

        if systems.get("hull", {}).get("level", 0) >= 3:
            desc_parts.append("reinforced armored hull")
        elif systems.get("hull", {}).get("level", 0) >= 1:
            desc_parts.append("basic hull plating")

        if systems.get("warp", {}).get("level", 0) >= 2:
            desc_parts.append("visible warp nacelles")

        if systems.get("weapons", {}).get("level", 0) >= 2:
            desc_parts.append("weapon arrays visible")

        if systems.get("shields", {}).get("level", 0) >= 3:
            desc_parts.append("shield emitters")

        return ", ".join(desc_parts) if desc_parts else "basic configuration"

    async def generate_phenomenon(
        self,
        phenomenon_type: str,
        description: str
    ) -> str:
        """Generate space phenomenon (nebula, anomaly, etc.)"""

        type_prompts = {
            "nebula": "colorful gas clouds, stellar nursery, cosmic dust",
            "black_hole": "gravitational lensing, accretion disk, event horizon",
            "wormhole": "spatial rift, quantum tunnel, swirling energy",
            "star": "stellar object, solar flares, corona",
            "planet": "planetary body, atmospheric details, surface features",
            "asteroid_field": "scattered asteroids, debris field, rocks",
            "anomaly": "strange energy signature, impossible geometry, quantum effect"
        }

        prompt = f"{self.style_base}, space scene, {type_prompts.get(phenomenon_type, '')}, {description}, cosmic vista, detailed, no ships, no characters"

        cache_key = self._get_cache_key(prompt)
        cached = self._check_cache(cache_key)
        if cached:
            return cached

        image = self.model(
            prompt=prompt,
            negative_prompt=self._get_negative_prompt(),
            num_inference_steps=50,
            guidance_scale=7.5,
            width=1024,
            height=576
        ).images[0]

        return self._save_image(image, cache_key)

    def _get_cache_key(self, prompt: str, seed: Optional[int] = None) -> str:
        """Generate cache key from prompt"""
        cache_input = f"{prompt}_{seed}" if seed else prompt
        return hashlib.md5(cache_input.encode()).hexdigest()

    def _check_cache(self, cache_key: str) -> Optional[str]:
        """Check if image already generated"""
        cache_path = os.path.join(self.cache_dir, f"{cache_key}.png")
        return cache_path if os.path.exists(cache_path) else None

    def _save_image(self, image: Image.Image, cache_key: str) -> str:
        """Save generated image"""
        os.makedirs(self.cache_dir, exist_ok=True)
        save_path = os.path.join(self.cache_dir, f"{cache_key}.png")
        image.save(save_path)
        return save_path
```

### API Endpoints

```python
# python/src/api/images.py

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from src.ai.image_generation import ImageGenerator

router = APIRouter()
generator = ImageGenerator()

class LocationImageRequest(BaseModel):
    description: str
    mission_type: str
    difficulty: int
    seed: int = None

class CharacterImageRequest(BaseModel):
    name: str
    species: str
    description: str
    personality: str
    role: str

class ShipImageRequest(BaseModel):
    ship_name: str
    systems: dict
    ship_class: str = "custom"

@router.post("/generate/location")
async def generate_location_image(request: LocationImageRequest):
    """Generate mission location image"""
    try:
        image_path = await generator.generate_location(
            request.description,
            request.mission_type,
            request.difficulty,
            request.seed
        )
        return {"image_path": image_path, "cached": False}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/generate/character")
async def generate_character_portrait(request: CharacterImageRequest):
    """Generate character portrait"""
    try:
        image_path = await generator.generate_character_portrait(
            request.name,
            request.species,
            request.description,
            request.personality,
            request.role
        )
        return {"image_path": image_path}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/generate/ship")
async def generate_ship_image(request: ShipImageRequest):
    """Generate ship exterior view"""
    try:
        image_path = await generator.generate_ship_exterior(
            request.ship_name,
            request.systems,
            request.ship_class
        )
        return {"image_path": image_path}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

### Godot Integration

```gdscript
# godot/scripts/autoload/image_service.gd
extends Node

const API_BASE = "http://localhost:8000/api/images"

var http_client = HTTPRequest.new()
var image_cache: Dictionary = {}

func _ready():
    add_child(http_client)
    http_client.request_completed.connect(_on_request_completed)

func request_location_image(description: String, mission_type: String, difficulty: int) -> void:
    var request_data = {
        "description": description,
        "mission_type": mission_type,
        "difficulty": difficulty
    }
    await _post_request("/generate/location", request_data)

func request_character_portrait(character: Dictionary) -> void:
    await _post_request("/generate/character", character)

func request_ship_image(ship_name: String, systems: Dictionary) -> void:
    var request_data = {
        "ship_name": ship_name,
        "systems": systems
    }
    await _post_request("/generate/ship", request_data)

func _post_request(endpoint: String, data: Dictionary) -> Dictionary:
    var url = API_BASE + endpoint
    var headers = ["Content-Type: application/json"]
    var json_data = JSON.stringify(data)

    var error = http_client.request(url, headers, HTTPClient.METHOD_POST, json_data)
    if error != OK:
        push_error("Image request failed: " + str(error))
        return {"error": "Request failed"}

    var response = await http_client.request_completed
    var result_code = response[1]
    var body = response[3]

    if result_code == 200:
        var json = JSON.new()
        var parse_result = json.parse(body.get_string_from_utf8())
        if parse_result == OK:
            return json.data

    return {"error": "Generation failed"}

func load_generated_image(image_path: String) -> Texture2D:
    """Load generated image from path"""
    if image_cache.has(image_path):
        return image_cache[image_path]

    var image = Image.new()
    var error = image.load(image_path)

    if error != OK:
        push_error("Failed to load image: " + image_path)
        return null

    var texture = ImageTexture.create_from_image(image)
    image_cache[image_path] = texture
    return texture
```

---

## Galaxy Map System

### Design

**Visual Style:** 2D star map with node-based navigation

```
┌──────────────────────────────────────────────────┐
│  GALAXY MAP - SECTOR 7                          │
├──────────────────────────────────────────────────┤
│                                                  │
│          [RIGEL SYSTEM] ★                       │
│                ╱  ╲                             │
│               ╱    ╲                            │
│              ╱      ╲                           │
│        [WOLF 359]   [SIRIUS] ☆                 │
│             │           │                        │
│             │           │                        │
│         [SOL] ◉    [α CENTAURI] ★              │
│                         │                        │
│                         │                        │
│                    [BARNARD'S] ☆               │
│                         │                        │
│                     [UNKNOWN] ?                 │
│                                                  │
│  Legend:                                        │
│  ◉ Current Location    ☆ Unvisited             │
│  ★ Visited             ? Undiscovered           │
│  ─ Warp Route          Distance: 4.3 LY        │
│                                                  │
│  [← Back]  [System Info]  [Set Course →]       │
└──────────────────────────────────────────────────┘
```

### Star System Data

```json
{
  "system_id": "sol",
  "name": "Sol System",
  "coordinates": {"x": 0, "y": 0},
  "star_type": "G-type main sequence",
  "planets": 8,
  "inhabited": true,
  "faction": "independent",
  "danger_level": 1,
  "description": "Birthplace of humanity. Earth is here.",
  "discovered": true,
  "visited": true,
  "warp_routes": ["alpha_centauri", "wolf_359"],
  "available_missions": ["mission_001", "mission_002"],
  "stations": [
    {
      "name": "Earth Orbit Station",
      "type": "trading",
      "services": ["repair", "trade", "missions"]
    }
  ],
  "phenomena": [],
  "background_image": "generated/sol_system.png"
}
```

### Implementation

```gdscript
# godot/scripts/galaxy_map.gd
extends Control

var star_systems: Dictionary = {}
var current_system: String = "sol"
var discovered_systems: Array = ["sol"]
var warp_routes: Dictionary = {}

func _ready():
    load_galaxy_data()
    render_map()

func load_galaxy_data():
    var file = FileAccess.open("res://assets/data/galaxy.json", FileAccess.READ)
    var json = JSON.new()
    json.parse(file.get_as_text())
    star_systems = json.data

func render_map():
    # Draw star positions
    for system_id in discovered_systems:
        var system = star_systems[system_id]
        draw_star_node(system)

    # Draw warp routes
    for route in warp_routes.values():
        draw_warp_route(route)

    # Highlight current position
    highlight_current_system()

func draw_star_node(system: Dictionary):
    # Create clickable star node
    var node = StarSystemButton.new()
    node.setup(system)
    node.pressed.connect(_on_system_selected.bind(system.system_id))
    add_child(node)

func set_course_to(destination_id: String):
    if not can_reach(destination_id):
        show_error("Cannot reach that system. Warp drive too weak.")
        return

    var distance = calculate_distance(current_system, destination_id)
    var fuel_cost = calculate_fuel_cost(distance)
    var travel_time = calculate_travel_time(distance)

    # Show confirmation dialog
    var dialog = ConfirmationDialog.new()
    dialog.dialog_text = "Travel to %s?\n\nDistance: %.1f LY\nFuel: %d units\nTime: %s" % [
        star_systems[destination_id].name,
        distance,
        fuel_cost,
        format_time(travel_time)
    ]
    dialog.confirmed.connect(_execute_warp.bind(destination_id))
    add_child(dialog)
    dialog.popup_centered()

func _execute_warp(destination_id: String):
    # Trigger warp sequence
    EventBus.emit_signal("warp_jump_started", destination_id)
    # Play warp animation
    # Update current system
    current_system = destination_id
    if not destination_id in discovered_systems:
        discovered_systems.append(destination_id)
    # Check for random encounter
    check_for_encounter()
```

---

## Mission Location Visuals

### UI Integration

```
┌──────────────────────────────────────────────────┐
│  MISSION: Echoes in Hangar 7                     │
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │  [AI-GENERATED LOCATION IMAGE]             │ │
│  │                                            │ │
│  │  Shows: Rusted spaceport gates, collapsed  │ │
│  │  towers, Hangar 7 in distance, overgrown  │ │
│  │  runway, patrol drones visible             │ │
│  │                                            │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  Kennedy Spaceport Ruins                        │
│  ────────────────────────────────               │
│                                                  │
│  The rusted gates of Kennedy Spaceport loom     │
│  ahead. Collapsed towers and overgrown runways  │
│  tell the story of rapid abandonment. Your      │
│  destination is Hangar 7, visible in the        │
│  distance. Security drones patrol in            │
│  predictable patterns.                          │
│                                                  │
│  How do you approach?                           │
│                                                  │
│  ○ Hack the security terminal [ENG 3]          │
│  ○ Wait for patrol, then sneak past            │
│  ○ Just walk in directly                       │
│                                                  │
│  [Sensors: 👁️ Drones detected]                 │
└──────────────────────────────────────────────────┘
```

### Pre-Generation Strategy

**MVP Approach:** Pre-generate all mission locations during development

```bash
# tools/generate_mission_images.py
python tools/generate_mission_images.py --missions godot/assets/data/missions/*.json
```

**Benefits:**
- Consistent quality (can review and regenerate if needed)
- No runtime generation delay
- Smaller game package (compared to embedding SD model)
- Can be version-controlled

**Post-MVP:** Option for dynamic generation of random missions

---

## Ship Visualization

### Dynamic Ship Builder

**Concept:** Ship appearance changes based on installed systems

```gdscript
# godot/scripts/ui/ship_viewer.gd
extends Control

var ship_image: TextureRect
var current_ship_texture: Texture2D

func _ready():
    ship_image = $ShipImage
    GameState.connect("system_installed", _on_system_changed)
    GameState.connect("system_upgraded", _on_system_changed)

func _on_system_changed():
    # Request new ship image based on current configuration
    request_updated_ship_visual()

func request_updated_ship_visual():
    var systems_summary = GameState.ship.systems

    # Show loading indicator
    show_loading()

    # Request generation
    var result = await ImageService.request_ship_image(
        GameState.ship.name,
        systems_summary
    )

    if result.has("image_path"):
        var texture = ImageService.load_generated_image(result.image_path)
        ship_image.texture = texture
        current_ship_texture = texture

    hide_loading()
```

### Ship Gallery

**Feature:** View your ship's evolution over time

```
┌──────────────────────────────────────────────────┐
│  SHIP GALLERY - U.S.S. ENDEAVOUR                 │
├──────────────────────────────────────────────────┤
│                                                  │
│  Day 1: First Frame      Day 15: Basic Systems  │
│  ┌──────────┐            ┌──────────┐          │
│  │  [Image] │            │  [Image] │          │
│  │  Level 1 │            │  Level 2 │          │
│  └──────────┘            └──────────┘          │
│                                                  │
│  Day 30: Spaceworthy     Day 42: Launch Ready   │
│  ┌──────────┐            ┌──────────┐          │
│  │  [Image] │            │  [Image] │          │
│  │  Level 5 │            │  Level 10│          │
│  └──────────┘            └──────────┘          │
│                                                  │
│  Current Configuration:                         │
│  All systems operational, ready for deep space  │
│                                                  │
│  [Export Image] [Share] [Set as Profile]       │
└──────────────────────────────────────────────────┘
```

---

## Character Portraits

### Crew/NPC System Integration

```json
{
  "character_id": "marcus_salvager",
  "name": "Marcus Reed",
  "species": "human",
  "role": "rival_scavenger",
  "description": "Weathered face, cybernetic eye, short gray hair, mechanic jumpsuit",
  "personality": "gruff, competitive, secretly helpful",
  "portrait_generated": true,
  "portrait_path": "generated/characters/marcus_reed.png",
  "first_appearance": "mission_005_the_rival",
  "relationship_level": 0
}
```

### Portrait Display

```gdscript
# godot/scripts/ui/dialogue_box.gd
extends Control

var character_portrait: TextureRect
var character_name_label: Label
var dialogue_text: RichTextLabel

func display_dialogue(character_id: String, text: String):
    var character = load_character_data(character_id)

    # Load portrait
    if character.has("portrait_path"):
        var portrait = ImageService.load_generated_image(character.portrait_path)
        character_portrait.texture = portrait

    character_name_label.text = character.name
    dialogue_text.text = text

    # Animate appearance
    animate_in()
```

---

## Space Phenomena

### Dynamic Backgrounds

**During Space Travel:**

```gdscript
# godot/scripts/ui/space_background.gd
extends Control

var current_phenomenon: String = ""
var background_image: TextureRect

func set_location(system_id: String):
    var system = GalaxyMap.get_system(system_id)

    # Check for special phenomena
    if system.has("phenomena") and len(system.phenomena) > 0:
        var phenomenon = system.phenomena[0]
        load_phenomenon_background(phenomenon)
    else:
        load_default_starfield(system.star_type)

func load_phenomenon_background(phenomenon: Dictionary):
    var image_path = phenomenon.get("image_path", "")

    if image_path == "":
        # Generate on-demand
        var result = await ImageService.request_phenomenon(
            phenomenon.type,
            phenomenon.description
        )
        image_path = result.image_path
        phenomenon.image_path = image_path

    var texture = ImageService.load_generated_image(image_path)
    background_image.texture = texture
    current_phenomenon = phenomenon.type
```

---

## UI Enhancement

### Loading Screens

**Generate loading screen art during development:**

```
┌──────────────────────────────────────────────────┐
│                                                  │
│  [Beautiful Space Scene - AI Generated]         │
│                                                  │
│  "Exploring the unknown..."                     │
│                                                  │
│  ████████████░░░░░░░░░░ 65%                     │
│                                                  │
└──────────────────────────────────────────────────┘
```

### Mission Briefing Cards

**Visual mission summaries:**

```
┌─────────────────────────┐
│ [Mission Location Art]  │
│                         │
│ SALVAGE RUN             │
│ Kennedy Spaceport       │
│ Difficulty: ★★☆☆☆      │
│                         │
│ Reward: Warp Coil       │
│ Time: ~15 minutes       │
│                         │
│ [Accept]     [Details]  │
└─────────────────────────┘
```

---

## Implementation Plan

### Week 1 (Foundation)
- [x] Set up project structure
- [ ] Install Stable Diffusion dependencies
- [ ] Create image generation service skeleton
- [ ] Test basic image generation

### Week 2 (Core Generation)
- [ ] Implement location image generation
- [ ] Create prompt templates
- [ ] Generate test images for quality
- [ ] Set up image caching system

### Week 3 (Integration)
- [ ] Integrate images into mission UI
- [ ] Create loading indicators
- [ ] Test image loading in Godot
- [ ] Generate initial mission images (10)

### Week 4 (Character & Ship)
- [ ] Implement character portrait generation
- [ ] Implement ship visualization
- [ ] Generate crew/NPC portraits
- [ ] Create ship evolution gallery

### Week 5 (Galaxy & Phenomena)
- [ ] Implement galaxy map visuals
- [ ] Generate space phenomena
- [ ] Create star system backgrounds
- [ ] Polish all visual integration

### Week 6 (Polish)
- [ ] Generate all remaining images
- [ ] Optimize loading and caching
- [ ] Create loading screens
- [ ] Final visual polish

---

## Performance Optimization

### Image Sizes

```python
SIZES = {
    "location": (768, 512),      # 16:9 widescreen
    "portrait": (512, 512),      # Square for UI
    "ship": (768, 768),          # Larger for detail
    "phenomenon": (1024, 576),   # Cinematic ratio
    "thumbnail": (256, 256),     # For lists/cards
}
```

### Compression

```python
def optimize_image(image: Image.Image, quality: int = 85) -> Image.Image:
    """Optimize image for game use"""
    # Convert to RGB (remove alpha if not needed)
    if image.mode == 'RGBA':
        background = Image.new('RGB', image.size, (0, 0, 0))
        background.paste(image, mask=image.split()[3])
        image = background

    # Compress
    output = BytesIO()
    image.save(output, format='PNG', optimize=True, quality=quality)
    return Image.open(output)
```

### Lazy Loading

```gdscript
func lazy_load_image(image_path: String) -> void:
    # Load in background thread
    var loader = ResourceLoader.load_threaded_request(image_path)

    # Show placeholder while loading
    show_placeholder()

    # Wait for load
    while ResourceLoader.load_threaded_get_status(image_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
        await get_tree().process_frame

    # Apply loaded image
    var texture = ResourceLoader.load_threaded_get(image_path)
    apply_texture(texture)
```

---

## Quality Control

### Image Review Process

1. **Generate batch of images**
2. **Review for quality and consistency**
3. **Regenerate poor quality images with adjusted prompts**
4. **Approve and commit to repository**

### Consistency Checklist

- [ ] Style matches retro sci-fi aesthetic
- [ ] Color palette is consistent (blues, cyans, oranges)
- [ ] No modern CGI look
- [ ] Appropriate mood for difficulty/type
- [ ] No text or watermarks
- [ ] Correct aspect ratio
- [ ] Proper resolution

---

**Document Status:** Complete v1.0
**Last Updated:** November 5, 2025
