# Docker Setup – Twenty CRM

## Task 5: Docker Containerization

### 1. Project Overview

The project is a Twenty CRM application containerized using Docker.

The Docker setup contains three services:

- Twenty CRM application
- PostgreSQL database
- Redis cache

The services communicate through a dedicated Docker bridge network.

---

## 2. Dockerfile

A multi-stage Dockerfile was created to containerize the application.

### Stages used

1. **Base stage**
   - Uses Node.js 24.5.0 Alpine.
   - Enables Corepack.
   - Activates Yarn 4.13.0.

2. **Dependencies stage**
   - Installs project dependencies using:
     `yarn install --immutable`

3. **Build stage**
   - Copies TypeScript configuration and application source files.
   - Builds the application using:
     `yarn twenty build`

4. **Runtime stage**
   - Copies only the required dependencies and build output.
   - Runs the container as the non-root `node` user.

### Docker best practices

- Multi-stage build
- Alpine-based Node.js image
- Dependency layer caching
- Immutable Yarn installation
- Non-root container execution
- Minimal runtime files

---

## 3. Docker Ignore

A `.dockerignore` file was created to prevent unnecessary files from being sent to the Docker build context.

Examples of excluded files/directories include:

- node_modules
- Git files
- Environment files
- Docker-related local files
- Build/cache files

This reduces the Docker build context and improves build performance.

---

## 4. Docker Compose

The `docker-compose.yml` file defines three services.

### Twenty CRM

- Image: `twentycrm/twenty:v2.35.0`
- Port: `3000:3000`
- Depends on PostgreSQL and Redis
- Connected to `crm-network`

### PostgreSQL

- Image: `postgres:16-alpine`
- Database: `default`
- Username: `postgres`
- Persistent volume: `db-data`
- Health check enabled

### Redis

- Image: `redis:7-alpine`
- Redis health check enabled
- Configured with `noeviction` memory policy

---

## 5. Environment Variables

The application is configured using environment variables for:

- Application port
- Database connection
- Redis connection
- Server URL
- Storage type
- Application secret
- Encryption key
- Database migration settings
- Cron job settings

Secrets are provided through environment configuration rather than being hard-coded into application source code.

---

## 6. Networking

A dedicated Docker bridge network named `crm-network` is used.

The services communicate using Docker service names:

- `twenty-db`
- `twenty-cache`

Example database connection:

`postgres://postgres:postgres@twenty-db:5432/default`

Example Redis connection:

`redis://twenty-cache:6379`

---

## 7. Persistent Storage

A Docker named volume called `db-data` is used for PostgreSQL.

This ensures that database data is retained when the PostgreSQL container is recreated.

---

## 8. Commands Used

### Validate Compose configuration

```bash
docker compose config