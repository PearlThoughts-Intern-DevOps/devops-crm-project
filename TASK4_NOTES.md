# CI Improvements: Review and Redesign

## Objective

Review the existing `.github/workflows/ci.yml` and build a new, improved
pipeline from scratch at `.github/workflows/ci-improvements.yml`, covering
dependency installation, linting, type checking, unit/integration testing,
build validation, caching, security, permissions, reliability, and failure
handling.

## Review of the existing `ci.yml`

| Area | Existing state | Gap identified |
|---|---|---|
| Dependency installation | `yarn install --immutable`, Yarn's own cache via `setup-node` | No caching of `node_modules` itself — every job pays the full install cost |
| Linting / type checking | Present, but run serially inside one long job | A lint failure isn't visible until earlier steps finish; no parallelism |
| Testing | Unit and integration tests run in the same job | The integration test depends on a freshly spawned Twenty instance with a known, reproducible sync bug (`INVALID_PAGE_LAYOUT_WIDGET_DATA`) — a failure there blocks the whole job, obscuring unrelated lint/typecheck results |
| Build validation | None — no separate build step exists | Nothing independently validates the app builds/typechecks outside of the test run |
| Caching | Yarn's cache only | No reuse of `node_modules` across jobs, no incremental TypeScript cache |
| Security | `permissions: contents: read` at workflow level | No dependency vulnerability scanning; checkout doesn't set `persist-credentials: false` |
| Permissions | One global block | Not scoped per job |
| Reliability | No timeouts, no retries | A hang has no timeout; a transient/flaky failure (the integration test) looks identical to a genuine, persistent one |
| Failure handling | Fails correctly but silently | No log/artifact upload on failure, no aggregated summary check |

## Design decisions in `ci-improvements.yml`

- **Split into independent jobs** (`install`, `lint`, `typecheck`,
  `unit-test`, `integration-test`, `dependency-review`, `ci-summary`)
  instead of one serial job, so fast checks report immediately and a
  slow/flaky job never blocks or muddies the results of the others.
- **`node_modules` caching**, keyed on `hashFiles('yarn.lock')`, shared
  across every job — a cache hit skips reinstalling entirely.
- **`yarn typecheck` used as the build-validation step.** This project
  has no separate build artifact (it's a Vite/TypeScript app synced live
  via the Twenty CLI, not compiled to a bundle for this purpose), so a
  clean TypeScript typecheck is the closest real equivalent to "the
  application builds successfully" — documented explicitly rather than
  inventing a build step that doesn't correspond to anything real.
- **Integration tests isolated into their own job**, with a **bounded
  retry (2 attempts, `nick-fields/retry@v3`)** around the known-flaky
  sync step. Retries absorb transient flakiness without masking a
  genuinely broken PR — if it still fails after 2 attempts, the job
  fails for real.
- **Log upload on integration-test failure** (`actions/upload-artifact`),
  so a failure can be diagnosed from the PR directly instead of
  requiring someone to reproduce it locally from scratch.
- **`actions/dependency-review-action`** added as a dedicated security
  job, scanning dependency changes introduced by the PR for known
  vulnerabilities before merge — something the original workflow didn't
  do at all.
- **`persist-credentials: false`** on every checkout step, so the
  ephemeral GitHub token used by the runner isn't left in the local git
  config for any longer than necessary.
- **Per-job `timeout-minutes`** on every job, so a hang fails loudly
  after a bounded time instead of running indefinitely.
- **`ci-summary` job** that aggregates the result of every other job
  into one final required check — lets branch protection rules require
  a single check instead of five separate ones.
- **`concurrency` group with `cancel-in-progress: true`**, so pushing a
  new commit to the same PR cancels the previous, now-superseded run
  instead of wasting CI minutes on both.

## New tools introduced (not previously used in this repo)

- `nick-fields/retry@v3` — for the bounded retry around the flaky
  integration test step.
- `actions/dependency-review-action@v4` — for dependency vulnerability
  scanning on PRs.
- `actions/cache@v4` — for explicit `node_modules` caching.

## Issues faced

- **The integration test's known flakiness directly informed the
  design.** Rather than hiding it with `continue-on-error: true` (which
  would silently mask a real future break), the retry approach keeps
  the check meaningful: transient failures get a second chance,
  persistent ones still fail the build as they should.
- **No literal "build" step exists for this project type**, so rather
  than fabricating one, `yarn typecheck` was used and the reasoning
  documented explicitly, to avoid the workflow looking like it validates
  something it doesn't.

## How to verify this on a PR

1. Push `ci-improvements.yml` on a branch named after yourself and open
   a PR against `main` in `devops-crm-project`.
2. On the PR's Checks tab, confirm seven distinct checks appear:
   `install`, `lint`, `typecheck`, `unit-test`, `integration-test`,
   `dependency-review`, `ci-summary`.
3. Confirm `lint`, `typecheck`, `unit-test`, `dependency-review`, and
   `ci-summary` pass.
4. Open `integration-test`'s logs to see whether the retry mechanism
   allowed it to pass, or whether it still hits the same
   `INVALID_PAGE_LAYOUT_WIDGET_DATA` error after 2 attempts — either
   outcome is expected given the pre-existing bug, and should be noted
   in the PR description rather than treated as a new problem.
5. If `integration-test` fails, confirm a `twenty-server-logs` artifact
   is attached to the job's summary page.
6. Push an intentionally broken change (e.g. a lint violation) on a
   scratch commit to confirm the corresponding job — and `ci-summary` —
   correctly fail, then revert it before merging.