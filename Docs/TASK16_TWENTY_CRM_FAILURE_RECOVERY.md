# Task 16 — Twenty CRM Failure & Recovery

## Objective

Deploy Twenty CRM on an AWS EC2 instance using Docker and configure automatic recovery using Docker restart policies and health checks.

The following recovery scenarios were tested:

1. Docker daemon restart
2. EC2 stop/start
3. Twenty CRM application health verification
4. Container and application log verification

---

## 1. EC2 Environment

| Configuration | Value |
|---|---|
| Instance Type | t3.small |
| Operating System | Ubuntu |
| Storage | 20 GiB |
| Application Port | 2020 |
| Container Port | 3000 |
| Docker Network | `twenty-net` |

---

## 2. Docker Environment

Docker version:

```text
Docker version 29.1.3
```

Docker was enabled as a system service:

```bash
sudo systemctl enable --now docker
```

Verification:

```bash
sudo systemctl is-enabled docker
```

Result:

```text
enabled
```

---

## 3. Docker Network

```bash
sudo docker network create twenty-net
```

Containers on the network:

- `twenty-db`
- `twenty-redis`
- `twenty-crm`

---

## 4. PostgreSQL Container

```bash
sudo docker run -d \
  --name twenty-db \
  --restart always \
  --network twenty-net \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=default \
  postgres:16
```

---

## 5. Redis Container

```bash
sudo docker run -d \
  --name twenty-redis \
  --restart always \
  --network twenty-net \
  redis:7
```

---

## 6. Twenty CRM Container

Twenty CRM was deployed using `twentycrm/twenty:latest` with Docker restart policy `always`, port mapping `2020:3000`, and a Docker health check.

```bash
sudo docker run -d \
  --name twenty-crm \
  --restart always \
  --network twenty-net \
  -p 2020:3000 \
  --health-cmd="curl -f http://localhost:3000/ || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  --health-start-period=60s \
  -e NODE_PORT=3000 \
  -e SERVER_URL="http://32.198.60.106:2020" \
  -e PG_DATABASE_URL="postgres://postgres:postgres@twenty-db:5432/default" \
  -e REDIS_URL="redis://twenty-redis:6379" \
  -e APP_SECRET="<generated-at-runtime>" \
  -e IS_BILLING_ENABLED=false \
  -e SIGN_IN_PREFILLED=true \
  twentycrm/twenty:latest
```

> The application secret was generated at runtime and is intentionally not documented.

---

## 7. Restart Policy Verification

```bash
sudo docker inspect --format='{{.Name}} → RestartPolicy={{.HostConfig.RestartPolicy.Name}} → RestartCount={{.RestartCount}}' twenty-crm twenty-db twenty-redis
```

Initial result:

```text
/twenty-crm → RestartPolicy=always → RestartCount=0
/twenty-db → RestartPolicy=always → RestartCount=0
/twenty-redis → RestartPolicy=always → RestartCount=0
```

---

## 8. Docker Health Check

Health check:

```text
curl -f http://localhost:3000/ || exit 1
```

| Setting | Value |
|---|---|
| Interval | 30 seconds |
| Timeout | 10 seconds |
| Retries | 3 |
| Start period | 60 seconds |

Twenty initially showed `health: starting` during initialization and subsequently became `healthy`.

---

## 9. Healthy Baseline

Before failure testing, all three containers were running:

- `twenty-crm`
- `twenty-db`
- `twenty-redis`

Twenty CRM was healthy and exposed through:

```text
0.0.0.0:2020->3000/tcp
```

---

# 10. Failure & Recovery Test 1 — Docker Daemon Restart

The Docker daemon was restarted:

```bash
sudo systemctl restart docker
```

After initialization, all three containers automatically came back up.

Twenty CRM initially showed `Health=starting` and subsequently became:

```text
Status=running
Health=healthy
RestartPolicy=always
RestartCount=0
```

Application verification:

```bash
curl -I http://localhost:2020
```

Result:

```text
HTTP/1.1 200 OK
```

This confirmed recovery after the Docker daemon restart.

---

# 11. Failure & Recovery Test 2 — EC2 Stop/Start

The EC2 instance was stopped from the AWS EC2 console and then started again.

