# Task 5: Docker Containerization

## Objective

Containerize the `devops-crm-project` app (a custom Twenty CRM extension
built on `twenty-sdk`) with a Dockerfile, `.dockerignore`, and a
`docker-compose.yml` that runs both the app and the Twenty CRM server it
depends on.

## Architecture

This app is **not a standalone web server** — it's a CLI-driven process
(`yarn twenty dev`) that typechecks, builds a manifest, and syncs itself
into a separately-running Twenty CRM server. Containerizing it therefore
means two cooperating services, not one:

- **`twenty`** — the Twenty CRM server itself, using the vendor-provided
  `twentycrm/twenty-app-dev` all-in-one dev image (bundles the server,
  Postgres, and Redis). Exposes port 2020.
- **`app`** — this repository, built from our `Dockerfile`, running
  `yarn twenty dev` to sync into the `twenty` service.

## Dockerfile design

- **Multi-stage build**: a `deps` stage resolves/installs dependencies in
  isolation (cached independently of source changes), and a `runtime`
  stage copies only `node_modules` + source into a fresh image. There's
  no compiled build artifact for this project type, so the split exists
  to keep dependency-layer caching effective and to avoid carrying any
  install-time-only tooling into the final image.
- **Non-root execution**: a dedicated `appuser`/`appgroup` runs the
  container.
- **Base image**: `node:24-slim`, matching this project's `^24.5.0`
  engines requirement (the exact `24.5.0-slim` tag isn't published on
  Docker Hub, so we float to the latest 24.x patch instead).

## docker-compose.yml design

- Two services (`twenty`, `app`) on a shared setup, with `app` using
  `network_mode: "service:twenty"` (see "Issues faced" below for why).
- Named volumes: `twenty-server-data` for the CRM server's persistent
  data, and `twenty-cli-config` mounted at `/app/.twenty` (the app
  container's `HOME`) so the CLI's authenticated remote config survives
  container restarts/rebuilds.

## Issues faced and how they were resolved

- **The `twenty` CLI defaults to checking `http://localhost:2020`, not a
  custom env var.** An initial `TWENTY_SERVER_URL` environment variable
  was set on the `app` service, but the CLI ignored it entirely and
  reported "Cannot reach Twenty server." Since `localhost` inside a
  container refers to that container itself, not a sibling container on
  the same Compose network, `app` could never reach `twenty` this way.
  Fixed by setting `network_mode: "service:twenty"` on `app`, so it
  shares `twenty`'s exact network namespace and `localhost:2020`
  genuinely resolves to the CRM server, matching the CLI's hardcoded
  expectation.
- **Severe disk I/O degradation caused a corrupted database.** A Postgres
  checkpoint that should take milliseconds took 178+ seconds, and the
  migration sequence subsequently failed with `relation "core.keyValuePair"
  does not exist` and later `column ... does not exist` — classic signs
  of a migration transaction timing out mid-way and leaving a
  half-finished schema. Root cause: the Windows host's C: drive was
  critically low on free space (under 8GB of 110GB), which severely
  degrades NTFS/WSL2 disk performance. Resolved by relocating Docker
  Desktop's entire disk image location to a drive with ample free space,
  then wiping the corrupted volume (`docker compose down -v`) and
  rebuilding from a clean state — migration times dropped from minutes
  to seconds afterward.
- **The `twenty` CLI's browser-based OAuth login times out inside a
  container** (120-second window, no display to interact with easily
  mid-flow). Initially assumed there was no non-interactive alternative,
  but `yarn twenty remote:add` actually falls back to an **API Key**
  prompt after the OAuth attempt times out. Generated a key from Twenty's
  UI (Settings → MCP & APIs) and supplied it at that prompt — this
  authenticates the CLI without ever needing a working browser redirect
  inside the container, and persists via the mounted `/app/.twenty`
  volume so it only needs to happen once.
- **`docker compose restart app` hung indefinitely** on a container using
  `network_mode: "service:twenty"`. Worked around with a manual
  stop → remove → recreate cycle (`docker compose stop app && docker
  compose rm -f app && docker compose up -d app`) instead of relying on
  `restart`.
- **The app's sync intermittently failed with a second, transient
  "Authentication failed" error** even after the API key was accepted
  and the manifest build succeeded. This mirrors the same kind of
  Twenty-sync flakiness already observed and documented in the CI
  pipeline work (Task 4) — resolved simply by retrying; a clean run
  completed the full Application Initialization → Resources Build →
  Resources Upload → Manifest Build → Application Synchronization → Api
  Client Generation sequence successfully afterward.
- **The `app` container doesn't survive a host reboot** — only `twenty`
  has a `restart: unless-stopped` policy; `app` does not, since it needs
  `twenty` healthy first and blindly auto-restarting it on boot could
  race the server's own startup. After a reboot, `docker compose up -d`
  needs to be re-run manually to bring `app` back.

## How to build and run

```bash
docker compose build
docker compose up -d
docker compose ps                     # confirm both services are running
docker compose exec app yarn twenty remote:add   # one-time auth (see note below)
docker compose logs -f app            # watch the sync complete
```

When prompted for the server URL, use `http://localhost:2020`. If the
browser-based login times out, paste an API key generated from Twenty's
UI (Settings → MCP & APIs) at the follow-up prompt instead.

## What I learned

- Not every "containerize this app" task maps to a single web-serving
  container — some apps are sync/CLI-driven tools whose "runtime" is a
  process that talks to another service, and the Compose design needs to
  reflect that honestly rather than forcing a conventional web-app shape.
- Why `network_mode: "service:twenty"` is the correct fix when a tool
  hardcodes `localhost` for a dependency it expects to share a host with.
- How severely a nearly-full host disk can degrade containerized
  database performance, to the point of corrupting an in-progress
  migration — and that fixing the disk-space problem is a prerequisite
  to trusting anything built on top of it.
- That a CLI's interactive-only-looking auth flow can still have a
  documented non-interactive fallback (API key) worth checking for
  before assuming a limitation.