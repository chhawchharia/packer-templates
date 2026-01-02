# Test 06: Multi-Tool CI Environment
# Comprehensive CI image with Docker, Go, kubectl, Helm, and common tools

variable "go_version" {
  type        = string
  default     = "1.22.0"
  description = "Go version"
}

variable "kubectl_version" {
  type        = string
  default     = "1.29"
  description = "kubectl major.minor version"
}

variable "system_packages" {
  type        = list(string)
  default     = ["git", "make", "gcc", "g++", "curl", "wget", "jq", "zip", "unzip", "tree"]
  description = "System packages to install"
}

# System packages
provisioner "shell" {
  inline = [
    "echo '=== Installing system packages ==='",
    "export DEBIAN_FRONTEND=noninteractive",
    "sudo apt-get update",
    "sudo apt-get install -y ${join(" ", var.system_packages)}",
    "echo '=== System packages installed ==='"
  ]
}

# Go
provisioner "shell" {
  inline = [
    "echo '=== Installing Go ${var.go_version} ==='",

    "curl -fsSL https://go.dev/dl/go${var.go_version}.linux-amd64.tar.gz -o /tmp/go.tar.gz",
    "sudo rm -rf /usr/local/go",
    "sudo tar -C /usr/local -xzf /tmp/go.tar.gz",
    "rm /tmp/go.tar.gz",

    "echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/go.sh",
    "echo 'export GOPATH=$HOME/go' | sudo tee -a /etc/profile.d/go.sh",
    "echo 'export PATH=$PATH:$GOPATH/bin' | sudo tee -a /etc/profile.d/go.sh",

    "/usr/local/go/bin/go version",
    "echo '=== Go installed ==='"
  ]
}

# Docker
provisioner "shell" {
  inline = [
    "echo '=== Installing Docker ==='",

    "sudo apt-get install -y ca-certificates curl gnupg",
    "sudo install -m 0755 -d /etc/apt/keyrings",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg",
    "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
    "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
    "sudo apt-get update",
    "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
    "sudo systemctl enable docker",

    "docker --version",
    "echo '=== Docker installed ==='"
  ]
}

# kubectl
provisioner "shell" {
  inline = [
    "echo '=== Installing kubectl ==='",

    "curl -fsSL https://pkgs.k8s.io/core:/stable:/v${var.kubectl_version}/deb/Release.key | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
    "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${var.kubectl_version}/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
    "sudo apt-get update",
    "sudo apt-get install -y kubectl",

    "kubectl version --client",
    "echo '=== kubectl installed ==='"
  ]
}

# Helm
provisioner "shell" {
  inline = [
    "echo '=== Installing Helm ==='",

    "curl https://baltocdn.com/helm/signing.asc | gpg --batch --yes --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null",
    "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main\" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list",
    "sudo apt-get update",
    "sudo apt-get install -y helm",

    "helm version",
    "echo '=== Helm installed ==='"
  ]
}

# Verification
provisioner "shell" {
  inline = [
    "echo '=========================================='",
    "echo '=== Multi-Tool CI Environment Ready ==='",
    "echo '=========================================='",
    "echo ''",
    "echo 'Installed versions:'",
    "echo '-------------------'",
    "/usr/local/go/bin/go version",
    "docker --version",
    "kubectl version --client --short 2>/dev/null || kubectl version --client | head -1",
    "helm version --short",
    "git --version",
    "make --version | head -1",
    "echo ''",
    "echo 'Disk usage:'",
    "df -h /",
    "echo '=========================================='",
  ]
}

/*
# Plugin settings for Test 06: Multi-Tool CI
PLUGIN_MODE=build
PLUGIN_PACKER_FILE_PATH=test-scenarios/06-multi-tool/packer.pkr.hcl
PLUGIN_IMAGE_NAME=multi-tool-ci
PLUGIN_IMAGE_VERSION=v1.0.0
PLUGIN_TARGET_OS=linux
PLUGIN_TARGET_ARCH=amd64
PLUGIN_BASE_OS=ubuntu
PLUGIN_BASE_VERSION=22.04
PLUGIN_DEBUG=true


 */