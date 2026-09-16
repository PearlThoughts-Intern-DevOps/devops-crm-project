# syntax=docker/dockerfile:1

FROM node:24-alpine AS dependencies

WORKDIR /app

RUN corepack enable && corepack prepare yarn@4.13.0 --activate

COPY package.json yarn.lock .yarnrc.yml ./

RUN yarn install --immutable

FROM node:24-alpine AS runtime

WORKDIR /app

ENV COREPACK_HOME=/opt/corepack

RUN mkdir -p "$COREPACK_HOME" \
	&& corepack enable && corepack prepare yarn@4.13.0 --activate \
	&& addgroup -S appgroup \
	&& adduser -S appuser -G appgroup \
	&& mkdir -p /app/.yarn \
	&& chown appuser:appgroup /app /app/.yarn

# Create a dedicated non-root user/group instead of running as root
COPY --from=dependencies --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=dependencies --chown=appuser:appgroup /app/package.json /app/yarn.lock /app/.yarnrc.yml ./
COPY --chown=appuser:appgroup src ./src
COPY --chown=appuser:appgroup public ./public
COPY --chown=appuser:appgroup tsconfig.json tsconfig.spec.json vitest.config.ts vitest.unit.config.ts ./

USER appuser

CMD ["yarn", "twenty", "dev"]
