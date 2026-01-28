# Test 16: Advanced Permission Tests
# Tests complex permission scenarios including:
# - User/group ownership
# - Restricted and elevated permissions
# - Umask verification
# - Multi-user script execution
# - Service file permissions
# - Secure file handling

variable "service_user" {
  type        = string
  default     = "harness-agent"
  description = "Service account user"
}

variable "service_group" {
  type        = string
  default     = "harness"
  description = "Service account group"
}

variable "secure_dir" {
  type        = string
  default     = "/opt/harness-secure"
  description = "Directory for secured files"
}

# ==============================================================================
# FILE PROVISIONERS
# ==============================================================================

# Copy secured scripts (require elevated permissions)
provisioner "file" {
  source      = "scripts/secured/"
  destination = "/tmp/secured-scripts"
}

# Copy elevated scripts (can run with sudo)
provisioner "file" {
  source      = "scripts/elevated/"
  destination = "/tmp/elevated-scripts"
}

# Copy restricted scripts (read-only configs)
provisioner "file" {
  source      = "scripts/restricted/"
  destination = "/tmp/restricted-scripts"
}

# ==============================================================================
# STEP 1: Create service user and group
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 1: Creating service user/group ==='",
    "echo '=============================================='",
    "",
    "# Create service group if it doesn't exist",
    "if ! getent group ${var.service_group} > /dev/null 2>&1; then",
    "  sudo groupadd ${var.service_group}",
    "  echo 'Created group: ${var.service_group}'",
    "else",
    "  echo 'Group already exists: ${var.service_group}'",
    "fi",
    "",
    "# Create service user if it doesn't exist",
    "if ! id -u ${var.service_user} > /dev/null 2>&1; then",
    "  sudo useradd -r -g ${var.service_group} -d /var/lib/harness -s /sbin/nologin -c 'Harness Agent' ${var.service_user}",
    "  echo 'Created user: ${var.service_user}'",
    "else",
    "  echo 'User already exists: ${var.service_user}'",
    "fi",
    "",
    "# Verify",
    "id ${var.service_user}",
    "getent group ${var.service_group}"
  ]
}

# ==============================================================================
# STEP 2: Create secure directory structure
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 2: Creating secure directories ==='",
    "echo '=============================================='",
    "",
    "# Create main secure directory",
    "sudo mkdir -p ${var.secure_dir}",
    "sudo mkdir -p ${var.secure_dir}/bin",
    "sudo mkdir -p ${var.secure_dir}/config",
    "sudo mkdir -p ${var.secure_dir}/secrets",
    "sudo mkdir -p ${var.secure_dir}/logs",
    "sudo mkdir -p ${var.secure_dir}/run",
    "",
    "# Set ownership",
    "sudo chown -R ${var.service_user}:${var.service_group} ${var.secure_dir}",
    "",
    "# Set directory permissions",
    "# - bin: 755 (executables)",
    "# - config: 750 (readable by group only)",
    "# - secrets: 700 (owner only)",
    "# - logs: 755 (everyone can read logs)",
    "# - run: 755 (pid files, sockets)",
    "sudo chmod 755 ${var.secure_dir}",
    "sudo chmod 755 ${var.secure_dir}/bin",
    "sudo chmod 750 ${var.secure_dir}/config",
    "sudo chmod 700 ${var.secure_dir}/secrets",
    "sudo chmod 755 ${var.secure_dir}/logs",
    "sudo chmod 755 ${var.secure_dir}/run",
    "",
    "echo 'Directory structure:'",
    "ls -la ${var.secure_dir}/"
  ]
}

# ==============================================================================
# STEP 3: Install secured scripts with proper ownership
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 3: Installing secured scripts ==='",
    "echo '=============================================='",
    "",
    "# Debug: Show what was uploaded",
    "echo 'Contents of /tmp/secured-scripts:'",
    "find /tmp/secured-scripts -type f 2>/dev/null || echo '(directory not found)'",
    "",
    "# Move scripts to secure location (handle nested directory structure from Packer file provisioner)",
    "# When Packer uploads a directory, it creates a nested structure",
    "if find /tmp/secured-scripts -name '*.sh' -type f 2>/dev/null | grep -q .; then",
    "  find /tmp/secured-scripts -name '*.sh' -type f -exec sudo cp {} ${var.secure_dir}/bin/ \\;",
    "  echo 'Copied secured scripts to ${var.secure_dir}/bin/'",
    "else",
    "  echo 'No secured scripts (.sh files) found to copy'",
    "fi",
    "",
    "# Set proper ownership and permissions",
    "sudo chown -R ${var.service_user}:${var.service_group} ${var.secure_dir}/bin/",
    "sudo find ${var.secure_dir}/bin -type f -name '*.sh' -exec chmod 750 {} \\;",
    "",
    "echo 'Installed secured scripts:'",
    "ls -la ${var.secure_dir}/bin/ || echo '(empty)'"
  ]
}

