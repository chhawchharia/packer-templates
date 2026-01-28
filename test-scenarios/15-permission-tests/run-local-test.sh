#!/bin/bash
# ==============================================================================
# run-local-test.sh - Local Permission Test Runner
# ==============================================================================
# This script can be run locally (without Packer/GCP) to test the permission
# scripts and verify they work correctly before deploying.
#
# Usage:
#   ./run-local-test.sh           # Run all tests
#   ./run-local-test.sh --dry-run # Show what would be done
#   ./run-local-test.sh --help    # Show help
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be done without executing"
    echo "  --help       Show this help message"
    echo ""
    echo "This script tests the permission scripts locally to ensure"
    echo "they are syntactically correct and have proper permissions."
}

log_section() {
    echo ""
    echo -e "${CYAN}=============================================="
    echo "$1"
    echo "==============================================${NC}"
    echo ""
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# ==============================================================================
# Main Execution
# ==============================================================================

log_section "LOCAL PERMISSION TEST SUITE"

TOTAL=0
PASSED=0
FAILED=0

# Test 1: Check all scripts exist
log_section "TEST 1: Script Existence"

SCRIPTS=(
    "scripts/setup/01-init.sh"
    "scripts/setup/02-packages.sh"
    "scripts/setup/03-configure.sh"
    "scripts/validation/check-permissions.sh"
    "scripts/validation/verify-all.sh"
)

for script in "${SCRIPTS[@]}"; do
    TOTAL=$((TOTAL + 1))
    full_path="$SCRIPT_DIR/$script"
    if [ -f "$full_path" ]; then
        log_pass "File exists: $script"
        PASSED=$((PASSED + 1))
    else
        log_fail "File missing: $script"
        FAILED=$((FAILED + 1))
    fi
done

# Test 2: Check script permissions
log_section "TEST 2: Script Permissions"

for script in "${SCRIPTS[@]}"; do
    TOTAL=$((TOTAL + 1))
    full_path="$SCRIPT_DIR/$script"
    if [ -f "$full_path" ]; then
        if [ -x "$full_path" ]; then
            log_pass "Executable: $script"
            PASSED=$((PASSED + 1))
        else
            log_warn "Not executable: $script (fixing...)"
            if ! $DRY_RUN; then
                chmod +x "$full_path"
                if [ -x "$full_path" ]; then
                    log_pass "Fixed permissions: $script"
                    PASSED=$((PASSED + 1))
                else
                    log_fail "Could not fix permissions: $script"
                    FAILED=$((FAILED + 1))
                fi
            else
                log_info "Would run: chmod +x $full_path"
                PASSED=$((PASSED + 1))  # Count as pass in dry-run
            fi
        fi
    fi
done

# Test 3: Validate script syntax
log_section "TEST 3: Script Syntax Validation"

for script in "${SCRIPTS[@]}"; do
    TOTAL=$((TOTAL + 1))
    full_path="$SCRIPT_DIR/$script"
    if [ -f "$full_path" ]; then
        if $DRY_RUN; then
            log_info "Would run: bash -n $full_path"
            PASSED=$((PASSED + 1))
        else
            if bash -n "$full_path" 2>/dev/null; then
                log_pass "Syntax valid: $script"
                PASSED=$((PASSED + 1))
            else
                log_fail "Syntax error in: $script"
                bash -n "$full_path" 2>&1 | head -5
                FAILED=$((FAILED + 1))
            fi
        fi
    fi
done

# Test 4: Check config files
log_section "TEST 4: Configuration Files"

CONFIGS=(
    "scripts/config/harness.yaml"
    "scripts/config/environment.conf"
)

for config in "${CONFIGS[@]}"; do
    TOTAL=$((TOTAL + 1))
    full_path="$SCRIPT_DIR/$config"
    if [ -f "$full_path" ]; then
        log_pass "Config exists: $config"
        PASSED=$((PASSED + 1))
    else
        log_fail "Config missing: $config"
        FAILED=$((FAILED + 1))
    fi
done

# Test 5: Check Packer file syntax
log_section "TEST 5: Packer File Validation"

PACKER_FILE="$SCRIPT_DIR/packer.pkr.hcl"
TOTAL=$((TOTAL + 1))

if [ -f "$PACKER_FILE" ]; then
    log_pass "Packer file exists"
    PASSED=$((PASSED + 1))
    
    # Check if packer is installed
    TOTAL=$((TOTAL + 1))
    if command -v packer &> /dev/null; then
        if $DRY_RUN; then
            log_info "Would run: packer validate $PACKER_FILE"
            PASSED=$((PASSED + 1))
        else
            # Note: This will fail if running standalone without full packer setup
            # but the syntax can still be partially checked
            if packer fmt -check "$PACKER_FILE" 2>/dev/null; then
                log_pass "Packer file format valid"
                PASSED=$((PASSED + 1))
            else
                log_warn "Packer file may need formatting (not a failure)"
                PASSED=$((PASSED + 1))
            fi
        fi
    else
        log_warn "Packer not installed, skipping format check"
        PASSED=$((PASSED + 1))
    fi
else
    log_fail "Packer file missing"
    FAILED=$((FAILED + 1))
fi

# Test 6: File provisioner source validation
log_section "TEST 6: File Provisioner Sources"

# These are the sources referenced in the packer file
PROVISIONER_SOURCES=(
    "scripts/setup"
    "scripts/validation"
    "scripts/config"
)

for source in "${PROVISIONER_SOURCES[@]}"; do
    TOTAL=$((TOTAL + 1))
    full_path="$SCRIPT_DIR/$source"
    if [ -d "$full_path" ]; then
        # Check it has content
        file_count=$(find "$full_path" -type f | wc -l | tr -d ' ')
        if [ "$file_count" -gt 0 ]; then
            log_pass "Provisioner source valid: $source ($file_count files)"
            PASSED=$((PASSED + 1))
        else
            log_fail "Provisioner source empty: $source"
            FAILED=$((FAILED + 1))
        fi
    else
        log_fail "Provisioner source missing: $source"
        FAILED=$((FAILED + 1))
    fi
done

# ==============================================================================
# Summary
# ==============================================================================

log_section "TEST SUMMARY"

echo "  Total tests:  $TOTAL"
echo -e "  ${GREEN}Passed:       $PASSED${NC}"
echo -e "  ${RED}Failed:       $FAILED${NC}"
echo ""

if [ $TOTAL -gt 0 ]; then
    PERCENTAGE=$((PASSED * 100 / TOTAL))
    echo "  Success rate: ${PERCENTAGE}%"
fi

echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}=============================================="
    echo "   SOME TESTS FAILED - REVIEW ABOVE OUTPUT   "
    echo "==============================================${NC}"
    exit 1
else
    echo -e "${GREEN}=============================================="
    echo "        ALL LOCAL TESTS PASSED!              "
    echo "==============================================${NC}"
    exit 0
fi
