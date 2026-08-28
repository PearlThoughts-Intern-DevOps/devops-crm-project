# DevOps CRM Project

## Task 2 — Local Setup & Automation

### 1. Clone Repository

```bash
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
```

### 2. Project Structure

The project is a Twenty application built with React and TypeScript.

Key directories:

* `src/` — application source code
* `src/__tests__/` — tests
* `src/front-components/` — frontend components
* `src/navigation-menu-items/` — navigation items
* `src/page-layouts/` — page layouts
* `public/` — public assets

### 3. Local Setup & Run

Required tools:

* Node.js 24.5.0
* Yarn 4
* Docker

Install dependencies:

```bash
yarn install
```

Start the Twenty Docker server:

```bash
yarn twenty docker:start
```

Check the server:

```bash
yarn twenty docker:status
```

Start the development server:

```bash
yarn twenty dev
```

The application runs at:

```text
http://localhost:2020
```

### 4. Python Automation

A Python script `local-setup.py` was created to automate the local setup and startup process.

Run:

```bash
python3 local-setup.py
```

The script checks the required tools, installs dependencies, starts the Twenty Docker server, and starts the development server.

No `.sh` shell script was used.

### 5. Branch & Pull Request

Task 2 changes were made on the branch:

```text
purva
```

The changes will be pushed to the `purva` branch and submitted through a Pull Request to `main`.

### 6. Issues Faced & Solutions

**Node.js version mismatch**

* Initial version: Node.js 22.22.1
* Required version: Node.js 24.5.0
* Solution: Installed NVM and switched to Node.js 24.5.0.

**Yarn peer dependency warning**

`yarn install` displayed a peer dependency warning related to `monaco-editor`, but installation completed successfully and the application ran correctly.

**Twenty CLI re-authentication**

`yarn twenty dev` requested local re-authentication.

Solution: Selected `Y` and continued. The application then started successfully.

## Thank you!
