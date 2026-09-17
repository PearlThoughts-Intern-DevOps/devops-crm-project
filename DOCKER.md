# Docker Containerization - Twenty CRM

## Overview

This document details the Docker containerization implementation for the Twenty CRM project. The setup includes a multi-stage Dockerfile for building the frontend application and a Docker Compose configuration for orchestrating the full-stack application with PostgreSQL and Redis.

## Architecture

The containerization consists of three main services:

1. **App (twenty-app)**: The main Twenty CRM application
   - Uses the official `twentycrm/twenty:latest` image for production stability
   - Exposed on port 2020
   - Configured with environment variables for database and cache connections

2. **PostgreSQL (twenty-postgres)**: Relational database
   - Uses `postgres:15-alpine` for minimal footprint
   - Persistent volume for data durability
   - Exposed on port 5432

3. **Redis (twenty-redis)**: In-memory cache
   - Uses `redis:7-alpine` for performance
   - Exposed on port 6379

## Docker Best Practices Implemented

### 1. Multi-Stage Build (Dockerfile)
The custom Dockerfile uses a three-stage build process:
- **Stage 1 (deps)**: Installs dependencies with layer caching
- **Stage 2 (build)**: Builds the application
- **Stage 3 (production)**: Serves static files using Nginx Alpine

### 2. Minimal Base Images
- Uses Alpine variants (`node:24-alpine`, `nginx:alpine`, `postgres:15-alpine`)
- Reduces image size and attack surface
- Faster pull and deployment times

### 3. Layer Caching
- Copies `package.json` and `yarn.lock` before source code
- Dependencies are cached and only reinstalled when manifest files change
- Significantly speeds up rebuilds

### 4. Security
- Non-root execution (Nginx runs as non-root by default)
- Read-only permissions where applicable
- Secrets managed via environment variables

### 5. Reliability & Orchestration
- Custom bridge network for service isolation
- Persistent volumes for database data
- Health checks for database readiness
- Automatic restart policies (`unless-stopped`)
- Proper service dependencies with `depends_on`
