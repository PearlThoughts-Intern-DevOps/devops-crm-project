# Task 3 - DevOps CRM Project

## Objective

Set up and run the DevOps CRM project locally and create a Python script to automate the local setup and startup process.

## Project Repository

https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project

## Work Completed

- Cloned the project repository.
- Explored the project structure and main components.
- Checked the required Node.js version.
- Installed project dependencies using Yarn.
- Installed and configured Docker Desktop with WSL 2.
- Started the Twenty application locally.
- Verified the application using Docker and Twenty status checks.
- Created a Python automation script named `setup_and_start.py`.
- Automated the dependency installation and application startup process.
- Added an HTTP health check for `http://localhost:2020`.
- Tested the automation when the application was already running.
- Tested the automation after stopping the existing container.

## Automation Process

The Python script performs the following steps:

1. Checks Node.js, Docker, and Yarn.
2. Verifies that Docker is running correctly.
3. Installs project dependencies using `yarn.cmd install`.
4. Starts the Twenty application using `yarn.cmd twenty docker:start`.
5. Verifies the Twenty server status.
6. Performs an HTTP health check on `http://localhost:2020`.

## Health Verification

The application was verified using:

- Required tool checks
- Docker health check
- Twenty server status
- HTTP application health check

The final HTTP health check returned:

```text
HTTP 200
```

This confirms that the application was not only running inside Docker but was also accessible through the local application URL.

## Testing

The automation was tested after stopping the Twenty server.

The script successfully started the existing stopped container and completed the health verification.

No duplicate container was created.

## Result

The DevOps CRM project was successfully set up and automated locally.

The application was successfully accessible at:

http://localhost:2020

The Python automation script successfully performed setup, startup, verification, and HTTP health checking.

## Detailed Documentation

Detailed documentation for this task, including the complete setup process, automation explanation, issues faced, solutions, testing, and screenshots, is available in:

`documentation/Task-3-Documentation.pdf`
