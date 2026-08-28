## Continuous Integration (Task 4)

This project uses a GitHub Actions workflow that runs automatically on
every Pull Request.

| File | What it is |
|---|---|
| [`.github/workflows/ci.yml`](./.github/workflows/ci.yml) | The CI workflow. |
| [`ci.pdf`](./ci.pdf) | Full documentation of the workflow and the steps followed to build it. |

### What the workflow does

**Triggers on:** push to `main`, and Pull Request open/update/reopen.

1. Checkout the code.
2. Spawn a live Twenty test instance (needed for integration tests).
3. Enable Corepack and set up Node.js (version from `.nvmrc`).
4. Install dependencies — `yarn install --immutable`.
5. Lint — `yarn lint`.
6. Typecheck — `yarn typecheck`.
7. Unit tests — `yarn test:unit`.
8. Integration tests — `yarn test`, against the live Twenty instance.
9. Build the application — `yarn twenty dev:build`.

If any step fails, the workflow fails and the PR shows a red status check.

See [`ci.pdf`](./ci.pdf) for full details.
