# Test 05: Python Development Environment
# Installs Python 3 with pip, poetry, and common packages

variable "python_version" {
  type        = string
  default     = "3.11"
  description = "Python version"
}

variable "pip_packages" {
  type        = list(string)
  default     = ["pytest", "black", "flake8", "mypy", "poetry"]
  description = "Python packages to install"
}

provisioner "shell" {
  inline = [
    "echo '=== Installing Python ${var.python_version} ==='",
    "export DEBIAN_FRONTEND=noninteractive",

    "sudo apt-get update",
    "sudo apt-get install -y python${var.python_version} python${var.python_version}-venv python${var.python_version}-dev python3-pip",

    "# Make this Python version the default",
    "sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${var.python_version} 1",
    "sudo update-alternatives --install /usr/bin/python python /usr/bin/python${var.python_version} 1",

    "python3 --version",
    "pip3 --version",

    "echo '=== Python installed ==='"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Installing pip packages ==='",

    "# Upgrade pip first",
    "python3 -m pip install --upgrade pip",

    "# Install specified packages",
    "python3 -m pip install ${join(" ", var.pip_packages)}",

    "echo '=== pip packages installed ==='"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Installing pipx for isolated tools ==='",

    "python3 -m pip install pipx",
    "python3 -m pipx ensurepath",

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

/*
# Plugin settings for Test 05: Python
PLUGIN_MODE=build
PLUGIN_PACKER_FILE_PATH=test-scenarios/05-python-pip/packer.pkr.hcl
PLUGIN_IMAGE_NAME=python-dev
PLUGIN_IMAGE_VERSION=v3.11.0
PLUGIN_TARGET_OS=linux
PLUGIN_TARGET_ARCH=amd64
PLUGIN_BASE_OS=ubuntu
PLUGIN_BASE_VERSION=22.04
PLUGIN_DEBUG=false

 */