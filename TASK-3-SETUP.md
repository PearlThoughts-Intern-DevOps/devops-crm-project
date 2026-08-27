# Task 3 - Local Setup and Python Automation

## Objective

The objective of this task was to set up the project locally, understand the project structure, run the application, create a Python script to automate the setup and startup process, and document the issues faced during the process.

## 1. Repository Setup

* Forked the project repository to my GitHub account.
* Cloned the forked repository to my local Windows system.
* Explored the project documentation and source structure.
* Created a separate branch for this task:

```text
tannu-task-3
```

## 2. Project Structure

The main project structure contains:

```text
devops-crm-project/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       ├── cd.yml
│       └── publish.yml
├── public/
├── src/
│   ├── constants/
│   ├── front-components/
│   ├── navigation-menu-items/
│   ├── page-layouts/
│   └── __tests__/
├── package.json
├── README.md
├── SETUP.md
├── tsconfig.json
└── vitest.config.ts
```

### Main Components

* `src/front-components/` - Front-end components.
* `src/page-layouts/` - Page layout configuration.
* `src/navigation-menu-items/` - Navigation menu configuration.
* `src/constants/` - Application constants and universal identifiers.
* `src/__tests__/` - Unit and integration tests.
* `.github/workflows/` - CI/CD and publishing workflows.
* `package.json` - Project dependencies and scripts.
* `SETUP.md` - Local setup instructions.

## 3. Local Setup

The setup instructions provided in `SETUP.md` were followed.

### Install Dependencies

```text
yarn install
```

### Start the Local Twenty Server

```text
yarn twenty docker:start
```

### Check Server Status

```text
yarn twenty docker:status
```

The Twenty server was successfully started and verified as healthy at:

```text
http://localhost:2020
```

### Start the Development Environment

```text
yarn twenty dev
```

The default development credentials provided in `SETUP.md` were used to log in to the local Twenty instance.

## 4. Python Automation

A Python script named `setup.py` was created to automate the local setup and startup process.

The script performs the following steps:

1. Checks whether Node.js is installed.
2. Checks whether Yarn is installed.
3. Checks whether Docker is installed.
4. Installs project dependencies.
5. Checks whether the local Twenty server is already running.
6. Starts the Twenty Docker environment if it is not running.
7. Waits for the Twenty server to become available.
8. Starts the Twenty development environment.

No shell script (`.sh`) was used for the automation.

## 5. Issues Faced and Solutions

### Issue 1 - Yarn Command Not Found from Python

Initially, the Python script attempted to execute:

```text
yarn install
```

This resulted in:

```text
FileNotFoundError: [WinError 2]
```

On Windows, Yarn is executed through `yarn.cmd`.

The Python script was updated to use `yarn.cmd` when executing Yarn commands.

After this change, the dependency installation completed successfully.

### Issue 2 - Twenty CLI Authentication Timeout

While running:

```text
yarn twenty dev
```

the Twenty CLI requested browser-based authentication.

The first authentication attempt timed out after 120 seconds.

The local remote was re-authenticated using:

```text
yarn twenty remote:add
```

After completing the browser authorization, the CLI successfully reported:

```text
Re-authenticated "local".
```

### Issue 3 - Front Component Synchronization Error

After successful authentication, the Twenty CLI successfully built the manifest and registered and installed the application.

However, application synchronization reported:

```text
INVALID_FRONT_COMPONENT_INPUT
Resource path must not contain backslashes
```

The error was related to generated Windows paths such as:

```text
.twenty\output\src\front-components\main-page.mjs
```

The relevant source files were inspected, including:

* `src/front-components/main-page.tsx`
* `src/application-config.ts`
* `src/page-layouts/main-page.page-layout.ts`

No hard-coded Windows resource paths were found in these source files.

The generated `.twenty` directory is already excluded through `.gitignore`.

## 6. Automation Verification

The Python script syntax was checked using:

```text
python -m py_compile setup.py
```

The automation was then tested using:

```text
python setup.py
```

The following steps were successfully verified:

* Node.js detection
* Yarn detection
* Docker detection
* Dependency installation
* Twenty server availability check
* Twenty CLI authentication
* Manifest build
* Application registration
* Application installation

## 7. Verification Commands

The Twenty server status can be checked using:

```text
yarn twenty docker:status
```

The project also provides the following validation commands:

```text
yarn lint
yarn typecheck
yarn test:unit
yarn test
```

## 8. Summary

The project was cloned, explored, and started locally using Docker and the Twenty CLI.

A Python-based automation script was created to simplify the local setup and startup process without using a shell script.

During the setup, a Windows-specific Yarn execution issue and a Twenty CLI authentication timeout were encountered and addressed. The application was successfully registered and installed, but a front-component synchronization issue related to Windows path separators was encountered and documented.