After reconnecting through SSH, all three containers were automatically running.

Twenty CRM initially showed `health: starting`. After initialization:

```text
Status=running
Health=healthy
RestartPolicy=always
RestartCount=2
StartedAt=2026-09-16T12:14:18.645270739Z
```

Application verification:

```bash
curl -I http://localhost:2020
```

The application returned an HTTP success response.

This confirmed recovery after the EC2 stop/start operation.

---

# 12. Public IP Change After EC2 Stop/Start

Initial public IP:

```text
32.198.60.106
```

Public IP after stop/start:

```text
3.83.85.213
```

The existing container configuration still contained:

```text
SERVER_URL=http://32.198.60.106:2020
```

Therefore, the EC2 public IP changed while the existing container configuration retained the original IP.

Recovery verification was based on container startup, health status, restart policy, restart count, local HTTP response, and application startup logs.

---

# 13. Final Container Verification

Final verification showed:

```text
twenty-crm → Status=running → Health=healthy → RestartPolicy=always → RestartCount=2
twenty-db → Status=running
twenty-redis → Status=running
```

---

# 14. Application Logs

Logs were checked using:

```bash
sudo docker logs --tail 100 twenty-crm
```

The logs showed normal NestJS initialization, including:

```text
[DatabaseConfigDriver] [INIT] Loading initial config variables from database
```

and:

```text
[DatabaseConfigDriver] [INIT] Config variables loaded: 0 values found in DB, 127 falling to env vars/defaults
```

The final startup confirmation was:

```text
[NestApplication] Nest application successfully started
```

This confirmed successful application initialization after recovery.

---

# 15. Recovery Verification Summary

| Test | Failure Simulation | Recovery Result | Evidence |
|---|---|---|---|
| Baseline | Normal operation | Twenty healthy | `docker ps` |
| Docker daemon | `systemctl restart docker` | Containers automatically started | `docker ps` |
| Docker daemon | Application initialization | Twenty became healthy | Docker health check |
| Application | Local HTTP request | HTTP 200 OK | `curl -I localhost:2020` |
| EC2 | AWS stop/start | Containers automatically started | `docker ps` |
| EC2 | Application initialization | Twenty became healthy | Docker health check |
| EC2 | Restart tracking | RestartCount = 2 | `docker inspect` |
| EC2 | Application verification | HTTP success response | `curl -I localhost:2020` |
| Logs | Post-recovery logs | Nest application successfully started | `docker logs` |

---

# 16. Key Docker Configuration

Restart policy:

```text
--restart always
```

Health check:

```text
curl -f http://localhost:3000/ || exit 1
```

Health-check parameters:

```text
Interval: 30s
Timeout: 10s
Retries: 3
Start period: 60s
```

---

# 17. Evidence Screenshots

### Screenshot 1 — Healthy Baseline

Shows Twenty CRM healthy, PostgreSQL and Redis running, and port 2020 mapped to container port 3000.

### Screenshot 2 — Restart Policy

Shows `RestartPolicy=always` for the containers.

### Screenshot 3 — Docker Daemon Recovery

Shows containers running after:

```bash
sudo systemctl restart docker
```

### Screenshot 4 — EC2 Recovery

Shows containers automatically starting after the EC2 stop/start operation.

### Screenshot 5 — Final Recovery State

Shows:

```text
twenty-crm → running → healthy
RestartPolicy=always
RestartCount=2
```

### Screenshot 6 — Health Check Configuration

Shows the Docker health check command and timing configuration.

### Screenshot 7 — Application Logs

Shows:

```text
[NestApplication] Nest application successfully started
```

---

# 18. Conclusion

Task 16 demonstrated automatic recovery of the Twenty CRM Docker environment.

The tests verified:

- Twenty CRM runs using Docker on EC2.
- Docker restart policy is configured as `always`.
- A Docker health check monitors the Twenty application.
- Containers automatically recover after a Docker daemon restart.
- Containers automatically start after an EC2 stop/start.
- Twenty CRM becomes healthy after application initialization.
- The application responds successfully on port 2020.
- Restart information can be verified using Docker inspection.
- Application logs confirm successful NestJS startup.

The recovery tests were completed successfully on the Task 16 EC2 environment.

