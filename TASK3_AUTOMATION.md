# Twenty CRM Local Setup and Automation

## 1. Project Overview

**Repository:** `PearlThoughts-Intern-DevOps/devops-crm-project`

This project contains a Twenty CRM application that was cloned and configured for local development as part of the PearlThoughts DevOps internship task.

## 2. Project Structure

The main project directories and configuration files were explored to understand the application:

* `.github` — GitHub-related configuration
* `.yarn` — Yarn-related files
* `src` — application source code
* `public` — public/static files
* `package.json` — project configuration and available scripts
* `yarn.lock` — dependency lock file
* `SETUP.md` — setup instructions
* `README.md` — project information
* `tsconfig.json` — TypeScript configuration

The project uses **Yarn 4.13.0** through Corepack.

## 3. Local Setup

The repository was cloned to the local system and the project dependencies were installed.

The Twenty CRM Docker environment was started locally using the project's Twenty CLI commands.

The application was successfully verified at:

`http://localhost:2020`

The Twenty Docker environment reported:

`Status: running (healthy)`

The application was also opened successfully in the browser.

## 4. Python Automation

A Python script named `setup.py` was created to automate the local setup and startup verification process.

The script performs the following operations:

1. Checks whether Docker is available.
2. Checks the current Twenty CRM Docker status.
3. Starts Twenty CRM when it is not already running.
4. Waits for the application to become available.
5. Performs an HTTP availability check.
6. Displays the Twenty CRM application URL after successful verification.
7. Reports errors when required services are unavailable.

Python was used for the automation as required by the task.

**No shell (`.sh`) scripts were used.**

## 5. Automation Testing

The automation script was executed using:

```text
python setup.py
```

The script completed successfully and produced the following results:

* Docker availability was verified.
* Twenty CRM was detected as running and healthy.
* The application was verified at `http://localhost:2020`.
* The automation process completed successfully.

The successful execution confirms that the Python automation can verify the local Twenty CRM environment and application availability.

## 6. Application Verification

The Twenty CRM application was verified through the local browser using:

`http://localhost:2020`

The application loaded successfully, confirming that the local environment was working.

## 7. Issues Faced and Solutions

### 7.1 Initial Twenty CRM Health-Check Issue

During the initial startup, the following message appeared:

```text
Registering cron jobs... Failed
Twenty server did not become healthy in time.
```

The Twenty CRM status was checked afterward using:

```text
corepack yarn twenty docker:status
```

The result showed:

```text
Status: running (healthy)
URL: http://localhost:2020
```

The application subsequently became healthy and accessible.

**Solution:** The application status was rechecked after the initial startup period. The Twenty CRM Docker environment recovered and reached a healthy state, so no reinstallation was required.

### 7.2 Integration Test Issue

While validating the project locally, the integration-test command was executed:

```text
corepack yarn test
```

The command reported:

```text
No test files found, exiting with code 1
```

The configured integration-test pattern was:

```text
src/**/*.integration-test.ts
```

The development synchronization process also reported configuration validation errors:

```text
INVALID_PAGE_LAYOUT_WIDGET_DATA
```

The error indicated that the position layout mode `GRID` did not match the tab layout mode `VERTICAL_LIST`.

Another error reported:

```text
INVALID_FRONT_COMPONENT_INPUT
```

This indicated that a resource path contained backslashes, which were not accepted by the application configuration.

The integration-test setup therefore failed during the development synchronization stage.

### 7.3 Unit Test Verification

The unit tests were executed separately using:

```text
corepack yarn test:unit
```

The result was successful:

```text
Test Files  1 passed
Tests       1 passed
```

This confirmed that the available unit test passed successfully.

The integration-test issues were related to the project's existing application/test configuration and were not caused by the Python automation script.

## 8. Git Workflow

A personal Git branch was created:

```text
ambu-kumar
```

The Python automation script was committed with:

```text
Add Python automation for local setup
```

Commit:

```text
8c20718
```

The documentation was then added and committed with:

```text
Add documentation for CRM setup automation
```

Commit:

```text
e31acd4
```

Both commits were pushed to the remote `ambu-kumar` branch.

## 9. Pull Request

A Pull Request was created from:

```text
ambu-kumar
```

into:

```text
main
```

**Pull Request:** Add Python automation for local Twenty CRM setup

The Pull Request contains:

* `setup.py`
* `TASK3_AUTOMATION.md`

## 10. CI Validation

The repository CI integration test currently reports a failure during the integration-test setup.

The failure is related to the integration-test configuration and development synchronization errors described above.

The unit test completed successfully locally.

The Python automation script also completed successfully and verified the local Twenty CRM environment.

## 11. Loom Demonstration

A Loom video demonstrating the local setup, Twenty CRM application, Python automation, and Git workflow will be provided below:

**Loom Video:** `[PASTE YOUR LOOM LINK HERE]`

## 12. Final Result

The Twenty CRM application was successfully configured and run locally.

The Python automation script was created and successfully executed to verify Docker availability, Twenty CRM status, and application availability.

The required automation was implemented using Python, and no shell (`.sh`) script was used.

The setup process, automation workflow, validation results, issues faced, solutions, Git workflow, and Pull Request information have been documented in this file.

## CI Test Result

The GitHub Actions integration test failed during the test setup because of a Twenty CRM page-layout configuration mismatch.

The error was:

`INVALID_PAGE_LAYOUT_WIDGET_DATA: Position layoutMode "GRID" does not match tab layoutMode "VERTICAL_LIST"`

The Vite configuration messages were warnings and were not the main cause of the failure.

The unit test was verified separately and passed successfully.

## Loom Demo

Loom video: https://www.loom.com/share/7b7426a80a7146a3bed7a3081ed57a6b