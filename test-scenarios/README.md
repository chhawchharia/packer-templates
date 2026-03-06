# BYOI Builder Test Scenarios

Comprehensive test suite for validating the BYOI Builder plugin.

## Test Scenarios

### Ubuntu 24.04 (AMD64) - Default

| # | Name | Description | Key Tests |
|---|------|-------------|-----------|
| 01 | minimal | Empty file | Only Harness default provisioners |
| 02 | docker | Docker CE | Full Docker installation |
| 03 | nodejs | Node.js | Node.js + npm + yarn + packages |
| 04 | java-maven | Java | OpenJDK + Maven + Gradle |
| 05 | python-pip | Python | Python 3.12 + pip + poetry |
| 06 | multi-tool | CI environment | Go, Docker, kubectl, Helm |
| 07 | file-scripts | File provisioner | External scripts, relative paths |
| 08 | heredoc-json | Heredocs | JSON configs, bash with braces |
| 09 | variables-complex | Variable types | string, list, map, object, bool |
| 10 | customer-source-ignored | Source handling | Verifies source blocks ignored |

### Other Architectures & Distributions

| # | Name | Arch | OS | Description |
|---|------|------|-----|-------------|
| 11 | arm64-docker | ARM64 | Ubuntu 24.04 | Docker on ARM64 (t2a machines) |
| 12 | debian-docker | AMD64 | Debian 12 | Docker on Debian bookworm |
| 13 | rocky-linux | AMD64 | Rocky 9 | Docker + Go on RHEL-compatible |
| 14 | ubuntu2204-go | AMD64 | Ubuntu 22.04 | Go on older LTS |

### Windows (AMD64) - File Provisioner & Scripts

| # | Name | Description | Key Tests |
|---|------|-------------|-----------|
| 17 | windows-1 | Basic Windows tools | Node.js, Python, .NET via Chocolatey |
| 18 | windows-minimal | Empty (Harness defaults) | Only Harness pre-installed tools |
| 19 | windows-java-dotnet | Java + .NET | Temurin JDK, Maven, Gradle, .NET |
| 20 | windows-nodejs-frontend | Frontend tools | Node.js, Yarn, pnpm, Python |
| 21 | windows-devops | DevOps/infra tools | Go, kubectl, Helm, Terraform, CLIs |
| 22 | windows-full-ci | Full CI environment | All languages + build + cloud tools |
| 23 | windows-file-scripts | File provisioner + scripts | Copy .ps1 to VM, run with params |
| 24 | windows-config-deploy | Config deployment | Dir copy, JSON/YAML config, validation |
| 25 | windows-cicd-pipeline | CI/CD simulation | Agent setup, build sim, git ops, cleanup |
| 26 | windows-env-registry | Env vars & registry | Machine env vars, registry, PATH, persist |
| 27 | windows-edge-cases | Edge cases & stress | Long paths, special chars, network, state |

### Permission Testing (Linux)

| # | Name | Description | Key Tests |
|---|------|-------------|-----------|
| 15 | permission-tests | File provisioner permissions | Script copy, chmod, execution |
| 16 | advanced-permissions | Service user permissions | User/group, elevated, restricted |

## Quick Start

### 1. Run Parser Tests (No GCP Required)

```bash
chmod +x run-parser-tests.sh
./run-parser-tests.sh          # All tests
./run-parser-tests.sh 02       # Docker test only
```

### 2. Build Docker Image for Testing

```bash
cd /path/to/byoiBuilder

# Build for Linux AMD64
docker buildx build \
  --platform linux/amd64 \
  -f docker/Dockerfile.linux.amd64 \
  -t dhirajharness/byoi-builder:v14 \
  --push .
```

### 3. Test with Harness Plugin Step

Use each test's `settings.env` file as reference for plugin configuration:

```yaml
- step:
    type: Plugin
    name: BYOI Build
    identifier: byoi_build
    spec:
      connectorRef: account.docker_hub
      image: dhirajharness/byoi-builder:v14
      settings:
        mode: build
        packerFilePath: test-scenarios/02-docker/packer.pkr.hcl
        imageName: docker-ci
        imageVersion: v1.0.0
        targetOS: linux
        targetArch: amd64
        baseOS: ubuntu
        baseVersion: "24.04"
        debug: "true"
```

