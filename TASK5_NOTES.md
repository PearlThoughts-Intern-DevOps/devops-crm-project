# Task 5: Docker Containerization

## Objective

Containerize the `devops-crm-project` application using Docker and orchestrate it with its required backend services using Docker Compose.

## What I Did

I studied the Twenty CRM application structure and identified its main dependencies:

- Twenty CRM server
- PostgreSQL
- Redis
- Node.js
- Yarn 4
- Twenty SDK

I created:

- `Dockerfile`
- `.dockerignore`
- `docker-compose.yml`

The Dockerfile uses a multi-stage build, while Docker Compose manages the application and its required services.

## Application Architecture

The project is a Twenty CRM application/extension built using the Twenty SDK. It does not provide its own standalone HTTP server like a traditional Express or Spring Boot application.

The architecture is:

```
                    Docker Compose
                         |
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
   PostgreSQL          Redis         Twenty Server
    postgres:16       redis:7       twentycrm/twenty
        │                │                │
        └────────────────┴────────────────┘
                         │
                    twenty-net
                         │
                         ▼
                       App
                  Built from Dockerfile
```

## Services

| Service | Image | Purpose |
|---|---|---|
| db | postgres:16-alpine | Stores Twenty CRM data |
| redis | redis:7-alpine | Cache/background jobs |
| twenty-server | twentycrm/twenty | Twenty CRM backend |
| app | Local Dockerfile | Builds/packages the CRM application |

## Dockerfile

The Dockerfile uses a two-stage build.

### Stage 1 — Builder

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

The builder stage:

- Starts with Node.js 24 Alpine.
- Enables Corepack for Yarn 4.
- Copies dependency files first.
- Installs dependencies.
- Copies the application source.
- Runs: `yarn twenty dev:build`

This creates the application build output.

### Stage 2 — Runtime

The second stage starts from a clean Node.js Alpine image and copies the files required to use the application.

A dedicated Linux group and user are created:

```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
```

The container then runs as `appuser` instead of root.

## Docker Best Practices Used

**Multi-stage build**
Separates build dependencies from the final image.

**Alpine image**
Uses `node:24-alpine`, which provides a smaller base image than a full Linux distribution.

**Docker layer caching**
Dependency files are copied before the source code:

```dockerfile
COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn install --immutable
```

This allows Docker to reuse the dependency layer when only application source files change.

**Non-root execution**
The application runs using `USER appuser` instead of root.

## .dockerignore

The `.dockerignore` excludes unnecessary files such as:

- node_modules
- .git
- .env
- logs
- .twenty/output
- editor files
- OS-specific files

This reduces the Docker build context and prevents sensitive `.env` files from being copied into the image.

## Docker Compose

Docker Compose is used to run the complete environment.

The services communicate through:

```yaml
networks:
  twenty-net:
    driver: bridge
```

Inside the Docker network, services can communicate using their service names. For example: `db:5432`, `redis:6379`, `twenty-server:3000` instead of using localhost.

### PostgreSQL

PostgreSQL stores the CRM database.

```yaml
db:
  image: postgres:16-alpine
```

A named volume `db-data` keeps database data persistent when containers are restarted.

A health check using `pg_isready` verifies that PostgreSQL is ready.

### Redis

Redis provides caching and background-job support.

```yaml
redis:
  image: redis:7-alpine
```

A health check using `redis-cli ping` verifies that Redis is available.

### Twenty Server

The Twenty server connects to PostgreSQL and Redis.

Its database connection uses the Docker service name `db`, and Redis uses `redis`.

The server exposes `3000` to the host.

Therefore the CRM can be accessed through `http://localhost:3000`.

The Twenty server waits for PostgreSQL and Redis to become healthy before starting.

## Environment Variables

Environment variables are stored in `.env`.

For example:

- PG_DATABASE_USER
- PG_DATABASE_PASSWORD
- PG_DATABASE_NAME
- APP_SECRET
- TWENTY_PORT
- SERVER_URL
- TWENTY_VERSION

The `.env` file is not committed to Git.

An example configuration is provided through `.env.example`.

