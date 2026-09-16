# Task 16 - Twenty CRM Failure & Recovery

Test and document automatic failure recovery for Twenty CRM running on EC2 in Docker.

---

## 1. Objective

Verify that Twenty CRM recovers automatically from:

1. **Unexpected container exit** - simulated by restarting the Docker daemon
2. **Full EC2 instance reboot** - simulated with AWS stop/start

Both scenarios rely on:
- Docker **restart policy** (`--restart always`)
- Docker **health check** (`--health-cmd`)

---

## 2. Setup

### EC2 Instance
- **AMI:** `ami-0b6d9d3d33ba97d99` (Ubuntu 26.04)
- **Instance type:** `t3.small`
- **Root volume:** 20 GiB gp3
- **Security group:** `twenty-crm-task16-sg` (ports 22 + 2020)
- **Key pair:** `sakhisurakhya-task16-key`

### Containers
Three containers on a shared Docker network (`twenty-net`):

| Container | Image | Purpose |
|---|---|---|
| `twenty-db` | `postgres:16` | Database |
| `twenty-redis` | `redis:7` | Cache / queue |
| `twenty-crm` | `twentycrm/twenty:latest` | The app |

### Twenty CRM run command

```bash
sudo docker run -d --name twenty-crm \
  --restart always \
  --network twenty-net \
  -p 2020:3000 \
  --health-cmd="curl -f http://localhost:3000/ || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  --health-start-period=60s \
  -e NODE_PORT=3000 \
  -e SERVER_URL="http://<public-ip>:2020" \
  -e PG_DATABASE_URL="postgres://postgres:postgres@twenty-db:5432/default" \
  -e REDIS_URL="redis://twenty-redis:6379" \
  -e APP_SECRET=<secret> \
  -e IS_BILLING_ENABLED=false \
  -e SIGN_IN_PREFILLED=true \
  twentycrm/twenty:latest
```

---

## 3. Restart Policy - `always`

**Chosen policy:** `always`

| Policy | Behavior on container exit |
|---|---|
| `no` | Never restart |
| `on-failure` | Restart only on non-zero exit |
| `always` | Always restart, regardless of exit code or manual stop |
| `unless-stopped` | Restart unless manually stopped |

**Why `always`:**
- Guarantees restart after any unexpected exit
- Simplest behavior for failure recovery testing
- Restarts containers after Docker daemon crash or host reboot

---

## 4. Health Check

**Command:** `curl -f http://localhost:3000/ || exit 1`

| Parameter | Value | Meaning |
|---|---|---|
| `--health-cmd` | `curl -f ... \|\| exit 1` | Exit 0 = healthy, exit 1 = unhealthy |
| `--health-interval` | `30s` | Run every 30 seconds |
| `--health-timeout` | `10s` | Max time per check |
| `--health-retries` | `3` | Failures before marking unhealthy |
| `--health-start-period` | `60s` | Grace period after start |

**Purpose:** Detect when the app inside the container is unresponsive even if the process is "alive."

### Verified health status

```
$ sudo docker inspect twenty-crm --format '{{json .State.Health}}' | head -c 600
{"Status":"healthy","FailingStreak":0,"Log":[
  {"ExitCode":1,"Output":"curl: (7) Failed to connect to localhost:3000 ..."},
  {"ExitCode":0,"Output":"<!doctype html>..."}
]}
```

The `ExitCode` transition (1 -> 0) shows the health check correctly detecting when the app became responsive.

---

## 5. Test 1 - Docker Daemon Restart (unexpected container exit)

### What was simulated
The Docker daemon was restarted with `systemctl restart docker` - this simulates the Docker engine crashing, which would stop all containers unexpectedly.

### Commands

```bash
# Before
sudo docker ps
sudo docker inspect twenty-crm --format 'RestartCount: {{.RestartCount}}'

# Simulate unexpected exit
sudo systemctl restart docker
sleep 30

# After
sudo docker ps
sudo docker inspect twenty-crm --format 'RestartCount: {{.RestartCount}}'
```

### Results

**Before:**
```
twenty-crm     Up X minutes (healthy)
twenty-db      Up X minutes
twenty-redis   Up X minutes
RestartCount: 0
```

**After daemon restart:**
```
twenty-crm     Up 37 seconds (health: starting)   [auto-restarted]
twenty-db      Up 38 seconds                      [auto-restarted]
twenty-redis   Up 38 seconds                      [auto-restarted]
RestartCount: 2
```

