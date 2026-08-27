# Twenty CRM App — Local Setup & Automation

## 1. Project Overview

`devops-crm-project` is a Twenty CRM app/extension. The app is developed locally using Node.js, Yarn 4, Docker, and the Twenty CLI.

The setup consists of:
1. Running the local Twenty CRM server using Docker.
2. Running and synchronizing the app using the Twenty CLI.

## 2. Manual Setup

**Step 1 — Clone the repository**
```
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
```

**Step 2 — Set up Node.js**

The required Node.js version is specified in `.nvmrc` as `24.5.0`.
```
nvm install
nvm use
```
Verify: `node -v`

**Step 3 — Set up Yarn 4**
```
corepack enable
yarn --version
```
Installed version: `4.13.0`

**Step 4 — Install dependencies**
```
yarn install
```
The installation completed successfully with a peer dependency warning related to `monaco-editor`.

**Step 5 — Start Twenty CRM**
```
yarn twenty docker:start
```
This starts the local Twenty server using Docker.
Server: `http://localhost:2020`

**Step 6 — Start and synchronize the app**
```
yarn twenty dev
```
The first run required authentication. After re-authentication, the app was successfully registered, installed, uploaded, and synchronized.

Final status:
- Overall Status: ✓ Synced
- Application Initialization: ✓ done
- Resources Build: ✓ done
- Resources Upload: ✓ done
- Manifest Build: ✓ done
- Application Synchronization: ✓ done
- Api Client Generation: ✓ done
- Entities: 7 synced

**Step 7 — Verify the application**

Open: `http://localhost:2020`

Development credentials:
- Email: `tim@apple.dev`
- Password: `tim@apple.dev`

## 3. Python Automation

The setup process was automated using Python as required by the task. No shell script (`.sh`) was used.

Automation script: `setup_project.py`
Run it using:
```
python3 setup_project.py
```

**Automation flow:**
```
Verify Project
      |
      v
Check Node / Yarn / Docker
      |
      v
Check Node Version
      |
      v
Check Docker
      |
      v
Install Dependencies
      |
      v
Check Twenty Server
      |
      v
Start Server if Required
      |
      v
Wait for Port 2020
      |
      v
Run "yarn twenty dev"
      |
      v
Application Synchronized
```

**What the script does:**
1. Verifies the project directory.
2. Checks that Node.js, Yarn, and Docker are installed.
3. Checks the Node.js version against `.nvmrc`.
4. Displays environment versions.
5. Checks that the Docker daemon is running.
6. Runs `yarn install`.
7. Checks whether the Twenty server is already running.
8. Starts Twenty if it is not running.
9. Waits for port 2020 to become available.
10. Runs `yarn twenty dev`.
11. Displays the final application status and URL.

**Design choices:**
- **No hard-coded paths** — the script detects its own project directory.
- **Live output** — installation and development commands show their output directly in the terminal.
- **Server check** — the script avoids unnecessarily starting Twenty when it is already running.
- **Timeout** — the script waits for the Twenty server with a defined timeout.
- **Fail-fast** — errors stop the process with a clear message.

## 4. Issues Faced and Solutions

**Issue 1 — Node.js version mismatch**
Problem: The system initially had Node.js v22.23.2, while the project required v24.5.0.
Solution: Used nvm to install and activate the version specified in `.nvmrc`.

```
nvm install
nvm use
```

**Issue 2 — Yarn not found**
Problem: Yarn was initially unavailable.
Solution: Enabled Corepack (`corepack enable`), which provided the required Yarn 4 version.

**Issue 3 — Yarn peer dependency warning**
Problem: `yarn install` reported a peer dependency warning for `monaco-editor`.
Solution: The installation completed successfully and the application ran correctly, so no unnecessary dependency changes were made.

**Issue 4 — Twenty authentication timeout**
Problem: The first `yarn twenty dev` attempt timed out during authentication.
Solution: The command was run again, and the local Twenty remote was successfully re-authenticated. The application then synchronized successfully.

**Issue 5 — GitHub write access**
Problem: Write access to the organization repository was not initially available.
Solution: The team requested members to fill in the access Excel sheet before the deadline. Write access will be provided after the list is finalized. Once access is provided, the changes will be pushed to the personal branch and a Pull Request will be created in the original repository.

## 5. Git Workflow

After write access is provided:

Create a branch:

```
git checkout -b Harish
```
Check the branch:

```
git branch --show-current
```
Review changes:

```
git status
git diff
```
Add changes:

```
git add setup_project.py
git add SETUP.md
```
Commit:
```
git commit -m "Add Python automation for local setup"
```
Push:
```
git push -u origin Harish
```
Then create a Pull Request from your branch to the repository's main branch.

## 6. Pull Request Summary

**Changes:**
- Added Python automation for local setup.
- Added prerequisite checks.
- Added Node.js version validation.
- Automated dependency installation.
- Added Docker and Twenty server checks.
- Added Twenty server readiness checking.
- Added application startup and synchronization.
- Documented setup steps and troubleshooting.

**Testing:**
The application was successfully:
- Installed locally.
- Started using the Twenty Docker server.
- Synchronized using `yarn twenty dev`.
- Verified through `http://localhost:2020`.

## 7. Loom Demonstration

The Loom video should demonstrate:
1. Repository and project structure.
2. Prerequisites.
3. `setup_project.py`.
4. Running the automation: `python3 setup_project.py`
5. Twenty authentication, if required.
6. Successful application synchronization.
7. Application running at `http://localhost:2020`.
8. Git branch and changes.
9. Pull Request creation.

Loom URL: [`link`](https://www.loom.com/share/8cdcac650fc442dd8a43c85c92b3a952)

## 8. Final Result

The local Twenty CRM environment was successfully configured and the application was synchronized.

**Final status:**
- Twenty CRM: `http://localhost:2020`
- Application: ✓ Synced
- Entities: 7 synced
- Automation: `setup_project.py`

The setup can be started using:
```
python3 setup_project.py
```

