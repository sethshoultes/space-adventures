#!/bin/bash
# Stop all Space Adventures microservices

echo "🛑 Stopping Space Adventures Microservices..."
echo "================================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Stop AI Service
echo -n "Stopping AI Service... "
pkill -f "python main.py" 2>/dev/null && echo -e "${GREEN}✓${NC}" || echo -e "${YELLOW}(not running)${NC}"

# Note: We don't stop Redis or Ollama as they might be used by other apps
echo ""
echo "================================================"
echo -e "${GREEN}✅ Services stopped${NC}"
echo ""
echo "Note: Redis and Ollama are still running (shared services)"
echo "To stop them manually:"
echo "  • Redis: redis-cli shutdown"
echo "  • Ollama: pkill ollama"
echo ""
