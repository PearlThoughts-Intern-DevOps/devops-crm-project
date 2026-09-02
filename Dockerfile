# Stage 1: Build the application
FROM node:24.5-alpine AS builder

WORKDIR /app

# Enable Yarn
RUN corepack enable

# Copy dependency files first
COPY package.json yarn.lock .yarnrc.yml ./

# Install dependencies
RUN yarn install --immutable

# Copy application source code
COPY . .

# Build the application
RUN yarn twenty dev:build


# Stage 2: Run the application
FROM node:24.5-alpine

WORKDIR /app

# Enable Yarn
RUN corepack enable

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy required files from build stage
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/yarn.lock ./yarn.lock
COPY --from=builder /app/.yarnrc.yml ./.yarnrc.yml
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

# Run as non-root user
USER appuser

# Start the application
CMD ["yarn", "twenty", "dev"]
