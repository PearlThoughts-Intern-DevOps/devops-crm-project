# Stage 1: Build
FROM node:24.5-bookworm-slim AS builder

WORKDIR /app

# Enable Corepack and activate the required Yarn version
RUN corepack enable && corepack prepare yarn@4.13.0 --activate

# Copy dependency manifests first for better Docker layer caching
COPY package.json yarn.lock .yarnrc.yml ./

# Install dependencies exactly as defined by yarn.lock
RUN yarn install --immutable

# Copy application source
COPY . .

# Build the Twenty application
RUN yarn twenty dev:build


# Stage 2: Runtime
FROM node:24.5-bookworm-slim

WORKDIR /app

# Enable the same Yarn version in the runtime image
RUN corepack enable && corepack prepare yarn@4.13.0 --activate

# Copy the application from the builder stage
COPY --from=builder --chown=node:node /app .

# Run as non-root user
USER node

# Twenty application port
EXPOSE 2020

# Start the application
CMD ["yarn", "twenty", "dev"]
