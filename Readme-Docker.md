# Docker Compose Setup

This guide explains how to build and run the Twenty CRM app extension and its
local Twenty server with Docker Compose.

## Architecture

The Compose project contains two services:

- `twenty`: Runs the official Twenty app-development image. This image includes
  the Twenty server, worker, PostgreSQL, and Redis processes required for local
  app development.
- `app`: Builds this repository, authenticates with the Twenty server, and
  applies the application manifest. This is a one-time synchronization service,
  so it should exit with code `0` after a successful run.

Docker Compose also creates:

- A private bridge network named `twenty-crm-app_twenty_network`.
- A `twenty-crm-database` volume for PostgreSQL data.
- A `twenty-crm-storage` volume for locally stored files.
- A host port mapping from port `2020` to the Twenty server.

## Prerequisites

Install the following tools before starting:

- Docker with Docker Compose support.
- Colima or Docker Desktop on macOS.
- At least 4 GB of memory available to the Docker runtime.
- At least 4 CPU cores are recommended for the initial Twenty setup.

Check the installed versions:

```bash
docker --version
docker compose version
```

When using Colima, check its current resources:

```bash
colima status
docker info --format 'CPUs={{.NCPU}} Memory={{.MemTotal}}'
```

If Colima has less than 4 GB of memory, resize it before starting Twenty:

```bash
colima stop
colima start --cpu 4 --memory 4
```

Restarting Colima temporarily stops every container running in that Colima VM.
Check `docker ps` first if other projects are running.

## Environment configuration

Create the local environment file from the provided example:

```bash
cp .env.example .env
```

Open `.env` and replace the placeholder API key:

```dotenv
TWENTY_API_KEY=replace-with-your-local-twenty-api-key
```

The supported variables are:

| Variable | Purpose | Default |
| --- | --- | --- |
| `TWENTY_API_KEY` | Authenticates the app synchronization process | Required |
| `TWENTY_IMAGE` | Official Twenty development image | Pinned digest |
| `TWENTY_PORT` | Port exposed on the host | `2020` |
| `NODE_VERSION` | Node.js version used to build the app image | `24.5.0` |

The real `.env` file is ignored by both Git and the Docker build context. Never
commit real API keys or other secrets.

## Validate the configuration

Render and validate the resolved Compose configuration:

```bash
docker compose config
```

This detects invalid YAML, missing required variables, and interpolation errors
without starting containers.

## Build the application image

Build the multi-stage application image:

```bash
docker compose build
```

The build performs these checks inside the image:

1. Installs dependencies with `yarn install --immutable`.
2. Runs the linter.
3. Runs TypeScript type checking.
4. Runs unit tests.
5. Builds the Twenty app manifest and front component.

To force a completely clean build:

```bash
docker compose build --no-cache
```

## Start the application

Start the stack in the background:

```bash
docker compose up -d
```

Compose starts the `twenty` service first and waits for it to become healthy.
It then starts `app`, which authenticates with Twenty and synchronizes the
application manifest.

The initial startup may take several minutes while Twenty initializes its
database and default workspace.

## Verify the application

Check all containers, including completed one-time containers:

```bash
docker compose ps --all
```

The expected result is:

- `twenty`: `Up` and `healthy`.
- `app`: `Exited (0)` after synchronization completes.

An `Exited (0)` app container is successful and expected. It is not intended to
remain running after it applies the application manifest.

Review the app synchronization output:

```bash
docker compose logs --no-color app
```

A successful run ends with output similar to:

```text
Synced My app
```

Review Twenty server logs:

```bash
docker compose logs --no-color --tail=200 twenty
```

Verify the HTTP endpoint:

```bash
curl --fail http://localhost:2020
```

Open the application in a browser:

```text
http://localhost:2020
```

The default local-development credentials documented by the project are:

```text
Email:    tim@apple.dev
Password: tim@apple.dev
```

## Rebuild after source changes

Rebuild the app image and run synchronization again:

```bash
docker compose build app
docker compose up -d --force-recreate app
```

Confirm that the synchronization completed:

```bash
docker compose ps --all
docker compose logs --no-color app
```

## Stop and remove containers

Stop the services while preserving their containers, network, images, and data:

```bash
docker compose stop
```

Start the stopped services again:

```bash
docker compose start
```

Stop and remove Compose containers and the project network while preserving the
named data volumes:

```bash
docker compose down
```

Do not add `--volumes` unless all local Twenty database and storage data should
be permanently deleted.

## Docker best practices used

- A multi-stage Dockerfile separates dependency installation, validation,
  compilation, and runtime assembly.
- The Node.js version is pinned and uses the `bookworm-slim` image variant.
- The official Twenty image is pinned by digest for reproducible deployments.
- Dependency manifests are copied before source files to improve layer caching.
- Yarn uses an immutable lockfile installation.
- `.dockerignore` prevents dependencies, secrets, Git data, logs, and generated
  local output from entering the build context.
- The application runtime uses the non-root `node` user with UID `1000`.
- API credentials are provided at runtime and are not built into the image.
- The Twenty health check controls app startup ordering.
- Only the required Twenty HTTP port is published.
- Database and file-storage data use named persistent volumes.

## Issues encountered and resolutions

### Twenty image tag was not available

The original configuration used:

```text
twentycrm/twenty-app-dev:v2.35.1
```

Docker Hub did not contain that tag, because the Twenty SDK package version does
not map directly to an identically numbered development-image tag.

Resolution: the available official multi-platform Twenty image was selected and
pinned by digest through `TWENTY_IMAGE`. This avoids a mutable `latest` reference
while supporting both AMD64 and ARM64 hosts.

### Twenty remained unhealthy

Compose reported:

```text
dependency failed to start: container twenty-crm-app-twenty-1 is unhealthy
```

Docker inspection showed:

```text
OOMKilled=true
```

Colima had only approximately 2 GB of memory. The all-in-one Twenty development
image starts PostgreSQL, Redis, the API server, the worker, migrations, and
workspace initialization. The server was killed before it could listen on port
`2020`, so every health check failed.

Resolution: Colima was restarted with 4 CPUs and 4 GB of memory:

```bash
colima stop
colima start --cpu 4 --memory 4
```

After this change, the Twenty container became healthy.

### Non-root app container could not run Yarn

The first runtime command used `yarn twenty apply`. Corepack attempted to create
`/app/.yarn` after the container had switched to the non-root `node` user:

```text
EACCES: permission denied, mkdir '/app/.yarn'
```

Resolution: the runtime now invokes the already-installed Twenty CLI directly
with Node. This avoids a runtime package-manager download and preserves non-root
execution.

### App container could not reach Twenty

The Twenty CLI initially searched for a server on its default local address.
Inside the app container, `localhost` refers to that app container, not the
Twenty service.

Resolution: the startup command registers a non-interactive CLI remote using
the Compose URL `http://twenty:2020`, authenticates with `TWENTY_API_KEY`, and
applies the app using that remote. Docker DNS resolves `twenty` on the private
Compose network.

### Runtime typecheck could not find a referenced config

The synchronization build failed with:

```text
File '/app/tsconfig.spec.json' not found
```

The runtime image contained `tsconfig.json`, but that file references
`tsconfig.spec.json`.

Resolution: the referenced TypeScript configuration is now copied into the
runtime stage. The subsequent synchronization completed successfully.

## Useful troubleshooting commands

Show service status:

```bash
docker compose ps --all
```

Follow all logs:

```bash
docker compose logs --follow
```

Inspect the Twenty health-check result:

```bash
docker inspect --format '{{json .State.Health}}' twenty-crm-app-twenty-1
```

Check whether Docker killed the container because of memory pressure:

```bash
docker inspect --format 'OOMKilled={{.State.OOMKilled}}' twenty-crm-app-twenty-1
```

Check current Docker resource allocation:

```bash
docker info --format 'CPUs={{.NCPU}} Memory={{.MemTotal}}'
```

Check live resource usage:

```bash
docker stats
```

Validate repository changes before committing:

```bash
git diff --check
git status --short
```
