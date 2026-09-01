# TASK - 5: Docker Containerization

## Objective

Containerize the Twenty application development environment using Docker and Docker Compose.

## Files Created

### 1. Dockerfile

A multi-stage Dockerfile was created.

**Builder stage:**
- Uses `node:24-alpine`
- Enables Corepack
- Installs dependencies with `yarn install --immutable`
- Copies the application source
- Builds application resources using `yarn twenty dev:build`

**Runtime stage:**
- Uses a separate `node:24-alpine` image
- Creates a non-root user
- Copies required files from the builder stage
- Exposes port `2020`

### 2. .dockerignore

The Docker build context excludes unnecessary files including:

- `node_modules`
- `.yarn/cache`
- `.git`
- `.github`
- `.twenty`
- `dist`
- `coverage`
- Environment files
- Log files

### 3. docker-compose.yml

Docker Compose uses the official Twenty development image:

```text
twentycrm/twenty-app-dev:latest
```

The configuration includes:

- Port mapping: `2020:2020`
- Development environment variables
- Persistent Docker volumes
- Dedicated bridge networking

## Architecture

```text
Browser
   |
   | http://localhost:2020
   v
Twenty Docker Container
   |
   |-- Twenty Application Server
   |-- PostgreSQL
   |-- Redis
```

The official Twenty development image manages the required internal services.

## Commands Used

Validate configuration:

```bash
docker compose config
```

Start the environment:

```bash
docker compose up -d
```

Check service status:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs --tail=100 twenty-app
```

Stop the environment:

```bash
docker compose down
```

## Verification

The Docker Compose container started successfully and exposed the application on:

```text
http://localhost:2020
```

The container logs confirmed:

- Redis started successfully
- PostgreSQL was initialized
- PostgreSQL became ready
- Initial database setup completed
- Database extensions were created
- Initial migrations were executed

## Issue Encountered

### Custom application image could not independently provide the Twenty server

The repository contains a Twenty application project and the Twenty SDK, but it does not contain the complete Twenty CRM server source code.

The application build resources alone cannot replace the required Twenty server runtime.

### Solution

The final Docker Compose setup uses the official:

```text
twentycrm/twenty-app-dev:latest
```

image, which provides the Twenty development server and required internal services.

## Docker Best Practices Applied

- Multi-stage build
- Alpine-based images
- Dependency layer caching
- `.dockerignore`
- Non-root user in the custom runtime stage
- Persistent named volumes
- Dedicated bridge network

## Result

Task 5 successfully created and validated:

- `Dockerfile`
- `.dockerignore`
- `docker-compose.yml`

The Twenty development environment was successfully started with Docker Compose and verified through container status and startup logs.

## Conclusion

The Twenty application development environment can be started reproducibly using Docker Compose. The official Twenty development image provides the server runtime and required internal services, while the Dockerfile demonstrates container build best practices for the application project.
