# Task 5 — Docker Containerization (devops-crm-project)

## 1. What I actually found when I looked into this repo

My first attempt at this task assumed `devops-crm-project` was the full Twenty
CRM source code (a NestJS server + React frontend, like the real
`twentyhq/twenty` repo on GitHub). That was wrong, and my first Dockerfile
failed on `docker compose build` because there was no `packages/` folder to
build from.

What this repo actually is: a **Twenty App**, built with `twenty-sdk`. Looking
at `package.json`, `SETUP.md`, and the `twenty --help` output, it's a small
dev-tooling project:

- `src/front-components/` etc. — my custom UI code, not a server.
- `twenty-sdk` (in devDependencies) — a CLI that builds this code and
  **syncs** it into a separately-running Twenty CRM instance.
- `yarn twenty docker:start` — starts the actual CRM. I checked with
  `docker ps -a` and confirmed it just runs **one** prebuilt image,
  `twentycrm/twenty-app-dev:latest`, on port 2020 — not a docker-compose
  stack, just a single container that already bundles the whole CRM.
- `yarn twenty dev` — builds my `src/` code and pushes it into that running
  container over the network (this is the "sync" step).

So there's no server source code of mine to containerize from scratch — the
CRM itself is Twenty's own prebuilt image. What I actually needed to
containerize was **the sync/dev workflow**, and use Compose to run it
alongside the CRM container instead of running both by hand.

## 2. Architecture

```
┌───────────────────┐        ┌──────────────────────┐
│   app-dev          │  syncs │   twenty-crm          │
│  (my Dockerfile:    │───────▶  (twentycrm/twenty-   │
│   yarn twenty dev)  │        │   app-dev image)      │
└───────────────────┘        └──────────┬────────────┘
                                          │ port 2020
                                          ▼
                                     http://localhost:2020
```

- `twenty-crm` — runs Twenty's own official `twentycrm/twenty-app-dev` image
  (the same one `docker:start` uses). I'm not rebuilding this — it's already
  a complete, prebuilt CRM.
- `app-dev` — my own image, built from my Dockerfile. Installs Node/Yarn
  dependencies, copies my app code, and runs the `twenty` CLI to build and
  continuously sync my code into `twenty-crm`.

Both containers sit on one Docker network (`twenty-network`) so `app-dev` can
reach the CRM by its service name (`http://twenty-crm:2020`) instead of
`localhost`.

## 3. Dockerfile (for app-dev)

- Base image: `node:24-alpine` (matches the `engines.node` in `package.json`).
- Installs Yarn 4.13.0 via Corepack (matches `packageManager` in
  `package.json`).
- Copies `package.json`/`yarn.lock` before the rest of the source, so the
  dependency install is cached across code changes.
- Runs as a non-root user (`twenty`), not root.
- Uses an `entrypoint.sh` script (see below) instead of a single `CMD`,
  because the container needs to do two things in order: register itself
  with the CRM, then run the sync process.

I didn't use a multi-stage build here — there's nothing to "compile down"
the way there is for a server app. This container's whole job is to *run*
the `twenty` CLI, so the CLI and source code need to stay in the final
image.

## 4. entrypoint.sh

```sh
until curl -s -o /dev/null "$TWENTY_URL"; do sleep 2; done
yarn twenty remote:add --as docker --url "$TWENTY_URL" --api-key "$TWENTY_API_KEY"
exec yarn twenty dev --verbose
```

Two things this handles that I initially got wrong:
- **Waiting for the CRM to be ready.** `depends_on` in Compose only waits for
  the container to *start*, not for the CRM app inside it to actually be
  accepting connections. Without the `curl` wait loop, `remote:add` would
  fail because the CRM isn't listening yet.
- **Non-interactive login.** `yarn twenty remote:add` normally does an
  interactive browser login. That doesn't work inside a container, so I used
  `--api-key` instead, which the CLI supports specifically for this.

## 5. docker-compose.yml

- **`twenty-crm` service** — runs the official image on port `2020` (matches
  what `docker:start` uses by default).
- **`app-dev` service** — builds from my Dockerfile, depends on `twenty-crm`,
  and mounts `./src` as a volume so code changes on my machine are picked up
  without rebuilding the image each time.
- **Networking** — a shared bridge network so the two containers can reach
  each other by name.
- **Ports** — only `2020` (the CRM's UI/API) is published to the host.
- **Volumes** — `./src` is bind-mounted into `app-dev` for live sync during
  development. I could **not** confirm the internal path the CRM image uses
  for persistent data (it's Twenty's prebuilt image, not something I built),
  so `twenty-crm` doesn't have a data volume yet — this is a known limitation
  I've noted directly in the compose file's comments, along with how to find
  the right path (`docker inspect twenty-crm`) if persistence is needed later.

## 6. Environment variables

`.env` (copied from `.env.example`, not committed):

| Variable | Purpose |
|---|---|
| `TWENTY_API_KEY` | Lets `app-dev` authenticate with the CRM non-interactively. Generated from inside the running CRM's Settings → APIs & Webhooks page. |

## 7. Commands I used

```bash
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
git checkout -b <myname>-task5

cp .env.example .env
# started the CRM once by hand to generate an API key:
yarn twenty docker:start
# opened http://localhost:2020, logged in, generated an API key,
# pasted it into .env, then stopped the manual container:
yarn twenty docker:stop

docker compose build
docker compose up -d

docker compose ps
docker compose logs -f app-dev
```

## 8. Issues faced & solutions

- **Assumed the wrong project structure.** My first Dockerfile assumed this
  was the full Twenty CRM monorepo (`packages/twenty-server`,
  `packages/twenty-front`). The build failed immediately with
  `COPY packages/twenty-server/package.json: not found`. I had to actually
  inspect `package.json`, `SETUP.md`, and `node_modules/twenty-sdk` to learn
  this repo is a **Twenty App**, not the CRM itself, and rewrite the Docker
  setup around that.
- **No docker-compose file shipped by the SDK.** I first assumed
  `docker:start` ran a compose stack under the hood. Grepping the CLI's
  bundled code and checking `docker ps -a` showed it's actually just one
  container (`twentycrm/twenty-app-dev`) — so my compose file wraps that
  single image directly instead of trying to reproduce a multi-service CRM
  stack that doesn't exist in this SDK.
- **Interactive login doesn't work in a container.** `yarn twenty
  remote:add` normally opens a browser for login. Found the `--api-key` flag
  via `--help` and used that instead for non-interactive auth.
- **Container startup race condition.** `app-dev` would fail to connect
  because it started before the CRM was actually ready to accept requests.
  Added a `curl`-based wait loop in `entrypoint.sh`.

## 9. Loom video

Plan for what I'll walk through on camera:
1. Explain why this project isn't a normal "build a server from source"
   Dockerfile — show `SETUP.md` and `yarn twenty --help`.
2. Walk through the Dockerfile and entrypoint.sh.
3. Walk through docker-compose.yml — both services, networking, the
   volume/persistence limitation I noted.
4. Run `docker compose build` and `docker compose up -d` live.
5. Open `http://localhost:2020` and show my synced app-component appearing
   in the CRM.
6. Cover the issues above and how I actually debugged them (checking
   `docker ps`, grepping the CLI bundle, reading `--help` output).