#!/bin/bash
# ==============================================================================
# 01-init.sh - Initialization Script
# ==============================================================================
# This script performs initial system setup and environment validation.
# It should be run first before other setup scripts.
# ==============================================================================

set -e

SCRIPT_NAME="01-init.sh"
LOG_FILE="/var/log/harness/setup.log"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    
    # Also log to file if available
    if [ -w "$(dirname $LOG_FILE)" ]; then
        echo "[$timestamp] [$SCRIPT_NAME] [$level] $message" >> "$LOG_FILE"
    fi
}

# ==============================================================================
# Main Execution
# ==============================================================================

log INFO "Starting initialization..."
log INFO "Running as user: $(whoami)"
log INFO "Current directory: $(pwd)"

# Check system information
log INFO "System information:"
log INFO "  - Hostname: $(hostname)"
log INFO "  - Kernel: $(uname -r)"
log INFO "  - Architecture: $(dpkg --print-architecture 2>/dev/null || uname -m)"
log INFO "  - OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"

# Check available disk space
log INFO "Disk space:"
df -h / | tail -1 | awk '{print "  - Available: " $4 " of " $2}'

# Check memory
log INFO "Memory:"
free -h | grep Mem | awk '{print "  - Total: " $2 ", Available: " $7}'

# Verify sudo access
if sudo -n true 2>/dev/null; then
    log INFO "Sudo access: available without password"
else
    log WARN "Sudo access: may require password"
fi

# Create marker file to indicate init completed
MARKER_DIR="/tmp/harness-setup"
mkdir -p "$MARKER_DIR"
echo "$(date)" > "$MARKER_DIR/01-init.done"

log INFO "Initialization complete"
echo ""
