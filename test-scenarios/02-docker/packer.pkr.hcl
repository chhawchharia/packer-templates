# Test 02: Docker Installation
# Complete Docker CE installation with Docker Compose

variable "docker_version" {
  type        = string
  default     = "latest"
  description = "Docker version to install"
}

provisioner "shell" {
  inline = [
    "echo '=== Installing Docker ==='",
    "export DEBIAN_FRONTEND=noninteractive",
    
    "# Remove old versions",
    "sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true",
    
    "# Install prerequisites",
    "sudo apt-get update",
    "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
    
    "# Add Docker GPG key",
    "sudo install -m 0755 -d /etc/apt/keyrings",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg",
    "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
    
    "# Add Docker repository - use single line to avoid HCL escaping issues",
    "ARCH=`dpkg --print-architecture` && RELEASE=`lsb_release -cs` && echo \"deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $RELEASE stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
    
    "# Install Docker (with retry for transient 404s)",
    "sudo apt-get update --fix-missing",
    "sudo apt-get install -y --fix-missing docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || (sleep 5 && sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)",
    
    "# Enable Docker service",
    "sudo systemctl enable docker",
    "sudo systemctl enable containerd",
    
    "# Verify installation",
    "docker --version",
    "sudo docker compose version",
    
    "echo '=== Docker installation complete ==='"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Configuring Docker daemon ==='",
    
    "# Create docker config directory",
    "sudo mkdir -p /etc/docker",
    
    "# Configure Docker daemon with optimal settings",
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

provisioner "shell" {
  inline = [
    "echo '=== Verification ==='",
    "docker --version",
    "sudo docker info --format '{{.Driver}}'",
    "echo '=== All done ==='"
  ]
}

