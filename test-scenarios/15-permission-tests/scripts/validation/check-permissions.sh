#!/bin/bash
# ==============================================================================
# check-permissions.sh - Permission Validation Script
# ==============================================================================
# This script validates file and directory permissions to ensure there are
# no permission issues that would affect CI pipeline execution.
# ==============================================================================

set -e

SCRIPT_NAME="check-permissions.sh"
SCRIPT_DIR="${HARNESS_HOME:-/opt/harness}/scripts"
CONFIG_DIR="${CONFIG_DIR:-/etc/harness}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    WARN_COUNT=$((WARN_COUNT + 1))
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# ==============================================================================
# Test Functions
# ==============================================================================

test_directory_exists() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        log_pass "Directory exists: $dir ($description)"
    else
        log_fail "Directory missing: $dir ($description)"
    fi
}

test_directory_permissions() {
    local dir="$1"
    local expected_perms="$2"
    local description="$3"
    
    if [ ! -d "$dir" ]; then
        log_fail "Cannot check permissions - directory missing: $dir"
        return
    fi
    
    local actual_perms=$(stat -c '%a' "$dir" 2>/dev/null || stat -f '%Lp' "$dir" 2>/dev/null)
    
    if [ "$actual_perms" = "$expected_perms" ]; then
        log_pass "Directory permissions correct: $dir ($actual_perms)"
    else
        log_warn "Directory permissions differ: $dir (expected $expected_perms, got $actual_perms)"
    fi
}

test_file_executable() {
    local file="$1"
    local description="$2"
    
    if [ ! -f "$file" ]; then
        log_warn "File not found: $file ($description)"
        return
    fi
    
    if [ -x "$file" ]; then
        log_pass "File is executable: $file"
    else
        log_fail "File is NOT executable: $file"
    fi
}

test_script_execution() {
    local script="$1"
    local description="$2"
    
    if [ ! -f "$script" ]; then
        log_warn "Script not found: $script ($description)"
        return
    fi
    
    if [ ! -x "$script" ]; then
        log_fail "Script not executable: $script"
        return
    fi
    
    # Try to execute with --help or similar safe option if available
    # Otherwise just check if it's parseable by bash
    if bash -n "$script" 2>/dev/null; then
        log_pass "Script syntax valid: $script"
    else
        log_warn "Script may have syntax issues: $script"
    fi
}

test_config_readable() {
    local file="$1"
    local description="$2"
    
    if [ ! -f "$file" ]; then
        log_warn "Config file not found: $file ($description)"
        return
    fi
    
    if [ -r "$file" ]; then
        log_pass "Config file readable: $file"
    else
        log_fail "Config file NOT readable: $file"
    fi
}

test_write_permissions() {
    local dir="$1"
    local description="$2"
    local test_file="$dir/.permission_test_$$"
    
    if [ ! -d "$dir" ]; then
        log_warn "Cannot test write - directory missing: $dir"
        return
    fi
    
    if touch "$test_file" 2>/dev/null; then
        rm -f "$test_file"
        log_pass "Directory writable: $dir ($description)"
    else
        log_warn "Directory not writable without sudo: $dir ($description)"
    fi
}

# ==============================================================================
# Main Execution
# ==============================================================================

echo ""
echo "=============================================="
echo "       PERMISSION VALIDATION REPORT          "
echo "=============================================="
echo ""

# Test 1: Core directories
log_info "Testing core directories..."
test_directory_exists "$SCRIPT_DIR" "Scripts directory"
test_directory_exists "$SCRIPT_DIR/setup" "Setup scripts"
test_directory_exists "$SCRIPT_DIR/validation" "Validation scripts"
test_directory_exists "$CONFIG_DIR" "Config directory"
test_directory_exists "/opt/harness" "Harness home"
test_directory_exists "/var/log/harness" "Log directory"

echo ""

# Test 2: Directory permissions
log_info "Testing directory permissions..."
test_directory_permissions "$SCRIPT_DIR" "755" "Scripts should be 755"
test_directory_permissions "$CONFIG_DIR" "755" "Config should be 755"
test_directory_permissions "/var/log/harness" "755" "Logs should be 755"

echo ""

# Test 3: Script executability
log_info "Testing script executability..."
if [ -d "$SCRIPT_DIR/setup" ]; then
    for script in "$SCRIPT_DIR/setup"/*.sh; do
        if [ -f "$script" ]; then
            test_file_executable "$script" "Setup script"
        fi
    done
fi

if [ -d "$SCRIPT_DIR/validation" ]; then
    for script in "$SCRIPT_DIR/validation"/*.sh; do
        if [ -f "$script" ]; then
            test_file_executable "$script" "Validation script"
        fi
    done
fi

echo ""

# Test 4: Script syntax validation
log_info "Testing script syntax..."
if [ -d "$SCRIPT_DIR/setup" ]; then
    for script in "$SCRIPT_DIR/setup"/*.sh; do
        if [ -f "$script" ]; then
            test_script_execution "$script" "Setup script"
        fi
    done
fi

echo ""

# Test 5: Config file readability
log_info "Testing config file readability..."
if [ -d "$CONFIG_DIR" ]; then
    for config in "$CONFIG_DIR"/*; do
        if [ -f "$config" ]; then
            test_config_readable "$config" "Config file"
        fi
    done
fi

echo ""

# Test 6: Write permissions for work directories
log_info "Testing write permissions..."
test_write_permissions "/tmp" "Temp directory"
test_write_permissions "/opt/harness/workspace" "Workspace"
test_write_permissions "/opt/harness/cache" "Cache"

echo ""

# ==============================================================================
# Summary
# ==============================================================================

echo "=============================================="
echo "                  SUMMARY                     "
echo "=============================================="
echo -e "  ${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "  ${RED}Failed: $FAIL_COUNT${NC}"
echo -e "  ${YELLOW}Warnings: $WARN_COUNT${NC}"
echo "=============================================="

if [ $FAIL_COUNT -gt 0 ]; then
    echo -e "\n${RED}Permission validation FAILED${NC}"
    exit 1
else
    echo -e "\n${GREEN}Permission validation PASSED${NC}"
    exit 0
fi
