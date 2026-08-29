# Task 4 - Issues and Solutions

## Issue 1: GitHub Actions detected the wrong Yarn version

### Problem

The first CI run failed during the Node.js setup step because GitHub Actions detected Yarn 1.22.22 instead of the project's required Yarn 4.13.0.

### Solution

The workflow was updated so that Corepack is enabled before the Node.js setup step in all jobs.

The correct order is:

1. Checkout repository.
2. Enable Corepack.
3. Setup Node.js.
4. Install dependencies.

### Result

GitHub Actions correctly used the project's Yarn 4.13.0 configuration.

---

## Issue 2: Integration tests initially failed during cleanup

### Problem

The integration tests reached the cleanup stage, but the application uninstall operation failed because the application could not be found.

The error referenced the application's universal identifier.

### Solution

The integration test teardown logic in `src/__tests__/global-setup.ts` was updated to handle cleanup exceptions safely using error handling.

### Result

The integration tests completed successfully without the cleanup error causing the CI job to fail.

---

## Issue 3: Page layout configuration caused application synchronization failure

### Problem

The application synchronization initially failed because the page layout used `VERTICAL_LIST` while the widget configuration used a grid position.

### Solution

Changed:

`layoutMode: PageLayoutTabLayoutMode.VERTICAL_LIST,`

to:

`layoutMode: PageLayoutTabLayoutMode.GRID,`

### Result

The application synchronized successfully and the integration tests were able to run successfully.

---

## Issue 4: Vite configuration warnings during tests

### Problem

The unit and integration tests displayed Vite warnings related to future `configLoader` behavior and the `vite-tsconfig-paths` plugin.

### Solution

The warnings were documented but not changed because they did not cause the tests to fail.

### Result

The tests completed successfully despite the warnings.

---

## Issue 5: Security audit and CI reliability improvements

### Problem

The original CI workflow did not include a dedicated dependency security audit or explicit job timeouts.

### Solution

The improved workflow added:

- A dedicated dependency security-audit job.
- Job timeouts.
- Explicit read-only repository permissions.
- Disabled credential persistence during checkout.
- Concurrency cancellation for outdated runs.
- Application build validation.

### Result

The improved workflow provides additional security and reliability checks.

---

## Final Verification

The improved workflow was tested through Pull Request #2.

The following jobs completed successfully:

- Lint, Typecheck, Unit Test & Build
- Integration Tests
- Dependency Security Audit

The final CI workflow status was successful.

