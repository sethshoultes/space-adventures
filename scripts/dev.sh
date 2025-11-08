#!/bin/bash
# Development helper - start services and open logs

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🎮 Space Adventures Development Mode"
echo "================================================"
echo ""

# Start all services
"$PROJECT_ROOT/scripts/start-all.sh"

echo ""
echo "================================================"
echo "Development mode active!"
echo ""
echo "Services are running. Logs available at:"
echo "  logs/ai-service.log"
echo "  logs/ollama.log"
echo "  logs/redis.log"
echo ""
echo "To monitor logs: ./scripts/logs.sh"
echo ""
echo "Ready to launch Godot!"
echo ""
