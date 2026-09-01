# Stage 1: Build the Twenty application
FROM node:24-alpine AS builder

WORKDIR /app

# Enable Corepack
RUN corepack enable

# Copy dependency files first for better layer caching
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Install dependencies
RUN yarn install --immutable

# Copy application source
COPY . .

# Build Twenty application resources
RUN yarn twenty dev:build


# Stage 2: Runtime image
FROM node:24-alpine AS runtime

WORKDIR /app

# Enable Corepack
RUN corepack enable

# Create non-root user
RUN addgroup -S appgroup \
    && adduser -S appuser -G appgroup

# Copy required files from builder
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/yarn.lock ./yarn.lock
COPY --from=builder /app/.yarnrc.yml ./.yarnrc.yml
COPY --from=builder /app/.yarn ./.yarn
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.twenty ./.twenty

# Give ownership to non-root user
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 2020

CMD ["yarn", "twenty", "dev"]