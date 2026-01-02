# Test 05: Python Development Environment
# Installs Python 3 with pip, poetry, and common packages
# Uses system default Python (3.12 on Ubuntu 24.04)

variable "pip_packages" {
  type        = list(string)
  default     = ["pytest", "black", "flake8", "mypy", "poetry"]
  description = "Python packages to install"
}

provisioner "shell" {
  inline = [
    "echo '=== Setting up Python environment ==='",
    "export DEBIAN_FRONTEND=noninteractive",
    
    "sudo apt-get update",
    "# Install python3-full for venv support and pip",
    "sudo apt-get install -y python3-full python3-pip python3-venv",
    
    "python3 --version",
    "pip3 --version || echo 'pip3 not directly available, using python3 -m pip'",
    
    "echo '=== Python setup complete ==='"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Installing pip packages ==='",
    
    "# Upgrade pip first (use --break-system-packages for Ubuntu 24.04)",
    "python3 -m pip install --upgrade pip --break-system-packages || python3 -m pip install --upgrade pip",
    
    "# Install specified packages",
    "python3 -m pip install ${join(" ", var.pip_packages)} --break-system-packages || python3 -m pip install ${join(" ", var.pip_packages)}",
    
    "echo '=== pip packages installed ==='"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Installing pipx for isolated tools ==='",
    
    "# Install pipx via apt (preferred on Ubuntu 24.04)",
    "sudo apt-get install -y pipx || python3 -m pip install pipx --break-system-packages",
    "pipx ensurepath || python3 -m pipx ensurepath",
    
    "echo '=== pipx installed ==='"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Final verification ==='",
    "python3 --version",
    "pip3 --version",
    "poetry --version || echo 'Poetry not found in PATH'",
    "pytest --version || echo 'Pytest not found'",
    "black --version || echo 'Black not found'",
    "echo '=== All done ==='"
  ]
}

