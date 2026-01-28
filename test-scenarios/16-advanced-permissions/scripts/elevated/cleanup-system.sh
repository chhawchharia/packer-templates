#!/bin/bash
# ==============================================================================
# cleanup-system.sh - System Cleanup Script (Requires Root)
# ==============================================================================
# This script performs system-level cleanup operations.
# It must be run as root.
# ==============================================================================

set -e

SCRIPT_NAME="cleanup-system.sh"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$SCRIPT_NAME] $1"
}

# Verify running as root
if [ "$(id -u)" -ne 0 ]; then
    log "ERROR: This script must be run as root"
    exit 1
fi

log "Starting system cleanup..."

# Clean package cache
clean_packages() {
    log "Cleaning package cache..."
    apt-get clean -y 2>/dev/null || true
    apt-get autoremove -y 2>/dev/null || true
    rm -rf /var/lib/apt/lists/*
    log "Package cache cleaned"
}

# Clean temp files
clean_temp() {
    log "Cleaning temp files..."
    rm -rf /tmp/* 2>/dev/null || true
    rm -rf /var/tmp/* 2>/dev/null || true
    log "Temp files cleaned"
}

# Clean logs
clean_logs() {
    log "Cleaning old logs..."
    find /var/log -type f -name "*.gz" -delete 2>/dev/null || true
    find /var/log -type f -name "*.old" -delete 2>/dev/null || true
    find /var/log -type f -name "*.[0-9]" -delete 2>/dev/null || true
    
    # Truncate current logs
    for logfile in /var/log/*.log; do
        if [ -f "$logfile" ]; then
            cat /dev/null > "$logfile" 2>/dev/null || true
        fi
    done
    
    log "Logs cleaned"
}

# Main
main() {
    clean_packages
    clean_temp
    clean_logs
    
    log "System cleanup complete"
    
    # Show space saved
    log "Disk usage after cleanup:"
    df -h /
}

main "$@"
