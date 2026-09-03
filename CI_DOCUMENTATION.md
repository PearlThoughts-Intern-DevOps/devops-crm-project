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
## Issues Encountered During CI Verification

### Page Layout Validation Error

The initial CI integration test failed during Twenty application synchronization with:

`INVALID_PAGE_LAYOUT_WIDGET_DATA`

The page layout tab was configured with `VERTICAL_LIST` while the widget used a grid position.

The tab layout mode was changed to:

`PageLayoutTabLayoutMode.GRID`

This made the tab layout compatible with the widget's `gridPosition` configuration.

### Windows Resource Path Issue

When running integration tests locally on Windows, the Twenty CLI generated resource paths containing Windows backslashes, resulting in:

`INVALID_FRONT_COMPONENT_INPUT: Resource path must not contain backslashes`

The application synchronized successfully when tested in WSL, where paths use forward slashes.

The GitHub Actions workflow runs on `ubuntu-latest`, so the CI environment uses Linux-style paths.

### Local Validation

The following checks were successfully completed locally:

- `yarn lint`
- `yarn typecheck`
- `yarn test:unit`
- `yarn twenty dev:build`

The full integration test command can require a running and authenticated Twenty development environment. On Windows, the Twenty CLI may additionally encounter path-separator issues because generated resource paths contain backslashes.

