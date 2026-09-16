# Task 16: Twenty CRM Failure & Recovery

## Objective

Configure and validate failure recovery for Twenty CRM running on AWS EC2 using Docker.

Requirements:
- Run Twenty CRM on EC2 using Docker.
- Configure a Docker restart policy.
- Add a Docker health check.
- Manually stop/kill the Twenty CRM container.
- Verify Docker recovery behavior.
- Stop and restart the EC2 instance.
- Verify Twenty CRM starts again after EC2 restart.
- Review application/container logs.
- Document the failure and recovery process.

## Environment

| Item | Value |
|---|---|
| AWS Region | us-east-1 |
| Instance type | t3.small |
| OS | Amazon Linux 2023 |
| Instance ID | i-0190dc21b6619b386 |
| Public IP | 34.234.236.73 |
| Application URL | http://34.234.236.73:3000 |
| Branch | netaji-task16 |

## Infrastructure

Terraform provisions a default-VPC/subnet EC2 deployment, a security group allowing SSH (22) and Twenty CRM (3000), and a public IP.

Terraform plan reported:

```text
No changes. Your infrastructure matches the configuration.
```

The final fresh instance was created successfully with Terraform.

## Docker Setup

Docker was installed and enabled:

```bash
sudo dnf update -y
sudo dnf install -y docker
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
```

After reconnecting, `docker ps` worked without `sudo`.

## Twenty CRM Configuration

Twenty CRM was deployed under:

```text
/opt/twenty-crm
```

The non-secret application configuration included:

```text
SERVER_URL=http://34.234.236.73:3000
PG_DATABASE_URL=postgresql://postgres:postgres@db:5432/twenty
REDIS_URL=redis://redis:6379
NODE_PORT=3000
```

The encryption key was generated on the EC2 instance and is intentionally not documented here.

## Docker Compose

Services:
- `twenty-server`
- `twenty-worker`
- `twenty-postgres`
- `twenty-redis`

The Twenty server uses:

```yaml
restart: unless-stopped
```

Health check:

```yaml
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:3000/ || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

PostgreSQL, Redis, and worker also use `restart: unless-stopped`.

## Controlled Startup

Dependencies were started first:

```bash
docker-compose up -d db redis
```

Then the application server:

```bash
docker-compose up -d server
```

The server container started successfully.

## Health Check Validation

The server was inspected with:

```bash
docker inspect --format='Status={{.State.Status}} Health={{if .State.Health}}{{.State.Health.Status}}{{else}}not-configured{{end}} RestartPolicy={{.HostConfig.RestartPolicy.Name}}' twenty-server
```

Observed initially:

```text
Status=running Health=starting RestartPolicy=unless-stopped
```

After the startup period:

```text
Health=healthy
```

The health-check history showed initial connection failures while the application was starting, followed by successful HTTP responses from Twenty.

## Failure Test

A graceful stop was performed:

```bash
docker stop twenty-server
```

Observed:

```text
Status=exited RestartCount=0
```

This is expected for `restart: unless-stopped`: an intentionally stopped container remains stopped.

The container was restored with:

```bash
docker start twenty-server
```

The next planned test was an abrupt failure using:

```bash
docker kill twenty-server
```

The AWS internship environment reached its scheduled 6 PM shutdown window before the resulting automatic-restart state could be captured.

## EC2 Reboot Recovery

The intended validation procedure was:

1. Confirm Twenty is healthy.
2. Stop the EC2 instance.
3. Start the EC2 instance.
4. SSH back into the instance.
5. Confirm Docker is running.
6. Confirm Twenty and its dependencies are running.
7. Confirm the HTTP endpoint is available.
8. Review Docker/application logs.

This final EC2 stop/start validation could not be completed before the scheduled AWS environment shutdown.

## Logs

Health-check history was inspected with:

```bash
docker inspect --format='{{range .State.Health.Log}}{{.ExitCode}} {{.Output}}{{"\n"}}{{end}}' twenty-server
```

The history showed initial:

```text
curl: (7) Failed to connect to localhost:3000
```

followed by successful HTTP responses containing the Twenty application HTML.

## Command Note

This EC2 environment provides the standalone `docker-compose` command. The Docker CLI `docker compose` subcommand was not available, so commands should use:

```bash
docker-compose
```

## Verification Summary

| Requirement | Result |
|---|---|
| EC2 created with Terraform | Verified |
| t3.small | Verified |
| Docker installed | Verified |
| Docker enabled | Verified |
| Twenty CRM started | Verified |
| Restart policy configured | Verified: `unless-stopped` |
| Health check configured | Verified |
| Health reached healthy | Verified |
| Manual graceful stop tested | Verified |
| Unexpected `docker kill` recovery | Not captured before shutdown |
| EC2 stop/start recovery | Not captured before shutdown |
| Logs reviewed | Verified |

## Conclusion

Task 16 infrastructure and Docker configuration were implemented on a t3.small EC2 instance. Twenty CRM successfully started, its health check reached healthy, and the required `unless-stopped` restart policy was confirmed. The remaining failure/recovery observations could not be captured after the AWS internship environment reached its scheduled shutdown window.
