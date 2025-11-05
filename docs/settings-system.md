# Space Adventures - Settings & Configuration System

**Version:** 1.0
**Date:** November 5, 2025
**Purpose:** Complete settings architecture with multi-provider AI configuration

---

## Table of Contents
1. [Overview](#overview)
2. [Settings Categories](#settings-categories)
3. [Settings UI Design](#settings-ui-design)
4. [Settings Storage](#settings-storage)
5. [API Provider Configuration](#api-provider-configuration)
6. [Visual Style Presets](#visual-style-presets)
7. [Performance Settings](#performance-settings)
8. [Settings Implementation](#settings-implementation)

---

## Overview

### Design Philosophy

**Global Settings:**
- Stored globally (affect all save files)
- Accessible from main menu and in-game
- Changes apply immediately without restart
- Settings persist across game sessions

**Core Principles:**
- **Simple by default** - Presets for quick setup
- **Powerful when needed** - Advanced options for power users
- **Validate immediately** - Test API keys before saving
- **Cost-aware** - Show estimated costs for API providers

---

## Settings Categories

### **5 Main Tabs:**

```
┌──────────────────────────────────────────────────────────┐
│ [General] [AI Providers] [Visuals] [Performance] [Advanced] │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  Tab content...                                          │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

### 1. General Settings

```
┌──────────────────────────────────────────────────────────┐
│ GENERAL SETTINGS                                         │
├──────────────────────────────────────────────────────────┤
│                                                           │
│ Game Settings                                            │
│ ─────────────                                            │
│ □ Auto-save enabled                                      │
│   Auto-save interval: [5 minutes ▼]                     │
│                                                           │
│ □ Tutorial hints enabled                                 │
│ □ Show damage numbers                                    │
│ □ Confirm dangerous actions                              │
│                                                           │
│ Accessibility                                            │
│ ─────────────                                            │
│ Text size: [Medium ▼]                                    │
│ Colorblind mode: [None ▼]                                │
│ □ High contrast UI                                       │
│                                                           │
│ Language                                                 │
│ ─────────────                                            │
│ Interface language: [English ▼]                          │
│                                                           │
│ [Save Changes] [Reset to Defaults]                       │
└──────────────────────────────────────────────────────────┘
```

### 2. AI Providers Tab

**Multi-Provider Configuration:**

```
┌──────────────────────────────────────────────────────────┐
│ AI PROVIDERS                                             │
├──────────────────────────────────────────────────────────┤
│                                                           │
│ Quick Setup Presets:                                     │
│ ○ Quality (Best AI, Higher Cost)                        │
│ ○ Balanced (Good AI, Moderate Cost) [RECOMMENDED]       │
│ ○ Free (Local AI Only, No Cost)                         │
│ ● Custom (Configure Manually)                           │
│                                                           │
│ ═══════════════════════════════════════════════════════  │
│                                                           │
│ Provider Configuration                                   │
│                                                           │
│ ┌─ STORY & NARRATIVE ──────────────────────────────┐    │
│ │ Provider: [Claude (Anthropic) ▼]                  │    │
│ │ Model: [claude-3-5-sonnet-20241022 ▼]           │    │
│ │ API Key: [sk-ant-****************************]   │    │
│ │ [Test Connection]  Status: ✓ Connected           │    │
│ │                                                   │    │
│ │ Used for: Main story missions, critical          │    │
│ │ narrative, ethical dilemmas, major choices       │    │
│ │                                                   │    │
│ │ Estimated cost: ~$0.05-0.15 per mission          │    │
│ └───────────────────────────────────────────────────┘    │
│                                                           │
│ ┌─ QUICK TASKS & DOCUMENTATION ─────────────────────┐    │
│ │ Provider: [Ollama (Local) ▼]                      │    │
│ │ Model: [llama3.2:3b ▼]                           │    │
│ │ Endpoint: [http://localhost:11434]               │    │
│ │ [Test Connection]  Status: ✓ Connected           │    │
│ │                                                   │    │
│ │ Used for: Ship documentation, UI text,           │    │
│ │ item descriptions, quick dialogue                │    │
│ │                                                   │    │
│ │ Cost: FREE (runs locally)                        │    │
│ └───────────────────────────────────────────────────┘    │
│                                                           │
│ ┌─ RANDOM CONTENT ──────────────────────────────────┐    │
│ │ Provider: [OpenAI (ChatGPT) ▼]                    │    │
│ │ Model: [gpt-3.5-turbo ▼]                         │    │
│ │ API Key: [sk-****************************]       │    │
│ │ [Test Connection]  Status: ✓ Connected           │    │
│ │                                                   │    │
│ │ Used for: Random encounters, minor missions,     │    │
│ │ NPC dialogue, exploration events                 │    │
│ │                                                   │    │
│ │ Estimated cost: ~$0.01-0.03 per generation       │    │
│ └───────────────────────────────────────────────────┘    │
│                                                           │
│ ┌─ IMAGE GENERATION ────────────────────────────────┐    │
│ │ Provider: [Stable Diffusion (Local) ▼]           │    │
│ │ Model: [SDXL 1.0 ▼]                              │    │
│ │ GPU: CUDA (NVIDIA RTX 3080)                      │    │
│ │ [Test Generation]  Status: ✓ Ready              │    │
│ │                                                   │    │
│ │ □ Enable image generation                        │    │
│ │ Quality: [High ▼]  Speed: ~8 seconds/image      │    │
│ │                                                   │    │
│ │ Cost: FREE (runs locally)                        │    │
│ └───────────────────────────────────────────────────┘    │
│                                                           │
│ [Save Configuration]  [Import]  [Export]                 │
└──────────────────────────────────────────────────────────┘
```

**Supported Providers:**
1. **Claude (Anthropic)** - Best for story, ethics, complex narrative
2. **OpenAI GPT-4** - High-quality alternative for story
3. **OpenAI GPT-3.5-turbo** - Fast, cheap, good for random content
4. **Google Gemini** - Alternative fast provider
5. **Ollama (Local)** - Free, private, good for simple tasks
6. **Stable Diffusion** - Image generation

### 3. Visuals Tab

```
┌──────────────────────────────────────────────────────────┐
│ VISUAL SETTINGS                                          │
├──────────────────────────────────────────────────────────┤
│                                                           │
│ Visual Style Preset                                      │
│ ──────────────────                                       │
│ ○ Retro Pixel Art (16-bit style, nostalgic)             │
│ ● Modern Illustrated (painted, artistic) [DEFAULT]       │
│ ○ Photorealistic (detailed, cinematic)                  │
│ ○ ASCII Art Only (pure text, no images)                 │
│                                                           │
│ ┌───────────────────────────────────────────────────┐   │
│ │ Preview:                                          │   │
│ │ [Shows example mission location image]           │   │
│ │                                                   │   │
│ │ "A painted illustration of an abandoned          │   │
│ │  spaceport with dramatic lighting and            │   │
│ │  a sense of melancholic beauty."                 │   │
│ └───────────────────────────────────────────────────┘   │
│                                                           │
│ Custom Style (Advanced)                                  │
│ ───────────────────                                      │
│ □ Use custom style prompt                                │
│ Base prompt: [retro sci-fi, detailed, serious tone...]  │
│ Negative prompt: [blurry, low quality, modern CGI...]   │
│                                                           │
│ Image Settings                                           │
│ ──────────────                                           │
│ □ Generate images for missions                           │
│ □ Generate character portraits                           │
│ □ Generate ship exteriors                                │
│ □ Generate space phenomena                               │
│                                                           │
│ Image Quality: [High ▼]                                  │
│ Resolution: [768x512 (recommended) ▼]                    │
│                                                           │
│ Cache Management                                         │
│ ───────────────                                          │
│ Generated images cached: 142 (1.2 GB)                    │
│ [Clear Image Cache]  [Pre-Generate All]                 │
│                                                           │
│ [Save Settings]  [Reset to Defaults]                     │
└──────────────────────────────────────────────────────────┘
```

### 4. Performance Tab

```
┌──────────────────────────────────────────────────────────┐
│ PERFORMANCE SETTINGS                                     │
├──────────────────────────────────────────────────────────┤
│                                                           │
│ AI Generation Performance                                │
│ ─────────────────────────                                │
│ Quality preset: [Balanced ▼]                             │
│ - Low: Fast, lower quality (2-5 seconds)                │
│ - Balanced: Good quality (5-10 seconds)                 │
│ - High: Best quality (10-30 seconds)                    │
│                                                           │
│ Concurrent AI Tasks                                      │
│ ──────────────────                                       │
│ Max parallel tasks: [2 ▼] (1-4)                         │
│ □ Auto-prioritize gameplay tasks                         │
│ □ Background processing when idle                        │
│                                                           │
│ Task Queue Settings                                      │
│ ──────────────────                                       │
│ □ Show AI task notifications                             │
│ □ Cancel tasks on scene change                           │
│ Task timeout: [60 seconds ▼]                             │
│                                                           │
│ Cache Settings                                           │
│ ──────────────                                           │
│ Response cache TTL: [24 hours ▼]                         │
│ Max cache size: [500 MB ▼]                               │
│ □ Aggressive caching (reuse more responses)              │
│                                                           │
│ Current Performance                                      │
│ ──────────────────                                       │
│ Average generation time: 7.2 seconds                     │
│ Cache hit rate: 68%                                      │
│ Active tasks: 1 / 2                                      │
│                                                           │
│ [Clear All Caches]  [Reset Performance Stats]            │
└──────────────────────────────────────────────────────────┘
```

### 5. Advanced Tab

```
┌──────────────────────────────────────────────────────────┐
│ ADVANCED SETTINGS                                        │
├──────────────────────────────────────────────────────────┤
│                                                           │
│ ⚠️  WARNING: Advanced users only                         │
│                                                           │
│ Ship Documentation                                       │
│ ──────────────────                                       │
│ □ Auto-update ship manual                                │
│ Update trigger: [On system install ▼]                   │
│ Documentation detail: [Full depth ▼]                     │
│ Include: ☑ Specs  ☑ Procedures  ☑ Safety  ☑ Lore        │
│                                                           │
│ AI Behavior                                              │
│ ─────────────                                            │
│ Temperature: [0.8] (0.0 = deterministic, 1.0 = creative)│
│ Max tokens: [1500 ▼]                                     │
│ Top P: [0.9]                                             │
│                                                           │
│ Debug & Development                                      │
│ ─────────────────────                                    │
│ □ Debug mode (show prompts and responses)                │
│ □ Log all AI interactions                                │
│ □ Measure generation performance                         │
│                                                           │
│ API Usage Tracking                                       │
│ ─────────────────                                        │
│ This session:                                            │
│ - Story AI (Claude): 12 requests, ~$0.84                │
│ - Quick AI (Ollama): 47 requests, FREE                  │
│ - Images (SD Local): 23 generated, FREE                 │
│                                                           │
│ Total this month: $12.40                                 │
│ [View Detailed Usage]  [Export Report]                   │
│                                                           │
│ Reset & Import/Export                                    │
│ ────────────────────                                     │
│ [Reset All Settings]                                     │
│ [Export Settings JSON]  [Import Settings]                │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

---

## Settings Storage

### Settings File Format

**Location:** `user://settings.json` (Godot user directory)

```json
{
  "version": "1.0.0",
  "last_updated": "2025-11-05T14:32:15Z",

  "general": {
    "auto_save_enabled": true,
    "auto_save_interval_minutes": 5,
    "tutorial_hints": true,
    "show_damage_numbers": true,
    "confirm_dangerous_actions": true,
    "text_size": "medium",
    "colorblind_mode": "none",
    "high_contrast": false,
    "language": "en"
  },

  "ai_providers": {
    "story_provider": {
      "type": "claude",
      "model": "claude-3-5-sonnet-20241022",
      "api_key_encrypted": "encrypted_key_here",
      "endpoint": "https://api.anthropic.com/v1",
      "enabled": true,
      "uses": ["story_missions", "critical_narrative", "ethical_dilemmas"]
    },
    "quick_provider": {
      "type": "ollama",
      "model": "llama3.2:3b",
      "endpoint": "http://localhost:11434",
      "enabled": true,
      "uses": ["ship_docs", "ui_text", "item_descriptions"]
    },
    "random_provider": {
      "type": "openai",
      "model": "gpt-3.5-turbo",
      "api_key_encrypted": "encrypted_key_here",
      "enabled": true,
      "uses": ["random_encounters", "minor_missions", "npc_dialogue"]
    },
    "image_provider": {
      "type": "stable_diffusion",
      "model": "sdxl_1.0",
      "device": "cuda",
      "enabled": true
    }
  },

  "visuals": {
    "style_preset": "modern_illustrated",
    "custom_style_enabled": false,
    "custom_base_prompt": "",
    "custom_negative_prompt": "",
    "generate_mission_images": true,
    "generate_character_portraits": true,
    "generate_ship_exteriors": true,
    "generate_phenomena": true,
    "image_quality": "high",
    "image_resolution": "768x512"
  },

  "performance": {
    "quality_preset": "balanced",
    "max_parallel_tasks": 2,
    "auto_prioritize_gameplay": true,
    "background_processing": true,
    "show_task_notifications": false,
    "cancel_tasks_on_scene_change": false,
    "task_timeout_seconds": 60,
    "cache_ttl_hours": 24,
    "max_cache_size_mb": 500,
    "aggressive_caching": false
  },

  "advanced": {
    "auto_update_ship_manual": true,
    "manual_update_trigger": "on_system_install",
    "documentation_detail": "full",
    "include_specs": true,
    "include_procedures": true,
    "include_safety": true,
    "include_lore": true,
    "temperature": 0.8,
    "max_tokens": 1500,
    "top_p": 0.9,
    "debug_mode": false,
    "log_ai_interactions": false,
    "measure_performance": true
  },

  "usage_tracking": {
    "track_usage": true,
    "session_stats": {},
    "monthly_stats": {}
  }
}
```

---

## API Provider Configuration

### Provider Definitions

```python
# python/src/models/ai_providers.py

from enum import Enum
from pydantic import BaseModel
from typing import List, Optional

class ProviderType(str, Enum):
    CLAUDE = "claude"
    OPENAI = "openai"
    GEMINI = "gemini"
    OLLAMA = "ollama"
    STABLE_DIFFUSION = "stable_diffusion"

class AITaskType(str, Enum):
    STORY_MISSION = "story_missions"
    CRITICAL_NARRATIVE = "critical_narrative"
    ETHICAL_DILEMMA = "ethical_dilemmas"
    RANDOM_ENCOUNTER = "random_encounters"
    MINOR_MISSION = "minor_missions"
    NPC_DIALOGUE = "npc_dialogue"
    SHIP_DOCUMENTATION = "ship_docs"
    UI_TEXT = "ui_text"
    ITEM_DESCRIPTION = "item_descriptions"
    IMAGE_GENERATION = "image_generation"

class AIProvider(BaseModel):
    type: ProviderType
    model: str
    api_key: Optional[str] = None
    endpoint: str
    enabled: bool = True
    uses: List[AITaskType] = []

    # Performance settings
    temperature: float = 0.8
    max_tokens: int = 1500
    top_p: float = 0.9

    # Cost tracking
    cost_per_1k_tokens: float = 0.0
    estimated_tokens_per_request: int = 1000

# Provider routing map
PROVIDER_ROUTING = {
    AITaskType.STORY_MISSION: "story_provider",
    AITaskType.CRITICAL_NARRATIVE: "story_provider",
    AITaskType.ETHICAL_DILEMMA: "story_provider",
    AITaskType.RANDOM_ENCOUNTER: "random_provider",
    AITaskType.MINOR_MISSION: "random_provider",
    AITaskType.NPC_DIALOGUE: "random_provider",
    AITaskType.SHIP_DOCUMENTATION: "quick_provider",
    AITaskType.UI_TEXT: "quick_provider",
    AITaskType.ITEM_DESCRIPTION: "quick_provider",
    AITaskType.IMAGE_GENERATION: "image_provider",
}
```

### Provider Clients

```python
# python/src/ai/multi_provider.py

from anthropic import AsyncAnthropic
from openai import AsyncOpenAI
import google.generativeai as genai
from typing import Dict, Any

class MultiProviderAIClient:
    def __init__(self, settings: Dict[str, Any]):
        self.settings = settings
        self.clients = {}
        self._initialize_clients()

    def _initialize_clients(self):
        """Initialize all enabled providers"""
        providers = self.settings.get("ai_providers", {})

        # Claude
        if providers.get("story_provider", {}).get("type") == "claude":
            story = providers["story_provider"]
            self.clients["claude"] = AsyncAnthropic(
                api_key=self._decrypt_key(story["api_key_encrypted"])
            )

        # OpenAI
        if providers.get("random_provider", {}).get("type") == "openai":
            random = providers["random_provider"]
            self.clients["openai"] = AsyncOpenAI(
                api_key=self._decrypt_key(random["api_key_encrypted"])
            )

        # Gemini
        if "gemini_provider" in providers:
            gemini = providers["gemini_provider"]
            genai.configure(api_key=self._decrypt_key(gemini["api_key_encrypted"]))
            self.clients["gemini"] = genai.GenerativeModel(gemini["model"])

        # Ollama
        if providers.get("quick_provider", {}).get("type") == "ollama":
            quick = providers["quick_provider"]
            self.clients["ollama"] = AsyncOpenAI(
                base_url=quick["endpoint"],
                api_key="ollama"  # Ollama doesn't need real key
            )

    async def generate(
        self,
        task_type: AITaskType,
        prompt: str,
        **kwargs
    ) -> str:
        """Route request to appropriate provider"""

        provider_key = PROVIDER_ROUTING.get(task_type, "quick_provider")
        provider_config = self.settings["ai_providers"].get(provider_key)

        if not provider_config or not provider_config.get("enabled"):
            raise ValueError(f"No provider configured for {task_type}")

        provider_type = provider_config["type"]

        if provider_type == "claude":
            return await self._generate_claude(prompt, provider_config, **kwargs)
        elif provider_type == "openai":
            return await self._generate_openai(prompt, provider_config, **kwargs)
        elif provider_type == "gemini":
            return await self._generate_gemini(prompt, provider_config, **kwargs)
        elif provider_type == "ollama":
            return await self._generate_ollama(prompt, provider_config, **kwargs)
        else:
            raise ValueError(f"Unknown provider type: {provider_type}")

    async def _generate_claude(self, prompt: str, config: dict, **kwargs) -> str:
        """Generate using Claude"""
        client = self.clients["claude"]

        response = await client.messages.create(
            model=config["model"],
            max_tokens=config.get("max_tokens", 1500),
            temperature=config.get("temperature", 0.8),
            messages=[{"role": "user", "content": prompt}]
        )

        return response.content[0].text

    async def _generate_openai(self, prompt: str, config: dict, **kwargs) -> str:
        """Generate using OpenAI"""
        client = self.clients["openai"]

        response = await client.chat.completions.create(
            model=config["model"],
            messages=[{"role": "user", "content": prompt}],
            temperature=config.get("temperature", 0.8),
            max_tokens=config.get("max_tokens", 1500)
        )

        return response.choices[0].message.content

    async def _generate_gemini(self, prompt: str, config: dict, **kwargs) -> str:
        """Generate using Gemini"""
        model = self.clients["gemini"]

        response = await model.generate_content_async(
            prompt,
            generation_config=genai.types.GenerationConfig(
                temperature=config.get("temperature", 0.8),
                max_output_tokens=config.get("max_tokens", 1500)
            )
        )

        return response.text

    async def _generate_ollama(self, prompt: str, config: dict, **kwargs) -> str:
        """Generate using Ollama (OpenAI-compatible)"""
        client = self.clients["ollama"]

        response = await client.chat.completions.create(
            model=config["model"],
            messages=[{"role": "user", "content": prompt}],
            temperature=config.get("temperature", 0.8),
            max_tokens=config.get("max_tokens", 1500)
        )

        return response.choices[0].message.content

    def _decrypt_key(self, encrypted_key: str) -> str:
        """Decrypt API key (implement proper encryption)"""
        # TODO: Implement actual encryption/decryption
        return encrypted_key
```

---

## Visual Style Presets

### Preset Definitions

```python
# python/src/ai/visual_styles.py

VISUAL_STYLE_PRESETS = {
    "retro_pixel_art": {
        "name": "Retro Pixel Art",
        "description": "16-bit style, nostalgic, crisp pixels",
        "base_prompt": "retro pixel art, 16-bit style, isometric, detailed sprite work, limited color palette, crisp pixels, Star Trek TNG inspired, serious sci-fi",
        "negative_prompt": "blurry, 3D render, modern, photorealistic, gradient, smooth, anti-aliased",
        "recommended_resolution": "512x512",
        "inference_steps": 40
    },
    "modern_illustrated": {
        "name": "Modern Illustrated",
        "description": "Painted, artistic, dramatic lighting",
        "base_prompt": "digital painting, illustrated, concept art style, dramatic lighting, detailed environment, cinematic composition, matte painting, Star Trek aesthetic, serious sci-fi",
        "negative_prompt": "photograph, photorealistic, blurry, low quality, ugly, deformed, modern CGI, lens flare",
        "recommended_resolution": "768x512",
        "inference_steps": 50
    },
    "photorealistic": {
        "name": "Photorealistic",
        "description": "Detailed, cinematic, realistic",
        "base_prompt": "photorealistic, detailed, cinematic lighting, professional photography, 4K quality, realistic materials, depth of field, Star Trek style, serious sci-fi",
        "negative_prompt": "cartoon, anime, illustration, painting, sketch, low quality, blurry, deformed",
        "recommended_resolution": "1024x576",
        "inference_steps": 60
    },
    "ascii_only": {
        "name": "ASCII Art Only",
        "description": "Pure text, no images generated",
        "base_prompt": None,  # Disables image generation
        "negative_prompt": None,
        "recommended_resolution": None,
        "inference_steps": 0
    }
}
```

---

## Settings Implementation

### GDScript Settings Manager

```gdscript
# godot/scripts/autoload/settings_manager.gd
extends Node

const SETTINGS_PATH = "user://settings.json"

signal settings_changed(category: String)
signal provider_status_changed(provider: String, status: bool)

var settings: Dictionary = {}
var default_settings: Dictionary = {}

func _ready():
    load_default_settings()
    load_settings()

func load_default_settings():
    """Initialize default settings"""
    default_settings = {
        "version": "1.0.0",
        "general": {
            "auto_save_enabled": true,
            "auto_save_interval_minutes": 5,
            "tutorial_hints": true,
            "show_damage_numbers": true,
            "text_size": "medium",
            "language": "en"
        },
        "ai_providers": {
            "story_provider": {
                "type": "claude",
                "model": "claude-3-5-sonnet-20241022",
                "enabled": false
            },
            "quick_provider": {
                "type": "ollama",
                "model": "llama3.2:3b",
                "endpoint": "http://localhost:11434",
                "enabled": true
            }
        },
        "visuals": {
            "style_preset": "modern_illustrated",
            "generate_mission_images": true,
            "image_quality": "high"
        },
        "performance": {
            "quality_preset": "balanced",
            "max_parallel_tasks": 2,
            "auto_prioritize_gameplay": true
        }
    }

func load_settings():
    """Load settings from file or use defaults"""
    if not FileAccess.file_exists(SETTINGS_PATH):
        settings = default_settings.duplicate(true)
        save_settings()
        return

    var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
    if file:
        var json = JSON.new()
        var parse_result = json.parse(file.get_as_text())
        if parse_result == OK:
            settings = json.data
        file.close()

func save_settings():
    """Save settings to file"""
    var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
    if file:
        settings.last_updated = Time.get_datetime_string_from_system()
        var json_string = JSON.stringify(settings, "\t")
        file.store_string(json_string)
        file.close()

func get_setting(path: String, default = null):
    """Get setting value by dot notation path"""
    var keys = path.split(".")
    var current = settings

    for key in keys:
        if current.has(key):
            current = current[key]
        else:
            return default

    return current

func set_setting(path: String, value):
    """Set setting value by dot notation path"""
    var keys = path.split(".")
    var current = settings

    for i in range(keys.size() - 1):
        var key = keys[i]
        if not current.has(key):
            current[key] = {}
        current = current[key]

    current[keys[-1]] = value
    save_settings()

    # Emit signal for category
    var category = keys[0]
    emit_signal("settings_changed", category)

func reset_to_defaults():
    """Reset all settings to defaults"""
    settings = default_settings.duplicate(true)
    save_settings()
    emit_signal("settings_changed", "all")

func export_settings() -> String:
    """Export settings as JSON string"""
    return JSON.stringify(settings, "\t")

func import_settings(json_string: String) -> bool:
    """Import settings from JSON string"""
    var json = JSON.new()
    var parse_result = json.parse(json_string)

    if parse_result == OK:
        settings = json.data
        save_settings()
        emit_signal("settings_changed", "all")
        return true

    return false

async func test_provider(provider_key: String) -> Dictionary:
    """Test AI provider connection"""
    var provider = get_setting("ai_providers." + provider_key, {})

    if provider.is_empty():
        return {"success": false, "error": "Provider not configured"}

    # Send test request to Python service
    var result = await AIService.test_provider_connection(provider)

    emit_signal("provider_status_changed", provider_key, result.success)
    return result
```

---

## Ship Documentation System

### Overview

The ship documentation system automatically generates and maintains comprehensive technical manuals for all installed ship systems. As players build and upgrade their ship, AI-powered documentation is created in the background, providing immersive in-universe reference material.

**Key Features:**
- **Auto-updating manuals** - Documentation regenerates when systems are installed/upgraded
- **Multi-process generation** - Multiple AI tasks run concurrently without blocking gameplay
- **Full depth content** - Technical specs, procedures, safety protocols, troubleshooting, and lore
- **Export capabilities** - PDF, Markdown, and JSON export for sharing

### Settings Configuration

**Location:** Advanced Tab > Ship Documentation

```
Ship Documentation
──────────────────
□ Auto-update ship manual
Update trigger: [On system install ▼]
Documentation detail: [Full depth ▼]
Include: ☑ Specs  ☑ Procedures  ☑ Safety  ☑ Lore
```

**Update Triggers:**
- **On system install** - Generate full documentation immediately (NORMAL priority)
- **On system upgrade** - Update specs and capabilities (NORMAL priority)
- **On damage** - Update troubleshooting section (LOW priority)
- **Milestone** - Generate ship overview and mission logs (HIGH priority)
- **Manual request** - User opens manual (HIGH priority)
- **Idle background** - Pre-generate when game idle (LOW priority)

**Documentation Detail Levels:**
- **Quick** - Essential info only (specs + capabilities)
- **Standard** - Includes procedures and troubleshooting
- **Full depth** - Everything including lore, history, and flavor text

### Content Sections

Each system documentation includes:

1. **System Overview** - What the system does, its importance
2. **Technical Specifications** - Level, power, mass, performance metrics
3. **Capabilities** - Current abilities and next level preview
4. **Operating Procedures** - Startup, operation, shutdown sequences
5. **Maintenance & Troubleshooting** - Common issues and solutions
6. **Lore & Background** - In-universe history and flavor
7. **Upgrade History** - Timeline of installations and upgrades

### Multi-Process Generation

**Concurrent Processing:**
- Up to 4 AI tasks can run simultaneously (configurable)
- Tasks are prioritized: CRITICAL > HIGH > NORMAL > LOW
- Gameplay tasks always take priority over documentation
- Background generation occurs during idle periods

**Task Queue:**
```python
# Example: Installing a Level 1 Warp Drive triggers 5 concurrent tasks
tasks = [
    AITask(type="doc_overview", priority=NORMAL),
    AITask(type="doc_capabilities", priority=NORMAL),
    AITask(type="doc_procedures", priority=LOW),
    AITask(type="doc_lore", priority=LOW),
    AITask(type="doc_troubleshooting", priority=LOW)
]
# All 5 tasks submitted to queue, processed in parallel
```

**Performance Impact:**
- Documentation generation is fully asynchronous
- Never blocks gameplay or player actions
- Results available when player opens ship manual
- Progress notifications (optional, can be disabled)

### For Complete Documentation Details

See **[docs/ship-documentation.md](ship-documentation.md)** for:
- Complete ship manual structure and format
- AI prompt templates for each content type
- Task queue architecture and implementation
- Update triggers and versioning system
- Example manual entries (Warp Drive, Computer Core)
- Export functionality (PDF, Markdown, JSON)
- Full Python and GDScript implementation code

---

## Summary

The Space Adventures settings system provides:

**✓ Multi-Provider AI Configuration**
- Route different tasks to optimal AI providers
- Claude for story, Ollama for docs, GPT-3.5 for random content
- Cost tracking and usage monitoring

**✓ Visual Style Customization**
- 4 presets: Retro Pixel Art, Modern Illustrated, Photorealistic, ASCII Only
- Custom style prompts for advanced users
- Per-image-type toggles

**✓ Performance Optimization**
- Configurable concurrent AI tasks (1-4)
- Quality presets (Low, Balanced, High)
- Aggressive caching options
- Task prioritization

**✓ AI-Generated Ship Documentation**
- Auto-updating technical manuals
- Multi-process concurrent generation
- Full depth or quick modes
- Export to PDF/Markdown

**✓ Developer-Friendly**
- Settings stored as JSON (easy to backup/share)
- API key encryption
- Debug mode for prompt inspection
- Comprehensive usage tracking

---

**Document Status:** Complete
**Related Documents:**
- [ship-documentation.md](ship-documentation.md) - Detailed ship manual system
- [technical-architecture.md](technical-architecture.md) - Implementation architecture
- [ai-integration.md](ai-integration.md) - AI prompt templates

**Last Updated:** November 5, 2025
