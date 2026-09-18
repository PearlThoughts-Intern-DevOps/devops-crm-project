# Task 16: Twenty CRM Failure & Recovery (Ubuntu)

## Overview
Tested automatic failure recovery for the Twenty CRM application running on an Ubuntu EC2 instance (t3.small) with Docker, using a Docker restart policy and container health checks.

## Configuration
- **Restart policy:** `restart: unless-stopped` on all services (server, postgres, redis) — Docker automatically restarts containers after unexpected stops and after host reboots.
- **Health checks:** Docker health check on the Twenty CRM server probing `http://localhost:3000/` every 30s (start period 90s), plus `pg_isready` (Postgres) and `redis-cli ping` (Redis).
- **Boot persistence:** `systemctl enable docker` ensures the Docker daemon and its containers start automatically when the EC2 instance boots.
- **Application secrets:** `ENCRYPTION_KEY`/`APP_SECRET` provided at boot to prevent server crash-loops.

## Test 1: Manual Container Kill
1. Verified the healthy stack: `sudo docker ps` (all containers Up and healthy).
2. Killed the application container: `sudo docker kill twenty-crm`.
3. The Docker restart policy immediately triggered automatic restart attempts — `RestartCount` incremented (observed value: 3) with exponential backoff, confirming the daemon actively tried to recover the service.
4. Observation: the Twenty CRM entrypoint re-runs database migrations on every boot (~60–90s), so verification snapshots must allow a recovery window; checks taken after only 10 seconds show the container between backoff attempts.

## Test 2: EC2 Stop / Start
1. Stopped the instance: `aws ec2 stop-instances --instance-ids <id>`.
2. Started the instance: `aws ec2 start-instances --instance-ids <id>`.
3. After boot, `sudo docker ps` showed all containers (postgres, redis, twenty-crm) automatically running again without any manual intervention, and `curl http://localhost:2020/healthz` returned `{"status":"ok"}`.

## Log Verification
- `sudo docker logs --tail 30 twenty-crm` shows the NestJS application completing migrations and printing "Nest application successfully started" after each recovery.
- `sudo docker inspect` confirms the `unless-stopped` restart policy and the accumulated restart count, evidencing automatic recovery attempts by the Docker daemon.

## Conclusion
The Docker restart policy (`unless-stopped`) combined with container health checks and Docker service auto-start provides self-healing behavior for the Twenty CRM stack across container-level failures and full EC2 reboots. Recovery time is dominated by the application's migration phase (~60–90s), which should be accounted for in health-check and monitoring windows.
