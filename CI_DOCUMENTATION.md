\# Continuous Integration (CI)



\## Overview



A GitHub Actions CI workflow is used to automatically validate the DevOps CRM project whenever a Pull Request is opened or updated.



\## Workflow



The CI workflow is defined in:



`.github/workflows/ci.yml`



The workflow runs on:



\- Pull Request creation

\- Pull Request updates

\- Pushes to `main`



\## CI Steps



The workflow performs the following checks:



1\. Checks out the repository.

2\. Starts a temporary Twenty test instance.

3\. Enables Corepack.

4\. Sets up the Node.js version specified in `.nvmrc`.

5\. Installs dependencies using Yarn.

6\. Runs linting.

7\. Runs TypeScript type checking.

8\. Runs unit tests.

9\. Runs integration tests.

10\. Builds the application.



\## Commands



The main project commands used by CI are:



```bash

yarn install --immutable

yarn lint

yarn typecheck

yarn test:unit

yarn test

yarn twenty dev:build

