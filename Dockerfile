# Multi-stage build for the Twenty CRM Frontend
FROM node:24-alpine AS deps
WORKDIR /app
RUN corepack enable && corepack prepare yarn@stable --activate
COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn install --immutable

FROM node:24-alpine AS build
WORKDIR /app
RUN corepack enable && corepack prepare yarn@stable --activate
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/.yarn ./.yarn
COPY . .
RUN yarn twenty dev:build

FROM nginx:alpine AS production
COPY --from=build /app/.twenty/output /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
