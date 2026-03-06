# Test 27: Windows Edge Cases & Stress Tests
# Tests corner cases that customers commonly hit:
#   - Long file paths (> 260 chars)
#   - Special characters in filenames and content (spaces, parens, UTF-8)
#   - Network downloads (Invoke-WebRequest, TLS config)
#   - File provisioner with directory copy (app/ folder with Dockerfile)
#   - JSON/YAML creation inline (heredoc-style)
#   - Large environment variable manipulation
#   - Mixed provisioner types (file + powershell)
#   - PowerShell "script" attribute (Packer auto-uploads and runs)
#   - Docker availability check
#   - Cross-provisioner state persistence
#
# This scenario is designed to catch issues before customers do.
#
# Plugin settings:
#   targetOs: windows
#   targetArch: amd64
#   baseImage: windows-server/2022

# Copy test scripts
provisioner "file" {
  source      = "scripts/test-long-paths.ps1"
  destination = "C:\\Windows\\Temp\\test-long-paths.ps1"
}

provisioner "file" {
  source      = "scripts/test-special-chars.ps1"
  destination = "C:\\Windows\\Temp\\test-special-chars.ps1"
}

provisioner "file" {
  source      = "scripts/test-network-download.ps1"
  destination = "C:\\Windows\\Temp\\test-network-download.ps1"
}

# Copy app directory (tests directory copy via file provisioner)
provisioner "file" {
  source      = "scripts/app/"
  destination = "C:\\Windows\\Temp\\test-app"
}

# ============================================================================
# Test 1: Long Paths
# ============================================================================
provisioner "powershell" {
  inline = [
    "Write-Host '=== Test 1: Long Paths ==='",
    "$ErrorActionPreference = 'Stop'",
    "& C:\\Windows\\Temp\\test-long-paths.ps1",
    "Write-Host '=== Long Paths: PASSED ==='"
  ]
}

# ============================================================================
# Test 2: Special Characters
# ============================================================================
provisioner "powershell" {
  inline = [
    "Write-Host '=== Test 2: Special Characters ==='",
    "$ErrorActionPreference = 'Stop'",
    "& C:\\Windows\\Temp\\test-special-chars.ps1",
    "Write-Host '=== Special Characters: PASSED ==='"
  ]
}

# ============================================================================
# Test 3: Network Downloads
# ============================================================================
provisioner "powershell" {
  inline = [
    "Write-Host '=== Test 3: Network Downloads ==='",
    "& C:\\Windows\\Temp\\test-network-download.ps1",
    "Write-Host '=== Network Downloads: PASSED ==='"
  ]
}

# ============================================================================
# Test 4: Directory copy verification
# ============================================================================
provisioner "powershell" {
  inline = [
    "Write-Host '=== Test 4: Directory Copy ==='",
    "$ErrorActionPreference = 'Stop'",
    "Write-Host 'Checking copied app directory...'",
    "if (Test-Path 'C:\\Windows\\Temp\\test-app\\Dockerfile') {",
    "  Write-Host '  [PASS] Dockerfile found'",
    "  Get-Content 'C:\\Windows\\Temp\\test-app\\Dockerfile' | ForEach-Object { Write-Host \"    $_\" }",
    "} else {",
    "  Write-Error 'Dockerfile not found in copied directory'",
    "  exit 1",
    "}",
    "if (Test-Path 'C:\\Windows\\Temp\\test-app\\app.txt') {",
    "  Write-Host '  [PASS] app.txt found'",
    "} else {",
    "  Write-Error 'app.txt not found in copied directory'",
    "  exit 1",
    "}",
    "Write-Host '=== Directory Copy: PASSED ==='"
  ]
}

