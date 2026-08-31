Twenty CRM — Docker Containerization

Overview

This project containerizes the Twenty CRM application and provides a Docker Compose setup for local development.

The setup consists of:

twenty-server — Twenty's all-in-one development image containing the application server, PostgreSQL, Redis, and worker processes.

crm-app — The project application image built from this repository using a multi-stage Dockerfile.

Both services communicate through a dedicated Docker bridge network.

Architecture

                         Docker Compose
                              |
              +---------------+---------------+
              |                               |
              v                               v
       twenty-server                      crm-app
       Port: 2020                         Application
              |                               |
              |<---- Docker network -------->|
              |
       +------+------+
       |             |
   PostgreSQL       Redis
   persistent       persistent
      data             data

The crm-app container communicates with Twenty using http://twenty-server:2020. Docker service discovery is used instead of localhost.

Dockerfile

The Dockerfile uses a multi-stage build.

Dependencies stage

Base image: node:24-bookworm-slim

Enables Corepack.

Activates Yarn 4.13.0.

Copies package manager configuration.

Runs yarn install --immutable.

Build stage

Copies the application source.

Runs yarn twenty dev:build.

Runtime stage

Uses a fresh node:24-bookworm-slim image.

Creates a non-root appuser.

Copies the application from the build stage.

Installs the custom Twenty CLI entrypoint.

Runs the application as appuser.

Docker Compose

twenty-server

Image: twentycrm/twenty-app-dev:latest

Port: 2020:2020

Dedicated Docker network

Persistent application storage

Persistent PostgreSQL data

Healthcheck on /healthz

crm-app

Built locally from the Dockerfile.

Waits for twenty-server to become healthy.

Uses http://twenty-server:2020.

Receives the Twenty API key through environment variables.

Volumes

Two named volumes are used:

twenty-storage
twenty-data

These preserve application storage and PostgreSQL data when containers are recreated.

Environment Variables

Create a local .env file:

TWENTY_API_URL=http://twenty-server:2020
TWENTY_API_KEY=<your-api-key>

The .env file must not be committed to Git. It is excluded by .dockerignore.

Custom Entrypoint

docker-entrypoint.sh configures the Twenty CLI to use the Docker-internal server:

yarn twenty remote:add   --as docker   --url "${TWENTY_API_URL}"   --api-key "${TWENTY_API_KEY}"

It then starts synchronization:

yarn twenty dev -r docker

This avoids the incorrect default connection to http://localhost:2020 from inside the crm-app container.

Commands

Build

docker compose build crm-app

Start

docker compose up -d

Stop

docker compose down

Status

docker compose ps

Logs

docker compose logs --tail 100 crm-app
docker compose logs --tail 100 twenty-server

Follow CRM logs

docker compose logs -f crm-app

Healthcheck

curl http://localhost:2020/healthz

Expected response:

{"status":"ok","info":{},"error":{},"details":{}}

Issues Encountered and Solutions

1. Port 2020 was already allocated

The original Twenty development container was already using port 2020.

Solution:

yarn twenty docker:stop

The Compose deployment could then bind 2020:2020.

2. Twenty server initially became unhealthy

The all-in-one Twenty development image performs initialization before becoming ready.

The healthcheck startup window was increased:

healthcheck:
  interval: 10s
  timeout: 5s
  retries: 30
  start_period: 120s

The /healthz endpoint was retained as the readiness check.

3. CRM container used localhost instead of the Compose service

Docker networking itself was working:

crm-app -> http://twenty-server:2020/healthz -> 200 OK

The Twenty CLI initially used http://localhost:2020, which refers to the CRM container itself.

Solution: a custom entrypoint configures a dedicated Docker remote pointing to http://twenty-server:2020.

4. Browser OAuth could not resolve twenty-server

The hostname twenty-server is available only inside the Compose network. A host browser cannot resolve it.

Solution: use the non-interactive API-key option:

--api-key "${TWENTY_API_KEY}"

5. Docker/WSL credential-helper issue

A temporary credential-helper error prevented pulling the Node base image.

Solution:

docker pull node:24-bookworm-slim

After the image was pulled successfully, the application image built normally.

Verification

The final deployment was successfully recreated with:

docker compose down
docker compose up -d

Final state:

crm-app         Up
twenty-server   Up (healthy)

Health endpoint:

GET http://localhost:2020/healthz

Response:

{"status":"ok","info":{},"error":{},"details":{}}

Twenty application synchronization completed successfully:

Overall Status: ✓ Synced
Application Initialization: ✓ done
Resources Build: ✓ done
Resources Upload: ✓ done
Manifest Build: ✓ done
Application Synchronization: ✓ done
Api Client Generation: ✓ done
Entities ✓ 7 synced

Docker Best Practices Applied

Multi-stage Docker build.

Slim Node.js base image.

Dependency installation isolated in its own layer.

yarn install --immutable.

Separate build and runtime stages.

Non-root runtime user.

Dedicated Docker bridge network.

Named persistent volumes.

Service healthcheck.

depends_on with service_healthy.

Secrets supplied through environment variables.

.env excluded from Docker context.

Credentials are not hard-coded in the Dockerfile.

Docker-internal service discovery through Compose DNS.

Files

.dockerignore
Dockerfile
docker-compose.yml
docker-entrypoint.sh
README.md

Final Result

The Twenty CRM project can be built and started using Docker Compose:

docker compose build crm-app
docker compose up -d

The resulting environment provides a reproducible containerized development setup with persistent storage, service networking, health monitoring, and non-root execution.
