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
└── 14-ubuntu2204-go/    # Ubuntu 22.04 AMD64
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

