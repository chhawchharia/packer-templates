param(
    [string]$WorkDir  = "C:\BuildAgent",
    [string]$CacheDir = "C:\BuildCache"
)

$ErrorActionPreference = 'Stop'

Write-Host "========================================"
Write-Host "Setting up CI Agent directories"
Write-Host "========================================"

$directories = @(
    "$WorkDir\workspace",
    "$WorkDir\tools",
    "$WorkDir\plugins",
    "$CacheDir\npm",
    "$CacheDir\nuget",
    "$CacheDir\pip",
    "$CacheDir\maven",
    "$CacheDir\gradle",
    "$CacheDir\go",
    "$CacheDir\docker"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

# Set npm cache
npm config set cache "$CacheDir\npm" 2>$null

# Set NuGet cache
$nugetConfigDir = "$env:APPDATA\NuGet"
if (-not (Test-Path $nugetConfigDir)) {
    New-Item -ItemType Directory -Force -Path $nugetConfigDir | Out-Null
}

# Set pip cache
[Environment]::SetEnvironmentVariable("PIP_CACHE_DIR", "$CacheDir\pip", "Machine")

# Set Go module cache
[Environment]::SetEnvironmentVariable("GOMODCACHE", "$CacheDir\go", "Machine")

Write-Host "CI agent directories created:"
foreach ($dir in $directories) {
    Write-Host "  $dir"
}
Write-Host "Cache directories configured."
