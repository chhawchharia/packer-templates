$ErrorActionPreference = 'Stop'

Write-Host "========================================"
Write-Host "Test: Long File Paths (> 260 chars)"
Write-Host "========================================"

# Enable LongPathsEnabled in registry (required for paths > 260 chars)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -Type DWord
$longPathEnabled = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled").LongPathsEnabled
Write-Host "LongPathsEnabled registry value: $longPathEnabled"

# Create a deeply nested directory structure using \\?\ prefix for immediate long-path access
$base = "C:\LongPathTest"
$deep = $base
for ($i = 1; $i -le 15; $i++) {
    $deep = Join-Path $deep ("level_$i" + "_" + ("x" * 15))
}

Write-Host "Path length: $($deep.Length) characters"

try {
    # Use \\?\ prefix to bypass the 260-char limit without requiring a reboot
    $extendedPath = "\\?\$deep"
    New-Item -ItemType Directory -Force -Path $extendedPath | Out-Null
    $testFile = Join-Path $extendedPath "test_file.txt"
    "This is a test file at a long path" | Set-Content -LiteralPath $testFile
    $content = Get-Content -LiteralPath $testFile
    if ($content -eq "This is a test file at a long path") {
        Write-Host "[PASS] Created and read file at $($deep.Length + 14)-char path"
    } else {
        Write-Host "[FAIL] Content mismatch at long path"
        exit 1
    }
} catch {
    Write-Host "[FAIL] Long path operations failed: $_"
    exit 1
} finally {
    Remove-Item -Recurse -Force "\\?\$base" -ErrorAction SilentlyContinue
}
