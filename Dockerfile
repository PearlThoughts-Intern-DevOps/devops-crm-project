# Build stage
FROM node:24-alpine AS builder

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml .nvmrc ./

RUN yarn install --immutable

COPY . .

RUN yarn twenty dev:build

# Runtime stage
FROM node:24-alpine AS runtime

WORKDIR /app

COPY --from=builder /app/.twenty/output ./app

USER node

CMD ["sh", "-c", "echo 'Twenty app package is ready in /app/app' && sleep infinity"]
