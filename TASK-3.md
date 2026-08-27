# Task 3 - Local Setup and Python Automation

## 1. Task Overview

This document reports the work completed for **Task 3** of my PearlThoughts DevOps internship. The task involved setting up a Twenty CRM application locally, understanding its custom application architecture, writing a Python automation script to handle environment validation and local server startup, and validating the setup through linting, type-checking, and automated tests.

All work was performed on the `abdulrahman-task-3` branch of the `devops-crm-project` repository.

## 2. Objectives

- Set up the Twenty CRM project locally on macOS (Apple Silicon).
- Understand the custom Twenty application's structure and how its pieces connect.
- Write a Python script (`setup.py`) to automate prerequisite checks, dependency installation, Docker startup, health checks, and launching the development server.
- Validate the setup using linting, type-checking, and unit/integration tests.
- Document the process in a clear, beginner-friendly way and validate changes using Git.

## 3. Project Overview

**Repository:** `devops-crm-project`
**GitHub remote:** `https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git`
**Working branch:** `abdulrahman-task-3`

The project is a **Twenty CRM** application built using the Twenty SDK, TypeScript, React, and Yarn. Twenty CRM allows developers to build custom applications (pages, roles, navigation items, and widgets) on top of its platform using a defined SDK.

The local Twenty server runs at: `http://localhost:2020`

## 4. Repository and Branch

All Task 3 work was committed on the dedicated branch `abdulrahman-task-3`, keeping it isolated from the main branch until it is ready for review.

## 5. Project Structure

The following source files were inspected as part of this task:

```
src/__tests__/application-config.test.ts
src/__tests__/global-setup.ts
src/__tests__/schema.integration-test.ts
src/application-config.ts
src/constants/universal-identifiers.ts
src/default-role.ts
src/front-components/main-page.tsx
src/navigation-menu-items/main-page.navigation-menu-item.ts
src/page-layouts/main-page.page-layout.ts
```

### What each file/directory is responsible for

| Path | Responsibility |
|---|---|
| `src/application-config.ts` | Defines the application itself (identifier, display name, description) using `defineApplication`. This is the entry point that tells Twenty "this is my custom app." |
| `src/constants/universal-identifiers.ts` | Centralizes all unique identifier strings and display text used across the application, so they aren't duplicated or hardcoded in multiple files. |
| `src/default-role.ts` | Defines the default permission role granted for this application using `defineApplicationRole`. |
| `src/front-components/main-page.tsx` | A React component that renders the actual UI shown to the user for this application's main page. |
| `src/navigation-menu-items/main-page.navigation-menu-item.ts` | Registers a navigation menu entry so users can reach the application's main page from Twenty's UI. |
| `src/page-layouts/main-page.page-layout.ts` | Defines how the main page is laid out (tabs, widgets, grid position) and which front component it displays. |
| `src/__tests__/application-config.test.ts` | Unit test verifying the application metadata constants are exposed correctly. |
| `src/__tests__/global-setup.ts` | Test setup file, likely used to prepare the test environment before integration tests run. |
| `src/__tests__/schema.integration-test.ts` | Integration tests that check the application against a running Twenty instance (installation status, CRUD operations). |

## 6. Application Architecture

### Application Configuration

`src/application-config.ts` uses `defineApplication` (from `twenty-sdk/define`) to declare:

- `universalIdentifier`
- `displayName`
- `description`

These values are imported from `src/constants/universal-identifiers.ts`, which defines constants such as:

- `APP_DISPLAY_NAME`
- `APP_DESCRIPTION`
- `APPLICATION_UNIVERSAL_IDENTIFIER`
- `DEFAULT_ROLE_UNIVERSAL_IDENTIFIER`
- `MAIN_PAGE_FRONT_COMPONENT_UNIVERSAL_IDENTIFIER`
- `MAIN_PAGE_LAYOUT_UNIVERSAL_IDENTIFIER`
- `MAIN_PAGE_LAYOUT_TAB_UNIVERSAL_IDENTIFIER`
- `MAIN_PAGE_WIDGET_UNIVERSAL_IDENTIFIER`
- `MAIN_PAGE_NAVIGATION_MENU_ITEM_UNIVERSAL_IDENTIFIER`

