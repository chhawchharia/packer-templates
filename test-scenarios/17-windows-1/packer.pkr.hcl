# Test 17: Windows Basic Custom Tools
# Installs Node.js, Python, .NET SDK, and common utilities via Chocolatey.
# This is a simple "starter" template for Windows BYOI.
#
# Plugin settings for this template:
#   targetOs: windows
#   targetArch: amd64
#   baseImage: windows-server/2022

# Install Node.js, Python, and utilities
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing developer tools ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y nodejs.install python3 jq 7zip",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "node --version",
    "npm --version",
    "python --version",
    "pip --version",
    "jq --version",
    "Write-Host '=== Developer tools installed ==='"
  ]
}

# Install .NET 8 SDK
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing .NET 8 SDK ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y dotnet-8.0-sdk",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "dotnet --version",
    "Write-Host '=== .NET SDK installed ==='"
  ]
}

# Install global npm tools
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing npm global tools ==='",
    "npm install -g typescript yarn",
    "tsc --version",
    "yarn --version",
    "Write-Host '=== npm tools installed ==='"
  ]
}

# Verification
provisioner "powershell" {
  inline = [
    "Write-Host '=========================================='",
    "Write-Host '=== Windows Basic CI Environment Ready ==='",
    "Write-Host '=========================================='",
    "Write-Host \"  Node.js:  $(node --version)\"",
    "Write-Host \"  Python:   $(python --version 2>&1)\"",
    "Write-Host \"  .NET:     $(dotnet --version)\"",
    "Write-Host \"  tsc:      $(tsc --version)\"",
    "Write-Host \"  Git:      $(git --version)\"",
    "Write-Host '=========================================='",
  ]
}
