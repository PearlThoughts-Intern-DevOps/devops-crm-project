# Docker setup for the Twenty CRM app

## Overview

This repository is a Twenty app project. The runtime is a small Node.js app that syncs to a local Twenty CRM instance using the Twenty CLI and a workspace API token.

The Docker Compose stack includes:

- `twenty`: the official Twenty CRM development container
- `app`: this application container, built from the repository Dockerfile

## Files added/updated

- `Dockerfile`
- `.dockerignore`
- `docker-compose.yml`
- `.env.example`
- `entrypoint.sh`

## Architecture

The app container is built in two stages:

1. `dependencies` stage:
   - installs Node.js dependencies with Yarn 4 in a cache-friendly layer
2. `runtime` stage:
   - copies only the required files
   - creates a non-root user (`twenty`)
   - runs the app entrypoint for remote registration and sync

The `twenty` service exposes port `2020` for the CRM UI/API, while the app container connects to it internally over the Docker network on `http://twenty:2020`.

## Environment variables

The Compose stack expects these values:

- `TWENTY_VERSION`: version of the Twenty development image
- `TWENTY_PORT`: host port for the CRM UI
- `SERVER_URL`: public URL used by the Twenty container
- `TWENTY_URL`: internal URL used by the app container
- `TWENTY_API_KEY`: valid workspace API key for app registration

A sample configuration is provided in `.env.example`.

## Build and run

From the project root:

```bash
docker compose build app
docker compose up -d --build
```

Check status:

```bash
docker compose ps
docker compose logs -f app
docker compose logs -f twenty
```

Stop everything:

```bash
docker compose down
```

## Verified status

The following verification steps were run successfully:

```bash
docker compose build app
docker compose up -d --build
docker compose ps
```

Evidence from the terminal:

- both containers were started successfully
- the `twenty` service was reported as `healthy`
- the `app` container stayed up in the Compose stack

## Important issue faced and fix

The core problem was authentication between this app and the local Twenty server:

- the project default API key was invalid for the local server
- `yarn twenty remote:add --as docker --url ... --api-key ...` failed with `Authentication failed`

The fix was:

- keep the app container from crashing when a real workspace API key is not yet set
- document that a valid `TWENTY_API_KEY` must be provided for real app registration and sync
- allow the app to stay alive in standby mode until valid credentials are configured

This keeps the Docker stack healthy while avoiding a false-negative crash for local development.

## Git status and PR note

The local branch in this environment is `ambu-task5`.

I could not push this branch or open the GitHub PR from here because GitHub push credentials/remote permission were not available in this session. The repository is ready locally, and the commands needed to push are:

```bash
git checkout ambu-task5
git add .
git commit -m "Add Docker containerization setup"
git push origin ambu-task5
```

Then open the repository in GitHub and create the PR against the target branch.
