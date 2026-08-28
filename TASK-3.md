Task 3 - Local Setup and Automation
1. Project Overview

This project is a Twenty CRM application built using the Twenty SDK.

The main project components include:

src/application-config.ts - Application configuration
src/default-role.ts - Default application role
src/constants/ - Universal identifiers
src/front-components/ - React front components
src/navigation-menu-items/ - Navigation menu configuration
src/page-layouts/ - Page layout configuration
src/__tests__/ - Unit and integration tests
public/ - Public application assets
package.json - Project dependencies and scripts
SETUP.md - Existing manual setup instructions
2. Prerequisites

The project requires:

Node.js 24.5.0
Yarn 4
Docker
Python 3
Git

The Node.js version is specified in .nvmrc.

3. Manual Setup

Install project dependencies:

yarn install

Start the local Twenty server:

yarn twenty docker:start

Check the server status:

yarn twenty docker:status

Start the Twenty application development environment:

yarn twenty dev

The application is available at:

http://localhost:2020

Default development credentials:

Email: tim@apple.dev
Password: tim@apple.dev

4. Project Structure

The important project files and directories are:

devops-crm-project/
├── .github/
├── public/
│ └── logo.svg
├── src/
│ ├── tests/
│ ├── constants/
│ ├── front-components/
│ ├── navigation-menu-items/
│ ├── page-layouts/
│ ├── application-config.ts
│ └── default-role.ts
├── .gitignore
├── .nvmrc
├── .yarnrc.yml
├── package.json
├── SETUP.md
├── TASK-3.md
├── tsconfig.json
└── yarn.lock

The application uses React for front components and the Twenty SDK for application development and synchronization with the local Twenty server.

5. Python Automation

A Python script named setup.py was created to automate the local setup process.

The script performs these steps:

Installs project dependencies using yarn install.
Starts the local Twenty server using yarn twenty docker:start.
Checks whether the Twenty server is reachable at http://localhost:2020.
Reports whether the setup completed successfully.

The automation was implemented in Python as required by the task. No shell script was used.

Run the automation with:

python3 setup.py

The script was syntax-checked successfully using:

python3 -m py_compile setup.py

6. Automation Result

The automation was successfully tested.

The script successfully:

Installed the project dependencies.
Started/detected the local Twenty server.
Verified that http://localhost:2020 was reachable.
Reported successful setup completion.

The application was subsequently started successfully using:

yarn twenty dev

The Twenty CLI reported:

Overall Status: ✓ Synced
Application Initialization: ✓ done
Resources Build: ✓ done
Resources Upload: ✓ done
Manifest Build: ✓ done
Application Synchronization: ✓ done
Api Client Generation: ✓ done
Entities ✓ 7 synced

7. Issues Faced and Solutions
Issue 1 - Node.js was unavailable in WSL

Initially, WSL could not find the node command even though Node.js was installed in the Windows environment.

Error:

Command 'node' not found

Solution:

NVM was installed inside WSL and Node.js 24.5.0 was configured using:

nvm install 24.5.0
nvm use 24.5.0
nvm alias default 24.5.0

Corepack was then enabled and Yarn 4.13.0 was configured using:

corepack enable
corepack prepare yarn@4.13.0 --activate

Issue 2 - Windows path separators caused Twenty CLI resource upload errors

When the project was initially run from Git Bash, the generated Twenty manifest contained Windows-style backslashes:

src\front-components\main-page.mjs
public\logo.svg

The Twenty server rejected these paths with:

Resource path must not contain backslashes

Solution:

The project was executed from the WSL environment using the Linux Node.js and Yarn installation. This generated valid resource paths and allowed the application resources to upload successfully.

Issue 3 - Layout configuration was initially VERTICAL_LIST

The generated page layout initially contained:

layoutMode: PageLayoutTabLayoutMode.VERTICAL_LIST

The layout was changed to:

layoutMode: PageLayoutTabLayoutMode.GRID

After running the development command again, the Twenty CLI reported that the page layout tab was updated successfully:

Metadata changes: 1 updated
updated pageLayoutTab ... [layoutMode] changed
✓ Synced

Issue 4 - Typecheck error

The existing integration test produced TypeScript errors:

'created.createNote' is possibly 'undefined'

This occurred in:

src/tests/schema.integration-test.ts

The unit tests themselves passed successfully:

Test Files 1 passed
Tests 1 passed

This issue was documented rather than modifying unrelated project code.

Issue 5 - Twenty Docker status

The command:

yarn twenty docker:status

reported:

Status: not created
Run 'yarn twenty docker:start' to create one.

However, the Twenty server was reachable at:

http://localhost:2020

and the application successfully synchronized through:

yarn twenty dev

The Python automation therefore verifies the actual Twenty server endpoint rather than relying only on the Docker status command.

8. Verification Commands

The following commands were used during verification:

docker --version
node --version
yarn --version
yarn twenty --version
yarn lint
yarn typecheck
yarn test:unit
python3 -m py_compile setup.py
python3 setup.py
yarn twenty dev

Environment versions:

Node.js: 24.5.0
Yarn: 4.13.0
Twenty CLI: 2.35.1
Twenty Server: 2.37.0
Docker: 29.1.3

9. Git Branch

The changes for this task are being developed on a separate branch named:

piyush

The branch was created from the repository's main branch.

10. Pull Request

The task requires the changes to be pushed to the personal branch and a Pull Request to be raised.

The PR should be created from:

piyush

into:

main

The changes should not be committed directly to the main branch.

11. Loom Demonstration

The Loom video should demonstrate:

Repository and project structure.
Node.js, Yarn and Docker versions.
Running python3 setup.py.
Successful dependency installation.
Twenty server verification.
Running yarn twenty dev.
Opening the application at http://localhost:2020.
Briefly explaining the issues encountered and their solutions.
Showing the Git branch and final changes.
