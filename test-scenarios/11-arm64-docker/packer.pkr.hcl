# Test 11: ARM64 Docker Installation
# Tests ARM64 architecture with Docker installation
# Ubuntu 24.04 on ARM64 (t2a-standard-4 machine type)

variable "docker_compose_version" {
  type        = string
  default     = "v2.24.0"
  description = "Docker Compose standalone version"
}

# Install Docker for ARM64
provisioner "shell" {
  inline = [
    "echo '=== Installing Docker on ARM64 ==='",
    "export DEBIAN_FRONTEND=noninteractive",
    
    "# Verify architecture",
    "ARCH=$(dpkg --print-architecture)",
    "echo \"Architecture: $ARCH\"",
    "if [ \"$ARCH\" != \"arm64\" ]; then",
    "  echo 'Warning: Expected arm64 but got $ARCH'",
    "fi",
    
    "# Remove old versions",
    "sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true",
    
    "# Install prerequisites",
    "sudo apt-get update",
    "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
    
    "# Add Docker GPG key",
    "sudo install -m 0755 -d /etc/apt/keyrings",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg",
    "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
    
    "# Add Docker repository (ARM64)",
    "echo \"deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
    
    "# Install Docker",
    "sudo apt-get update",
    "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
    
    "# Enable Docker service",
    "sudo systemctl enable docker",
    "sudo systemctl enable containerd",
    
    "echo '=== Docker installation complete ==='"
  ]
}

# Configure Docker daemon for ARM64
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
    "  \"storage-driver\": \"overlay2\",",
    "  \"live-restore\": true",
    "}",
    "DAEMONJSON",
    
    "echo '=== Docker daemon configured ==='"
  ]
}

# Verification
provisioner "shell" {
  inline = [
    "echo '=== Verification ==='",
    "echo 'Architecture:' $(dpkg --print-architecture)",
    "docker --version",
    "sudo docker compose version",
    "sudo docker info --format '{{.Architecture}}'",
    "echo '=== All done ==='"
  ]
}

