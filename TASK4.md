# Task 4 – Continuous Integration Improvements

## Project

PearlThoughts DevOps CRM Project using the Twenty CRM application.

## Objective

The objective was to review the existing GitHub Actions CI workflow and create an improved CI pipeline from scratch.

The improved workflow is located at:

`.github/workflows/ci-improvements.yml`

## Existing CI Review

The existing `ci.yml` already provided:

- Pull Request triggering
- Node.js setup
- Yarn dependency installation
- Yarn caching
- Linting
- Type checking
- Unit tests
- Integration tests
- Read-only repository permissions
- Concurrency control

## Improvements Introduced

The new workflow improves the existing CI pipeline through:

- Separate quality, integration, and build jobs
- Explicit CI status validation
- Job-level timeout limits
- Yarn dependency caching
- Security auditing
- Application build validation
- Least-privilege repository permissions
- Pull Request event filtering
- Automatic cancellation of outdated workflow runs
- Clear separation of CI stages
- Explicit failure handling

## CI Workflow

The workflow runs automatically when a Pull Request is:

- Opened
- Synchronised with new commits
- Reopened

## Pipeline Stages

### 1. Quality Checks

The quality job:

1. Checks out the repository.
2. Enables Corepack.
3. Sets up Node.js using `.nvmrc`.
4. Uses Yarn dependency caching.
5. Installs dependencies using immutable mode.
6. Runs linting.
7. Runs TypeScript type checking.
8. Runs unit tests.
9. Runs a dependency security audit.

### 2. Integration Tests

The integration job:

1. Checks out the repository.
2. Starts an isolated Twenty test instance.
3. Enables Corepack.
4. Sets up Node.js.
5. Installs dependencies using immutable mode.
6. Runs integration tests against the temporary Twenty instance.

The Twenty API URL and API key are provided to the integration tests through GitHub Actions environment variables.

### 3. Build Validation

The build job validates that the application can be built successfully using:

