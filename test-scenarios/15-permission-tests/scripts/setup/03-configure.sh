#!/bin/bash
# ==============================================================================
# 03-configure.sh - System Configuration Script
# ==============================================================================
# This script configures system settings for CI environments.
# It sets up directories, environment variables, and system limits.
# ==============================================================================

set -e

SCRIPT_NAME="03-configure.sh"
LOG_FILE="/var/log/harness/setup.log"
CONFIG_DIR="/etc/harness"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        INFO)  color=$GREEN ;;
        WARN)  color=$YELLOW ;;
        ERROR) color=$RED ;;
        *)     color=$NC ;;
    esac
    
    echo -e "${color}[$timestamp] [$SCRIPT_NAME] [$level] $message${NC}"
}

# ==============================================================================
# Main Execution
# ==============================================================================

log INFO "Starting system configuration..."

# Check dependencies
if [ ! -f /tmp/harness-setup/02-packages.done ]; then
    log WARN "Packages script may not have run, but continuing..."
fi

# Create work directories
log INFO "Creating work directories..."
WORK_DIRS=(
    "/opt/harness/workspace"
    "/opt/harness/cache"
    "/opt/harness/artifacts"
    "/opt/harness/tmp"
)

for dir in "${WORK_DIRS[@]}"; do
    sudo mkdir -p "$dir"
    sudo chmod 755 "$dir"
    log INFO "  Created: $dir"
done

# Set up environment variables
log INFO "Setting up environment variables..."
cat << 'ENVEOF' | sudo tee /etc/profile.d/harness.sh > /dev/null
# Harness CI Environment Variables
export HARNESS_HOME=/opt/harness
export HARNESS_WORKSPACE=/opt/harness/workspace
export HARNESS_CACHE=/opt/harness/cache
export HARNESS_ARTIFACTS=/opt/harness/artifacts

# Add to PATH if not already present
if [[ ":$PATH:" != *":/opt/harness/scripts:"* ]]; then
    export PATH="$PATH:/opt/harness/scripts"
fi
ENVEOF
sudo chmod 644 /etc/profile.d/harness.sh

# Source the new environment
source /etc/profile.d/harness.sh || true

# Verify configuration
log INFO "Verifying configuration..."
log INFO "  - HARNESS_HOME: ${HARNESS_HOME:-'(not set)'}"
log INFO "  - Work directories created successfully"

# Test write permissions
log INFO "Testing write permissions..."
if touch /opt/harness/workspace/.test_write 2>/dev/null; then
    rm -f /opt/harness/workspace/.test_write
    log INFO "  [OK] Workspace is writable"
else
    log WARN "  [WARN] Workspace may require sudo for writes"
fi

# Create marker file
echo "$(date)" > /tmp/harness-setup/03-configure.done

log INFO "System configuration complete"
echo ""
