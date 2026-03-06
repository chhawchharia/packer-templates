$ErrorActionPreference = 'Stop'
$exitCode = 0

Write-Host "========================================"
Write-Host "Verifying Environment & Registry Settings"
Write-Host "========================================"

# Verify machine-level env vars
Write-Host ""
Write-Host "--- Machine Environment Variables ---"
$requiredVars = @("APP_HOME", "APP_DATA", "APP_LOGS", "CI", "HARNESS_CI")

foreach ($var in $requiredVars) {
    $val = [Environment]::GetEnvironmentVariable($var, "Machine")
    if ($val) {
        Write-Host "  [PASS] $var = $val"
    } else {
        Write-Host "  [FAIL] $var is not set"
        $exitCode = 1
    }
}

# Verify PATH additions
Write-Host ""
Write-Host "--- PATH Verification ---"
$machinePath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$pathsToCheck = @("C:\MyApp\bin", "C:\MyApp\tools")
foreach ($p in $pathsToCheck) {
    if ($machinePath -like "*$p*") {
        Write-Host "  [PASS] PATH contains: $p"
    } else {
        Write-Host "  [FAIL] PATH missing: $p"
        $exitCode = 1
    }
}

# Verify registry settings
Write-Host ""
Write-Host "--- Registry Settings ---"
$longPath = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -ErrorAction SilentlyContinue).LongPathsEnabled
if ($longPath -eq 1) {
    Write-Host "  [PASS] LongPathsEnabled = 1"
} else {
    Write-Host "  [FAIL] LongPathsEnabled = $longPath (expected 1)"
    $exitCode = 1
}

$wer = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -ErrorAction SilentlyContinue).Disabled
if ($wer -eq 1) {
    Write-Host "  [PASS] Windows Error Reporting: Disabled"
} else {
    Write-Host "  [FAIL] Windows Error Reporting: not disabled"
    $exitCode = 1
}

# Verify directories
Write-Host ""
Write-Host "--- Directory Structure ---"
$dirsToCheck = @("C:\MyApp\bin", "C:\MyApp\tools", "C:\MyApp\data", "C:\MyApp\logs")
foreach ($dir in $dirsToCheck) {
    if (Test-Path $dir) {
        Write-Host "  [PASS] Directory exists: $dir"
    } else {
        Write-Host "  [FAIL] Directory missing: $dir"
        $exitCode = 1
    }
}

Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "ALL VERIFICATIONS PASSED"
} else {
    Write-Host "SOME VERIFICATIONS FAILED"
}

exit $exitCode
