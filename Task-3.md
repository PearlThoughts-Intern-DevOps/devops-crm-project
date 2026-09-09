# DevOps Internship Task 3 – Twenty CRM Local Setup Automation

## Intern

Mujtaba Shaikh

## Date

27 August 2026

## Task

Twenty CRM Local Setup and Python Automation

## Objective

The objective of this task was to clone the Twenty CRM application repository, understand the project structure, install the required dependencies, set up and run the Twenty CRM application locally, and create a Python script to automate the local setup and startup process.

The automation was implemented using Python as required by the task. No shell script (`.sh`) was used for the automation.

## Environment

Operating System: Ubuntu Linux  
Node.js  
Yarn 4  
Docker  
Python 3  
Twenty CRM  
Twenty CLI  
Twenty SDK  

## Work Completed

Cloned the Twenty CRM application repository from GitHub.

Reviewed the repository structure and project documentation.

Checked the required development tools and dependencies.

Installed the project dependencies using Yarn.

Started the local Twenty CRM server using Docker.

Authenticated the Twenty CLI with the local Twenty CRM environment.

Registered and installed the application named `My app`.

Synchronized the application with the local Twenty CRM server.

Created a Python automation script named `automation.py`.

Tested the Python automation script successfully.

Verified that the application was synchronized and that 7 entities were synced successfully.

## Project Structure

The project structure was reviewed to understand the main components.

Important files and directories include:

```text
devops-crm-project/
├── .github/
├── .twenty/
├── .yarn/
├── node_modules/
├── public/
├── src/
│   ├── application-config.ts
│   └── default-role.ts
├── AGENTS.md
├── CHANGELOG.md
├── CLAUDE.md
├── package.json
├── README.md
├── SETUP.md
├── tsconfig.json
├── tsconfig.spec.json
├── vitest.config.ts
├── vitest.unit.config.ts
├── yarn.lock
└── .yarnrc.yml
Local Setup

The required project dependencies were installed using:

yarn install

The local Twenty CRM server was started using:

yarn twenty docker:start

The Twenty development environment was started using:

yarn twenty dev

The local Twenty CRM application is available at:

http://localhost:2020
Twenty CLI Authentication

During the first execution of yarn twenty dev, the Twenty CLI requested authentication.

The browser authorization was completed successfully. After authentication, the credentials were saved by the Twenty CLI.

The application My app was registered and installed successfully.

The successful setup included:

Re-authenticated "local"
Application registration created: My app
Credentials saved to config.
Application installed
Successfully uploaded 4 files

After authentication was completed, subsequent executions detected the existing application registration.

Application Synchronization

The Twenty application was successfully synchronized with the local Twenty CRM server.

The final synchronization result was:

Application
  Name: My app
  Overall Status: ✓ Synced

  Application Initialization: ✓ done
  Resources Build: ✓ done
  Resources Upload: ✓ done
  Manifest Build: ✓ done
  Application Synchronization: ✓ done
  Api Client Generation: ✓ done

  Entities ✓ 7 synced

This confirmed that the local Twenty application was successfully configured and synchronized.

Python Automation

A Python script named automation.py was created to automate the local setup and startup process.

The automation performs the following steps:

Check Node.js
      ↓
Check Yarn
      ↓
Check Docker
      ↓
Install project dependencies
      ↓
Start local Twenty server
      ↓
Start Twenty development environment
      ↓
Synchronize My app
      ↓
Verify successful setup

The script uses Python's shutil.which() to check the required tools and subprocess.run() to execute the required commands.

The automation does not use any .sh shell script.

Automation Execution

The Python automation was executed using:

python3 automation.py

The script successfully detected the required tools:

✓ Node.js is available
✓ Yarn is available
✓ Docker is available

The project dependencies were installed successfully:

>>> Running: yarn install
✓ Completed: yarn install

The local Twenty server was started successfully:

>>> Running: yarn twenty docker:start
Twenty server detected on http://localhost:2020
✓ Completed: yarn twenty docker:start

The Twenty development environment was then started:

>>> Running: yarn twenty dev
Automation Result

The Python automation completed successfully.

The Twenty CLI detected the existing application registration:

Existing app registration found

The application was successfully installed and synchronized.

The final result was:

Name: My app
Overall Status: ✓ Synced

Application Initialization: ✓ done
Resources Build: ✓ done
Resources Upload: ✓ done
Manifest Build: ✓ done
Application Synchronization: ✓ done
Api Client Generation: ✓ done

Entities ✓ 7 synced

This confirmed that the Python script successfully automated the local Twenty CRM setup and startup process.

Issues Encountered

During the execution of yarn install, Yarn displayed a peer dependency warning:

YN0002: my-app@workspace:. doesn't provide monaco-editor,
requested by twenty-ui.

Yarn also displayed:

YN0086: Some peer dependencies are incorrectly met by your project.

However, the dependency installation completed successfully:

Done with warnings
✓ Completed: yarn install

The Twenty CRM application also started successfully and the application synchronization completed successfully.

Solution

The peer dependency warning was reviewed and did not prevent the application from running.

No dependency changes were required because the installation completed successfully and the Twenty application was successfully synchronized.

The final application status confirmed:

Overall Status: ✓ Synced
Entities ✓ 7 synced
Verification

The local Twenty server can be checked using:

yarn twenty docker:status

Docker containers can be checked using:

docker ps

The Twenty CRM application can be accessed through:

http://localhost:2020

The application synchronization was also verified through the Twenty CLI output.

The final result showed:

Overall Status: ✓ Synced
Application Synchronization: ✓ done
Entities ✓ 7 synced
Key Learnings

Learned how to work with the Twenty CRM application development environment.

Learned how to understand and configure a Twenty application project.

Learned how Yarn is used to install and manage project dependencies.

Learned how Docker is used to run the local Twenty CRM server.

Learned how to authenticate the Twenty CLI with a local Twenty environment.

Learned how the Twenty CLI registers, installs, uploads, and synchronizes an application.

Learned how to use Python subprocess for command automation.

Learned how to use Python shutil.which() to verify required dependencies.

Learned how to automate a multi-step local application setup using Python instead of shell scripts.

Learned how to troubleshoot and document dependency warnings.

Result

The Twenty CRM application was successfully configured and run locally.

The application was successfully synchronized using the Twenty CLI.

The Python automation script successfully checked the required dependencies, installed the project dependencies, started the local Twenty CRM server, started the Twenty development environment, and synchronized My app.

The local application was verified through:

http://localhost:2020

The final Twenty CLI output confirmed:

Overall Status: ✓ Synced
Entities ✓ 7 synced
Conclusion

Task 3 was successfully completed.

The Twenty CRM application was cloned, its project structure and dependencies were reviewed, and the application was successfully set up and run locally using Docker.

The Twenty CLI was authenticated with the local Twenty CRM environment, and the My app application was successfully registered, installed, and synchronized.

A Python automation script named automation.py was created to automate the local setup and startup process. The script successfully checks the required dependencies, installs the project dependencies, starts the local Twenty CRM server, and runs the Twenty development environment.

The automation was tested successfully, and the final output confirmed:

Overall Status: ✓ Synced
Application Synchronization: ✓ done
Entities ✓ 7 synced

The local Twenty CRM application was successfully verified at:

http://localhost:2020

This completes the local setup and Python automation requirements of Task 3.
