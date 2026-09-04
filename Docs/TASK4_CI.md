# Task 4 – Continuous Integration (CI)

## Objective

Implemented Continuous Integration (CI) using GitHub Actions for the DevOps CRM project.

## CI Workflow

The CI workflow is located at:

`.github/workflows/ci.yml`

The workflow runs automatically when a Pull Request is opened or updated.

## CI Steps

The workflow performs the following steps:

1. Checkout the repository
2. Set up Node.js using `.nvmrc`
3. Enable Corepack
4. Start a Twenty test instance
5. Install project dependencies
6. Run linting
7. Run type checking
8. Run unit tests
9. Run integration tests
10. Build the application

## Commands

Dependencies:

```bash
yarn install --immutable
