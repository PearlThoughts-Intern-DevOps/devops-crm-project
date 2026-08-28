# Task 3 – CRM Local Setup Automation

## Project Repository

[GitHub - PearlThoughts-Intern-DevOps/devops-crm-project](https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git)

## Objective

The objective of this task was to:

1. Clone the CRM project repository locally.
2. Explore the project structure and understand its components.
3. Set up and run the application locally.
4. Create a Python script to automate the local setup and startup process.
5. Use Python instead of a shell script for automation.
6. Create a personal branch using my name.
7. Push the changes to my fork/repository and raise a Pull Request.
8. Document the complete setup process, issues faced, solutions, and verification results.

---

## 1. Repository Setup

The project was cloned into the WSL Ubuntu environment.

The project is located at:

`/home/saketh/projects/projects/devops-crm-project`

The repository was cloned from my GitHub repository:

`https://github.com/Saketh8904/devops-crm-project.git`

### Initial Repository Verification

The following commands were used to verify the repository:

    pwd
    git status
    git remote -v
    git branch
    ls -la

The repository contained the following important files and directories:

- `.github/workflows/` – GitHub Actions workflows
- `public/` – Public/static application files
- `src/` – Application source code
- `README.md` – Project documentation
- `SETUP.md` – Setup instructions
- `package.json` – Project configuration and dependencies
- `yarn.lock` – Locked dependency versions
- `.nvmrc` – Required Node.js version
- `tsconfig.json` – TypeScript configuration
- `vitest.config.ts` – Vitest configuration
- `vitest.unit.config.ts` – Unit test configuration
- `AGENTS.md` – Development instructions
- `CLAUDE.md` – Project instructions
- `CHANGELOG.md` – Project changelog

---

## 2. Git Branch Setup

The repository initially contained the `main` branch.

The branches were checked using:

    git branch -a

Output:

    * main
      remotes/origin/HEAD -> origin/main
      remotes/origin/main

A personal branch was created using my name:

    git checkout -b saketh

The branch was successfully created and switched to:

    saketh

The final branch status was:

    main
    * saketh

All task-related changes were made on the `saketh` branch.

---

## 3. Node.js Setup

The project contains an `.nvmrc` file specifying the required Node.js version.

The contents of `.nvmrc` were:

    24.5.0

The installed NVM version was checked using:

    nvm --version

Output:

    0.40.3

The required Node.js version was selected using:

    nvm use

The project was successfully configured to use:

    Node.js v24.5.0
    npm v11.5.1

The versions were verified using:

    node --version
    npm --version

Output:

    v24.5.0
    11.5.1

---

## 4. Yarn Setup

The project uses Yarn 4.

Initially, Yarn was not available in the environment, so Yarn was installed/configured.

The version was verified using:

    yarn --version

Output:

    4.13.0

The project dependencies were installed using:

    yarn install

Installation completed successfully.

There were peer dependency warnings:

    my-app@workspace:. doesn't provide monaco-editor
    Some peer dependencies are incorrectly met by your project

These were warnings and did not prevent the installation from completing.

The final result was:

    Done with warnings

---

## 5. Docker Setup

The project requires Docker for running the local Twenty CRM server.

Initially, the `docker` command inside WSL was pointing to Podman instead of Docker Desktop.

Running:

    docker --version

initially returned:

    podman version 4.9.3

The Docker Desktop installation was checked from Windows.

WSL distributions were checked using:

    wsl -l -v

Docker Desktop was running:

    docker-desktop    Running    2

The Docker Desktop CLI provided the actual Docker binary at:

    /mnt/wsl/docker-desktop/cli-tools/usr/bin/docker

The Docker Desktop CLI version was checked using:

    /mnt/wsl/docker-desktop/cli-tools/usr/bin/docker --version

Output:

    Docker version 29.5.2

An alias was then configured for the current WSL session:

    alias docker=/mnt/wsl/docker-desktop/cli-tools/usr/bin/docker

Docker was then verified using:

    docker version

The client and server were successfully detected.

