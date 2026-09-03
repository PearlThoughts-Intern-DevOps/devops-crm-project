# Stage 1: Build the Twenty application
FROM node:24-alpine AS builder

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./

RUN yarn install --immutable

COPY . .

RUN yarn twenty dev:build


# Stage 2: Store the built application artifact
FROM alpine:3.22 AS runtime

WORKDIR /app

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

COPY --from=builder --chown=appuser:appgroup \
    /app/.twenty/output ./output

USER appuser

CMD ["sh", "-c", "echo 'Twenty application artifact:' && ls -la /app/output"]