Keeping these identifiers in one constants file avoids duplication and keeps every part of the app (config, role, navigation, layout) referring to the exact same identifier strings.

### Front Component

`src/front-components/main-page.tsx` uses React, the `useState` hook, Twenty UI's `Avatar` component, Twenty UI icons, and `defineFrontComponent` to build the main application page. It renders:

- An application avatar
- The application name
- An installation message
- A link to application settings
- Documentation categories (Data model, Logic, Layout sections)
- Hover interactions
- Documentation links

This demonstrates how a **custom React component** can be integrated directly into the Twenty platform: instead of Twenty providing a generic screen, this component is registered through `defineFrontComponent` and displayed through the page layout system, giving full control over the page's look and behavior while still living inside Twenty's UI shell.

### Default Role

`src/default-role.ts` uses `defineApplicationRole` and configures the following permissions:

| Permission | Value | Meaning |
|---|---|---|
| `canReadAllObjectRecords` | `true` | Users with this role can view all records across object types. |
| `canUpdateAllObjectRecords` | `true` | Users with this role can modify any record. |
| `canSoftDeleteAllObjectRecords` | `true` | Users with this role can soft-delete records (mark as deleted, recoverable). |
| `canDestroyAllObjectRecords` | `false` | Users with this role **cannot** permanently destroy records — this is intentionally restricted for safety. |

At a high level, this role grants broad read/write/soft-delete access while explicitly preventing irreversible hard deletes, which is a sensible default for an application role.

### Navigation

`src/navigation-menu-items/main-page.navigation-menu-item.ts` uses `defineNavigationMenuItem` to create a navigation entry that points to the main page layout, making the application reachable from Twenty's navigation menu.

### Page Layout

`src/page-layouts/main-page.page-layout.ts` uses `definePageLayout` to define:

- A standalone page
- An "Overview" tab
- A vertical list layout
- A front component widget
- The widget's grid position
- The front component's universal identifier (linking the layout to the actual React component)

### How the pieces connect

```
Navigation Menu
    ↓
Page Layout
    ↓
Widget
    ↓
Front Component
```

- The **Navigation Menu** item gives the user an entry point in Twenty's UI.
- Clicking it opens the **Page Layout**, which defines the page's structure (tabs, grid).
- Inside the layout, a **Widget** is placed at a defined grid position.
- That widget references a **Front Component** (the React component), which is what actually renders on screen.

In short: navigation gets the user to the page, the layout arranges the page, the widget occupies a slot in that layout, and the front component is the real UI content displayed in that slot.

## 7. Development Environment

| Tool | Version / Detail |
|---|---|
| Operating System | macOS |
| Architecture | Apple Silicon / ARM64 |
| Node.js | 24.5.0 |
| Yarn | 4.13.0 |
| Docker | 29.6.2 |
| Docker server architecture | aarch64 |
| Twenty Server | v2.35.0 |
| Twenty CLI | v2.35.1 |

The required Node.js version was identified from the project's `.nvmrc` file. The required Yarn version was identified from `package.json`, which specifies:

```
packageManager: yarn@4.13.0
```

## 8. Dependency Installation

Command executed:

```bash
yarn install
```

**Result:** Installation completed successfully, with two warnings:

```
YN0002: my-app@workspace:. doesn't provide monaco-editor (p196b5c), requested by twenty-ui.
YN0086: Some peer dependencies are incorrectly met by your project.
```

**Final result:** `Done with warnings`

These are Yarn **warnings**, not errors — they indicate a missing/mismatched peer dependency (`monaco-editor`) but did **not** prevent installation from completing successfully. No further action was required for Task 3.

## 9. Running Twenty with Docker

Command executed:

```bash
yarn twenty docker:start
```

Output indicated:

```
Twenty server detected on http://localhost:2020
```

