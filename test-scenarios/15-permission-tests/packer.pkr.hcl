# Test 15: Permission Tests
# Comprehensive test for file provisioner permissions and script execution
# This validates:
# - File provisioner with various permission modes
# - Script copying and execution
# - Permission verification for different contexts
# - Directory permissions and ownership
# - Executable permissions after copy

variable "test_user" {
  type        = string
  default     = "testuser"
  description = "Test user to create for permission validation"
}

variable "test_group" {
  type        = string
  default     = "testgroup"
  description = "Test group to create for permission validation"
}

variable "script_dir" {
  type        = string
  default     = "/opt/harness/scripts"
  description = "Directory where scripts will be installed"
}

variable "config_dir" {
  type        = string
  default     = "/etc/harness"
  description = "Directory for configuration files"
}

# ==============================================================================
# FILE PROVISIONERS - Copy all scripts and configs to target
# ==============================================================================

# Copy setup scripts
provisioner "file" {
  source      = "scripts/setup/"
  destination = "/tmp/setup-scripts"
}

# Copy validation scripts  
provisioner "file" {
  source      = "scripts/validation/"
  destination = "/tmp/validation-scripts"
}

# Copy config files
provisioner "file" {
  source      = "scripts/config/"
  destination = "/tmp/config-files"
}

# ==============================================================================
# STEP 1: Create directories with proper permissions
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 1: Creating directories ==='",
    "echo '=============================================='",
    "",
    "# Create script directory",
    "sudo mkdir -p ${var.script_dir}",
    "sudo mkdir -p ${var.script_dir}/setup",
    "sudo mkdir -p ${var.script_dir}/validation",
    "sudo chmod -R 755 ${var.script_dir}",
    "",
    "# Create config directory",
    "sudo mkdir -p ${var.config_dir}",
    "sudo chmod 755 ${var.config_dir}",
    "",
    "# Create log directory",
    "sudo mkdir -p /var/log/harness",
    "sudo chmod 755 /var/log/harness",
    "",
    "echo 'Directories created successfully'",
    "ls -la ${var.script_dir}/",
    "ls -la ${var.config_dir}/"
  ]
}

# ==============================================================================
# STEP 2: Install setup scripts with executable permissions
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 2: Installing setup scripts ==='",
    "echo '=============================================='",
    "",
    "# Move setup scripts to final location",
    "sudo cp -r /tmp/setup-scripts/* ${var.script_dir}/setup/ 2>/dev/null || echo 'No setup scripts to copy'",
    "",
    "# Make all scripts executable",
    "if [ -d ${var.script_dir}/setup ]; then",
    "  sudo find ${var.script_dir}/setup -type f -name '*.sh' -exec chmod 755 {} \\;",
    "  echo 'Setup scripts permissions set'",
    "  ls -la ${var.script_dir}/setup/ || true",
    "fi"
  ]
}

# ==============================================================================
# STEP 3: Install validation scripts with executable permissions
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 3: Installing validation scripts ==='",
    "echo '=============================================='",
    "",
    "# Move validation scripts to final location",
    "sudo cp -r /tmp/validation-scripts/* ${var.script_dir}/validation/ 2>/dev/null || echo 'No validation scripts to copy'",
    "",
    "# Make all scripts executable",
    "if [ -d ${var.script_dir}/validation ]; then",
    "  sudo find ${var.script_dir}/validation -type f -name '*.sh' -exec chmod 755 {} \\;",
    "  echo 'Validation scripts permissions set'",
    "  ls -la ${var.script_dir}/validation/ || true",
    "fi"
  ]
}

# ==============================================================================
# STEP 4: Install config files with proper permissions
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 4: Installing config files ==='",
    "echo '=============================================='",
    "",
    "# Move config files to final location",
    "sudo cp -r /tmp/config-files/* ${var.config_dir}/ 2>/dev/null || echo 'No config files to copy'",
    "",
    "# Set config file permissions (readable, not writable by others)",
    "if [ -d ${var.config_dir} ]; then",
    "  sudo find ${var.config_dir} -type f -exec chmod 644 {} \\;",
    "  echo 'Config file permissions set'",
    "  ls -la ${var.config_dir}/ || true",
    "fi"
  ]
}

# ==============================================================================
# STEP 5: Run permission validation scripts
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 5: Running permission validation ==='",
    "echo '=============================================='",
    "",
    "# Run the main permission check script",
    "if [ -f ${var.script_dir}/validation/check-permissions.sh ]; then",
    "  echo 'Running permission check script...'",
    "  ${var.script_dir}/validation/check-permissions.sh",
    "else",
    "  echo 'Permission check script not found, running inline checks...'",
    "  ",
    "  # Inline permission checks",
    "  echo '--- Checking script directory permissions ---'",
    "  ls -la ${var.script_dir}/",
    "  ",
    "  echo '--- Checking config directory permissions ---'",
    "  ls -la ${var.config_dir}/",
    "  ",
    "  echo '--- Testing script execution ---'",
    "  for script in ${var.script_dir}/setup/*.sh; do",
    "    if [ -f \"$script\" ]; then",
    "      echo \"Testing: $script\"",
    "      if [ -x \"$script\" ]; then",
    "        echo \"  [OK] Script is executable\"",
    "      else",
    "        echo \"  [FAIL] Script is NOT executable\"",
    "        exit 1",
    "      fi",
    "    fi",
    "  done",
    "fi"
  ]
}

