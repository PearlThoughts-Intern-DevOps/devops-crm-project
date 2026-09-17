# Task 16 — Twenty CRM Failure & Recovery

## Objective

Test and configure failure recovery for the Twenty CRM application running on an AWS EC2 instance using Docker.

## Environment

- EC2 Instance: `i-045d59702c781e4ef`
- Instance Name: `tannu-twenty-crm-task16`
- Instance Type: `t3.small`
- OS: Ubuntu
- Docker: 29.1.3
- Docker Compose: 2.40.3
- Twenty CRM Image: `twentycrm/twenty:latest`
- Application Port: `3000`

## 1. Twenty CRM Deployment

Twenty CRM was deployed on the EC2 instance using Docker Compose.

The deployment consists of:

- PostgreSQL
- Redis
- Twenty CRM Server
- Twenty CRM Worker

Persistent Docker volumes were configured for application data, PostgreSQL and Redis.

## 2. Docker Restart Policy

The Docker Compose configuration uses:

```yaml
restart: unless-stopped

for the application and supporting services.

This allows Docker to automatically restart containers after an unexpected container failure and start them again when Docker starts after an EC2 reboot.

3. Docker Health Check

A health check was configured for the Twenty CRM server:

healthcheck:
  test: ["CMD-SHELL", "curl --fail http://localhost:3000/ || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 10
  start_period: 5m

PostgreSQL uses pg_isready and Redis uses redis-cli ping for their respective health checks.

4. Manual Container Failure Test

The Twenty CRM server container was manually terminated using:

sudo docker kill twenty-crm-server-1
5. Automatic Container Recovery

Docker automatically restarted the Twenty CRM server because the container was configured with:

restart: unless-stopped

The container restart count increased, confirming automatic container recovery.

6. EC2 Restart Test

The EC2 instance was stopped and started again through the AWS EC2 console.

After the instance returned to the running state, SSH access was restored.

7. Twenty CRM Recovery After EC2 Restart

The following command was used to verify the containers:

sudo docker ps

After the EC2 restart, all required services automatically started:

twenty-crm-db-1
twenty-crm-redis-1
twenty-crm-server-1
twenty-crm-worker-1

Post-restart output showed PostgreSQL and Redis as healthy and the Twenty CRM server in the application startup/health-check phase.

This confirmed that the Docker services automatically started after the EC2 restart.

8. Logs Verification

Twenty CRM application logs were checked using:

sudo docker logs --tail 30 twenty-crm-server-1

The logs showed application startup and database configuration/migration activity.

Important recovery log entries included:

[DatabaseConfigDriver] [INIT] Loading initial config variables from database
[DatabaseConfigDriver] [INIT] Config variables loaded
[FlushCacheCommand] Flushing all namespaces for pattern: *...
[FlushCacheCommand] Cache flushed

These logs confirmed that the application startup and recovery process was executed after the EC2 restart.

9. Failure and Recovery Summary
Container Failure

Twenty CRM server container was manually killed.

Result: Docker automatically restarted the container using the configured restart policy.

EC2 Failure

The EC2 instance was stopped and started again.

Result: Docker services automatically started after the EC2 instance came back online, including the Twenty CRM server and worker.

Conclusion

Twenty CRM failure and recovery behavior was configured and tested successfully.

The task demonstrated:

Docker restart policy configuration.
Twenty CRM container failure and automatic recovery.
EC2 stop/start recovery.
Automatic startup of Docker services after EC2 restart.
Application and container log verification.