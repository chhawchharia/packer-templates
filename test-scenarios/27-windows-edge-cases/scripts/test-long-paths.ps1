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
    $extendedPath = "\\?\$deep"
    [System.IO.Directory]::CreateDirectory($extendedPath) | Out-Null
    $testFile = "$extendedPath\test_file.txt"
    [System.IO.File]::WriteAllText($testFile, "This is a test file at a long path")
    $content = [System.IO.File]::ReadAllText($testFile)
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
    try { [System.IO.Directory]::Delete("\\?\$base", $true) } catch { }
}
