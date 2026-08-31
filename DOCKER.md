# Task 5 - Docker Containerization

## Overview

This task containerizes the Twenty CRM application extension and provides a Docker Compose environment for running the Twenty CRM server with PostgreSQL and Redis.

The project uses:

- Node.js 24.5.0
- Yarn 4.13.0
- Twenty SDK
- TypeScript
- Vitest
- Docker
- Docker Compose
- PostgreSQL
- Redis

## Project Structure

```text
devops-crm-project/
├── src/
├── public/
├── .twenty/
├── package.json
├── yarn.lock
├── .nvmrc
├── Dockerfile
├── .dockerignore
├── docker-compose.yml
├── .env.example
└── DOCKER.md

## Docker Architecture

```text
                    Docker Compose
                         |
          +--------------+--------------+
          |              |              |
     PostgreSQL        Redis       Twenty CRM
          |              |              |