The server was then verified with:

```bash
yarn twenty docker:status
```

Result:

```
Status: running (healthy)
URL: http://localhost:2020
Version: v2.35.0
```

**Why health verification matters:** A container can be "started" without the application inside it actually being ready to serve requests. Checking for a `running (healthy)` status confirms that the Twenty server has fully initialized and is actually able to respond to requests, rather than assuming it's ready the moment the container process starts. This prevents automation from moving on to the next step (like starting the dev server) too early and failing.

## 10. Understanding the Twenty CLI

Command executed (for inspection only):

```bash
yarn twenty --help
```

This listed the available commands, which fall into a few logical groups:

| Group | Commands | Purpose |
|---|---|---|
| Development | `dev`, `dev:build`, `dev:typecheck`, `dev:add`, `dev:generate-client` | Running and building the application in development mode, type-checking, adding new SDK elements, and generating the API client. |
| Planning/Deployment | `plan`, `apply` | Computing and applying a metadata plan for the application (used later in `dev`). |
| Docker | `docker:start`, `docker:stop`, `docker:logs`, `docker:status`, `docker:reset`, `docker:upgrade` | Managing the local Twenty server container — starting, stopping, viewing logs, checking status, resetting, or upgrading it. |
| Remote | `remote:add`, `remote:list`, `remote:use`, `remote:status`, `remote:remove` | Managing connections to remote Twenty instances. |

**Note:** Only `docker:start`, `docker:status`, and `dev` were actually executed as part of this task. The other commands listed above were inspected via `--help` but not run.

## 11. Python Automation

To make the local setup process repeatable and less error-prone, I wrote a Python script, `setup.py`, that automates the environment checks and startup sequence.

The script uses the following standard library modules:

```python
import shutil
import subprocess
import sys
import time
from pathlib import Path
```

At a high level, the script:

1. Determines the project root using `Path(__file__).resolve().parent`
2. Requires Node.js `24.5.0`
3. Requires Yarn `4.13.0`
4. Checks that expected project files exist
5. Checks availability of `python3`, `node`, `yarn`, and `docker` on the system
6. Checks the installed Node.js version
7. Checks the installed Yarn version
8. Checks that the Docker daemon is running, using `docker info`
9. Runs `yarn install`
10. Runs `yarn twenty docker:start`
11. Polls `yarn twenty docker:status`
12. Waits for the status to become `running (healthy)`
13. Runs `yarn twenty dev`
14. Handles `Ctrl+C` gracefully to stop the development server

## 12. Detailed Explanation of setup.py

| Function | Purpose |
|---|---|
| `print_step` | Prints a formatted, human-readable status message for each stage of the automation, so the console output is easy to follow. |
| `run_command` | Runs a shell command (via `subprocess`) and lets its output stream directly to the console, used for long-running commands like `yarn install`. |
| `get_command_output` | Runs a command and captures/returns its output as a string, used when the script needs to read a value (e.g., a version number) rather than just display it. |
| `check_project` | Verifies that the expected project files/structure exist before proceeding, to fail fast if run in the wrong directory. |
| `check_command` | Checks whether a given executable (e.g., `node`, `yarn`, `docker`) is available on the system `PATH`, typically using `shutil.which`. |
| `check_prerequisites` | Calls `check_command` for `python3`, `node`, `yarn`, and `docker`, and confirms all required tools are present before continuing. |
| `check_docker` | Runs `docker info` to confirm the Docker daemon is actually running (not just that the `docker` CLI is installed). |
| `install_dependencies` | Runs `yarn install` to install all project dependencies. |
| `start_twenty_docker` | Runs `yarn twenty docker:start` to bring up the local Twenty server container. |
| `wait_for_twenty` | Polls `yarn twenty docker:status` in a loop (using `time.sleep` between attempts) until the server reports `running (healthy)`, with a maximum number of attempts. |
| `start_development_server` | Runs `yarn twenty dev` to start the development server, and catches `KeyboardInterrupt` so the user can stop it cleanly with `Ctrl+C`. |
| `main` | Orchestrates the entire flow in order: check project → check prerequisites → check Docker → install dependencies → start Docker → wait for health → start dev server. |

