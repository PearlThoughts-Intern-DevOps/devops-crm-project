# Task 5 - Docker Containerization

## Objective

Containerize the Twenty CRM application package using Docker and provide a Docker Compose setup for local execution.

## Project Structure

The project is a Twenty application built using:

- Node.js 24
- Yarn 4
- TypeScript
- React
- Twenty SDK
- Twenty Client SDK
- Twenty UI

The application source is located under `src/`.

The Twenty CLI is used to build the application package.

## Dockerfile

The Dockerfile uses a multi-stage build.

### Build Stage

- Uses `node:24-alpine`
- Enables Corepack
- Installs dependencies using Yarn
- Copies the application source
- Runs `yarn twenty dev:build`

### Runtime Stage

- Uses `node:24-alpine`
- Copies only the generated Twenty application package
- Runs as the non-root `node` user
- Keeps the generated application package available inside the container

This reduces the runtime image size and avoids running the container as root.

## Docker Ignore

The `.dockerignore` excludes:

- node_modules
- .git
- .github
- .twenty
- dist
- coverage
- build
- logs
- environment files
- OS-specific files

This keeps unnecessary files out of the Docker build context.

## Docker Compose

Docker Compose defines the application service with:

- Image: `my-twenty-app:task-5`
- Container: `my-twenty-app-compose`
- Port: `2025:2020`
- `NODE_ENV=production`
- `TWENTY_API_URL=http://host.docker.internal:2020`
- Restart policy: `unless-stopped`

Docker Compose also creates a project network automatically.

## Commands Used

### Build Docker image

```bash
docker build -t my-twenty-app:task-5 .
```

### Run Docker container directly

```bash
docker run -d --name my-twenty-app -p 2025:2020 my-twenty-app:task-5
```

### Validate Docker Compose configuration

```bash
docker compose config
```

### Build with Docker Compose

```bash
docker compose build
```

### Start the application container

```bash
docker compose up -d
```

### Check running containers

```bash
docker compose ps
```

### View logs

```bash
docker compose logs
```

### Stop the Compose application

```bash
docker compose down
```

### Twenty Application Build

The Twenty application package was successfully built using:

```bash
yarn twenty dev:build
```

The generated output contains:

```text
manifest.json
package.json
README.md
public/logo.svg
src/front-components/main-page.mjs
application source map
yarn.lock
```

A tarball was also successfully generated using:

```bash
yarn twenty dev:build --tarball
```

### Private Application Deployment

The application was successfully published to the local Twenty server registry using:

```bash
yarn twenty app:publish --private
```

The command reported:

```text
Published my-app v0.1.0 to localhost
```

The application was then visible in the local Twenty CRM interface.

## Issues Faced and Solutions

### 1. Docker was initially unavailable inside WSL

The Docker CLI initially reported that Docker was not available in the WSL distribution.

Solution:

Started Docker Desktop
Enabled WSL 2 integration
Verified Docker using:

```bash
docker --version
docker ps
```

### 2. Docker Compose YAML parsing error

The initial docker-compose.yml had invalid YAML formatting and produced:

```text
mapping values are not allowed in this context
```

Solution:

The Compose file was recreated with valid YAML indentation and then verified using:

```bash
docker compose config
```

### 3. Twenty Docker image version

The existing Twenty development container was initially using:

```text
twentycrm/twenty-app-dev:latest
```

The compatible version was pulled and verified using:

```bash
yarn twenty docker:start 2.35.0
```

### 4. Generated build output

The .twenty directory is ignored by Git because it contains generated build artifacts.

The Docker build generates the output inside the build stage and copies it into the runtime image.

## Verification

Docker image:

```text
my-twenty-app:task-5
```

Docker Compose container:

```text
my-twenty-app-compose
```

Port mapping:

```text
2025 -> 2020
```

The Compose container successfully starts and remains running.

The Twenty application was also successfully built, published to the local Twenty registry, installed, and displayed as My app in the local Twenty CRM interface.

## Architecture

```text
Developer
   |
   v
Git Repository
   |
   v
Dockerfile
   |
   +--> Build Stage
   |      |
   |      +--> Yarn install
   |      +--> Twenty build
   |
   v
Runtime Image
   |
   v
Docker Compose
   |
   v
my-twenty-app-compose
   |
   +--> /app/app
   |
   +--> Port 2025:2020

Local Twenty Server
   |
   +--> localhost:2020
   |
   +--> My app
```

## Conclusion

The Twenty application package was successfully containerized using a multi-stage Docker build. Docker Compose was configured for reproducible local execution, with environment variables, port mapping, automatic restart, and a dedicated Compose network. The build and runtime containers were verified successfully.
