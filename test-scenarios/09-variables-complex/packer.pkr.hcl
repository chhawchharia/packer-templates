# Test 09: Complex Variable Types
# Tests all Packer variable types: string, number, bool, list, map, object

variable "app_name" {
  type        = string
  default     = "complex-app"
  description = "Application name"
}

variable "app_port" {
  type        = number
  default     = 8080
  description = "Application port"
}

variable "enable_debug" {
  type        = bool
  default     = false
  description = "Enable debug mode"
}

variable "packages" {
  type        = list(string)
  default     = ["curl", "wget", "jq", "vim", "htop"]
  description = "Packages to install"
}

variable "env_vars" {
  type = map(string)
  default = {
    "APP_ENV"       = "production"
    "LOG_LEVEL"     = "info"
    "ENABLE_CACHE"  = "true"
    "MAX_WORKERS"   = "4"
  }
  description = "Environment variables"
}

variable "app_config" {
  type = object({
    name        = string
    version     = string
    replicas    = number
    auto_scale  = bool
    endpoints   = list(string)
  })
  default = {
    name       = "my-service"
    version    = "2.0.0"
    replicas   = 3
    auto_scale = true
    endpoints  = ["/api", "/health", "/metrics"]
  }
  description = "Application configuration object"
}

# Install packages from list
provisioner "shell" {
  inline = [
    "echo '=== Installing packages ==='",
    "export DEBIAN_FRONTEND=noninteractive",
    "sudo apt-get update",
    "sudo apt-get install -y ${join(" ", var.packages)}",
    "echo '=== Packages installed ==='"
  ]
}

# Configure environment
provisioner "shell" {
  inline = [
    "echo '=== Configuring environment ==='",
    
    "# Create environment file",
    "cat > /tmp/app.env << 'EOF'",
    "APP_NAME=${var.app_name}",
    "APP_PORT=${var.app_port}",
    "DEBUG=${var.enable_debug}",
    "APP_ENV=${var.env_vars["APP_ENV"]}",
    "LOG_LEVEL=${var.env_vars["LOG_LEVEL"]}",
    "ENABLE_CACHE=${var.env_vars["ENABLE_CACHE"]}",
    "MAX_WORKERS=${var.env_vars["MAX_WORKERS"]}",
    "EOF",
    
    "sudo mkdir -p /etc/${var.app_name}",
    "sudo mv /tmp/app.env /etc/${var.app_name}/env",
    
    "echo '=== Environment configured ==='"
  ]
}

# Configure application from object
provisioner "shell" {
  inline = [
    "echo '=== Configuring application ==='",
    
    "echo 'App Name: ${var.app_config.name}'",
    "echo 'App Version: ${var.app_config.version}'",
    "echo 'Replicas: ${var.app_config.replicas}'",
    "echo 'Auto Scale: ${var.app_config.auto_scale}'",
    "echo 'Endpoints: ${join(", ", var.app_config.endpoints)}'",
    
    "echo '=== Application configured ==='"
  ]
}

# Verification
provisioner "shell" {
  inline = [
    "echo '=== Verification ==='",
    "echo 'Environment file:'",
    "cat /etc/${var.app_name}/env",
    "echo ''",
    "echo 'Installed packages:'",
    "dpkg -l | grep -E '${join("|", var.packages)}' | head -10",
    "echo '=== All done ==='"
  ]
}

