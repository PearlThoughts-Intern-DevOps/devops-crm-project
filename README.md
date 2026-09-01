# My Twenty App

Describe your app in one or two sentences.

## Features

List the top things your app does, for example:

- Feature one
- Feature two
- Feature three

## Getting started

Setup instructions live in [SETUP.md](SETUP.md).

## Publishing

The `Publish` workflow (`.github/workflows/publish.yml`) publishes the app to npm with provenance using [npm trusted publishing](https://docs.npmjs.com/trusted-publishers). To publish:

1. On npmjs.com register this repository as a trusted publisher of your package, pointing at the `publish.yml` workflow.
2. Bump the version in `package.json`, then push a version tag (e.g. `git tag v1.0.0 && git push --tags`) or run the workflow manually from the Actions tab.

Publishing with provenance is also how you prove ownership when claiming your app in a Twenty marketplace.

## Changelog

Notable changes are documented in [CHANGELOG.md](CHANGELOG.md).

## Learn more

- [Twenty Apps documentation](https://docs.twenty.com/developers/extend/apps/getting-started/quick-start)
- [twenty-sdk CLI reference](https://www.npmjs.com/package/twenty-sdk)
- [Discord](https://discord.gg/cx5n4Jzs57)

## Docker Setup

### Overview

The application is containerized and can be run locally with Docker Compose.

The Docker setup consists of four services:

- **server** - Twenty CRM application server
- **worker** - Twenty background job worker
- **db** - PostgreSQL 16 database
- **redis** - Redis 7 for caching and job queues

The services communicate through the Docker Compose network.

### Architecture

```text
                    Browser
                       |
                       | localhost:2020
                       v
              +-------------------+
              |   Twenty Server   |
              |   Port 3000       |
              +---------+---------+
                        |
              +---------+---------+
              |                   |
              v                   v
       +-------------+     +-------------+
       | PostgreSQL  |     |    Redis    |
       | postgres:16 |     |   redis:7   |
       +-------------+     +-------------+
              ^                   ^
              |                   |
              +---------+---------+
                        |
                        v
                +---------------+
                | Twenty Worker |
                |  worker:prod  |
                +---------------+