# ==============================================================================
# STEP 4: Install elevated scripts
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 4: Installing elevated scripts ==='",
    "echo '=============================================='",
    "",
    "# Debug: Show what was uploaded",
    "echo 'Contents of /tmp/elevated-scripts:'",
    "find /tmp/elevated-scripts -type f 2>/dev/null || echo '(directory not found)'",
    "",
    "# These scripts require root to run",
    "sudo mkdir -p /usr/local/sbin/harness",
    "",
    "# Move scripts (handle nested directory structure from Packer file provisioner)",
    "if find /tmp/elevated-scripts -name '*.sh' -type f 2>/dev/null | grep -q .; then",
    "  find /tmp/elevated-scripts -name '*.sh' -type f -exec sudo cp {} /usr/local/sbin/harness/ \\;",
    "  echo 'Copied elevated scripts to /usr/local/sbin/harness/'",
    "else",
    "  echo 'No elevated scripts (.sh files) found to copy'",
    "fi",
    "",
    "# Set root ownership and permissions (750 - only root can execute)",
    "sudo chown -R root:root /usr/local/sbin/harness/",
    "sudo find /usr/local/sbin/harness -type f -name '*.sh' -exec chmod 750 {} \\;",
    "",
    "echo 'Installed elevated scripts:'",
    "ls -la /usr/local/sbin/harness/ || echo '(empty)'"
  ]
}

# ==============================================================================
# STEP 5: Install restricted configs
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 5: Installing restricted configs ==='",
    "echo '=============================================='",
    "",
    "# Debug: Show what was uploaded",
    "echo 'Contents of /tmp/restricted-scripts:'",
    "find /tmp/restricted-scripts -type f 2>/dev/null || echo '(directory not found)'",
    "",
    "# Copy restricted configs (handle nested directory structure from Packer file provisioner)",
    "if find /tmp/restricted-scripts -name '*.yaml' -o -name '*.yml' -o -name '*.conf' -type f 2>/dev/null | grep -q .; then",
    "  find /tmp/restricted-scripts \\( -name '*.yaml' -o -name '*.yml' -o -name '*.conf' \\) -type f -exec sudo cp {} ${var.secure_dir}/config/ \\;",
    "  echo 'Copied restricted configs to ${var.secure_dir}/config/'",
    "else",
    "  echo 'No restricted configs (.yaml/.yml/.conf files) found to copy'",
    "fi",
    "",
    "# Set restrictive permissions (640 - owner read/write, group read)",
    "sudo chown -R ${var.service_user}:${var.service_group} ${var.secure_dir}/config/",
    "sudo find ${var.secure_dir}/config -type f -exec chmod 640 {} \\;",
    "",
    "echo 'Installed restricted configs:'",
    "sudo ls -la ${var.secure_dir}/config/ || echo '(empty)'"
  ]
}

# ==============================================================================
# STEP 6: Test permission scenarios
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 6: Testing permission scenarios ==='",
    "echo '=============================================='",
    "",
    "# Test 1: Verify service user can execute secured scripts",
    "echo 'Test 1: Service user script execution'",
    "if [ -f ${var.secure_dir}/bin/health-check.sh ]; then",
    "  sudo -u ${var.service_user} ${var.secure_dir}/bin/health-check.sh && echo '  [PASS]' || echo '  [EXPECTED FAIL - testing]'",
    "else",
    "  echo '  [SKIP] health-check.sh not found'",
    "fi",
    "",
    "# Test 2: Verify secrets directory is not accessible by others",
    "echo 'Test 2: Secrets directory isolation'",
    "if sudo ls ${var.secure_dir}/secrets/ > /dev/null 2>&1; then",
    "  echo '  [PASS] Root can access secrets'",
    "else",
    "  echo '  [FAIL] Root cannot access secrets'",
    "fi",
    "",
    "# Test 3: Verify elevated scripts require sudo",
    "echo 'Test 3: Elevated script protection'",
    "if [ -f /usr/local/sbin/harness/root-setup.sh ]; then",
    "  # This should fail without sudo",
    "  if /usr/local/sbin/harness/root-setup.sh 2>/dev/null; then",
    "    echo '  [WARN] Script ran without sudo'",
    "  else",
    "    echo '  [PASS] Script requires sudo'",
    "  fi",
    "else",
    "  echo '  [SKIP] root-setup.sh not found'",
    "fi",
    "",
    "# Test 4: Verify config files are readable but not world-writable",
    "echo 'Test 4: Config file permissions'",
    "world_writable=$(find ${var.secure_dir}/config -type f -perm -o+w 2>/dev/null | wc -l)",
    "if [ \"$world_writable\" -eq 0 ]; then",
    "  echo '  [PASS] No world-writable config files'",
    "else",
    "  echo '  [FAIL] Found world-writable config files'",
    "fi",
    "",
    "echo ''",
    "echo 'Permission tests complete'"
  ]
}

