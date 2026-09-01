# syntax=docker/dockerfile:1

FROM node:24.5.0-bookworm-slim AS builder

WORKDIR /app

# Enable Corepack and activate the exact Yarn version required by the project.
RUN corepack enable \
    && corepack prepare yarn@4.13.0 --activate

# Copy dependency manifests first for better layer caching.
COPY package.json yarn.lock .yarnrc.yml ./

# Install dependencies exactly from the lockfile.
RUN yarn install --immutable

# Copy application source and build configuration.
COPY src ./src
COPY public ./public
COPY tsconfig.json tsconfig.spec.json vitest.config.ts vitest.unit.config.ts .oxlintrc.json .nvmrc ./

# Build the Twenty application.
RUN yarn twenty dev:build


FROM twentycrm/twenty:v2.35.0 AS runtime

WORKDIR /app

# Copy the generated application from the builder.
COPY --from=builder /app/.twenty/output /app/.twenty/output

# Twenty's official entrypoint handles database setup,
# migrations, background jobs, and then starts the supplied command.

EXPOSE 3000

CMD ["yarn", "start:prod"]
