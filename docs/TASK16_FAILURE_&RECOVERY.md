# Task 16: Twenty CRM Failure and Recovery

**Name:** P. HARISH
**Date:** 16 September 2026
**PR link:** [https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project/pull/381]
**Loom link:** [https://drive.google.com/file/d/1HXruoz3VbTTWcHOKLd5VN9mX9QmEa7DL/view?usp=drive_link]

## Objective

* Deploy Twenty CRM on an AWS EC2 instance using Docker.
* Configure automatic container restart after an unexpected failure.
* Configure Docker health checks for the application.
* Test container failure and automatic recovery.
* Restart the EC2 instance and verify automatic recovery.
* Verify the application using logs and HTTP response.

---

# 1. EC2 Configuration

| Configuration          | Value            |
| ---------------------- | ---------------- |
| Cloud Provider         | AWS              |
| Region                 | `us-east-1`      |
| Instance Type          | `t3.small`       |
| Operating System       | Ubuntu           |
| Public IP              | `100.28.210.235` |
| Application Port       | `2020`           |
| Docker Version         | `29.1.3`         |
| Docker Compose Version | `2.29.2`         |

---

# 2. Repository Configuration

Repository:

```text
devops-crm-project
```

Branch:

```text
harish-task16
```

Clone the repository:

```bash
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
```

Create and switch to the Task 16 branch:

```bash
git checkout -b harish-task16
```

---

# 3. Dockerfile

The following Dockerfile was used for building the application image.

```dockerfile
FROM node:24-alpine AS builder

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

RUN yarn install --immutable

COPY . .

RUN yarn twenty dev:build


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

---

# 4. Docker Compose Configuration

The application, PostgreSQL, and Redis services were configured using Docker Compose.

```yaml
services:

  db:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${PG_DATABASE_USER:-postgres}
      POSTGRES_PASSWORD: ${PG_DATABASE_PASSWORD:-postgres}
      POSTGRES_DB: ${PG_DATABASE_NAME:-default}
    volumes:
      - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${PG_DATABASE_USER:-postgres}"]
      interval: 5s
      timeout: 5s
      retries: 10
    networks:
      - twenty-net

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 10
    networks:
      - twenty-net

  twenty-server:
    build:
      context: .
      dockerfile: Dockerfile

    restart: unless-stopped

    environment:
      NODE_PORT: 3000
      PG_DATABASE_URL: postgres://${PG_DATABASE_USER:-postgres}:${PG_DATABASE_PASSWORD:-postgres}@db:5432/${PG_DATABASE_NAME:-default}
      REDIS_URL: redis://redis:6379
      SERVER_URL: ${SERVER_URL:-http://localhost:2020}
      APP_SECRET: ${APP_SECRET:?APP_SECRET must be set in .env}
      STORAGE_TYPE: local

    ports:
      - "${TWENTY_PORT:-2020}:3000"

    volumes:
      - twenty-server-data:/app/packages/twenty-server/.local-storage

    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy

    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000/healthz"]
      interval: 10s
      timeout: 5s
      retries: 30
      start_period: 180s

    networks:
      - twenty-net


volumes:
  db-data:
  redis-data:
  twenty-server-data:


networks:
  twenty-net:
    driver: bridge
```

---

# 5. Environment Configuration

The `.env` file was created for the Docker Compose configuration.

```text
PG_DATABASE_USER=postgres
PG_DATABASE_PASSWORD=postgres
PG_DATABASE_NAME=default
APP_SECRET=<secret>
SERVER_URL=http://100.28.210.235:2020
TWENTY_PORT=2020
```

The application secret was kept private and was not committed to Git.

To check the environment configuration without displaying the secret:

```bash
grep -v APP_SECRET .env
```

---

# 6. Docker Compose Commands

Build the application:

```bash
docker-compose build
```

Start all services:

```bash
docker-compose up -d
```

Check running services:

```bash
docker-compose ps
```

Check application logs:

```bash
docker-compose logs twenty-server
```

Follow application logs:

```bash
docker-compose logs -f twenty-server
```

Stop the Compose services:

```bash
docker-compose down
```

Start them again:

```bash
docker-compose up -d
```

---

# 7. Restart Policy

The application container was configured with:

```yaml
restart: unless-stopped
```

This allows Docker to automatically restart the container when the application process exits unexpectedly.

The restart policy was verified using:

```bash
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' twenty-crm
```

Expected result:

```text
unless-stopped
```

---

# 8. Health Check

The application health check was configured to test the application endpoint.

```yaml
healthcheck:
  test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000/healthz"]
  interval: 10s
  timeout: 5s
  retries: 30
  start_period: 180s
```

The health check verifies whether the application is responding on port `3000` inside the container.

Health status can be checked using:

```bash
docker inspect -f '{{.State.Health.Status}}' twenty-server
```

For the running application container:

```bash
docker inspect -f '{{.State.Health.Status}}' twenty-crm
```

Expected result:

```text
healthy
```

---

# 9. Container Failure Test

To test automatic recovery, the main process of the Twenty CRM container was intentionally terminated:

```bash
docker exec twenty-crm sh -c 'kill -TERM 1'
```

Docker detected that the container process had stopped and automatically restarted the container because of:

```text
restart: unless-stopped
```

The restart count was checked using:

```bash
docker inspect -f '{{.State.Status}} RestartCount={{.RestartCount}}' twenty-crm
```

The restart count increased after the failure test.

Example:

```text
running RestartCount=1
```

---

# 10. Application Recovery Verification

After the container restarted, the application was tested using:

```bash
curl -I http://127.0.0.1:2020
```

Expected response:

```text
HTTP/1.1 200 OK
```

The application may require some time to complete startup after a restart.

---

# 11. EC2 Restart Test

The EC2 instance was restarted using:

```bash
sudo reboot
```

After the EC2 instance became available again, SSH was used to reconnect.

Check running containers:

```bash
docker ps
```

Check the application container:

```bash
docker inspect -f '{{.State.Status}} RestartCount={{.RestartCount}} Health={{.State.Health.Status}}' twenty-crm
```

Test the application:

```bash
curl -I http://127.0.0.1:2020
```

Expected response:

```text
HTTP/1.1 200 OK
```

---

# 12. Log Verification

Twenty CRM logs were checked using:

```bash
docker logs twenty-crm
```

or:

```bash
docker-compose logs twenty-server
```

Recent logs can be viewed using:

```bash
docker logs --tail 100 twenty-crm
```

The logs were checked to confirm that the application completed startup after recovery.

Important application startup message:

```text
Nest application successfully started
```

---

# 13. Issues and Solutions

## Issue 1: Dockerfile Build Command

The Dockerfile uses:

```bash
yarn twenty dev:build
```

during the build and also as the container command.

The command is related to the development build process, so it can complete and exit instead of behaving like a continuously running application server.

### Solution

The container lifecycle and restart behavior were tested separately, and the Docker configuration was checked to ensure that the required restart policy and health-check configuration were present.

---

## Issue 2: Database Hostname Resolution

Initially, the application could not resolve the PostgreSQL hostname.

Error:

```text
could not translate host name "twenty-db" to address
```

### Cause

The application, PostgreSQL, and Redis containers were not initially connected to the same Docker network.

### Solution

Docker Compose was configured with a common network:

```yaml
networks:
  twenty-net:
    driver: bridge
```

The services were connected to:

```yaml
networks:
  - twenty-net
```

This allowed the services to communicate using their service names.

---

## Issue 3: Application Startup Delay

After restarting the container or EC2 instance, the application was temporarily unavailable.

### Solution

The application was given enough time to complete startup before performing the HTTP verification.

The health check also includes a startup period:

```yaml
start_period: 180s
```

---

## Issue 4: Database Migration Messages

During application startup, database migration and configuration messages were observed in the logs.

The application completed its startup process and subsequently responded successfully to the HTTP request.

The logs were checked after recovery to confirm successful application startup.

---

# 14. Verification Commands

Check all containers:

```bash
docker ps
```

Check all containers including stopped containers:

```bash
docker ps -a
```

Check restart policy:

```bash
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' twenty-crm
```

Check status, restart count and health:

```bash
docker inspect -f '{{.State.Status}} RestartCount={{.RestartCount}} Health={{.State.Health.Status}}' twenty-crm
```

Check application port:

```bash
docker port twenty-crm
```

Check application:

```bash
curl -I http://127.0.0.1:2020
```

Check logs:

```bash
docker logs twenty-crm
```

Check latest logs:

```bash
docker logs --tail 100 twenty-crm
```

Check Compose services:

```bash
docker-compose ps
```

Check Compose application logs:

```bash
docker-compose logs twenty-server
```

---

# 15. Final Verification

The final verification should show:

```text
Container Status: running
Health Status: healthy
Restart Policy: unless-stopped
Restart Count: increased after failure test
Application Response: HTTP/1.1 200 OK
```

The following command provides the main container verification:

```bash
docker inspect -f '{{.State.Status}} RestartCount={{.RestartCount}} Health={{.State.Health.Status}}' twenty-crm
```

The application response was verified using:

```bash
curl -I http://127.0.0.1:2020
```

---

# 16. Git Commands

Check the current branch:

```bash
git branch
```

Check repository status:

```bash
git status
```

Make sure `.env` is not included:

```bash
git status
```

Add the Task 16 documentation:

```bash
git add docs/TASK16_TWENTY_CRM_FAILURE_RECOVERY.md
```

Commit the documentation:

```bash
git commit -m "Task-16 CRM failure and recovery completed"
```

Push the branch:

```bash
git push -u origin harish-task16
```

---

# 17. Pull Request

After pushing the branch, create a Pull Request with:

**Title:**

```text
Task-16: CRM Failure and Recovery
```

**Description:**

```markdown

 Task 16: Twenty CRM Failure and Recovery

- Configured Twenty CRM using Docker.
- Added Docker restart policy.
- Added Docker health check.
- Tested container failure and automatic recovery.
- Restarted the EC2 instance and verified container recovery.
- Verified application availability using HTTP response.
- Checked application logs after recovery.
- Added Task 16 documentation.
```

---

# 18. Task Result

The Task 16 failure and recovery process was documented and tested.

Failure recovery was tested by terminating the application container and verifying that Docker restarted it.

EC2 restart recovery was tested using `sudo reboot`, followed by container and application verification.

Application logs and HTTP response were checked after recovery.
