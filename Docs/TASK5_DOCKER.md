# Task 5 – Docker Containerization

## Objective

The objective of this task was to containerize the devops-crm-project using Docker and Docker Compose.

## Project Overview

The project is a Twenty CRM application using:

- Node.js 24.5.0
- Yarn 4.13.0
- Twenty SDK
- Docker
- Docker Compose

## Docker Files Created

The following Docker-related files were created:

- `Dockerfile`
- `.dockerignore`
- `docker-compose.yml`

## Dockerfile

The Dockerfile uses a multi-stage build approach.

### Stage 1 – Dependencies

The dependency stage uses Node.js 24.5 and installs the project dependencies using Yarn.

### Stage 2 – Build

The build stage copies the application source code and runs:

    yarn twenty dev:build

This generates the application output.

### Stage 3 – Runtime

The runtime stage uses a lightweight Node.js image and copies the required application files from the previous stages.

## .dockerignore

The `.dockerignore` file excludes unnecessary files such as:

- node_modules
- .git
- .github
- .twenty
- coverage
- build artifacts
- environment files
- editor configuration files
- log files

This reduces the Docker build context.

## Docker Compose

Docker Compose is used to run the Twenty CRM development server.

The Compose configuration includes:

- Twenty application container
- Port mapping
- Persistent Docker volume
- Automatic restart policy
- Docker network

## Port Configuration

The application is exposed on:

    2020

The application can be accessed at:

    http://localhost:2020

## Persistent Storage

A Docker volume named:

    twenty-data

is used to persist application data.

## Docker Network

Docker Compose creates a dedicated network:

    devops-crm-project_default

This allows the Compose services to communicate through Docker networking.

## Commands Used

### Build Docker Image

    docker build -t devops-crm-image:latest .

### Check Docker Images

    docker images

### Start the application

    docker compose up -d

### Check running containers

    docker compose ps

### Validate Compose configuration

    docker compose config

### View logs

    docker compose logs

### Stop the application

    docker compose down

## Verification

The Docker environment was successfully verified.

Node.js version inside the Docker image:

    v24.5.0

Yarn version inside the Docker image:

    4.13.0

The Twenty server health endpoint was successfully verified using:

    curl http://localhost:2020/healthz

The response was:

    {"status":"ok","info":{},"error":{},"details":{}}

Docker Compose also showed the Twenty container running successfully with port 2020 exposed.

## Issues Faced and Solutions

### Issue 1 – Docker and WSL integration

Initially, Docker Desktop encountered a WSL-related issue where the `install` command was unavailable inside the Ubuntu environment.

### Solution

The missing system utility was investigated and the Docker/WSL environment was repaired. Docker was subsequently verified using:

    docker info

### Issue 2 – Twenty server startup

Initially, the Twenty server was not ready and requests to the server failed.

### Solution

The container was restarted and the server was allowed to complete its initialization. The health endpoint was then checked successfully.

### Issue 3 – Docker image tag

The image was available with the `latest` tag while testing was attempted using the `task5` tag.

### Solution

The existing image tag was identified using:

    docker images

The correct image tag was then used for verification.

## Docker Best Practices

The implementation follows Docker best practices including:

- Multi-stage Docker build
- Lightweight Node.js base image
- Separate dependency and build stages
- `.dockerignore` usage
- Persistent Docker volume
- Docker Compose for container management
- Environment/configuration separation
- Explicit port configuration

## Final Verification

The following checks were successful:

- Docker image built successfully
- Node.js 24.5.0 verified
- Yarn 4.13.0 verified
- Docker Compose configuration validated
- Twenty container running successfully
- Port 2020 accessible
- `/healthz` endpoint returned status OK
- Application accessible through localhost

## Conclusion

The devops-crm-project was successfully containerized and configured to run using Docker and Docker Compose. The application environment was verified successfully and the setup was documented.
