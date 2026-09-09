# syntax=docker/dockerfile:1

# ------------------------------------------------------------
# Stage 1: Dependencies
# ------------------------------------------------------------
FROM node:24-bookworm-slim AS dependencies

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/ .yarn/

RUN yarn install --immutable


# ------------------------------------------------------------
# Stage 2: Build
# ------------------------------------------------------------
FROM dependencies AS builder

WORKDIR /app

COPY . .

RUN yarn twenty dev:build


# ------------------------------------------------------------
# Stage 3: Application image
# ------------------------------------------------------------
FROM node:24-bookworm-slim AS app

WORKDIR /app

RUN groupadd --system appgroup \
    && useradd --system --create-home --home-dir /home/appuser \
       --gid appgroup appuser \
    && mkdir -p /home/appuser/.cache/node/corepack \
    && chown -R appuser:appgroup /home/appuser

RUN corepack enable

COPY --from=builder --chown=appuser:appgroup /app/package.json ./
COPY --from=builder --chown=appuser:appgroup /app/yarn.lock ./
COPY --from=builder --chown=appuser:appgroup /app/.yarnrc.yml ./
COPY --from=builder --chown=appuser:appgroup /app/.yarn ./.yarn
COPY --from=dependencies --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/src ./src
COPY --from=builder --chown=appuser:appgroup /app/public ./public
COPY --from=builder --chown=appuser:appgroup /app/.twenty/output ./.twenty/output
COPY --from=builder --chown=appuser:appgroup /app/tsconfig.json ./tsconfig.json

USER appuser

CMD ["sh", "-c", "yarn twenty remote:add --as docker --url http://twenty:2020 --api-key \"$TWENTY_API_KEY\" && yarn twenty --remote docker dev"]