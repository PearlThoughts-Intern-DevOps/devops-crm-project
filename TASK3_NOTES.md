# Task 3: DevOps CRM Project — Setup, Automation, and Issues

## What this project is

`devops-crm-project` is not a full CRM built from scratch — it's a custom
**App/extension for Twenty CRM**, scaffolded with `create-twenty-app` and
built on `twenty-sdk`. Twenty CRM itself (the platform) runs as a Docker
container; this repo's code is a small app that gets built and synced
*into* that running platform via the `twenty` CLI.

## Manual setup steps followed

1. Cloned the repo directly (already an org member via
   `PearlThoughts-Intern-DevOps`, so no fork was needed).
2. Created a branch named after myself: `netaji`.
3. Installed the exact Node version this project pins (`.nvmrc` → 24.5.0)
   using `nvm install 24.5.0 && nvm use 24.5.0`.
4. Enabled Corepack and confirmed the pinned Yarn 4 version (`.yarnrc.yml`)
   with `corepack enable` and `yarn -v` (4.13.0).
5. Confirmed Docker Desktop was installed and enabled WSL2 integration for
   this Ubuntu distro, since the local Twenty server only ships as a
   Docker image (no non-Docker path exists for it via this SDK).
6. Ran `yarn install` to install dependencies, including the `twenty` CLI.
7. Ran `yarn twenty docker:start` to pull and start the local Twenty CRM
   server container.
8. Ran `yarn twenty docker:status` to confirm the server was healthy.
9. Opened `http://localhost:2020` and logged in with the default dev
   credentials `tim@apple.dev` / `tim@apple.dev`.
10. Ran `yarn twenty dev` to build and sync this app into the running
    Twenty instance — authorized the CLI via the browser prompt it opened.
11. Confirmed success: Overall Status `✓ Synced`, all pipeline stages
    (`Application Initialization`, `Resources Build`, `Resources Upload`,
    `Manifest Build`, `Application Synchronization`, `Api Client
    Generation`) done, 7 entities synced.

### Stopping things

- `yarn twenty dev` is a foreground watch process — stop it with `Ctrl+C`.
- The Twenty server itself keeps running in Docker until explicitly
  stopped with `yarn twenty docker:stop` (or `docker stop
  twenty-app-dev` directly).

## Automation: `setup_crm.py`

Per the task requirement, wrote a **Python script** (not a shell script)
that automates the entire manual sequence above:

1. Verifies it's run from the correct project directory (checks
   `package.json` references `twenty-sdk`).
2. Checks required tools (`node`, `yarn`, `docker`, `git`) are installed
   and displays each version.
3. Compares the active Node version against `package.json`'s `engines`
   field and warns if they don't match.
4. Confirms Docker is actually *running* (`docker ps`), not just
   installed.
5. Runs `yarn install`.
6. Checks if the Twenty server is already running before starting it, to
   avoid redundant restarts.
7. Starts the server with `yarn twenty docker:start` if needed.
8. **Polls** `yarn twenty docker:status` every 10 seconds (up to 2
   minutes) until it reports healthy, instead of checking once.
9. Displays the local URL.
10. Starts `yarn twenty dev` for the app build/sync step.

No hard-coded paths (resolves its own directory via `Path(__file__)`), and
every command uses Python's `subprocess` module with explicit error
handling rather than assuming success.

## Issues faced and how they were resolved

- **Docker command not found in WSL** — Docker Desktop was installed on
  Windows but WSL2 integration wasn't enabled for this Ubuntu distro.
  Fixed via Docker Desktop → Settings → Resources → WSL Integration →
  enabled the toggle for this distro → Apply & Restart.
- **`docker:start` reported "did not become healthy in time"** even
  though the server was actually fine — confirmed via `docker:logs`
  (showed normal migration/seed completion) and `docker:status`
  separately reporting healthy. This is a flaky first-boot health-check
  in the CLI itself, not a real failure — verified rather than trusted
  blindly.
- **`yarn` command resolved to the wrong program** — a fresh terminal
  didn't have Node/Corepack set up yet, and `apt`'s own suggested fix
  (`sudo apt install cmdtest`) installed an unrelated Python testing tool
  that *also* provides a binary called `yarn`, silently shadowing the
  real one. Diagnosed with `which -a yarn` (showed `/usr/bin/yarn` ahead
  of the real Corepack-managed one), fixed by purging `cmdtest`
  (`sudo apt remove --purge cmdtest`) and re-enabling Corepack.
- **`nvm alias default` didn't change the current shell** — setting a
  default only applies to new terminals; had to also run `nvm use
  24.5.0` to fix the terminal already open.
- **CLI authentication for `yarn twenty dev` timed out (120s limit)** —
  didn't click "Authorize" quickly enough on the browser prompt the first
  time. Resolved by re-running and authorizing immediately when prompted.
- **Automation script's health check timed out even though the server
  was healthy** — the script checked `docker:status` only once,
  immediately after `docker:start`, catching the server mid-boot after a
  cold start (right after `docker:stop`). Fixed by changing the script to
  **poll** `docker:status` every 10 seconds for up to 2 minutes instead
  of checking a single time — a one-shot check right after starting a
  slow-booting service is inherently unreliable.

## What I learned

- How a platform (Twenty CRM) and an app/extension built on its SDK
  relate to each other, and why the app's setup depends on the
  platform's own container being healthy first.
- Why a single status check right after starting a slow service is
  unreliable, and why polling with a timeout window is the correct
  pattern for automation scripts waiting on async startup.
- How a completely unrelated `apt` package can silently shadow a command
  you already have installed correctly, and how to diagnose that with
  `which -a`.
- The difference between `nvm alias default` (future shells) and `nvm
  use` (current shell).
- That a script's own error message can be misleading in async/timing
  situations — cross-checking manually (as I did with `docker:logs`) is
  often necessary before trusting an automated failure report.