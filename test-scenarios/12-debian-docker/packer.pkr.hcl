# Test 12: Debian 12 Docker Installation
# Tests Debian distribution with Docker installation
# Debian 12 (bookworm) on AMD64

# Install Docker for Debian
provisioner "shell" {
  inline = [
    "echo '=== Installing Docker on Debian ==='",
    "export DEBIAN_FRONTEND=noninteractive",
    
    "# Show OS info",
    "cat /etc/os-release | head -5",
    
    "# Remove old versions",
    "sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true",
    
    "# Install prerequisites",
    "sudo apt-get update",
    "sudo apt-get install -y ca-certificates curl gnupg",
    
    "# Add Docker GPG key for Debian",
    "sudo install -m 0755 -d /etc/apt/keyrings",
    "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg",
    "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
    
    "# Add Docker repository for Debian",
    "ARCH=`dpkg --print-architecture`",
    ". /etc/os-release",
    "echo \"deb [arch=$$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $$VERSION_CODENAME stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
    
    "# Install Docker (with retry for transient 404s)",
    "sudo apt-get update --fix-missing",
    "sudo apt-get install -y --fix-missing docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || (sleep 5 && sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)",
    
    "# Enable Docker service",
    "sudo systemctl enable docker",
    "sudo systemctl enable containerd",
    
    "echo '=== Docker installation complete ==='"
  ]
}

# Install common build tools
provisioner "shell" {
  inline = [
    "echo '=== Installing build tools ==='",
    "export DEBIAN_FRONTEND=noninteractive",
    
    "sudo apt-get install -y build-essential git make curl wget jq",
    
    "echo '=== Build tools installed ==='"
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
    "echo ''",
    "echo 'Build Tools:'",
    "gcc --version | head -1",
    "git --version",
    "echo '=== All done ==='"
  ]
}

