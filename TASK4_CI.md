# Task 4: Continuous Integration (CI)

## Overview

For Task 4, I reviewed the existing GitHub Actions CI workflow and created a new improved CI pipeline from scratch using GitHub Actions.

The new workflow is available at:

`.github/workflows/ci-improvements.yml`

It is configured to automatically run whenever a Pull Request is opened, updated, or reopened.

## Existing CI Workflow Review

The existing `.github/workflows/ci.yml` already provided basic CI functionality.

It included:

- Pull Request and main branch triggers
- Node.js setup
- Yarn dependency installation
- Dependency caching
- Linting
- Type checking
- Unit tests
- Integration tests

However, there were areas that could be improved:

- No application build validation
- No dependency security audit
- No job timeout
- Limited reliability controls
- External test setup action uses a moving `main` reference
- Node and Yarn versions were not explicitly verified
- CI structure could provide stronger failure and concurrency handling

## Improved CI Pipeline

The new `.github/workflows/ci-improvements.yml` adds the following improvements:

### 1. Pull Request Trigger

The workflow runs automatically when a Pull Request is:

- Opened
- Updated
- Reopened

### 2. Dependency Installation

Dependencies are installed using:

`yarn install --immutable`

This ensures that the lockfile is respected and unexpected dependency changes are not introduced during CI.

### 3. Node.js and Yarn Verification

The workflow uses the project's `.nvmrc` file for the Node.js version and verifies the installed Node.js and Yarn versions.

### 4. Dependency Caching

GitHub Actions Node.js caching is enabled for Yarn dependencies to improve workflow execution time.

### 5. Linting

The workflow runs:

`yarn lint`

This checks the source code for linting issues.

### 6. Type Checking

The workflow runs:

`yarn typecheck`

This validates the TypeScript code and catches type-related problems.

### 7. Unit Testing

The workflow runs:

`yarn test:unit`

Unit tests are required to pass for the CI job to continue.

### 8. Integration Testing

A Twenty test instance is started before integration tests.

The workflow then runs:

`yarn test`

with the required Twenty API environment variables.

### 9. Build Validation

The application build is validated using:

`yarn twenty dev:build`

The supported `dev:build` command is used instead of the deprecated `twenty build` command.

### 10. Security

A Yarn dependency security audit is included:

`yarn npm audit --all`

The audit is currently non-blocking so that dependency advisories do not prevent otherwise successful CI checks from completing.

### 11. Permissions

The workflow uses least-privilege permissions:

`contents: read`

This prevents unnecessary repository write access.

### 12. Concurrency

Concurrency control is enabled so that outdated CI runs for the same Pull Request can be cancelled when a newer commit is pushed.

### 13. Timeout and Failure Handling

The CI job has a 20-minute timeout.

Linting, type checking, unit tests, integration tests, and build validation are blocking steps. If any of these steps fail, the CI job fails.

## Local Verification

Before pushing the workflow, the following checks were performed locally:

- `yarn install --immutable` — Passed
- `yarn lint` — Passed with 0 warnings and 0 errors
- `yarn typecheck` — Passed
- `yarn test:unit` — Passed with 1 test passed
- `yarn twenty dev:build` — Passed successfully

During the initial build verification, `yarn twenty build` worked but displayed a deprecation warning. It was replaced with the recommended `yarn twenty dev:build` command.

## Pull Request Verification

A branch named:

`Kaushal-Sharma-Task-4`

was created and pushed to the repository.

A Pull Request was created against the `main` branch.

The GitHub Actions workflow was automatically triggered on the Pull Request.

### Initial CI Run

The first CI run failed during the integration testing stage.

The Twenty test instance reported a dev synchronization error related to page layout widget data, and the integration test process exited with code 1.

This was not caused by linting, type checking, unit tests, or the application build.

### Successful CI Run

After the Pull Request was synchronized, GitHub Actions automatically triggered the improved CI workflow again.

The subsequent CI run completed successfully.

All major CI stages passed:

- Checkout
- Node.js setup
- Dependency installation
- Security audit
- Lint
- Typecheck
- Unit tests
- Twenty test instance setup
- Integration tests
- Application build

The successful GitHub Actions run confirms that the improved CI pipeline works correctly on the Pull Request.

## Conclusion

The new CI pipeline provides stronger automated validation for the project by combining dependency installation, caching, linting, type checking, unit testing, integration testing, security auditing, and build validation.

It also improves reliability through permissions, concurrency control, version verification, timeout handling, and clear failure behavior.
