# syntax=docker/dockerfile:1

FROM node:24-alpine AS dependencies

WORKDIR /app

RUN corepack enable \
    && corepack prepare yarn@4.13.0 --activate

COPY package.json yarn.lock .yarnrc.yml ./

RUN yarn install --immutable

FROM node:24-alpine AS runtime

WORKDIR /app

RUN apk add --no-cache curl \
    && addgroup -S twenty \
    && adduser -S twenty -G twenty

RUN corepack enable \
    && corepack prepare yarn@4.13.0 --activate

COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=dependencies /app/.yarn ./.yarn
COPY --chown=twenty:twenty package.json yarn.lock .yarnrc.yml ./
COPY --chown=twenty:twenty src ./src
COPY --chown=twenty:twenty public ./public
COPY --chown=twenty:twenty tsconfig.json tsconfig.spec.json vitest.config.ts vitest.unit.config.ts ./
COPY --chown=twenty:twenty entrypoint.sh ./entrypoint.sh

RUN mkdir -p /app/.twenty \
    && chown twenty:twenty /app/.twenty

USER twenty

ENTRYPOINT ["sh", "/app/entrypoint.sh"]
