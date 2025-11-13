#!/bin/bash

# Milestone 2 Test Runner
# Runs automated tests for Warp Drive, Life Support, Parts, and Missions

set -e  # Exit on first error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

echo -e "${BLUE}================================================================================${NC}"
echo -e "${BLUE}MILESTONE 2 AUTOMATED TEST SUITE${NC}"
echo -e "${BLUE}================================================================================${NC}"
echo ""

# Change to project root
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

echo -e "${BLUE}Project Root:${NC} $PROJECT_ROOT"
echo ""

# ============================================================================
# FILE EXISTENCE CHECKS
# ============================================================================

echo -e "${YELLOW}>> Checking File Existence...${NC}"

check_file() {
    if [ -f "$1" ]; then
        echo -e "   ${GREEN}✓${NC} $1 exists"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "   ${RED}✗${NC} $1 MISSING"
        ((TESTS_FAILED++))
        return 1
    fi
}

# System files
check_file "godot/scripts/systems/warp_system.gd"
check_file "godot/scripts/systems/life_support_system.gd"

# Parts files
check_file "godot/assets/data/parts/warp_parts.json"
check_file "godot/assets/data/parts/life_support_parts.json"

# Mission files
check_file "godot/assets/data/missions/mission_industrial_zone_salvage.json"
check_file "godot/assets/data/missions/mission_orbital_station_salvage.json"
check_file "godot/assets/data/missions/mission_underground_bunker_exploration.json"
check_file "godot/assets/data/missions/mission_exodus_archive.json"

# Test files
check_file "godot/tests/test_milestone_2.gd"
check_file "godot/tests/test_m2_integration.gd"

echo ""

# ============================================================================
# JSON VALIDATION
# ============================================================================

echo -e "${YELLOW}>> Validating JSON Files...${NC}"

validate_json() {
    if python3 -m json.tool "$1" > /dev/null 2>&1; then
        echo -e "   ${GREEN}✓${NC} $1 is valid JSON"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "   ${RED}✗${NC} $1 has JSON errors"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Validate parts JSON
validate_json "godot/assets/data/parts/warp_parts.json"
validate_json "godot/assets/data/parts/life_support_parts.json"

# Validate mission JSON
validate_json "godot/assets/data/missions/mission_industrial_zone_salvage.json"
validate_json "godot/assets/data/missions/mission_orbital_station_salvage.json"
validate_json "godot/assets/data/missions/mission_underground_bunker_exploration.json"
validate_json "godot/assets/data/missions/mission_exodus_archive.json"

echo ""

# ============================================================================
# GIT COMMIT CHECK
# ============================================================================

echo -e "${YELLOW}>> Checking Git Commits...${NC}"

# Check if we're in a git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Check for M2-related commits
    WARP_COMMITS=$(git log --all --oneline --grep="warp" -i | wc -l)
    LIFE_COMMITS=$(git log --all --oneline --grep="life.support" -i | wc -l)

    if [ "$WARP_COMMITS" -gt 0 ]; then
        echo -e "   ${GREEN}✓${NC} Found $WARP_COMMITS warp-related commits"
        ((TESTS_PASSED++))
    else
        echo -e "   ${YELLOW}⚠${NC} No warp-related commits found (may be expected)"
    fi

    if [ "$LIFE_COMMITS" -gt 0 ]; then
        echo -e "   ${GREEN}✓${NC} Found $LIFE_COMMITS life support-related commits"
        ((TESTS_PASSED++))
    else
        echo -e "   ${YELLOW}⚠${NC} No life support-related commits found (may be expected)"
    fi
else
    echo -e "   ${YELLOW}⚠${NC} Not a git repository"
fi

echo ""

# ============================================================================
# GODOT HEADLESS TESTS
# ============================================================================

echo -e "${YELLOW}>> Running Godot Headless Tests...${NC}"

# Check if Godot is available
if command -v godot &> /dev/null; then
    GODOT_CMD="godot"
elif command -v godot4 &> /dev/null; then
    GODOT_CMD="godot4"
elif [ -f "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT_CMD="/Applications/Godot.app/Contents/MacOS/Godot"
else
    echo -e "   ${RED}✗${NC} Godot not found in PATH"
    echo -e "   ${YELLOW}⚠${NC} Skipping Godot tests (install Godot or add to PATH)"
    GODOT_CMD=""
fi

if [ -n "$GODOT_CMD" ]; then
    echo -e "   ${BLUE}Using Godot:${NC} $GODOT_CMD"

    # Run main test suite
    echo -e "   ${BLUE}Running test_milestone_2.gd...${NC}"
    if "$GODOT_CMD" --headless --path "$PROJECT_ROOT/godot" --script res://tests/test_milestone_2.gd 2>&1 | tee /tmp/m2_test_output.txt; then
        echo -e "   ${GREEN}✓${NC} test_milestone_2.gd completed"
        ((TESTS_PASSED++))
    else
        echo -e "   ${RED}✗${NC} test_milestone_2.gd FAILED"
        ((TESTS_FAILED++))
    fi

    # Run integration tests
    echo -e "   ${BLUE}Running test_m2_integration.gd...${NC}"
    if "$GODOT_CMD" --headless --path "$PROJECT_ROOT/godot" --script res://tests/test_m2_integration.gd 2>&1 | tee /tmp/m2_integration_output.txt; then
        echo -e "   ${GREEN}✓${NC} test_m2_integration.gd completed"
        ((TESTS_PASSED++))
    else
        echo -e "   ${RED}✗${NC} test_m2_integration.gd FAILED"
        ((TESTS_FAILED++))
    fi
else
    echo -e "   ${YELLOW}⚠${NC} Godot tests skipped"
fi

echo ""

# ============================================================================
# SUMMARY
# ============================================================================

echo -e "${BLUE}================================================================================${NC}"
echo -e "${BLUE}TEST RESULTS SUMMARY${NC}"
echo -e "${BLUE}================================================================================${NC}"

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
if [ $TOTAL_TESTS -gt 0 ]; then
    PASS_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($TESTS_PASSED / $TOTAL_TESTS) * 100}")
    FAIL_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($TESTS_FAILED / $TOTAL_TESTS) * 100}")
else
    PASS_PERCENT="0.0"
    FAIL_PERCENT="0.0"
fi

echo -e "Total Tests: ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC} (${PASS_PERCENT}%)"
echo -e "Failed: ${RED}$TESTS_FAILED${NC} (${FAIL_PERCENT}%)"
echo -e "${BLUE}================================================================================${NC}"

# Exit with appropriate code
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✅ ALL TESTS PASSED ✅${NC}\n"
    exit 0
else
    echo -e "\n${RED}❌ SOME TESTS FAILED ❌${NC}\n"
    echo -e "${YELLOW}Check test output above for details${NC}"
    exit 1
fi