An application secret can be generated using:

```
openssl rand -base64 32
```

## Volumes

Docker named volumes are used for persistent data:

- db-data
- redis-data
- twenty-server-data

This means removing and recreating containers does not automatically remove the stored application data.

## Health Checks

Health checks are configured for:

- PostgreSQL
- Redis
- Twenty Server

For example, PostgreSQL uses `pg_isready`. Redis uses `redis-cli ping`. Twenty Server uses `/healthz`.

Docker Compose uses these health checks to control service startup order.

## Commands Used

**Create environment file**
```bash
cp .env.example .env
```

Generate the application secret:
```bash
openssl rand -base64 32
```

**Build and start**
```bash
docker compose up --build
```

**Check containers**
```bash
docker compose ps
```

**Stop containers**
```bash
docker compose down
```

**View logs**
```bash
docker compose logs -f
```

## Verification

The Docker Compose stack was tested successfully.

The following services reached a healthy state:

```
db                 Up (healthy)
redis              Up (healthy)
twenty-server      Up (healthy)
```

The Twenty CRM UI was accessible at `http://localhost:3000`.

The application Docker image also successfully completed `yarn twenty dev:build` with:

```
✓ Build succeeded (5 files)
```

## Issues Faced and Solutions

### 1. Docker Compose YAML indentation error

**Error**
```
services.redis additional properties 'twenty-server' not allowed
```

**Cause**
The `twenty-server` service was accidentally indented inside the `redis` service.

**Solution**
Corrected the YAML indentation so that `db`, `redis`, `twenty-server`, and `app` are all separate services.

### 2. Twenty Server exited after migrations

**Problem**
The Twenty container initially performed database migrations and then exited instead of remaining available as the CRM server.

**Solution**
Configured the Twenty server to start the production server after the required initialization/migrations.

### 3. Incorrect file copied in Dockerfile

**Problem**
An initial Dockerfile referenced a file that did not exist in the project.

**Solution**
Inspected the actual project structure and changed the Dockerfile to copy only files that exist and are required.

### 4. Corepack/Yarn network error

**Error**
```
Error: getaddrinfo EAI_AGAIN repo.yarnpkg.com
```

**Cause**
The runtime container attempted to download Yarn again because the required Corepack cache was not available.

**Solution**
Copied the required Corepack cache from the builder stage into the runtime image and corrected ownership for the non-root user.

### 5. Missing tsconfig.spec.json

**Error**
```
tsconfig.json(38,5): File '/app/tsconfig.spec.json' not found.
```

**Cause**
`tsconfig.json` references `tsconfig.spec.json`, but the file had not been copied into the runtime image.

**Solution**
Added `tsconfig.spec.json` to the runtime image.

### 6. yarn twenty dev authentication requirement

**Problem**
The `yarn twenty dev` command requires an authenticated Twenty remote and can require interactive browser authorization. This makes it unsuitable as an unattended Docker container startup command.

**Solution**
Used `yarn twenty dev:build` for the containerized application build. This performs the application build without requiring the interactive authentication flow.

## Result

The Task 5 Docker implementation provides:

-  Dockerfile
-  Multi-stage build
-  Node.js + Yarn 4
-  .dockerignore
-  Docker Compose
-  PostgreSQL
-  Redis
-  Twenty CRM server
-  Application container
-  Environment variables
-  Docker networking
-  Persistent volumes
-  Health checks
-  Non-root execution
-  Successful application build
-  Twenty CRM accessible through localhost:3000

## Final Architecture

```
                    Browser
                       │
                       ▼
              localhost:3000
                       │
                       ▼
              ┌─────────────────┐
              │  Twenty Server  │
              └───────┬─────────┘
                      │
             ┌────────┴────────┐
             ▼                 ▼
       PostgreSQL            Redis
             │                 │
             └────────┬────────┘
                      │
                twenty-net
                      │
                      ▼
                 App Container
                 Dockerfile
                 Multi-stage
```



LOOM VIDEO:-
[https://www.loom.com/share/783efd6d499d45f8ac801d5b86a36335]