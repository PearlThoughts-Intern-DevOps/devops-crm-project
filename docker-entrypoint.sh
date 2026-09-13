#!/bin/sh
set -e

echo "Configuring Twenty CLI remote..."

yarn twenty remote:add \
  --as docker \
  --url "${TWENTY_API_URL}" \
  --api-key "${TWENTY_API_KEY}"

echo "Starting Twenty application sync..."

exec yarn twenty dev -r docker
