# Task 3 — Setup & Automation Documentation

**Project:** devops-crm-project (Twenty CRM)
**Branch:** `sakhisurakhya/task-3`

## Manual Setup Steps

Clone the repository and install the dependencies:

```bash
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
yarn install
```

Start the local Twenty CRM server:

```bash
yarn twenty docker:start
```

Check the server status:

```bash
yarn twenty docker:status
```

The status should show the server as healthy.

Open the application:

`http://localhost:2020`

Development login:

`tim@apple.dev` / `tim@apple.dev`

To stop the server:

```bash
yarn twenty docker:stop
```

> **Note:** `yarn twenty dev` is used for developing and syncing a custom Twenty application extension. It was not required to run the core CRM locally. The application successfully runs using `yarn twenty docker:start`.

## Automation — `scripts/setup_local.py`

A Python script was created to automate the local setup and startup process.

No shell (`.sh`) scripts were used.

Run the automation from the project root:

```bash
python scripts/setup_local.py
```

The script performs the following steps:

1. Checks required prerequisites:

   * Node.js
   * Yarn
   * Docker
   * Docker daemon availability
2. Installs project dependencies using `yarn install`.
3. Starts the local Twenty server using `yarn twenty docker:start`.
4. Polls the Docker/Twenty status until the application is healthy.
5. Opens the application at `http://localhost:2020` in the browser.

## Issues Faced & Solutions

| Issue                                                          | Cause                                                                       | Solution                                                                                            |
| -------------------------------------------------------------- | --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Docker Desktop would not start                                 | WSL 2 was not installed/configured                                          | Installed WSL 2 and configured Docker Desktop to use the WSL 2 engine                               |
| `yarn install` failed with `ENOTFOUND registry.yarnpkg.com`    | Intermittent registry/network connectivity issue                            | Retried installation with an increased network timeout                                              |
| `yarn twenty dev` failed on Windows with path/backslash errors | Windows-specific path handling issue during Twenty resource synchronization | `yarn twenty dev` was not required for running the core CRM, so it was excluded from the automation |
| Python script reported Yarn as unavailable                     | Yarn is exposed through a `.cmd` shim on Windows                            | Used `shutil.which()` to correctly resolve Windows executables                                      |

## CI Validation Issue

During CI validation, the Twenty application reported the following page-layout validation error:

```text
INVALID_PAGE_LAYOUT_WIDGET_DATA:
Position layoutMode "GRID" does not match tab layoutMode "VERTICAL_LIST"
```

The affected widget used `gridPosition`, while its parent tab was configured with `VERTICAL_LIST`.

The page layout configuration was corrected to:

```typescript
layoutMode: PageLayoutTabLayoutMode.GRID,
```

After this correction, the application build was successfully validated using:

```bash
yarn twenty dev:build
```

## Verification

The following were successfully verified:

* Repository cloned and explored.
* Application installed and run locally.
* Application accessible at `http://localhost:2020`.
* Python automation script created.
* Python automation tested successfully.
* No shell scripts were used.
* Setup and troubleshooting documented.
* Task branch `sakhisurakhya/task-3` created.
* Changes pushed to the fork.
* Pull request created.
* Page-layout CI validation issue identified and resolved.
* Application build completed successfully.

## Result

Task 3 local setup and Python automation requirements have been completed and documented.
