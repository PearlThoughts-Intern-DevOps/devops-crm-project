# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# This app has no HTTP server of its own -- it's scaffolded on twenty-sdk and
# runs as a CLI-driven process (`yarn twenty dev`) that typechecks, builds a
# manifest, and syncs itself into a separately-running Twenty CRM instance
# (see docker-compose.yml's "twenty" service). There is no compiled build
# artifact to hand off between stages, so the multi-stage split here
# separates "install dependencies" from "final runtime image" purely to keep
# the runtime image free of anything install-time only would need on a
# different base (e.g. native-module build toolchains), and to make the
# dependency layer cacheable independently of source code changes.
# ---------------------------------------------------------------------------

# ---- deps: resolve and install dependencies in isolation for layer caching
FROM node:24-slim AS deps
WORKDIR /app

RUN corepack enable

# Only copy what's needed to resolve dependencies first, so this layer is
# cached and skipped on rebuilds unless the lockfile actually changes.
COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn install --immutable

# ---- runtime: minimal final image, non-root
FROM node:24-slim AS runtime
WORKDIR /app

RUN corepack enable \
    && groupadd --system appgroup \
    && useradd --system --gid appgroup --home-dir /app --shell /usr/sbin/nologin appuser

# Bring in installed dependencies from the deps stage rather than
# reinstalling, and only the source the app actually needs at runtime.
COPY --from=deps /app/node_modules ./node_modules
COPY package.json yarn.lock .yarnrc.yml ./
COPY src ./src
COPY public ./public
COPY tsconfig.json tsconfig.spec.json vitest.config.ts vitest.unit.config.ts .oxlintrc.json ./

# The twenty CLI stores per-remote credentials at ~/.twenty/config.json.
# With HOME=/app (set via --home-dir above), that resolves to
# /app/.twenty, which docker-compose.yml mounts as a named volume so
# authentication persists across container restarts/rebuilds instead of
# needing to re-authenticate every time.
RUN mkdir -p /app/.twenty && chown -R appuser:appgroup /app

USER appuser

CMD ["yarn", "twenty", "dev"]