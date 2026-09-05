# syntax=docker/dockerfile:1

ARG NODE_VERSION=24.5.0

FROM node:${NODE_VERSION}-bookworm-slim AS base

ENV NODE_ENV=production

WORKDIR /app

RUN corepack enable \
    && corepack prepare yarn@4.13.0 --activate

FROM base AS dependencies

ENV NODE_ENV=development

COPY --chown=node:node package.json yarn.lock .yarnrc.yml ./

RUN yarn install --immutable

FROM dependencies AS build

COPY --chown=node:node . .

RUN yarn lint \
    && yarn typecheck \
    && yarn test:unit \
    && yarn twenty dev:build

FROM base AS runtime

ENV NODE_ENV=production

COPY --from=dependencies --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/package.json ./package.json
COPY --from=build --chown=node:node /app/yarn.lock ./yarn.lock
COPY --from=build --chown=node:node /app/.yarnrc.yml ./.yarnrc.yml
COPY --from=build --chown=node:node /app/src ./src
COPY --from=build --chown=node:node /app/public ./public
COPY --from=build --chown=node:node /app/.twenty/output ./.twenty/output
COPY --from=build --chown=node:node /app/tsconfig.json ./tsconfig.json
COPY --from=build --chown=node:node /app/tsconfig.spec.json ./tsconfig.spec.json

USER node

CMD ["sh", "-c", "node node_modules/twenty-sdk/dist/cli.mjs remote:add --as compose --url \"$TWENTY_API_URL\" --api-key \"$TWENTY_API_KEY\" && exec node node_modules/twenty-sdk/dist/cli.mjs --remote compose apply"]
