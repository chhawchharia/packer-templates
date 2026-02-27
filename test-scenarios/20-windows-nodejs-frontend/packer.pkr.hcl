# Test 20: Windows Node.js + Frontend Development Environment
# Installs Node.js LTS, Yarn, Python 3, common frontend & build tools
#
# Plugin settings for this template:
#   targetOs: windows
#   targetArch: amd64
#   baseImage: windows-server/2022

variable "node_version" {
  type        = string
  default     = "22.14.0"
  description = "Node.js version (LTS recommended)"
}

variable "python_version" {
  type        = string
  default     = "3.12.9"
  description = "Python 3 version"
}

# Install Node.js
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing Node.js ${var.node_version} ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y nodejs.install --version=${var.node_version}",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "node --version",
    "npm --version",
    "Write-Host '=== Node.js installed ==='"
  ]
}

# Install Yarn and pnpm
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing Yarn and pnpm ==='",
    "$ErrorActionPreference = 'Stop'",
    "npm install -g yarn pnpm",
    "yarn --version",
    "pnpm --version",
    "Write-Host '=== Yarn and pnpm installed ==='"
  ]
}

# Install global npm tools for CI
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing global npm packages ==='",
    "$ErrorActionPreference = 'Stop'",
    "npm install -g typescript@latest",
    "npm install -g eslint@latest",
    "npm install -g prettier@latest",
    "npm install -g npm-check-updates@latest",
    "tsc --version",
    "eslint --version",
    "prettier --version",
    "ncu --version",
    "Write-Host '=== npm packages installed ==='"
  ]
}

# Install Python 3
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing Python ${var.python_version} ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y python3 --version=${var.python_version}",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "python --version",
    "pip --version",
    "Write-Host '=== Python installed ==='"
  ]
}

# Install common CLI utilities
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing CLI utilities ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y jq 7zip",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "jq --version",
    "7z | Select-String 'Copyright' | Select-Object -First 1",
    "Write-Host '=== CLI utilities installed ==='"
  ]
}

# Final verification
provisioner "powershell" {
  inline = [
    "Write-Host '============================================'",
    "Write-Host '=== Node.js/Frontend Environment Ready ==='",
    "Write-Host '============================================'",
    "Write-Host ''",
    "Write-Host 'Node.js & Package Managers:'",
    "Write-Host \"  node    $(node --version)\"",
    "Write-Host \"  npm     $(npm --version)\"",
    "Write-Host \"  yarn    $(yarn --version)\"",
    "Write-Host \"  pnpm    $(pnpm --version)\"",
    "Write-Host ''",
    "Write-Host 'Build Tools:'",
    "Write-Host \"  tsc     $(tsc --version)\"",
    "Write-Host \"  eslint  $(eslint --version)\"",
    "Write-Host ''",
    "Write-Host 'Languages:'",
    "Write-Host \"  python  $(python --version 2>&1)\"",
    "Write-Host ''",
    "Write-Host 'Global npm packages:'",
    "npm list -g --depth=0 2>&1 | ForEach-Object { Write-Host \"  $_\" }",
    "Write-Host ''",
    "Write-Host 'Git (pre-installed by Harness):'",
    "Write-Host \"  $(git --version)\"",
    "Write-Host ''",
    "Write-Host 'Disk usage:'",
    "Get-PSDrive C | ForEach-Object { Write-Host \"  Used: $([math]::Round($_.Used/1GB,1)) GB  Free: $([math]::Round($_.Free/1GB,1)) GB\" }",
    "Write-Host '============================================'"
  ]
}
