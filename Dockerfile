FROM node:24-bookworm-slim AS dependencies

WORKDIR /app

RUN corepack enable \
    && corepack prepare yarn@4.13.0 --activate

COPY package.json yarn.lock .yarnrc.yml .nvmrc ./

RUN yarn install --immutable


FROM dependencies AS build

COPY . .

RUN yarn twenty dev:build


FROM node:24-bookworm-slim AS runtime

WORKDIR /app

RUN corepack enable \
    && corepack prepare yarn@4.13.0 --activate \
    && useradd --create-home --shell /bin/bash appuser

COPY --from=build --chown=appuser:appuser /app /app
COPY --chown=appuser:appuser docker-entrypoint.sh /usr/local/bin/docker-entrypoint-twenty.sh

RUN chmod +x /usr/local/bin/docker-entrypoint-twenty.sh

USER appuser

ENV NODE_ENV=development

ENTRYPOINT ["/usr/local/bin/docker-entrypoint-twenty.sh"]
