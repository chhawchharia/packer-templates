$ErrorActionPreference = 'Stop'

Write-Host "========================================"
Write-Host "Test: Long File Paths (> 260 chars)"
Write-Host "========================================"

# Verify LongPathsEnabled in registry
$longPathEnabled = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -ErrorAction SilentlyContinue).LongPathsEnabled
Write-Host "LongPathsEnabled registry value: $longPathEnabled"

# Create a deeply nested directory structure
$base = "C:\LongPathTest"
$deep = $base
for ($i = 1; $i -le 15; $i++) {
    $deep = Join-Path $deep ("level_$i" + "_" + ("x" * 15))
}

Write-Host "Path length: $($deep.Length) characters"

try {
    New-Item -ItemType Directory -Force -Path $deep | Out-Null
    $testFile = Join-Path $deep "test_file.txt"
    "This is a test file at a long path" | Set-Content $testFile
    $content = Get-Content $testFile
    if ($content -eq "This is a test file at a long path") {
        Write-Host "[PASS] Created and read file at $($testFile.Length)-char path"
    } else {
        Write-Host "[FAIL] Content mismatch at long path"
        exit 1
    }
} catch {
    Write-Host "[FAIL] Long path operations failed: $_"
    exit 1
} finally {
    Remove-Item -Recurse -Force $base -ErrorAction SilentlyContinue
}
