# Task 16 – Twenty CRM Failure & Recovery

## Objective

The objective of this task is to deploy Twenty CRM using Docker on AWS EC2 and verify automatic recovery after container and EC2 failures.

The task includes:

* Configure Docker restart policy.
* Configure Docker health checks.
* Test Twenty CRM container failure.
* Verify automatic container recovery.
* Restart the EC2 instance.
* Verify Twenty CRM starts automatically after EC2 restart.
* Check logs and application health.

## EC2 Configuration

* **AWS Region:** `us-east-1`
* **Instance Type:** `t3.small`
* **Operating System:** Ubuntu
* **VPC:** Default VPC
* **Application Port:** `2020`
* **Container Port:** `3000`
* **Docker Network:** `twenty-net`

## Docker Configuration

The application is built using a multi-stage Dockerfile.

### Builder Stage

```dockerfile
FROM node:24-alpine AS builder

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

RUN yarn install --immutable

COPY . .

RUN yarn twenty dev:build
```

The builder stage installs dependencies and builds the application using the project's Yarn command.

### Runtime Stage

```dockerfile
FROM node:24-alpine AS runtime

WORKDIR /app

RUN corepack enable

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app/package.json /app/yarn.lock /app/.yarnrc.yml ./
COPY --from=builder /app/.yarn ./.yarn
COPY --from=builder /app/.twenty ./.twenty
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/public ./public
COPY --from=builder /app/tsconfig.json ./tsconfig.json
COPY --from=builder /app/tsconfig.spec.json ./tsconfig.spec.json
COPY --from=builder /root/.cache/node/corepack /root/.cache/node/corepack

RUN chown -R appuser:appgroup /app

USER appuser

CMD ["yarn", "twenty", "dev:build"]
```

The runtime stage creates a non-root user and runs the application as `appuser`.

## Docker Compose Configuration

Three services are configured:

* PostgreSQL
* Redis
* Twenty CRM

All services use the same Docker network:

```yaml
networks:
  twenty-net:
    driver: bridge
```

### PostgreSQL

```yaml
db:
  image: postgres:16-alpine
  restart: unless-stopped
```

A PostgreSQL health check is also configured using `pg_isready`.

### Redis

```yaml
redis:
  image: redis:7-alpine
  restart: unless-stopped
```

Redis is checked using `redis-cli ping`.

### Twenty CRM

The Twenty CRM service uses:

```yaml
restart: unless-stopped
```

Port mapping:

```yaml
ports:
  - "${TWENTY_PORT:-2020}:3000"
```

This maps EC2 port `2020` to the application container port `3000`.

## Twenty CRM Health Check

The application health check is:

```yaml
healthcheck:
  test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000/healthz"]
  interval: 10s
  timeout: 5s
  retries: 30
  start_period: 180s
```

This checks whether the Twenty CRM application is responding through its `/healthz` endpoint.

## Environment Configuration

The port and server URL were configured using:

```bash
sed -i 's/^TWENTY_PORT=.*/TWENTY_PORT=2020/' .env
```

```bash
sed -i 's|^SERVER_URL=.*|SERVER_URL=http://localhost:2020|' .env
```

The `.env` file contains the required application and database configuration.

The `.env` file should not be committed because it contains the application secret.

## Commands Used

### Build Twenty CRM

```bash
docker compose build twenty-server
```

### Start Services

```bash
docker compose up -d
```

### Check Containers

```bash
docker compose ps
```

### Check Application Logs

```bash
docker compose logs twenty-server
```

### Follow Application Logs

```bash
docker compose logs -f twenty-server
```

### Check Health Status

```bash
docker inspect -f '{{.State.Health.Status}}' twenty-server
```

### Check Restart Policy

```bash
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' twenty-server
```

### Check Restart Count

```bash
docker inspect -f '{{.State.Status}} RestartCount={{.RestartCount}}' twenty-server
```

### Check Application

```bash
curl -I http://127.0.0.1:2020
```

## Issues and Solutions

### Issue 1 – Database Connection

Initially, the application could not resolve the database container name.

Error:

```text
could not translate host name "twenty-db" to address
```

### Solution

The database, Redis, and Twenty CRM containers were configured on the same Docker network:

```text
twenty-net
```

This allows the services to communicate using their Docker service/container names.

### Issue 2 – Health Check Was Not Configured

Initially, the application container did not have a Docker health check.

### Solution

A Docker health check was added:

```yaml
test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000/healthz"]
```

The container can then report whether the application is healthy.

### Issue 3 – Application Takes Time to Start

Twenty CRM may temporarily be unavailable while the application starts.

### Solution

A `start_period` of `180s` was configured so Docker allows sufficient startup time before health-check failures are counted.

## Container Failure Test

The Twenty CRM container can be stopped to test Docker recovery.

Command:

```bash
docker compose stop twenty-server
```

The container can then be started again with:

```bash
docker compose start twenty-server
```

For an unexpected process failure, the restart policy is configured as:

```yaml
restart: unless-stopped
```

The restart count can be checked using:

```bash
docker inspect -f '{{.State.Status}} RestartCount={{.RestartCount}}' twenty-server
```

## EC2 Restart Test

The EC2 instance can be restarted using:

```bash
sudo reboot
```

After reconnecting to the EC2 instance, verify the containers:

```bash
docker compose ps
```

Check the application:

```bash
curl -I http://127.0.0.1:2020
```

Check the logs:

```bash
docker compose logs twenty-server
```

## Verification

### 1. Container Status

```bash
docker compose ps
```

Expected:

```text
twenty-server   running
db              running
redis           running
```

### 2. Restart Policy

```bash
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' twenty-server
```

Expected:

```text
unless-stopped
```

### 3. Health Status

```bash
docker inspect -f '{{.State.Health.Status}}' twenty-server
```

Expected:

```text
healthy
```

### 4. Application Response

```bash
curl -I http://127.0.0.1:2020
```

Expected:

```text
HTTP/1.1 200 OK
```

### 5. Restart Count

```bash
docker inspect -f '{{.State.Status}} RestartCount={{.RestartCount}}' twenty-server
```

The restart count should increase after an unexpected container process failure.

### 6. Application Logs

```bash
docker compose logs twenty-server
```

The logs are checked to confirm that the application starts successfully after recovery.

## Final Result

The Docker Compose configuration provides:

* PostgreSQL database service.
* Redis service.
* Twenty CRM application service.
* Docker restart policy.
* Docker health check.
* Persistent Docker volumes.
* Common Docker network.
* Application port mapping from `2020` to `3000`.

The failure and recovery process can be verified using Docker container status, restart count, health status, application response, and application logs.
