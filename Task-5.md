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
- `docker-compose.yaml`

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
A .dockerignore file was added to prevent unnecessary files from being included in the Docker build context.
The file excludes unnecessary files such as:

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

Docker Compose is used to run the application together with the required Twenty server.

Two services are defined:
``` 
app
twenty
```
The application can be accessed at:

    http://localhost:2020

**App Service**

The `app` service is built using the project's Dockerfile:
```yaml
build:
context: .
dockerfile: Dockerfile
```

**Twenty Service**

The Twenty server uses:
``` 
twentycrm/twenty-app-dev:latest
```
The container's port `2020` is mapped to host port `2020`:
```yaml
ports:
  - "2020:2020"
```

The Twenty service uses a named Docker volume:
```yaml
volumes:
  - twenty-data:/data
```
The service is configured with:
```yaml
NODE_ENV: development
```

**Networking**
Both services are connected to the same Docker bridge network:
```yaml
networks:
  crm-network:
    driver: bridge
```
This allows the containers to communicate using Docker's service-name based networking.

**Persistent Storage**

A named Docker volume is used for the Twenty service:
```yaml
volumes:
  twenty-data:
```
It is mounted at:
```
/data
```
This allows the data stored by the Twenty service to persist independently of the lifecycle of the container.

## Commands Used

### Build Docker Image

    docker build -t devops-crm-image:task5 .

### Check Docker Images

    docker images

### Validate Compose configuration

    docker compose config
### Start the application

    docker compose up -d --build

### Check running containers

    docker compose ps



### View logs

    docker compose logs

### Stop the application

    docker compose down

## Verification

The Docker image was successfully built.
Docker Compose successfully started the required services:
```
devops-crm-app
devops-crm-twenty
```
The Twenty server was accessible at:
```
http://localhost:2020
```
The application was opened successfully in a browser and the development login was completed successfully.

## Issues Faced and Solutions

### Issue 1 – Docker Compose port conflict
Port 8080 was already being used by Jenkins on the local machine.
### Solution

Instead of using port 8080, the Twenty server was exposed using:
```yaml
ports:
  - "2020:2020"
```
The application was then accessed through:
```
http://localhost:2020
```
### Issue 2 – Container remote configuration
The app container's Twenty CLI was configured with:
```
http://localhost:2020 [none]
```
Inside a Docker container, localhost refers to the current container rather than the separate Twenty server container.

### Solution
Configured the CLI to use:
```
http://twenty:2020
```
Tested the Twenty CLI's supported API-key authentication method for configuring the remote. However, the local development server redirected the CLI to browser-based OAuth authentication, so the non-interactive authentication attempt could not be completed from the container.

Therefore, no personal OAuth credentials or API keys were added to the Dockerfile or committed to the repository.
## Result
Task 5 Docker containerization was implemented using:

- Multi-stage Docker build
- Node.js 24 Alpine
- Yarn 4.13.0
- Dependency-layer caching
- Non-root runtime execution
- .dockerignore
- Docker Compose
- Dedicated Docker network
- Persistent named volume
- Successful Docker image build
- Successful Compose startup
- Successful browser access to the Twenty CRM application

## Conclusion
The devops-crm-project was successfully containerized and configured to run using Docker and Docker Compose. The application environment was verified successfully and the setup was documented.
