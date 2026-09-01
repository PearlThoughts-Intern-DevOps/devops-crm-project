# ==========================================================
# Stage 1: Base image with Node.js 24 & Corepack Yarn Berry
# ==========================================================
FROM node:24-alpine AS base

# Install libc6-compat for compatibility with native modules on Alpine
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Enable Corepack and prepare the exact Yarn version specified in package.json
RUN corepack enable && corepack prepare yarn@4.13.0 --activate

# ==========================================================
# Stage 2: Dependencies (leveraging layer caching)
# ==========================================================
FROM base AS dependencies

# Copy package manifests and Yarn configuration
COPY package.json yarn.lock .yarnrc.yml .nvmrc ./
COPY .yarn/ ./.yarn/

# Install dependencies deterministically
RUN yarn install --immutable

# ==========================================================
# Stage 3: Builder & Quality Assurance
# ==========================================================
FROM dependencies AS builder

# Copy project configuration and source code
COPY tsconfig.json tsconfig.spec.json .oxlintrc.json vitest.config.ts vitest.unit.config.ts ./
COPY public/ ./public/
COPY src/ ./src/

# Run linting, typechecking, unit tests, and build compilation
RUN yarn lint
RUN yarn typecheck
RUN yarn test:unit
RUN yarn twenty dev:build

# ==========================================================
# Stage 4: Production Runner (Minimal & Non-Root)
# ==========================================================
FROM base AS runner

ENV NODE_ENV=production
ENV PORT=3000

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Ensure application directory and copy corepack cache to user directory
RUN mkdir -p /app /home/node/.twenty /home/node/.cache && \
    (cp -r /root/.cache/* /home/node/.cache/ 2>/dev/null || true) && \
    chown -R node:node /app /home/node

# Set up non-root user execution
USER node

# Copy installed dependencies, manifests, and build outputs with proper ownership
COPY --chown=node:node --from=dependencies /app/node_modules ./node_modules
COPY --chown=node:node --from=dependencies /app/package.json ./package.json
COPY --chown=node:node --from=dependencies /app/yarn.lock ./yarn.lock
COPY --chown=node:node --from=dependencies /app/.yarnrc.yml ./.yarnrc.yml
COPY --chown=node:node --from=dependencies /app/.nvmrc ./.nvmrc
COPY --chown=node:node --from=dependencies /app/.yarn ./.yarn
COPY --chown=node:node --from=builder /app/tsconfig.json ./tsconfig.json
COPY --chown=node:node --from=builder /app/tsconfig.spec.json ./tsconfig.spec.json
COPY --chown=node:node --from=builder /app/.oxlintrc.json ./.oxlintrc.json
COPY --chown=node:node --from=builder /app/vitest.config.ts ./vitest.config.ts
COPY --chown=node:node --from=builder /app/vitest.unit.config.ts ./vitest.unit.config.ts
COPY --chown=node:node --from=builder /app/public ./public
COPY --chown=node:node --from=builder /app/src ./src
COPY --chown=node:node --from=builder /app/.twenty ./.twenty
COPY --chown=node:node --from=builder /app/dist ./dist

# Expose application port
EXPOSE 3000

# Health check to ensure the container runtime is responsive
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "process.exit(0)" || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["yarn", "twenty", "dev"]
