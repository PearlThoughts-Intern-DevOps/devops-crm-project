#!/bin/sh
set -e

if [ -z "${TWENTY_URL}" ] || [ -z "${TWENTY_API_KEY}" ]; then
  echo "TWENTY_URL and TWENTY_API_KEY must be set. Copy .env.example to .env and configure them."
  exit 1
fi

echo "Waiting for Twenty CRM at ${TWENTY_URL}..."

until curl -fsS "${TWENTY_URL}" > /dev/null; do
  sleep 2
done

echo "Twenty CRM is ready."

echo "Configuring Twenty CLI remote..."

yarn twenty remote:add \
  --as docker \
  --url "${TWENTY_URL}" \
  --api-key "${TWENTY_API_KEY}"

echo "Starting Twenty app development sync..."

exec yarn twenty dev --verbose
