# 28 — Ubuntu 24.04 — LAB: block CI health port (9079) **after** cloud-final

## Prefer scenario 29

Health checks often **win the race** before the `After=cloud-final` iptables rule runs, so steps can still succeed. For a **reliable** repro of “provision OK, health never OK,” use **`29-ubuntu2404-early-block-ci-health-9079`** (`Before=cloud-config.service`).

---

## Purpose

**Negative / diagnostic scenario only.** Do not ship this pattern to customers as a “good” image.

It reproduces a common class of **Machine health check failed** issues:

1. **Build** (Packer over IAP/OS Login) **succeeds** — SSH is unrelated to port 9079.
2. **Run** (Harness Cloud): instance metadata runs `user-data`, downloads **lite-engine**, starts it on **9079**.
3. A **systemd oneshot** runs **`After=cloud-final.service`** and inserts:

   `iptables -I INPUT -p tcp --dport 9079 -j DROP`

   so the **runner** can no longer complete TLS health checks to **lite-engine**, even if the process is running.

That matches the hypothesis “something in the image / policy **blocks 9079**,” without requiring the customer’s real Packer file.

## What this is *not* proving

- **“Machine provisioned successfully”** only means the GCP API created the VM and the runner got an IP. It does **not** guarantee `cloud-init` finished or `lite-engine` started.
- This scenario deliberately breaks **inbound** health checks **after** cloud-init. Other failures (cloud-init never downloads lite-engine, binary crash, TLS mismatch) need different repros.

## Harness pipeline (plugin)

Use the same settings as other Ubuntu 24.04 AMD64 scenarios, for example:

- `packerFilePath`: path to this `packer.pkr.hcl` in your repo checkout  
- `baseImage`: `ubuntu/24.04`  
- `targetOs`: `linux`  
- `targetArch`: `amd64`  

Then add a **second stage** with `imageSpec.imageName` / `imageVersion` pointing at the built image.

## Expected outcome

| Stage        | Expected |
|-------------|----------|
| Image build | Success  |
| Image use   | **Failure** — “Machine health check failed” / lite-engine health timeout |

## Cleanup

Disable or remove this image from CI pools after testing so it is not picked accidentally.

## Parser test

From `test-scenarios/`:

```bash
./run-parser-tests.sh 28
```
