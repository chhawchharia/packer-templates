$ErrorActionPreference = 'Stop'

Write-Host "========================================"
Write-Host "Configuring Windows Registry Settings"
Write-Host "========================================"

# Enable Long Paths (required for many build tools like Node.js, .NET)
$longPathKey = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
Set-ItemProperty -Path $longPathKey -Name "LongPathsEnabled" -Value 1 -Type DWord
$val = Get-ItemProperty -Path $longPathKey -Name "LongPathsEnabled"
Write-Host "  LongPathsEnabled: $($val.LongPathsEnabled)"

# Configure Windows Error Reporting (disable for CI - avoids hang on crash)
$werKey = "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting"
if (-not (Test-Path $werKey)) { New-Item -Path $werKey -Force | Out-Null }
Set-ItemProperty -Path $werKey -Name "Disabled" -Value 1 -Type DWord
Write-Host "  Windows Error Reporting: Disabled"

# Disable Server Manager auto-start (saves resources on CI VMs)
$smKey = "HKLM:\SOFTWARE\Microsoft\ServerManager"
if (Test-Path $smKey) {
    Set-ItemProperty -Path $smKey -Name "DoNotOpenServerManagerAtLogon" -Value 1 -Type DWord
    Write-Host "  Server Manager auto-start: Disabled"
}

# Configure crash dump (small memory dump for CI)
$crashKey = "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl"
Set-ItemProperty -Path $crashKey -Name "CrashDumpEnabled" -Value 3 -Type DWord
Write-Host "  Crash dump type: Small (3)"

# Set timezone to UTC (common for CI)
try {
    Set-TimeZone -Id "UTC" -ErrorAction SilentlyContinue
    Write-Host "  Timezone: UTC"
} catch {
    Write-Host "  Timezone: Could not set (non-critical)"
}

Write-Host ""
Write-Host "Registry configuration complete."
