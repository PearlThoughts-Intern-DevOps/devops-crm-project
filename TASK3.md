# Task 3 - Automate Local CRM Project Setup

## Objective

The objective of this task was to set up the CRM application locally and automate the setup and startup process using Python instead of a shell script.

## Project Understanding

The project is a Twenty App based application built using TypeScript/React and the Twenty SDK.

Important project files and directories include:

- `src/` - Application source code
- `public/` - Public assets
- `package.json` - Project configuration, scripts, and dependencies
- `yarn.lock` - Locked dependency versions
- `SETUP.md` - Local setup instructions
- `.github/` - GitHub workflow configuration

## Manual Setup

The initial manual setup involved:

1. Cloning the repository.
2. Installing the required Node.js and Yarn environment.
3. Installing dependencies using `yarn install`.
4. Starting the local Twenty server using `yarn twenty docker:start`.
5. Running the application using `yarn twenty dev`.
6. Verifying the application at `http://localhost:2020`.

## Python Automation

Created `run_project.py` to automate the local setup process.

The script:

1. Verifies the project root.
2. Checks required tools such as Node.js, Yarn, and Docker.
3. Displays dependency versions.
4. Installs project dependencies.
5. Checks whether Docker is running.
6. Starts the local Twenty server when required.
7. Checks the health of the local server.
8. Starts the application development/synchronization process.
9. Displays the local application URL.
10. Handles errors and exits when a required step fails.

## Port and Health Check

The script checks port `2020` before starting the local server and performs a health check against:

`http://localhost:2020`

This helps detect port conflicts and confirms that the server is responding.

## Issues Faced

Initially, I tried using pnpm because of my previous DevOps setup experience, but the project is configured to use Yarn 4.

I also initially tried `npm run dev`, but the project does not define a `dev` script. The correct project command is provided by the Twenty CLI:

`yarn twenty dev`

Another issue was that the Twenty server was not running, which caused the CLI to report:

`Cannot reach Twenty server.`

After checking `SETUP.md`, I understood that the local Twenty server needs to be started first using the provided Docker-based command.

## Solution

I followed the repository's setup instructions, used Yarn for dependency management, started the local Twenty server, and then ran the development synchronization command.

For the automation task, I converted these manual steps into a Python workflow with validation and error handling.

## Testing

The Python automation script was tested from the project root.

The script successfully:

- Checked required tools.
- Displayed dependency versions.
- Verified the project directory.
- Installed dependencies.
- Checked the local server.
- Started the required services.
- Verified the application health.
- Started the application development process.

The application was verified at:

`http://localhost:2020`

## Learning

This task helped me understand how a real application setup can be converted into an automated workflow using Python.

I learned how to work with Yarn-based projects, understand project-specific CLI commands, perform environment validation, handle errors, check service availability, and automate repetitive local setup tasks.