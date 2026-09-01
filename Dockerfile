# syntax=docker/dockerfile:1

FROM node:24.5.0-alpine AS base

WORKDIR /app

RUN corepack enable && corepack prepare yarn@4.13.0 --activate

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

FROM base AS dependencies

RUN yarn install --immutable

FROM dependencies AS build

COPY . .

RUN yarn twenty dev:build

FROM dependencies AS runtime

ENV NODE_ENV=development
ENV PORT=3000
ENV NODE_PORT=3000

COPY --from=build /app ./

RUN chown -R node:node /app

USER node

EXPOSE 3000

CMD ["yarn", "twenty", "dev"]