Docker Desktop server information:

    Docker Desktop 4.76.0
    Docker Engine 29.5.2

This confirmed that Docker Desktop was running correctly through WSL.

---

## 6. Initial Docker Issue

When running:

    yarn twenty docker:start

the first attempt failed because the `docker` command was still using Podman.

The error was:

    Error: short-name "twentycrm/twenty-app-dev:latest" did not resolve to an alias and no unqualified-search registries are defined

This happened because the system's `/usr/bin/docker` command was actually a Podman compatibility wrapper.

After configuring the Docker Desktop CLI:

    alias docker=/mnt/wsl/docker-desktop/cli-tools/usr/bin/docker

the Docker command correctly used Docker Desktop.

The command was then run again:

    yarn twenty docker:start

The Twenty CRM container was successfully created and started.

---

## 7. Twenty CRM Startup

The Twenty CRM server was started using:

    yarn twenty docker:start

The startup process performed the following operations:

- Pulled the Twenty CRM Docker image.
- Started the Twenty CRM container.
- Started PostgreSQL.
- Performed database setup and migrations.
- Flushed the cache.
- Ran the application upgrade.
- Seeded workspace data.
- Prepared the database.

The initial startup displayed:

    Registering cron jobs... Failed

and reported:

    Twenty server did not become healthy in time.

However, checking the server status afterward showed that the application was actually running successfully.

The status was checked using:

    yarn twenty docker:status

Output:

    Status:  running (healthy)
    URL:     http://localhost:2020
    Version: v2.35.0
    Login:   tim@apple.dev / tim@apple.dev

Therefore, the application was confirmed to be healthy.

---

## 8. Docker Logs Investigation

The application logs were checked using:

    yarn twenty docker:logs

The logs contained Gmail-related errors such as:

    No refresh token found for connected account

and:

    REFRESH_TOKEN_NOT_FOUND

The logs also showed:

    FAILED_INSUFFICIENT_PERMISSIONS

These messages were related to the seeded Gmail/message channel integration and did not prevent the main Twenty CRM server from becoming healthy.

The final server status confirmed:

    Status: running (healthy)

Therefore, the Gmail permission/refresh-token messages were treated as application integration warnings rather than a failure of the local CRM setup.

---

## 9. Local Application Verification

The application was successfully available at:

    http://localhost:2020

The local server status was verified using:

    yarn twenty docker:status

Result:

    Status:  running (healthy)
    URL:     http://localhost:2020
    Version: v2.35.0

The provided local login credentials were:

    Username: tim@apple.dev
    Password: tim@apple.dev

---

## 10. Project Verification

The project provides the following verification commands:

    yarn lint
    yarn typecheck
    yarn test:unit
    yarn test

All verification commands were executed successfully.

### Lint

Command:

    yarn lint

Result:

    Found 0 warnings and 0 errors.
    Finished in 19ms on 11 files with 1 rules using 12 threads.

The project passed linting successfully.

### Type Checking

Command:

    yarn typecheck

The command completed successfully without errors.

### Unit Tests

Command:

    yarn test:unit

Result:

    Test Files  1 passed
    Tests       1 passed

The unit test completed successfully.

The test executed:

    src/__tests__/application-config.test.ts

Result:

    1 test passed

There were Vite configuration warnings related to future `configLoader` behavior and the `vite-tsconfig-paths` plugin, but these warnings did not cause the tests to fail.

### Integration Tests

Command:

    yarn test

The integration tests completed successfully.

Result:

    Test Files  1 passed
    Tests       2 passed

The following tests passed:

    App installation
    CoreApiClient

The integration test successfully:

- Checked the installed application.
- Verified the application installation.
- Tested CRUD operations through the Core API Client.

The test also performed:

- Server checking
- Manifest building
- Application file building
- Type checking
- Metadata plan computation
- Application registration
- File upload
- Manifest synchronization
- API client generation

---

## 11. Python Automation

The task required automation using Python instead of a shell script.

A Python script named:

    setup.py

was created in the root of the repository.

The script automates the local CRM setup process.

The script performs the following major operations:

1. Checks required tools.
2. Checks Node.js.
3. Checks Yarn.
4. Checks Docker.
5. Installs project dependencies.
6. Starts the Twenty CRM server.
7. Checks the server status.
8. Displays the local URL and login credentials.

The script uses Python's subprocess functionality to execute the required commands and provides clear progress messages.

---

## 12. Python Script Validation

The Python version was checked using:

    python3 --version

Output:

    Python 3.12.3

The Python script was syntax-checked using:

    python3 -m py_compile setup.py

The command completed successfully without syntax errors.

The generated `__pycache__` directory was removed afterward:

    rm -rf __pycache__

This prevented unnecessary generated files from being included in Git.

---

## 13. Running the Automation Script

The automation script was executed using:

    python3 setup.py

The script displayed:

    ============================================================
    Twenty CRM Local Setup Automation
    ============================================================

### Step 1 – Required Tools

The script verified:

    Node.js found
    Yarn found
    Docker found

### Step 2 – Node.js

The script executed:

    node --version

Result:

    v24.5.0

### Step 3 – Yarn

The script executed:

    yarn --version

Result:

    4.13.0

### Step 4 – Docker

The script executed:

    docker version

Docker Desktop was successfully detected.

Docker Engine:

    29.5.2

### Step 5 – Dependencies

The script executed:

    yarn install

The dependencies were successfully installed.

The same peer dependency warnings appeared, but the installation completed successfully.

### Step 6 – Start Twenty CRM

The script executed:

    yarn twenty docker:start

The script detected that the Twenty server was already running:

    Twenty server detected on http://localhost:2020

It then checked the server status.

Result:

    Status:  running (healthy)
    URL:     http://localhost:2020
    Version: v2.35.0
    Login:   tim@apple.dev / tim@apple.dev

The final automation output was:

    ============================================================
    Twenty CRM is running successfully!
    URL: http://localhost:2020
    Login: tim@apple.dev
    Password: tim@apple.dev
    ============================================================

This confirmed that the Python automation was working successfully.

---

## 14. Issues Faced and Solutions

### Issue 1 – Incorrect WSL Distribution Name

Initially, the following command was used:

    wsl -d ubunut

It returned:

    There is no distribution with the supplied name.

#### Solution

The correct distribution name was:

    Ubuntu

The correct command was:

    wsl -d ubuntu

---

### Issue 2 – Git Permission Error on Windows Mounted Drive

An attempt was made to clone the repository under:

    /mnt/d/pearl/twenty

Git returned:

    error: chmod on .../.git/config.lock failed: Operation not permitted

#### Cause

The repository was being manipulated from the WSL environment on a Windows-mounted filesystem.

#### Solution

The project was moved/cloned into the Linux filesystem:

    /home/saketh/projects/projects/devops-crm-project

This avoided the Windows-mounted filesystem permission issue and allowed Git to work normally.

---

### Issue 3 – Docker Command Pointed to Podman

Initially:

    docker --version

returned:

    podman version 4.9.3

#### Cause

The WSL environment had Podman installed and `/usr/bin/docker` was a Podman compatibility wrapper.

#### Solution

The Docker Desktop CLI was used directly:

    /mnt/wsl/docker-desktop/cli-tools/usr/bin/docker

An alias was created:

    alias docker=/mnt/wsl/docker-desktop/cli-tools/usr/bin/docker

After this, Docker correctly connected to Docker Desktop.

---

### Issue 4 – Docker Socket Permission

Initially, Docker Desktop's Docker client reported:

    permission denied while trying to connect to the docker API

The Docker socket was checked:

    ls -l /var/run/docker.sock

The socket was owned by:

    root docker

The WSL user was not initially part of the `docker` group.

The issue was bypassed by using the Docker Desktop CLI integration that correctly connected to the Docker Desktop engine.

---

### Issue 5 – Twenty Container Initial Health Timeout

The first startup displayed:

    Registering cron jobs... Failed

and:

    Twenty server did not become healthy in time.

#### Solution

The actual server status was checked using:

    yarn twenty docker:status

