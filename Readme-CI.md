# CI Improvements – Twenty CRM App

This project implements an improved GitHub Actions CI pipeline for the Twenty CRM application. The workflow validates the application through dependency installation, linting, type checking, unit tests, integration tests, and build validation.

## CI Workflow

The workflow is located at:

```text
.github/workflows/ci-improvements.yml
```

It runs automatically when:

* A Pull Request is opened, updated, or reopened against `main`.
* Code is pushed to the `chirag-sabharwal-ci-improvements` branch.

The pipeline includes Yarn caching, dependency validation, security permissions, concurrency control, timeout handling, linting, type checking, unit testing, integration testing, and application build validation.

## Issues Faced & Resolutions

### 1. Yarn Version Mismatch

**Issue:** GitHub Actions detected Yarn `1.22.22`, while the project requires Yarn `4.13.0`.

**Resolution:** Enabled Corepack and explicitly activated Yarn `4.13.0` before installing dependencies.

### 2. Yarn Cache Initialization

**Issue:** `setup-node` attempted to access Yarn before Corepack was enabled.

**Resolution:** Moved Yarn setup before dependency installation and used GitHub Actions cache for the Yarn cache directory.

### 3. Integration Test Dependency

**Issue:** Integration tests require a running Twenty server.

**Resolution:** Added the Twenty test-instance action before running integration tests and passed its generated API URL and API key to the test environment.

### 4. Build Validation

**Issue:** The existing CI workflow did not explicitly validate the application build.

**Resolution:** Added:

```bash
yarn twenty dev:build
```

to verify that the application can be successfully built.

## Verification

The CI pipeline verifies:

```text
Dependencies
     ↓
Lint
     ↓
Typecheck
     ↓
Unit Tests
     ↓
Integration Tests
     ↓
Build
```

If any required step fails, GitHub Actions marks the workflow as failed.

## Result

The improved CI workflow provides automated validation for Pull Requests and helps ensure that code is properly linted, type-checked, tested, and buildable before merging.
