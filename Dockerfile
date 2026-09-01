#stage 1: build
FROM node:24-alpine AS builder

WORKDIR /app

RUN corepack enable && corepack prepare yarn@4.13.0 --activate

COPY . .

RUN yarn install --immutable

RUN yarn twenty dev:build


#stage 2: Runtime 

FROM node:24-alpine

WORKDIR /app

RUN corepack enable && corepack prepare yarn@4.13.0 --activate

RUN addgroup -S twenty && adduser -S twenty -G twenty &&  chown -R twenty:twenty /app

COPY --from=builder --chown=twenty:twenty /app ./

USER twenty

EXPOSE 2020

CMD ["yarn", "twenty", "dev"]
