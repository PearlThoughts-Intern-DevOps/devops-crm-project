# My Twenty App

Describe your app in one or two sentences.

## Features

List the top things your app does, for example:

- Feature one
- Feature two
- Feature three

## Getting started

Setup instructions live in [SETUP.md](SETUP.md).

## Publishing

The `Publish` workflow (`.github/workflows/publish.yml`) publishes the app to npm with provenance using [npm trusted publishing](https://docs.npmjs.com/trusted-publishers). To publish:

1. On npmjs.com register this repository as a trusted publisher of your package, pointing at the `publish.yml` workflow.
2. Bump the version in `package.json`, then push a version tag (e.g. `git tag v1.0.0 && git push --tags`) or run the workflow manually from the Actions tab.

Publishing with provenance is also how you prove ownership when claiming your app in a Twenty marketplace.

## Changelog

Notable changes are documented in [CHANGELOG.md](CHANGELOG.md).

## Learn more

- [Twenty Apps documentation](https://docs.twenty.com/developers/extend/apps/getting-started/quick-start)
- [twenty-sdk CLI reference](https://www.npmjs.com/package/twenty-sdk)
- [Discord](https://discord.gg/cx5n4Jzs57) 


# devops - task-03 
# Twenty CRM — Local Setup & Automation

**PearlThoughts DevOps Internship — Task 03**
**Author:** Shubham Singh

---

## What is Twenty CRM?

Twenty is an open-source CRM (Customer Relationship Management) platform. This project is a custom Twenty SDK-based app that connects to a self-hosted Twenty backend running via Docker. It lets you manage companies, people, opportunities, tasks, and more — all in one place.

---

## Tech Stack

| Layer | Tool | Purpose |
|---|---|---|
| **Runtime** | Node.js v24.5.0 | JavaScript runtime |
| **Package Manager** | Yarn 4.13.0 | Dependency management |
| **Language** | TypeScript 5.x | Type-safe JavaScript |
| **Frontend Framework** | React 19 | UI rendering |
| **CRM Platform** | Twenty SDK / Twenty UI | CRM components and API client |
| **API Client** | twenty-client-sdk | Auto-generated GraphQL client |
| **Build Tool** | esbuild / Rolldown | Fast JS/TS bundler |
| **Dev Server** | Vite | Hot-reload dev server |
| **Testing** | Vitest | Unit and integration tests |
| **Linting** | OxLint | Fast Rust-based JS/TS linter |
| **Database** | PostgreSQL | Relational data storage |
| **Cache / Queue** | Redis | Background jobs and caching |
| **Container** | Docker | Runs the Twenty backend stack |
| **Node Version Manager** | NVM | Manages Node.js versions via `.nvmrc` |
| **Automation** | Python 3 | Setup and startup automation script |

---

## Project Structure

```
devops-crm-project/
├── src/                        # App source code
├── public/                     # Static assets
├── script/
│   └── setup.py               # Python automation script
├── package.json               # Dependencies and scripts
├── .nvmrc                     # Node version lock (read by nvm)
├── .env                       # Environment config (DB, ports, URLs)
├── tsconfig.json              # TypeScript config
├── vitest.config.ts           # Test config
├── .oxlintrc.json             # Linter config
└── yarn.lock                  # Locked dependency tree
```

---

## Prerequisites

Make sure these are installed before starting:

| Tool | Check Command |
|---|---|
| Git | `git --version` |
| Node.js (via nvm) | `node --version` |
| Yarn | `yarn --version` |
| Docker | `docker --version` |
| Python 3 | `python3 --version` |
| NVM | `nvm --version` |

---

## Manual Setup (Step by Step)

### Step 1 — Clone the Repository

```bash
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
```

### Step 2 — Set Correct Node Version

The `.nvmrc` file locks the Node version for this project:

```bash
nvm install     # reads .nvmrc and installs the right version
nvm use         # switches to that version
node --version  # verify: should show v24.5.0
```

### Step 3 — Install Dependencies

```bash
yarn            # installs all packages from yarn.lock
```

### Step 4 — Configure Environment

```bash
cp .env.example .env   # if example exists
# OR edit .env directly
```

Your `.env` should contain the following keys (fill in your own values):

```env
DB_HOST=
DB_PORT=
DB_NAME=
DB_USER=
DB_PASSWORD=
NODE_ENV=development
PORT=
SERVER_URL=
PG_DATABASE_URL=
```

> ⚠️ Never commit your `.env` file to Git. It is already listed in `.gitignore`.

### Step 5 — Start PostgreSQL

```bash
sudo apt install postgresql -y
sudo systemctl start postgresql
sudo -u postgres psql -c "CREATE USER twenty WITH PASSWORD 'twenty';"
sudo -u postgres psql -c 'CREATE DATABASE "default" OWNER twenty;'
sudo -u postgres psql -c 'CREATE DATABASE "test" OWNER twenty;'
```

### Step 6 — Start Redis

```bash
sudo apt install redis-server -y
sudo systemctl start redis-server
redis-cli ping   # should return PONG
```

### Step 7 — Start the App via Docker

Twenty's backend (API + worker + frontend) runs as a Docker container:

```bash
yarn twenty docker:start
```

The app will be available at: **http://localhost:2020**

Default login:
- **Email:** `tim@apple.dev`
- **Password:** `tim@apple.dev`

---

## Automated Setup (Python Script)

All the above steps are automated in a single Python script.

### Run Everything at Once

```bash
python3 script/setup.py all
```

### Or Run Individual Steps

```bash
python3 script/setup.py check      # verify all tools are installed
python3 script/setup.py env        # copy .env files
python3 script/setup.py install    # nvm + yarn install
python3 script/setup.py start      # docker:start + wait for app
python3 script/setup.py status     # check what's running
python3 script/setup.py stop       # stop Docker container
```

### How the Script Works

```
python3 setup.py all
        │
        ├── check    → verifies git, node, yarn, docker, docker daemon
        ├── env      → finds/copies .env (searches whole project)
        ├── install  → reads .nvmrc → nvm install → nvm use → yarn
        └── start    → yarn twenty docker:start → polls until app is up
```

**Key design decisions:**

- **No hardcoding** — all config (port, DB name, user, password) is read from `.env`
- **Dynamic root detection** — script finds project root automatically, works from any folder
- **Dynamic Node version** — reads `.nvmrc` so it always installs the correct Node version
- **Dynamic start command** — reads `package.json` scripts to find the right start command
- **Idempotent** — safe to run multiple times; skips steps already done

---

## Verification

### Frontend

Open browser → **http://localhost:2020**

You should see the Twenty CRM login page. Log in with `tim@apple.dev`.

Navigate to **Companies** — you'll see 600 companies seeded automatically.

### Backend Health Check

```bash
curl http://localhost:2020/healthz
# {"status":"ok","info":{},"error":{},"details":{}}
```

### Database Verification

Connect to PostgreSQL and query live CRM data:

```bash
sudo -u postgres psql -d default
```

```sql
-- Check a company exists
SELECT name, "domainNamePrimaryLinkUrl", "addressAddressCountry"
FROM "workspace_1wgvd1injqtife6y4rvfbu3h5"."company"
WHERE name ILIKE '%shubham%';

-- Check a person record
SELECT "nameFirstName", "nameLastName", "emailsPrimaryEmail"
FROM "workspace_1wgvd1injqtife6y4rvfbu3h5"."person"
WHERE "nameFirstName" ILIKE '%shubham%';
```

**Result confirmed in DB:**

| Field | Value |
|---|---|
| Company | Shubham Cloud Solutions |
| Domain | ShubhamCloudSolution.com |
| Country | INDIA |
| Person | shubham singh |
| Email | shubhamsingh74888@gmail.com |

### Redis Verification

```bash
redis-cli ping    # PONG = running
```

### Docker Container

```bash
yarn twenty docker:status   # shows container health
yarn twenty docker:logs     # stream live logs
```

---

## Available Scripts

From `package.json`:

| Command | Description |
|---|---|
| `yarn twenty` | Twenty CLI (docker, remote, dev commands) |
| `yarn twenty docker:start` | Start the CRM via Docker |
| `yarn twenty docker:stop` | Stop the container |
| `yarn twenty docker:status` | Check container health |
| `yarn twenty docker:logs` | Stream logs |
| `yarn twenty docker:reset` | Reset all data and restart fresh |
| `yarn test` | Run all tests with Vitest |
| `yarn test:unit` | Run unit tests only |
| `yarn lint` | Lint with OxLint |
| `yarn typecheck` | TypeScript type check |

---

## Issues Faced & Solutions

| Issue | Cause | Solution |
|---|---|---|
| `Run from twenty repo root` error | Script looked for `package.json` in wrong folder | Added `find_root()` to walk up directory tree automatically |
| `.env.example` not found | This repo has no `.env.example`, uses root `.env` directly | Script now checks for existing `.env` and skips gracefully |
| `nx not found` | This repo doesn't use Nx at all | Removed nx entirely; script reads `package.json` scripts dynamically |
| Password prompt for PostgreSQL | `subprocess.run` was passing password interactively | Switched to `sudo -u postgres psql` (superuser, no password needed) |
| App URL wrong | Hardcoded port 3000 but app runs on 2020 | `PORT` and `SERVER_URL` now read from `.env` |
| `yarn twenty` just printed help | `twenty` is a CLI tool, not a server | Correct command is `yarn twenty docker:start` |

---



