# Task 4 — Continuous Integration (CI)

## CI Workflow

Implemented Continuous Integration using GitHub Actions for the DevOps CRM project.

The workflow runs automatically when a Pull Request is opened or updated.

### CI Steps

1. Checkout the repository.
2. Set up Node.js using the version specified in `.nvmrc`.
3. Install project dependencies using Yarn.
4. Run linting.
5. Run type checking.
6. Run unit tests.
7. Run integration tests.
8. Build the application.

### Workflow## Issues Faced & Solutions

- The initial CI run failed during the integration test stage with a page layout validation error:
  `GRID` did not match the tab's `VERTICAL_LIST` layout mode.
- The issue was caused by the widget using `gridPosition` while its parent tab used `VERTICAL_LIST`.
- Removed the `gridPosition` configuration from the widget.
- Verified the fix locally using `yarn test` and `yarn twenty dev:build`.
- Both commands completed successfully.

```text
Pull Request
     ↓
Checkout
     ↓
Setup Node.js
     ↓
Install Dependencies
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
     ↓
CI Passed
```

### Verification

The CI workflow was triggered automatically on the Pull Request and verified through GitHub Actions.
