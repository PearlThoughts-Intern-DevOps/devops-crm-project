# Task 16 – Twenty CRM Failure & Recovery

## Objective

Deploy Twenty CRM on AWS EC2 using Docker, configure automatic restart and a health check, test application failure recovery, reboot the EC2 instance, verify automatic startup, and check recovery logs.

## Environment

| Component | Configuration |
|---|---|
| Cloud | AWS |
| Region | us-east-1 |
| EC2 | `mohsin-task-16-ec2` |
| Instance type | `t3.small` |
| AMI | `ami-0b6d9d3d33ba97d99` |
| OS | Ubuntu 26.04 LTS |
| Docker | 29.1.3 |
| Application port | 2020 |

### Approved AMIs

- `ami-081b0a6eac00b4f53`
- `ami-0b6d9d3d33ba97d99`

The deployed EC2 instance used `ami-0b6d9d3d33ba97d99`.

## Docker Architecture

Three containers were used:

- `twenty-server` – Twenty CRM application
- `twenty-db` – PostgreSQL 16
- `twenty-redis` – Redis 7

All containers use the Docker network `twenty-network`.

Twenty CRM is exposed as:

```text
EC2 port 2020 → container port 3000
```

## Restart Policy

The application and supporting containers were started with:

```text
--restart unless-stopped
```

The policy was verified with:

```bash
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' twenty-server
```

Result:

```text
unless-stopped
```

## Health Check

The Twenty CRM container uses:

```bash
curl -fsS http://localhost:3000/healthz || exit 1
```

Health-check configuration:

```text
Interval: 30s
Timeout: 10s
Retries: 5
Start period: 60s
```

The container reached:

```text
healthy
```

The application endpoint was also verified:

```bash
curl -I http://localhost:2020/healthz
```

Result:

```text
HTTP/1.1 200 OK
```

## Failure Test – Application Process

An explicit `docker kill twenty-server` was tested first. Because `unless-stopped` treats an intentional manual stop as a stopped state, the container did not automatically restart.

To simulate an unexpected application failure, the main Twenty CRM process was terminated:

```bash
docker top twenty-server
sudo kill -9 <main-process-PID>
```

Docker automatically restarted the container.

Verification:

```bash
docker inspect -f 'RestartCount={{.RestartCount}} Status={{.State.Status}} Health={{.State.Health.Status}}' twenty-server
```

Result:

```text
RestartCount=1
Status=running
Health=healthy
```

The health endpoint again returned:

```text
HTTP/1.1 200 OK
```

## Failure Test – EC2 Reboot

The EC2 instance was rebooted:

```bash
sudo reboot
```

After reconnecting through SSH:

```bash
docker ps
```

showed the containers running again.

`twenty-server` was:

```text
Up (healthy)
```

The restart policy remained:

```text
unless-stopped
```

The application health endpoint again returned:

```text
HTTP/1.1 200 OK
```

This confirmed that Docker automatically started the configured containers after the EC2 reboot.

## Log Verification

Application logs were checked with:

```bash
docker logs --tail 10 twenty-server
```

The logs included:

```text
Nest application successfully started
```

This confirmed successful application startup after recovery.

## Verification Summary

| Test | Result |
|---|---|
| Twenty CRM running | Passed |
| Restart policy configured | Passed |
| Docker health check | Passed |
| Health endpoint HTTP 200 | Passed |
| Application process failure recovery | Passed |
| Restart count increased to 1 | Passed |
| EC2 reboot recovery | Passed |
| Successful startup logs | Passed |

## Evidence

Four screenshots were captured:

1. Baseline container, restart policy, and health configuration.
2. Application process failure followed by automatic recovery, `RestartCount=1`, healthy status, and HTTP 200.
3. Container recovery after EC2 reboot and successful health check.
4. Twenty CRM startup logs and final healthy container status.

## Result

Task 16 successfully demonstrated Twenty CRM deployment, Docker health monitoring, automatic recovery after an unexpected application-process failure, and automatic startup after an EC2 reboot.

