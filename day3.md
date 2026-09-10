# Day 3 – Local CRM Setup and Python Automation

---

## 1. Executive Summary & Objective

The objective of the Day 3 DevOps Internship task is to:
1. Clone the official repository locally (`https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git`).
2. Explore the project structure and understand the core services and main components.
3. Set up and run the Twenty CRM application locally.
4. Create a Python automation script (`scripts/automate setup.py`) to automate setup, prerequisite checks, and server startup without using shell scripts (`.sh`).
5. Create a branch using my name (`bkkrish007`), commit changes, push to the official shared repository, and open a Pull Request.
6. Document setup, automation, issues faced, resolutions, and include a Loom demonstration video.

---

## 2. Environment & Repository Information

| Environment Attribute | Configuration / Version |
| :--- | :--- |
| **Operating System** | macOS |
| **Official Repository** | `https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git` |
| **Official Repository Owner** | `PearlThoughts-Intern-DevOps` |
| **Local Folder** | `devops-crm-project` |
| **GitHub Username** | `BK-KRISH` |
| **Working Branch** | `bkkrish007` |
| **Node.js (.nvmrc)** | `24.5.0` (Active: `v24.5.0`) |
| **Yarn** | `4.13.0` |
| **Python** | `3.14.3` |
| **Docker** | Installed & Required for Local Server |

### Remote Verification & Git Identity
```bash
git remote -v
# Output:
# origin https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git (fetch)
# origin https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git (push)

git config --global user.name
# Output: BK-KRISH

git config --global user.email
# Output: baranikrishnan007@gmail.com
```

---

## 3. Project Structure & Analysis

The repository structure was explored to understand the core components, configuration files, and services. Key observed paths include:

- `.github/` – GitHub Actions workflows and CI configurations.
- `.twenty/` – Core Twenty CRM application configurations and server components.
- `.yarn/` – Yarn 4 Berry modern package manager binaries and cache settings.
- `public/` – Static web assets.
- `src/` – Main application source code and UI components.
- `scripts/` – Location for setup and automation scripts (containing `automate setup.py`).
- `package.json` – Node.js project manifest defining workspace dependencies and scripts.
- `README.md`, `SETUP.md`, `AGENTS.md`, `CHANGELOG.md` – Project documentation and guidelines.
- `.nvmrc` – Node.js version lock file requiring `24.5.0`.
- `.yarnrc.yml` & `yarn.lock` – Yarn Berry configuration and exact dependency tree lock file.
- `tsconfig.json` – TypeScript compilation rules.
- `vitest.config.ts` – Testing suite configuration.

---

## 4. Local Environment Setup & Verification

### Step 1 – Repository Cloning & Branch Creation
```bash
cd ~/Desktop/Internship
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
git checkout -b bkkrish007
```

### Step 2 – Prerequisites Verification
```bash
cat .nvmrc
node -v
yarn --version
python3 --version
docker --version
```
*Confirmed active Node.js version matches `.nvmrc` (`24.5.0`), Yarn version is `4.13.0`, Python is `3.14.3`, and Docker is installed.*

### Step 3 – Installing Dependencies
```bash
yarn install
```
*Log details:* Yarn processed dependencies and executed an `esbuild` build step. Warnings were outputted regarding peer dependencies:
- `YN0002: my-app@workspace:. doesn't provide monaco-editor, requested by twenty-ui.`
- `YN0086: Some peer dependencies are incorrectly met by your project.`
*Note: These peer dependency warnings did not prevent installation completion.*

### Step 4 – Starting Twenty Server & Dev Environment
Start the local Twenty Docker server:
```bash
yarn twenty docker:start
```
*Output:* `Twenty server detected on http://localhost:2020`

Start the development server:
```bash
yarn twenty dev
```
*Sync output:*
```text
Using remote "local"
Building manifest
Successfully built manifest
Existing app registration found
Application installed
Successfully uploaded 4 files
Manifest checksums set
Manifest saved to output directory
Computing metadata plan
Syncing manifest
No metadata changes
✓ Synced

Overall Status: ✓ Synced
Application Initialization: ✓ done
Resources Build: ✓ done
Resources Upload: ✓ done
Manifest Build: ✓ done
Application Synchronization: ✓ done
Api Client Generation: ✓ done
Entities ✓ 7 synced
```
*Verification:* Navigated to `http://localhost:2020` in the browser, confirming that the CRM Companies page loaded successfully.

---

## 5. Python Automation (`scripts/automate setup.py`)

