# Task 3 - CRM Local Setup and Python Automation

## Objective

Set up the CRM application locally and create a Python script to automate the local setup and startup process without using a shell script.

## Project

Repository:
https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project

The project is a TypeScript/JavaScript application using Node.js, Yarn, Docker, and the Twenty platform.

## Environment

- Ubuntu 24.04.4 LTS on WSL
- Node.js 24.5.0
- npm 11.5.1
- Yarn 4.13.0
- Docker 29.7.2
- Docker Compose 5.4.0

## Manual Setup

1. Cloned the CRM project repository.
2. Verified the required Node.js version using `.nvmrc`.
3. Installed project dependencies using `yarn install`.
4. Started the local Twenty Docker environment using `yarn twenty docker:start`.
5. Applied and synchronized the application using `yarn twenty apply`.
6. Opened the application at `http://localhost:2020`.
7. Logged in using the default development credentials provided by the project setup instructions.

## Project Structure

Important project components include:

- `.github/` - GitHub-related configuration and workflows.
- `public/` - Public/static assets.
- `src/` - Main application source code.
- `package.json` - Project metadata, scripts, and dependencies.
- `yarn.lock` - Locked Yarn dependency versions.
- `.nvmrc` - Required Node.js version.
- `.yarnrc.yml` - Yarn configuration.
- `SETUP.md` - Local setup instructions.

## Python Automation

The automation script is `task3/setup_crm.py`.

The script:

1. Verifies the CRM project directory.
2. Checks Node.js, npm, Yarn, and Docker.
3. Displays dependency versions.
4. Validates Node.js against `.nvmrc`.
5. Verifies the Docker Engine.
6. Runs `yarn install`.
7. Starts or verifies the Twenty Docker environment.
8. Verifies the `twenty-app-dev` container.
9. Runs `yarn twenty apply`.
10. Displays the local application URL.

The automation is written in Python and does not use a shell script.

## Testing

The Python automation was tested successfully.

Final result:

    ✓ Synced My app (5 files)
    [OK] Twenty application synchronized successfully.
    [OK] Setup complete. Open http://localhost:2020 in your browser.

## Result

The CRM application was successfully set up and run locally, and the setup and synchronization process was automated using Python.

