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

### Workflow

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
