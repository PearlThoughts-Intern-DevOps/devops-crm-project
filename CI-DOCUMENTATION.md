# Task 04 — CI Documentation
**PearlThoughts DevOps Internship**

---

## Overview

Two GitHub Actions workflows were created for the `devops-crm-project`:

| File | Purpose |
|---|---|
| `.github/workflows/ci.yml` | Basic CI — single job, sequential steps |
| `.github/workflows/ci-improvements.yml` | Improved CI — parallel jobs, caching, security, gate |

Both trigger automatically on any Pull Request targeting `main` or `master`.

---

## Workflow 1 — `ci.yml` (Basic)

### Steps (run sequentially in one job)

1. **Checkout** — fetches the PR branch code
2. **Setup Node.js** — reads version from `.nvmrc`
3. **Corepack** — enables Yarn without a separate install
4. **Install dependencies** — `yarn install --frozen-lockfile`
   - `--frozen-lockfile` ensures `yarn.lock` is never mutated in CI
5. **Lint** — `yarn lint` runs oxlint against `.oxlintrc.json`
6. **Type check** — `yarn typecheck` runs `tsgo --noEmit`
7. **Test** — `yarn test` runs vitest

If any step returns a non-zero exit code, the workflow fails immediately and the PR is blocked.

---

## Workflow 2 — `ci-improvements.yml` (Production-Grade)

### Improvements over the basic workflow

| Area | What was done |
|---|---|
| **Parallel jobs** | Lint, Typecheck, Test, Security run simultaneously — faster feedback |
| **Caching** | `~/.yarn/cache` + `node_modules` cached on `yarn.lock` hash — avoids re-downloading packages on every run |
| **Permissions** | `contents: read` + `pull-requests: read` — least-privilege; no accidental write access |
| **Concurrency** | `cancel-in-progress: true` — if you push a second commit to the same PR, the old run is cancelled immediately |
| **Timeouts** | Each job has `timeout-minutes` — a hung test suite doesn't burn GitHub Actions minutes forever |
| **Security audit** | `yarn npm audit --severity high` — fails on high/critical CVEs in dependencies |
| **CI Gate job** | A final `ci-gate` job that depends on all others — set this as the single required status check in branch protection settings |
| **Frozen lockfile** | `--frozen-lockfile` on every install step |

### Job diagram

```
PR opened / pushed
        │
   ┌────┴─────────────────────┐
   │         │         │      │
 lint   typecheck    test  security
   │         │         │      │
   └────┬─────────────────────┘
        │
     ci-gate  ← only required check you need in branch protection
```

### Tools used

| Tool | Version source |
|---|---|
| oxlint | `devDependencies` in `package.json` |
| tsgo (TypeScript native preview) | `@typescript/native-preview` in `package.json` |
| vitest | `vitest.config.ts` + `vitest.unit.config.ts` |
| yarn | Corepack (reads `packageManager` field or `.nvmrc`) |

---

## Steps Followed

```bash
# 1. Create branch
git checkout -b shubham-singh

# 2. Create workflow directory
mkdir -p .github/workflows

# 3. Create both workflow files
# (copy ci.yml and ci-improvements.yml into .github/workflows/)

# 4. Add documentation
# (copy CI-DOCUMENTATION.md to project root)

# 5. Commit and push
git add .github/workflows/ci.yml
git add .github/workflows/ci-improvements.yml
git add CI-DOCUMENTATION.md
git commit -m "feat: add CI workflows (Task 04)"
git push origin shubham-singh

# 6. Open Pull Request on GitHub
# Go to repo → Pull Requests → New PR
# base: main  ←  compare: shubham-singh
```

---

## Issues & Solutions

### Issue 1 — No `build` script in `package.json`
**Problem:** The task says "build the application" but the project has no `build` script.  
**Solution:** Used `yarn typecheck` (`tsgo --noEmit`) as the build validation step. A full TypeScript compile with no errors is equivalent to a build check for a library/SDK-style project.

### Issue 2 — Yarn version mismatch in CI
**Problem:** `yarn install` can fail if the CI node version doesn't match the expected Yarn version.  
**Solution:** Added `corepack enable` before every install step. Corepack reads the `packageManager` field in `package.json` and activates the correct Yarn version automatically.

### Issue 3 — `yarn npm audit` vs `yarn audit`
**Problem:** Yarn v2+ (Berry) uses `yarn npm audit`, not `yarn audit`.  
**Solution:** Used `yarn npm audit --severity high` in the security job. Added `|| true` as a fallback option in comments if the team wants warnings-only (non-blocking) audit.

---

## How to Verify

1. Open the PR on GitHub
2. Scroll to the bottom — you'll see status checks appear within ~30 seconds
3. Click **Details** on any check to see the live log
4. All checks must be green for the PR to be mergeable (if branch protection is set)

### Issue 4 — Integration tests require a live Twenty server
**Problem:** `yarn test` runs `schema.integration-test.ts` which connects to a real Twenty backend at `http://localhost:2020`. This fails in GitHub Actions because no server is running.  
**Root cause:** `vitest.config.ts` includes `*.integration-test.ts` files which need `TWENTY_API_URL` pointing to a live instance.  
**Solution:** Changed CI to run `yarn test:unit` instead — unit tests use `vitest.unit.config.ts` which only picks up `*.test.ts` files with no server dependency.
