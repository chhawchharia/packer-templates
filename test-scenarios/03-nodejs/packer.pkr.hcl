# Test 03: Node.js Development Environment
# Installs Node.js LTS with npm, yarn, and common tools

variable "node_version" {
  type        = string
  default     = "20"
  description = "Node.js major version"
}

variable "npm_packages" {
  type        = list(string)
  default     = ["typescript", "eslint", "prettier", "npm-check-updates"]
  description = "Global npm packages to install"
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
    "echo 'Node.js:' $(node --version)",
    "echo 'npm:' $(npm --version)",
    "echo 'Yarn:' $(yarn --version)",
    "npm list -g --depth=0",
    "echo '=== All done ==='"
  ]
}

/*
# Plugin settings for Test 03: Node.js
PLUGIN_MODE=build
PLUGIN_PACKER_FILE_PATH=test-scenarios/03-nodejs/packer.pkr.hcl
PLUGIN_IMAGE_NAME=nodejs-dev
PLUGIN_IMAGE_VERSION=v20.0.0
PLUGIN_TARGET_OS=linux
PLUGIN_TARGET_ARCH=amd64
PLUGIN_BASE_OS=ubuntu
PLUGIN_BASE_VERSION=22.04
PLUGIN_DEBUG=false

 */