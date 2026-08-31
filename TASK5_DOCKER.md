# Task 5 – Docker Containerization

## Overview

Containerized the Twenty CRM application using Docker and Docker Compose.

## Docker Architecture

The Docker Compose setup contains four services:

- PostgreSQL – database
- Redis – cache and queue service
- Twenty – CRM server
- App – custom application built using the project Dockerfile

All services communicate through the twenty-network Docker bridge network.

## Dockerfile

The Dockerfile uses a multi-stage build:

1. Builder stage uses Node.js 24 Alpine.
2. Dependencies are installed using Yarn.
3. The Twenty application is built using yarn twenty dev:build.
4. A separate runtime stage is used.
5. The application runs as the non-root node user.

## Docker Compose

Docker Compose configures:

- PostgreSQL 16
- Redis 7
- Twenty CRM v2.35.0
- Custom application
- Environment variables
- Networking
- Persistent volumes
- Health checks
- Port mapping

The Twenty CRM server is available at:

http://localhost:2020

## Volumes

The following named volumes are configured:

- postgres-data
- redis-data
- twenty-data

## Networking

All services communicate through:

twenty-network

Internal service addresses:

- PostgreSQL: postgres:5432
- Redis: redis:6379
- Twenty: twenty:3000

## Verification

Twenty server health check:

docker exec twenty-server sh -c "wget -S -O - http://127.0.0.1:3000/healthz"

Result:

HTTP/1.1 200 OK
{"status":"ok","info":{},"error":{},"details":{}}

Host verification:

curl -v http://127.0.0.1:2020

Result:

HTTP/1.1 200 OK

The Twenty CRM application is successfully running at:

http://localhost:2020

## Docker Best Practices

- Multi-stage build
- Alpine-based images
- Layer caching
- .dockerignore
- Named volumes
- Dedicated network
- Health checks
- Non-root execution
- Environment variables

## Final Result

The Twenty CRM application and its required services are successfully running using Docker Compose.