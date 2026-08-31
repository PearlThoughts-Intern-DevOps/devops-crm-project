# Task 05 — Docker Containerization
**PearlThoughts DevOps Internship**

---

## Overview

Three files created to containerize the Twenty CRM application:

| File | Purpose |
|---|---|
| `Dockerfile` | Multi-stage build to containerize the app |
| `.dockerignore` | Excludes unnecessary files from build context |
| `docker-compose.yml` | Runs the app with all required services |

---

## Application Architecture
┌─────────────────────────────────────┐
│ twenty-network (bridge) │
│ │
│ ┌──────────┐ ┌───────────────┐ │
│ │ twenty │ │ twenty │ │
│ │ -db │ │ -redis │ │
│ │ postgres │ │ redis:7 │ │
│ │ port:5432│ │ port:6379 │ │
│ └────┬─────┘ └──────┬────────┘ │
│ │ │ │
│ ┌────▼─────────────────▼────────┐ │
│ │ twenty-server │ │
│ │ twentycrm/twenty:latest │ │
│ │ port: 3000 (exposed) │ │
│ └────────────────┬──────────────┘ │
│ │ │
│ ┌────────────────▼──────────────┐ │
│ │ twenty-worker │ │
│ │ twentycrm/twenty:latest │ │
│ │ background jobs (BullMQ) │ │
│ └───────────────────────────────┘ │
└─────────────────────────────────────┘


---

## Dockerfile — Multi-Stage Build

### Why multi-stage?
Multi-stage builds keep the final image small. Each stage has a specific purpose:

| Stage | Base | Purpose |
|---|---|---|
| `base` | node:22-alpine | Common foundation — installs curl, openssl, creates non-root user |
| `deps` | base | Installs all yarn dependencies |
| `builder` | deps | Copies source code, runs typecheck |
| `runner` | base | Final production image — only copies what's needed |

### Key decisions
- **Alpine images** — `node:22-alpine` is 58MB vs `node:22` which is 900MB+
- **Non-root user** — runs as `twenty` user, not root (security best practice)
- **Healthcheck** — container reports unhealthy if app crashes
- **`--mode=skip-build`** — prevents yarn lifecycle scripts (SonarCloud S6505 fix)

---

## docker-compose.yml — Services

### db (PostgreSQL 16)
- Alpine variant for smaller image
- Health check using `pg_isready`
- Data persisted in named volume `db-data`
- Memory limited to 512MB

### redis (Redis 7)
- `noeviction` policy — background jobs never silently dropped
- Memory limited to 256MB
- Health check using `redis-cli ping`

### server (Twenty CRM)
- Uses official `twentycrm/twenty:latest` image
- Depends on db and redis being healthy before starting
- Exposes port 3000 to host
- 90 second start period for healthcheck (migrations take time)
- Memory limited to 1GB

### worker (Twenty background jobs)
- Same image as server
- Runs `yarn worker:prod` command
- Depends on server being healthy
- Migrations and crons disabled (server owns those)
- Memory limited to 512MB

---

## Commands Used

### Build Docker image
```bash
docker build -t myapp .
```

### Start all services
```bash
docker compose up -d
```

### Check status
```bash
docker compose ps
```

### View logs
```bash
docker compose logs -f
docker compose logs -f server
```

### Health check
```bash
curl http://localhost:3000/healthz
```

### Stop services
```bash
docker compose down
```

### Stop and delete all data
```bash
docker compose down -v
```

---

## Environment Variables

| Variable | Required | Default | Purpose |
|---|---|---|---|
| `PG_DATABASE_PASSWORD` | Yes | — | PostgreSQL password |
| `ENCRYPTION_KEY` | Yes | — | Twenty encryption key (32 chars) |
| `PG_DATABASE_USER` | No | postgres | PostgreSQL user |
| `PG_DATABASE_NAME` | No | default | PostgreSQL database name |
| `SERVER_URL` | No | http://localhost:3000 | Public URL of the server |
| `HOST_PORT` | No | 3000 | Port exposed to host |
| `REDIS_URL` | No | redis://redis:6379 | Redis connection URL |
| `STORAGE_TYPE` | No | local | Storage backend (local or s3) |

---

## Issues Faced & Solutions

### Issue 1 — No `build` script in package.json
**Problem:** Dockerfile ran `yarn build` but this project has no build script.
**Solution:** Replaced with `yarn typecheck` which acts as build validation.

### Issue 2 — `$$` typo in RUN command
**Problem:** `mkdir -p /app/.local-storage $$ chown` — `$$` means process ID in shell.
**Solution:** Changed to `&&` which means "run next command if previous succeeded".

### Issue 3 — `yarn workspaces focus` not available
**Problem:** Command failed — this project is not a monorepo workspace.
**Solution:** Removed the command entirely.

### Issue 4 — `/var/cache/apl/*` typo
**Problem:** `apl` should be `apk` (Alpine Package Keeper).
**Solution:** Fixed to `/var/cache/apk/*`.

### Issue 5 — `PG_DATABASE_PASSWORD` missing
**Problem:** `docker compose up` failed — required variable not set.
**Solution:** Added all required variables to `.env` file.

### Issue 6 — `docker compose up -d` flag not recognized
**Problem:** Old Docker version didn't support `docker compose` (v2 syntax).
**Solution:** Installed `docker-compose-v2` via apt.

---

## Docker Best Practices Applied

| Practice | How applied |
|---|---|
| Multi-stage builds | 4 stages — base, deps, builder, runner |
| Minimal base image | `node:22-alpine` (58MB vs 900MB+) |
| Non-root execution | Created `twenty` user, switched with `USER twenty` |
| Health checks | All 4 services have health checks |
| Resource limits | Memory limits on all services |
| Dependency ordering | `depends_on` with `condition: service_healthy` |
| Secrets not in image | All secrets via `.env` file, never baked in |
| Named volumes | Data persists across container restarts |
| Private network | All containers on `twenty-network`, only server exposed |
