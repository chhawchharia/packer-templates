param(
    [string[]]$Packages = @("jq", "7zip")
)

$ErrorActionPreference = 'Stop'

Write-Host "========================================"
Write-Host "Installing Chocolatey packages"
Write-Host "========================================"

foreach ($pkg in $Packages) {
    Write-Host "Installing: $pkg"
    choco install -y $pkg
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install $pkg"
        exit 1
    }
    Write-Host "  $pkg installed successfully"
}

Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
Update-SessionEnvironment

Write-Host "All packages installed successfully."
