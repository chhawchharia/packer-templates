param(
    [string]$WorkDir  = "C:\BuildAgent\workspace",
    [string]$RepoUrl  = ""
)

$ErrorActionPreference = 'Stop'

Write-Host "========================================"
Write-Host "Build Simulation - CI Pipeline Test"
Write-Host "========================================"

# Step 1: Verify essential tools
Write-Host ""
Write-Host "--- Step 1: Tool Verification ---"
$tools = @(
    @{ Name = "git";    Cmd = "git --version" },
    @{ Name = "docker"; Cmd = "docker --version" }
)

foreach ($tool in $tools) {
    try {
        $result = Invoke-Expression $tool.Cmd 2>&1
        Write-Host "  [OK] $($tool.Name): $result"
    } catch {
        Write-Host "  [FAIL] $($tool.Name): not found"
        exit 1
    }
}

# Step 2: Simulate workspace setup
Write-Host ""
Write-Host "--- Step 2: Workspace Setup ---"
$projectDir = Join-Path $WorkDir "test-project"
New-Item -ItemType Directory -Force -Path $projectDir | Out-Null

# Create a dummy build file
$buildScript = @'
Write-Host "Building project..."
Write-Host "Compiling sources... [OK]"
Write-Host "Running unit tests... [OK]"
Write-Host "Build successful."
exit 0
'@
Set-Content -Path "$projectDir\build.ps1" -Value $buildScript

# Step 3: Run the build
Write-Host ""
Write-Host "--- Step 3: Build Execution ---"
& "$projectDir\build.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed with exit code $LASTEXITCODE"
    exit 1
}

# Step 4: Simulate artifact creation
Write-Host ""
Write-Host "--- Step 4: Artifact Creation ---"
$artifactDir = Join-Path $WorkDir "artifacts"
New-Item -ItemType Directory -Force -Path $artifactDir | Out-Null
"Build artifact v1.0.0 - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Set-Content "$artifactDir\release.txt"
Write-Host "  Artifact created: $artifactDir\release.txt"

# Step 5: Verify git operations
Write-Host ""
Write-Host "--- Step 5: Git Operations ---"
Push-Location $projectDir
git init 2>&1 | Out-Null
git config user.email "ci@harness.io"
git config user.name "CI Agent"
"test file" | Set-Content "test.txt"
git add . 2>&1 | Out-Null
git commit -m "initial" 2>&1 | Out-Null
$hash = git rev-parse HEAD
Write-Host "  Git init + commit: OK (commit $hash)"
Pop-Location

Write-Host ""
Write-Host "========================================"
Write-Host "Build simulation completed successfully"
Write-Host "========================================"
