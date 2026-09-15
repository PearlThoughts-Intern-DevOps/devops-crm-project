# --- Stage 1: build/validate ---
FROM node:24.5.0-alpine AS builder
WORKDIR /app

RUN corepack enable && corepack prepare yarn@4.13.0 --activate

COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn install --immutable

COPY . .
RUN yarn lint && yarn typecheck

# --- Stage 2: minimal runtime ---
FROM node:24.5.0-alpine
WORKDIR /app

RUN corepack enable && corepack prepare yarn@4.13.0 --activate \
    && addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder --chown=appuser:appgroup /app ./

USER appuser
EXPOSE 2020

CMD ["yarn", "twenty", "dev"]