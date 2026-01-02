# Test 03: Node.js Development Environment
# Installs Node.js LTS with npm, yarn, and common tools
# Compatible with Ubuntu 22.04 and 24.04

variable "node_version" {
  type        = string
  default     = "20"
  description = "Node.js major version (18, 20, 21, 22)"
}

variable "npm_packages" {
  type        = list(string)
  default     = ["typescript", "eslint", "prettier", "npm-check-updates"]
  description = "Global npm packages to install"
}

# Install prerequisites
provisioner "shell" {
  inline = [
    "echo '=== Installing prerequisites ==='",
    "export DEBIAN_FRONTEND=noninteractive",
    "sudo apt-get update",
    "sudo apt-get install -y curl ca-certificates gnupg",
    "echo '=== Prerequisites installed ==='"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Installing Node.js ${var.node_version} ==='",
    "export DEBIAN_FRONTEND=noninteractive",
    
    "# Install Node.js from NodeSource",
    "curl -fsSL https://deb.nodesource.com/setup_${var.node_version}.x | sudo -E bash -",
    "sudo apt-get install -y nodejs",
    
    "# Verify installation",
    "node --version",
    "npm --version",
    
    "echo '=== Node.js installed ==='"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Installing Yarn ==='",
    
    "# Install Yarn via npm",
    "sudo npm install -g yarn",
    "yarn --version",
    
    "echo '=== Yarn installed ==='"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Installing global npm packages ==='",
    
    "# Install specified packages",
    "sudo npm install -g ${join(" ", var.npm_packages)}",
    
    "# Verify installations",
    "tsc --version || echo 'TypeScript not installed'",
    "eslint --version || echo 'ESLint not installed'",
    
    "echo '=== Global packages installed ==='"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Final verification ==='",
    "echo 'Node.js:' $$(node --version)",
    "echo 'npm:' $$(npm --version)",
    "echo 'Yarn:' $$(yarn --version)",
    "npm list -g --depth=0",
    "echo '=== All done ==='"
  ]
}

