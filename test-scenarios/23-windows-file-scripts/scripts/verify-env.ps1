$ErrorActionPreference = 'Stop'

Write-Host "========================================"
Write-Host "Environment Verification"
Write-Host "========================================"

$checks = @(
    @{ Name = "Git";        Command = { git --version } },
    @{ Name = "Docker";     Command = { docker --version } },
    @{ Name = "PowerShell"; Command = { $PSVersionTable.PSVersion.ToString() } },
    @{ Name = "Chocolatey"; Command = { choco --version } }
)

$passed = 0
$failed = 0

foreach ($check in $checks) {
    try {
        $result = & $check.Command 2>&1
        Write-Host "  [PASS] $($check.Name): $result"
        $passed++
    }
    catch {
        Write-Host "  [FAIL] $($check.Name): $_"
        $failed++
    }
}

Write-Host ""
Write-Host "System Info:"
Write-Host "  OS: $([System.Environment]::OSVersion.VersionString)"
Write-Host "  Architecture: $env:PROCESSOR_ARCHITECTURE"
Write-Host "  CPU Count: $env:NUMBER_OF_PROCESSORS"
$mem = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
Write-Host "  RAM: ${mem} GB"

$drive = Get-PSDrive C
Write-Host "  Disk Free: $([math]::Round($drive.Free/1GB, 1)) GB"

Write-Host ""
Write-Host "Results: $passed passed, $failed failed"
if ($failed -gt 0) { exit 1 }
