# 29 — Early block TCP 9079 (reliable “customer-like” health failure)

## What this simulates

On a real CI VM, Harness attaches **custom metadata** `user-data` that matches what you pasted: `#cloud-config` with `packages`, `write_files` for certs under `/tmp/certs/`, then `runcmd` to `wget` lite-engine, plugins, and start `lite-engine server` on **9079**.

The **customer issue** is: **VM provisions** (GCP OK) but **machine health check never succeeds** — the runner cannot complete HTTPS health to `https://<VM internal IP>:9079/healthz` within the timeout.

That is **inbound** connectivity to **9079**, not “cloud-init never ran” (outbound `wget` still works if DNS/network are fine).

## Simplest faithful repro

Bake into the image a **netfilter rule** that **DROP**s **inbound** TCP to port **9079** **before** `cloud-config.service` runs the Harness `runcmd` chain.

- **After `network-online.target`** — metadata + downloads in `runcmd` still work.
- **Before `cloud-config.service`** — rule exists before lite-engine is started by user-data; the listener may still bind, but **runner → VM:9079** is dropped.

This matches **firewall / security group / iptables policy** mistakes on BYOI images without racing the health check.

## Why not scenario 28?

Scenario 28 used **`After=cloud-final.service`**, which often runs **too late**: health can pass first, so steps still succeed. See scenario 28 README.

## Harness plugin settings

Same as other Ubuntu 24.04 AMD64 tests, e.g.:

- `packerFilePath`: this directory’s `packer.pkr.hcl`
- `baseImage`: `ubuntu/24.04`
- `targetOs` / `targetArch`: `linux` / `amd64`

## Expected

| Stage      | Result |
|-----------|--------|
| BYOI build | Success |
| Image use  | **Machine health check failed** (or equivalent lite-engine health timeout) |

## If health still passes

Rare ordering differences on a given Ubuntu build:

1. On the VM: `systemctl cat cloud-config.service` and adjust `Before=` in the unit to the unit that immediately precedes cloud-config on that image.
2. Confirm `iptables` is the active backend (`iptables-nft` vs legacy); the rule uses `iptables` CLI as in Harness cloud-init (`ufw allow 9079`).

## Cleanup

Delete lab images from registries after testing.
