FROM node:24-alpine AS dependencies

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./

RUN yarn install --immutable


FROM node:24-alpine AS builder

WORKDIR /app

RUN corepack enable

COPY --from=dependencies /app/node_modules ./node_modules

COPY . .

RUN yarn twenty dev:build


FROM alpine:3.22 AS artifact

WORKDIR /app

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

COPY --from=builder --chown=appuser:appgroup \
    /app/.twenty/output ./output

USER appuser

CMD ["sh", "-c", "echo 'Twenty application artifact ready' && ls -la /app/output"]
