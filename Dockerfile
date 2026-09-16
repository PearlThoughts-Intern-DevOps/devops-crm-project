FROM node:22-alpine AS base

RUN apk add --no-cache curl openssl ca-certificates git \
    && rm -rf /var/cache/apk/*

RUN corepack enable && corepack prepare yarn@stable --activate

RUN addgroup -S twenty && adduser -S twenty -G twenty

WORKDIR /app

FROM base AS deps
COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn config set enableImmutableInstalls false && \
    yarn install --mode=skip-build

FROM deps AS builder
COPY . .
RUN yarn typecheck

FROM base AS runner
ENV NODE_ENV=production

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/src ./src
COPY --from=builder /app/.yarnrc.yml ./.yarnrc.yml
COPY --from=builder /app/.yarn ./.yarn

RUN mkdir -p /app/.local-storage && chown -R twenty:twenty /app

USER twenty

EXPOSE 2020

HEALTHCHECK --interval=10s --timeout=5s --retries=10 --start-period=60s \
  CMD curl --fail http://localhost:2020 || exit 1

CMD ["yarn", "twenty", "dev"]
