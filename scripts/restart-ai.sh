#!/bin/bash
# Restart AI Service only

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_SERVICE_DIR="$PROJECT_ROOT/python/ai-service"
LOG_DIR="$PROJECT_ROOT/logs"

mkdir -p "$LOG_DIR"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔄 Restarting AI Service..."
echo "================================================"

# Stop AI Service
echo -n "Stopping AI Service... "
pkill -f "python main.py" 2>/dev/null && echo -e "${GREEN}✓${NC}" || echo -e "${YELLOW}(not running)${NC}"
sleep 1

# Start AI Service
echo -n "Starting AI Service... "
cd "$AI_SERVICE_DIR"
source venv/bin/activate
nohup python main.py > "$LOG_DIR/ai-service.log" 2>&1 &
AI_PID=$!

# Wait for service to be ready
echo -n "waiting"
for i in {1..15}; do
    if curl -s http://localhost:17011/health > /dev/null 2>&1; then
        echo ""
        echo -e "${GREEN}✓ AI Service restarted (PID: $AI_PID)${NC}"
        break
    fi
    echo -n "."
    sleep 1
done

if ! curl -s http://localhost:17011/health > /dev/null 2>&1; then
    echo ""
    echo -e "✗ AI Service failed to start"
    echo "Check logs: $LOG_DIR/ai-service.log"
    exit 1
fi

echo ""
echo "Service URL: http://localhost:17011/health"
echo "Logs: $LOG_DIR/ai-service.log"
echo ""
