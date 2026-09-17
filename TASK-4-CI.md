# Task 4: Continuous Integration (CI)

## Objective

Implemented an improved GitHub Actions CI pipeline for the `devops-crm-project`.

## Existing CI Review

The existing `.github/workflows/ci.yml` already included:

- Pull request triggering
- Dependency installation using Yarn
- Linting
- Type checking
- Unit tests
- Integration tests
- Twenty test instance

Areas improved in the new workflow:

- Dedicated CI improvements workflow
- Explicit PR event triggers
- Yarn dependency caching through `setup-node`
- Type checking as a separate CI step
- Unit and integration testing
- Application build validation
- Dependency security audit
- Read-only repository permissions
- Concurrency control to cancel outdated PR runs
- Failure handling through separate CI steps

## New Workflow

Created:

`.github/workflows/ci-improvements.yml`

The workflow runs automatically when a Pull Request is:

- Opened
- Updated (`synchronize`)
- Reopened

## CI Pipeline Steps

The workflow performs the following steps:

1. Checkout repository
2. Spawn a Twenty test instance
3. Enable Corepack
4. Set up Node.js using `.nvmrc`
5. Install dependencies using `yarn install --immutable`
6. Run linting
7. Run TypeScript type checking
8. Run unit tests
9. Run integration tests
10. Build the application
11. Run a high-severity dependency security audit

## Local Verification

The following commands were tested locally:

```bash
yarn install --immutable
yarn lint
yarn typecheck
yarn test:unit
yarn test
yarn twenty dev:build
yarn npm audit --all --recursive --severity high

## Issues Faced and Solutions

### Integration Test Failure

During CI verification, the integration test initially failed during Twenty application sync with the following error:

`INVALID_PAGE_LAYOUT_WIDGET_DATA: Position layoutMode "GRID" does not match tab layoutMode "VERTICAL_LIST"`

The issue was caused by a mismatch between the page layout tab's layout mode and its grid-based widget positioning.

The page layout configuration was updated from:

`PageLayoutTabLayoutMode.VERTICAL_LIST`

to:

`PageLayoutTabLayoutMode.GRID`

After the change, the integration test was verified locally and passed successfully with 2 tests passing.

### Twenty Test Image Version

The CI workflow initially used `v2.35.1` for the Twenty test instance, but the corresponding Docker image was not available.

The workflow was changed to use:

`TWENTY_VERSION: latest`

After this change, the CI workflow completed successfully.