# ---------------------------------------------------------
# Stage 1: Dependencies
# ---------------------------------------------------------
FROM node:24-alpine AS dependencies

WORKDIR /app

# Enable Corepack so the Yarn version from package.json is used
RUN corepack enable

# Copy only dependency-related files first
COPY package.json yarn.lock .yarnrc.yml ./

# Install dependencies using the locked Yarn configuration
RUN yarn install --immutable


# ---------------------------------------------------------
# Stage 2: Build
# ---------------------------------------------------------
FROM node:24-alpine AS builder

WORKDIR /app

RUN corepack enable

# Copy installed dependencies
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=dependencies /app/.yarn ./.yarn

# Copy package manager/configuration files
COPY package.json yarn.lock .yarnrc.yml ./

# Copy project configuration
COPY tsconfig.json ./
COPY tsconfig.spec.json ./
COPY vitest.config.ts ./
COPY vitest.unit.config.ts ./
COPY .oxlintrc.json ./

# Copy application source
COPY src ./src
COPY public ./public

# Build the Twenty application
RUN yarn twenty dev:build


# ---------------------------------------------------------
# Stage 3: Runtime
# ---------------------------------------------------------
FROM node:24-alpine AS runtime

WORKDIR /app

# Create a dedicated non-root user
RUN addgroup -S appgroup \
    && adduser -S appuser -G appgroup

# Enable Corepack / Yarn
RUN corepack enable

# Copy package manager files
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/yarn.lock ./yarn.lock
COPY --from=builder /app/.yarnrc.yml ./.yarnrc.yml
COPY --from=builder /app/.yarn ./.yarn

# Copy dependencies
COPY --from=builder /app/node_modules ./node_modules

# Copy application files
COPY --from=builder /app/src ./src
COPY --from=builder /app/public ./public

# Create runtime directory required by Twenty SDK
# and give ownership to the non-root user.
RUN mkdir -p /app/.twenty \
    && chown -R appuser:appgroup /app

# Run as non-root user
USER appuser

# Twenty development server port
EXPOSE 2020

# Start the application
CMD ["yarn", "twenty", "dev"]