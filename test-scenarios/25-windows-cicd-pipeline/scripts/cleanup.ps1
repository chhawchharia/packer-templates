param(
    [string]$WorkDir = "C:\BuildAgent\workspace"
)

$ErrorActionPreference = 'SilentlyContinue'

Write-Host "========================================"
Write-Host "Cleanup - Removing build artifacts"
Write-Host "========================================"

$tempFiles = @(
    "$WorkDir\test-project",
    "$WorkDir\artifacts"
)

foreach ($path in $tempFiles) {
    if (Test-Path $path) {
        Remove-Item -Recurse -Force $path
        Write-Host "  Removed: $path"
    }
}

# Clear temp files
Get-ChildItem $env:TEMP -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddHours(-1) } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Cleanup complete."
