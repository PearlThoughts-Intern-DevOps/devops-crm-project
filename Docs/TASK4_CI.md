# Task 4 – Continuous Integration (CI)

## Objective

Implemented and verified Continuous Integration (CI) using GitHub Actions for the `devops-crm-project`.

The repository already contained a CI workflow, so the existing `.github/workflows/ci.yml` was updated instead of creating a separate workflow.

## CI Workflow

The workflow is located at:

```text
.github/workflows/ci.yml
```

The workflow runs automatically when:

* A Pull Request is opened.
* A Pull Request is updated.
* Changes are pushed to the `main` branch.

## CI Steps

The workflow performs the following steps:

1. Checkout the repository.
2. Start a Twenty test instance.
3. Enable Corepack.
4. Set up Node.js using `.nvmrc`.
5. Install dependencies using Yarn.
6. Run linting.
7. Run TypeScript type checking.
8. Run unit tests.
9. Run integration tests.
10. Build the application.

The workflow stops and fails if a required step fails because the commands are executed as GitHub Actions steps and errors return a non-zero exit code.

## Commands Verified Locally

### Install dependencies

```bash
yarn install --immutable
```

### Lint

```bash
yarn lint
```

Result:

```text
Found 0 warnings and 0 errors.
```

### Typecheck

```bash
yarn typecheck
```

Result:

```text
Passed successfully.
```

### Unit tests

```bash
yarn test:unit
```

Result:

```text
Test Files  1 passed
Tests       1 passed
```

### Application build

```bash
yarn twenty dev:build
```

Result:

```text
Build succeeded (5 files)
```

## Issues Faced and Solutions

### 1. TypeScript typecheck error

The integration test reported that `created.createNote` could be `undefined`.

The test was updated to verify the value before accessing its `id`.

This resolved the TypeScript typecheck failure.

### 2. Integration test / page layout validation error

During CI verification, the integration test failed because the page layout widget position used:

```text
GRID
```

while the corresponding tab used:

```text
VERTICAL_LIST
```

The page layout configuration was corrected so that both use the compatible `GRID` layout mode.

After this fix, the CI workflow passed successfully.

### 3. Vite configuration warnings

Some Vite configuration warnings were displayed during tests regarding `configLoader: 'native'` and `vite-tsconfig-paths`.

These were warnings and did not cause the tests or build to fail, so no change was required for Task 4.

## Pull Request

The Task 4 changes were committed to the branch:

```text
vasundara-task4
```

A Pull Request was created from:

```text
vasundara-task4 → main
```

Pull Request:

```text
#32
```

The GitHub Actions CI workflow was automatically triggered by the Pull Request.

## CI Verification

The latest commit:

```text
49aea72 Fix page layout mode for CI
```

successfully passed the GitHub Actions check.

Result:

```text
All checks have passed
1 successful check
```
