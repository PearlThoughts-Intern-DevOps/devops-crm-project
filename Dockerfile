FROM node:24.5.0-alpine AS builder

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml tsconfig.json tsconfig.spec.json vitest.config.ts vitest.unit.config.ts .oxlintrc.json ./
COPY .yarn ./.yarn

RUN yarn install --immutable

COPY . .

RUN yarn twenty dev:build


FROM node:24.5.0-alpine AS app

WORKDIR /app

RUN corepack enable

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app/package.json ./
COPY --from=builder /app/yarn.lock ./
COPY --from=builder /app/.yarnrc.yml ./
COPY --from=builder /app/.yarn ./.yarn
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/public ./public
COPY --from=builder /app/tsconfig.json ./
COPY --from=builder /app/tsconfig.spec.json ./
COPY --from=builder /app/vitest.config.ts ./
COPY --from=builder /app/vitest.unit.config.ts ./
COPY --from=builder /app/.oxlintrc.json ./
COPY --from=builder /app/.twenty/output ./.twenty/output

RUN chown -R appuser:appgroup /app
RUN mkdir -p /home/appuser/.twenty && chown -R appuser:appgroup /home/appuser/.twenty

ENV HOME=/home/appuser
ENV NODE_ENV=development

USER appuser

CMD ["sh", "-c", "node -e \"const fs=require('fs'),path=require('path'),p=path.join(process.env.HOME,'.twenty/config.json');fs.mkdirSync(path.dirname(p),{recursive:true});fs.writeFileSync(p,JSON.stringify({version:1,remotes:{local:{apiUrl:'http://twenty-app-dev:2020',apiKey:process.env.TWENTY_API_KEY}},defaultRemote:'local'},null,2))\" && yarn twenty dev"]