# Task 3 — Local Setup & Automation: devops-crm-project

**Repo:** https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project
**Environment:** Windows 11, VS Code, PowerShell

## 1. Overview

This project is a custom app built on the [Twenty CRM](https://twenty.com) platform using the `twenty-sdk`. It's not a standalone app — it runs as an extension synced into a local Twenty CRM server instance, which itself runs via Docker.

## 2. Setup Steps

### 2.1 Clone the repository

```bash
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
```

### 2.2 Explore the project

- `README.md` — high-level project description, points to `SETUP.md`
- `SETUP.md` — official setup instructions
- `package.json` — Node/Yarn project, pinned to `node ^24.5.0`, `yarn >=4.0.2`, built on `twenty-sdk` / `twenty-client-sdk`
- `.nvmrc` — pins Node to `24.5.0`

### 2.3 Install prerequisites

| Tool | Required version | Notes |
|---|---|---|
| Node.js | 24.5.0 (per `.nvmrc`) | Installed via `nvm-windows` |
| Yarn | 4.13.0 (Yarn 4+) | Enabled via Node's `corepack` |
| Docker Desktop | any recent version | Runs the local Twenty CRM server |

```powershell
nvm install 24.5.0
nvm use 24.5.0
corepack enable
corepack prepare yarn@4.13.0 --activate
```

### 2.4 Install dependencies

```powershell
yarn install
```

### 2.5 Start the local Twenty server (Docker)

```powershell
yarn twenty docker:start
```

Verify with:
```powershell
yarn twenty docker:status
```

Expected healthy output:
```
Status:  running (healthy)
URL:     http://localhost:2020
Version: v2.37.0
Login:   tim@apple.dev / tim@apple.dev
```

### 2.6 Log in

Open `http://localhost:2020` → log in with `tim@apple.dev` / `tim@apple.dev`. **Confirmed working.**

### 2.7 Start the dev/sync server

```powershell
yarn twenty dev
```

This is meant to build and sync the custom app into the running Twenty instance. **This step failed on native Windows — see Issue #3 below.**

## 3. Automation

A Python script (`setup.py`, no shell scripts used per task requirement) automates steps 2.3–2.6: checks Node/Docker are present, enables Yarn via corepack, installs dependencies, starts the Docker-based Twenty server, and prints the status/login info.

Run with:
```powershell
python setup.py
```

## 4. Issues Faced & Solutions

### Issue 1: Node.js and Yarn not installed
**Symptom:** `node`/`yarn` not recognized as a command.
**Cause:** Fresh machine, Node not installed at all.
**Solution:** Installed [nvm-windows](https://github.com/coreybutler/nvm-windows), then `nvm install 24.5.0` / `nvm use 24.5.0` to match the version pinned in `.nvmrc`. Enabled Yarn via Node's built-in `corepack`.

### Issue 2: PowerShell blocked Yarn's script from running
**Symptom:**
```
File ...\yarn.ps1 cannot be loaded because running scripts is disabled on this system.
```
**Cause:** Windows PowerShell's default execution policy (`Restricted`) blocks local `.ps1` scripts, including the one Yarn uses as its entry point on Windows.
**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
This allows locally-created scripts to run for the current user only, while still requiring downloaded scripts to be signed — the standard safe setting for dev machines.

### Issue 3: `yarn twenty dev` fails with Windows path-separator errors
**Symptom:**
```
Failed to upload .twenty\output\public\logo.svg: filePath contains unsafe characters or path traversal
INVALID_FRONT_COMPONENT_INPUT: Resource path must not contain backslashes
```
**Root cause:** The `twenty-sdk` CLI (v2.35.1) builds internal resource paths using Node's native path handling, which produces backslash-separated paths (`\`) on Windows. The Twenty server's sync API validates resource paths as POSIX-style and rejects backslashes as unsafe — a cross-platform incompatibility in the CLI itself, not a local misconfiguration. This is deterministic and reproduces on every run on native Windows.

**Attempted solution:** Run the toolchain inside WSL2 (Windows Subsystem for Linux), which uses POSIX paths throughout and is the standard workaround for this class of Windows/Node path bug.
- Installed WSL2 (`wsl --install`) successfully.
- Ubuntu distro registered but failed to boot with `Catastrophic failure — Error code: Wsl/Service/E_UNEXPECTED` on every launch attempt.
- Diagnosed systematically: confirmed disk space was ample (339 GB free), confirmed the core WSL2/Hyper-V backend was healthy (the pre-existing `docker-desktop` WSL distro ran fine), unregistered and reinstalled Ubuntu cleanly — issue persisted.
- Checked system memory: only **~1.5 GB free out of 8 GB total** RAM while Docker Desktop + VS Code + browser were running. WSL2 requires spinning up a Hyper-V virtual machine to boot a distro, and insufficient free memory is a known cause of this exact error.

**Conclusion:** The dev-sync (`yarn twenty dev`) step is blocked by a genuine upstream Windows-compatibility bug in `twenty-sdk` 2.35.1, and the standard WSL2 workaround is blocked on this machine by insufficient available RAM (8 GB total is tight for WSL2 + Docker Desktop + a full dev environment simultaneously). The Docker-based Twenty server itself runs successfully and was verified working end-to-end (healthy status, working login).

**Recommendation for a permanent fix:** Either (a) run this project on a machine with more RAM or in WSL2 with other apps closed, (b) run it in a native Linux/macOS environment, or (c) flag the path-handling bug upstream to the `twenty-sdk` maintainers.

### Issue 4: Calendar sync warnings/errors in server logs
**Symptom:** `Calendar event fetch error: No refresh token found...` and `Google APIs auth is not enabled` in logs.
**Cause:** The seeded demo workspace includes placeholder calendar integrations that require real Google OAuth credentials, which aren't configured for local dev.
**Solution:** None needed — this doesn't affect core CRM functionality or login, which use email/password, not Google OAuth. Safe to ignore for local development.

## 5. Loom Video

[Add your Loom link here after recording — demonstrate: clone → prerequisite install → `python setup.py` running end-to-end → Docker server healthy → logging into localhost:2020 → briefly show the `yarn twenty dev` error as the documented known issue.]

## 6. Summary

| Step | Status |
|---|---|
| Clone repo | ✅ |
| Explore structure | ✅ |
| Install prerequisites (Node, Yarn, Docker) | ✅ |
| `yarn install` | ✅ |
| `yarn twenty docker:start` (server) | ✅ |
| Login at localhost:2020 | ✅ |
| `yarn twenty dev` (app sync) | ❌ Known upstream Windows bug, documented above |
| Python automation script | ✅ |