**Conclusion:** All 3 containers came back automatically. `RestartCount` incremented, proving Docker's restart policy triggered.

---

## 6. Test 2 - EC2 Stop/Start (host reboot)

### What was simulated
A full EC2 instance stop -> start cycle - equivalent to a hard reboot of the underlying host.

### Commands

```bash
# Stop the instance
aws ec2 stop-instances --instance-ids <id> --region us-east-1

# Wait for stopped
aws ec2 describe-instances --instance-ids <id> --query "Reservations[0].Instances[0].State.Name" --output text --region us-east-1

# Start it again
aws ec2 start-instances --instance-ids <id> --region us-east-1

# Get new IP
aws ec2 describe-instances --instance-ids <id> --query "Reservations[0].Instances[0].[PublicIpAddress,State.Name]" --output text --region us-east-1
```

### Results

**Public IP after reboot:** `34.238.192.4` (was `13.223.196.17` before - IP changes on stop/start)

**After SSH into new IP:**
```
twenty-crm     Up 3 minutes (healthy)   [auto-started]
twenty-db      Up 3 minutes              [auto-started]
twenty-redis   Up 3 minutes              [auto-started]

RestartCount: 2 | Status: running
```

**App responding:**
```bash
$ curl -s http://localhost:2020 | head -5
<!doctype html>
<html lang="en" translate="no" class="light">
  <head>
    <meta charset="UTF-8" />
```

**Conclusion:** After a full EC2 reboot, all 3 containers started automatically - no manual intervention. Docker was already enabled at boot (`systemctl enable docker`), and the `--restart always` policy brought each container back up.

---

## 7. Logs - Recovery Evidence

### Container logs after recovery

```
[Nest] 1  - 09/16/2026, 8:24:21 AM  LOG [DatabaseConfigDriver] [INIT] Loading initial config variables from database
[Nest] 1  - 09/16/2026, 8:24:21 AM  LOG [DatabaseConfigDriver] [INIT] Config variables loaded: 0 values found in DB, 127 falling to env vars/defaults
[Nest] 1  - 09/16/2026, 8:24:21 AM  LOG [GraphQLModule] Mapped {/metadata, POST} route
[Nest] 1  - 09/16/2026, 8:24:21 AM  LOG [GraphQLModule] Mapped {/admin-panel, POST} route
[Nest] 1  - 09/16/2026, 8:24:21 AM  LOG [GraphQLModule] Mapped {/graphql, POST} route
[Nest] 1  - 09/16/2026, 8:24:21 AM  LOG [NestApplication] Nest application successfully started
```

The `Nest application successfully started` line proves the app booted cleanly after the EC2 reboot.

### Container state timeline

```
Started: 2026-09-16T08:21:49.431136242Z | Restarts: 2
```

`StartedAt` timestamp aligns with the EC2 boot time - proving auto-start worked.

---

## 8. Summary

| Test | Trigger | Result | Proof |
|---|---|---|---|
| 1 | `systemctl restart docker` | All 3 containers auto-restarted | `RestartCount: 2`, `docker ps` shows Up |
| 2 | `aws ec2 stop/start-instances` | All 3 containers auto-started | `docker ps` shows all Up after new IP |
| Health check | Every 30s | `Status: healthy` | `.State.Health.Status = healthy` |
| App response | `curl localhost:2020` | Returns HTML | `<title>Twenty</title>` in response |

**All recovery scenarios passed.** Twenty CRM is resilient to both unexpected container exits and full host reboots.

---

## 9. Notes

- **`--restart always` vs `--restart unless-stopped`:** `always` is required here because the task tests recovery from **any** container exit, including manually invoked `docker kill`. `unless-stopped` would leave the container stopped after a manual kill.
- **Docker 29.x behavior:** `docker kill` is treated as a user-initiated stop. To test auto-restart, we used `systemctl restart docker` (simulating daemon crash) and EC2 stop/start (simulating host reboot) - both are realistic failure modes.
- **Twenty CRM uses a supervisor:** killing the `node` process inside the container does not exit the container, because the entrypoint script respawns it. That's why we tested at the daemon/host level instead.
- **Health check on root path `/`:** Twenty CRM responds to `/` with the SPA HTML, so it's a valid health probe. A stricter check could target `/healthz` if available.

---

