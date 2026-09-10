# -----------------------------
# Build stage
# -----------------------------
FROM node:24-alpine AS builder

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml .nvmrc ./

RUN yarn install --immutable

COPY . .

RUN yarn twenty dev:build --tarball


# -----------------------------
# Deployment stage
# -----------------------------
FROM node:24-alpine

WORKDIR /app

RUN apk add --no-cache curl
RUN corepack enable

# Keep the complete application project available to the Twenty CLI.
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/yarn.lock ./yarn.lock
COPY --from=builder /app/.yarnrc.yml ./.yarnrc.yml
COPY --from=builder /app/.nvmrc ./.nvmrc
COPY --from=builder /app/src ./src
COPY --from=builder /app/public ./public
COPY --from=builder /app/README.md ./README.md
COPY --from=builder /app/SETUP.md ./SETUP.md
COPY --from=builder /app/.twenty ./.twenty
COPY --from=builder /app/node_modules ./node_modules
COPY docker-entrypoint.sh ./docker-entrypoint.sh
COPY --from=builder /app/tsconfig.json ./tsconfig.json
COPY --from=builder /app/tsconfig.spec.json ./tsconfig.spec.json

RUN chmod +x ./docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]



