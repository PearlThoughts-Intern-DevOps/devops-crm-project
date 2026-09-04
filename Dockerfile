# syntax=docker/dockerfile:1
# Stage 1: Builder

FROM node:24-alpine AS builder

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

RUN yarn install --immutable

COPY . .

RUN yarn twenty dev:build


# Stage 2: Runtime

FROM node:24-alpine AS runtime

WORKDIR /app

RUN corepack enable

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app/package.json /app/yarn.lock /app/.yarnrc.yml ./
COPY --from=builder /app/.yarn ./.yarn
COPY --from=builder /app/.twenty ./.twenty
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/public ./public
COPY --from=builder /app/tsconfig.json ./tsconfig.json
COPY --from=builder /app/tsconfig.spec.json ./tsconfig.spec.json
COPY --from=builder /root/.cache/node/corepack /root/.cache/node/corepack

RUN chown -R appuser:appgroup /app

USER appuser

CMD ["yarn", "twenty", "dev:build"]