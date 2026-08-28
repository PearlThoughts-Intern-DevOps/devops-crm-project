# Day 4 – Continuous Integration (CI) Improvements

---

## 1. Objective & Task Overview

The objective of Day 4 is to implement an improved Continuous Integration (CI) pipeline for the `devops-crm-project` using GitHub Actions (`.github/workflows/ci-improvements.yml`).

---

## 2. Review of Existing CI Workflow

The existing `.github/workflows/ci.yml` provided basic CI functionality:
- Repository checkout
- Node.js setup using `.nvmrc`
- Yarn dependency installation
- Linting
- Type checking
- Unit tests
- Integration tests using a Twenty test instance

### Areas Identified for Improvement
- Adding explicit Node.js and Yarn version verification logs.
- Enhancing security for repository checkout (`persist-credentials: false`).
- Adding job timeout control for reliability (`timeout-minutes: 15`).
- Implementing concurrency control to automatically cancel outdated CI runs on pull request updates.
- Adding an explicit application build validation step (`yarn twenty dev:build`).
- Ensuring deterministic dependency installation via `yarn install --immutable`.

---

## 3. New CI Improvements Workflow

A new workflow file was created at `.github/workflows/ci-improvements.yml`.

### Workflow Triggers
The workflow triggers automatically when a Pull Request is:
- Opened
- Synchronized (updated with new commits)
- Reopened

### Workflow Execution Stages
1. **Checkout Repository:** Clones repository with `persist-credentials: false`.
2. **Setup Node.js:** Loads Node.js version from `.nvmrc` with Yarn caching enabled.
3. **Enable Corepack:** Activates Yarn 4 Berry package manager.
4. **Verify Node.js and Yarn Versions:** Outputs `node --version` and `yarn --version`.
5. **Install Dependencies:** Executes `yarn install --immutable`.
6. **Run Lint:** Executes `yarn lint` (`oxlint`).
7. **Run Typecheck:** Executes `yarn typecheck` (`tsgo`).
8. **Run Unit Tests:** Executes `yarn test:unit` via Vitest.
9. **Spawn Twenty Test Instance:** Starts temporary server container via Twenty GitHub Action.
10. **Run Integration Tests:** Executes `yarn test` with `TWENTY_API_URL` and `TWENTY_API_KEY`.
11. **Build Application:** Executes `yarn twenty dev:build` to validate compilation.

---

## 4. Pipeline Components & Local Validation Results

### 4.1 Dependency Installation
- Installed using `yarn install --immutable` to strictly match the lockfile.
- Dependency cache managed through `actions/setup-node@v4` with `cache: yarn`.

### 4.2 Linting & Type Checking
- `yarn lint` checks code formatting and lint rules.
- `yarn typecheck` verifies TypeScript typing rules.
- Both checks must exit with code `0`.

### 4.3 Unit Testing
- Executed via `yarn test:unit`.
- **Result:**
  ```text
  Test Files  1 passed
  Tests       1 passed
  ```

### 4.4 Integration Testing
- Spawns a temporary Twenty instance using `twentyhq/twenty/.github/actions/spawn-twenty-app-dev-test@main`.
- Configures environment variables `TWENTY_API_URL` and `TWENTY_API_KEY`.
- Executed via `yarn test`.
- **Result:**
  ```text
  Test Files  1 passed
  Tests       2 passed
  ```

### 4.5 Build Validation
- Executed via `yarn twenty dev:build`.
- **Result:**
  ```text
  Build succeeded (5 files)
  ```

---

## 5. Security & Reliability Enhancements

| Feature | Implementation | Purpose |
| :--- | :--- | :--- |
| **Least Privilege Permissions** | `permissions: contents: read` | Restricts `GITHUB_TOKEN` scope to read-only access. |
| **Credential Security** | `persist-credentials: false` | Prevents token persistence in Git configuration after checkout. |
| **Timeout Protection** | `timeout-minutes: 15` | Prevents stuck or hanging CI jobs. |
| **Concurrency Control** | `concurrency: group: ...` | Automatically cancels outdated runs on PR update. |

---

## 6. Failure Handling & Strict Enforcement

The workflow is designed to fail if any step encounters an error. The following commands must succeed:
```bash
yarn install --immutable
yarn lint
yarn typecheck
yarn test:unit
yarn test
yarn twenty dev:build
```
If any step returns a non-zero exit code, the pipeline immediately halts and marks the pull request check as failed, preventing invalid code from merging into `main`.

---

## 7. Issues Faced & Resolutions

### 1. Node.js Version Mismatch
- **Issue:** Local active environment was running Node.js `v22.23.0`, whereas `.nvmrc` required `24.5.0`.
- **Resolution:** Switched active Node.js version using NVM:
  ```bash
  nvm use 24.5.0
  ```

### 2. TypeScript Typecheck Failure (`schema.integration-test.ts`)
- **Issue:** `yarn typecheck` failed because `created.createNote` was potentially `undefined`.
- **Resolution:** Added explicit assertion check in `src/__tests__/schema.integration-test.ts`:
  ```typescript
  expect(created.createNote).toBeDefined();

  if (!created.createNote) {
    throw new Error('Failed to create integration test note');
  }
  ```
  After updating, `yarn typecheck` passed with zero errors.

### 3. Integration Test Server Connection Failure
- **Issue:** Local test run failed initially because Twenty server was not running on `localhost:2020`.
- **Resolution:** Started Docker containers and dev environment via `yarn twenty docker:start`.

---

## 8. Local Verification & PR Submission

### Full Local Validation Command
```bash
yarn lint && yarn typecheck && yarn test:unit && yarn test && yarn twenty dev:build
```

### Verification Summary
- **Lint:** PASSED
- **Typecheck:** PASSED
- **Unit Tests:** PASSED
- **Integration Tests:** PASSED
- **Build Validation:** PASSED

### Git Workflow & Pull Request
- **Working Branch:** `bkkrish007`
- **Workflow File:** `.github/workflows/ci-improvements.yml`
- **Target Branch:** `main`

---

## 9. Demonstration Video (Loom)

- **Loom Video Link:** [https://www.loom.com/share/67be2b0cb14841a093b0294e5d4a5243](https://www.loom.com/share/67be2b0cb14841a093b0294e5d4a5243)
- **Demonstration Highlights:**
  - Overview of Pull Request and GitHub Actions workflow execution.
  - Pipeline stages breakdown (Lint, Typecheck, Unit/Integration tests, Build).
  - Validation of CI check results on GitHub.

---

## 10. Conclusion

Day 4 successfully upgraded the project's Continuous Integration process by introducing `.github/workflows/ci-improvements.yml`. The new pipeline provides deterministic dependency management, comprehensive unit and integration testing, build validation, least-privilege security permissions, job timeouts, and concurrency control.
