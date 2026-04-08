# Test 28: Negative test — block TCP 9079 after cloud-init (LAB ONLY)
#
# Use this to reproduce the failure mode where the VM is created successfully
# but Harness reports "Machine health check failed" because the runner cannot
# reach lite-engine on https://<VM>:9079/healthz.
#
# Mechanism: a systemd oneshot runs After=cloud-final.service and inserts
#   iptables -I INPUT -p tcp --dport 9079 -j DROP
# so it executes after Harness user-data has started lite-engine, simulating
# a firewall rule that blocks the health check (not the build-time Packer SSH path).
#
# Expected: Build stage succeeds; Image Use / health check fails.

provisioner "file" {
  source      = "systemd/harness-lab-block-ci-health-9079.service"
  destination = "/tmp/harness-lab-block-ci-health-9079.service"
}

provisioner "file" {
  source      = "files/lab-readme.txt"
  destination = "/tmp/lab-readme.txt"
}

provisioner "shell" {
  inline = [
    "set -eux",
    "echo '=== Test 28: LAB — install iptables and enable post-cloud-init DROP on 9079 ==='",
    "export DEBIAN_FRONTEND=noninteractive",
    "sudo apt-get update",
    "sudo apt-get install -y iptables",
    "sudo install -d /usr/share/doc/harness-lab-block-ci-health-9079",
    "sudo cp /tmp/lab-readme.txt /usr/share/doc/harness-lab-block-ci-health-9079/README.txt",
    "sudo mv /tmp/harness-lab-block-ci-health-9079.service /etc/systemd/system/",
    "sudo systemctl daemon-reload",
    "sudo systemctl enable harness-lab-block-ci-health-9079.service",
    "echo '=== Enabled harness-lab-block-ci-health-9079.service (runs on first boot after cloud-init) ==='",
  ]
}
