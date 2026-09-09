# Task 5: Docker Containerization

## 1. Objective

The objective of this task was to containerize the Twenty CRM project using Docker.

The following were implemented:

* Dockerfile
* Multi-stage Docker build
* `.dockerignore`
* `docker-compose.yml`
* PostgreSQL and Redis services
* Docker networking
* Persistent volumes
* Environment variables
* Non-root container execution
* Docker image build and application deployment

---

## 2. Docker Architecture

The Docker Compose setup contains four services:

```text
                    Browser
                       |
                       |
               localhost:2020
                       |
                       v
              +----------------+
              |   Twenty CRM   |
              |   twenty-crm   |
              +-------+--------+
                      |
              +-------+-------+
              |               |
              v               v
        +-----------+    +-----------+
        | PostgreSQL|    |   Redis   |
        |   :5432   |    |   :6379   |
        +-----------+    +-----------+

              +----------------+
              |   twenty-app   |
              | Custom Docker  |
              |     Image      |
              +----------------+
```

All services communicate through the Docker network:

```text
twenty-network
```

---

## 3. Dockerfile

A multi-stage Dockerfile was created.

### Builder Stage

The builder stage:

* Uses Node.js 24.5 Alpine.
* Enables Corepack.
* Installs project dependencies using Yarn.
* Copies the project source code.
* Builds the application.

```dockerfile
FROM node:24.5-alpine AS builder

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

RUN yarn install --immutable

COPY . .

RUN yarn twenty dev:build
```

### Runtime Stage

The runtime stage uses a fresh Alpine image and creates a non-root user.

```dockerfile
FROM node:24.5-alpine

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/yarn.lock ./yarn.lock
COPY --from=builder /app/.yarnrc.yml ./.yarnrc.yml
COPY --from=builder /app/.yarn ./.yarn
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

RUN chown -R appuser:appgroup /app

USER appuser

CMD ["yarn", "twenty", "dev"]
```

### Docker Best Practices Used

* Multi-stage build
* Alpine-based image
* Proper dependency layers
* Non-root user
* Separate build and runtime stages

---

## 4. `.dockerignore`

The `.dockerignore` file excludes unnecessary files from the Docker build context.

```text
# Dependencies
node_modules
.pnp
.pnp.js

# Build output
dist
build
.next
.cache

# Version control
.git
.gitignore
.github

# Environment files
.env
.env.*
!.env.example

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# IDE
.vscode
.idea

# OS files
.DS_Store
Thumbs.db

# Testing / coverage
coverage
.nyc_output

# Documentation
README.md
docs

# Docker
Dockerfile
docker-compose.yml
.dockerignore
```

This prevents unnecessary files such as `node_modules`, Git files, logs, environment files, and build output from being included in the Docker build context.

---

## 5. Docker Compose

The `docker-compose.yml` contains four services:

### Twenty CRM

```yaml
twenty:
  image: twentycrm/twenty:latest
  container_name: twenty-crm
  ports:
    - "2020:3000"
```

The application is available at:

```text
http://localhost:2020
```

### PostgreSQL

```yaml
postgres:
  image: postgres:16-alpine
```

PostgreSQL stores the Twenty CRM database.

### Redis

```yaml
redis:
  image: redis:7-alpine
```

Redis is used by Twenty CRM for caching and related services.

### Custom Application

```yaml
app:
  build:
    context: .
    dockerfile: Dockerfile
```

This service builds the custom Docker image using the Dockerfile created for the task.

---

## 6. Environment Variables

The Twenty CRM container was configured with:

```text
SERVER_URL=http://localhost:2020
PG_DATABASE_URL=postgres://twenty:twenty@postgres:5432/default
REDIS_URL=redis://redis:6379
STORAGE_TYPE=local
APP_SECRET=twenty-task5-secret
NODE_ENV=production
```

The custom application container uses:

```text
TWENTY_API_URL=http://twenty:3000
```

---

## 7. Networking

A custom Docker bridge network was created:

```yaml
networks:
  twenty-network:
    driver: bridge
```

All services are connected to this network.

Containers communicate using service names such as:

```text
twenty:3000
postgres:5432
redis:6379
```

---

## 8. Volumes

Two named volumes were configured.

### Twenty CRM storage

```text
twenty-storage
```

Mounted at:

```text
/app/packages/twenty-server/.local-storage
```

### PostgreSQL storage

```text
postgres-data
```

Mounted at:

```text
/var/lib/postgresql/data
```

These volumes provide persistent storage for the application and database.

---

## 9. Build and Run

The existing containers were stopped:

```bash
docker compose down
```

The Twenty CRM image was pulled:

```bash
docker compose pull twenty
```

The custom application image was built:

```bash
docker compose build --no-cache app
```

The build completed successfully:

```text
✔ app Built
```

The complete application was started:

```bash
docker compose up -d
```

The containers started successfully:

```text
✔ twenty-redis Healthy
✔ twenty-postgres Healthy
✔ twenty-crm Started
✔ twenty-app Started
```

---

## 10. Container Verification

Container status was checked using:

```bash
docker compose ps
```

The result showed:

```text
twenty-app        Up
twenty-crm        Up
twenty-postgres   Up (healthy)
twenty-redis      Up (healthy)
```

This confirmed that all required services were running.

---

## 11. Application Verification

The application was tested using:

```bash
curl -I http://localhost:2020
```

After the initial startup and database initialization, the application returned:

```text
HTTP/1.1 200 OK
```

This confirmed that Twenty CRM was successfully running and accessible.

The application was also opened successfully in the browser at:

```text
http://localhost:2020
```

---

## 12. Issues Faced and Solutions

### Issue 1: Connection reset during initial startup

Initially:

```text
curl: (56) Recv failure: Connection reset by peer
```

Twenty CRM was still starting and performing database initialization and migrations.

After waiting approximately 20 to 30 seconds, the application became available and returned:

```text
HTTP/1.1 200 OK
```

### Issue 2: Docker Compose Bake warning

During the build, Docker displayed:

```text
Docker Compose is configured to build using Bake, but buildx isn't installed
```

This was only a warning. The image still built successfully:

```text
✔ app Built
```

No action was required for the task.

### Issue 3: Initial Dockerfile did not use best practices

The first Dockerfile was single-stage and used the default root user.

It was improved by:

* Adding a multi-stage build.
* Using Alpine.
* Creating `appuser`.
* Changing ownership to `appuser`.
* Running the application with `USER appuser`.

The configuration was verified with:

```bash
docker inspect twenty-app --format '{{.Config.User}}'
```

Output:

```text
appuser
```

This confirms non-root execution is configured.

---

## 13. Final Status

| Requirement               | Status     |
| ------------------------- | ---------- |
| Dockerfile                | Completed  |
| Multi-stage build         | Completed  |
| `.dockerignore`           | Completed  |
| Docker Compose            | Completed  |
| PostgreSQL                | Completed  |
| Redis                     | Completed  |
| Environment variables     | Completed  |
| Networking                | Completed  |
| Volumes                   | Completed  |
| Non-root execution        | Completed  |
| Docker image build        | Successful |
| Docker Compose deployment | Successful |
| Application verification  | Successful |

## Conclusion

The Twenty CRM project was successfully containerized using Docker.

The final setup uses a multi-stage Dockerfile, Alpine-based images, a non-root application user, `.dockerignore`, Docker Compose, PostgreSQL, Redis, networking, and persistent volumes.

The application was successfully started with Docker Compose and verified using:

```bash
curl -I http://localhost:2020
```

which returned:

```text
HTTP/1.1 200 OK
```

Therefore, the Docker containerization requirements for Task 5 have been completed successfully.