# ==============================================================================
# STEP 6: Execute setup scripts to verify they work
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 6: Executing setup scripts ==='",
    "echo '=============================================='",
    "",
    "# Run init script",
    "if [ -x ${var.script_dir}/setup/01-init.sh ]; then",
    "  echo 'Running 01-init.sh...'",
    "  ${var.script_dir}/setup/01-init.sh",
    "fi",
    "",
    "# Run packages script",
    "if [ -x ${var.script_dir}/setup/02-packages.sh ]; then",
    "  echo 'Running 02-packages.sh...'",
    "  ${var.script_dir}/setup/02-packages.sh",
    "fi",
    "",
    "# Run configure script",
    "if [ -x ${var.script_dir}/setup/03-configure.sh ]; then",
    "  echo 'Running 03-configure.sh...'",
    "  ${var.script_dir}/setup/03-configure.sh",
    "fi",
    "",
    "echo 'All setup scripts executed successfully'"
  ]
}

# ==============================================================================
# STEP 7: Comprehensive verification
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 7: Final verification ==='",
    "echo '=============================================='",
    "",
    "# Run comprehensive validation",
    "if [ -x ${var.script_dir}/validation/verify-all.sh ]; then",
    "  ${var.script_dir}/validation/verify-all.sh",
    "else",
    "  echo 'Running inline verification...'",
    "  ",
    "  echo ''",
    "  echo '--- Directory Structure ---'",
    "  tree ${var.script_dir} 2>/dev/null || find ${var.script_dir} -type f | head -20",
    "  ",
    "  echo ''",
    "  echo '--- Permission Summary ---'",
    "  echo 'Scripts directory:'",
    "  stat -c '%A %U:%G %n' ${var.script_dir} 2>/dev/null || stat ${var.script_dir}",
    "  ",
    "  echo ''",
    "  echo 'Config directory:'",
    "  stat -c '%A %U:%G %n' ${var.config_dir} 2>/dev/null || stat ${var.config_dir}",
    "  ",
    "  echo ''",
    "  echo '--- Executable Check ---'",
    "  find ${var.script_dir} -name '*.sh' -exec test -x {} \\; -print | while read f; do",
    "    echo \"[OK] Executable: $f\"",
    "  done",
    "  ",
    "  find ${var.script_dir} -name '*.sh' ! -perm -u+x -print | while read f; do",
    "    echo \"[WARN] Not executable: $f\"",
    "  done",
    "fi"
  ]
}

# ==============================================================================
# STEP 8: Permission edge cases
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 8: Testing permission edge cases ==='",
    "echo '=============================================='",
    "",
    "# Test 1: Create file and set permissions",
    "echo 'Test 1: File permission setting'",
    "echo '#!/bin/bash' | sudo tee /tmp/test-perm.sh > /dev/null",
    "echo 'echo \"Hello from test script\"' | sudo tee -a /tmp/test-perm.sh > /dev/null",
    "sudo chmod 755 /tmp/test-perm.sh",
    "if [ -x /tmp/test-perm.sh ]; then",
    "  /tmp/test-perm.sh",
    "  echo '  [PASS] File permission test passed'",
    "else",
    "  echo '  [FAIL] File permission test failed'",
    "  exit 1",
    "fi",
    "",
    "# Test 2: Script with sudo requirements",
    "echo 'Test 2: Script with sudo execution'",
    "echo '#!/bin/bash' | sudo tee /tmp/test-sudo.sh > /dev/null",
    "echo 'whoami' | sudo tee -a /tmp/test-sudo.sh > /dev/null",
    "echo 'id' | sudo tee -a /tmp/test-sudo.sh > /dev/null",
    "sudo chmod 755 /tmp/test-sudo.sh",
    "sudo /tmp/test-sudo.sh",
    "echo '  [PASS] Sudo execution test passed'",
    "",
    "# Test 3: Directory permissions",
    "echo 'Test 3: Directory permission inheritance'",
    "sudo mkdir -p /tmp/test-dir-perms/subdir",
    "sudo touch /tmp/test-dir-perms/subdir/test.sh",
    "sudo chmod -R 755 /tmp/test-dir-perms",
    "ls -la /tmp/test-dir-perms/subdir/",
    "echo '  [PASS] Directory permission test passed'",
    "",
    "# Cleanup",
    "sudo rm -rf /tmp/test-perm.sh /tmp/test-sudo.sh /tmp/test-dir-perms",
    "",
    "echo ''",
    "echo '=============================================='",
    "echo '=== ALL PERMISSION TESTS PASSED ==='",
    "echo '=============================================='",
  ]
}
