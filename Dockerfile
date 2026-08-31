# Stage 1: Build
FROM node:24.5-bookworm-slim AS builder

WORKDIR /app

RUN corepack enable && corepack prepare yarn@4.13.0 --activate

COPY . .

RUN yarn install --immutable
RUN yarn twenty dev:build


# Stage 2: Runtime
FROM node:24.5-bookworm-slim

WORKDIR /app

RUN corepack enable && corepack prepare yarn@4.13.0 --activate

COPY --from=builder --chown=node:node /app .

USER node

EXPOSE 2020

CMD ["yarn", "twenty", "dev"]
