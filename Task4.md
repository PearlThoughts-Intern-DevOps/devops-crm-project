\# Task 4: Continuous Integration Improvements



\## Objective



Improve the existing GitHub Actions CI workflow for the `devops-crm-project` and ensure that the required checks run automatically on Pull Requests.



\## Changes Made



\* Reviewed the existing `.github/workflows/ci.yml`.

\* Created a new `.github/workflows/ci-improvements.yml`.

\* Configured the workflow to run when a Pull Request is opened, updated, or reopened.

\* Added dependency installation using `yarn install --immutable`.

\* Enabled Yarn dependency caching.

\* Added linting using `yarn lint`.

\* Added TypeScript type checking using `yarn typecheck`.

\* Added unit tests using `yarn test:unit`.

\* Added integration tests using `yarn test`.

\* Added a fresh Twenty test instance for integration testing.

\* Added application build validation using `yarn twenty dev:build`.

\* Added read-only GitHub Actions permissions using `contents: read`.

\* Added concurrency control to cancel outdated CI runs.

\* Added a 30-minute job timeout for reliability.



\## CI Workflow



The improved pipeline performs the following steps:



1\. Checkout the repository.

2\. Start a fresh Twenty test instance.

3\. Enable Corepack.

4\. Set up Node.js using the version specified in `.nvmrc`.

5\. Install dependencies using the immutable Yarn lockfile.

6\. Run linting.

7\. Run TypeScript type checking.

8\. Run unit tests.

9\. Run integration tests.

10\. Build the application.



If any step fails, the GitHub Actions job fails automatically.



\## Issue Encountered and Solution



Initially, the CI workflow failed during the Twenty test instance/dev sync because of a page layout validation error:



```text

INVALID\_PAGE\_LAYOUT\_WIDGET\_DATA:

Position layoutMode "GRID" does not match tab layoutMode "VERTICAL\_LIST"

```



The affected widget had the universal identifier:



```text

3f7638d4-3d27-4106-b655-f4815dc154a0

```



The page layout configuration was corrected by changing the tab layout mode from `VERTICAL\_LIST` to `GRID` so that it matched the widget configuration.



After pushing the fix, the CI workflows were executed again successfully.



\## Local Validation



The following commands were used to validate the application locally:



```bash

yarn lint

yarn typecheck

yarn test:unit

yarn twenty dev:build

```



The application build completed successfully.



\## Pull Request Verification



A Pull Request was created from:



```text

SAKHI-123/devops-crm-project

sakhisurakhya/task-4

```



to:



```text

PearlThoughts-Intern-DevOps/devops-crm-project

main

```



GitHub Actions automatically triggered the workflows for the Pull Request.



The final verification showed:



\* CI / test — Successful

\* CI Improvements / Lint, Typecheck, Test and Build — Successful



Therefore, the improved CI pipeline was successfully implemented and verified on the Pull Request.



