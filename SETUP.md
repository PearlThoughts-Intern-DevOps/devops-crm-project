# Setup

Follow these steps to get your app running locally.

## Prerequisites

- Node.js (version specified in `.nvmrc`)
- Yarn 4
- Docker (to run the local Twenty server)

## Docker Compose setup

The Compose stack runs the official Twenty development server and this app's
development sync container on a private `twenty` network. The development
server manages its bundled PostgreSQL and Redis services; its file storage uses
a named volume so data survives container restarts.

1. Copy the example environment file and set a real database password and
   Twenty API key:

   ```bash
   cp .env.example .env
   ```

2. Build and start the stack:

   ```bash
   docker compose up --build
   ```

3. Open [http://localhost:2020](http://localhost:2020) after the Twenty
   container becomes healthy. The app service then registers and syncs the
   application automatically.

4. Stop the stack while preserving data:

   ```bash
   docker compose down
   ```

   To remove the stored database, Redis, and file data as well:

   ```bash
   docker compose down -v
   ```

The `TWENTY_URL` value is `http://twenty:3000` inside the Compose network;
port `2020` is exposed on the host. Do not commit `.env` or real API keys.

## Steps

1. Install dependencies:

   ```bash
   yarn install
   ```

2. Start the local Twenty server:

   ```bash
   yarn twenty docker:start
   ```

   Check the server status at any time with `yarn twenty docker:status`.

3. Start the development server and sync your app:

   ```bash
   yarn twenty dev
   ```

4. Open [http://localhost:2020](http://localhost:2020) and log in with the default development credentials: `tim@apple.dev` / `tim@apple.dev`.

## Verifying your setup

- `yarn lint` - Lint the project with oxlint
- `yarn typecheck` - Type-check the project
- `yarn test:unit` - Run unit tests
- `yarn test` - Run integration tests

## Troubleshooting

See the [troubleshooting guide](https://docs.twenty.com/developers/extend/apps/getting-started/troubleshooting) or ask on [Discord](https://discord.gg/cx5n4Jzs57).
