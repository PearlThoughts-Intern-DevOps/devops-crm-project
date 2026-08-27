# Task 3 - Local Setup and Python Automation

## 1. Overview

This task involved setting up the PearlThoughts DevOps CRM project locally, understanding the project structure, running the Twenty CRM application through Docker, validating the development environment, and creating a Python script to automate the local setup and startup workflow.

The project is a Twenty application built using the Twenty SDK, TypeScript, React, and Yarn. The local Twenty server runs through Docker.

---

## 2. Environment

The setup was performed on a MacBook with Apple Silicon (ARM64).

### Tools and versions

- Node.js: `24.5.0`
- Yarn: `4.13.0`
- Docker: `29.6.2`
- Python 3: available
- Docker architecture: `aarch64`

The required Node.js version was identified from `.nvmrc`.

The required Yarn version was identified from `package.json`, which specifies:

```text
packageManager: yarn@4.13.0
