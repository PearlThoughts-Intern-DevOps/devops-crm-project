Task 7: AWS EC2 – Twenty CRM Deployment
Objective

Launch and configure an AWS EC2 instance and deploy/run the Twenty CRM application. Verify the application, resolve configuration and CI issues, and validate the application using linting, type checking, and tests.

Environment
Cloud Platform: AWS
Compute Service: EC2
Operating System: Amazon Linux 2023
Node.js: 24.18.1
Yarn: 4.13.0
Docker: Running
Twenty CLI: 2.35.1
Twenty Server: 2.37.4
Application Port: 2020
Git Branch: Nagendra_M_task-7
Setup

The project repository was cloned into the EC2 instance and the required dependencies were installed.

git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project

Installed project dependencies:

yarn install

Verified Yarn:

yarn --version

Output:

4.13.0
Twenty CRM Setup

Checked the Twenty application Docker container:

yarn twenty docker:status

The Twenty server was running successfully and reported a healthy status.

Verified the application endpoint:

curl -I http://localhost:2020

The server returned:

HTTP/1.1 200 OK

Verified that port 2020 was listening:

ss -lntp | grep 2020

The application was listening on port 2020.

Application Synchronization

Started the Twenty development environment:

yarn twenty dev

The application synchronized successfully.

Verification included:

Application registration completed
Application resources built successfully
Resources uploaded successfully
Manifest generated successfully
Application synchronization completed
API client generation completed
7 entities synchronized
Overall application status: Synced
Issues Faced and Solutions
Issue 1: Page Layout Synchronization Error

The application initially failed synchronization with:

INVALID_PAGE_LAYOUT_WIDGET_DATA
Position layoutMode "GRID" does not match
tab layoutMode "VERTICAL_LIST"

The page layout contained a gridPosition configuration while the tab used VERTICAL_LIST.

Solution

Removed the incompatible gridPosition configuration from:

src/page-layouts/main-page.page-layout.ts

After the change, the application synchronized successfully.

Issue 2: TypeScript Typecheck Error

The CI typecheck reported:

'created.createNote' is possibly 'undefined'

The issue occurred in:

src/__tests__/schema.integration-test.ts
Solution

Stored the returned note in a variable, verified that it exists, and then accessed its ID.

This resolved the TypeScript strict null-checking error.

Validation

The following checks were performed successfully.

Typecheck
yarn typecheck

Result:

Passed
Lint
yarn lint

Result:

Found 0 warnings and 0 errors
Unit Tests
yarn test:unit

Result:

1 test passed
Integration Tests
yarn test

Result:

Test Files  1 passed
Tests       2 passed
Final Status

The Twenty CRM application was successfully configured and synchronized on the AWS EC2 environment.

The application and project validation completed successfully:

EC2 environment configured
Dependencies installed
Docker/Twenty server running
Twenty application synchronized
Page layout issue resolved
TypeScript typecheck issue resolved
Lint passed
Unit tests passed
Integration tests passed
Git Branch

All Task 7 changes were made on:

Nagendra_M_task-7
