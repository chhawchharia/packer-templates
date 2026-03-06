param(
    [string]$ConfigSource = "C:\Windows\Temp\harness-config",
    [string]$InstallDir   = "C:\Harness"
)

$ErrorActionPreference = 'Stop'

Write-Host "========================================"
Write-Host "Deploying configuration files"
Write-Host "  Source:  $ConfigSource"
Write-Host "  Target:  $InstallDir"
Write-Host "========================================"

$dirs = @("Agent", "Data", "Logs", "Temp", "Config")
foreach ($d in $dirs) {
    $path = Join-Path $InstallDir $d
    New-Item -ItemType Directory -Force -Path $path | Out-Null
    Write-Host "  Created: $path"
}

if (Test-Path $ConfigSource) {
    $files = Get-ChildItem $ConfigSource -File
    foreach ($f in $files) {
        $dest = Join-Path "$InstallDir\Config" $f.Name
        Copy-Item $f.FullName $dest -Force
        Write-Host "  Deployed: $($f.Name) -> $dest"
    }
} else {
    Write-Error "Config source directory not found: $ConfigSource"
    exit 1
}

Write-Host ""
Write-Host "Deployed configuration:"
Get-ChildItem "$InstallDir\Config" | Format-Table Name, Length, LastWriteTime
