# Test 22: Windows Full CI Environment
# Comprehensive CI image with Java, Node.js, Python, Go, .NET, build tools, and utilities.
# This is the most feature-rich Windows template, suitable for polyglot teams.
#
# Estimated build time: 30-45 minutes
#
# Plugin settings for this template:
#   targetOs: windows
#   targetArch: amd64
#   baseImage: windows-server/2022
#   dockerVersion: 28

variable "java_major_version" {
  type        = string
  default     = "17"
  description = "Java major version (17 or 21)"
}

variable "node_version" {
  type        = string
  default     = "22.14.0"
  description = "Node.js version"
}

variable "go_version" {
  type        = string
  default     = "1.23.6"
  description = "Go version"
}

variable "python_version" {
  type        = string
  default     = "3.12.9"
  description = "Python 3 version"
}

# ============================================================================
# Phase 1: Languages
# ============================================================================

# Java (Eclipse Temurin JDK)
provisioner "powershell" {
  inline = [
    "Write-Host '=== [1/10] Installing Eclipse Temurin JDK ${var.java_major_version} ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y Temurin${var.java_major_version}",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "java -version",
    "javac -version",
    "if (-not $env:JAVA_HOME) { Write-Error 'JAVA_HOME is not set'; exit 1 }",
    "Write-Host '=== JDK installed ==='"
  ]
}

# Node.js + package managers
provisioner "powershell" {
  inline = [
    "Write-Host '=== [2/10] Installing Node.js ${var.node_version} ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y nodejs.install --version=${var.node_version}",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "node --version",
    "npm --version",
    "npm install -g yarn pnpm typescript",
    "yarn --version",
    "pnpm --version",
    "tsc --version",
    "Write-Host '=== Node.js installed ==='"
  ]
}

# Python 3
provisioner "powershell" {
  inline = [
    "Write-Host '=== [3/10] Installing Python ${var.python_version} ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y python3 --version=${var.python_version}",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "python --version",
    "pip --version",
    "pip install --quiet virtualenv",
    "Write-Host '=== Python installed ==='"
  ]
}

# Go
provisioner "powershell" {
  inline = [
    "Write-Host '=== [4/10] Installing Go ${var.go_version} ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y golang --version=${var.go_version}",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "go version",
    "Write-Host '=== Go installed ==='"
  ]
}

# .NET 8 SDK
provisioner "powershell" {
  inline = [
    "Write-Host '=== [5/10] Installing .NET 8 SDK ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y dotnet-8.0-sdk",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "dotnet --version",
    "Write-Host '=== .NET SDK installed ==='"
  ]
}

# ============================================================================
# Phase 2: Build Tools
# ============================================================================

# Maven + Gradle
provisioner "powershell" {
  inline = [
    "Write-Host '=== [6/10] Installing Maven + Gradle ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y maven gradle",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "mvn --version 2>&1 | Select-Object -First 1",
    "gradle --version 2>&1 | Where-Object { $_ -match 'Gradle' } | Select-Object -First 1",
    "Write-Host '=== Maven + Gradle installed ==='"
  ]
}

# CMake + Make (for C/C++ builds)
provisioner "powershell" {
  inline = [
    "Write-Host '=== [7/10] Installing CMake + Make ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y cmake make",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "cmake --version 2>&1 | Select-Object -First 1",
    "make --version 2>&1 | Select-Object -First 1",
    "Write-Host '=== CMake + Make installed ==='"
  ]
}

# ============================================================================
# Phase 3: DevOps & Cloud Tools
# ============================================================================

# Kubernetes tools (kubectl + Helm)
provisioner "powershell" {
  inline = [
    "Write-Host '=== [8/10] Installing kubectl + Helm ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y kubernetes-cli kubernetes-helm",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "kubectl version --client 2>&1 | Select-Object -First 1",
    "helm version --short 2>&1",
    "Write-Host '=== kubectl + Helm installed ==='"
  ]
}

