# TASK 4 – Continuous Integration (CI)

## Project

**Repository:** devops-crm-project  
**Branch:** saketh  
**Workflow:** `.github/workflows/ci-improvements.yml`

## 1. Objective

The objective of this task is to review the existing GitHub Actions CI workflow and create an improved CI pipeline.

The improved CI pipeline automatically validates the project when a Pull Request is opened, updated, or reopened.

The CI pipeline includes:

- Dependency installation
- Dependency caching
- Linting
- Type checking
- Unit testing
- Integration testing
- Security checking
- Application build validation
- Restricted permissions
- Concurrency control
- Failure handling

## 2. Existing CI Workflow Review

The existing workflow is located at:

`.github/workflows/ci.yml`

The existing workflow included:

- Pull Request triggers
- Node.js setup
- Yarn dependency installation
- Yarn dependency caching
- Linting
- Type checking
- Unit tests
- Full tests

### Areas Identified for Improvement

The improved workflow adds:

- Separate quality checks
- Separate unit-test job
- Separate integration-test job
- Separate security-check job
- Separate build-validation job
- Read-only repository permissions
- Concurrency control
- Job dependencies
- Failure handling

## 3. Improved CI Workflow

A new workflow was created at:

`.github/workflows/ci-improvements.yml`

The workflow triggers automatically when a Pull Request is:

- Opened
- Updated with new commits
- Reopened

## 4. Dependency Installation

The project uses:

- Node.js `24.5.0`
- Yarn `4.13.0`

The Node.js version is configured using `.nvmrc`.

Dependencies are installed using:

`yarn install --immutable`

The `--immutable` option ensures that the lockfile is not unexpectedly modified during CI.

Yarn dependency caching is enabled through `actions/setup-node`.

## 5. Linting

The project uses Oxlint for code-quality checks.

The CI workflow runs:

`yarn lint`

Result:

`Found 0 warnings and 0 errors.`

## 6. Type Checking

Type checking is performed using:

`yarn typecheck`

The type-checking process completed successfully.

## 7. Unit Testing

Unit tests are executed using:

`yarn test:unit`

Result:

`1 test passed.`

## 8. Integration Testing

Integration tests are executed using:

`yarn test`

Result:

`2 tests passed.`

## 9. Build Validation

The application build is validated using:

`yarn twenty dev:build`

Result:

`Build succeeded.`

The build job depends on the quality, unit-test, and integration-test jobs.

## 10. Security Check

A dependency security audit is included using:

`yarn npm audit --all`

This checks project dependencies for known security vulnerabilities.

## 11. Permissions

The workflow uses restricted repository permissions:

`permissions: contents: read`

This follows the principle of least privilege by providing read-only access to repository contents.

## 12. Reliability and Concurrency

Concurrency control is configured to cancel older CI runs when a newer commit is pushed to the same Pull Request.

This reduces unnecessary CI usage and ensures that the latest changes are tested.

## 13. CI Jobs

The improved workflow contains five jobs:

### Quality

**Job:** Lint and Type Check

Commands:

- `yarn install --immutable`
- `yarn lint`
- `yarn typecheck`

### Unit Tests

**Job:** Unit Tests

Commands:

- `yarn install --immutable`
- `yarn test:unit`

### Integration Tests

**Job:** Integration Tests

Commands:

- `yarn install --immutable`
- `yarn test`

### Security

**Job:** Security Check

Commands:

- `yarn install --immutable`
- `yarn npm audit --all`

### Build

**Job:** Build Application

Commands:

- `yarn install --immutable`
- `yarn twenty dev:build`

The build depends on:

Quality → Unit Tests → Integration Tests → Build

## 14. Local Testing

Before pushing the workflow to GitHub, the CI commands were tested locally.

### Dependency Installation

Command:

`yarn install --immutable`

Result:

`Completed successfully with warnings.`

### Lint

Command:

`yarn lint`

Result:

`Found 0 warnings and 0 errors.`

### Type Checking

Command:

`yarn typecheck`

Result:

`Passed successfully.`

### Unit Tests

Command:

`yarn test:unit`

Result:

`1 test passed.`

### Integration Tests

Command:

`yarn test`

Result:

`2 tests passed.`

### Build

Command:

`yarn twenty dev:build`

Result:

`Build succeeded.`

## 15. Issues Encountered

### Issue 1 – Yarn Peer Dependency Warning

During dependency installation, Yarn displayed a peer dependency warning related to `monaco-editor` being requested by `twenty-ui`.

This was only a warning and did not cause dependency installation or tests to fail.

### Issue 2 – Vite Configuration Warnings

Vitest displayed warnings related to the Vite configuration and future changes to Vite's native configuration loader.

These warnings did not cause the tests to fail.

Both unit tests and integration tests completed successfully.

## 16. Failure Handling

The workflow is designed to fail if any required command fails.

The following commands will cause their respective jobs to fail if they return a failure status:

- `yarn lint`
- `yarn typecheck`
- `yarn test:unit`
- `yarn test`
- `yarn npm audit --all`
- `yarn twenty dev:build`

The build job depends on the Quality, Unit Tests, and Integration Tests jobs.

Therefore, a failed required validation job prevents the build from proceeding successfully.

## 17. Git Workflow

The work is completed on the personal branch:

`saketh`

The changes are staged using:

`git add .github/workflows/ci-improvements.yml TASK4.md`

The changes are committed using:

`git commit -m "improve GitHub Actions CI pipeline"`

The changes are pushed to the personal fork using:

`git push origin saketh`

The Pull Request is created from:

`saketh`

to:

`main`

in the official repository.

## 18. Pull Request Verification

After pushing the changes, GitHub Actions automatically runs the `CI Improvements` workflow.

Expected jobs:

- Lint and Type Check
- Unit Tests
- Integration Tests
- Security Check
- Build Application

The workflow will be verified from the GitHub Actions tab and the Pull Request checks section.


## 19. Final Result

The improved CI pipeline provides automated validation for Pull Requests.

The pipeline includes:

- Dependency installation
- Dependency caching
- Linting
- Type checking
- Unit testing
- Integration testing
- Security checking
- Build validation
- Restricted permissions
- Concurrency control
- Failure handling

This ensures that code changes are automatically checked before they are merged into the main branch.

## 20. Files Changed

- `.github/workflows/ci-improvements.yml`
- `TASK4.md`

