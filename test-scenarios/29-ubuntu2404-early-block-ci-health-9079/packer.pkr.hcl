# Test 29: LAB — block inbound TCP 9079 *before* cloud-config (reliable health failure)
#
# Why scenario 28 was unreliable:
#   A unit After=cloud-final.service often runs *after* lite-engine is already up and
#   the runner has already passed the health check → steps still run.
#
# This scenario installs a oneshot ordered:
#   After=network-online.target
#   Before=cloud-config.service
# so the DROP is in place before Harness #cloud-config user-data runs runcmd
# (wget lite-engine, start listener). Outbound downloads still work; inbound
# connections to :9079 from the runner fail — same class as "customer BYOI + firewall".
#
# Expected: Build OK; Image Use → Machine health check failed (lite-engine retry timeout).

provisioner "file" {
  source      = "systemd/harness-lab-early-drop-9079.service"
  destination = "/tmp/harness-lab-early-drop-9079.service"
}

provisioner "file" {
  source      = "files/lab-readme.txt"
  destination = "/tmp/lab-readme.txt"
}

provisioner "shell" {
  inline = [
    "set -eux",
    "echo '=== Test 29: LAB — early DROP tcp/9079 before cloud-config ==='",
    "export DEBIAN_FRONTEND=noninteractive",
    "sudo apt-get update",
    "sudo apt-get install -y iptables",
    "sudo install -d /usr/share/doc/harness-lab-early-drop-9079",
    "sudo cp /tmp/lab-readme.txt /usr/share/doc/harness-lab-early-drop-9079/README.txt",
    "sudo mv /tmp/harness-lab-early-drop-9079.service /etc/systemd/system/",
    "sudo systemctl daemon-reload",
    "sudo systemctl enable harness-lab-early-drop-9079.service",
    "echo '=== Enabled harness-lab-early-drop-9079.service ==='",
  ]
}