As required, shell scripts (`.sh`) were avoided in favor of a Python automation script located at:
`scripts/automate setup.py`

### Script Objectives & Implementation
The script uses standard library modules (`subprocess`, `shutil`, `re`, `sys`, `pathlib.Path`) to handle execution and validation safely:
1. **Prerequisite Checks:**
   - Verifies `node` command availability.
   - Reads `.nvmrc` file to ensure the running Node.js version matches `24.5.0`.
   - Verifies `yarn` availability.
   - Verifies `docker` CLI availability and checks if the Docker daemon is active (`docker info`).
   - Aborts execution via `fail()` with descriptive error messages if any check fails.
2. **Automated Command Execution:**
   - `yarn install`
   - `yarn twenty docker:start`
   - `yarn twenty dev`

### Script Source Code (`scripts/automate setup.py`)
```python
import re
import shutil
import subprocess
import sys
from pathlib import Path


def fail(message):
    print(f"\nERROR: {message}")
    sys.exit(1)


def run_command(command):
    print(f"\nRunning: {' '.join(command)}")
    result = subprocess.run(command)

    if result.returncode != 0:
        fail(f"Command failed: {' '.join(command)}")


def check_command(command, name):
    if shutil.which(command) is None:
        fail(f"{name} is not installed or not available in PATH.")


def check_node():
    check_command("node", "Node.js")

    nvmrc = Path(".nvmrc")

    if not nvmrc.exists():
        fail(".nvmrc file not found.")

    required_version = nvmrc.read_text().strip()

    result = subprocess.run(
        ["node", "--version"],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        fail("Unable to determine the Node.js version.")

    installed_version = result.stdout.strip()
    match = re.fullmatch(r"v(\d+\.\d+\.\d+)", installed_version)

    if not match:
        fail(f"Unable to parse Node.js version: {installed_version}")

    print(f"Node.js required: {required_version}")
    print(f"Node.js installed: {installed_version}")

    if match.group(1) != required_version:
        fail(
            f"Node.js version mismatch. "
            f"Required {required_version}, "
            f"but found {match.group(1)}."
        )

    print("Node.js version check: OK")


def check_yarn():
    check_command("yarn", "Yarn")

    result = subprocess.run(
        ["yarn", "--version"],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        fail("Unable to determine the Yarn version.")

    print(f"Yarn version: {result.stdout.strip()}")
    print("Yarn check: OK")


def check_docker():
    check_command("docker", "Docker")

    result = subprocess.run(
        ["docker", "info"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    if result.returncode != 0:
        fail("Docker is installed, but the Docker daemon is not running.")

    print("Docker check: OK")


def check_prerequisites():
    print("\nChecking prerequisites...")

    check_node()
    check_yarn()
    check_docker()

    print("\nAll required prerequisites are available.")


def main():
    print("Starting local CRM setup...")

    check_prerequisites()

    run_command(["yarn", "install"])
    run_command(["yarn", "twenty", "docker:start"])

    print("\nStarting the development server...")
    run_command(["yarn", "twenty", "dev"])


if __name__ == "__main__":
    main()
```

### Syntax Validation
Syntax was validated prior to running:
```bash
python3 -m py_compile "scripts/automate setup.py"
```
*(Completed with code 0 / no errors).*

---

## 6. Automation Testing & Validation Scenarios

The script was intentionally tested under failure states to verify error-handling reliability before running in a clean environment.

### Scenario 1 – Node.js Version Mismatch
- **Condition:** Node.js active version was `v22.23.0`, whereas `.nvmrc` required `24.5.0`.
- **Execution Output:**
  ```text
  Node.js required: 24.5.0
  Node.js installed: v22.23.0

  ERROR: Node.js version mismatch. Required 24.5.0, but found 22.23.0.
  ```
- **Validation Outcome:** Script cleanly terminated without attempting `yarn install`.
- **Resolution:**
  ```bash
  nvm use 24.5.0
  node -v # Returns v24.5.0
  ```

### Scenario 2 – Docker Daemon Not Running
- **Condition:** Docker desktop/daemon was shut down.
- **Execution Output:**
  ```text
  Node.js version check: OK
  Yarn check: OK

  ERROR: Docker is installed, but the Docker daemon is not running.
  ```
- **Validation Outcome:** Script correctly identified that `docker info` returned non-zero exit code and aborted.
- **Resolution:** Started Docker Desktop daemon.

