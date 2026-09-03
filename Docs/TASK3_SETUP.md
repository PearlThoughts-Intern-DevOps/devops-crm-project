# Task 3 - CRM Local Setup Automation

## Setup

- Cloned the DevOps CRM project.
- Explored the project structure and configuration files.
- Installed Node.js and Yarn.
- Installed project dependencies using Yarn.
- Started the local Twenty server using Docker.
- Authenticated the local Twenty CLI.
- Started the development application.

## Environment

- Node.js: 24.5.0
- Yarn: 4.13.0
- Docker Desktop
- Python 3
- Ubuntu WSL2

## Automation

Created `scripts/setup.py`.

The Python script automates:

- Required tool checking
- Project directory validation
- Dependency version checking
- Dependency installation
- Twenty Docker server startup
- Development server startup

## Application

The application runs locally at:

http://localhost:2020

## Issue Faced

Initially, the application was run from the Windows filesystem.

The Twenty CLI generated Windows-style paths containing backslashes, which caused resource synchronization errors.

## Solution

The project was run from the WSL Linux filesystem:

`/home/prabhas/devops-crm-project`

After moving to the Linux filesystem, the generated paths used forward slashes and the application synchronized successfully.

## Result

The CRM application was successfully built, synchronized, and started locally.
