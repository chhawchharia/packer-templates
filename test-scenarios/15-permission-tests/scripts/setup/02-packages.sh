#!/bin/bash
# ==============================================================================
# 02-packages.sh - Package Installation Script
# ==============================================================================
# This script installs essential packages for CI environments.
# It includes retry logic for handling transient package manager issues.
# ==============================================================================

set -e

SCRIPT_NAME="02-packages.sh"
LOG_FILE="/var/log/harness/setup.log"

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

# Retry function for package operations
retry_command() {
    local max_attempts=$1
    shift
    local command="$@"
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log INFO "Attempt $attempt of $max_attempts: $command"
        if eval "$command"; then
            return 0
        fi
        log WARN "Command failed, waiting before retry..."
        sleep 5
        attempt=$((attempt + 1))
    done
    
    log ERROR "Command failed after $max_attempts attempts"
    return 1
}

# ==============================================================================
# Main Execution
# ==============================================================================

log INFO "Starting package installation..."

# Check if init was completed
if [ ! -f /tmp/harness-setup/01-init.done ]; then
    log WARN "Init script may not have run, but continuing..."
fi

# Update package lists
log INFO "Updating package lists..."
export DEBIAN_FRONTEND=noninteractive
retry_command 3 "sudo apt-get update -qq"

# Define packages to install
PACKAGES=(
    "curl"
    "wget"
    "git"
    "jq"
    "tree"
    "unzip"
    "zip"
    "ca-certificates"
)

log INFO "Installing packages: ${PACKAGES[*]}"

# Install packages with retry
retry_command 3 "sudo apt-get install -y -qq ${PACKAGES[*]}"

# Verify installations
log INFO "Verifying package installations..."
FAILED=0

for pkg in "${PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $pkg "; then
        log INFO "  [OK] $pkg installed"
    else
        log ERROR "  [FAIL] $pkg not found"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    log ERROR "Some packages failed to install"
    exit 1
fi

# Create marker file
echo "$(date)" > /tmp/harness-setup/02-packages.done

log INFO "Package installation complete"
echo ""
