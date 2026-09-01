#!/bin/sh
set -eu

TWENTY_URL="${TWENTY_URL:-http://twenty:2020}"

if [ -z "${TWENTY_API_KEY:-}" ]; then
  echo "TWENTY_API_KEY is empty. The app container will remain running in standby mode until a valid Twenty workspace API key is configured."
  echo "To enable app sync, set TWENTY_API_KEY in the environment or in .env to a valid token from your Twenty workspace."
  exec tail -f /dev/null
fi

echo "Waiting for Twenty CRM at ${TWENTY_URL}..."

until curl -fsS "${TWENTY_URL}/healthz" > /dev/null; do
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
