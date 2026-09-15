# Task 4 - Continuous Integration (CI) Improvements

## Intern Details

**Name:** Mujtaba Shaikh
**Internship:** DevOps Internship
**Project:** devops-crm-project
**Task:** Task 4 - Continuous Integration (CI) Improvements
**Branch:** Mujtaba-Task-4-PT
**Date:** 28 August 2026

---

# Objective

The objective of this task was to implement an improved Continuous Integration (CI) pipeline for the devops-crm-project using GitHub Actions.

The workflow should automatically run when a Pull Request is opened or updated and perform code quality checks, testing, build validation, and security checks before changes are merged.

---

# Existing CI Workflow Review

Before making any changes, I reviewed the existing workflow:

`.github/workflows/ci.yml`

The existing workflow already included:

* Dependency installation
* Linting
* Type checking
* Unit tests
* Integration tests

As per the task instructions, I did not modify the existing workflow. Instead, I created a new improved workflow from scratch.

---

# New CI Workflow

I created a new workflow file:

`.github/workflows/ci-improvements.yml`

The workflow is automatically triggered when a Pull Request is:

* Opened
* Updated (synchronize)
* Reopened

---

# CI Pipeline Steps

The workflow performs the following steps:

1. Checkout repository code
2. Setup Node.js environment
3. Enable Corepack
4. Install dependencies
5. Run lint checks
6. Run TypeScript type checking
7. Run unit tests
8. Start Twenty test instance
9. Run integration tests
10. Build validation
11. Security audit

Workflow flow:

Pull Request
↓
Install Dependencies
↓
Lint
↓
Type Check
↓
Unit Tests
↓
Spawn Twenty Test Instance
↓
Integration Tests
↓
Build Application
↓
Security Audit

---

# Commands and Purpose

| Command | Purpose |
|----------|----------|
| `yarn lint` | Checks code quality and coding standards. |
| `yarn typecheck` | Validates TypeScript types and catches type-related issues. |
| `yarn test:unit` | Runs unit tests to verify individual components and functions. |
| `yarn test` | Runs integration tests to verify that different parts of the application work together correctly. |
| `yarn twenty dev:build` | Verifies that the application builds successfully without errors. |
| `yarn npm audit --all --recursive` | Checks project dependencies for known security vulnerabilities. |

---

# Improvements Implemented

### Dependency Installation

`yarn install --immutable`

Ensures dependencies match the lockfile and improves consistency.

### Lint Validation

`yarn lint`

Checks code quality and coding standards.

### Type Checking

`yarn typecheck`

Validates TypeScript types before code is merged.

### Unit Testing

`yarn test:unit`

Runs unit tests automatically.

### Integration Testing

`yarn test`

Runs integration tests against a temporary Twenty test environment.

### Build Validation

`yarn twenty dev:build`

Verifies that the application builds successfully.

### Security Audit

`yarn npm audit --all --recursive`

Checks project dependencies for known vulnerabilities.

### Caching

Implemented Yarn dependency caching to improve workflow performance.

### Permissions

Configured minimal GitHub permissions using the principle of least privilege.

---

# Issue Faced and Solution

## Issue

While running `yarn typecheck`, TypeScript reported:

`'created.createNote' is possibly 'undefined'`

## Solution

Added a validation check before accessing the object:

```ts
expect(created.createNote).toBeDefined();

if (!created.createNote) {
  throw new Error('Failed to create note');
}
```

After applying the fix, type checking completed successfully.

---

# Local Verification

The following commands were executed successfully:

```bash
yarn install
yarn lint
yarn typecheck
yarn test:unit
yarn test
yarn twenty dev:build
```

Results:

* Lint Passed
* Type Check Passed
* Unit Tests Passed
* Integration Tests Passed
* Build Passed

Some Vite warnings appeared during testing, but they did not affect the execution or results.

---

# Conclusion

In this task, I reviewed the existing CI workflow and created a new improved GitHub Actions workflow from scratch. The workflow automatically runs on Pull Requests and performs dependency installation, linting, type checking, testing, build validation, and security checks. This improves reliability, code quality validation, security awareness, and overall CI coverage for the project.

