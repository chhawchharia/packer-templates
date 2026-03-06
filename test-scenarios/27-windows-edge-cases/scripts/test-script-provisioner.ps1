# This script tests the "provisioner powershell { script = ... }" pattern.
# Packer auto-uploads this file and runs it directly (no manual file copy needed).
$ErrorActionPreference = 'Stop'

Write-Host "========================================"
Write-Host "Test: PowerShell Script Provisioner"
Write-Host "  (auto-uploaded by Packer)"
Write-Host "========================================"

Write-Host "Script path:  $PSScriptRoot"
Write-Host "PS Version:   $($PSVersionTable.PSVersion)"
Write-Host "User:         $env:USERNAME"
Write-Host "Machine:      $env:COMPUTERNAME"
Write-Host "OS:           $([System.Environment]::OSVersion.VersionString)"

# Test that we can access the filesystem
$testFile = "$env:TEMP\script-provisioner-test.txt"
"script-provisioner-works" | Set-Content $testFile
$content = Get-Content $testFile
if ($content -eq "script-provisioner-works") {
    Write-Host "[PASS] Script provisioner can read/write files"
} else {
    Write-Error "[FAIL] File content mismatch"
    exit 1
}
Remove-Item $testFile -Force

# Test that pre-installed tools are accessible
try {
    $gitVer = git --version
    Write-Host "[PASS] Git accessible: $gitVer"
} catch {
    Write-Error "[FAIL] Git not accessible"
    exit 1
}

Write-Host ""
Write-Host "Script provisioner test PASSED."
