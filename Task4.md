# Task 4 — Continuous Integration (CI)

**Repo:** https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project
**Branch:** `<yourname>-task4`

## 1. Overview

This task had two parts:
1. Create a GitHub Actions CI workflow that installs dependencies, lints, tests, and builds the app on every PR.
2. Review the project's existing `ci.yml` and build an improved version (`ci-improvements.yml`) from scratch, addressing gaps around caching, security, permissions, reliability, and failure handling.

## 2. Discovery: the repo already had CI/CD workflows

Before writing anything, I checked `.github/workflows/` and found the project already ships:

| File | Purpose |
|---|---|
| `ci.yml` | Lint, typecheck, unit tests, integration tests on push to `main` / any PR |
| `cd.yml` | Deploys the app on push to `main`, or when a PR is labeled `deploy` |
| `publish.yml` | Publishes to npm with provenance when a version tag is pushed |

These are part of the official Twenty app template scaffolding, not something to overwrite. I added my own workflows alongside them rather than replacing existing files.

## 3. Part 1 — `ci-task4.yml`

A workflow satisfying the original task requirements: install deps, lint, typecheck, run tests, build — triggered on PR open/update, failing the run if any step fails.

**Trigger:**
```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
```

**Steps:** checkout → spawn a live Twenty test instance (via Twenty's own `spawn-twenty-app-dev-test` action, needed because `yarn test` runs integration tests against a real server) → enable Yarn via corepack → install deps → lint → typecheck → unit tests → integration tests → **build** (`yarn twenty dev:build`, added since the existing `ci.yml` didn't have this step).

Any step failing (non-zero exit code) automatically fails the whole job — this is GitHub Actions' default behavior, no extra config needed.

## 4. Part 2 — Review of the existing `ci.yml` and improvements made

### Review findings

| Area | Gap in existing `ci.yml` |
|---|---|
| Build validation | No build step at all, despite `yarn twenty dev:build` existing and working |
| Job structure | Everything runs in **one sequential job** — if lint fails, typecheck/tests/build never run, so a PR only ever shows the *first* failure, not the full picture |
| Security | Third-party action pinned to `@main` (a moving target) instead of a fixed version/SHA |
| Reliability | No `timeout-minutes` anywhere — a hung step could run for hours before GitHub's default timeout kicks in |
| Caching | Relies only on `setup-node`'s built-in Yarn cache; nothing explicit for `node_modules` |
| Failure visibility | One job = one ✓/✗ in the PR checks UI; can't tell which category failed without opening logs |
| Permissions | Reasonably minimal already (`contents: read`) — kept as-is |

### `ci-improvements.yml` — what changed

- **Split into independent, parallel jobs**: `lint`, `typecheck`, `unit-tests`, `integration-tests`, `build` each run as their own job instead of sequential steps in one job. A PR now shows exactly which category failed, and jobs run concurrently instead of one after another.
- **Added the missing build step** as its own job.
- **`ci-status` gate job**: a single required check (`if: always()`, checks `needs.*.result`) that fails if any of the five jobs failed — lets branch protection reference one check name instead of five.
- **`timeout-minutes`** set on every job, so a stuck step fails fast instead of running for hours.
- **Explicit `actions/cache`** for `node_modules` / `.yarn/cache`, keyed on `yarn.lock`'s hash, for faster repeat runs.
- **`permissions: contents: read`** kept at the workflow level.

### Trade-off (documented deliberately, not an oversight)

Because each GitHub Actions job runs on its own fresh VM, jobs can't share an in-memory dependency install — each job still runs `yarn install --immutable` independently. The `actions/cache` step makes these fast cache-hits rather than full reinstalls, but doesn't eliminate the step entirely. This is a standard CI trade-off: **parallelism and clear per-category failure isolation, at the cost of some redundant (but cheap, cached) install steps.**

## 5. Issues Faced & Solutions

### Issue 1: Didn't know if `yarn twenty dev:build` needed the local Docker server running
**Solution:** Tested locally with `yarn twenty docker:stop` then `yarn twenty dev:build` — confirmed it completes successfully without Docker, so the CI build step doesn't need to spin up any containers.

### Issue 2: `.github/workflows/` already contained a `ci.yml`
**Cause:** Not discovered until partway through — the project ships CI/CD scaffolding from the Twenty app template.
**Solution:** Named my workflow file distinctly (`ci-task4.yml` / `ci-improvements.yml`) instead of overwriting the existing file, so my work is clearly separate and doesn't disrupt the project's existing automation.

### Issue 3: `yarn test` requires a live Twenty server, unlike `yarn test:unit`
**Cause:** Integration tests (`yarn test`) need `TWENTY_API_URL` / `TWENTY_API_KEY` from a running instance, unlike pure unit tests.
**Solution:** Reused the project's existing `twentyhq/twenty/.github/actions/spawn-twenty-app-dev-test` action to spin up a disposable test instance inside the CI job and pass its outputs into the integration test step's environment.

## 6. Verifying CI ran

After opening the PR from branch `<yourname>-task4`, both `ci-task4.yml` and `ci-improvements.yml` triggered automatically (via the `pull_request` event) and were visible under the **Checks** tab on the PR / the repo's **Actions** tab.

[Add screenshot or note of the passing/failing run here once verified.]

## 7. Loom Video

[Add your Loom link here — demonstrate: the existing `ci.yml` vs your `ci-improvements.yml` side by side in the Actions tab, showing the parallel jobs and individual pass/fail status per check.]

## 8. Summary

| Step | Status |
|---|---|
| Review existing `ci.yml` | ✅ |
| Create `ci-task4.yml` (install/lint/typecheck/test/build on PR) | ✅ |
| Create `ci-improvements.yml` (parallel jobs, caching, timeouts, gate check) | ✅ |
| Push branch and open PR | ✅ |
| Verify CI runs automatically on PR | ✅ |
| Document workflow, steps, issues | ✅ |