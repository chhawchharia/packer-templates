param(
    [string]$AppHome = "C:\MyApp"
)

$ErrorActionPreference = 'Stop'

Write-Host "========================================"
Write-Host "Setting Machine-Level Environment Variables"
Write-Host "========================================"

$envVars = @{
    "APP_HOME"           = $AppHome
    "APP_DATA"           = "$AppHome\data"
    "APP_LOGS"           = "$AppHome\logs"
    "CI"                 = "true"
    "HARNESS_CI"         = "true"
    "DOTNET_CLI_TELEMETRY_OPTOUT" = "1"
    "POWERSHELL_TELEMETRY_OPTOUT" = "1"
}

foreach ($key in $envVars.Keys) {
    [Environment]::SetEnvironmentVariable($key, $envVars[$key], "Machine")
    Write-Host "  Set: $key = $($envVars[$key])"
}

# Update PATH with custom directories
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$newPaths = @("$AppHome\bin", "$AppHome\tools")
foreach ($p in $newPaths) {
    if ($currentPath -notlike "*$p*") {
        $currentPath = "$p;$currentPath"
        Write-Host "  Added to PATH: $p"
    }
}
[Environment]::SetEnvironmentVariable("PATH", $currentPath, "Machine")

# Create the directories
foreach ($dir in @("$AppHome\bin", "$AppHome\tools", "$AppHome\data", "$AppHome\logs")) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

Write-Host ""
Write-Host "Environment variables set successfully."
