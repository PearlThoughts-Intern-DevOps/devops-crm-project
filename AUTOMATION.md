# Local Setup and Automation Guide

This document outlines the manual setup process for the Twenty CRM project, the Python-based automation script created to streamline this process, and the troubleshooting steps taken during development.

## ️ Manual Setup Steps

Before automating, the application was successfully set up and run manually using the following steps:

1. **Prerequisites:** Ensure Docker is running, Node.js v24.5.0 is installed (via `nvm`), and Yarn v4 is active.
2. **Install Dependencies:** Run `yarn install` to fetch all project dependencies.
3. **Start Backend (Docker):** Run `yarn twenty docker:start` to spin up the local Twenty server and database containers.
4. **Start Frontend (Dev Server):** Run `yarn twenty dev` to start the development server.
5. **Access App:** Open `http://localhost:2020` and log in with `tim@apple.dev` / `tim@apple.dev`.

##  Automation Steps

To eliminate manual intervention and ensure a reproducible environment, a Python script (`setup.py`) was created. 

### How it works:
The script uses Python's built-in `subprocess` module to execute terminal commands sequentially. It performs the following actions:
1. Verifies that Node, Yarn, and Docker are installed and running.
2. Installs project dependencies via `yarn install`.
3. Starts the Docker containers using `yarn twenty docker:start`.
4. Pauses execution for 20 seconds to allow Docker containers to fully initialize.
5. Launches the frontend development server via `yarn twenty dev`.

### How to run:
Simply execute the following command in the root directory of the project:
```bash
python setup_and_run.py
