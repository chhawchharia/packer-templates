# Test 10: Customer Source Block (Should Be Ignored)
# This tests that customer-provided source and build blocks are IGNORED
# Harness BYOI uses its own source configuration for security and consistency

variable "customer_var" {
  type        = string
  default     = "this-should-be-preserved"
  description = "This variable SHOULD be preserved"
}

variable "install_nginx" {
  type        = bool
  default     = true
  description = "Whether to install nginx"
}

# ============================================================
# THIS SOURCE BLOCK WILL BE COMPLETELY IGNORED BY HARNESS
# Customer cannot control the source configuration
# ============================================================
source "googlecompute" "customer-defined" {
  # ALL OF THESE WILL BE IGNORED:
  project_id          = "customer-wrong-project"      # IGNORED - Harness uses its project
  source_image_family = "debian-11"                   # IGNORED - Harness uses baseOS setting
  zone                = "europe-west1-b"              # IGNORED - Harness uses default zone
  machine_type        = "e2-micro"                    # IGNORED - Harness uses n2-standard-4
  image_name          = "wrong-image-name"            # IGNORED - Harness uses {accountId}-{imageName}-{version}
  disk_size           = 10                            # IGNORED - Harness uses 50GB
}

# ============================================================
# THIS BUILD BLOCK WILL ALSO BE IGNORED
# ============================================================
build {
  sources = ["source.googlecompute.customer-defined"]
  
  # BUT THIS PROVISIONER WILL BE EXTRACTED AND USED
  provisioner "shell" {
    inline = [
      "echo 'Variable value: ${var.customer_var}'",
      "echo 'This provisioner from build block SHOULD run!'"
    ]
  }
}

# ============================================================
# THESE PROVISIONERS OUTSIDE BUILD WILL ALSO BE EXTRACTED
# ============================================================

provisioner "shell" {
  inline = [
    "echo '=== Customer provisioner 1 ==='",
    "echo 'Variable: ${var.customer_var}'",
    "export DEBIAN_FRONTEND=noninteractive",
    "sudo apt-get update"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Customer provisioner 2 ==='",
    "echo 'Installing nginx...'",
    "export DEBIAN_FRONTEND=noninteractive",
    "sudo apt-get install -y nginx",
    "nginx -v"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Verification ==='",
    "echo 'OS Info:'",
    "cat /etc/os-release | head -5",
    "echo ''",
    "echo 'This proves:'",
    "echo '1. Customer source block was IGNORED'",
    "echo '2. Customer build block was IGNORED'",
    "echo '3. Customer variables were PRESERVED'",
    "echo '4. Customer provisioners were EXTRACTED and RUN'",
    "echo '=== All done ==='"
  ]
}

