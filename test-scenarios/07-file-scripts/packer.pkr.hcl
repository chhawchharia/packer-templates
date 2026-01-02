# Test 07: File Provisioner with Scripts
# Tests file provisioner with external script files

variable "app_name" {
  type        = string
  default     = "myapp"
  description = "Application name"
}

variable "app_port" {
  type        = number
  default     = 8080
  description = "Application port"
}

# Copy setup script
provisioner "file" {
  source      = "scripts/setup.sh"
  destination = "/tmp/setup.sh"
}

# Copy config file
provisioner "file" {
  source      = "scripts/config.yaml"
  destination = "/tmp/config.yaml"
}

# Copy application directory
provisioner "file" {
  source      = "scripts/app/"
  destination = "/tmp/app"
}

# Run setup script
provisioner "shell" {
  inline = [
    "echo '=== Running setup script ==='",
    "chmod +x /tmp/setup.sh",
    "/tmp/setup.sh '${var.app_name}' '${var.app_port}'",
    "echo '=== Setup complete ==='"
  ]
}

# Verify installation
provisioner "shell" {
  inline = [
    "echo '=== Verification ==='",
    "ls -la /opt/${var.app_name}/",
    "cat /opt/${var.app_name}/config.yaml",
    "echo '=== All done ==='"
  ]
}

/*
# Plugin settings for Test 07: File Scripts
PLUGIN_MODE=build
PLUGIN_PACKER_FILE_PATH=test-scenarios/07-file-scripts/packer.pkr.hcl
PLUGIN_IMAGE_NAME=file-scripts-test
PLUGIN_IMAGE_VERSION=v1.0.0
PLUGIN_TARGET_OS=linux
PLUGIN_TARGET_ARCH=amd64
PLUGIN_BASE_OS=ubuntu
PLUGIN_BASE_VERSION=22.04
PLUGIN_DEBUG=false

 */