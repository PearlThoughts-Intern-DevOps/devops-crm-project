# Docker Compose Deployment Documentation – Twenty CRM

## 1. Objective

The objective is to containerize the Twenty CRM application and its required supporting services using Docker Compose.

The setup provides:

* Isolated containers
* Service-to-service networking
* Persistent storage
* Environment-based configuration
* Health checks
* Automatic container restart
* Single-command application startup

## 2. Architecture

The deployment consists of three containers:

```text
                    Docker Compose
                         |
          +--------------+--------------+
          |              |              |
          v              v              v
     Twenty CRM      PostgreSQL       Redis
     :3000             :5432          :6379
          |              |              |
          +--------- crm-network --------+
```

### Services

1. **Twenty CRM**

   * Main CRM application
   * Port: `3000`

2. **PostgreSQL**

   * Application database
   * Port: `5432`

3. **Redis**

   * Cache service required by Twenty v2.35.0
   * Port: `6379`

## 3. Docker Compose Configuration

Docker Compose defines the application, database, cache, networking, volumes, environment variables, health checks, and service dependencies.

### 3.1 Twenty CRM

```yaml
twenty-crm:
  image: twentycrm/twenty:v2.35.0
  container_name: twenty_crm_app
```

The application uses the official Twenty CRM `v2.35.0` image.

The container is named:

```text
twenty_crm_app
```

It waits for PostgreSQL and Redis to become healthy before starting.

### 3.2 PostgreSQL

```yaml
twenty-db:
  image: postgres:16-alpine
  container_name: twenty_crm_db
```

PostgreSQL is deployed as a separate container.

Database configuration:

```text
Database: default
Username: postgres
Password: postgres
Port: 5432
```

### 3.3 Redis

```yaml
twenty-cache:
  image: redis:7-alpine
  container_name: twenty_crm_cache
```

Redis is deployed as a separate container because Twenty v2.35.0 requires Redis for cache storage.

Redis is available internally at:

```text
twenty-cache:6379
```

## 4. Environment Variables

### Twenty application

```text
NODE_PORT=3000
SERVER_URL=http://localhost:3000
PG_DATABASE_URL=postgres://postgres:postgres@twenty-db:5432/default
REDIS_URL=redis://twenty-cache:6379
STORAGE_TYPE=local
DISABLE_DB_MIGRATIONS=false
DISABLE_CRON_JOBS_REGISTRATION=false
```

### PostgreSQL

```text
POSTGRES_DB=default
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
```

The PostgreSQL connection string uses the Docker service name:

```text
twenty-db
```

instead of `localhost`.

The Redis connection string similarly uses:

```text
twenty-cache
```

instead of `localhost`.

## 5. Networking

All services are connected to:

```text
crm-network
```

The network uses the Docker bridge driver.

This allows containers to communicate using Docker Compose service names.

```text
Twenty
  |
  +---- twenty-db:5432
  |
  +---- twenty-cache:6379
```

PostgreSQL and Redis do not need to expose their ports to the host because they are only accessed internally by the Twenty application.

Only port `3000` is published:

```yaml
ports:
  - "3000:3000"
```

The application is accessed from the host using:

```text
http://localhost:3000
```

## 6. Persistent Storage

Three Docker volumes are configured.

### PostgreSQL

```text
db-data
```

Mounted at:

```text
/var/lib/postgresql/data
```

This keeps PostgreSQL data when the container is recreated.

### Twenty

```text
twenty-data
```

Mounted at:

```text
/app/packages/twenty-server/.local-storage
```

This persists local application storage.

### Redis

```text
redis-data
```

Mounted at:

```text
/data
```

This provides persistent Redis storage.

## 7. Health Checks

### PostgreSQL

PostgreSQL uses:

```bash
pg_isready -U postgres -h localhost -d default
```

Docker marks PostgreSQL as healthy when it can accept connections.

### Redis

Redis uses:

```bash
redis-cli ping
```

A successful response indicates that Redis is available.

### Twenty

Twenty uses:

```bash
curl --fail http://localhost:3000/healthz
```

This checks whether the HTTP server is ready.

## 8. Service Dependencies

Twenty depends on:

```yaml
depends_on:
  twenty-db:
    condition: service_healthy
  twenty-cache:
    condition: service_healthy
```

Therefore:

```text
PostgreSQL
    |
  healthy
    |
Redis
    |
  healthy
    |
Twenty CRM
```

This prevents Twenty from starting before its required services are ready.

## 9. Database Migrations

When a new PostgreSQL volume is created, Twenty detects that the database is empty and performs database setup and migrations.

The startup logs showed:

