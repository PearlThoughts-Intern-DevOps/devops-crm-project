# syntax=docker/dockerfile:1

FROM node:24.5.0-alpine AS base

WORKDIR /app

RUN corepack enable \
    && corepack prepare yarn@4.13.0 --activate

COPY package.json yarn.lock .yarnrc.yml ./

FROM base AS dependencies

RUN yarn install --immutable

FROM dependencies AS build

COPY tsconfig.json tsconfig.spec.json vitest.config.ts vitest.unit.config.ts ./
COPY .oxlintrc.json ./
COPY src ./src
COPY public ./public

RUN yarn twenty dev:build

FROM base AS runtime

ENV NODE_ENV=development
ENV PORT=3000
ENV NODE_PORT=3000

COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=dependencies /app/package.json ./package.json
COPY --from=dependencies /app/yarn.lock ./yarn.lock
COPY --from=dependencies /app/.yarnrc.yml ./.yarnrc.yml

COPY --from=build /app/.twenty/output ./.twenty/output
COPY --from=build /app/public ./public

RUN chown -R node:node /app

USER node

EXPOSE 3000

CMD ["yarn", "twenty", "dev"]