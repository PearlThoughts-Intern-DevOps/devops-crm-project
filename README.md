# Twenty CRM — Local Setup & Automation

**PearlThoughts DevOps Internship — Task 03**
**Author:** Shubham Singh

---

## What is Twenty CRM?

Twenty is an open-source CRM platform. This project is a custom Twenty SDK-based app that connects to a self-hosted Twenty backend running via Docker. It lets you manage companies, people, opportunities, tasks, and more.

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
├── src/                   # App source code
├── public/                # Static assets
├── script/
│   └── setup.py          # Python automation script
├── package.json          # Dependencies and scripts
├── .nvmrc                # Node version lock (read by nvm)
├── .env                  # Environment config (not committed to Git)
├── tsconfig.json         # TypeScript config
├── vitest.config.ts      # Test config
├── .oxlintrc.json        # Linter config
└── yarn.lock             # Locked dependency tree
```

---

## Prerequisites

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

The `.nvmrc` file locks the exact Node version needed for this project:

```bash
nvm install     # reads .nvmrc and installs the right version
nvm use         # switches to that version
node --version  # verify: should show v24.5.0
```

### Step 3 — Install Dependencies

```bash
yarn
```

### Step 4 — Configure Environment

```bash
cp .env.example .env   # if example exists, else create .env manually
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

Twenty's backend runs as a Docker container managed by the Twenty CLI:

```bash
yarn twenty docker:start
```

App available at: **http://localhost:2020**
Login: `tim@apple.dev` / `tim@apple.dev`

---

## Automated Setup (Python Script)

All 7 steps above are automated in a single Python script — no manual steps needed.

### Run Everything at Once

```bash
python3 script/setup.py all
```

### Individual Steps

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
        ├── check    → verifies git, node, yarn, docker + daemon running
        ├── env      → finds/copies .env (searches whole project tree)
        ├── install  → reads .nvmrc → nvm install → nvm use → yarn
        └── start    → yarn twenty docker:start → polls until app is up
```

**Key design decisions:**

- **No hardcoding** — all config (port, DB, URL) read from `.env`
- **Dynamic root detection** — `find_root()` walks up folders to find `package.json`, works from any directory
- **Dynamic Node version** — reads `.nvmrc` so always installs the correct version
- **Idempotent** — safe to run multiple times, skips already completed steps

---

## Verification

### Frontend

Open **http://localhost:2020** → login with `tim@apple.dev` → navigate to Companies → see 600 seeded companies.

### Backend Health Check

```bash
curl http://localhost:2020/healthz
# Expected: {"status":"ok","info":{},"error":{},"details":{}}
```

### Database Verification

```bash
sudo -u postgres psql -d default
```

```sql
-- Verify company data
SELECT name, "domainNamePrimaryLinkUrl", "addressAddressCountry"
FROM "workspace_1wgvd1injqtife6y4rvfbu3h5"."company"
WHERE name ILIKE '%shubham%';

-- Verify person data
SELECT "nameFirstName", "nameLastName", "emailsPrimaryEmail"
FROM "workspace_1wgvd1injqtife6y4rvfbu3h5"."person"
WHERE "nameFirstName" ILIKE '%shubham%';
```

**Confirmed in DB:**

| Field | Value |
|---|---|
| Company | Shubham Cloud Solutions |
| Domain | ShubhamCloudSolution.com |
| Country | INDIA |
| Person | shubham singh |

### Redis

```bash
redis-cli ping    # PONG = running
```

### Docker Container

```bash
yarn twenty docker:status   # container health
yarn twenty docker:logs     # live logs
```

---

## Available Scripts

| Command | Description |
|---|---|
| `yarn twenty docker:start` | Start the CRM via Docker |
| `yarn twenty docker:stop` | Stop the container |
| `yarn twenty docker:status` | Check container health |
| `yarn twenty docker:logs` | Stream live logs |
| `yarn twenty docker:reset` | Reset all data and restart fresh |
| `yarn test` | Run all tests with Vitest |
| `yarn test:unit` | Run unit tests only |
| `yarn lint` | Lint with OxLint |
| `yarn typecheck` | TypeScript type check |

---

## Issues Faced & Solutions

| Issue | Cause | Solution |
|---|---|---|
| `Run from twenty repo root` error | Script was run from `script/` folder, looked for `package.json` in current directory | Added `find_root()` to walk up directory tree automatically — works from any folder |
| `nx not found` | Script assumed standard Twenty CRM repo which uses Nx; this repo does not | Removed nx entirely; script now reads `package.json` scripts dynamically |
| Password prompt for PostgreSQL | `subprocess.run` was passing DB password interactively | Switched to `sudo -u postgres psql` — runs as superuser, no password needed |
| App URL wrong | Port 3000 was hardcoded but this repo runs on port 2020 | `PORT` and `SERVER_URL` now read directly from `.env` — no hardcoding |
| `yarn twenty` only printed help | `twenty` is a CLI tool — running it alone just shows available commands | Correct start command is `yarn twenty docker:start` |
| CI test failure on PR | Pre-existing bug in repo: `layoutMode VERTICAL_LIST` conflicts with widget `gridPosition` which requires `GRID` | Not caused by Task 03 changes — documented as existing repo issue |

---

## Branch & PR

```bash
git checkout -b shubham-singh
git add script/setup.py README.md
git commit -m "Task 03: Python automation script + README"
git push origin shubham-singh
```

---

## Demo

Loom video: https://www.loom.com/share/704f77a822074b24badcfd3b0537cafc
