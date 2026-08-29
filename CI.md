Continuous Integration (CI)
Overview
GitHub Actions CI was implemented for the devops-crm-project.

The workflow file is:

.github/workflows/ci.yml

The CI workflow automatically runs when a Pull Request is opened or updated.

CI Workflow Steps
Checkout — Checks out the project code.
Spawn Twenty test instance — Starts a temporary Twenty server for integration tests.
Setup Node.js — Uses the Node.js version specified in .nvmrc.
Install dependencies — Runs yarn install --immutable.
Lint — Runs yarn lint.
Typecheck — Runs yarn typecheck.
Unit tests — Runs yarn test:unit.
Integration tests — Runs yarn test using the temporary Twenty server.
Build — Runs yarn twenty dev:build.
If any step fails, GitHub Actions reports the workflow as failed.

Build Verification
The application build was tested locally using:

./node_modules/.bin/twenty.cmd dev:build

The build completed successfully.

Issues and Solutions
Build command
The project does not have a normal yarn build script. The Twenty CLI provides the correct build command.

Solution:

yarn twenty dev:build

Windows CLI execution
On the Windows local environment, the Twenty CLI was executed using:

./node_modules/.bin/twenty.cmd dev:build

The build completed successfully.

CI Verification
The CI workflow was triggered automatically by Pull Request #41.

The GitHub Actions CI / test check completed successfully.

Loom Demonstration
The Loom video demonstrates the CI workflow and the successful GitHub Actions result on Pull Request #41.

Loom link: [https://www.loom.com/share/be24d323631045c58b7f0af8033ad5fd]

