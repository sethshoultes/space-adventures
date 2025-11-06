"""
Whisper Service - Voice-to-Text Transcription Service

This service provides voice transcription using OpenAI Whisper.
It's an optional service that enables voice input for the chat system.

Features:
- Audio file transcription (WAV, MP3, OGG, FLAC, M4A)
- Multiple language support
- Automatic language detection
- Real-time transcription
- Graceful degradation (game works without it)
"""

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import os
from dotenv import load_dotenv
from datetime import datetime
import logging
from typing import Dict, Any, Optional
import tempfile
import aiofiles

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Space Adventures Whisper Service",
    description="Voice-to-text transcription service using OpenAI Whisper",
    version="0.1.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
WHISPER_MODEL = os.getenv("WHISPER_MODEL", "base")
DEVICE = os.getenv("DEVICE", "cpu")
MAX_FILE_SIZE = int(os.getenv("MAX_FILE_SIZE_MB", "25")) * 1024 * 1024
SUPPORTED_FORMATS = os.getenv("SUPPORTED_FORMATS", "wav,mp3,ogg,flac,m4a").split(",")


# Lazy load Whisper model (only when needed)
_whisper_model = None


def get_whisper_model():
    """Lazy load Whisper model."""
    global _whisper_model
    if _whisper_model is None:
        try:
            import whisper
            logger.info(f"Loading Whisper model: {WHISPER_MODEL}")
            _whisper_model = whisper.load_model(WHISPER_MODEL, device=DEVICE)
            logger.info("Whisper model loaded successfully")
        except Exception as e:
            logger.error(f"Failed to load Whisper model: {e}")
            raise HTTPException(
                status_code=503,
                detail=f"Whisper model not available: {str(e)}"
            )
    return _whisper_model


# Health check endpoint
@app.get("/health")
async def health_check() -> Dict[str, Any]:
    """
    Whisper Service health check.
    Returns service status and model information.
    """
    model_loaded = _whisper_model is not None

    return {
        "status": "healthy",
        "service": "whisper-service",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "0.1.0",
        "model": WHISPER_MODEL,
        "device": DEVICE,
        "model_loaded": model_loaded,
        "supported_formats": SUPPORTED_FORMATS
    }


@app.get("/")
async def root():
    """Root endpoint with service information."""
    return {
        "service": "Space Adventures Whisper Service",
        "version": "0.1.0",
        "status": "operational",
        "docs": "/docs",
        "health": "/health",
        "endpoints": {
            "transcribe": "/api/transcribe",
            "models": "/api/models"
        }
    }


@app.get("/api/models")
async def list_models():
    """List available Whisper models and current configuration."""
    return {
        "available_models": [
            {
                "name": "tiny",
                "size": "39 MB",
                "description": "Fastest, lowest accuracy"
            },
            {
                "name": "base",
                "size": "142 MB",
                "description": "Recommended - Fast with good accuracy"
            },
            {
                "name": "small",
                "size": "466 MB",
                "description": "Better accuracy, slower"
            },
            {
                "name": "medium",
                "size": "1.5 GB",
                "description": "High accuracy, requires more resources"
            },
            {
                "name": "large",
                "size": "2.9 GB",
                "description": "Best accuracy, slowest"
            }
        ],
        "current_model": WHISPER_MODEL,
        "device": DEVICE,
        "supported_formats": SUPPORTED_FORMATS
    }


@app.post("/api/transcribe")
async def transcribe_audio(
    file: UploadFile = File(...),
    language: Optional[str] = None
):
    """
    Transcribe audio file to text.

    Args:
        file: Audio file (WAV, MP3, OGG, FLAC, M4A)
        language: Optional language code (en, es, fr, etc.) or 'auto'

    Returns:
        Transcribed text and metadata
    """
    # Validate file size
    contents = await file.read()
    file_size = len(contents)

    if file_size > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=413,
            detail=f"File too large. Max size: {MAX_FILE_SIZE / 1024 / 1024} MB"
        )

    # Validate file format
    file_extension = file.filename.split(".")[-1].lower()
    if file_extension not in SUPPORTED_FORMATS:
        raise HTTPException(
            status_code=415,
            detail=f"Unsupported format. Supported: {', '.join(SUPPORTED_FORMATS)}"
        )

    # Save file temporarily
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=f".{file_extension}") as temp_file:
            temp_file.write(contents)
            temp_path = temp_file.name

        # Load Whisper model
        model = get_whisper_model()

        # Transcribe
        logger.info(f"Transcribing file: {file.filename} ({file_size} bytes)")
        start_time = datetime.utcnow()

        result = model.transcribe(
            temp_path,
            language=language if language and language != "auto" else None,
            task="transcribe"
        )

        end_time = datetime.utcnow()
        duration = (end_time - start_time).total_seconds()

        # Clean up temp file
        os.remove(temp_path)

        # Return transcription
        return {
            "success": True,
            "text": result["text"].strip(),
            "language": result.get("language", "unknown"),
            "duration_seconds": duration,
            "model": WHISPER_MODEL,
            "segments": len(result.get("segments", [])),
            "timestamp": datetime.utcnow().isoformat()
        }

    except Exception as e:
        # Clean up temp file on error
        if 'temp_path' in locals():
            try:
                os.remove(temp_path)
            except:
                pass

        logger.error(f"Transcription error: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Transcription failed: {str(e)}"
        )


"""
TODO Phase 4, Week 13-14:
- Add streaming transcription support
- Implement voice activation detection
- Add noise reduction preprocessing
- Implement caching for common phrases
- Add multi-language support optimization
- Performance benchmarking
"""

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", "8002")),
        log_level=os.getenv("LOG_LEVEL", "info")
    )
