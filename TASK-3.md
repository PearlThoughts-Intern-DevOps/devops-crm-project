# Task 3 - Local Setup Automation

## Objective

The objective of this task was to clone the DevOps CRM project, set it up locally, understand the project structure, and automate the local setup and startup process using Python.

## Environment

The project was developed and tested using:

- Windows 11
- WSL2
- Ubuntu 24.04.1 LTS
- Node.js 24.5.0
- Yarn 4.13.0
- Docker Desktop
- Twenty CRM
- Python 3

## Manual Setup

The project was first cloned from the provided GitHub repository.

The basic setup steps were:

```bash
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
```

Node.js 24.5.0 was installed using NVM because the project specifies this version in `.nvmrc`.

Dependencies were installed using:

```bash
yarn install
```

The local Twenty server was started using:

```bash
yarn twenty docker:start
```

The application was then started and synchronized using:

```bash
yarn twenty dev
```

The application was successfully synchronized with the local Twenty server.

## Python Automation

A Python script was created at:

```text
scripts/setup.py
```

The script automates the main local setup process.

It performs the following steps:

1. Checks whether Node.js, Yarn, and Docker are available.
2. Installs project dependencies using `yarn install`.
3. Starts the local Twenty server.
4. Checks whether the Twenty server is responding on port 2020.
5. Starts the Twenty development environment using `yarn twenty dev`.

The script uses Python's `subprocess` module to execute the required terminal commands.

It also checks command return codes and stops the setup process if a command fails.

## Running the Automation

From the project root, run:

```bash
python3 scripts/setup.py
```

The script will perform the setup and start the Twenty development environment.

Press `Ctrl+C` to stop the development process.

## Issues Faced

### 1. Windows path issue

While running the project directly from the Windows filesystem, the Twenty CLI generated resource paths containing Windows backslashes.

For example:

```text
src\front-components\main-page.mjs
```

The Twenty server rejected these paths with an error indicating that resource paths must not contain backslashes.

### Solution

The project was cloned into the WSL2 Linux filesystem:

```text
/home/neooo/projects/devops-crm-project
```

Running the project from the Linux filesystem generated forward-slash paths and resolved the resource path issue.

No modification to the Twenty SDK was required.

### 2. Docker was not initially available inside WSL

Docker commands were initially unavailable from the Ubuntu WSL environment because Docker Desktop WSL integration was not enabled for the Ubuntu distribution.

### Solution

Docker Desktop WSL2 integration was enabled for the Ubuntu distribution.

After that, Docker commands were available from WSL.

### 3. Python command

The Ubuntu environment did not provide the `python` command by default.

The available command was:

```bash
python3
```

Therefore, the automation script is executed using:

```bash
python3 scripts/setup.py
```

## Verification

The automation script was tested successfully.

The application completed synchronization with the local Twenty server:

```text
Successfully uploaded 4 files
✓ Synced
Overall Status: ✓ Synced
Entities ✓ 7 synced
```

## Loom Demonstration

A Loom video demonstrating the setup process and Python automation will be added before submission.

## Branch

The changes are being developed on the following branch:

```text
neooo
```
