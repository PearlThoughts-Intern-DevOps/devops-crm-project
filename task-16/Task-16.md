# Task 16: Twenty CRM Failure & Recovery

## Objective

The objective of this task was to deploy Twenty CRM on an AWS EC2 instance using Docker and verify automatic recovery after container and EC2 failures.

## Environment

- AWS Region: `us-east-1`
- EC2 Instance Type: `t3.small`
- OS: Ubuntu
- Application: Twenty CRM
- Container Image: `twentycrm/twenty-app-dev:latest`
- Application Port: `2020`
- Docker Restart Policy: `unless-stopped`
- Docker Health Check: HTTP request to `/`

## Docker Configuration

Twenty CRM was started using Docker with:

- Port mapping: `2020:2020`
- Restart policy: `unless-stopped`
- Docker health check using:

```bash
curl -f http://localhost:2020/ || exit 1
```

The health check was configured with:

- Interval: 30 seconds
- Timeout: 10 seconds
- Start period: 120 seconds
- Retries: 3

## Failure and Recovery Test 1: Container Failure

The running container was verified as healthy before the failure test.

The configured restart policy was verified using:

```bash
docker inspect twenty-crm --format='RestartPolicy={{.HostConfig.RestartPolicy.Name}}'
```

Result:

```text
RestartPolicy=unless-stopped
```

The main container process was then terminated to simulate an unexpected application/container failure:

```bash
docker exec twenty-crm sh -c 'kill -TERM 1'
```

The container automatically started again.

The recovery was verified using:

```bash
docker inspect twenty-crm --format='ExitCode={{.State.ExitCode}} OOMKilled={{.State.OOMKilled}} RestartCount={{.RestartCount}} Status={{.State.Status}}'
```

The result showed:

```text
RestartCount=1
Status=running
OOMKilled=false
```

After the application finished initializing, the health status became healthy and the application returned:

```text
HTTP/1.1 200 OK
```

This confirmed that Docker automatically recovered the container after the simulated failure.

## Failure and Recovery Test 2: EC2 Reboot

The EC2 instance was rebooted using:

```bash
sudo reboot
```

After reconnecting to the EC2 instance, the Docker container was already running automatically:

```bash
docker ps
```

Initially, Twenty CRM showed:

```text
Up ... (health: starting)
```

After allowing sufficient time for application initialization, the container became:

```text
Up ... (healthy)
```

The application was then verified using:

```bash
curl -I http://localhost:2020
```

Result:

```text
HTTP/1.1 200 OK
```

The final container status was verified using:

```bash
docker inspect twenty-crm --format='Status={{.State.Status}} Health={{.State.Health.Status}} RestartCount={{.RestartCount}}'
```

Result:

```text
Status=running Health=healthy RestartCount=0
```

This confirmed that the Docker service and configured container restarted automatically after the EC2 reboot.

## Docker Service Verification

Docker was also verified to start automatically with the operating system:

```bash
systemctl is-enabled docker
```

Expected result:

```text
enabled
```

Docker service status was verified using:

```bash
systemctl is-active docker
```

Expected result:

```text
active
```

## Logs and Recovery

Docker logs were checked throughout the failure and recovery tests using:

```bash
docker logs --tail 30 twenty-crm
```

The logs were used to verify Twenty CRM application initialization and recovery.

The application may temporarily remain in `health: starting` after a restart because Twenty CRM requires time to initialize its internal services. Once initialization completed, the health check succeeded and the application returned HTTP 200.

## Final Result

The following recovery scenarios were successfully verified:

1. Twenty CRM runs inside a Docker container on EC2.
2. Docker restart policy is configured as `unless-stopped`.
3. Docker health check monitors the application on port `2020`.
4. A container process failure was simulated.
5. Docker automatically restarted the container.
6. Restart count increased after the failure.
7. Twenty CRM recovered and returned HTTP 200.
8. The EC2 instance was rebooted.
9. Docker automatically started the Twenty CRM container after the reboot.
10. Twenty CRM eventually became healthy after initialization.
11. The application returned HTTP 200 after the EC2 reboot.
12. Docker service was verified as enabled and active.

## Conclusion

Twenty CRM was successfully configured for container-level and EC2-level recovery. Docker's `unless-stopped` restart policy ensured that the application container restarted after an unexpected process failure and automatically started again after the EC2 instance rebooted. The Docker health check provided application-level health verification, and successful HTTP 200 responses confirmed recovery.

### Thank you!
