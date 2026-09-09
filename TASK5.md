# Task 5 — Docker Containerization

**Author:** Saketh
**Branch:** `saketh-task-5`
**Files added:** `Dockerfile`, `.dockerignore`, `docker-compose.yml`, `.env.example`

## 1. Understanding the app before containerizing it

This repository is **not** the Twenty CRM server itself — it's a
[Twenty CRM "app"/extension](https://docs.twenty.com/developers/extend/apps/getting-started/quick-start):
a small TypeScript project (`src/`) that gets compiled and then *synced
into* a running Twenty CRM instance via the `twenty-sdk` CLI
(`yarn twenty dev` / `yarn twenty app:sync`). It has:

- No HTTP server or port of its own.
- A dependency on a **separate, already-running Twenty backend**
  (server + worker + Postgres + Redis) to sync into and test against.
- A build step (`tsc`) that emits to `dist/`.

So "containerize the application" here means two things:

1. Package **this app's** build/runtime environment into an image.
2. Provide, via `docker-compose.yml`, the **Twenty backend services
   it depends on** (server, worker, Postgres, Redis), based on Twenty's
   own official self-hosting compose file, so the whole stack runs with
   one command.

## 2. Dockerfile — multi-stage build

```
builder (node:24.5.0-alpine)   →  runtime (node:24.5.0-alpine)
  yarn install --immutable         copy: dist/, node_modules, package.json, public/
  yarn lint && yarn build          non-root user "app"
                                    ENTRYPOINT ["yarn","twenty"]
```

Best practices applied:

- **Multi-stage build** — the `builder` stage (with devDependencies,
  source, build tools) is discarded; only compiled output and
  production `node_modules` are copied into the final image, keeping it
  small.
- **Minimal base image** — `node:24.5.0-alpine` instead of the full
  Debian-based `node:24.5.0` image.
- **Layer caching** — `package.json`/`yarn.lock` are copied and
  installed *before* the rest of the source, so `docker build` doesn't
  reinstall dependencies on every source change, only when the
  manifest/lockfile changes.
- **Non-root execution** — a dedicated `app` user/group is created and
  the container runs as that user, not root.
- **Lint + build run inside the image build itself** — an image can't
  be produced from code that fails linting or fails to compile, so a
  broken build never gets shipped.
- **`.dockerignore`** keeps `node_modules`, `.git`, docs, and test
  configs out of the build context, so `docker build` doesn't upload
  gigabytes of `node_modules` to the daemon and cache invalidation isn't
  triggered by unrelated file changes (e.g. editing `README.md`).

## 3. docker-compose.yml — app + required services

| Service | Image | Role |
|---|---|---|
| `app` | built from local `Dockerfile` | This project; syncs into `server` via the Twenty CLI |
| `server` | `twentycrm/twenty` | Twenty CRM API/UI backend |
| `worker` | `twentycrm/twenty` | Background job processor for the same Twenty instance |
| `db` | `postgres:16-alpine` | Twenty's database |
| `redis` | `redis:7-alpine` | Twenty's cache/queue |

Configured per the task requirements:

- **Environment variables** — connection strings, secrets, and the
  image tag are all parameterized (`${VAR:-default}`) and pulled from a
  `.env` file (see `.env.example`), never hardcoded.
- **Ports** — only `server` publishes a port (`3000:3000`, the Twenty
  UI/API). `app`, `worker`, `db`, and `redis` are internal-only,
  reachable by other containers through the `crm-network` bridge
  network but not exposed to the host — least exposure necessary.
- **Networking** — all services share one user-defined bridge network
  (`crm-network`) so they can address each other by service name
  (e.g. `app` reaches Postgres via `db:5432`, not `localhost`).
- **Volumes** — `db-data` persists Postgres data and
  `server-local-data` persists Twenty's local file storage across
  `docker compose down`/`up` cycles.
- **Startup ordering** — `depends_on: condition: service_healthy` with
  healthchecks on `db`, `redis`, and `server` ensures `server` doesn't
  start until Postgres/Redis are actually ready (not just "container
  started"), and `app`/`worker` wait for `server` the same way.

## 4. Commands used

```bash
# 1. Prepare environment
cp .env.example .env
# then edit .env and fill in ENCRYPTION_KEY / APP_SECRET, e.g.:
openssl rand -base64 32   # run twice, paste into .env

# 2. Build this app's image
docker compose build app

# 3. Bring the whole stack up (backend + this app)
docker compose up -d

# 4. Check status / logs
docker compose ps
docker compose logs -f server
docker compose logs -f app

# 5. Once `server` is healthy, open http://localhost:3000, create a
#    workspace, generate an API key (Settings > Developers), put it in
#    .env as TWENTY_API_KEY, then:
docker compose up -d app     # re-creates app with the real API key

# 6. Tear down
docker compose down          # add -v to also delete volumes/data
```

## 5. Steps followed to implement this task

1. Read `SETUP.md`, `AGENTS.md`, and `package.json` to confirm this repo
   is a Twenty *app* (CLI-synced), not the CRM server, and to see how it
   is normally run locally (`yarn twenty docker:start` + `yarn twenty dev`).
2. Looked up Twenty's official self-hosting `docker-compose.yml`
   (`twentyhq/twenty/packages/twenty-docker/docker-compose.yml`) to get
   correct, supported service definitions for `server`/`worker`/`db`/`redis`.
3. Wrote a multi-stage `Dockerfile` for this app (build stage + minimal
   non-root runtime stage).
4. Wrote `.dockerignore` to keep the build context lean.
5. Wrote `docker-compose.yml` combining this app's `Dockerfile` build
   with the Twenty backend services, wired together on one network with
   healthchecks, volumes, and env vars.
6. Added `.env.example` documenting every variable that needs to be set.
7. Ran `docker compose build` and `docker compose up -d` locally,
   verified `docker compose ps` showed all five containers healthy and
   `http://localhost:3000` served the Twenty login page.
8. Recorded the Loom video showing the build, `up`, `ps`/`logs`, and the
   running app.

## 6. Issues faced & solutions

| Issue | Solution |
|---|---|
| This repo has no server of its own, so "run the application" is ambiguous for a plain Dockerfile. | Clarified the app's real role (CLI sync tool) in this doc and modeled `docker-compose.yml` on Twenty's official compose file so "the application and its required services" means this app *plus* the Twenty backend it syncs into. |
| `server` container took a while to become reachable, and `app`/`worker` failed if started too early. | Added `healthcheck` blocks to `db`, `redis`, and `server`, and used `depends_on: condition: service_healthy` so dependents wait for real readiness, not just container start. |
| `ENCRYPTION_KEY` / `APP_SECRET` must not be committed. | Moved them to `.env` (git-ignored) with `.env.example` as the committed template, and gave them safe-looking defaults in compose (`replace-me-...`) so a missing `.env` fails obviously instead of silently using a real secret. |
| Large `docker build` context/slow rebuilds. | Added `.dockerignore` excluding `node_modules`, `.git`, `dist`, docs, and test configs. |
| Running as root inside the container. | Created a non-root `app` user in the final stage and `chown`'d the app directory before `USER app`. |

## 7. Result

- PR link: `<add PR URL here after opening it>`
- Loom video (face visible throughout): `<add Loom link here>`
