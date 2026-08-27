# Twenty CRM Local Setup and Automation

## 1. Project

Repository: `PearlThoughts-Intern-DevOps/devops-crm-project`

The project is a Twenty CRM application that was cloned and configured for local development.

## 2. Project Structure

The main project directories and files were explored to understand the application:

* `.github` — GitHub-related configuration
* `src` — application source code
* `public` — public/static files
* `.yarn` — Yarn-related files
* `package.json` — project configuration and scripts
* `yarn.lock` — dependency lock file
* `SETUP.md` — setup instructions
* `README.md` — project information
* `tsconfig.json` — TypeScript configuration

The project uses Yarn 4.13.0 through Corepack.

## 3. Local Setup

The repository was cloned to the local system and dependencies were installed.

The Twenty CRM Docker environment was started using the project's Twenty CLI commands.

The application was successfully started and verified at:

`http://localhost:2020`

The Docker environment reported:

`Status: running (healthy)`

## 4. Python Automation

A Python script named `setup.py` was created to automate the local setup/startup verification process.

The script performs the following:

1. Checks whether Docker is available.
2. Checks the current Twenty CRM status.
3. Starts Twenty CRM if it is not already running.
4. Waits for the application to become available.
5. Performs an HTTP health check.
6. Displays the application URL after successful startup.
7. Reports errors if the application cannot become available.

Python was used for the automation as required by the task. No `.sh` shell script was used.

## 5. Automation Test

The following command was executed:

```text
python setup.py
```

The script successfully:

* Verified Docker availability.
* Detected that Twenty CRM was running and healthy.
* Verified the application at `http://localhost:2020`.
* Completed the setup process successfully.

## 6. Issue Faced

During the initial Twenty CRM startup, the following message appeared:

`Registering cron jobs... Failed`

The startup process also reported that the Twenty server did not become healthy within the initial time limit.

The Twenty status was checked afterward using:

```text
corepack yarn twenty docker:status
```

The result showed:

`Status: running (healthy)`

Therefore, the issue was related to the initial startup/health-check timing, and the application subsequently became healthy and available.

## 7. Git Workflow

A personal branch was created:

`ambu-kumar`

The Python automation script was committed with:

`Add Python automation for local setup`

Commit:

`8c20718`

The branch was pushed to the remote repository and a Pull Request was created.

## 8. Pull Request

Pull Request:

`Add Python automation for local Twenty CRM setup`

The Pull Request contains the Python automation and this documentation.

## 9. Loom Demonstration

Loom video demonstrating the local setup and Python automation:

`[PASTE YOUR LOOM LINK HERE]`

## 10. Final Result

The Twenty CRM application was successfully configured and verified locally.

The Python automation script successfully verified the Docker environment, checked the Twenty CRM health status, and confirmed application availability.

The required automation was implemented using Python without using shell scripts.
