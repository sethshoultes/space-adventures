#!/bin/bash
# Start all Space Adventures microservices

set -e  # Exit on error

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_SERVICE_DIR="$PROJECT_ROOT/python/ai-service"
LOG_DIR="$PROJECT_ROOT/logs"

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

echo "🚀 Starting Space Adventures Microservices..."
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Ollama is running
echo -n "Checking Ollama... "
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${YELLOW}⚠ Not running${NC}"
    echo "  Starting Ollama..."
    # Try to start Ollama (platform-specific)
    if command -v ollama &> /dev/null; then
        ollama serve > "$LOG_DIR/ollama.log" 2>&1 &
        sleep 3
        echo -e "${GREEN}✓ Ollama started${NC}"
    else
        echo -e "${RED}✗ Ollama not found. Please install Ollama.${NC}"
        exit 1
    fi
fi

# Check if Redis is running
echo -n "Checking Redis... "
if redis-cli -p 6379 ping > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Running (port 6379)${NC}"
else
    echo -e "${YELLOW}⚠ Not running${NC}"
    echo "  Starting Redis..."
    redis-server --daemonize yes --port 6379 > "$LOG_DIR/redis.log" 2>&1
    sleep 2
    echo -e "${GREEN}✓ Redis started (port 6379)${NC}"
fi

# Start AI Service
echo -n "Checking AI Service... "
if curl -s http://localhost:17011/health > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Already running${NC}"
    echo "  Use './scripts/restart-ai.sh' to restart"
else
    echo -e "Starting..."
    cd "$AI_SERVICE_DIR"

    # Activate venv and start service
    source venv/bin/activate
    nohup python main.py > "$LOG_DIR/ai-service.log" 2>&1 &
    AI_PID=$!

    # Wait for service to be ready
    echo -n "  Waiting for AI service to start"
    for i in {1..15}; do
        if curl -s http://localhost:17011/health > /dev/null 2>&1; then
            echo ""
            echo -e "${GREEN}✓ AI Service started (PID: $AI_PID, port 17011)${NC}"
            break
        fi
        echo -n "."
        sleep 1
    done

    if ! curl -s http://localhost:17011/health > /dev/null 2>&1; then
        echo ""
        echo -e "${RED}✗ AI Service failed to start${NC}"
        echo "  Check logs: $LOG_DIR/ai-service.log"
        exit 1
    fi
fi

echo ""
echo "================================================"
echo -e "${GREEN}✅ All services running!${NC}"
echo ""
echo "Service URLs:"
echo "  • AI Service:  http://localhost:17011"
echo "  • Ollama:      http://localhost:11434"
echo "  • Redis:       localhost:6379"
echo ""
echo "Logs directory: $LOG_DIR"
echo ""
echo "Commands:"
echo "  • Check status:  ./scripts/status.sh"
echo "  • Stop services: ./scripts/stop-all.sh"
echo "  • Restart AI:    ./scripts/restart-ai.sh"
echo ""