## Test Details

### Test 01: Minimal
- **Purpose**: Verify empty files work
- **Provisioners**: None (only Harness defaults)
- **Use case**: Base image with just apt-get update

### Test 02: Docker
- **Purpose**: Install Docker CE with optimal configuration
- **Provisioners**: 3 shell provisioners
- **Use case**: Docker-based CI pipelines

### Test 03: Node.js
- **Purpose**: Node.js development environment
- **Variables**: node_version, npm_packages (list)
- **Use case**: JavaScript/TypeScript projects

### Test 04: Java + Maven
- **Purpose**: Java development environment
- **Variables**: java_version, maven_version, gradle_version
- **Use case**: Java/Kotlin/Scala projects

### Test 05: Python
- **Purpose**: Python development environment
- **Variables**: python_version, pip_packages (list)
- **Use case**: Python projects

### Test 06: Multi-Tool CI
- **Purpose**: Comprehensive CI environment
- **Tools**: Go, Docker, kubectl, Helm, git, make
- **Use case**: Kubernetes-based deployments

### Test 07: File Scripts
- **Purpose**: Test file provisioner with external scripts
- **Files**: setup.sh, config.yaml, app/
- **Use case**: Complex setups with external files

### Test 08: Heredoc JSON
- **Purpose**: Test heredocs with nested braces
- **Features**: JSON configs, bash loops, arrays
- **Use case**: Complex configuration generation

### Test 09: Complex Variables
- **Purpose**: Test all variable types
- **Types**: string, number, bool, list, map, object
- **Use case**: Parameterized builds

### Test 10: Customer Source Ignored
- **Purpose**: Verify source/build blocks are ignored
- **Verifies**: Only variables and provisioners extracted
- **Use case**: Customers migrating existing Packer files

### Test 11: ARM64 Docker
- **Purpose**: Docker installation on ARM64 architecture
- **Machine Type**: t2a-standard-4 (ARM)
- **Use case**: ARM-native builds for Apple Silicon / Graviton

### Test 12: Debian Docker
- **Purpose**: Docker on Debian 12 (bookworm)
- **Package Manager**: apt (Debian-specific repo)
- **Use case**: Customers preferring Debian over Ubuntu

### Test 13: Rocky Linux
- **Purpose**: CI environment on RHEL-compatible OS
- **Package Manager**: dnf/yum
- **Use case**: Enterprise customers requiring RHEL compatibility

### Test 14: Ubuntu 22.04 Go
- **Purpose**: Go development on older LTS
- **Ubuntu Version**: 22.04 LTS (jammy)
- **Use case**: Customers needing older LTS for stability

### Test 23: Windows File Scripts
- **Purpose**: Test file provisioner with external PowerShell scripts on Windows
- **Provisioners**: 3 file + 4 powershell
- **Files**: `scripts/setup-tools.ps1`, `scripts/install-packages.ps1`, `scripts/verify-env.ps1`
- **Tests**:
  - Copy `.ps1` files to VM via file provisioner
  - Run scripts with parameters (`-ToolsDir`, `-AppName`)
  - Script-based Chocolatey package installation
  - Health check from deployed script
  - Environment verification
- **Use case**: Customers with existing setup scripts

### Test 24: Windows Config Deployment
- **Purpose**: Test config file deployment with directory copy
- **Provisioners**: 3 file + 4 powershell
- **Files**: `scripts/config/` (JSON, YAML, PS1), `scripts/setup/` (deploy, validate)
- **Tests**:
  - Directory copy via file provisioner (trailing slash)
  - JSON config deserialization and validation
  - YAML content verification
  - Directory structure creation from script
  - Cross-provisioner config reading
- **Use case**: Customers deploying application configurations

### Test 25: Windows CI/CD Pipeline Simulation
- **Purpose**: Simulate a realistic CI/CD agent setup and build flow
- **Provisioners**: 3 file + 5 powershell
- **Files**: `scripts/setup-ci-agent.ps1`, `scripts/build-simulation.ps1`, `scripts/cleanup.ps1`
- **Tests**:
  - CI agent directory + cache structure creation
  - npm/pip/Go cache directory configuration
  - Build simulation with workspace management
  - Git operations inside VM (init, commit)
  - Artifact creation and cleanup
