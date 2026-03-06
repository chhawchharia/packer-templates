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

# Configure cache env vars at machine level (tools will use them when installed later)
[Environment]::SetEnvironmentVariable("NPM_CONFIG_CACHE", "$CacheDir\npm", "Machine")
[Environment]::SetEnvironmentVariable("PIP_CACHE_DIR", "$CacheDir\pip", "Machine")
[Environment]::SetEnvironmentVariable("GOMODCACHE", "$CacheDir\go", "Machine")
[Environment]::SetEnvironmentVariable("NUGET_PACKAGES", "$CacheDir\nuget", "Machine")

Write-Host "CI agent directories created:"
foreach ($dir in $directories) {
    Write-Host "  $dir"
}
Write-Host "Cache directories configured."
