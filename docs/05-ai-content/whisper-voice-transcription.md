# Space Adventures - Whisper AI Voice Transcription System

**Version:** 1.0
**Date:** November 5, 2025
**Purpose:** Voice-to-text transcription using OpenAI Whisper for hands-free AI chat interaction

---

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Whisper Service Setup](#whisper-service-setup)
4. [API Design](#api-design)
5. [Settings Integration](#settings-integration)
6. [Godot Voice Input](#godot-voice-input)
7. [Audio Processing Pipeline](#audio-processing-pipeline)
8. [Database Schema](#database-schema)
9. [Implementation Plan](#implementation-plan)
10. [Performance Optimization](#performance-optimization)
11. [Error Handling](#error-handling)

---

## Overview

### What is Whisper?

**OpenAI Whisper** is a state-of-the-art automatic speech recognition (ASR) model that:
- Runs entirely locally (no API costs, complete privacy)
- Supports multiple languages
- Handles background noise well
- Works with various audio qualities
- Provides accurate transcription in real-time

### Integration Goals

Enable players to:
1. **Speak commands** instead of typing ("Plot course to Earth", "Show fuel status")
2. **Have voice conversations** with AI personalities (ATLAS, Storyteller, Guardian, Companion)
3. **Use push-to-talk** or voice activation modes
4. **Toggle voice input on/off** in settings
5. **See real-time transcription** as they speak

### Why Voice Input?

**Star Trek Immersion:**
- Speak to ship's computer like Captain Picard
- Natural, hands-free interaction
- More immersive storytelling experience
- Accessibility for players who prefer voice

**Gameplay Benefits:**
- Faster than typing during critical moments
- More natural conversation flow
- Multitask while playing (voice while managing ship)
- Accessibility for players with mobility issues

---

## Architecture

### Multi-Service Design

```
┌─────────────────────────────────────────────────────┐
│                    GODOT GAME                        │
│  ┌──────────────────────────────────────────────┐   │
│  │         Voice Input Component                │   │
│  │  ┌─────────────┐    ┌──────────────────┐    │   │
│  │  │ Microphone  │───▶│ Audio Buffer     │    │   │
│  │  │ Capture     │    │ (WAV/PCM)        │    │   │
│  │  └─────────────┘    └──────────────────┘    │   │
│  │         │                    │               │   │
│  │         ▼                    ▼               │   │
│  │  ┌─────────────────────────────────────┐    │   │
│  │  │  Push-to-Talk / Voice Activation    │    │   │
│  │  └─────────────────────────────────────┘    │   │
│  └──────────────────────────────────────────────┘   │
└───────────────────────┬─────────────────────────────┘
                        │ HTTP POST (audio file)
                        ▼
┌─────────────────────────────────────────────────────┐
│          WHISPER TRANSCRIPTION SERVICE               │
│                  (Port 8001)                         │
│  ┌──────────────────────────────────────────────┐   │
│  │  FastAPI Server                              │   │
│  │  POST /transcribe                            │   │
│  └──────────────────────────────────────────────┘   │
│                        │                             │
│                        ▼                             │
│  ┌──────────────────────────────────────────────┐   │
│  │  Whisper Model (whisper-base or whisper-small)│  │
│  │  - Audio preprocessing                       │   │
│  │  - Speech recognition                        │   │
│  │  - Text output                               │   │
│  └──────────────────────────────────────────────┘   │
│                        │                             │
└────────────────────────┼─────────────────────────────┘
                         │ JSON response (transcribed text)
                         ▼
┌─────────────────────────────────────────────────────┐
│              AI CHAT SERVICE                         │
│                 (Port 8000)                          │
│  ┌──────────────────────────────────────────────┐   │
│  │  Process transcribed message                 │   │
│  │  Route to AI personality                     │   │
│  │  Generate response                           │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### Service Ports

- **Port 8000**: Main AI service (existing)
- **Port 8001**: Whisper transcription service (NEW)
- **Port 5432**: PostgreSQL global database (existing)
- **Port 6379**: Redis cache (existing)

### Service Independence

**Whisper service runs separately:**
- Optional installation (user can skip if they don't want voice input)
- Can be stopped/started independently
- Doesn't affect main game if disabled
- Settings control whether to attempt connection

---

## Whisper Service Setup

### Installation Requirements

**System Requirements:**
- **Python 3.10+** (same as main AI service)
- **FFmpeg** (for audio processing)
- **~1-3 GB disk space** (for Whisper model)
- **GPU recommended** but not required (CPU works fine)

**Recommended Whisper Model Sizes:**

| Model | Size | Speed | Accuracy | Use Case |
|-------|------|-------|----------|----------|
| `tiny` | 75 MB | Very fast | Good | Testing only |
| `base` | 142 MB | Fast | Good | **Recommended for most users** |
| `small` | 466 MB | Medium | Better | High-quality transcription |
| `medium` | 1.5 GB | Slow | Excellent | Best quality (GPU recommended) |
| `large` | 3 GB | Very slow | Best | Overkill for game use |

**Default recommendation: `base`** - Good balance of speed and accuracy

### Python Dependencies

**whisper-requirements.txt:**
```txt
# Core Whisper
openai-whisper==20231117

# Audio processing
ffmpeg-python==0.2.0
soundfile==0.12.1
librosa==0.10.1

# Web service
fastapi==0.104.1
uvicorn[standard]==0.24.0
python-multipart==0.0.6

# Utilities
numpy==1.26.2
torch==2.1.1  # CPU version (or torch-gpu for NVIDIA)
```

### Installation Script

**install-whisper-service.sh:**
```bash
#!/bin/bash
# Space Adventures - Whisper Service Installation

echo "🎤 Installing Whisper Transcription Service..."

# Check for FFmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "⚠️  FFmpeg not found. Installing..."

    # macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install ffmpeg
    # Ubuntu/Debian
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update
        sudo apt-get install -y ffmpeg
    # Windows (via winget)
    elif [[ "$OSTYPE" == "msys" ]]; then
        winget install Gyan.FFmpeg
    fi
fi

# Create virtual environment
cd python/whisper-service
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install --upgrade pip
pip install -r whisper-requirements.txt

# Download Whisper model (base by default)
echo "📦 Downloading Whisper base model (~142 MB)..."
python -c "import whisper; whisper.load_model('base')"

echo "✅ Whisper service installed successfully!"
echo ""
echo "To start the service:"
echo "  cd python/whisper-service"
echo "  source venv/bin/activate"
echo "  python main.py"
echo ""
echo "Service will run on http://localhost:8001"
```

### Docker Setup (Alternative)

**whisper-service/Dockerfile:**
```dockerfile
FROM python:3.10-slim

# Install FFmpeg
RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements
COPY whisper-requirements.txt .
RUN pip install --no-cache-dir -r whisper-requirements.txt

# Download Whisper model at build time
RUN python -c "import whisper; whisper.load_model('base')"

# Copy service code
COPY . .

# Expose port
EXPOSE 8001

# Run service
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"]
```

**docker-compose.yml addition:**
```yaml
services:
  whisper-service:
    build: ./python/whisper-service
    ports:
      - "8001:8001"
    volumes:
      - ./python/whisper-service:/app
      - whisper-cache:/root/.cache/whisper
    environment:
      - MODEL_SIZE=base
      - LANGUAGE=en
    restart: unless-stopped
    profiles:
      - voice  # Optional service, only start with --profile voice

volumes:
  whisper-cache:
```

**Start with voice:**
```bash
docker-compose --profile voice up
```

---

## API Design

### Whisper Service Endpoints

**Base URL:** `http://localhost:8001`

#### **POST /transcribe**

Transcribe audio file to text.

**Request:**
```http
POST /transcribe
Content-Type: multipart/form-data

{
  "file": <audio_file>,  # WAV, MP3, OGG, FLAC
  "language": "en",      # Optional: auto-detect if not specified
  "task": "transcribe"   # "transcribe" or "translate" (to English)
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8001/transcribe \
  -F "file=@recording.wav" \
  -F "language=en"
```

**Response (Success):**
```json
{
  "success": true,
  "text": "Plot course to Earth and engage at warp 5",
  "language": "en",
  "duration": 3.2,
  "processing_time": 0.87,
  "confidence": 0.94,
  "segments": [
    {
      "id": 0,
      "start": 0.0,
      "end": 3.2,
      "text": "Plot course to Earth and engage at warp 5"
    }
  ]
}
```

**Response (Error):**
```json
{
  "success": false,
  "error": "No speech detected in audio",
  "error_type": "no_speech",
  "processing_time": 0.45
}
```

#### **GET /health**

Check if Whisper service is running.

**Response:**
```json
{
  "status": "healthy",
  "model": "base",
  "model_loaded": true,
  "language": "en",
  "device": "cpu",
  "version": "1.0.0"
}
```

#### **GET /models**

List available Whisper models.

**Response:**
```json
{
  "available_models": ["tiny", "base", "small", "medium", "large"],
  "current_model": "base",
  "model_info": {
    "name": "base",
    "size_mb": 142,
    "parameters": "74M",
    "multilingual": true
  }
}
```

#### **POST /change-model**

Change the loaded Whisper model (requires service restart).

**Request:**
```json
{
  "model": "small"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Model changed to 'small'. Please restart the service.",
  "requires_restart": true
}
```

### Python Implementation

**whisper-service/main.py:**
```python
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import whisper
import tempfile
import os
import time
from pathlib import Path
from typing import Optional

app = FastAPI(
    title="Space Adventures - Whisper Transcription Service",
    version="1.0.0"
)

# Allow CORS for Godot
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load Whisper model
MODEL_SIZE = os.getenv("MODEL_SIZE", "base")
print(f"Loading Whisper model: {MODEL_SIZE}")
model = whisper.load_model(MODEL_SIZE)
print(f"✅ Whisper model '{MODEL_SIZE}' loaded successfully")


@app.get("/")
async def root():
    return {
        "service": "Space Adventures Whisper Transcription",
        "version": "1.0.0",
        "status": "online"
    }


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "model": MODEL_SIZE,
        "model_loaded": model is not None,
        "language": "en",
        "device": str(model.device) if model else "unknown",
        "version": "1.0.0"
    }


@app.post("/transcribe")
async def transcribe_audio(
    file: UploadFile = File(...),
    language: Optional[str] = Form(None),
    task: str = Form("transcribe")
):
    """
    Transcribe audio file to text using Whisper

    Args:
        file: Audio file (WAV, MP3, OGG, FLAC)
        language: Language code (e.g., 'en', 'es', 'fr') or None for auto-detect
        task: 'transcribe' or 'translate' (translate to English)

    Returns:
        JSON with transcribed text and metadata
    """
    start_time = time.time()

    # Validate file
    if not file.filename:
        raise HTTPException(status_code=400, detail="No file provided")

    # Save uploaded file temporarily
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=Path(file.filename).suffix) as temp_file:
            content = await file.read()
            temp_file.write(content)
            temp_path = temp_file.name

        # Transcribe
        result = model.transcribe(
            temp_path,
            language=language,
            task=task,
            fp16=False  # CPU compatibility
        )

        # Clean up temp file
        os.unlink(temp_path)

        processing_time = time.time() - start_time

        # Extract text
        text = result["text"].strip()

        # Check if empty
        if not text:
            return JSONResponse(
                status_code=200,
                content={
                    "success": false,
                    "error": "No speech detected in audio",
                    "error_type": "no_speech",
                    "processing_time": processing_time
                }
            )

        # Build response
        return {
            "success": True,
            "text": text,
            "language": result.get("language", language or "unknown"),
            "duration": result.get("duration", 0),
            "processing_time": processing_time,
            "confidence": calculate_average_confidence(result.get("segments", [])),
            "segments": result.get("segments", [])
        }

    except Exception as e:
        if os.path.exists(temp_path):
            os.unlink(temp_path)

        return JSONResponse(
            status_code=500,
            content={
                "success": False,
                "error": str(e),
                "error_type": "transcription_error",
                "processing_time": time.time() - start_time
            }
        )


@app.get("/models")
async def list_models():
    """List available Whisper models"""
    return {
        "available_models": ["tiny", "base", "small", "medium", "large"],
        "current_model": MODEL_SIZE,
        "model_info": {
            "name": MODEL_SIZE,
            "size_mb": get_model_size(MODEL_SIZE),
            "parameters": get_model_params(MODEL_SIZE),
            "multilingual": True
        }
    }


def calculate_average_confidence(segments):
    """Calculate average confidence from segments"""
    if not segments:
        return 0.0

    # Whisper doesn't provide confidence directly, but we can estimate
    # based on probability of tokens (if available)
    # For now, return a placeholder
    return 0.95  # High confidence placeholder


def get_model_size(model_name: str) -> int:
    """Get model size in MB"""
    sizes = {
        "tiny": 75,
        "base": 142,
        "small": 466,
        "medium": 1500,
        "large": 3000
    }
    return sizes.get(model_name, 0)


def get_model_params(model_name: str) -> str:
    """Get model parameter count"""
    params = {
        "tiny": "39M",
        "base": "74M",
        "small": "244M",
        "medium": "769M",
        "large": "1550M"
    }
    return params.get(model_name, "unknown")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
```

---

## Settings Integration

### Settings UI Design

**Add to General Settings Tab (AI Chat & Conversation section):**

```
┌──────────────────────────────────────────────────────────┐
│ GENERAL SETTINGS                                         │
├──────────────────────────────────────────────────────────┤
│                                                           │
│ AI Chat & Conversation                                   │
│ ─────────────────────                                    │
│ □ Enable AI chat system                                  │
│ Chat hotkey: [C ▼]                                       │
│                                                           │
│ Voice Input                                              │
│ ────────────                                             │
│ □ Enable voice transcription (requires Whisper service) │
│ Voice hotkey: [V ▼]                                      │
│ Input mode: [Push-to-Talk ▼]                            │
│   • Push-to-Talk (hold V to record)                     │
│   • Voice Activation (auto-detect speech)               │
│   • Toggle Mode (press V to start/stop)                 │
│                                                           │
│ Whisper service:                                         │
│   URL: [http://localhost:8001]                          │
│   [Test Connection]  Status: ✓ Connected                │
│                                                           │
│ Voice Activation Settings (if enabled):                 │
│   Activation threshold: [──●────] Medium                 │
│   Silence timeout: [2 seconds ▼]                        │
│                                                           │
│ Audio Settings:                                          │
│   Microphone: [Default ▼]                               │
│   Sample rate: [16000 Hz ▼] (recommended)              │
│   □ Show waveform while recording                        │
│   □ Play beep on start/stop recording                    │
│                                                           │
│ □ Enable spontaneous AI events                           │
│ ...                                                       │
└──────────────────────────────────────────────────────────┘
```

### Settings JSON Schema

**Updated settings.json:**
```json
{
  "version": "1.0.0",
  "last_updated": "2025-11-05T14:32:15Z",

  "conversation": {
    "chat_enabled": true,
    "chat_hotkey": "C",

    "voice_enabled": true,
    "voice_hotkey": "V",
    "voice_input_mode": "push_to_talk",
    "whisper_service_url": "http://localhost:8001",
    "whisper_model": "base",
    "whisper_language": "en",

    "voice_activation": {
      "enabled": false,
      "threshold": 0.5,
      "silence_timeout_seconds": 2
    },

    "audio": {
      "microphone_device": "default",
      "sample_rate": 16000,
      "show_waveform": true,
      "play_beep": true
    },

    "spontaneous_events_enabled": true,
    "event_frequency": "moderate",
    ...
  }
}
```

### Settings Validation

**Check Whisper service on startup:**
```python
# python/src/utils/whisper_check.py

import httpx
import asyncio

async def check_whisper_service(url: str = "http://localhost:8001") -> dict:
    """
    Check if Whisper transcription service is available

    Returns:
        dict with status, model info, or error
    """
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(f"{url}/health")

            if response.status_code == 200:
                data = response.json()
                return {
                    "available": True,
                    "status": data.get("status"),
                    "model": data.get("model"),
                    "device": data.get("device"),
                    "error": None
                }
            else:
                return {
                    "available": False,
                    "error": f"Service returned status {response.status_code}"
                }

    except httpx.ConnectError:
        return {
            "available": False,
            "error": "Cannot connect to Whisper service. Is it running?"
        }

    except Exception as e:
        return {
            "available": False,
            "error": str(e)
        }


# Example usage
async def main():
    result = await check_whisper_service()

    if result["available"]:
        print(f"✅ Whisper service online (model: {result['model']})")
    else:
        print(f"❌ Whisper service unavailable: {result['error']}")

if __name__ == "__main__":
    asyncio.run(main())
```

**GDScript settings validation:**
```gdscript
# godot/scripts/autoload/settings_manager.gd

func validate_whisper_service() -> Dictionary:
    """Check if Whisper service is available"""
    var url = get_setting("conversation.whisper_service_url", "http://localhost:8001")
    var http = HTTPRequest.new()
    add_child(http)

    var result = await http.request_completed
    remove_child(http)
    http.queue_free()

    if result[1] == 200:
        var json = JSON.parse_string(result[3].get_string_from_utf8())
        return {
            "available": true,
            "model": json.get("model", "unknown"),
            "status": json.get("status", "unknown")
        }
    else:
        return {
            "available": false,
            "error": "Service not responding"
        }
```

---

## Godot Voice Input

### Voice Input Component

**godot/scripts/ui/voice_input.gd:**
```gdscript
extends Control
class_name VoiceInput

# Signals
signal recording_started
signal recording_stopped
signal transcription_received(text: String)
signal transcription_error(error: String)

# Configuration
@export var whisper_url: String = "http://localhost:8001"
@export var sample_rate: int = 16000
@export var input_mode: String = "push_to_talk"  # "push_to_talk", "voice_activation", "toggle"

# Audio recording
var audio_effect: AudioEffectRecord
var recording: AudioStreamSample
var is_recording: bool = false
var is_toggle_active: bool = false

# UI elements
@onready var record_button = $RecordButton
@onready var waveform = $Waveform
@onready var status_label = $StatusLabel
@onready var transcription_label = $TranscriptionLabel

# Voice activation
var voice_activation_threshold: float = 0.5
var silence_timer: float = 0.0
var silence_timeout: float = 2.0


func _ready():
    # Load settings
    load_voice_settings()

    # Setup audio recording
    setup_audio_recording()

    # Connect signals
    record_button.pressed.connect(_on_record_button_pressed)


func load_voice_settings():
    """Load voice input settings"""
    whisper_url = SettingsManager.get_setting("conversation.whisper_service_url", "http://localhost:8001")
    input_mode = SettingsManager.get_setting("conversation.voice_input_mode", "push_to_talk")
    sample_rate = SettingsManager.get_setting("conversation.audio.sample_rate", 16000)

    voice_activation_threshold = SettingsManager.get_setting("conversation.voice_activation.threshold", 0.5)
    silence_timeout = SettingsManager.get_setting("conversation.voice_activation.silence_timeout_seconds", 2.0)


func setup_audio_recording():
    """Initialize audio recording"""
    # Get the AudioStreamPlayer
    var audio_player = AudioStreamPlayer.new()
    add_child(audio_player)

    # Add recording effect
    var audio_bus_idx = AudioServer.get_bus_index("Record")
    if audio_bus_idx == -1:
        audio_bus_idx = AudioServer.bus_count
        AudioServer.add_bus(audio_bus_idx)
        AudioServer.set_bus_name(audio_bus_idx, "Record")

    audio_effect = AudioEffectRecord.new()
    AudioServer.add_bus_effect(audio_bus_idx, audio_effect)


func _input(event: InputEvent):
    """Handle voice input"""
    if not SettingsManager.get_setting("conversation.voice_enabled", false):
        return

    var voice_key = SettingsManager.get_setting("conversation.voice_hotkey", "V")

    match input_mode:
        "push_to_talk":
            if event.is_action_pressed("voice_input"):  # V key
                start_recording()
            elif event.is_action_released("voice_input"):
                stop_recording()

        "toggle":
            if event.is_action_pressed("voice_input"):
                if is_toggle_active:
                    stop_recording()
                    is_toggle_active = false
                else:
                    start_recording()
                    is_toggle_active = true

        "voice_activation":
            # Auto-handled in _process()
            pass


func _process(delta: float):
    """Monitor voice activation"""
    if input_mode == "voice_activation" and SettingsManager.get_setting("conversation.voice_activation.enabled", false):
        var audio_level = get_current_audio_level()

        if audio_level > voice_activation_threshold:
            if not is_recording:
                start_recording()
            silence_timer = 0.0
        else:
            if is_recording:
                silence_timer += delta
                if silence_timer >= silence_timeout:
                    stop_recording()


func get_current_audio_level() -> float:
    """Get current microphone audio level"""
    # Implementation depends on Godot's audio capture API
    # This is a placeholder
    return 0.0


func start_recording():
    """Start audio recording"""
    if is_recording:
        return

    is_recording = true
    audio_effect.set_recording_active(true)

    # Play beep if enabled
    if SettingsManager.get_setting("conversation.audio.play_beep", true):
        play_beep("start")

    # Update UI
    status_label.text = "🎤 Recording..."
    record_button.modulate = Color.RED

    emit_signal("recording_started")


func stop_recording():
    """Stop recording and transcribe"""
    if not is_recording:
        return

    is_recording = false
    recording = audio_effect.get_recording()
    audio_effect.set_recording_active(false)

    # Play beep if enabled
    if SettingsManager.get_setting("conversation.audio.play_beep", true):
        play_beep("stop")

    # Update UI
    status_label.text = "⏳ Transcribing..."
    record_button.modulate = Color.WHITE

    emit_signal("recording_stopped")

    # Send to Whisper service
    await transcribe_audio(recording)


func transcribe_audio(audio: AudioStreamSample):
    """Send audio to Whisper service for transcription"""
    # Save audio to temporary WAV file
    var temp_path = "user://temp_recording.wav"
    save_audio_to_wav(audio, temp_path)

    # Read file as bytes
    var file = FileAccess.open(temp_path, FileAccess.READ)
    var audio_bytes = file.get_buffer(file.get_length())
    file.close()

    # Send HTTP request
    var http = HTTPRequest.new()
    add_child(http)

    var headers = ["Content-Type: multipart/form-data; boundary=----Boundary"]
    var body = create_multipart_body(audio_bytes, "recording.wav")

    http.request(whisper_url + "/transcribe", headers, HTTPClient.METHOD_POST, body)

    var response = await http.request_completed
    remove_child(http)
    http.queue_free()

    # Parse response
    var status_code = response[1]
    var response_body = response[3].get_string_from_utf8()

    if status_code == 200:
        var json = JSON.parse_string(response_body)

        if json.success:
            var text = json.text
            status_label.text = "✅ Transcribed"
            transcription_label.text = text
            emit_signal("transcription_received", text)
        else:
            status_label.text = "❌ " + json.error
            emit_signal("transcription_error", json.error)
    else:
        status_label.text = "❌ Service error"
        emit_signal("transcription_error", "HTTP " + str(status_code))


func save_audio_to_wav(audio: AudioStreamSample, path: String):
    """Save AudioStreamSample to WAV file"""
    var file = FileAccess.open(path, FileAccess.WRITE)

    # WAV header
    file.store_buffer("RIFF".to_ascii_buffer())
    file.store_32(0)  # File size - 8 (will update later)
    file.store_buffer("WAVE".to_ascii_buffer())

    # fmt chunk
    file.store_buffer("fmt ".to_ascii_buffer())
    file.store_32(16)  # Chunk size
    file.store_16(1)   # Audio format (PCM)
    file.store_16(1)   # Channels (mono)
    file.store_32(sample_rate)
    file.store_32(sample_rate * 2)  # Byte rate
    file.store_16(2)   # Block align
    file.store_16(16)  # Bits per sample

    # data chunk
    file.store_buffer("data".to_ascii_buffer())
    var audio_data = audio.data
    file.store_32(audio_data.size())
    file.store_buffer(audio_data)

    # Update file size
    var file_size = file.get_position()
    file.seek(4)
    file.store_32(file_size - 8)

    file.close()


func create_multipart_body(file_data: PackedByteArray, filename: String) -> PackedByteArray:
    """Create multipart/form-data body"""
    var boundary = "----Boundary"
    var body = PackedByteArray()

    # Add file field
    body.append_array(("--" + boundary + "\r\n").to_utf8_buffer())
    body.append_array(("Content-Disposition: form-data; name=\"file\"; filename=\"" + filename + "\"\r\n").to_utf8_buffer())
    body.append_array("Content-Type: audio/wav\r\n\r\n".to_utf8_buffer())
    body.append_array(file_data)
    body.append_array("\r\n".to_utf8_buffer())

    # Add language field
    body.append_array(("--" + boundary + "\r\n").to_utf8_buffer())
    body.append_array("Content-Disposition: form-data; name=\"language\"\r\n\r\n".to_utf8_buffer())
    body.append_array("en\r\n".to_utf8_buffer())

    # End boundary
    body.append_array(("--" + boundary + "--\r\n").to_utf8_buffer())

    return body


func play_beep(type: String):
    """Play audio feedback beep"""
    # Implementation: play short beep sound
    pass
```

### Chat Integration

**Integrate voice input with chat overlay:**
```gdscript
# godot/scripts/ui/chat_overlay.gd (additions)

var voice_input: VoiceInput

func _ready():
    # ... existing code ...

    # Setup voice input
    if SettingsManager.get_setting("conversation.voice_enabled", false):
        voice_input = VoiceInput.new()
        add_child(voice_input)

        voice_input.transcription_received.connect(_on_voice_transcription)
        voice_input.transcription_error.connect(_on_voice_error)


func _on_voice_transcription(text: String):
    """Handle transcribed voice input"""
    # Insert transcribed text into chat input
    text_input.text = text

    # Optionally auto-send
    if SettingsManager.get_setting("conversation.voice_auto_send", true):
        await process_message(text)
    else:
        # Let user review/edit before sending
        text_input.grab_focus()


func _on_voice_error(error: String):
    """Handle voice transcription error"""
    add_system_message("Voice error: " + error)
```

---

## Audio Processing Pipeline

### Audio Flow

```
┌──────────────┐
│  Microphone  │
└──────┬───────┘
       │ Raw audio stream
       ▼
┌──────────────────────┐
│  Audio Input Bus     │
│  (Godot AudioServer) │
└──────┬───────────────┘
       │ Capture via AudioEffectRecord
       ▼
┌──────────────────────┐
│  Audio Buffer        │
│  (AudioStreamSample) │
└──────┬───────────────┘
       │ 16kHz, mono, 16-bit PCM
       ▼
┌──────────────────────┐
│  WAV Encoder         │
│  (Write WAV header)  │
└──────┬───────────────┘
       │ WAV file
       ▼
┌──────────────────────┐
│  HTTP Upload         │
│  POST /transcribe    │
└──────┬───────────────┘
       │ Multipart form data
       ▼
┌──────────────────────┐
│  Whisper Service     │
│  (FFmpeg → Whisper)  │
└──────┬───────────────┘
       │ Transcribed text
       ▼
┌──────────────────────┐
│  JSON Response       │
│  {"text": "..."}     │
└──────────────────────┘
```

### Audio Format Specifications

**Recommended Settings:**
- **Sample Rate**: 16000 Hz (Whisper's native rate)
- **Channels**: 1 (mono)
- **Bit Depth**: 16-bit PCM
- **Format**: WAV (uncompressed)

**Why 16kHz?**
- Whisper is trained on 16kHz audio
- Lower bandwidth (faster uploads)
- Good enough for speech (human voice is 300-3400 Hz)
- Reduces file size by 66% vs 48kHz

### Noise Reduction (Optional)

**Pre-processing in Godot (before sending to Whisper):**
```gdscript
func apply_noise_gate(audio: AudioStreamSample, threshold: float) -> AudioStreamSample:
    """Apply simple noise gate to remove background noise"""
    var data = audio.data
    var processed = PackedByteArray()

    for i in range(0, data.size(), 2):
        var sample = data.decode_s16(i)
        var amplitude = abs(sample) / 32768.0

        if amplitude > threshold:
            processed.append(data[i])
            processed.append(data[i + 1])
        else:
            processed.append(0)
            processed.append(0)

    var result = AudioStreamSample.new()
    result.data = processed
    result.format = audio.format
    result.mix_rate = audio.mix_rate
    result.stereo = audio.stereo

    return result
```

---

## Database Schema

### Voice Settings Table (Local SQLite)

```sql
-- Store per-save voice preferences
CREATE TABLE voice_settings (
    save_slot INTEGER PRIMARY KEY,
    voice_enabled BOOLEAN DEFAULT TRUE,
    voice_input_mode TEXT DEFAULT 'push_to_talk',  -- 'push_to_talk', 'voice_activation', 'toggle'
    voice_activation_threshold REAL DEFAULT 0.5,
    silence_timeout_seconds REAL DEFAULT 2.0,
    auto_send_transcription BOOLEAN DEFAULT TRUE,
    show_waveform BOOLEAN DEFAULT TRUE,
    play_beep BOOLEAN DEFAULT TRUE,
    microphone_device TEXT DEFAULT 'default',
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Track voice usage statistics
CREATE TABLE voice_usage_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    save_slot INTEGER NOT NULL,
    timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
    recording_duration_seconds REAL,
    transcription_length INTEGER,
    transcription_time_ms INTEGER,
    success BOOLEAN,
    error_message TEXT,
    FOREIGN KEY (save_slot) REFERENCES voice_settings(save_slot)
);

-- Index for performance
CREATE INDEX idx_voice_usage_timestamp ON voice_usage_log(timestamp);
```

### Global Voice Settings (PostgreSQL)

```sql
-- Global Whisper service configuration
CREATE TABLE whisper_settings (
    id SERIAL PRIMARY KEY,
    whisper_service_url TEXT DEFAULT 'http://localhost:8001',
    whisper_model TEXT DEFAULT 'base',
    whisper_language TEXT DEFAULT 'en',
    service_enabled BOOLEAN DEFAULT TRUE,
    last_health_check TIMESTAMP,
    health_status TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Implementation Plan

### Phase 1: Whisper Service Setup (Week 1)

**Day 1-2: Installation & Testing**
- [ ] Create `python/whisper-service/` directory
- [ ] Write `whisper-requirements.txt`
- [ ] Create `main.py` FastAPI server
- [ ] Write installation script
- [ ] Test `/transcribe` endpoint with sample audio
- [ ] Test `/health` endpoint
- [ ] Document installation process

**Day 3: Docker Integration**
- [ ] Create `Dockerfile` for Whisper service
- [ ] Update `docker-compose.yml` with whisper service
- [ ] Test Docker deployment
- [ ] Create startup scripts

**Day 4-5: API Testing**
- [ ] Test with different audio formats (WAV, MP3, OGG)
- [ ] Test with different languages
- [ ] Benchmark transcription speed
- [ ] Test error handling (no speech, corrupted audio)

### Phase 2: Settings Integration (Week 2)

**Day 1-2: Settings UI**
- [ ] Add Voice Input section to General Settings
- [ ] Create voice settings UI components
- [ ] Implement Whisper service connection test
- [ ] Add microphone device selection

**Day 3: Settings Backend**
- [ ] Update `settings.json` schema
- [ ] Add voice settings to SettingsManager
- [ ] Implement settings validation
- [ ] Create Whisper service health check

**Day 4-5: Database**
- [ ] Create voice_settings table (SQLite)
- [ ] Create whisper_settings table (PostgreSQL)
- [ ] Implement settings persistence
- [ ] Test settings save/load

### Phase 3: Godot Voice Input (Week 3)

**Day 1-2: Audio Recording**
- [ ] Implement VoiceInput component
- [ ] Setup AudioEffectRecord
- [ ] Test microphone capture
- [ ] Implement WAV file encoding

**Day 3-4: Transcription Integration**
- [ ] Implement HTTP upload to Whisper service
- [ ] Parse transcription response
- [ ] Handle errors gracefully
- [ ] Add loading indicators

**Day 5: Input Modes**
- [ ] Implement push-to-talk mode
- [ ] Implement toggle mode
- [ ] Implement voice activation mode (basic)
- [ ] Add audio level visualization

### Phase 4: Chat Integration (Week 4)

**Day 1-2: UI Integration**
- [ ] Add voice button to chat overlay
- [ ] Show recording status
- [ ] Display transcription preview
- [ ] Implement auto-send option

**Day 3: Voice Commands**
- [ ] Test voice commands with command parser
- [ ] Test voice questions with AI personalities
- [ ] Verify routing to correct AI

**Day 4-5: Polish & Testing**
- [ ] Add audio feedback (beeps)
- [ ] Improve error messages
- [ ] Test end-to-end flow
- [ ] User acceptance testing

### Phase 5: Optimization & Documentation (Week 5)

**Day 1-2: Performance**
- [ ] Optimize audio file size
- [ ] Implement caching (if needed)
- [ ] Test on different hardware
- [ ] Benchmark latency

**Day 3-4: Documentation**
- [ ] Update CLAUDE.md with voice setup
- [ ] Update README.md with voice features
- [ ] Create troubleshooting guide
- [ ] Write user tutorial

**Day 5: Final Testing**
- [ ] Full integration test
- [ ] Test with/without Whisper service
- [ ] Test graceful degradation
- [ ] Performance validation

---

## Performance Optimization

### Latency Breakdown

**Target: < 2 seconds total**

| Step | Time | Optimization |
|------|------|--------------|
| Recording (user speaks) | 1-5s | User-controlled |
| Audio encoding (WAV) | 50-100ms | Pre-allocate buffers |
| HTTP upload | 100-300ms | Local network, compress if needed |
| Whisper transcription | 500-1500ms | Use `base` model, GPU if available |
| HTTP response | 50-100ms | - |
| **Total** | **~1.5-3s** | **Acceptable for voice input** |

### Speed Improvements

**1. Use Faster Whisper Model**
```python
# Trade accuracy for speed
model = whisper.load_model("tiny")  # 2-3x faster than base
```

**2. GPU Acceleration**
```python
# If NVIDIA GPU available
import torch
device = "cuda" if torch.cuda.is_available() else "cpu"
model = whisper.load_model("base", device=device)
```

**3. Optimize Audio Upload**
```gdscript
# Compress audio before upload (if needed)
func compress_audio(audio: AudioStreamSample) -> PackedByteArray:
    # Convert to lower bitrate MP3 or Opus
    # Trade file size for slight quality loss
    pass
```

**4. Stream Audio (Advanced)**
```python
# Stream audio in chunks instead of waiting for full recording
# Useful for long voice messages
# Not recommended for v1 (adds complexity)
```

### Memory Usage

**Whisper Model Memory:**
- `tiny`: ~400 MB RAM
- `base`: ~1 GB RAM
- `small`: ~2 GB RAM
- `medium`: ~5 GB RAM

**Recommendation:** Use `base` model (good balance)

---

## Error Handling

### Common Errors & Solutions

#### 1. Whisper Service Not Running

**Error:**
```json
{
  "success": false,
  "error": "Cannot connect to Whisper service"
}
```

**Solution:**
- Show clear error in UI: "Voice input unavailable. Start Whisper service?"
- Provide link to installation guide
- Fall back to text-only chat
- Don't block game functionality

**Godot UI:**
```gdscript
if not whisper_available:
    voice_button.disabled = true
    voice_button.tooltip_text = "Voice input requires Whisper service.\nSee Settings > Voice Input"
```

#### 2. No Speech Detected

**Error:**
```json
{
  "success": false,
  "error": "No speech detected in audio",
  "error_type": "no_speech"
}
```

**Solution:**
- Show message: "No speech detected. Try again?"
- Suggest checking microphone
- Show audio level indicator to help user

#### 3. Microphone Permission Denied

**Error:**
Browser/OS blocks microphone access

**Solution:**
- Request permission on first use
- Show clear instructions
- Provide troubleshooting steps

#### 4. Audio Too Long

**Limit:** Max 30 seconds per recording (Whisper limitation)

**Solution:**
```gdscript
const MAX_RECORDING_DURATION = 30.0
var recording_timer = 0.0

func _process(delta):
    if is_recording:
        recording_timer += delta
        if recording_timer >= MAX_RECORDING_DURATION:
            stop_recording()
            show_warning("Recording limit reached (30s)")
```

#### 5. Low Quality Transcription

**Causes:**
- Background noise
- Low volume
- Poor microphone

**Solutions:**
- Show confidence score to user
- Allow manual correction before sending
- Suggest noise reduction settings
- Show transcription preview for review

### Graceful Degradation

**If Whisper service fails:**
1. Disable voice button
2. Show notification
3. Continue with text-only chat
4. Periodically retry connection (every 30s)

```gdscript
func check_whisper_availability():
    var result = await WhisperService.check_health()

    if result.available:
        voice_input.show()
        voice_button.disabled = false
    else:
        voice_input.hide()
        voice_button.disabled = true

        # Retry in 30 seconds
        await get_tree().create_timer(30.0).timeout
        check_whisper_availability()
```

---

## Summary

This Whisper AI Voice Transcription System enables:

✅ **Voice-to-text transcription** using OpenAI Whisper (local, private, no costs)
✅ **Three input modes** - Push-to-talk, Voice Activation, Toggle
✅ **Optional installation** - Users can skip if they don't want voice
✅ **Settings integration** - Full configuration in General Settings tab
✅ **Chat integration** - Voice transcription feeds directly into AI chat
✅ **Multiple AI personalities** - Works with ATLAS, Storyteller, Guardian, Companion
✅ **Fast transcription** - ~1-3 seconds total latency with `base` model
✅ **Graceful fallback** - Text chat works even if Whisper unavailable
✅ **Star Trek immersion** - "Computer, plot course to Earth!"

### Key Features

1. **Local Processing** - Runs on user's machine, no cloud API needed
2. **Privacy** - Audio never leaves the local network
3. **Cost-Free** - No per-use charges (unlike cloud APIs)
4. **Multiple Languages** - Whisper supports 90+ languages
5. **Good Accuracy** - Whisper is state-of-the-art for speech recognition
6. **Low Barrier** - Easy installation, works on CPU (GPU optional)

---

**Document Status:** Complete
**Related Documents:**
- [ai-chat-storytelling-system.md](ai-chat-storytelling-system.md) - AI chat and conversation system
- [settings-system.md](settings-system.md) - Settings and configuration
- [technical-architecture.md](technical-architecture.md) - Implementation architecture

**Last Updated:** November 5, 2025