- **Use case**: Customers setting up CI agent infrastructure

### Test 26: Windows Environment & Registry
- **Purpose**: Test environment variable and registry configuration via scripts
- **Provisioners**: 3 file + 4 powershell
- **Files**: `scripts/set-environment.ps1`, `scripts/configure-registry.ps1`, `scripts/verify-settings.ps1`
- **Tests**:
  - Machine-level environment variable creation
  - PATH manipulation from script
  - Registry modifications (LongPaths, WER, crash dump)
  - Cross-provisioner persistence verification
  - Inline + script validation mixing
- **Use case**: Customers needing system-level configuration

### Test 27: Windows Edge Cases
- **Purpose**: Catch corner cases before customers do
- **Provisioners**: 4 file + 1 script + 9 powershell
- **Files**: `scripts/test-*.ps1`, `scripts/app/` (Dockerfile, app.txt)
- **Tests**:
  - Long file paths (> 260 characters)
  - Special characters in filenames (spaces, parens, dots, hyphens, UTF-8)
  - Network downloads (Invoke-WebRequest, TLS config)
  - Directory copy via file provisioner
  - Inline JSON creation (heredoc-style)
  - Docker availability check
  - Cross-provisioner state persistence (env vars + files)
  - PowerShell `script` attribute (Packer auto-upload)
- **Use case**: Pre-testing edge cases to prevent customer issues

### Test 15: Permission Tests
- **Purpose**: Comprehensive file provisioner permission testing
- **Tests**: Script copying, chmod, execution verification
- **Features**: 
  - File provisioner with multiple source directories
  - Automatic permission setting after copy
  - Script execution in various contexts
  - Permission validation scripts
- **Scripts**:
  - `scripts/setup/01-init.sh` - System initialization
  - `scripts/setup/02-packages.sh` - Package installation with retry
  - `scripts/setup/03-configure.sh` - System configuration
  - `scripts/validation/check-permissions.sh` - Permission validation
  - `scripts/validation/verify-all.sh` - Comprehensive verification
- **Local Testing**: Run `./run-local-test.sh` to test scripts locally

### Test 16: Advanced Permissions
- **Purpose**: Complex permission scenarios for production environments
- **Tests**: Service users, elevated privileges, restricted configs
- **Features**:
  - Service user/group creation
  - Secure directory structure with proper ownership
  - Elevated scripts requiring root
  - Restricted config files (640 permissions)
  - Umask verification
  - Systemd service file permissions
- **Scripts**:
  - `scripts/secured/` - Scripts owned by service user
  - `scripts/elevated/` - Scripts requiring root privileges
  - `scripts/restricted/` - Read-only configuration files

## Directory Structure

