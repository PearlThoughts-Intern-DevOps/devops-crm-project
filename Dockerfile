# syntax=docker/dockerfile:1

# -----------------------------
# Stage 1: Install dependencies
# -----------------------------
FROM node:24-alpine AS dependencies

WORKDIR /app

RUN corepack enable && \
    corepack prepare yarn@4.13.0 --activate

COPY package.json yarn.lock .yarnrc.yml .nvmrc ./

RUN yarn install --immutable

# -----------------------------
# Stage 2: Build Twenty app
# -----------------------------
FROM node:24-alpine AS builder

WORKDIR /app

RUN corepack enable && \
    corepack prepare yarn@4.13.0 --activate

COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=dependencies /app/.yarn ./.yarn

COPY package.json yarn.lock .yarnrc.yml .nvmrc ./
COPY src ./src
COPY public ./public
COPY tsconfig.json tsconfig.spec.json vitest.config.ts vitest.unit.config.ts ./
COPY .oxlintrc.json ./

RUN yarn twenty dev:build

# -----------------------------
# Stage 3: Artifact image
# -----------------------------
FROM alpine:3.22 AS runtime

WORKDIR /app

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

COPY --from=builder /app/.twenty/output ./.twenty/output

RUN chown -R appuser:appgroup /app

USER appuser

CMD ["sh", "-c", "echo 'Twenty app artifact is ready'; find .twenty/output -maxdepth 3 -type f"]