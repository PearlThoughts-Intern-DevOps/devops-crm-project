# -- stage 1: Base ----
FROM node:22-alpine AS base
RUN apk add --no-cache \
    curl \
    openssl \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# Enable Corepack for Yarn v4 support
RUN corepack enable

# Create a non-root user for security
RUN addgroup -S twenty && adduser -S twenty -G twenty

# Set working directory
WORKDIR /app

# --- stage 2: Dependencies ---
FROM base AS deps
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn/

# Install all dependencies
RUN yarn install --immutable --mode=skip-build

# --- stage 3: Builder ---
FROM deps AS builder

# Copy full source code
COPY . .

# Type check acts as build validation (no build script exists)
RUN yarn typecheck

# --- stage 4: Production Runner ---
FROM base AS runner

# Set NODE_ENV to production
ENV NODE_ENV=production

# Copy built artifacts and production node_modules from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/src ./src

# Copy config files needed at runtime
COPY --from=builder /app/.yarn ./.yarn
COPY --from=builder /app/.yarnrc.yml ./.yarnrc.yml

# Create local storage directory and set ownership to non-root user
RUN mkdir -p /app/.local-storage && chown -R twenty:twenty /app

# Switch to non-root user
USER twenty

# Expose port
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=10s --timeout=5s --retries=10 --start-period=60s \
            CMD curl --fail http://localhost:3000/healthz || exit 1

# Default command
CMD ["node", "src/main.js"]
