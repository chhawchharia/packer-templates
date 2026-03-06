$ErrorActionPreference = 'Stop'

Write-Host "========================================"
Write-Host "Test: Network Downloads & Web Requests"
Write-Host "========================================"

$downloadDir = "C:\DownloadTest"
New-Item -ItemType Directory -Force -Path $downloadDir | Out-Null

try {
    # Test 1: Invoke-WebRequest (PowerShell native)
    Write-Host "--- Test 1: Invoke-WebRequest ---"
    try {
        $response = Invoke-WebRequest -Uri "https://httpbin.org/get" -UseBasicParsing -TimeoutSec 30
        if ($response.StatusCode -eq 200) {
            Write-Host "  [PASS] Invoke-WebRequest: HTTP 200"
        } else {
            Write-Host "  [WARN] Invoke-WebRequest: HTTP $($response.StatusCode)"
        }
    } catch {
        Write-Host "  [WARN] Invoke-WebRequest failed (may be network-restricted): $_"
    }

    # Test 2: Invoke-RestMethod (JSON API)
    Write-Host "--- Test 2: Invoke-RestMethod ---"
    try {
        $json = Invoke-RestMethod -Uri "https://httpbin.org/json" -TimeoutSec 30
        if ($json) {
            Write-Host "  [PASS] Invoke-RestMethod: received JSON"
        }
    } catch {
        Write-Host "  [WARN] Invoke-RestMethod failed (may be network-restricted): $_"
    }

    # Test 3: TLS 1.2 (required for most modern APIs/registries)
    Write-Host "--- Test 3: TLS Configuration ---"
    $protocols = [Net.ServicePointManager]::SecurityProtocol
    Write-Host "  Current protocols: $protocols"
    if ($protocols -match "Tls12") {
        Write-Host "  [PASS] TLS 1.2 is enabled"
    } else {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Host "  [INFO] Enabled TLS 1.2"
    }

    # Test 4: Download a file
    Write-Host "--- Test 4: File Download ---"
    try {
        $url = "https://raw.githubusercontent.com/git/git/master/README.md"
        $dest = "$downloadDir\README.md"
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -TimeoutSec 30
        if (Test-Path $dest) {
            $size = (Get-Item $dest).Length
            Write-Host "  [PASS] Downloaded file: $size bytes"
        } else {
            Write-Host "  [WARN] File download produced no output"
        }
    } catch {
        Write-Host "  [WARN] File download failed (may be network-restricted): $_"
    }

    Write-Host ""
    Write-Host "Network tests complete."

} finally {
    Remove-Item -Recurse -Force $downloadDir -ErrorAction SilentlyContinue
}
