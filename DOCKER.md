# Docker Setup – Twenty CRM App

## Overview

This document describes the Docker containerisation of the **Twenty CRM App** —
a plugin/extension built on the [Twenty SDK](https://docs.twenty.com/developers/extend/apps/getting-started/quick-start)
that extends the [Twenty CRM](https://twenty.com) platform.

The stack consists of two services:

| Service | Image | Purpose |
|---|---|---|
| `twenty-server` | `twentycrm/twenty-app-dev:latest` | All-in-one Twenty CRM server (Postgres + Redis + API + Frontend) |
| `twenty-app` | Built from `Dockerfile` in this repo | The app package: lint → typecheck → test → sync/publish |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Docker Network: twenty-net              │
│                                                              │
│  ┌──────────────────────────┐   ┌────────────────────────┐  │
│  │      twenty-server        │   │      twenty-app         │  │
│  │  twentycrm/twenty-app-dev │   │  Built from Dockerfile  │  │
│  │                           │   │                         │  │
│  │  ┌─────────────────────┐  │   │  Stage 1: base          │  │
│  │  │ PostgreSQL :5432    │  │   │  Node 24 + Yarn 4       │  │
│  │  │ Redis      :6379    │  │   │                         │  │
│  │  │ NestJS API :2020    │  ◄───│  Stage 2: deps          │  │
│  │  │ React SPA  :2020    │  │   │  yarn install --immutable│  │
│  │  └─────────────────────┘  │   │                         │  │
│  │                           │   │  Stage 3: builder        │  │
│  │  Volumes:                 │   │  lint + typecheck + test │  │
│  │  twenty-data  (Postgres)  │   │                         │  │
│  │  twenty-storage (files)   │   │  Stage 4: release        │  │
│  └──────────────────────────┘   │  Non-root user (appuser) │  │
│                                  │  yarn twenty dev         │  │
│         HOST port: 2020          └────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Files

| File | Purpose |
|---|---|
| `Dockerfile` | Multi-stage build for the app package |
| `.dockerignore` | Excludes unnecessary files from the build context |
| `docker-compose.yml` | Orchestrates the full dev stack |
| `.env.example` | Template for environment variables |

---

## Quick Start

### Prerequisites

- [Docker Engine](https://docs.docker.com/engine/install/) ≥ 24
- [Docker Compose](https://docs.docker.com/compose/install/) ≥ 2.20

### 1. Clone and configure

```bash
git clone <this-repo>
cd <this-repo>
cp .env.example .env
# Edit .env if you need non-default ports or secrets
```

### 2. Start the full stack

```bash
docker compose up -d
```

This will:
1. Pull `twentycrm/twenty-app-dev:latest` (≈1.8 GB, first time only)
2. Build the app image using the multi-stage `Dockerfile`
3. Start the Twenty server and wait for its health check to pass
4. Start the app container which syncs with the server

### 3. Open the Twenty UI

```
http://localhost:2020
```

Default dev credentials: `tim@apple.dev` / `tim@apple.dev`

---

## Useful Commands

```bash
# View logs for all services
docker compose logs -f

# View logs for the app only
docker compose logs -f twenty-app

# View logs for the server only
docker compose logs -f twenty-server

# Stop the stack (data is preserved)
docker compose down

# Stop and wipe all volumes (fresh start)
docker compose down -v

# Rebuild the app image after code changes
docker compose build twenty-app
docker compose up -d twenty-app

# Open a shell in the running app container
docker compose exec twenty-app sh

# Check service health
docker compose ps
```

---

## Dockerfile – Multi-Stage Build Explained

The `Dockerfile` uses four stages for efficiency and security:

### Stage 1 – `base`
- `node:24-alpine` (≈65 MB) – minimal image
- Enables **Corepack** and pins **Yarn 4.13.0**

### Stage 2 – `deps`
- Copies only `package.json`, `yarn.lock`, `.yarnrc.yml`
- Runs `yarn install --immutable`
- **Layer caching**: this expensive step is only re-run when dependency files change

### Stage 3 – `builder`
- Copies source code on top of the installed dependencies
- Runs the full quality gate:
  - `yarn lint` — oxlint checks
  - `yarn typecheck` — TypeScript strict mode
  - `yarn test:unit` — Vitest unit tests

### Stage 4 – `release`
- Minimal final image (no build tools)
- Creates a **non-root user** (`appuser:appgroup`, UID/GID 1001) — principle of least privilege
- Runs `yarn twenty dev` by default

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `TWENTY_VERSION` | `latest` | Twenty server image tag |
| `SERVER_PORT` | `2020` | Host port mapped to the server |
| `SERVER_URL` | `http://localhost:2020` | Public URL of the server |
| `APP_SECRET` | `twenty-app-dev-secret…` | JWT signing secret (**change in production!**) |
| `NODE_ENV` | `development` | Node.js environment |
| `TWENTY_API_URL` | `http://twenty-server:2020` | Server URL seen from inside Docker |
| `TWENTY_API_KEY` | _(empty)_ | API key for the app (set after first login) |
| `APP_VERSION` | `local` | Tag for the built app image |

---

## Volumes

| Volume | Mount point | Purpose |
|---|---|---|
| `twenty-data` | `/data/postgres` | Embedded PostgreSQL data |
| `twenty-storage` | `/app/packages/twenty-server/.local-storage` | Uploaded files |

Data persists across `docker compose down`. Use `docker compose down -v` to wipe.

---

## Networking

All services communicate over an isolated **bridge network** (`twenty-net`).
The Twenty server is reachable from the app container at `http://twenty-server:2020`.
Only port `2020` is exposed to the host.

---

## Docker Best Practices Applied

| Practice | Implementation |
|---|---|
| **Multi-stage build** | 4 stages: base → deps → builder → release |
| **Minimal base image** | `node:24-alpine` (Alpine Linux, ≈65 MB) |
| **Layer caching** | Dependencies installed before copying source |
| **Non-root execution** | `appuser` (UID 1001) owns `/app` |
| **`.dockerignore`** | Excludes `node_modules`, `dist`, `.git`, `.env*` |
| **Health checks** | Server health check gates the app container start |
| **Named volumes** | Data persists independently of container lifecycle |
| **Isolated network** | Custom bridge network |
| **Pinned tool versions** | Yarn 4.13.0 pinned via `packageManager` field |
| **Environment separation** | Config via env vars / `.env` file |

---

## Issues Faced & Solutions

### Issue 1: `node:24.5.0-alpine3.20` not available on Docker Hub

**Problem:** The exact Node version from `.nvmrc` (`24.5.0`) has no Alpine variant
on Docker Hub.

**Solution:** Used `node:24-alpine` and pinned Yarn 4.13.0 explicitly via
`corepack prepare`. Reproducibility is maintained because Yarn version (the main
package manager) is pinned exactly.

---

### Issue 2: The app is not a standalone HTTP server

**Problem:** This project is a **Twenty SDK plugin**, not an HTTP service. It runs
`yarn twenty dev` to sync to a live Twenty CRM server — it cannot run in isolation.

**Solution:** `docker-compose.yml` orchestrates both the official Twenty server
(with PostgreSQL, Redis, API and frontend bundled) and the app container. This
mirrors the official local development workflow from
[SETUP.md](./SETUP.md) exactly.

---

### Issue 3: Integration tests require a live server

**Problem:** `yarn test` needs `TWENTY_API_URL` and `TWENTY_API_KEY` pointing to
a running server.

**Solution:** Only `yarn test:unit` is run in the Docker builder stage. Integration
tests run after the full stack is up:

```bash
docker compose exec twenty-app yarn test
```

---

## Loom Video

> 📹 **[Add your Loom link here after recording]**
>
> The video should demonstrate:
> - Project structure and architecture overview
> - Walkthrough of `Dockerfile`, `.dockerignore`, and `docker-compose.yml`
> - Running `docker compose up -d` and watching the build
> - Logging into the Twenty UI and verifying the app syncs
> - Explaining Docker best practices applied

---

## References

- [Twenty Apps Documentation](https://docs.twenty.com/developers/extend/apps/getting-started/quick-start)
- [Twenty Local Server](https://docs.twenty.com/developers/extend/apps/getting-started/local-server)
- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Docker Compose Health Checks](https://docs.docker.com/compose/how-tos/startup-order/)