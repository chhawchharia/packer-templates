#!/bin/bash
# Setup script for file provisioner test
set -e

APP_NAME="${1:-myapp}"
APP_PORT="${2:-8080}"

echo "========================================"
echo "Setting up application: $APP_NAME"
echo "Port: $APP_PORT"
echo "========================================"

# Create application directory
sudo mkdir -p /opt/$APP_NAME/{bin,config,logs}
sudo chown -R $(whoami):$(whoami) /opt/$APP_NAME

# Copy config
cp /tmp/config.yaml /opt/$APP_NAME/config.yaml

# Update port in config
sed -i "s/port: .*/port: $APP_PORT/" /opt/$APP_NAME/config.yaml

# Copy application files if they exist
if [ -d /tmp/app ]; then
    cp -r /tmp/app/* /opt/$APP_NAME/
fi

# Create a simple health check script
cat > /opt/$APP_NAME/bin/health.sh << 'EOF'
#!/bin/bash
echo "OK"
exit 0
EOF
chmod +x /opt/$APP_NAME/bin/health.sh

echo "Application setup complete!"
echo "Location: /opt/$APP_NAME"
ls -la /opt/$APP_NAME/
