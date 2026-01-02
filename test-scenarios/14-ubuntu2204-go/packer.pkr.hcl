# Test 14: Ubuntu 22.04 Go Development
# Tests Ubuntu 22.04 LTS with Go installation
# Useful for customers who need older LTS version

variable "go_version" {
  type        = string
  default     = "1.22.0"
  description = "Go version to install"
}

# Install prerequisites
provisioner "shell" {
  inline = [
    "echo '=== Installing prerequisites ==='",
    "export DEBIAN_FRONTEND=noninteractive",
    
    "sudo apt-get update",
    "sudo apt-get install -y curl wget git make gcc g++ unzip tar jq",
    
    "echo '=== Prerequisites installed ==='"
  ]
}

# Install Go
provisioner "shell" {
  inline = [
    "echo '=== Installing Go ${var.go_version} ==='",
    
    "curl -fsSL https://go.dev/dl/go${var.go_version}.linux-amd64.tar.gz -o /tmp/go.tar.gz",
    "sudo rm -rf /usr/local/go",
    "sudo tar -C /usr/local -xzf /tmp/go.tar.gz",
    "rm /tmp/go.tar.gz",
    
    "# Add Go to PATH",
    "echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/go.sh",
    "echo 'export GOPATH=$HOME/go' | sudo tee -a /etc/profile.d/go.sh",
    "echo 'export PATH=$PATH:$GOPATH/bin' | sudo tee -a /etc/profile.d/go.sh",
    
    "/usr/local/go/bin/go version",
    
    "echo '=== Go installed ==='"
  ]
}

# Install golangci-lint
provisioner "shell" {
  inline = [
    "echo '=== Installing golangci-lint ==='",
    
    "curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin v1.55.2",
    
    "/usr/local/bin/golangci-lint --version",
    
    "echo '=== golangci-lint installed ==='"
  ]
}

# Verification
provisioner "shell" {
  inline = [
    "echo '=== Verification ==='",
    "echo 'OS Info:'",
    "cat /etc/os-release | grep -E '^(NAME|VERSION)='",
    "echo ''",
    "echo 'Go:'",
    "/usr/local/go/bin/go version",
    "echo ''",
    "echo 'golangci-lint:'",
    "/usr/local/bin/golangci-lint --version",
    "echo ''",
    "echo 'Build Tools:'",
    "gcc --version | head -1",
    "git --version",
    "make --version | head -1",
    "echo '=== All done ==='"
  ]
}

