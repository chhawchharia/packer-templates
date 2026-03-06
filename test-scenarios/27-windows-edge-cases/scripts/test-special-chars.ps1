$ErrorActionPreference = 'Stop'

Write-Host "========================================"
Write-Host "Test: Special Characters in Paths/Content"
Write-Host "========================================"

$testDir = "C:\SpecialCharTest"
New-Item -ItemType Directory -Force -Path $testDir | Out-Null

try {
    # Test 1: Spaces in file names
    $spacePath = "$testDir\file with spaces.txt"
    "content with spaces" | Set-Content $spacePath
    if (Test-Path $spacePath) { Write-Host "  [PASS] Spaces in filename" }
    else { Write-Host "  [FAIL] Spaces in filename"; exit 1 }

    # Test 2: Parentheses in path (common: "Program Files (x86)")
    $parenDir = "$testDir\test (x86)\subdir"
    New-Item -ItemType Directory -Force -Path $parenDir | Out-Null
    "content" | Set-Content "$parenDir\test.txt"
    if (Test-Path "$parenDir\test.txt") { Write-Host "  [PASS] Parentheses in path" }
    else { Write-Host "  [FAIL] Parentheses in path"; exit 1 }

    # Test 3: Dots in directory name
    $dotDir = "$testDir\.hidden.dir"
    New-Item -ItemType Directory -Force -Path $dotDir | Out-Null
    "hidden content" | Set-Content "$dotDir\config.txt"
    if (Test-Path "$dotDir\config.txt") { Write-Host "  [PASS] Dots in directory name" }
    else { Write-Host "  [FAIL] Dots in directory name"; exit 1 }

    # Test 4: Hyphens and underscores
    $mixPath = "$testDir\my-app_v2.0\build-output"
    New-Item -ItemType Directory -Force -Path $mixPath | Out-Null
    "artifact" | Set-Content "$mixPath\release-notes_v2.0.md"
    if (Test-Path "$mixPath\release-notes_v2.0.md") { Write-Host "  [PASS] Hyphens and underscores" }
    else { Write-Host "  [FAIL] Hyphens and underscores"; exit 1 }

    # Test 5: JSON with special characters
    $jsonContent = @{
        "name" = "test's app"
        "path" = "C:\Program Files (x86)\My App"
        "version" = "1.0.0-beta+build.123"
        "description" = 'Line 1`nLine 2'
    } | ConvertTo-Json
    Set-Content -Path "$testDir\special.json" -Value $jsonContent
    $parsed = Get-Content "$testDir\special.json" -Raw | ConvertFrom-Json
    if ($parsed.name -eq "test's app") { Write-Host "  [PASS] JSON with special characters" }
    else { Write-Host "  [FAIL] JSON special characters"; exit 1 }

    # Test 6: UTF-8 content
    $utf8Content = "English, 日本語, Español, Deutsch, Français"
    [System.IO.File]::WriteAllText("$testDir\utf8.txt", $utf8Content, [System.Text.Encoding]::UTF8)
    $readBack = [System.IO.File]::ReadAllText("$testDir\utf8.txt", [System.Text.Encoding]::UTF8)
    if ($readBack -eq $utf8Content) { Write-Host "  [PASS] UTF-8 content" }
    else { Write-Host "  [FAIL] UTF-8 content mismatch"; exit 1 }

    Write-Host ""
    Write-Host "All special character tests passed."

} finally {
    Remove-Item -Recurse -Force $testDir -ErrorAction SilentlyContinue
}
