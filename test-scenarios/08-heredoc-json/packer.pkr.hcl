# Test 08: Heredoc and JSON Configuration
# Tests heredocs with nested braces, JSON, and bash constructs
# Note: Use $$ to escape literal $ in Packer HCL strings

variable "app_config" {
  type        = string
  default     = "production"
  description = "Application configuration environment"
}

# Create JSON config
provisioner "shell" {
  inline = [
    "echo '=== Creating JSON configuration ==='",
    "sudo mkdir -p /etc/myapp",
    "cat > /tmp/app-config.json << 'JSONEOF'",
    "{",
    "  \"application\": {",
    "    \"name\": \"myapp\",",
    "    \"version\": \"1.0.0\",",
    "    \"environment\": \"${var.app_config}\"",
    "  },",
    "  \"server\": {",
    "    \"host\": \"0.0.0.0\",",
    "    \"port\": 8080",
    "  },",
    "  \"features\": {",
    "    \"cache\": true,",
    "    \"metrics\": true",
    "  }",
    "}",
    "JSONEOF",
    "sudo mv /tmp/app-config.json /etc/myapp/config.json",
    "echo 'JSON config created'"
  ]
}

# Create bash script with loops - ALL bash $ must be escaped as $$
provisioner "shell" {
  inline = [
    "echo '=== Creating bash scripts ==='",
    "cat > /tmp/check-services.sh << 'BASHEOF'",
    "#!/bin/bash",
    "set -e",
    "SERVICES=(\"ssh\" \"cron\")",
    "echo \"Checking services...\"",
    "for svc in \"$${SERVICES[@]}\"; do",
    "    if systemctl is-active --quiet \"$$svc\" 2>/dev/null; then",
    "        echo \"OK: $$svc is running\"",
    "    else",
    "        echo \"SKIP: $$svc is not running\"",
    "    fi",
    "done",
    "DISK=`df -h / | awk 'NR==2 {print $$5}' | tr -d '%'`",
    "echo \"Disk usage: $${DISK}%\"",
    "echo \"Service check complete\"",
    "BASHEOF",
    "chmod +x /tmp/check-services.sh",
    "sudo mv /tmp/check-services.sh /usr/local/bin/check-services",
    "echo 'Bash script created'"
  ]
}

# Verify
provisioner "shell" {
  inline = [
    "echo '=== Verification ==='",
    "echo 'JSON config:'",
    "cat /etc/myapp/config.json",
    "echo ''",
    "echo 'Bash script:'",
    "head -15 /usr/local/bin/check-services",
    "echo ''",
    "echo 'Running check-services:'",
    "/usr/local/bin/check-services || true",
    "echo '=== All done ==='"
  ]
}
