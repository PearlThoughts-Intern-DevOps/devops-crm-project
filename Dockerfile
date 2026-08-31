# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Stage 1: dependencies
# Installs dependencies in their own layer so Docker can cache this step
# and skip re-installing when only source files change (not package.json).
# ---------------------------------------------------------------------------
FROM node:24-alpine AS deps

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./

RUN yarn install --immutable

# ---------------------------------------------------------------------------
# Stage 2: runtime
# Minimal final image: only the installed dependencies and app source,
# running as a non-root user.
# ---------------------------------------------------------------------------
FROM node:24-alpine AS runtime

WORKDIR /app

RUN corepack enable

# Create a dedicated non-root user/group instead of running as root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/package.json /app/yarn.lock /app/.yarnrc.yml ./

COPY . .

RUN chown -R appuser:appgroup /app

USER appuser

# This container builds and syncs the app's definitions against a running
# Twenty server (see docker-compose.yml) — it does not serve its own HTTP
# port, so no EXPOSE is needed here.
CMD ["yarn", "twenty", "dev"]
