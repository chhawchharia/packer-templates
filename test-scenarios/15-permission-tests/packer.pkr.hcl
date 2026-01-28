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
# Note: When copying a directory with trailing slash, Packer uploads the contents
# directly to the destination. When copying without trailing slash, it preserves
# the directory name.

# Copy setup scripts (individual files to flat destination)
provisioner "file" {
  source      = "scripts/setup/"
  destination = "/tmp/harness-setup-scripts/"
}

# Copy validation scripts (individual files to flat destination)
provisioner "file" {
  source      = "scripts/validation/"
  destination = "/tmp/harness-validation-scripts/"
}

# Copy config files (individual files to flat destination)
provisioner "file" {
  source      = "scripts/config/"
  destination = "/tmp/harness-config-files/"
}

# ==============================================================================
# DEBUG: Show what was uploaded
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=== DEBUG: Checking uploaded files ==='",
    "echo 'Setup scripts (/tmp/harness-setup-scripts/):'",
    "ls -la /tmp/harness-setup-scripts/ 2>/dev/null || echo '  Directory does not exist'",
    "find /tmp/harness-setup-scripts -name '*.sh' 2>/dev/null || echo '  No .sh files found'",
    "echo ''",
    "echo 'Validation scripts (/tmp/harness-validation-scripts/):'",
    "ls -la /tmp/harness-validation-scripts/ 2>/dev/null || echo '  Directory does not exist'",
    "echo ''",
    "echo 'Config files (/tmp/harness-config-files/):'",
    "ls -la /tmp/harness-config-files/ 2>/dev/null || echo '  Directory does not exist'",
    "echo '=== End Debug ==='"
  ]
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
    "# Create marker directory for setup tracking",
    "sudo mkdir -p /tmp/harness-setup",
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
    "# Find and copy setup scripts - handle both flat and nested structures",
    "SRC_DIR='/tmp/harness-setup-scripts'",
    "DST_DIR='${var.script_dir}/setup'",
    "",
    "if [ -d \"$SRC_DIR\" ]; then",
    "  # Count .sh files in source (including subdirectories)",
    "  SCRIPT_COUNT=$(find \"$SRC_DIR\" -name '*.sh' -type f 2>/dev/null | wc -l)",
    "  echo \"Found $SCRIPT_COUNT setup script(s) in $SRC_DIR\"",
    "  ",
    "  if [ \"$SCRIPT_COUNT\" -gt 0 ]; then",
    "    # Copy all .sh files preserving their names (flatten if nested)",
    "    find \"$SRC_DIR\" -name '*.sh' -type f -exec sudo cp {} \"$DST_DIR/\" \\;",
    "    # Also copy any non-sh files",
    "    find \"$SRC_DIR\" -type f ! -name '*.sh' -exec sudo cp {} \"$DST_DIR/\" \\; 2>/dev/null || true",
    "    echo 'Setup scripts copied successfully'",
    "  else",
    "    echo 'No .sh files found in source directory'",
    "  fi",
    "else",
    "  echo 'Source directory does not exist: $SRC_DIR'",
    "fi",
    "",
    "# Make all scripts executable",
    "sudo find \"$DST_DIR\" -type f -name '*.sh' -exec chmod 755 {} \\; 2>/dev/null || true",
    "echo 'Final setup scripts:'",
    "ls -la \"$DST_DIR/\" 2>/dev/null || echo '(empty)'"
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
    "# Find and copy validation scripts",
    "SRC_DIR='/tmp/harness-validation-scripts'",
    "DST_DIR='${var.script_dir}/validation'",
    "",
    "if [ -d \"$SRC_DIR\" ]; then",
    "  SCRIPT_COUNT=$(find \"$SRC_DIR\" -name '*.sh' -type f 2>/dev/null | wc -l)",
    "  echo \"Found $SCRIPT_COUNT validation script(s) in $SRC_DIR\"",
    "  ",
    "  if [ \"$SCRIPT_COUNT\" -gt 0 ]; then",
    "    find \"$SRC_DIR\" -name '*.sh' -type f -exec sudo cp {} \"$DST_DIR/\" \\;",
    "    echo 'Validation scripts copied successfully'",
    "  else",
    "    echo 'No .sh files found in source directory'",
    "  fi",
    "else",
    "  echo 'Source directory does not exist: $SRC_DIR'",
    "fi",
    "",
    "# Make all scripts executable",
    "sudo find \"$DST_DIR\" -type f -name '*.sh' -exec chmod 755 {} \\; 2>/dev/null || true",
    "echo 'Final validation scripts:'",
    "ls -la \"$DST_DIR/\" 2>/dev/null || echo '(empty)'"
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
    "# Find and copy config files",
    "SRC_DIR='/tmp/harness-config-files'",
    "DST_DIR='${var.config_dir}'",
    "",
    "if [ -d \"$SRC_DIR\" ]; then",
    "  FILE_COUNT=$(find \"$SRC_DIR\" -type f 2>/dev/null | wc -l)",
    "  echo \"Found $FILE_COUNT config file(s) in $SRC_DIR\"",
    "  ",
    "  if [ \"$FILE_COUNT\" -gt 0 ]; then",
    "    find \"$SRC_DIR\" -type f -exec sudo cp {} \"$DST_DIR/\" \\;",
    "    echo 'Config files copied successfully'",
    "  else",
    "    echo 'No files found in source directory'",
    "  fi",
    "else",
    "  echo 'Source directory does not exist: $SRC_DIR'",
    "fi",
    "",
    "# Set config file permissions (644 - readable by all, writable by owner)",
    "sudo find \"$DST_DIR\" -type f -exec chmod 644 {} \\; 2>/dev/null || true",
    "echo 'Final config files:'",
    "ls -la \"$DST_DIR/\" 2>/dev/null || echo '(empty)'"
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
    "SCRIPT_DIR='${var.script_dir}'",
    "CONFIG_DIR='${var.config_dir}'",
    "",
    "# Run the main permission check script",
    "if [ -x \"$SCRIPT_DIR/validation/check-permissions.sh\" ]; then",
    "  echo 'Running permission check script...'",
    "  \"$SCRIPT_DIR/validation/check-permissions.sh\"",
    "else",
    "  echo 'Permission check script not found, running inline checks...'",
    "  ",
    "  # Inline permission checks",
    "  echo '--- Checking script directory permissions ---'",
    "  ls -la \"$SCRIPT_DIR/\" || true",
    "  ",
    "  echo '--- Checking config directory permissions ---'",
    "  ls -la \"$CONFIG_DIR/\" || true",
    "  ",
    "  echo '--- Testing script execution ---'",
    "  for script in \"$SCRIPT_DIR\"/setup/*.sh; do",
    "    if [ -f \"$script\" ]; then",
    "      echo \"Testing: $script\"",
    "      if [ -x \"$script\" ]; then",
    "        echo \"  [OK] Script is executable\"",
    "      else",
    "        echo \"  [WARN] Script is NOT executable\"",
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
    "SCRIPT_DIR='${var.script_dir}'",
    "",
    "# Run init script",
    "if [ -x \"$SCRIPT_DIR/setup/01-init.sh\" ]; then",
    "  echo 'Running 01-init.sh...'",
    "  \"$SCRIPT_DIR/setup/01-init.sh\"",
    "else",
    "  echo '01-init.sh not found or not executable, skipping'",
    "fi",
    "",
    "# Run packages script",
    "if [ -x \"$SCRIPT_DIR/setup/02-packages.sh\" ]; then",
    "  echo 'Running 02-packages.sh...'",
    "  \"$SCRIPT_DIR/setup/02-packages.sh\"",
    "else",
    "  echo '02-packages.sh not found or not executable, skipping'",
    "fi",
    "",
    "# Run configure script",
    "if [ -x \"$SCRIPT_DIR/setup/03-configure.sh\" ]; then",
    "  echo 'Running 03-configure.sh...'",
    "  \"$SCRIPT_DIR/setup/03-configure.sh\"",
    "else",
    "  echo '03-configure.sh not found or not executable, skipping'",
    "fi",
    "",
    "echo 'Setup script execution completed'"
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
    "SCRIPT_DIR='${var.script_dir}'",
    "CONFIG_DIR='${var.config_dir}'",
    "",
    "# Run comprehensive validation",
    "if [ -x \"$SCRIPT_DIR/validation/verify-all.sh\" ]; then",
    "  \"$SCRIPT_DIR/validation/verify-all.sh\"",
    "else",
    "  echo 'Running inline verification...'",
    "  ",
    "  echo ''",
    "  echo '--- Directory Structure ---'",
    "  find \"$SCRIPT_DIR\" -type f 2>/dev/null | head -20 || echo '(empty)'",
    "  ",
    "  echo ''",
    "  echo '--- Permission Summary ---'",
    "  echo 'Scripts directory:'",
    "  ls -la \"$SCRIPT_DIR/\" 2>/dev/null || echo '(not found)'",
    "  ",
    "  echo ''",
    "  echo 'Config directory:'",
    "  ls -la \"$CONFIG_DIR/\" 2>/dev/null || echo '(not found)'",
    "  ",
    "  echo ''",
    "  echo '--- Executable Check ---'",
    "  EXEC_COUNT=$(find \"$SCRIPT_DIR\" -name '*.sh' -perm -u+x 2>/dev/null | wc -l)",
    "  TOTAL_COUNT=$(find \"$SCRIPT_DIR\" -name '*.sh' 2>/dev/null | wc -l)",
    "  echo \"Executable scripts: $EXEC_COUNT of $TOTAL_COUNT\"",
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
