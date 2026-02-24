// Custom Windows BYOI Packer template
// Harness auto-installs: Git, Git LFS, Docker, safe.directory, GCM config
// Add your custom provisioners below:

variable "node_version" {
  type    = string
  default = "20"
}

provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing custom tools ==='",
    "choco install -y nodejs --version=${var.node_version}",
    "choco install -y python3",
    "choco install -y jq",
    "choco install -y 7zip",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "node --version",
    "python --version",
    "Write-Host '=== Custom tools installed ==='"
  ]
}

provisioner "powershell" {
  inline = [
    "Write-Host '=== Installing .NET SDK ==='",
    "choco install -y dotnet-sdk --version=8.0",
    "Import-Module $env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1",
    "Update-SessionEnvironment",
    "dotnet --version",
    "Write-Host '=== .NET SDK installed ==='"
  ]
}