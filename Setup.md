= DevOps CRM - Local Setup

== Prerequisites

* Node.js 24.x
* Yarn 4.13.0
* Docker Desktop
* WSL 2

== Setup

Clone the repository:

[source,bash]
----
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
----

Install dependencies:

[source,bash]
----
yarn install
----

Start Docker/Twenty:

[source,bash]
----
yarn twenty docker:start
----

Start development:

[source,bash]
----
yarn twenty dev
----

Open:

[source,text]
----
http://localhost:2020
----

== Python Automation

Run:

[source,bash]
----
python3 setup.py
----

The script automates:

[source,text]
----
yarn install
     |
Docker/Twenty startup
     |
Application health check
     |
yarn twenty dev
----

== Issues Faced

=== Windows Path Separator Issue

The application generated Windows backslash paths:

[source,text]
----
.twenty\output\public\logo.svg
.twenty\output\src\front-components\main-page.mjs
----

The error was:

[source,text]
----
INVALID_FRONT_COMPONENT_INPUT:
Resource path must not contain backslashes
----

Forward-slash path normalization was attempted on Windows, but the issue still occurred during application synchronization.

The `twenty-sdk@2.35.1` package was patched using Yarn 4 and stored under:

[source,text]
----
.yarn/patches/
----

=== WSL and Node.js Issue

Windows Node/Yarn was initially being used inside WSL, causing:

[source,text]
----
exec: node: not found
----

Ubuntu 22.04 was configured with Node.js and Yarn for the project.

=== Docker WSL Issue

Docker was initially unavailable inside WSL.

Solution: enabled Docker Desktop WSL Integration for Ubuntu-22.04.

=== Twenty Startup Timeout

Twenty initially reported a health-check timeout, but the container logs showed that the database and cron jobs were running successfully.

== Git Workflow

[source,bash]
----
git checkout -b rohith
git add setup.py SETUP.adoc package.json .yarn/patches
git commit -m "Add Python automation for local setup"
git push -u origin rohith
----


