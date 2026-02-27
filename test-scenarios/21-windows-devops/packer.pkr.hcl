# Test 21: Windows DevOps / Infrastructure Environment
# Installs Go, kubectl, Helm, Terraform, AWS CLI, Azure CLI, common DevOps tools
#
# Plugin settings for this template:
#   targetOs: windows
#   targetArch: amd64
#   baseImage: windows-server/2022

variable "go_version" {
  type        = string
  default     = "1.23.6"
  description = "Go version"
}

variable "terraform_version" {
  type        = string
  default     = "1.10.5"
  description = "Terraform version"
}

# Install Go
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing Go ${var.go_version} ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y golang --version=${var.go_version}",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "go version",
    "go env GOPATH",
    "Write-Host '=== Go installed ==='"
  ]
}

# Install kubectl
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing kubectl ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y kubernetes-cli",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "kubectl version --client",
    "Write-Host '=== kubectl installed ==='"
  ]
}

# Install Helm
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing Helm ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y kubernetes-helm",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "helm version",
    "Write-Host '=== Helm installed ==='"
  ]
}

# Install Terraform
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing Terraform ${var.terraform_version} ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y terraform --version=${var.terraform_version}",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "terraform version",
    "Write-Host '=== Terraform installed ==='"
  ]
}

# Install AWS CLI v2
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing AWS CLI v2 ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y awscli",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "aws --version",
    "Write-Host '=== AWS CLI installed ==='"
  ]
}

# Install Azure CLI
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing Azure CLI ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y azure-cli",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "az version",
    "Write-Host '=== Azure CLI installed ==='"
  ]
}

# Install common DevOps utilities
provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing DevOps utilities ==='",
    "$ErrorActionPreference = 'Stop'",
    "choco install -y jq yq make 7zip",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "jq --version",
    "yq --version",
    "make --version 2>&1 | Select-Object -First 1",
    "Write-Host '=== DevOps utilities installed ==='"
  ]
}

# Final verification
provisioner "powershell" {
  inline = [
    "Write-Host '========================================'",
    "Write-Host '=== DevOps Environment Ready ==='",
    "Write-Host '========================================'",
    "Write-Host ''",
    "Write-Host 'Languages:'",
    "Write-Host \"  Go         $(go version)\"",
    "Write-Host ''",
    "Write-Host 'Kubernetes:'",
    "kubectl version --client 2>&1 | Select-Object -First 1 | ForEach-Object { Write-Host \"  kubectl    $_\" }",
    "Write-Host \"  Helm       $(helm version --short 2>&1)\"",
    "Write-Host ''",
    "Write-Host 'Infrastructure:'",
    "terraform version 2>&1 | Select-Object -First 1 | ForEach-Object { Write-Host \"  Terraform  $_\" }",
    "Write-Host ''",
    "Write-Host 'Cloud CLIs:'",
    "Write-Host \"  AWS CLI    $(aws --version 2>&1)\"",
    "az version 2>&1 | Select-String 'azure-cli' | ForEach-Object { Write-Host \"  Azure CLI  $_\" }",
    "Write-Host ''",
    "Write-Host 'Git (pre-installed by Harness):'",
    "Write-Host \"  $(git --version)\"",
    "Write-Host ''",
    "Write-Host 'Docker (pre-installed by Harness):'",
    "Write-Host \"  $(docker --version)\"",
    "Write-Host ''",
    "Write-Host 'Disk usage:'",
    "Get-PSDrive C | ForEach-Object { Write-Host \"  Used: $([math]::Round($_.Used/1GB,1)) GB  Free: $([math]::Round($_.Free/1GB,1)) GB\" }",
    "Write-Host '========================================'",
  ]
}
