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
## Integration Test Troubleshooting

During CI verification, the integration-test stage encountered a Twenty application synchronization validation error:

`INVALID_PAGE_LAYOUT_WIDGET_DATA`

The error indicated that the position layout mode `GRID` did not match the tab layout mode `VERTICAL_LIST`.

The failure occurred during the Twenty development synchronization process in `src/__tests__/global-setup.ts`.

A separate local test attempt also showed that the local Twenty server remote could require re-authentication:

`Authentication failed on remote "local"`

These issues are related to the Twenty development/test environment and existing application configuration rather than the CI workflow changes.

The CI workflow intentionally allows these failures to propagate so that CI does not report a false successful build when tests cannot execute successfully.

