# Task 5 - Docker Containerization

## Objective

Containerize the Twenty CRM application environment using Docker and Docker Compose.

## Project

Repository:
https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project

The project is a Twenty application built with Node.js, Yarn 4, TypeScript, React, and the Twenty SDK.

## Environment

- Ubuntu 24.04.4 LTS on WSL
- Node.js 24.5.0
- Yarn 4.13.0
- Docker 29.7.2
- Docker Compose 5.4.0

## Docker Files

Created the following files:

- `Dockerfile`
- `.dockerignore`
- `docker-compose.yml`
- `docker-entrypoint.sh`

## Docker Architecture

The setup uses two services.

### Twenty Server

The `twenty` service uses the official:

`twentycrm/twenty-app-dev:latest`

This is an all-in-one development image containing the Twenty server, PostgreSQL, Redis, and worker components.

Port `2020` is exposed so the CRM can be accessed at:

`http://localhost:2020`

Persistent Docker volumes are used for application storage and PostgreSQL data.

### Application Deployer

The `app-deployer` service is built from the project `Dockerfile`.

Its process is:

1. Install the project dependencies using Yarn.
2. Build the Twenty application package.
3. Wait for the Twenty server to become available.
4. Authenticate to the local Twenty server using the `TWENTY_API_KEY` environment variable.
5. Publish the application privately to the local Twenty registry.
6. Install the published application into the local Twenty server.

The deployer container exits after the deployment is complete.

## Dockerfile

The Dockerfile uses a multi-stage build.

### Build Stage

The build stage:

- Uses Node.js 24 Alpine.
- Enables Corepack.
- Installs dependencies using `yarn install --immutable`.
- Copies the application source.
- Builds the Twenty application package using:

`yarn twenty dev:build --tarball`

### Deployment Stage

The deployment stage:

- Uses Node.js 24 Alpine.
- Installs `curl` for server readiness checks.
- Copies the project files required by the Twenty CLI.
- Copies the generated application package.
- Runs `docker-entrypoint.sh`.

## Docker Compose Configuration

The Compose configuration provides:

- Twenty server container
- Application deployer container
- Port mapping `2020:2020`
- Persistent application storage volume
- Persistent PostgreSQL data volume
- Automatic restart for the Twenty service
- Dependency ordering between the deployer and Twenty server

## Environment Variables

The deployment container uses:

`TWENTY_SERVER_URL=http://twenty:2020`

and:

`TWENTY_API_KEY`

The API key is stored in the local `.env` file and is excluded from Git using `.gitignore`.

No credentials are committed to the repository.

## Commands Used

Build the Docker services:

`docker compose build`

Start the environment:

`docker compose up -d`

Check container status:

`docker compose ps`

Check all containers, including completed deployer containers:

`docker compose ps -a`

View deployment logs:

`docker compose logs app-deployer`

Stop the environment:

`docker compose down`

Check the application:

`curl -I http://localhost:2020`

## Verification

The Docker image was built successfully.

The Compose environment started successfully.

The Twenty server returned:

`HTTP/1.1 200 OK`

The application deployer successfully:

- Built the application package.
- Published `my-app` to the local Twenty registry.
- Installed the application into the local Twenty server.

The final deployment log reported:

`[OK] Application installed.`

and:

`[INFO] Deployment completed successfully.`

The CRM application was then accessible through:

`http://localhost:2020`

and the application was shown as successfully installed in the Twenty interface.

## Result

The CRM application was successfully containerized and run using Docker Compose, with the application package automatically built, published, and installed into the local Twenty server.

