# Test 19: Windows Java + .NET Development Environment
# Installs Eclipse Temurin JDK 17, Maven, Gradle, .NET 8 SDK, NuGet CLI
#
# Plugin settings for this template:
#   targetOs: windows
#   targetArch: amd64
#   baseImage: windows-server/2022

variable "java_major_version" {
  type        = string
  default     = "17"
  description = "Java major version (17 or 21)"
}

variable "maven_version" {
  type        = string
  default     = "3.9.9"
  description = "Apache Maven version"
}

variable "gradle_version" {
  type        = string
  default     = "8.12"
  description = "Gradle version"
}

# Install Eclipse Temurin JDK
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing Eclipse Temurin JDK ${var.java_major_version} ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y Temurin${var.java_major_version}",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "java -version",
    "javac -version",
    "Write-Host \"JAVA_HOME = $env:JAVA_HOME\"",
    "if (-not $env:JAVA_HOME) { Write-Error 'JAVA_HOME is not set'; exit 1 }",
    "Write-Host '=== JDK installed ==='"
  ]
}

# Install Apache Maven
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing Maven ${var.maven_version} ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y maven --version=${var.maven_version}",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "mvn --version",
    "Write-Host '=== Maven installed ==='"
  ]
}

# Install Gradle
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing Gradle ${var.gradle_version} ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y gradle --version=${var.gradle_version}",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "gradle --version",
    "Write-Host '=== Gradle installed ==='"
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
    "dotnet --list-sdks",
    "Write-Host '=== .NET SDK installed ==='"
  ]
}

# Install NuGet CLI
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing NuGet CLI ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y nuget.commandline",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "nuget help | Select-Object -First 1",
    "Write-Host '=== NuGet installed ==='"
  ]
}

# Final verification
provisioner "powershell" {
  inline = [
    "Write-Host '=========================================='",
    "Write-Host '=== Java/.NET Development Environment ==='",
    "Write-Host '=========================================='",
    "Write-Host ''",
    "Write-Host 'Java:'",
    "java -version 2>&1 | ForEach-Object { Write-Host \"  $_\" }",
    "Write-Host \"  JAVA_HOME = $env:JAVA_HOME\"",
    "Write-Host ''",
    "Write-Host 'Maven:'",
    "mvn --version 2>&1 | Select-Object -First 1 | ForEach-Object { Write-Host \"  $_\" }",
    "Write-Host ''",
    "Write-Host 'Gradle:'",
    "gradle --version 2>&1 | Where-Object { $_ -match 'Gradle' } | Select-Object -First 1 | ForEach-Object { Write-Host \"  $_\" }",
    "Write-Host ''",
    "Write-Host '.NET SDK:'",
    "dotnet --version 2>&1 | ForEach-Object { Write-Host \"  $_\" }",
    "Write-Host ''",
    "Write-Host 'Git (pre-installed by Harness):'",
    "git --version 2>&1 | ForEach-Object { Write-Host \"  $_\" }",
    "Write-Host ''",
    "Write-Host 'Disk usage:'",
    "Get-PSDrive C | ForEach-Object { Write-Host \"  Used: $([math]::Round($_.Used/1GB,1)) GB  Free: $([math]::Round($_.Free/1GB,1)) GB\" }",
    "Write-Host '=========================================='",
  ]
}
