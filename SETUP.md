
# CRM Project – Local Setup and Automation

## 1. Objective

The objective of this task was to automate the local setup and startup process of the CRM project.

A Python script named `setup.py` was created to automate the main setup steps instead of running each command manually.

The automation performs the following:

1. Installs project dependencies using Yarn.
2. Starts the Twenty Docker server.
3. Checks the Twenty server status.
4. Starts the Twenty development server.

---

## 2. Prerequisites

The following tools are required:

* Git
* Python
* Node.js
* Yarn
* Docker Desktop
* WSL 2
* Twenty CLI/project dependencies

Docker Desktop must have WSL integration enabled for the Ubuntu distribution.

---

## 3. Project Setup

The project was cloned/opened in the local development environment.

The project was initially located under the Windows filesystem:

```bash
/mnt/c/Users/jatin/Devops_Task/devops-crm-project
```

Working directly from the Windows-mounted filesystem caused issues while installing dependencies.

To avoid these issues, the project was copied to the WSL Linux filesystem:

```bash
mkdir -p ~/Devops_Task/devops-crm-project
```

The project files were then copied using:

```bash
rsync -a --exclude='node_modules' --exclude='.twenty' /mnt/c/Users/jatin/Devops_Task/devops-crm-project/ ~/Devops_Task/devops-crm-project/
```

The project was then opened from:

```bash
cd ~/Devops_Task/devops-crm-project
```

The working directory was verified using:

```bash
pwd
```

Expected location:

```text
/home/jatin/Devops_Task/devops-crm-project
```

---

## 4. Installing Dependencies

Project dependencies were installed using:

```bash
yarn install
```

Initially, `yarn install` failed with an I/O error related to:

```text
node_modules/@esbuild/win32-x64/esbuild.exe
```

The issue was related to running the project from the Windows-mounted filesystem through WSL.

After moving the project into the WSL Linux filesystem, `yarn install` completed successfully.

The installation completed with warnings about peer dependencies, but the installation itself was successful.

---

## 5. Docker Setup

Docker Desktop was required for the Twenty server.

Initially, Docker was not available inside WSL and the following error was displayed:

```text
The command 'docker' could not be found in this WSL 2 distro.
```

Docker Desktop WSL integration was enabled for Ubuntu.

WSL was then restarted using PowerShell:

```powershell
wsl --shutdown
```

After restarting WSL and Docker Desktop, Docker was verified using:

```bash
docker --version
```

Docker containers were also checked using:

```bash
docker ps
```

---

## 6. Starting the Twenty Server

From the project directory, the Twenty Docker server was started using:

```bash
yarn twenty docker:start
```

The server was then checked using:

```bash
yarn twenty docker:status
```

A successful status showed:

```text
Status:  running (healthy)
URL:     http://localhost:2020
Version: v2.35.0
```

---

## 7. Twenty CLI Authentication

While starting the development server, the Twenty CLI required authentication.

The command used was:

```bash
yarn twenty remote:add
```

The CLI provided a browser authentication URL.

After authentication/API-key setup, the local remote was successfully added and set as the default remote.

---

## 8. Starting the Development Server

The development server was started using:

```bash
yarn twenty dev
```

The application was successfully built and synchronized.

The successful output showed:

```text
Successfully uploaded 4 files
```

and:

```text
✓ Synced
```

The final application status showed:

```text
Overall Status: ✓ Synced
```

The application was then accessible through the local Twenty server.

---

## 9. Setup Automation

The file `setup.py` was created to automate the complete local setup process.

The script performs these steps:

```text
STEP 1 → yarn install
STEP 2 → yarn twenty docker:start
STEP 3 → yarn twenty docker:status
STEP 4 → yarn twenty dev
```

The script also includes error handling using Python's `subprocess` module.

If a command fails, the script reports the error and exits with the corresponding exit code.

The script also handles keyboard interruption using `KeyboardInterrupt`.

---

## 10. Running the Automation

The automation script can be executed from the project directory using:

```bash
python setup.py
```

The script displays each step while it is running.

A successful execution starts the Twenty server, verifies its health, and starts the development server.

---

## 11. Issues Faced and Solutions

### Issue 1: Docker command not available in WSL

**Problem:**

The following error appeared:

```text
The command 'docker' could not be found in this WSL 2 distro.
```

**Solution:**

Docker Desktop WSL integration was enabled for Ubuntu.

WSL was restarted using:

```powershell
wsl --shutdown
```

Docker was then verified from WSL:

```bash
docker --version
```

---

### Issue 2: Yarn installation failed on Windows-mounted filesystem

**Problem:**

`yarn install` failed with:

```text
EIO: i/o error, unlink .../node_modules/@esbuild/win32-x64/esbuild.exe
```

**Solution:**

The project was moved from the Windows-mounted filesystem:

```text
/mnt/c/Users/jatin/...
```

to the WSL Linux filesystem:

```text
/home/jatin/Devops_Task/devops-crm-project
```

After moving the project, `yarn install` completed successfully.

---

### Issue 3: Twenty CLI authentication timeout

**Problem:**

When running:

```bash
yarn twenty dev
```

the CLI requested browser authentication and initially timed out.

**Solution:**

The Twenty remote was authenticated using:

```bash
yarn twenty remote:add
```

The remote was successfully added using the API key provided during the authentication process.

After authentication, `yarn twenty dev` successfully synchronized the application.

---

### Issue 4: Initial application synchronization error

**Problem:**

During an earlier attempt, the Twenty application reported errors related to Windows backslashes in resource paths:

```text
INVALID_FRONT_COMPONENT_INPUT
Resource path must not contain backslashes
```

**Solution:**

The project was moved to the WSL Linux filesystem and the dependencies/build output were regenerated.

After this, the application synchronized successfully.

The final run showed:

```text
Overall Status: ✓ Synced
Entities ✓ 7 synced
```

---

## 12. Git Workflow

A separate branch was created using the developer's name:

```bash
git checkout -b jatin
```

The automation file was staged:

```bash
git add setup.py
```

A commit was created:

```bash
git commit -m "Add Local Setup Automation"
```

The branch was pushed to the existing repository:

```bash
git push origin jatin
```

A Pull Request was then created from:

```text
jatin → main
```

in the same repository.

---

## 13. Verification

The final setup was verified successfully.

The following were confirmed:

* Dependencies installed successfully.
* Docker was available through WSL.
* Twenty Docker server was running and healthy.
* Twenty CLI authentication was completed.
* Development server started successfully.
* Application resources were uploaded successfully.
* Application synchronization completed successfully.
* All 7 entities were synchronized successfully.
* `setup.py` successfully automated the local setup
