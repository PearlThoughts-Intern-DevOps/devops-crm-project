#!/bin/sh
set -e

# Initialize Twenty CLI configuration if TWENTY_API_URL is provided
if [ -n "$TWENTY_API_URL" ]; then
  mkdir -p /home/node/.twenty
  cat <<EOF > /home/node/.twenty/config.json
{
  "version": 1,
  "remotes": {
    "local": {
      "apiUrl": "${TWENTY_API_URL}",
      "apiKey": "${TWENTY_API_KEY:-dev-api-key-for-local-testing}",
      "accessToken": "${TWENTY_API_KEY:-dev-api-key-for-local-testing}"
    }
  },
  "defaultRemote": "local"
}
EOF
fi

# Execute the passed command
exec "$@"
