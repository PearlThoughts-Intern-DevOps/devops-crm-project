# Stage 1: Build dependencies and application
FROM node:24-alpine AS builder

WORKDIR /app

# Enable Corepack for Yarn 4
RUN corepack enable

# Copy dependency files first for better Docker layer caching
COPY package.json yarn.lock .yarnrc.yml ./

# Copy Yarn files
COPY .yarn/ .yarn/

# Install dependencies
RUN yarn install --immutable

# Copy application source
COPY . .

# Build the Twenty app
RUN yarn twenty dev:build


# Stage 2: Runtime image
FROM node:24-alpine AS runtime

WORKDIR /app

# Enable Corepack
RUN corepack enable

# Copy application configuration
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/yarn.lock ./yarn.lock
COPY --from=builder /app/.yarnrc.yml ./.yarnrc.yml

# Copy Yarn files and install state
COPY --from=builder /app/.yarn/ ./.yarn/

# Copy installed dependencies
COPY --from=builder /app/node_modules/ ./node_modules/

# Copy built Twenty application
COPY --from=builder /app/.twenty/ ./.twenty/

# Give the non-root user ownership of the application files
RUN chown -R node:node /app/.twenty

# Run as non-root user
USER node

# Start the application
CMD ["yarn", "twenty", "dev"]