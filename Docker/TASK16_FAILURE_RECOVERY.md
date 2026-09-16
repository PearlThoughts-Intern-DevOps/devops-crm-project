# Task 16 – Twenty CRM Failure & Recovery

## Objective

Deploy Twenty CRM using Docker on EC2 and verify automatic recovery after container failure and EC2 restart.

## Environment

- AWS EC2 - Amazon Linux 2023
- Docker
- Docker Compose
- Twenty CRM
- PostgreSQL 16
- Redis 7
- Application Port: 2020

## Docker Configuration

Configured Twenty CRM with:

- Restart policy: `unless-stopped`
- Docker health check using `/healthz`
- PostgreSQL dependency
- Redis dependency
- Persistent PostgreSQL volume
- `ENCRYPTION_KEY` configured using `.env`

## Container Failure Test

The Twenty CRM main process was intentionally terminated using:

    sudo kill -9 <PID>

Docker automatically restarted the Twenty CRM container.

Verification:

    docker inspect twenty-crm --format 'Status={{.State.Status}} RestartCount={{.RestartCount}} Health={{.State.Health.Status}}'

Result:

    Status=running RestartCount=1 Health=healthy

This confirmed that Docker automatically recovered the application after an unexpected process failure.

## EC2 Restart Test

The EC2 instance was restarted using:

    sudo reboot

After reconnecting to the EC2 instance, the containers were checked using:

    docker ps

PostgreSQL, Redis, and Twenty CRM containers automatically started after the EC2 reboot.

Final verification:

    Status=running RestartCount=1 Health=healthy

PostgreSQL and Redis were also reported as healthy.

## Logs and Recovery

Docker container status and health checks were used to verify successful recovery.

The Twenty CRM container returned to a healthy state after both:

1. Main application process failure
2. EC2 instance restart

## Final Verification

- Twenty CRM container running
- PostgreSQL container healthy
- Redis container healthy
- Restart policy configured
- Health check configured
- Automatic container recovery verified
- Automatic recovery after EC2 restart verified
- Application port 2020 available

## Conclusion

Task 16 was completed successfully. Twenty CRM was configured with Docker restart and health-check mechanisms, and automatic recovery was verified after both container failure and EC2 restart.
