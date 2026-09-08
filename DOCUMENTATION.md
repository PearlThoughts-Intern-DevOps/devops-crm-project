# DevOps CRM Project - Setup and Automation Documentation

## 1. Project Setup

### Project

* Repository: `PearlThoughts-Intern-DevOps/devops-crm-project`
* Application: My Twenty App

### Environment

* Operating System: Ubuntu 26.04 LTS on WSL2
* Node.js: 24.5.0
* Yarn: 4.13.0
* Docker: 29.1.3
* Python: Python 3
* Git: Used for version control

### Clone the Repository

```bash
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
```

### Check Node.js Version

The project requires Node.js version 24.5.0.

```bash
cat .nvmrc
node --version
```

### Install Project Dependencies

```bash
yarn install
```

This installs all the dependencies required by the project.

---

## 2. Running the Application

### Start Twenty Server

The project requires the local Twenty server to run using Docker.

```bash
yarn twenty docker:start
```

### Check Twenty Server Status

```bash
yarn twenty docker:status
```

Expected result:

```text
Status: running (healthy)
URL: http://localhost:2020
```

### Start the Development Application

```bash
yarn twenty dev
```

During the first run, authentication is required.

The development credentials provided by the project are:

```text
Email: tim@apple.dev
Password: tim@apple.dev
```

The application can be accessed at:

```text
http://localhost:2020
```

### Verify the Application

The application was successfully synchronized.

Verified:

* Application Initialization: done
* Resources Build: done
* Resources Upload: done
* Application Synchronization: done
* Entities: 7 synced
* Twenty Server: running and healthy

---

## 3. Python Automation

### Automation Script

A Python script named `setup.py` was created to automate the repeatable local setup process.

The script uses Python's `subprocess` module to execute the required Yarn commands.

### Commands Automated

The Python script automates:

```bash
yarn install
yarn twenty docker:start
yarn twenty docker:status
```

### Run the Python Automation

```bash
python3 setup.py
```

### Purpose of Automation

The purpose of the Python script is to reduce the need to manually run the setup commands every time.

Instead of running the commands individually, the setup can be started using:

```bash
python3 setup.py
```

The script also stops execution if one of the commands fails.

The `yarn twenty dev` command is started separately because it requires interactive authentication.

---

## 4. Issues Faced

### Issue 1 - Node.js Version Mismatch

The system initially had:

```text
Node.js 22.23.1
```

The project required:

```text
Node.js 24.5.0
```

### Issue 2 - NVM Not Installed

When checking NVM:

```bash
nvm --version
```

the system returned:

```text
Command 'nvm' not found
```

### Issue 3 - Yarn Not Found

Initially, Yarn was not available in the Ubuntu environment.

### Issue 4 - Twenty Server Health Timeout

When starting the Twenty server, the following message appeared:

```text
Twenty server did not become healthy in time.
```

### Issue 5 - Gmail Synchronization Warning

The application displayed:

```text
Sync lost with mailbox tim@apple.dev.
Please reconnect for updates.
```

---

## 5. Solutions

### Solution 1 - Node.js Version

NVM was installed to manage Node.js versions.

The required Node.js version was installed and activated:

```bash
nvm install 24.5.0
nvm use 24.5.0
```

The version was then verified:

```bash
node --version
```

Result:

```text
v24.5.0
```

### Solution 2 - Install and Enable NVM

NVM was installed using:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

NVM was loaded using:

```bash
source ~/.bashrc
```

NVM was verified using:

```bash
nvm --version
```

Result:

```text
0.40.3
```

### Solution 3 - Install Yarn

Corepack was enabled:

```bash
corepack enable
```

Yarn was then verified:

```bash
yarn --version
```

Result:

```text
4.13.0
```

### Solution 4 - Twenty Server Health Timeout

The Docker logs were checked using:

```bash
yarn twenty docker:logs
```

The server status was then checked using:

```bash
yarn twenty docker:status
```

The final status was:

```text
Status: running (healthy)
URL: http://localhost:2020
```

Therefore, the Twenty server was successfully running.

### Solution 5 - Gmail Synchronization Warning

The Gmail synchronization warning was related to the development Gmail account and missing authentication refresh information.

The warning did not prevent the Twenty application from being successfully installed and synchronized.

---

## 6. Git Branch and Pull Request

### Create Branch

The work was performed on a separate Git branch:

```bash
git checkout -b shradha
```

The branch name is:

```text
shradha
```

### Verify Branch

```bash
git branch
```

The current branch was verified as:

```text
* shradha
```

### Files Added

The following files were created:

```text
setup.py
DOCUMENTATION.md
```

### Commit Changes

The changes will be added and committed using Git.

```bash
git add setup.py DOCUMENTATION.md
git commit -m "Add Python setup automation and documentation"
```

### Push Branch

The branch will be pushed to GitHub:

```bash
git push -u origin shradha
```

### Pull Request

After pushing the branch, create a Pull Request in the same repository:

```text
Repository:
PearlThoughts-Intern-DevOps/devops-crm-project

Source:
shradha

Target:
main
```

---

## 7. Loom Video

A Loom video will demonstrate:

* Project cloning and local setup
* Installing dependencies
* Starting the Twenty Docker server
* Running the Python automation script
* Checking the server status
* Opening the application

Loom video:

```text
[Add Loom link here]
```

---

## 8. Final Result

The DevOps CRM project was successfully set up and run locally using Ubuntu WSL2.

The local environment was configured with the required Node.js, Yarn, Docker, Python, and Git tools.

The Twenty server was successfully started and verified as healthy.

A Python automation script was created to automate the repeatable setup process.

The changes are prepared on the `shradha` branch for submission through a Pull Request.

