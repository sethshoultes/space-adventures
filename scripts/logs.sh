#!/bin/bash
# Tail logs for Space Adventures services

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs"

if [ ! -d "$LOG_DIR" ]; then
    echo "No logs directory found. Services may not be running."
    exit 1
fi

echo "📋 Tailing AI Service logs..."
echo "Press Ctrl+C to exit"
echo "================================================"
echo ""

tail -f "$LOG_DIR/ai-service.log" 2>/dev/null || echo "No AI service log found"
