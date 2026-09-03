#!/bin/sh
set -e

echo "Waiting for Twenty CRM at $TWENTY_URL ..."
until curl -s -o /dev/null "$TWENTY_URL"; do
  sleep 2
done
echo "Twenty CRM is up."

yarn twenty remote:add --as docker --url "$TWENTY_URL" --api-key "$TWENTY_API_KEY"

exec yarn twenty dev --verbose