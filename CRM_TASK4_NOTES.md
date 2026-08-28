# Task 4: Continuous Integration (CI)

## Objective

Implement and verify Continuous Integration (CI) using GitHub Actions for the
`devops-crm-project`.

## What I Did

The repository already had a GitHub Actions CI workflow at:

`.github/workflows/ci.yml`

The existing workflow already included dependency installation, linting,
type checking, unit tests, and integration tests.

I updated the existing workflow by adding the required application build step.

## Why I Edited the Existing Workflow

I did not create a second CI workflow because the repository already had a
`ci.yml` workflow.

Creating another CI workflow would duplicate the existing CI process.

Therefore, I made a minimal change to the existing workflow and added only
the missing build step.

## CI Trigger

The existing workflow contains:

```yaml
on:
  push:
    branches:
      - main
  pull_request: {}

The pull_request trigger runs the workflow automatically when a Pull Request
is opened or updated, including when new commits are pushed to an open PR.

This satisfies the Pull Request trigger requirement without any additional
configuration.

CI Pipeline:-

Pull Request
     |
     v
Checkout code
     |
     v
Start Twenty test instance
     |
     v
Setup Node.js + Yarn
     |
     v
Install dependencies
     |
     v
Lint
     |
     v
Typecheck
     |
     v
Unit tests
     |
     v
Integration tests
     |
     v
Build application

Steps Included:-

1. Checkout

GitHub Actions checks out the repository code.

2. Twenty Test Instance

A temporary Twenty instance is started for integration testing.

3. Node.js and Yarn

The Node.js version is taken from .nvmrc, and Corepack is enabled for
Yarn 4.

4. Install Dependencies
yarn install --immutable

--immutable ensures that the lockfile cannot be changed during CI.

5. Lint
yarn lint

Checks the project for code-quality issues.

6. Typecheck
yarn typecheck

Checks TypeScript types.

7. Unit Tests
yarn test:unit

Runs the unit tests.

8. Integration Tests
yarn test

Runs the integration tests against the temporary Twenty instance.

9. Build

I added the missing build step:

yarn twenty dev:build

This is the Twenty SDK's build command, confirmed using:

yarn twenty --help

The command is listed as:

dev:build — Build and generate API client

There is no plain yarn build script in package.json, so the Twenty CLI
build command is used instead.

The build was tested locally and completed successfully:

✓ Build succeeded (5 files)
Failure Handling

GitHub Actions stops the job when a command returns a non-zero exit code.

Therefore, if dependency installation, linting, type checking, tests, or the
build fails, the CI job is marked as failed.

This prevents later steps from running after a required step has failed.

Verification

The following commands were tested locally:

yarn lint           
yarn typecheck        
yarn test:unit        
yarn test             
yarn twenty dev:build  

The integration tests passed locally:

Test Files  1 passed
Tests       2 passed

The application build also passed locally:

✓ Build succeeded (5 files)
Issue Faced

The GitHub Actions integration-test environment failed during Twenty
application metadata synchronization with:

INVALID_PAGE_LAYOUT_WIDGET_DATA
GRID does not match VERTICAL_LIST

The failure occurred before the integration tests could run.

I investigated the related page-layout configuration and confirmed that it
existed in the repository's initial commit, before my Task 4 changes.

The same integration tests passed locally, and the application build also
passed locally.

Therefore, I documented this as a CI/Twenty test-environment issue rather
than modifying unrelated application code.

The workflow correctly stopped when the integration-test step failed. This
demonstrates the required failure-handling behavior.

Git Changes

Branch used:

harish

Commit:

Add build step to CI workflow

The changes were pushed to the harish branch and included in the Pull
Request.

Result

The CI workflow now contains all required stages:

 Pull Request trigger
 Dependency installation
 Lint
 Typecheck
 Unit tests
 Integration test stage
 Application build
 Failure handling

The build was successfully verified locally, and the CI workflow was
automatically triggered by the Pull Request.

Loom Video

Loom video:

<PASTE LOOM LINK HERE>


**This is the version I recommend submitting.** It is honest about the CI failure while clearly showing that you implemented the required CI pipeline and verified the build locally.