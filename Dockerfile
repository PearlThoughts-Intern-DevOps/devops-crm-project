# Dockerfile for my Twenty App (devops-crm-project)
#
# What this actually is: my repo is a "Twenty App" built with twenty-sdk.
# It's not the CRM server itself - it's a small package (custom UI
# components, config) that gets built and synced INTO a running Twenty
# CRM instance using the `twenty` CLI (`yarn twenty dev`).
#
# So this image doesn't run a server - it runs the twenty-sdk CLI, which
# builds my app and pushes it to the CRM container over the network.
# The actual CRM runs in a separate container (see docker-compose.yml),
# using Twenty's own prebuilt image (twentycrm/twenty-app-dev).

FROM node:24-alpine

# git is needed because some yarn/npm installs shell out to it
RUN apk add --no-cache git curl

WORKDIR /app

# Enable yarn (this repo uses Yarn 4 via corepack)
RUN corepack enable && corepack prepare yarn@4.13.0 --activate

# Copy package files first so the dependency install layer can be cached
COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn install --immutable

# Now copy the actual app source
COPY . .

# Run as a non-root user instead of root
RUN addgroup -S twenty && adduser -S twenty -G twenty && chown -R twenty:twenty /app
USER twenty

# entrypoint.sh registers this container as a "remote" pointing at the
# twenty-crm service, then runs `yarn twenty dev` to build + sync
COPY --chown=twenty:twenty entrypoint.sh /app/entrypoint.sh
ENTRYPOINT ["sh", "/app/entrypoint.sh"]