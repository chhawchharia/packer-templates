param(
    [string]$ToolsDir = "C:\Tools",
    [string]$AppName  = "myapp"
)

$ErrorActionPreference = 'Stop'

Write-Host "========================================"
Write-Host "Setting up tools for: $AppName"
Write-Host "Tools directory: $ToolsDir"
Write-Host "========================================"

New-Item -ItemType Directory -Force -Path "$ToolsDir\$AppName\bin"   | Out-Null
New-Item -ItemType Directory -Force -Path "$ToolsDir\$AppName\logs"  | Out-Null
New-Item -ItemType Directory -Force -Path "$ToolsDir\$AppName\config" | Out-Null

$marker = @{
    AppName    = $AppName
    SetupDate  = (Get-Date).ToString("o")
    SetupBy    = $env:USERNAME
    Machine    = $env:COMPUTERNAME
}
$marker | ConvertTo-Json | Set-Content "$ToolsDir\$AppName\setup-marker.json"

$healthScript = @'
param([string]$AppName = "myapp")
$markerPath = "C:\Tools\$AppName\setup-marker.json"
if (Test-Path $markerPath) {
    $data = Get-Content $markerPath | ConvertFrom-Json
    Write-Host "OK - $($data.AppName) setup at $($data.SetupDate)"
    exit 0
} else {
    Write-Error "FAIL - marker not found at $markerPath"
    exit 1
}
'@
Set-Content -Path "$ToolsDir\$AppName\bin\health-check.ps1" -Value $healthScript

Write-Host "Application setup complete!"
Get-ChildItem "$ToolsDir\$AppName" -Recurse | Format-Table Name, Length, LastWriteTime
