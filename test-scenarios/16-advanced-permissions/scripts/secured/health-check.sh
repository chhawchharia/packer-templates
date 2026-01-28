#!/bin/bash
# ==============================================================================
# health-check.sh - Service Health Check Script
# ==============================================================================
# This script is owned by the service user and runs health checks.
# It should be executable by the service user only.
# ==============================================================================

set -e

SCRIPT_NAME="health-check.sh"
SERVICE_NAME="harness-agent"
CHECK_INTERVAL=${CHECK_INTERVAL:-10}

# Output formatting
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$SCRIPT_NAME] $1"
}

# Health check functions
check_process() {
    log "Checking process..."
    if pgrep -x "$SERVICE_NAME" > /dev/null 2>&1; then
        log "  Process: RUNNING"
        return 0
    else
        log "  Process: NOT RUNNING"
        return 1
    fi
}

check_disk() {
    log "Checking disk space..."
    local usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    if [ "$usage" -lt 90 ]; then
        log "  Disk usage: ${usage}% [OK]"
        return 0
    else
        log "  Disk usage: ${usage}% [WARNING]"
        return 1
    fi
}

check_memory() {
    log "Checking memory..."
    local available=$(free -m | awk 'NR==2 {printf "%.0f", $7/$2*100}')
    if [ "$available" -gt 10 ]; then
        log "  Memory available: ${available}% [OK]"
        return 0
    else
        log "  Memory available: ${available}% [WARNING]"
        return 1
    fi
}

# Main
main() {
    log "Starting health check..."
    log "Running as user: $(whoami)"
    
    local exit_code=0
    
    # Run checks (don't fail script on check failure)
    check_disk || exit_code=$((exit_code + 1))
    check_memory || exit_code=$((exit_code + 1))
    
    if [ $exit_code -eq 0 ]; then
        log "Health check PASSED"
    else
        log "Health check completed with $exit_code warnings"
    fi
    
    return 0
}

main "$@"
