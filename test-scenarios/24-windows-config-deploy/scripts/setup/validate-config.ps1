param(
    [string]$ConfigDir = "C:\Harness\Config"
)

$ErrorActionPreference = 'Stop'
$exitCode = 0

Write-Host "========================================"
Write-Host "Validating deployed configuration"
Write-Host "========================================"

# Validate app-settings.json
$jsonFile = Join-Path $ConfigDir "app-settings.json"
if (Test-Path $jsonFile) {
    try {
        $json = Get-Content $jsonFile -Raw | ConvertFrom-Json
        if ($json.application.name -eq "harness-ci-agent") {
            Write-Host "  [PASS] app-settings.json: valid JSON, app name correct"
        } else {
            Write-Host "  [FAIL] app-settings.json: unexpected app name: $($json.application.name)"
            $exitCode = 1
        }
    } catch {
        Write-Host "  [FAIL] app-settings.json: invalid JSON - $_"
        $exitCode = 1
    }
} else {
    Write-Host "  [FAIL] app-settings.json not found"
    $exitCode = 1
}

# Validate service-config.yaml exists and has content
$yamlFile = Join-Path $ConfigDir "service-config.yaml"
if (Test-Path $yamlFile) {
    $content = Get-Content $yamlFile -Raw
    if ($content -match "harness-ci-agent") {
        Write-Host "  [PASS] service-config.yaml: file exists, contains expected service name"
    } else {
        Write-Host "  [FAIL] service-config.yaml: missing expected content"
        $exitCode = 1
    }
} else {
    Write-Host "  [FAIL] service-config.yaml not found"
    $exitCode = 1
}

# Validate environment.ps1 exists
$envFile = Join-Path $ConfigDir "environment.ps1"
if (Test-Path $envFile) {
    Write-Host "  [PASS] environment.ps1: file exists"
} else {
    Write-Host "  [FAIL] environment.ps1 not found"
    $exitCode = 1
}

# Validate directory structure
$requiredDirs = @("Agent", "Data", "Logs", "Temp", "Config")
foreach ($dir in $requiredDirs) {
    $path = Join-Path (Split-Path $ConfigDir -Parent) $dir
    if (Test-Path $path) {
        Write-Host "  [PASS] Directory exists: $path"
    } else {
        Write-Host "  [FAIL] Directory missing: $path"
        $exitCode = 1
    }
}

Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "ALL VALIDATIONS PASSED"
} else {
    Write-Host "SOME VALIDATIONS FAILED"
}

exit $exitCode
