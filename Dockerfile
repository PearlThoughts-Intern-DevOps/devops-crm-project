FROM node:24-alpine

WORKDIR /app

COPY package.json yarn.lock .yarnrc.yml .nvmrc ./
COPY .yarn ./.yarn

RUN corepack enable && yarn install --immutable

COPY . .

RUN yarn twenty dev:build

EXPOSE 2020

CMD ["yarn", "twenty", "dev"]
