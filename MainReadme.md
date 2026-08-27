# Twenty CRM App – Local Setup & Automation

This project is a Twenty CRM application built using TypeScript, React, Node.js, Yarn, and the Twenty SDK.

The objective of this task was to run the application locally, troubleshoot environment/setup issues, and create a Python script to automate the local setup and startup process.

## Setup Summary

The application was successfully configured and tested on **macOS**.

The final working environment uses:

* Node.js `24.5.0`
* Yarn `4.13.0`
* Twenty SDK `2.35.1`
* Docker CLI with **Colima** as the Docker runtime
* Python 3 for automation

The application is available locally at:

```text
http://localhost:2020
```

---

# Issues Faced and Resolutions

## 1. Node.js Version Mismatch

### Issue

The system initially had Node.js `v26.5.1`, while the project requires Node.js `24.5.0`, as specified in `.nvmrc`.

### Resolution

The required Node.js version was configured using NVM.

After switching versions:

```text
Node.js: v24.5.0
```

The project was then compatible with the required Node.js version.

---

## 2. Yarn Was Not Available Initially

### Issue

The `yarn` command was initially unavailable.

The project requires Yarn `4.13.0`, which is specified in `package.json`.

### Resolution

Corepack was enabled and the project-specific Yarn version was activated.

Verified version:

```text
Yarn: 4.13.0
```

The project dependencies were then installed successfully using:

```bash
yarn install
```

---

## 3. Docker Desktop Credential Helper Error

### Issue

When starting the Twenty server, the following error occurred:

```text
docker: error getting credentials - err: exec: "docker-credential-desktop": executable file not found in $PATH
```

### Cause

The Docker configuration was still configured to use the Docker Desktop credential helper:

```text
credsStore: desktop
```

However, the active Docker runtime was **Colima**.

### Resolution

The Docker Desktop credential-store configuration was removed while keeping the Colima Docker context.

After the configuration was corrected, Docker was able to communicate with the Colima runtime successfully.

---

## 4. Twenty Server Startup

After resolving the Docker credential issue, the Twenty server started successfully using:

```bash
yarn twenty docker:start
```

The server completed:

* PostgreSQL startup
* Database initialization
* Database migrations
* Cache flushing
* Workspace data seeding
* Cron job registration

The server was successfully available at:

```text
http://localhost:2020
```

---

# Automation

A Python script named `setup.py` was created to automate the local setup and startup process.

The script performs checks for:

* Python
* Node.js
* Yarn
* Docker
* Docker engine availability
* Required project files

It also:

1. Installs project dependencies.
2. Starts the Twenty server.
3. Waits for the local server to become available.
4. Starts the Twenty development server.
5. Displays clear success, warning, and error messages.
6. Stops execution when a required dependency or setup step fails.

Run the automation with:

```bash
python3 setup.py
```

---

# Verification

The following commands can be used to verify the project:

```bash
yarn lint
yarn typecheck
yarn test:unit
yarn test
```

---

# Final Result

The Twenty CRM application was successfully run locally on macOS.

The major environment and Docker configuration issues were identified and resolved, and the successful manual setup was converted into a Python-based automation script.

The application is accessible at:

```text
http://localhost:2020
```

## Successful Startup Flow

```text
Environment Checks
       ↓
Dependency Validation
       ↓
Install Dependencies
       ↓
Start Twenty Server
       ↓
Wait for localhost:2020
       ↓
Start Twenty Development Server
       ↓
Application Running
```
