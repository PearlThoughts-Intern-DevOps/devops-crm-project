# Task 16: Twenty CRM Failure & Recovery

## Overview
This document covers the failure recovery configuration for Twenty CRM running on EC2 using Docker.

---

## Infrastructure
- **EC2 Instance:** t3.small, Ubuntu 26.04
- **IP:** 18.207.106.119
- **App Port:** 2020
- **Docker Image:** twentycrm/twenty:v2.35.0

---

## 1. Containers Running via user_data

All containers are started automatically on EC2 boot via `user_data.sh.tpl`:

| Container | Image | Restart Policy |
|---|---|---|
| twenty-db | postgres:16-alpine | unless-stopped |
| twenty-redis | redis:7-alpine | unless-stopped |
| twenty-crm | twentycrm/twenty:v2.35.0 | unless-stopped |
| twenty-worker | twentycrm/twenty:v2.35.0 | unless-stopped |

---

## 2. Restart Policy Configuration

All containers use `--restart unless-stopped` which means:
- Container restarts automatically if it crashes or the process dies
- Container restarts automatically after EC2 reboot
- Container does NOT restart only if manually stopped with `docker stop`

---

## 3. Health Check Configuration

Added to `twenty-crm`:
```bash
--health-cmd="curl -f http://localhost:3000/healthz || exit 1"
--health-interval=30s
--health-timeout=10s
--health-retries=3
--health-start-period=90s
```

Added to `twenty-worker` (process-based since no HTTP port):
```bash
--health-cmd="ps aux | grep 'worker:prod' | grep -v grep || exit 1"
--health-interval=30s
--health-timeout=10s
--health-retries=3
--health-start-period=60s
```

---

## 4. Failure Recovery Test — Container Crash

### Step 1 — Verified containers healthy

docker ps -a

twenty-crm: Up 5 minutes (healthy)

### Step 2 — Killed the process inside the container
```bash
docker exec twenty-crm kill -9 1
```

### Step 3 — Verified auto-restart
```bash
sleep 10 && docker ps -a
# twenty-crm: Up 10 seconds (healthy) ← restarted automatically
```

**Result:** Docker detected the crash and restarted the container within seconds.

---

## 5. Failure Recovery Test — EC2 Reboot

### Step 1 — Rebooted EC2
```bash
sudo reboot
```

### Step 2 — SSH back in after 3 minutes
```bash
ssh -i ~/.ssh/shubhamsingh-task16.pem ubuntu@18.207.106.119
```

### Step 3 — Verified all containers auto-started
```bash
docker ps -a
# twenty-db:     Up 3 minutes
# twenty-redis:  Up 3 minutes
# twenty-crm:    Up 3 minutes (unhealthy → healthy after boot)
# twenty-worker: Up 1 second (health: starting)
```

**Result:** All 4 containers restarted automatically after EC2 reboot with zero manual intervention.

**Why it works:**
- `systemctl enable docker` in user_data ensures Docker starts on boot
- `--restart unless-stopped` ensures containers start with Docker

---

## 6. Logs Verification

```bash
# container logs
docker logs twenty-crm --tail 20

# bootstrap log
tail -20 /var/log/user-data.log

# health check status
docker inspect twenty-crm --format='Health Status: {{.State.Health.Status}}'
```

---

## 7. Key Takeaways

| Scenario | Mechanism | Result |
|---|---|---|
| App process crashes | `--restart unless-stopped` | Auto-restart in seconds |
| EC2 reboots | `systemctl enable docker` + restart policy | All containers auto-start |
| Health check fails | `--health-*` flags | Docker marks container unhealthy |