```text
Running database setup and migrations...
Database appears to be empty, running migrations.
Performed 'create schema "public"' successfully
Performed 'create schema "core"' successfully
Performed 'create extension "uuid-ossp"' successfully
Performed 'create extension "unaccent"' successfully
```

The application should be allowed to finish the migration process before checking the HTTP endpoint.

## 10. Dockerfile

The custom Dockerfile uses a multi-stage build.

```text
Base
 |
 +---- Dependencies
          |
          +---- Build
 |
 +---- Runtime
```

### Base stage

```dockerfile
FROM node:24.5.0-alpine AS base

WORKDIR /app

RUN corepack enable \
    && corepack prepare yarn@4.13.0 --activate

COPY package.json yarn.lock .yarnrc.yml ./
```

This prepares Node.js, Yarn and the application working directory.

### Dependencies stage

```dockerfile
FROM base AS dependencies

RUN yarn install --immutable
```

Dependencies are installed using the lockfile.

`--immutable` prevents Yarn from modifying the lockfile.

### Build stage

```dockerfile
FROM dependencies AS build
```

The required source files are copied and:

```dockerfile
RUN yarn twenty dev:build
```

is executed.

This generates the Twenty development build output.

### Runtime stage

```dockerfile
FROM base AS runtime
```

Only the required application artifacts are copied into the runtime stage.

The container runs using the non-root `node` user:

```dockerfile
USER node
```

This follows the principle of avoiding root execution where possible.

## 11. Important Dockerfile Note

The current `docker-compose.yml` uses:

```yaml
image: twentycrm/twenty:v2.35.0
```

Therefore Docker Compose uses the official prebuilt Twenty image.

The custom Dockerfile is **not currently used by Compose**.

To use the custom Dockerfile, the Compose service would need a `build` configuration such as:

```yaml
build:
  context: .
  dockerfile: Dockerfile
```

The custom Dockerfile should only be switched into the Compose deployment after its runtime command has been verified to start the Twenty server correctly.

## 12. Deployment Commands

Stop the existing stack and remove obsolete containers:

```bash
docker compose down -v --remove-orphans
```

Pull the required images:

```bash
docker compose pull
```

Start the application:

```bash
docker compose up -d
```

Check the containers:

```bash
docker compose ps
```

Check Twenty logs:

```bash
docker compose logs --tail=100 twenty-crm
```

Follow the logs:

```bash
docker compose logs -f twenty-crm
```

Check the application health endpoint:

```bash
curl http://localhost:3000/healthz
```

Open the application:

```text
http://localhost:3000
```

## 13. Expected Container Status

A successful deployment should show:

```text
twenty_crm_app      Up (healthy)
twenty_crm_db       Up (healthy)
twenty_crm_cache    Up (healthy)
```

Port mapping:

```text
0.0.0.0:3000 -> 3000/tcp
```

## 14. Best Practices Applied

The deployment applies the following Docker practices:

* Separate containers for application, database and cache
* Dedicated Docker network
* Persistent named volumes
* Health checks
* Dependency conditions based on service health
* Lightweight Alpine images for PostgreSQL and Redis
* Multi-stage Dockerfile
* Immutable dependency installation
* Non-root application execution in the custom runtime image
* Internal-only database and Redis communication
* Only the application HTTP port is exposed to the host
* Automatic restart using `restart: unless-stopped`

## 15. Troubleshooting

### Container is running but web page does not open

Check:

```bash
docker compose ps
```

Then:

```bash
docker compose logs --tail=200 twenty-crm
```

Check the endpoint:

```bash
curl http://localhost:3000/healthz
```

### PostgreSQL errors

Check:

```bash
docker compose logs twenty-db
```

### Redis errors

Check:

```bash
docker compose logs twenty-cache
```

### Fresh database initialization

If this is a new development environment and the database needs to be recreated:

```bash
docker compose down -v --remove-orphans
docker compose up -d
```

Do not use `down -v` if existing database data must be preserved.

## 16. Final Architecture

The final deployment is:

```text
                    Host Machine
                        |
                 localhost:3000
                        |
                        v
              +-------------------+
              |    Twenty CRM     |
              |    v2.35.0        |
              +---------+---------+
                        |
             +----------+----------+
             |                     |
             v                     v
      +-------------+       +-------------+
      | PostgreSQL  |       |    Redis    |
      |     16      |       |      7      |
      +-------------+       +-------------+
             |                     |
             +------ Volumes ------+
```

The application, PostgreSQL and Redis run as independent containers while communicating through the dedicated `crm-network`.

The browser communicates only with the Twenty CRM application on port `3000`.