### Scenario 3 – Successful Automation Execution
- **Command Executed:**
  ```bash
  python3 "scripts/automate setup.py"
  ```
- **Output:**
  ```text
  Starting local CRM setup...

  Checking prerequisites...
  Node.js required: 24.5.0
  Node.js installed: v24.5.0
  Node.js version check: OK
  Yarn version: 4.13.0
  Yarn check: OK
  Docker check: OK

  All required prerequisites are available.

  Running: yarn install
  ...
  Running: yarn twenty docker:start
  ...
  Starting the development server...
  Running: yarn twenty dev
  ...
  Overall Status: ✓ Synced
  ```
- **Result:** Successfully automated environment validation, container start, and dev server synchronization.

---

## 7. Issues Faced & Resolutions

### 1. Local Folder vs. Official Repository Naming Confusion
- **Issue:** An earlier local attempt was organized inside a folder named `devops-crm-day3`, causing ambiguity regarding remote sync and repository structure.
- **Resolution:** Removed temporary working folders and cloned fresh directly into `devops-crm-project` matching the official repository.
  ```bash
  cd ~/Desktop/Internship
  rm -rf devops-crm-day3 devops-crm-project
  git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
  cd devops-crm-project
  ```

### 2. Python Script Filename Execution Syntax Error
- **Issue:** Running `python3 scripts/automate setup.py` caused Python to treat `scripts/automate` as the target file due to the unquoted space in the filename.
- **Resolution:** Enclosed path in quotes for both execution and compilation:
  ```bash
  python3 -m py_compile "scripts/automate setup.py"
  python3 "scripts/automate setup.py"
  ```

### 3. Personal Repository vs. Shared Organization Push
- **Issue:** Pushing initially targeted personal repository `BK-KRISH/devops-crm-project`. However, internship requirements specify that the branch and Pull Request must be in the official shared repository.
- **Resolution:** Re-verified remote `origin` to ensure it points to `https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git`.

### 4. Organization Push Permission Denial (HTTP 403 / Authentication Failure)
- **Issue:** Git push returned permission errors:
  `remote: Permission to PearlThoughts-Intern-DevOps/devops-crm-project.git denied to BK-KRISH.`
  `fatal: unable to access ... The requested URL returned error: 403`
- **Resolution:** Checked invitation status on GitHub for `PearlThoughts-Intern-DevOps` organization, accepted the org invitation, and completed GitHub Web/Device authentication to link Keychain credentials with write permissions to the organization repository.

### 5. GitHub CLI (`gh`) Availability
- **Issue:** `gh auth status` returned `zsh: command not found: gh`.
- **Resolution:** Proceeded with standard Git commands and GitHub web UI for repository authentication and PR creation.

---

## 8. Git Workflow & Submission Status

### Commands Prepared for Staging and Committing:
```bash
git status
git add day3.md "scripts/automate setup.py"
git commit -m "Add Day 3 Python automation and documentation"
```

### Remote Push Command:
```bash
git push -u origin bkkrish007
```

### Pull Request & Official Submission Status:
- **Source Branch:** `bkkrish007`
- **Target Repository & Branch:** `PearlThoughts-Intern-DevOps/devops-crm-project:main`
- **Pull Request Status:** **Pending** *(Will be submitted on GitHub once branch push is finalized).*

---

## 9. Demonstration Video (Loom)

- **Loom Video Link:** [https://www.loom.com/share/67be2b0cb14841a093b0294e5d4a5243](https://www.loom.com/share/67be2b0cb14841a093b0294e5d4a5243)
- **Demonstration Highlights:**
  - Local repository setup and environment inspection.
  - Node.js, Yarn, and Docker prerequisite verification.
  - Execution of `scripts/automate setup.py`.
  - Handling of prerequisite errors.
  - Synchronization of Twenty CRM application on `http://localhost:2020`.

---

## 10. Conclusion

Day 3 tasks were completed with full local setup verification and automated execution:
- Successfully cloned and inspected `PearlThoughts-Intern-DevOps/devops-crm-project`.
- Installed and synchronized Twenty CRM dependencies via Node.js v24.5.0, Yarn 4.13.0, and Docker.
- Implemented `scripts/automate setup.py` in Python to validate prerequisites and run local servers automatically.
- Tested failure scenarios (Node version mismatch, Docker daemon down) to ensure robust error handling.
- Documented step-by-step setup, troubleshooting, and Git workflow. Official repository branch push and Pull Request are prepared and marked as Pending completion.
