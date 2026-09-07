# Dockerfile for my Twenty App (devops-crm-project)


FROM node:24-alpine

RUN apk add --no-cache git curl

WORKDIR /app

RUN corepack enable && corepack prepare yarn@4.13.0 --activate

COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn install --immutable

COPY . .

RUN addgroup -S twenty && adduser -S twenty -G twenty && chown -R twenty:twenty /app
USER twenty

COPY --chown=twenty:twenty entrypoint.sh /app/entrypoint.sh
ENTRYPOINT ["sh", "/app/entrypoint.sh"]