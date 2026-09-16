# Task 16: Docker Failure and Recovery

**Name:** Mujtaba Shaikh
**Task:** 16
**Date:** 16 September 2026

## Summary

* Deployed Twenty CRM on AWS EC2 using Docker Compose.
* Configured PostgreSQL and Redis as supporting services.
* Configured Docker restart policy using `unless-stopped`.
* Added Docker health checks for Twenty CRM, PostgreSQL, and Redis.
* Simulated an application process failure.
* Verified Docker automatically restarted the Twenty CRM container.
* Rebooted the EC2 instance and verified that all containers started automatically.
* Verified Twenty CRM was accessible after recovery.

## Docker Configuration

The application was deployed using Docker Compose with the following services:

* Twenty CRM
* PostgreSQL
* Redis

Twenty CRM is exposed on:

```text
EC2 Port: 2020
Container Port: 3000
```

The Twenty CRM container uses:

```yaml
restart: unless-stopped
```

## Health Check

Twenty CRM uses the following health check:

```yaml
healthcheck:
  test: ["CMD-SHELL", "curl --fail http://localhost:3000/healthz || exit 1"]
  interval: 10s
  timeout: 5s
  retries: 10
  start_period: 30s
```

The container image was verified to contain `curl`, so the health check works correctly.

## Initial Verification

Twenty CRM was verified before the failure test.

```text
Status=running
Health=healthy
RestartCount=0
```

The application was also tested locally on the EC2 instance:

```text
HTTP/1.1 200 OK
```

## Failure and Automatic Recovery Test

The main Twenty CRM process was intentionally terminated:

```bash
docker exec twenty-crm sh -c 'kill 1'
```

After 15 seconds:

```text
Status=running
Health=starting
RestartCount=1
```

After the health check completed:

```text
Status=running
Health=healthy
RestartCount=1
```

This confirmed that Docker automatically restarted the Twenty CRM container after the application process failed.

## Application Recovery Verification

The application was tested after recovery:

```bash
curl -I http://localhost:2020
```

Result:

```text
HTTP/1.1 200 OK
```

This confirmed that Twenty CRM was available again after the failure.

## EC2 Reboot Test

The EC2 instance was rebooted using:

```bash
sudo reboot
```

After reconnecting to the EC2 instance, the containers were automatically started by Docker.

```text
twenty-crm        Up
twenty-postgres   Up (healthy)
twenty-redis      Up (healthy)
```

Twenty CRM was initially shown as:

```text
Up ... (health: starting)
```

After startup, the application became healthy.

The application was also verified again using:

```bash
curl -I http://localhost:2020
```

Result:

```text
HTTP/1.1 200 OK
```

## Recovery Verification

Final recovery checks confirmed:

* Twenty CRM container automatically restarted after process failure.
* Restart count increased to `1`.
* Twenty CRM health check became healthy.
* PostgreSQL and Redis started automatically after EC2 reboot.
* Twenty CRM was accessible after EC2 reboot.
* Docker restart policy was configured as `unless-stopped`.

## Conclusion

Task 16 successfully demonstrated Docker failure recovery and automatic container startup after an EC2 reboot using Docker Compose and the `unless-stopped` restart policy.

