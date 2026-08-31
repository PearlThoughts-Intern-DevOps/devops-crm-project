# ---------- Build stage ----------
FROM node:24.5.0-bookworm-slim AS builder

WORKDIR /app

ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml .nvmrc ./

RUN yarn install --immutable

COPY . .

RUN yarn twenty dev:build


# ---------- Runtime stage ----------
FROM node:24.5.0-bookworm-slim AS runtime

WORKDIR /app

ENV NODE_ENV=production
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

RUN groupadd --system appgroup \
    && useradd --system --gid appgroup --create-home appuser

COPY --from=builder --chown=appuser:appgroup /app/package.json ./package.json
COPY --from=builder --chown=appuser:appgroup /app/.twenty ./.twenty
COPY --from=builder --chown=appuser:appgroup /app/src ./src
COPY --from=builder --chown=appuser:appgroup /app/public ./public

USER appuser

CMD ["node", "-e", "console.log('Twenty CRM application image built successfully. Use docker compose for the complete application stack.')"]