The result was:

    Status: running (healthy)

Therefore, the application had successfully started despite the initial timeout message.

---

### Issue 6 – Gmail Refresh Token Error

The Docker logs showed:

    No refresh token found for connected account

and:

    REFRESH_TOKEN_NOT_FOUND

#### Cause

The seeded CRM workspace contains Gmail/message-channel integration data without a valid OAuth refresh token.

#### Solution

This was identified as an integration/permission warning rather than a failure of the CRM server.

The server itself was verified as:

    running (healthy)

Therefore, no change to the application source code was required.

---

### Issue 7 – Yarn Peer Dependency Warning

During:

    yarn install

Yarn reported:

    my-app@workspace:. doesn't provide monaco-editor

and:

    Some peer dependencies are incorrectly met by your project

#### Solution

The installation completed successfully and the application/tests worked correctly.

Since these were warnings and not blocking errors, they were documented but not changed unnecessarily.

---

## 15. Final Verification

The following components were successfully verified:

| Component | Status |
|---|---|
| WSL Ubuntu | Working |
| Node.js | v24.5.0 |
| npm | v11.5.1 |
| NVM | v0.40.3 |
| Yarn | v4.13.0 |
| Python | v3.12.3 |
| Docker Desktop | v4.76.0 |
| Docker Engine | v29.5.2 |
| Dependencies | Installed |
| Twenty CRM | Running |
| Server health | Healthy |
| Lint | Passed |
| Typecheck | Passed |
| Unit tests | Passed |
| Integration tests | Passed |
| Python automation | Passed |

---

## 16. Automation Result

The final automation command is:

    python3 setup.py

The script successfully:

    ✓ Checked Node.js
    ✓ Checked Yarn
    ✓ Checked Docker
    ✓ Verified versions
    ✓ Installed dependencies
    ✓ Started/verified Twenty CRM
    ✓ Displayed the application URL
    ✓ Displayed the login credentials

The application is available at:

    http://localhost:2020

---

## 17. Git Status

After creating the Python automation script, the repository showed:

    On branch saketh

    Untracked files:
        setup.py

The generated `__pycache__/` directory was removed before committing.

The final changes to be committed are:

    setup.py
    Task 3 documentation markdown file

---

## 18. Commit and Push

After completing the documentation and automation work, the changes should be committed using:

    git add setup.py TASK3.md

Then create the commit:

    git commit -m "feat: automate local CRM setup with Python"

Push the branch:

    git push -u origin saketh

---

## 19. Pull Request

After pushing the branch, create a Pull Request from:

    saketh

to:

    main

The Pull Request should be created in my own GitHub repository/fork and NOT in the official PearlThoughts repository.

The PR should include:

- Python automation script
- Task 3 documentation
- Setup procedure
- Project verification results
- Issues faced
- Solutions implemented
- Loom demonstration link

---

## 20. Loom Video

The Loom video should demonstrate:

1. Opening the project repository.
2. Showing the project structure.
3. Showing `.nvmrc`.
4. Showing Node.js and Yarn versions.
5. Showing Docker Desktop connectivity.
6. Showing the Twenty CRM status.
7. Running:

       python3 setup.py

8. Showing the successful automation output.
9. Opening:

       http://localhost:2020

10. Showing that the CRM application is running.
11. Showing the verification commands/results.
12. Briefly explaining the issues faced and their solutions.

Loom Video:

    <PASTE LOOM VIDEO LINK HERE>

---

## 21. Conclusion

Task 3 was completed by setting up the Twenty CRM application locally using WSL, Node.js, Yarn, and Docker Desktop.

A Python-based automation script was created to automate the local setup and startup process without using a `.sh` shell script.

The application was successfully started and verified as healthy at:

    http://localhost:2020

The project also passed linting, type checking, unit tests, and integration tests.

The main environment issues involving WSL filesystem permissions, Podman/Docker command conflicts, Docker socket permissions, and Twenty CRM startup/log warnings were investigated and resolved or documented appropriately.

The final implementation is ready to be committed to the `saketh` branch and submitted through a Pull Request.