### Why these specific modules were useful

- **`subprocess`** — needed to actually run external commands like `yarn`, `docker`, and `node` from within Python and capture their output/exit codes.
- **`shutil`** — used for `shutil.which()` to check whether a required executable exists on the system `PATH` before trying to run it.
- **`time`** — used to add delays between health-check polling attempts, avoiding a tight loop that hammers the Docker status command.
- **`pathlib`** — used for `Path(__file__).resolve().parent` to reliably determine the project root regardless of the current working directory the script is invoked from.

## 13. Running the Automation

### Syntax validation (before running)

```bash
python3 -m py_compile setup.py
```

**Result:** Exit code `0`.

This confirms the script is syntactically valid Python — it does **not** execute the script's logic, it only checks that the code can be parsed and compiled.

### Full execution

```bash
python3 setup.py
```

Observed stages, in order:

```
Twenty CRM Local Setup Automation
Checking project directory
Project structure check: OK

Checking prerequisites
python3: available
node: available
yarn: available
docker: available

Node.js: v24.5.0
Yarn: 4.13.0
Docker: Docker version 29.6.2

Node.js version check: OK
Yarn version check: OK

Docker daemon: available

Installing project dependencies
Dependencies installed successfully.

Starting local Twenty server
Twenty server detected on http://localhost:2020

Waiting for Twenty to become healthy
Health check 1/12...
Twenty server is healthy.
Status: running (healthy)

Starting Twenty development server
```

## 14. Browser/Application Verification

Once the development server started, the Twenty development CLI requested re-authentication for the local remote. I accepted the re-authentication prompt, which opened a browser login page. The local Twenty application opened successfully in the browser, and the **Companies** list was visible, confirming the application was running and reachable end-to-end.

The development server was then stopped manually with `Ctrl+C`.

## 15. Testing and Validation

### Lint

```bash
yarn lint
```

Result:

```
Found 0 warnings and 0 errors.
Finished in 7ms on 11 files with 1 rules using 8 threads.
```

### Typecheck

```bash
yarn typecheck
```

Completed without any errors reported.

### Unit tests

```bash
yarn test:unit
```

Result:

```
Test Files 1 passed
Tests 1 passed
```

Test covered: `application identifiers` → `should expose the application metadata constants`

### Full test suite (including integration)

```bash
yarn test
```

Observed development/build workflow during the test run:

```
[dev] Checking server...
[dev] Building manifest...
[dev] Building application files...
[dev] Running typecheck...
[dev] Computing metadata plan...
[dev] Registering application...
[dev] Uploading 5 files...
[dev] Syncing manifest...
[dev] Generating API client...
```

Integration test results:

```
Test Files 1 passed
Tests 2 passed
```

Tests included:

1. **App installation** — `should find the installed app in the applications list`
2. **CoreApiClient** — `should support CRUD on standard objects`

The CRUD integration test creates a `Note` using `CoreApiClient` and then destroys it, confirming that the application's API integration works correctly against a live Twenty instance.

## 16. Warnings Encountered

During `yarn install`, `yarn twenty docker:start`/`docker:status`, and testing, the following non-fatal warnings appeared:

- **Yarn peer dependency warnings** (`YN0002`, `YN0086`) — related to a missing `monaco-editor` peer dependency requested by `twenty-ui`, and some peer dependencies not being exactly matched. Installation still completed successfully.
- **Vite/Vitest configuration warnings** during test runs, concerning:
  - `configLoader: 'native'`
  - ESM syntax used in a CommonJS configuration
  - `vite-tsconfig-paths`
  - Future Vite configuration behavior changes

These were all displayed as **warnings**, not test failures — all test suites still passed.

## 17. Git Workflow and Validation

Files created for Task 3:

- `TASK-3.md`
- `setup.py`