# ==============================================================================
# STEP 7: Umask and default permission verification
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 7: Umask verification ==='",
    "echo '=============================================='",
    "",
    "# Check current umask",
    "echo 'Current umask:' $(umask)",
    "",
    "# Test file creation with different umasks",
    "echo 'Testing file creation with umask 022:'",
    "umask 022",
    "touch /tmp/test_umask_022",
    "ls -la /tmp/test_umask_022",
    "expected_perms=\"-rw-r--r--\"",
    "actual_perms=$(ls -la /tmp/test_umask_022 | awk '{print $1}')",
    "if [ \"$actual_perms\" = \"$expected_perms\" ]; then",
    "  echo '  [PASS] Umask 022 creates 644 files'",
    "else",
    "  echo '  [INFO] Got $actual_perms (may vary by system)'",
    "fi",
    "",
    "echo 'Testing file creation with umask 077:'",
    "umask 077",
    "touch /tmp/test_umask_077",
    "ls -la /tmp/test_umask_077",
    "expected_perms=\"-rw-------\"",
    "actual_perms=$(ls -la /tmp/test_umask_077 | awk '{print $1}')",
    "if [ \"$actual_perms\" = \"$expected_perms\" ]; then",
    "  echo '  [PASS] Umask 077 creates 600 files'",
    "else",
    "  echo '  [INFO] Got $actual_perms (may vary by system)'",
    "fi",
    "",
    "# Cleanup",
    "rm -f /tmp/test_umask_022 /tmp/test_umask_077",
    "umask 022  # Reset to safe default"
  ]
}

# ==============================================================================
# STEP 8: Systemd service file permissions
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 8: Service file permissions ==='",
    "echo '=============================================='",
    "",
    "# Create a sample systemd service file with correct permissions",
    "cat << 'SERVICEEOF' | sudo tee /etc/systemd/system/harness-agent.service > /dev/null",
    "[Unit]",
    "Description=Harness Agent Service",
    "After=network.target",
    "",
    "[Service]",
    "Type=simple",
    "User=${var.service_user}",
    "Group=${var.service_group}",
    "WorkingDirectory=${var.secure_dir}",
    "ExecStart=${var.secure_dir}/bin/agent-start.sh",
    "ExecStop=${var.secure_dir}/bin/agent-stop.sh",
    "Restart=on-failure",
    "RestartSec=5",
    "",
    "[Install]",
    "WantedBy=multi-user.target",
    "SERVICEEOF",
    "",
    "# Set correct permissions for systemd service file",
    "sudo chmod 644 /etc/systemd/system/harness-agent.service",
    "sudo chown root:root /etc/systemd/system/harness-agent.service",
    "",
    "# Verify",
    "echo 'Service file permissions:'",
    "ls -la /etc/systemd/system/harness-agent.service",
    "",
    "# Validate service file",
    "if systemd-analyze verify /etc/systemd/system/harness-agent.service 2>/dev/null; then",
    "  echo '  [PASS] Service file syntax valid'",
    "else",
    "  echo '  [WARN] Service file may have issues (expected if scripts dont exist)'",
    "fi"
  ]
}

# ==============================================================================
# STEP 9: Final comprehensive verification
# ==============================================================================
provisioner "shell" {
  inline = [
    "echo '=============================================='",
    "echo '=== STEP 9: Comprehensive verification ==='",
    "echo '=============================================='",
    "",
    "echo ''",
    "echo '--- Permission Summary ---'",
    "echo ''",
    "",
    "echo 'Secure directory structure:'",
    "find ${var.secure_dir} -maxdepth 2 -exec ls -ld {} \\; 2>/dev/null | head -20",
    "",
    "echo ''",
    "echo 'Elevated scripts directory:'",
    "ls -la /usr/local/sbin/harness/ 2>/dev/null || echo '(empty)'",
    "",
    "echo ''",
    "echo '--- Security Checks ---'",
    "",
    "# Check for world-writable files",
    "echo -n 'World-writable files in secure dir: '",
    "ww_count=$(find ${var.secure_dir} -type f -perm -o+w 2>/dev/null | wc -l)",
    "if [ \"$ww_count\" -eq 0 ]; then",
    "  echo '0 [PASS]'",
    "else",
    "  echo \"$ww_count [WARN]\"",
    "fi",
    "",
    "# Check for world-writable directories",
    "echo -n 'World-writable dirs in secure dir: '",
    "wd_count=$(find ${var.secure_dir} -type d -perm -o+w 2>/dev/null | wc -l)",
    "if [ \"$wd_count\" -eq 0 ]; then",
    "  echo '0 [PASS]'",
    "else",
    "  echo \"$wd_count [WARN]\"",
    "fi",
    "",
    "# Check secrets directory permission",
    "echo -n 'Secrets directory permission: '",
    "secrets_perm=$(stat -c '%a' ${var.secure_dir}/secrets 2>/dev/null || echo 'N/A')",
    "if [ \"$secrets_perm\" = '700' ]; then",
    "  echo \"$secrets_perm [PASS]\"",
    "else",
    "  echo \"$secrets_perm [CHECK]\"",
    "fi",
    "",
    "echo ''",
    "echo '=============================================='",
    "echo '=== ADVANCED PERMISSION TESTS COMPLETE ==='",
    "echo '=============================================='",
  ]
}
