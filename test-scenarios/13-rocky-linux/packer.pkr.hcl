# Test 13: Rocky Linux 9 CI Environment
# Tests RHEL-compatible distribution with Docker and development tools
# Rocky Linux 9 on AMD64
# Note: Uses dnf/yum package manager instead of apt

# Install prerequisites and Docker
provisioner "shell" {
  inline = [
    "echo '=== Installing Docker on Rocky Linux ==='",
    
    "# Show OS info",
    "cat /etc/os-release | head -5",
    
    "# Remove old versions",
    "sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine 2>/dev/null || true",
    
    "# Install prerequisites",
    "sudo dnf install -y dnf-plugins-core",
    
    "# Add Docker repository for CentOS/RHEL",
    "sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
    
    "# Install Docker",
    "sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
    
    "# Enable and start Docker service",
    "sudo systemctl enable docker",
    "sudo systemctl start docker",
    
    "echo '=== Docker installation complete ==='"
  ]
}

# Install development tools
provisioner "shell" {
  inline = [
    "echo '=== Installing development tools ==='",
    
    "# Install Development Tools group",
    "sudo dnf groupinstall -y 'Development Tools'",
    
    "# Install additional tools",
    "sudo dnf install -y git curl wget jq unzip tar",
    
    "echo '=== Development tools installed ==='"
  ]
}

# Install Go
provisioner "shell" {
  inline = [
    "echo '=== Installing Go ==='",
    
    "GO_VERSION=1.22.0",
    "curl -fsSL https://go.dev/dl/go$$GO_VERSION.linux-amd64.tar.gz -o /tmp/go.tar.gz",
    "sudo rm -rf /usr/local/go",
    "sudo tar -C /usr/local -xzf /tmp/go.tar.gz",
    "rm /tmp/go.tar.gz",
    
    "# Add to PATH",
    "echo 'export PATH=$$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/go.sh",
    "echo 'export GOPATH=$$HOME/go' | sudo tee -a /etc/profile.d/go.sh",
    "echo 'export PATH=$$PATH:$$GOPATH/bin' | sudo tee -a /etc/profile.d/go.sh",
    
    "/usr/local/go/bin/go version",
    
    "echo '=== Go installed ==='"
  ]
}

# Configure Docker daemon
provisioner "shell" {
  inline = [
    "echo '=== Configuring Docker daemon ==='",
    
    "sudo mkdir -p /etc/docker",
    
    "cat << 'DAEMONJSON' | sudo tee /etc/docker/daemon.json",
    "{",
    "  \"log-driver\": \"json-file\",",
    "  \"log-opts\": {",
    "    \"max-size\": \"10m\",",
    "    \"max-file\": \"3\"",
    "  },",
    "  \"storage-driver\": \"overlay2\"",
    "}",
    "DAEMONJSON",
    
    "sudo systemctl restart docker",
    
    "echo '=== Docker daemon configured ==='"
  ]
}

# Verification
provisioner "shell" {
  inline = [
    "echo '=== Verification ==='",
    "echo 'OS Info:'",
    "cat /etc/os-release | grep -E '^(NAME|VERSION)='",
    "echo ''",
    "echo 'Docker:'",
    "docker --version",
    "sudo docker compose version",
    "sudo docker info --format '{{.Driver}}'",
    "echo ''",
    "echo 'Go:'",
    "/usr/local/go/bin/go version",
    "echo ''",
    "echo 'Build Tools:'",
    "gcc --version | head -1",
    "git --version",
    "echo '=== All done ==='"
  ]
}