# ============================================================================
# Test 5: Inline JSON/config creation (heredoc-style pattern)
# ============================================================================
provisioner "powershell" {
  inline = [
    "Write-Host '=== Test 5: Inline JSON creation ==='",
    "$ErrorActionPreference = 'Stop'",
    "$config = @{",
    "  application = @{",
    "    name = 'edge-case-tester'",
    "    version = '1.0.0'",
    "    features = @('long-paths', 'special-chars', 'network', 'docker')",
    "  }",
    "  build = @{",
    "    timestamp = (Get-Date).ToString('o')",
    "    machine = $env:COMPUTERNAME",
    "    os = [System.Environment]::OSVersion.VersionString",
    "  }",
    "}",
    "$json = $config | ConvertTo-Json -Depth 5",
    "$json | Set-Content 'C:\\Windows\\Temp\\build-config.json'",
    "Write-Host 'Created build-config.json:'",
    "Get-Content 'C:\\Windows\\Temp\\build-config.json' | ForEach-Object { Write-Host \"  $_\" }",
    "$readBack = Get-Content 'C:\\Windows\\Temp\\build-config.json' -Raw | ConvertFrom-Json",
    "if ($readBack.application.name -eq 'edge-case-tester') {",
    "  Write-Host '  [PASS] JSON roundtrip succeeded'",
    "} else {",
    "  Write-Error 'JSON roundtrip failed'",
    "  exit 1",
    "}",
    "Write-Host '=== Inline JSON: PASSED ==='"
  ]
}

# ============================================================================
# Test 6: Docker availability
# ============================================================================
provisioner "powershell" {
  inline = [
    "Write-Host '=== Test 6: Docker Availability ==='",
    "try {",
    "  $dockerVer = docker --version 2>&1",
    "  Write-Host \"  Docker version: $dockerVer\"",
    "  Write-Host '  [PASS] Docker is available'",
    "} catch {",
    "  Write-Host '  [WARN] Docker not available (expected if docker not pre-installed)'",
    "}",
    "Write-Host '=== Docker Check: DONE ==='"
  ]
}

# ============================================================================
# Test 7: Cross-provisioner state persistence
# ============================================================================
provisioner "powershell" {
  inline = [
    "Write-Host '=== Test 7a: Setting state ==='",
    "[Environment]::SetEnvironmentVariable('EDGE_TEST_MARKER', 'provisioner-state-test', 'Machine')",
    "$markerPath = 'C:\\Windows\\Temp\\edge-test-marker.txt'",
    "'marker-from-provisioner-7a' | Set-Content $markerPath",
    "Write-Host '  Set machine env var EDGE_TEST_MARKER'",
    "Write-Host '  Created marker file'",
    "Write-Host '=== State set ==='"
  ]
}

provisioner "powershell" {
  inline = [
    "Write-Host '=== Test 7b: Verifying state from previous provisioner ==='",
    "$ErrorActionPreference = 'Stop'",
    "$marker = [Environment]::GetEnvironmentVariable('EDGE_TEST_MARKER', 'Machine')",
    "if ($marker -eq 'provisioner-state-test') {",
    "  Write-Host '  [PASS] Machine env var persisted across provisioners'",
    "} else {",
    "  Write-Error 'Machine env var not found across provisioners'",
    "  exit 1",
    "}",
    "$fileMarker = Get-Content 'C:\\Windows\\Temp\\edge-test-marker.txt'",
    "if ($fileMarker -eq 'marker-from-provisioner-7a') {",
    "  Write-Host '  [PASS] File marker persisted across provisioners'",
    "} else {",
    "  Write-Error 'File marker not found across provisioners'",
    "  exit 1",
    "}",
    "Write-Host '=== State persistence: PASSED ==='"
  ]
}

# ============================================================================
# Test 8: PowerShell "script" attribute (Packer auto-uploads + runs)
# ============================================================================
provisioner "powershell" {
  script = "scripts/test-script-provisioner.ps1"
}

# ============================================================================
# Final Summary
# ============================================================================
provisioner "powershell" {
  inline = [
    "Write-Host ''",
    "Write-Host '================================================================'",
    "Write-Host '         Edge Case Test Suite - Summary                         '",
    "Write-Host '================================================================'",
    "Write-Host '  1. Long Paths (> 260 chars)        : PASSED'",
    "Write-Host '  2. Special Characters               : PASSED'",
    "Write-Host '  3. Network Downloads                : PASSED'",
    "Write-Host '  4. Directory Copy (file prov.)      : PASSED'",
    "Write-Host '  5. Inline JSON Creation             : PASSED'",
    "Write-Host '  6. Docker Availability              : CHECKED'",
    "Write-Host '  7. Cross-Provisioner State          : PASSED'",
    "Write-Host '  8. Script Provisioner (auto-upload) : PASSED'",
    "Write-Host '================================================================'",
    "Write-Host '  All edge case tests completed successfully!'",
    "Write-Host '================================================================'"
  ]
}
