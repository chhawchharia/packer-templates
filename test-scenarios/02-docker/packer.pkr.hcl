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

    "# Add Docker repository",
    "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",

    "# Install Docker",
    "sudo apt-get update",
    "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",

    "# Enable Docker service",
    "sudo systemctl enable docker",
    "sudo systemctl enable containerd",

    "# Verify installation",
    "docker --version",
    "docker compose version",

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
    "docker info --format '{{.Driver}}'",
    "echo '=== All done ==='"
  ]
}


# # Plugin settings for Test 02: Docker
# PLUGIN_MODE=build
# PLUGIN_PACKER_FILE_PATH=test-scenarios/02-docker/packer.pkr.hcl
# PLUGIN_IMAGE_NAME=docker-ci
# PLUGIN_IMAGE_VERSION=v1.0.0
# PLUGIN_TARGET_OS=linux
# PLUGIN_TARGET_ARCH=amd64
# PLUGIN_BASE_OS=ubuntu
# PLUGIN_BASE_VERSION=22.04
# PLUGIN_DEBUG=false
