LAB image: early iptables DROP on TCP 9079 before cloud-config.service.

This mimics host firewall / security policy that blocks the Harness runner from
reaching lite-engine on 9079 during first boot — the same user-data you see in
GCP custom metadata still runs, but inbound health checks fail.

Expected: Image build OK; Image Use shows provision OK then machine health check failed.

See test-scenarios/README.md scenario 29.
