#!/bin/bash
# ==============================================================================
# root-setup.sh - Root-level System Setup
# ==============================================================================
# This script requires root privileges to run.
# It performs system-level configuration that cannot be done by regular users.
# ==============================================================================

set -e

SCRIPT_NAME="root-setup.sh"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$SCRIPT_NAME] $1"
}

# Verify running as root
if [ "$(id -u)" -ne 0 ]; then
    log "ERROR: This script must be run as root"
    exit 1
fi

log "Starting root-level setup..."
log "Running as: $(whoami)"

# System tuning
configure_sysctl() {
    log "Configuring system parameters..."
    
    # Create sysctl config for CI workloads
    cat << 'SYSCTL' | tee /etc/sysctl.d/99-harness-ci.conf > /dev/null
# Harness CI optimizations
# Increase file descriptor limits
fs.file-max = 2097152

# Network optimizations
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535

# Memory optimizations
vm.swappiness = 10
vm.dirty_ratio = 60
vm.dirty_background_ratio = 2
SYSCTL
    
    log "Sysctl configuration written"
}

configure_limits() {
    log "Configuring system limits..."
    
    # Create limits config
    cat << 'LIMITS' | tee /etc/security/limits.d/99-harness.conf > /dev/null
# Harness CI limits
*               soft    nofile          65535
*               hard    nofile          65535
*               soft    nproc           65535
*               hard    nproc           65535
LIMITS
    
    log "Limits configuration written"
}

# Main
main() {
    configure_sysctl
    configure_limits
    
    log "Root-level setup complete"
}

main "$@"
