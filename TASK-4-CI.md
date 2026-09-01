# Task 4: Continuous Integration (CI)

## Overview

This task implements and improves Continuous Integration (CI) for the `devops-crm-project` using GitHub Actions.

The objective was to create an automated CI pipeline that validates code changes whenever a Pull Request is opened or updated.

The improved workflow is implemented in:

```text
.github/workflows/ci-improvements.yml
```

---

## Objectives

The CI pipeline is designed to:

* Install project dependencies reliably.
* Run linting/code quality checks.
* Run TypeScript type checking.
* Run unit tests.
* Run integration tests against a Twenty test instance.
* Validate the application build.
* Cache Yarn dependencies to improve execution time.
* Use minimal GitHub Actions permissions.
* Cancel outdated CI runs when new commits are pushed.
* Apply a timeout to prevent indefinitely running jobs.
* Fail the workflow when any required validation step fails.
* Automatically execute on Pull Request activity.

---

## Existing CI Workflow Review

Before creating the improved workflow, the existing `.github/workflows/ci.yml` was reviewed.

The existing workflow already provided:

* Repository checkout.
* Twenty test instance.
* Node.js setup.
* Yarn dependency installation.
* Linting.
* Type checking.
* Unit testing.
* Integration testing.

However, the workflow could be improved in areas such as:

* Explicit job timeout.
* Better concurrency handling.
* Explicit Node.js/Yarn verification.
* Clearer step organization.
* Dependency caching configuration.
* Build validation.
* Explicit minimal permissions.
* More reliable CI execution and failure handling.

The improved workflow was therefore created separately instead of modifying the original workflow.

---

## Improved CI Workflow

The new workflow is:

```text
.github/workflows/ci-improvements.yml
```

### Trigger

The workflow runs automatically for Pull Requests when they are:

* Opened
* Updated with new commits
* Reopened

Configuration:

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
```

This ensures that CI runs automatically whenever the PR changes.

---

## CI Pipeline Steps

The pipeline performs the following steps.

### 1. Checkout Repository

The source code is checked out using:

```yaml
uses: actions/checkout@v4
```

This provides the workflow with the latest PR code.

---

### 2. Enable Corepack

Corepack is enabled before the Node.js/Yarn setup:

```yaml
- name: Enable Corepack
  run: corepack enable
```

This ensures the project's package manager configuration can be used consistently.

---

### 3. Setup Node.js

Node.js is configured using the project's `.nvmrc`:

```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version-file: '.nvmrc'
    cache: yarn
```

Using `.nvmrc` keeps the CI Node.js version aligned with the project.

The Yarn cache also reduces dependency installation time on subsequent runs.

---

### 4. Verify Node.js and Yarn

The workflow verifies the installed versions:

```yaml
- name: Verify Node.js and Yarn versions
  run: |
    node --version
    yarn --version
```

This makes the CI environment easier to diagnose if a version-related issue occurs.

---

### 5. Install Dependencies

Dependencies are installed using:

```yaml
yarn install --immutable
```

The `--immutable` option prevents Yarn from silently modifying the lockfile.

This helps ensure that CI uses the exact dependency state committed to the repository.

---

### 6. Lint

The workflow runs:

```yaml
yarn lint
```

This checks the source code for configured linting/code-quality issues.

If linting fails, the CI job fails.

---

### 7. Type Checking

The workflow runs:

```yaml
yarn typecheck
```

This validates TypeScript types without relying only on runtime tests.

If type checking fails, the CI job fails.

---

### 8. Unit Tests

Unit tests are executed using:

```yaml
yarn test:unit
```

This validates individual application components and logic.

---

### 9. Spawn Twenty Test Instance

A temporary Twenty test instance is created using:

```yaml
uses: twentyhq/twenty/.github/actions/spawn-twenty-app-dev-test@main
```

The workflow receives the test server URL and API key from the action outputs.

---

### 10. Integration Tests

Integration tests are executed using:

```yaml
yarn test
```

The Twenty test instance credentials are provided through environment variables:

```yaml
env:
  TWENTY_API_URL: ${{ steps.twenty.outputs.server-url }}
  TWENTY_API_KEY: ${{ steps.twenty.outputs.api-key }}
