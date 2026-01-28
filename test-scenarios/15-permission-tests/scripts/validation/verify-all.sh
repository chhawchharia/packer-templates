#!/bin/bash
# ==============================================================================
# verify-all.sh - Comprehensive Verification Script
# ==============================================================================
# This script performs a comprehensive verification of the entire setup,
# including all scripts, permissions, and configurations.
# ==============================================================================

set -e

SCRIPT_NAME="verify-all.sh"
SCRIPT_DIR="${HARNESS_HOME:-/opt/harness}/scripts"
CONFIG_DIR="${CONFIG_DIR:-/etc/harness}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "  Testing: $test_name... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# ==============================================================================
# Main Execution
# ==============================================================================

echo ""
echo -e "${CYAN}=============================================="
echo "      COMPREHENSIVE VERIFICATION SUITE        "
echo "==============================================${NC}"
echo ""

# ==============================================================================
# Section 1: Directory Structure
# ==============================================================================
echo -e "${BLUE}[1/6] Checking Directory Structure${NC}"
echo "----------------------------------------------"

run_test "Scripts directory exists" "[ -d '$SCRIPT_DIR' ]"
run_test "Setup scripts directory exists" "[ -d '$SCRIPT_DIR/setup' ]"
run_test "Validation scripts directory exists" "[ -d '$SCRIPT_DIR/validation' ]"
run_test "Config directory exists" "[ -d '$CONFIG_DIR' ]"
run_test "Log directory exists" "[ -d '/var/log/harness' ]"
run_test "Workspace directory exists" "[ -d '/opt/harness/workspace' ]"
run_test "Cache directory exists" "[ -d '/opt/harness/cache' ]"
run_test "Artifacts directory exists" "[ -d '/opt/harness/artifacts' ]"

echo ""

# ==============================================================================
# Section 2: Script Permissions
# ==============================================================================
echo -e "${BLUE}[2/6] Checking Script Permissions${NC}"
echo "----------------------------------------------"

# Check all setup scripts
if [ -d "$SCRIPT_DIR/setup" ]; then
    shopt -s nullglob
    for script in "$SCRIPT_DIR/setup"/*.sh; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")
            run_test "Setup script executable: $script_name" "[ -x '$script' ]"
        fi
    done
    shopt -u nullglob
fi

# Check all validation scripts
if [ -d "$SCRIPT_DIR/validation" ]; then
    shopt -s nullglob
    for script in "$SCRIPT_DIR/validation"/*.sh; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")
            run_test "Validation script executable: $script_name" "[ -x '$script' ]"
        fi
    done
    shopt -u nullglob
fi

echo ""

# ==============================================================================
# Section 3: Script Syntax
# ==============================================================================
echo -e "${BLUE}[3/6] Validating Script Syntax${NC}"
echo "----------------------------------------------"

# Check all scripts for syntax errors
find "$SCRIPT_DIR" -name "*.sh" -type f 2>/dev/null | while read script; do
    script_name=$(basename "$script")
    run_test "Syntax valid: $script_name" "bash -n '$script'"
done

echo ""

# ==============================================================================
# Section 4: Configuration Files
# ==============================================================================
echo -e "${BLUE}[4/6] Checking Configuration Files${NC}"
echo "----------------------------------------------"

if [ -d "$CONFIG_DIR" ]; then
    shopt -s nullglob
    for config in "$CONFIG_DIR"/*; do
        if [ -f "$config" ]; then
            config_name=$(basename "$config")
            run_test "Config readable: $config_name" "[ -r '$config' ]"
        fi
    done
    shopt -u nullglob
else
    echo "  (No config files to check)"
fi

echo ""

# ==============================================================================
# Section 5: Setup Completion
# ==============================================================================
echo -e "${BLUE}[5/6] Checking Setup Completion${NC}"
echo "----------------------------------------------"

run_test "Init completed" "[ -f '/tmp/harness-setup/01-init.done' ]"
run_test "Packages completed" "[ -f '/tmp/harness-setup/02-packages.done' ]"
run_test "Configure completed" "[ -f '/tmp/harness-setup/03-configure.done' ]"

echo ""

# ==============================================================================
# Section 6: Installed Tools
# ==============================================================================
echo -e "${BLUE}[6/6] Verifying Installed Tools${NC}"
echo "----------------------------------------------"

run_test "curl installed" "which curl"
run_test "wget installed" "which wget"
run_test "git installed" "which git"
run_test "jq installed" "which jq"
run_test "tree installed" "which tree"
run_test "unzip installed" "which unzip"

echo ""

# ==============================================================================
# Summary
# ==============================================================================
echo -e "${CYAN}=============================================="
echo "                  FINAL SUMMARY               "
echo "==============================================${NC}"
echo ""
echo "  Total tests:  $TOTAL_TESTS"
echo -e "  ${GREEN}Passed:       $PASSED_TESTS${NC}"
echo -e "  ${RED}Failed:       $FAILED_TESTS${NC}"
echo ""

# Calculate percentage
if [ $TOTAL_TESTS -gt 0 ]; then
    PERCENTAGE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "  Success rate: ${PERCENTAGE}%"
fi

echo ""
echo "=============================================="

if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}VERIFICATION FAILED - $FAILED_TESTS tests did not pass${NC}"
    exit 1
else
    echo -e "${GREEN}ALL VERIFICATION TESTS PASSED${NC}"
    exit 0
fi
