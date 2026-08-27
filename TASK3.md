# Task 3 - Local Setup and Python Automation

## Project

**DevOps CRM Project**

Repository:

`https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project`

Branch:

`vasundara`

## 1. Project Setup

The project repository was cloned from the shared internship repository.

The project was checked out to the `vasundara` branch before making changes.

### Prerequisites

The project requires:

- Python 3
- Node.js 24.5.0 or newer
- Yarn 4.0.2 or newer
- Docker

The installed versions used during setup were:

- Python 3.12.3
- Node.js 24.19.0
- Yarn 4.13.0
- Docker 29.1.5

## 2. Manual Setup

The original project setup process is documented in `SETUP.md`.

The main steps are:

```bash
yarn install
yarn twenty docker:start
yarn twenty dev	

The local Twenty server is available at:

http://localhost:2020

The application was successfully initialized and synchronized.

##3. Python Automation

A Python script named setup.py was created to automate the local setup and startup process.

The script performs the following tasks:

Verifies that it is being run from the project root.
Checks that the required tools are installed.
Displays the installed dependency versions.
Verifies the required Node.js and Yarn versions.
Installs project dependencies when required.
Checks whether the local Twenty server is already running.
Starts the Twenty Docker server when necessary.
Waits for the Twenty server to become available.
Starts the Twenty development server.
Handles errors and allows the development server to be stopped with Ctrl+C.
Run the automation

From the project root:

python3 setup.py

After successful startup, the application can be accessed at:

http://localhost:2020

##4. Verification

The automation script was tested successfully.

The final application status was:

Overall Status: ✓ Synced
Application Initialization: ✓ done
Resources Build: ✓ done
Resources Upload: ✓ done
Manifest Build: ✓ done
Application Synchronization: ✓ done
Api Client Generation: ✓ done
Entities ✓ 7 synced
##5. Issues Faced and Solutions
Issue 1 - Yarn/Corepack download timeout

While preparing Yarn through Corepack, the download from the Yarn repository timed out.

The error was related to network connectivity:

ETIMEDOUT
ENETUNREACH
Solution

The issue was identified as a network connectivity problem rather than a project configuration problem.

After the required Yarn version became available, the project setup continued successfully.

Issue 2 - OAuth callback connection error

During local Twenty authentication, the browser initially displayed:

ERR_CONNECTION_REFUSED

The Twenty server itself was then verified using:

curl -I http://localhost:2020
curl -I http://127.0.0.1:2020

Both returned:

HTTP/1.1 200 OK

The server was therefore confirmed to be running correctly.

Solution

The local Twenty server was accessed directly through:

http://localhost:2020

The CLI authentication was then completed successfully and the application was synchronized.

##6. Docker Usage

Docker is required by the project's existing setup instructions because the local Twenty server is started using:

yarn twenty docker:start

The Python automation script therefore checks Docker availability and uses the project's existing Twenty Docker command.

No shell script was created for the automation requirement.

##7. Files Added

The following files were added for this task:

setup.py
TASK3.md
