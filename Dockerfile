
# Twenty CRM App - Dockerfile

# Multi-stage build following Docker best practices:
#   - Stage 1 (base):    Node.js base image with Corepack/Yarn 4
#   - Stage 2 (deps):    Install all dependencies (cached layer)
#   - Stage 3 (builder): Build / type-check / lint the app
#   - Stage 4 (release): Minimal production image for publishing/deploying

# Stage 1 – base: Node.js + Corepack (Yarn 4)

FROM node:24-alpine AS base

LABEL org.opencontainers.image.title="twenty-crm-app" \
      org.opencontainers.image.description="Twenty CRM App extension – containerized" \
      org.opencontainers.image.licenses="MIT"

# Enable Corepack so Yarn 4 
RUN corepack enable && corepack prepare yarn@4.13.0 --activate

WORKDIR /app


# Stage 2 – deps: install dependencies 

FROM base AS deps


COPY package.json yarn.lock .yarnrc.yml ./

RUN yarn install --immutable


# Stage 3 – builder: lint, typecheck, test, build

FROM deps AS builder

# Copy the full source tree on top of the installed dependencies
COPY tsconfig.json tsconfig.spec.json vitest.config.ts vitest.unit.config.ts .oxlintrc.json ./
COPY src/ ./src/
COPY public/ ./public/

# Run quality gates
RUN yarn lint
RUN yarn typecheck

# Run unit tests (integration tests need a live Twenty server, skipped here)
RUN yarn test:unit

# Stage 4 – release: minimal runtime image (non-root user)

FROM base AS release

ENV NODE_ENV=production

# Create a dedicated non-root user for security
RUN addgroup --system --gid 1001 appgroup && \
    adduser  --system --uid 1001 --ingroup appgroup appuser

WORKDIR /app

# Copy dependencies and source from previous stages
COPY --chown=appuser:appgroup --from=deps    /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=builder /app/src          ./src
COPY --chown=appuser:appgroup --from=builder /app/public       ./public
COPY --chown=appuser:appgroup package.json yarn.lock .yarnrc.yml tsconfig.json ./

USER appuser

CMD ["yarn", "twenty", "dev"]