```
test-scenarios/
├── README.md
├── run-parser-tests.sh
│
├── 01-minimal/          # Ubuntu 24.04 AMD64
├── 02-docker/           # Ubuntu 24.04 AMD64
├── 03-nodejs/           # Ubuntu 24.04 AMD64
├── 04-java-maven/       # Ubuntu 24.04 AMD64
├── 05-python-pip/       # Ubuntu 24.04 AMD64
├── 06-multi-tool/       # Ubuntu 24.04 AMD64
├── 07-file-scripts/     # Ubuntu 24.04 AMD64 + scripts/
├── 08-heredoc-json/     # Ubuntu 24.04 AMD64
├── 09-variables-complex/# Ubuntu 24.04 AMD64
├── 10-customer-source-ignored/  # Ubuntu 24.04 AMD64
│
├── 11-arm64-docker/     # Ubuntu 24.04 ARM64
├── 12-debian-docker/    # Debian 12 AMD64
├── 13-rocky-linux/      # Rocky Linux 9 AMD64
├── 14-ubuntu2204-go/    # Ubuntu 22.04 AMD64
│
├── 15-permission-tests/ # Permission testing
│   ├── packer.pkr.hcl
│   ├── settings.env
│   ├── run-local-test.sh
│   └── scripts/
│       ├── setup/
│       ├── validation/
│       └── config/
│
├── 16-advanced-permissions/  # Advanced permission scenarios
│   ├── packer.pkr.hcl
│   ├── settings.env
│   └── scripts/
│       ├── secured/
│       ├── elevated/
│       └── restricted/
│
├── 17-windows-1/            # Windows basic tools
├── 18-windows-minimal/      # Windows minimal (no provisioners)
├── 19-windows-java-dotnet/  # Windows Java + .NET
├── 20-windows-nodejs-frontend/  # Windows frontend tools
├── 21-windows-devops/       # Windows DevOps tools
├── 22-windows-full-ci/      # Windows full CI environment
│
├── 23-windows-file-scripts/ # Windows file provisioner + scripts
│   ├── packer.pkr.hcl
│   └── scripts/
│       ├── setup-tools.ps1
│       ├── install-packages.ps1
│       └── verify-env.ps1
│
├── 24-windows-config-deploy/ # Windows config deployment
│   ├── packer.pkr.hcl
│   └── scripts/
│       ├── config/           # JSON, YAML, PS1 configs
│       └── setup/            # Deploy + validate scripts
│
├── 25-windows-cicd-pipeline/ # Windows CI/CD simulation
│   ├── packer.pkr.hcl
│   └── scripts/
│       ├── setup-ci-agent.ps1
│       ├── build-simulation.ps1
│       └── cleanup.ps1
│
├── 26-windows-env-registry/  # Windows env vars + registry
│   ├── packer.pkr.hcl
│   └── scripts/
│       ├── set-environment.ps1
│       ├── configure-registry.ps1
│       └── verify-settings.ps1
│
└── 27-windows-edge-cases/    # Windows edge cases
    ├── packer.pkr.hcl
    └── scripts/
        ├── test-long-paths.ps1
        ├── test-special-chars.ps1
        ├── test-network-download.ps1
        ├── test-script-provisioner.ps1
        └── app/              # Dockerfile + app.txt
```

Each test directory contains:
- `packer.pkr.hcl` - Packer configuration
- `settings.env` - Plugin settings for testing

## Verification Checklist

When testing, verify:

- [ ] Generated file has `source "googlecompute" "harness-byoi"`
- [ ] Customer source blocks are NOT in generated file
- [ ] Customer variables ARE in generated file
- [ ] Customer provisioners ARE in generated file (in order)
- [ ] Harness pre-install provisioner runs first
- [ ] Harness cleanup provisioner runs last
- [ ] `GOOGLE_OAUTH_ACCESS_TOKEN` is used for auth
- [ ] Access token is marked `sensitive = true`
- [ ] File provisioner relative paths work
- [ ] Heredocs with braces don't break parsing

### Windows Testing Checklist (Tests 17-27)

- [ ] File provisioner copies `.ps1` scripts to VM
- [ ] File provisioner copies directories (trailing slash = contents)
- [ ] Copied scripts execute correctly with `& script.ps1 -Param value`
- [ ] PowerShell `script` attribute auto-uploads and runs scripts
- [ ] Variables interpolate correctly in paths (backslash handling)
- [ ] JSON/YAML config files parse correctly after copy
- [ ] Machine-level env vars persist across provisioners
- [ ] Registry modifications (LongPaths, WER) are applied
- [ ] PATH additions survive across provisioner boundaries
- [ ] Long file paths (> 260 chars) work when LongPaths is enabled
- [ ] Special characters in filenames work (spaces, parens, dots)
- [ ] UTF-8 content reads/writes correctly
- [ ] Network downloads work (Invoke-WebRequest, TLS 1.2)
- [ ] Git operations work inside the VM
- [ ] Docker CLI is accessible
- [ ] Cross-provisioner state persists (files + env vars)

### Permission Testing Checklist (Tests 15-16)

- [ ] Scripts are copied via file provisioner
- [ ] Scripts have executable permissions after copy (755)
- [ ] Scripts can be executed without permission errors
- [ ] Config files have restrictive permissions (644 or 640)
- [ ] Directory permissions are correct (755 or 750)
- [ ] Service user scripts work with correct ownership
- [ ] Elevated scripts require root to execute
- [ ] No world-writable files in secure directories
- [ ] Secrets directory has 700 permissions
- [ ] Systemd service files have 644 permissions

