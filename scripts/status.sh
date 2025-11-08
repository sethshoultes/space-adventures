#!/bin/bash
# Check status of all Space Adventures microservices

echo "📊 Space Adventures Service Status"
echo "================================================"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to check service
check_service() {
    local name=$1
    local url=$2
    local port=$3

    echo -n "$name (port $port): "
    if curl -s "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Running${NC}"
        return 0
    else
        echo -e "${RED}✗ Not running${NC}"
        return 1
    fi
}

# Function to check Redis
check_redis() {
    echo -n "Redis (port 6379): "
    if redis-cli -p 6379 ping > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Running${NC}"
        return 0
    else
        echo -e "${RED}✗ Not running${NC}"
        return 1
    fi
}

# Check all services
check_service "Ollama" "http://localhost:11434/api/tags" "11434"
check_redis
check_service "AI Service" "http://localhost:17011/health" "17011"

echo ""
echo "================================================"

# Check AI Service details if running
if curl -s http://localhost:17011/health > /dev/null 2>&1; then
    echo ""
    echo "AI Service Details:"
    curl -s http://localhost:17011/health | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f\"  Status: {data.get('status', 'unknown')}\")
print(f\"  Providers: {', '.join(data.get('providers', {}).get('available', []))}\")
print(f\"  Orchestrator: {'enabled' if data.get('orchestrator_enabled') else 'disabled'}\")
if 'scheduler' in data:
    sched = data['scheduler']
    print(f\"  Scheduler: {sched.get('status', 'unknown')} ({len(sched.get('jobs', []))} jobs)\")
" 2>/dev/null || echo "  (Could not fetch details)"
fi

echo ""
echo "Commands:"
echo "  • Start all:     ./scripts/start-all.sh"
echo "  • Stop all:      ./scripts/stop-all.sh"
echo "  • Restart AI:    ./scripts/restart-ai.sh"
echo "  • View AI logs:  tail -f logs/ai-service.log"
echo ""
