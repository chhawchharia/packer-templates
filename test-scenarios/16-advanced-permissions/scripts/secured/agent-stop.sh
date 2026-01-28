#!/bin/bash
# ==============================================================================
# agent-stop.sh - Agent Shutdown Script
# ==============================================================================
# This script stops the Harness agent service gracefully.
# ==============================================================================

set -e

SCRIPT_NAME="agent-stop.sh"
SECURE_DIR="${HARNESS_SECURE_DIR:-/opt/harness-secure}"
PID_FILE="$SECURE_DIR/run/agent.pid"
LOG_FILE="$SECURE_DIR/logs/agent.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$SCRIPT_NAME] $1" | tee -a "$LOG_FILE"
}

main() {
    log "Stopping Harness Agent..."
    
    if [ ! -f "$PID_FILE" ]; then
        log "PID file not found, agent may not be running"
        exit 0
    fi
    
    local pid=$(cat "$PID_FILE")
    
    if kill -0 "$pid" 2>/dev/null; then
        log "Sending SIGTERM to PID $pid..."
        kill -TERM "$pid"
        
        # Wait for graceful shutdown
        local count=0
        while kill -0 "$pid" 2>/dev/null && [ $count -lt 30 ]; do
            sleep 1
            count=$((count + 1))
        done
        
        if kill -0 "$pid" 2>/dev/null; then
            log "Process did not stop gracefully, sending SIGKILL..."
            kill -KILL "$pid"
        fi
        
        log "Agent stopped"
    else
        log "Process $pid not running"
    fi
    
    rm -f "$PID_FILE"
    log "Cleanup complete"
}

main "$@"
