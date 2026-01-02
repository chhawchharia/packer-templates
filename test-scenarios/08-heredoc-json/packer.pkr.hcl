# Test 08: Heredoc and JSON Configuration
# Tests heredocs with nested braces, JSON, and bash constructs

variable "app_config" {
  type        = string
  default     = "production"
  description = "Application configuration environment"
}

# Create JSON config using heredoc
provisioner "shell" {
  inline = [<<-EOF
    echo '=== Creating JSON configuration ==='
    
    # Create config directory
    sudo mkdir -p /etc/myapp
    
    # Create JSON config with nested structures
    cat > /tmp/app-config.json << 'JSONEOF'
    {
      "application": {
        "name": "myapp",
        "version": "1.0.0",
        "environment": "${var.app_config}"
      },
      "server": {
        "host": "0.0.0.0",
        "port": 8080,
        "tls": {
          "enabled": true,
          "cert": "/etc/myapp/cert.pem",
          "key": "/etc/myapp/key.pem"
        }
      },
      "database": {
        "connections": [
          {"host": "db1.example.com", "port": 5432, "role": "primary"},
          {"host": "db2.example.com", "port": 5432, "role": "replica"}
        ],
        "pool": {
          "min": 5,
          "max": 20
        }
      },
      "features": {
        "rate_limiting": true,
        "caching": true,
        "metrics": {
          "enabled": true,
          "endpoint": "/metrics"
        }
      }
    }
JSONEOF
    
    sudo mv /tmp/app-config.json /etc/myapp/config.json
    echo 'JSON config created'
    EOF
  ]
}

# Create bash script with loops and conditionals
provisioner "shell" {
  inline = [<<SCRIPT
    echo '=== Creating bash scripts ==='
    
    # Create a script with bash braces
    cat > /tmp/check-services.sh << 'BASHEOF'
#!/bin/bash
set -e

SERVICES=("docker" "ssh" "cron")

echo "Checking services..."

for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "✓ $service is running"
    else
        echo "✗ $service is not running"
    fi
done

# Check disk space
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$DISK_USAGE" -lt 80 ]; then
    echo "✓ Disk usage OK: ${DISK_USAGE}%"
else
    echo "⚠ Disk usage high: ${DISK_USAGE}%"
fi

# Check memory
FREE_MEM=$(free -m | awk 'NR==2 {printf "%.0f", $7/$2*100}')
echo "Free memory: ${FREE_MEM}%"

echo "Service check complete"
BASHEOF
    
    chmod +x /tmp/check-services.sh
    sudo mv /tmp/check-services.sh /usr/local/bin/check-services
    echo 'Bash script created'
SCRIPT
  ]
}

# Verify
provisioner "shell" {
  inline = [
    "echo '=== Verification ==='",
    "echo 'JSON config:'",
    "cat /etc/myapp/config.json | head -20",
    "echo ''",
    "echo 'Bash script:'",
    "head -15 /usr/local/bin/check-services",
    "echo ''",
    "echo 'Running check-services:'",
    "/usr/local/bin/check-services || true",
    "echo '=== All done ==='"
  ]
}