# Terraform + Cloud CLIs
provisioner "powershell" {
  inline = [
    "Write-Host '=== [9/10] Installing Terraform + Cloud CLIs ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y terraform awscli azure-cli",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "terraform version 2>&1 | Select-Object -First 1",
    "aws --version 2>&1",
    "az version 2>&1 | Select-String 'azure-cli'",
    "Write-Host '=== Terraform + Cloud CLIs installed ==='"
  ]
}

# ============================================================================
# Phase 4: Utilities
# ============================================================================

# Common CLI utilities
provisioner "powershell" {
  inline = [
    "Write-Host '=== [10/10] Installing CLI utilities ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y jq yq 7zip nuget.commandline",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "jq --version",
    "yq --version",
    "nuget help 2>&1 | Select-Object -First 1",
    "Write-Host '=== CLI utilities installed ==='"
  ]
}

# ============================================================================
# Final Verification
# ============================================================================

provisioner "powershell" {
  inline = [
    "Write-Host ''",
    "Write-Host '================================================================'",
    "Write-Host '         Windows Full CI Environment - Verification             '",
    "Write-Host '================================================================'",
    "Write-Host ''",
    "",
    "Write-Host '--- Languages ---'",
    "java -version 2>&1 | Select-Object -First 1 | ForEach-Object { Write-Host \"  Java:       $_\" }",
    "Write-Host \"  Node.js:    $(node --version)\"",
    "Write-Host \"  Python:     $(python --version 2>&1)\"",
    "Write-Host \"  Go:         $(go version)\"",
    "Write-Host \"  .NET:       $(dotnet --version)\"",
    "Write-Host \"  TypeScript: $(tsc --version)\"",
    "Write-Host ''",
    "",
    "Write-Host '--- Build Tools ---'",
    "mvn --version 2>&1 | Select-Object -First 1 | ForEach-Object { Write-Host \"  Maven:   $_\" }",
    "gradle --version 2>&1 | Where-Object { $_ -match 'Gradle' } | Select-Object -First 1 | ForEach-Object { Write-Host \"  Gradle:  $_\" }",
    "cmake --version 2>&1 | Select-Object -First 1 | ForEach-Object { Write-Host \"  CMake:   $_\" }",
    "make --version 2>&1 | Select-Object -First 1 | ForEach-Object { Write-Host \"  Make:    $_\" }",
    "Write-Host \"  npm:     $(npm --version)\"",
    "Write-Host \"  yarn:    $(yarn --version)\"",
    "Write-Host \"  pnpm:    $(pnpm --version)\"",
    "Write-Host \"  pip:     $(pip --version 2>&1)\"",
    "Write-Host ''",
    "",
    "Write-Host '--- DevOps & Cloud ---'",
    "kubectl version --client 2>&1 | Select-Object -First 1 | ForEach-Object { Write-Host \"  kubectl:    $_\" }",
    "Write-Host \"  Helm:       $(helm version --short 2>&1)\"",
    "terraform version 2>&1 | Select-Object -First 1 | ForEach-Object { Write-Host \"  Terraform:  $_\" }",
    "Write-Host \"  AWS CLI:    $(aws --version 2>&1)\"",
    "az version 2>&1 | Select-String 'azure-cli' | ForEach-Object { Write-Host \"  Azure CLI:  $_\" }",
    "Write-Host ''",
    "",
    "Write-Host '--- Pre-installed by Harness ---'",
    "Write-Host \"  Git:        $(git --version)\"",
    "Write-Host \"  Git LFS:    $(git lfs version 2>&1)\"",
    "Write-Host \"  Docker:     $(docker --version)\"",
    "Write-Host ''",
    "",
    "Write-Host '--- Disk Usage ---'",
    "Get-PSDrive C | ForEach-Object { Write-Host \"  Used: $([math]::Round($_.Used/1GB,1)) GB  Free: $([math]::Round($_.Free/1GB,1)) GB  Total: $([math]::Round(($_.Used+$_.Free)/1GB,1)) GB\" }",
    "Write-Host ''",
    "Write-Host '================================================================'",
    "Write-Host '         All tools verified successfully!                       '",
    "Write-Host '================================================================'"
  ]
}
