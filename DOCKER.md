# Docker Setup - Twenty CRM

## Overview

This project is a Twenty CRM application containerized using Docker and Docker Compose.

## Dockerfile

The Dockerfile uses a multi-stage build:

1. Dependencies stage
   - Uses Node.js 24 Alpine
   - Enables Corepack
   - Installs dependencies using Yarn 4.13.0

2. Application stage
   - Uses Node.js 24 Alpine
   - Copies installed dependencies
   - Copies application source code
   - Creates a non-root `appuser`
   - Runs the application build as the non-root user

## Docker Ignore

The `.dockerignore` excludes unnecessary files such as:

- node_modules
- .yarn
- environment files
- logs
- coverage
- dist
- .twenty
- Git files

This reduces the Docker build context.

## Docker Compose

Docker Compose runs the following services:

- `twenty-app` - Builds the Twenty application using the custom Dockerfile.
- `twenty-server` - Runs the Twenty development server.

Both services communicate through a dedicated Docker bridge network.

The Twenty server exposes port `2020`.

## Volumes

Persistent Docker volumes are configured for:

- PostgreSQL data
- Twenty local storage

## Environment Variables

The Twenty server is configured with environment variables including:

- `APP_SECRET`
- `APP_VERSION`
- `NODE_ENV`
- `NODE_PORT`
- `PG_DATABASE_URL`
- `REDIS_URL`
- `STORAGE_TYPE`
- `IS_BILLING_ENABLED`

## Commands Used

### Build Docker image

```bash
docker build -t twenty-app-task5 .
