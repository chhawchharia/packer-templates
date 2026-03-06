# Test 24: Windows Config File Deployment
# Tests:
#   - file provisioner with directory copy (source trailing slash -> copies contents)
#   - Deploying JSON, YAML, and PS1 config files to the VM
#   - Running deployment scripts that read and validate copied configs
#   - Config file parsing (JSON deserialization, YAML content check)
#   - Directory structure creation from script
#
# This is the Windows equivalent of Linux test-scenario 15.
#
# Plugin settings:
#   targetOs: windows
#   targetArch: amd64
#   baseImage: windows-server/2022

variable "install_dir" {
  type        = string
  default     = "C:\\Harness"
  description = "Base installation directory"
}

# Copy config files directory (trailing slash = contents only)
provisioner "file" {
  source      = "scripts/config/"
  destination = "C:\\Windows\\Temp\\harness-config"
}

# Copy deployment script
provisioner "file" {
  source      = "scripts/setup/deploy-config.ps1"
  destination = "C:\\Windows\\Temp\\deploy-config.ps1"
}

# Copy validation script
provisioner "file" {
  source      = "scripts/setup/validate-config.ps1"
  destination = "C:\\Windows\\Temp\\validate-config.ps1"
}

# Debug: show what was uploaded
provisioner "powershell" {
  inline = [
    "Write-Host '=== DEBUG: Checking uploaded files ==='",
    "Write-Host 'Config files (C:\\Windows\\Temp\\harness-config):'",
    "if (Test-Path 'C:\\Windows\\Temp\\harness-config') { Get-ChildItem 'C:\\Windows\\Temp\\harness-config' -Recurse | Format-Table Name, Length } else { Write-Host '  Directory not found' }",
    "Write-Host ''",
    "Write-Host 'Deployment scripts:'",
    "Test-Path 'C:\\Windows\\Temp\\deploy-config.ps1' | ForEach-Object { Write-Host \"  deploy-config.ps1: $_\" }",
    "Test-Path 'C:\\Windows\\Temp\\validate-config.ps1' | ForEach-Object { Write-Host \"  validate-config.ps1: $_\" }",
    "Write-Host '=== End Debug ==='"
  ]
}

# Run deployment script
provisioner "powershell" {
  inline = [
    "Write-Host '=== Deploying configuration ==='",
    "$ErrorActionPreference = 'Stop'",
    "& C:\\Windows\\Temp\\deploy-config.ps1 -ConfigSource 'C:\\Windows\\Temp\\harness-config' -InstallDir '${var.install_dir}'",
    "Write-Host '=== Deployment complete ==='"
  ]
}

# Run validation script
provisioner "powershell" {
  inline = [
    "Write-Host '=== Validating configuration ==='",
    "$ErrorActionPreference = 'Stop'",
    "& C:\\Windows\\Temp\\validate-config.ps1 -ConfigDir '${var.install_dir}\\Config'",
    "Write-Host '=== Validation complete ==='"
  ]
}

# Test reading deployed config values inline (customer might do this)
provisioner "powershell" {
  inline = [
    "Write-Host '=== Reading config values inline ==='",
    "$ErrorActionPreference = 'Stop'",
    "$config = Get-Content '${var.install_dir}\\Config\\app-settings.json' -Raw | ConvertFrom-Json",
    "Write-Host \"App Name: $($config.application.name)\"",
    "Write-Host \"Version:  $($config.application.version)\"",
    "Write-Host \"Port:     $($config.server.port)\"",
    "Write-Host \"Logging:  $($config.logging.level)\"",
    "if ($config.application.name -ne 'harness-ci-agent') { Write-Error 'Unexpected app name'; exit 1 }",
    "Write-Host '=== Config read successfully ==='"
  ]
}
