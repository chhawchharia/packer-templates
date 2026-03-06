# Test 23: Windows File Provisioner with PowerShell Scripts
# Tests:
#   - file provisioner to copy .ps1 scripts to the Windows VM
#   - Executing copied scripts with parameters
#   - Script-based package installation
#   - Environment verification from external script
#
# This is the Windows equivalent of Linux test-scenario 07.
#
# Plugin settings:
#   targetOs: windows
#   targetArch: amd64
#   baseImage: windows-server/2022

variable "app_name" {
  type        = string
  default     = "myapp"
  description = "Application name for setup"
}

variable "tools_dir" {
  type        = string
  default     = "C:\\Tools"
  description = "Directory where tools will be installed"
}

# Copy setup-tools script
provisioner "file" {
  source      = "scripts/setup-tools.ps1"
  destination = "C:\\Windows\\Temp\\setup-tools.ps1"
}

# Copy install-packages script
provisioner "file" {
  source      = "scripts/install-packages.ps1"
  destination = "C:\\Windows\\Temp\\install-packages.ps1"
}

# Copy verification script
provisioner "file" {
  source      = "scripts/verify-env.ps1"
  destination = "C:\\Windows\\Temp\\verify-env.ps1"
}

# Run setup-tools with parameters
provisioner "powershell" {
  inline = [
    "Write-Host '=== Running setup-tools script ==='",
    "$ErrorActionPreference = 'Stop'",
    "& C:\\Windows\\Temp\\setup-tools.ps1 -ToolsDir '${var.tools_dir}' -AppName '${var.app_name}'",
    "Write-Host '=== Setup complete ==='"
  ]
}

# Run install-packages script
provisioner "powershell" {
  inline = [
    "Write-Host '=== Running package installation script ==='",
    "$ErrorActionPreference = 'Stop'",
    "& C:\\Windows\\Temp\\install-packages.ps1 -Packages @('jq', '7zip')",
    "Write-Host '=== Packages installed ==='",
    "jq --version"
  ]
}

# Run health check from the deployed script
provisioner "powershell" {
  inline = [
    "Write-Host '=== Running health check ==='",
    "$ErrorActionPreference = 'Stop'",
    "& '${var.tools_dir}\\${var.app_name}\\bin\\health-check.ps1' -AppName '${var.app_name}'",
    "Write-Host '=== Health check passed ==='"
  ]
}

# Run environment verification
provisioner "powershell" {
  inline = [
    "Write-Host '=== Running environment verification ==='",
    "& C:\\Windows\\Temp\\verify-env.ps1",
    "Write-Host '=== Verification complete ==='"
  ]
}
