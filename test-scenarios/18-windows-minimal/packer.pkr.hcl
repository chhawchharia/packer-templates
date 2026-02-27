# Test 18: Windows Minimal
# Tests that an empty Windows Packer file produces a valid image.
# Harness automatically installs: Chocolatey, Git, Git LFS, Docker (Moby),
# git safe.directory *, GCM non-interactive mode, and cleanup.
#
# Plugin settings for this template:
#   targetOs: windows
#   targetArch: amd64
#   baseImage: windows-server/2022
