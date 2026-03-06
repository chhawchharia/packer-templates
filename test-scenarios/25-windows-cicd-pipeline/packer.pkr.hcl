# Test 25: Windows CI/CD Pipeline Simulation
# Tests a realistic customer scenario:
#   - file provisioner to copy CI agent setup, build, and cleanup scripts
#   - CI agent directory/cache structure creation
#   - Build simulation with workspace management
#   - Git operations inside the VM (init, commit)
#   - Docker availability check
#   - Artifact creation
#   - Cleanup after build
#
# This tests the full lifecycle a customer would use in a CI pipeline.
#
# Plugin settings:
#   targetOs: windows
#   targetArch: amd64
#   baseImage: windows-server/2022

variable "work_dir" {
  type        = string
  default     = "C:\\BuildAgent"
  description = "CI agent working directory"
}

variable "cache_dir" {
  type        = string
  default     = "C:\\BuildCache"
  description = "Shared cache directory"
}

# Copy CI agent setup script
provisioner "file" {
  source      = "scripts/setup-ci-agent.ps1"
  destination = "C:\\Windows\\Temp\\setup-ci-agent.ps1"
}

# Copy build simulation script
provisioner "file" {
  source      = "scripts/build-simulation.ps1"
  destination = "C:\\Windows\\Temp\\build-simulation.ps1"
}

# Copy cleanup script
provisioner "file" {
  source      = "scripts/cleanup.ps1"
  destination = "C:\\Windows\\Temp\\cleanup.ps1"
}

# Step 1: Set up CI agent
provisioner "powershell" {
  inline = [
    "Write-Host '=== Step 1: Setting up CI agent ==='",
    "$ErrorActionPreference = 'Stop'",
    "& C:\\Windows\\Temp\\setup-ci-agent.ps1 -WorkDir '${var.work_dir}' -CacheDir '${var.cache_dir}'",
    "Write-Host '=== CI agent setup complete ==='"
  ]
}

# Step 2: Verify cache directories exist
provisioner "powershell" {
  inline = [
    "Write-Host '=== Step 2: Verifying cache directories ==='",
    "$ErrorActionPreference = 'Stop'",
    "$dirs = @('npm','nuget','pip','maven','gradle','go','docker')",
    "foreach ($d in $dirs) {",
    "  $path = Join-Path '${var.cache_dir}' $d",
    "  if (Test-Path $path) {",
    "    Write-Host \"  [OK] $path\"",
    "  } else {",
    "    Write-Error \"  [FAIL] Missing cache dir: $path\"",
    "    exit 1",
    "  }",
    "}",
    "Write-Host '=== Cache directories verified ==='"
  ]
}

# Step 3: Run build simulation
provisioner "powershell" {
  inline = [
    "Write-Host '=== Step 3: Running build simulation ==='",
    "$ErrorActionPreference = 'Stop'",
    "& C:\\Windows\\Temp\\build-simulation.ps1 -WorkDir '${var.work_dir}\\workspace'",
    "Write-Host '=== Build simulation complete ==='"
  ]
}

# Step 4: Run cleanup
provisioner "powershell" {
  inline = [
    "Write-Host '=== Step 4: Running cleanup ==='",
    "& C:\\Windows\\Temp\\cleanup.ps1 -WorkDir '${var.work_dir}\\workspace'",
    "Write-Host '=== Cleanup complete ==='"
  ]
}

# Final verification
provisioner "powershell" {
  inline = [
    "Write-Host ''",
    "Write-Host '========================================'",
    "Write-Host '=== CI/CD Pipeline Test Summary     ==='",
    "Write-Host '========================================'",
    "Write-Host \"  Work dir:   $(Test-Path '${var.work_dir}')\"",
    "Write-Host \"  Cache dir:  $(Test-Path '${var.cache_dir}')\"",
    "Write-Host \"  Git:        $(git --version)\"",
    "Write-Host \"  Docker:     $(docker --version)\"",
    "Write-Host '========================================'",
  ]
}
