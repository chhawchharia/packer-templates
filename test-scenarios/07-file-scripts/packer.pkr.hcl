# Test 07: File Provisioner with Scripts
# Tests file provisioner with external script files
# Relative paths are relative to the packer file directory

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
