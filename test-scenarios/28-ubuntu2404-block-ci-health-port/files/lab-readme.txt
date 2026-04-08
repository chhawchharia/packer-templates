This image is a LAB / NEGATIVE test only.

It installs a systemd oneshot that runs after cloud-final.service and drops
inbound TCP connections to port 9079. That mimics customer Packer or host
hardening that blocks the port Harness CI uses for lite-engine health checks.

Expected Harness behavior: VM provisions, then "Machine health check failed"
after the cold-start timeout.

Do not use this pattern in production images.
