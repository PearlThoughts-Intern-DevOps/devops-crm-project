# Task 3 — Setup & Automation Documentation

**Project:** devops-crm-project (Twenty CRM) | **Branch:** `sakhisurakhya/task-3`

## Manual Setup Steps

```bash
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
yarn install
yarn twenty docker:start
yarn twenty docker:status   # confirm "healthy"
```

Open **http://localhost:2020** → login: `tim@apple.dev` / `tim@apple.dev`

To stop: `yarn twenty docker:stop`

> Note: `yarn twenty dev` (listed in SETUP.md) is for syncing a custom app extension, not for running the core CRM. It wasn't needed — see Issue 3.

## Automation — `setup_local.py`

Pure Python (no `.sh` scripts), run with:
```bash
python setup_local.py
```

It automates: checking prerequisites (Node/Yarn/Docker + daemon running) → `yarn install` → `yarn twenty docker:start` → polling `docker:status` until healthy → opening `localhost:2020` in the browser.

## Issues Faced & Solutions

| Issue | Cause | Fix |
|---|---|---|
| Docker Desktop wouldn't start | WSL 2 not installed | `wsl --install` (as Admin) + restart; set Docker to use WSL2 engine |
| `yarn install` failed with `ENOTFOUND registry.yarnpkg.com` | Intermittent registry connectivity (DNS/ping were fine) | Ran with `yarn install --network-timeout 300000`; added this to `setup.py` by default |
| `yarn twenty dev` failed with backslash/path errors | Twenty CLI (v2.35.1) bug — doesn't convert Windows `\` paths to `/` for resource uploads | Not required for the task; `docker:start` alone runs the full app. Would likely work in WSL2. Excluded from automation. |
| `setup.py` reported Yarn as missing | Yarn on Windows is a `.cmd` shim; Python's `subprocess` (shell=False) doesn't auto-resolve `PATHEXT` | Used `shutil.which()` to resolve executables correctly |



## Status

- Clone, explore, run app locally (verified in browser)
- Python automation script
- Branch created (`sakhisurakhya/task-3`)
- Push + PR
