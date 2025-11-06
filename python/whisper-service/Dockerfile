# Whisper Service Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies including FFmpeg
RUN apt-get update && apt-get install -y \
    curl \
    ffmpeg \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Download Whisper base model (142 MB)
# This happens at build time for faster startups
RUN python -c "import whisper; whisper.load_model('base')"

# Copy application code
COPY . .

# Create temp directory for audio files
RUN mkdir -p /tmp/whisper_uploads

# Expose port
EXPOSE 17012

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:17012/health || exit 1

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "17012"]
