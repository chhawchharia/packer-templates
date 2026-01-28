#!/bin/bash
# ==============================================================================
# agent-start.sh - Agent Startup Script
# ==============================================================================
# This script starts the Harness agent service.
# It runs as the service user with limited permissions.
# ==============================================================================

set -e

SCRIPT_NAME="agent-start.sh"
SECURE_DIR="${HARNESS_SECURE_DIR:-/opt/harness-secure}"
PID_FILE="$SECURE_DIR/run/agent.pid"
LOG_FILE="$SECURE_DIR/logs/agent.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$SCRIPT_NAME] $1" | tee -a "$LOG_FILE"
}

# Pre-flight checks
check_permissions() {
    log "Checking permissions..."
    
    # Verify we can write to required directories
    local dirs=("$SECURE_DIR/run" "$SECURE_DIR/logs")
    for dir in "${dirs[@]}"; do
        if [ ! -w "$dir" ]; then
            log "ERROR: Cannot write to $dir"
            return 1
        fi
    done
    
    log "Permission checks passed"
    return 0
}

check_already_running() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            log "Agent already running (PID: $pid)"
            return 0
        else
            log "Stale PID file found, removing..."
            rm -f "$PID_FILE"
        fi
    fi
    return 1
}

# Main startup
main() {
    log "Starting Harness Agent..."
    log "Running as: $(whoami)"
    log "Secure directory: $SECURE_DIR"
    
    # Perform checks
    check_permissions || exit 1
    
    if check_already_running; then
        log "Agent is already running, exiting"
        exit 0
    fi
    
    # Create PID file
    echo $$ > "$PID_FILE"
    log "PID file created: $PID_FILE"
    
    # In a real scenario, this would start the actual agent
    log "Agent startup complete"
    
    # Cleanup PID on exit
    trap 'rm -f "$PID_FILE"' EXIT
    
    log "Agent ready for operation"
}

main "$@"
