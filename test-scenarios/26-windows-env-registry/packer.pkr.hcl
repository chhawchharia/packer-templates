# Test 26: Windows Environment Variables, Registry, and System Config
# Tests:
#   - file provisioner to copy PowerShell scripts for env/registry setup
#   - Setting machine-level environment variables from script
#   - Modifying Windows registry from script (LongPaths, WER, crash dump)
#   - PATH manipulation from script
#   - Verifying settings persist (read back from machine scope)
#   - Cross-provisioner env variable visibility
#
# This is a critical customer scenario: many CI images need custom env vars,
# registry tweaks, and PATH changes that must survive reboots.
#
# Plugin settings:
#   targetOs: windows
#   targetArch: amd64
#   baseImage: windows-server/2022

variable "app_home" {
  type        = string
  default     = "C:\\MyApp"
  description = "Application home directory"
}

# Copy scripts to VM
provisioner "file" {
  source      = "scripts/set-environment.ps1"
  destination = "C:\\Windows\\Temp\\set-environment.ps1"
}

provisioner "file" {
  source      = "scripts/configure-registry.ps1"
  destination = "C:\\Windows\\Temp\\configure-registry.ps1"
}

provisioner "file" {
  source      = "scripts/verify-settings.ps1"
  destination = "C:\\Windows\\Temp\\verify-settings.ps1"
}

# Step 1: Set environment variables
provisioner "powershell" {
  inline = [
    "Write-Host '=== Step 1: Setting environment variables ==='",
    "$ErrorActionPreference = 'Stop'",
    "& C:\\Windows\\Temp\\set-environment.ps1 -AppHome '${var.app_home}'",
    "Write-Host '=== Environment variables set ==='"
  ]
}

# Step 2: Configure registry
provisioner "powershell" {
  inline = [
    "Write-Host '=== Step 2: Configuring registry ==='",
    "$ErrorActionPreference = 'Stop'",
    "& C:\\Windows\\Temp\\configure-registry.ps1",
    "Write-Host '=== Registry configured ==='"
  ]
}

# Step 3: Verify all settings from a separate provisioner
# (proves settings persist across provisioner boundaries)
provisioner "powershell" {
  inline = [
    "Write-Host '=== Step 3: Verifying settings (cross-provisioner) ==='",
    "$ErrorActionPreference = 'Stop'",
    "& C:\\Windows\\Temp\\verify-settings.ps1",
    "Write-Host '=== All settings verified ==='"
  ]
}

# Step 4: Extra inline checks (customer might mix inline + script)
provisioner "powershell" {
  inline = [
    "Write-Host '=== Step 4: Inline verification ==='",
    "$ci = [Environment]::GetEnvironmentVariable('CI', 'Machine')",
    "if ($ci -ne 'true') { Write-Error 'CI env var not set'; exit 1 }",
    "$appHome = [Environment]::GetEnvironmentVariable('APP_HOME', 'Machine')",
    "if ($appHome -ne '${var.app_home}') { Write-Error 'APP_HOME mismatch'; exit 1 }",
    "$longPath = (Get-ItemProperty 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\FileSystem' -Name 'LongPathsEnabled').LongPathsEnabled",
    "if ($longPath -ne 1) { Write-Error 'LongPaths not enabled'; exit 1 }",
    "Write-Host '=== All inline checks passed ==='"
  ]
}