Both files were added on the `abdulrahman-task-3` branch. The Git diff was validated with:

```bash
git diff --check
```

**Result:** No errors.

The changes were also staged and reviewed with:

```bash
git diff --cached --stat
```

Expected staged files:

```
TASK-3.md
setup.py
```

### Normal Git workflow followed

```
working tree
   ↓
git add
   ↓
staged changes
   ↓
review with git diff --cached
   ↓
commit
   ↓
push
```

*Note: This report does not claim that the final Task 3 changes have already been pushed to the remote — only that they were validated at the staging/diff-review stage described above.*

## 18. Results

- ✅ Twenty CRM project structure understood and documented.
- ✅ Local development environment (Node.js, Yarn, Docker) validated against project requirements.
- ✅ Dependencies installed successfully (with non-blocking warnings).
- ✅ Local Twenty server started via Docker and confirmed healthy.
- ✅ Python automation script (`setup.py`) written, syntax-validated, and executed successfully end-to-end.
- ✅ Application verified manually in the browser (Companies list visible).
- ✅ Lint, typecheck, unit tests, and integration tests all passed.
- ✅ Git changes staged and validated on the `abdulrahman-task-3` branch.

## 19. What I Learned

- **Environment validation**: Checking tool availability and versions before running anything saves time by failing fast with a clear error instead of a confusing failure mid-process.
- **Dependency management**: Yarn warnings (like unmet peer dependencies) don't always mean installation failed — it's important to distinguish warnings from actual errors.
- **Docker**: Starting a container is not the same as the service inside it being ready; health checks close that gap.
- **Health checks**: Polling with a wait/retry pattern is a simple but effective way to synchronize automation with an external process that takes time to become ready.
- **CLI tooling**: Twenty's CLI groups commands logically (dev, docker, remote), which made it easier to understand the tool's capabilities from `--help` output alone.
- **Automation**: Wrapping a multi-step manual process into a single Python script reduces the chance of human error and makes onboarding/repeating the setup much faster.
- **Subprocess execution**: Running and capturing output from external CLI tools (`node`, `yarn`, `docker`) from Python is a core DevOps automation skill.
- **Error handling**: Handling `Ctrl+C` gracefully (via `KeyboardInterrupt`) makes a long-running automation script more pleasant and safer to use.
- **Testing**: Lint, typecheck, unit, and integration tests each catch different classes of issues, and running all of them gives more confidence than any single check alone.
- **Git workflow**: Reviewing staged changes with `git diff --cached` before committing helps catch unintended changes before they're committed.
- **Documentation**: Writing this report reinforced how important it is to document not just *what* was done, but *why* each step matters.

## 20. Task 3 Completion Checklist

- [x] Reviewed and understood the Twenty CRM project structure
- [x] Reviewed application config, default role, navigation, and page layout files
- [x] Verified local development environment (Node.js, Yarn, Docker versions)
- [x] Ran `yarn install` and reviewed warnings
- [x] Started the local Twenty server via Docker
- [x] Verified server health via `docker:status`
- [x] Inspected the Twenty CLI's available commands
- [x] Wrote `setup.py` automation script
- [x] Validated `setup.py` syntax with `py_compile`
- [x] Ran `setup.py` end-to-end successfully
- [x] Verified the running application in the browser
- [x] Ran lint, typecheck, unit tests, and integration tests
- [x] Staged and reviewed changes with Git
- [x] Documented the entire process in `TASK-3.md`

## 21. Conclusion

Task 3 involved setting up the Twenty CRM project locally, understanding how its custom application architecture (navigation → layout → widget → front component) fits together, and automating the local setup process using a Python script. The automation script successfully validated prerequisites, installed dependencies, started the Twenty server via Docker, waited for it to become healthy, and launched the development server. All lint, typecheck, unit, and integration tests passed, and the changes were validated through the standard Git workflow on the `abdulrahman-task-3` branch. This task strengthened my practical understanding of environment automation, Docker health checks, and end-to-end validation as part of a DevOps workflow.