```

This allows integration tests to communicate with the isolated test instance.

---

### 11. Build Validation

The final CI validation step runs:

```yaml
yarn twenty dev:build
```

This verifies that the application can successfully build.

A successful build provides additional confidence that the application is deployable.

---

## Reliability Improvements

### Concurrency

The workflow uses:

```yaml
concurrency:
  group: improved-ci-${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true
```

If a developer pushes a new commit while an older CI run is still executing, the outdated run can be cancelled.

This avoids wasting CI resources on obsolete commits.

---

### Job Timeout

The CI job has:

```yaml
timeout-minutes: 20
```

This prevents a stuck CI process from running indefinitely.

---

## Security Improvements

The workflow explicitly uses:

```yaml
permissions:
  contents: read
```

This follows the principle of least privilege by giving the workflow only the repository content permission it requires.

Secrets and API credentials are passed through workflow environment variables rather than being hardcoded into the workflow.

---

## Failure Handling

The CI steps are executed as separate workflow steps.

GitHub Actions automatically stops the job when a required step fails.

Therefore, failures in:

* Dependency installation
* Linting
* Type checking
* Unit tests
* Integration tests
* Build validation

cause the CI workflow to fail.

This prevents a Pull Request from appearing healthy when an important validation stage has failed.

---

# Issues Faced and Solutions

## Issue 1: Page Layout Configuration Failure

During the initial GitHub Actions run, the integration test failed with:

```text
INVALID_PAGE_LAYOUT_WIDGET_DATA

Position layoutMode "GRID" does not match tab layoutMode "VERTICAL_LIST"
```

### Root Cause

The page layout tab was configured with:

```typescript
layoutMode: PageLayoutTabLayoutMode.VERTICAL_LIST
```

while the widget position was configured using grid positioning.

### Solution

The tab layout mode was changed to:

```typescript
layoutMode: PageLayoutTabLayoutMode.GRID
```

This made the tab layout mode consistent with the widget's grid position configuration.

After the change, the integration tests passed.

---

## Issue 2: Local Twenty Authentication Failure

While running integration tests locally, the following error appeared:

```text
Authentication failed on remote "local"
```

The local Twenty server itself was healthy:

```text
http://localhost:2020
```

and `/healthz` returned:

```text
200
```

### Root Cause

The test environment uses:

```text
~/.twenty/config.test.json
```

while the normal CLI configuration uses a different configuration file.

The test configuration contained an invalid/stale API key.

### Solution

The test configuration was updated using the valid API key from the local Twenty configuration.

After updating the test configuration:

```text
NODE_ENV=test yarn twenty remote:status
```

returned:

```text
Remote:  local
Server:  http://localhost:2020
Auth:    api-key (valid)
```

The integration test was then executed successfully.

---

# Local Test Verification

The integration test was successfully executed locally.

Result:

```text
Test Files  1 passed
Tests       2 passed
```

The tests included:

```text
✓ App installation
✓ CoreApiClient
```

The unit tests were also successfully executed:

```text
Test Files  1 passed
Tests       1 passed
```

The application build completed successfully:

```text
✓ Build succeeded
```

---

# Pull Request Verification

The changes were pushed to the branch:

```text
task-4-abhishek
```

A Pull Request was created against the repository.

The GitHub Actions CI workflows automatically executed on the Pull Request.

Final result:

```text
CI / test                  ✅ Successful
Improved CI / CI Checks    ✅ Successful
```

Both workflows completed successfully.

The PR was intentionally **not merged**, as the task instructions required only raising the Pull Request for review.

---

# Files Changed

The main files involved in this task are:

```text
.github/workflows/ci-improvements.yml
src/__tests__/schema.integration-test.ts
src/page-layouts/main-page.page-layout.ts
```

The new CI workflow was created from scratch without replacing the existing `ci.yml`.

---

# Final CI Flow

The improved CI pipeline can be summarized as:

```text
Pull Request
     │
     ▼
Checkout Repository
     │
     ▼
Enable Corepack
     │
     ▼
Setup Node.js + Yarn Cache
     │
     ▼
Verify Node.js / Yarn
     │
     ▼
Install Dependencies
     │
     ▼
Lint
     │
     ▼
Typecheck
     │
     ▼
Unit Tests
     │
     ▼
Spawn Twenty Test Instance
     │
     ▼
Integration Tests
     │
     ▼
Build Application
     │
     ▼
       PASS ✅
```

If any required stage fails, the CI workflow fails.

---

# Conclusion

The improved GitHub Actions CI pipeline provides automated validation for Pull Requests.

It performs dependency installation, linting, type checking, unit testing, integration testing, and build validation while also improving reliability through dependency caching, concurrency control, job timeouts, and explicit minimal permissions.

The final Pull Request successfully passed both the existing CI workflow and the newly implemented improved CI workflow.
