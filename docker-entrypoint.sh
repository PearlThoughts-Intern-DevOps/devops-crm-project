#!/bin/sh
set -eu

TWENTY_SERVER_URL="${TWENTY_SERVER_URL:-http://twenty:2020}"

echo "========================================"
echo "      Twenty App Deployment"
echo "========================================"

echo "[INFO] Waiting for Twenty server..."

until curl -fsS "${TWENTY_SERVER_URL}/healthz" >/dev/null 2>&1; do
    sleep 3
done

echo "[OK] Twenty server is ready."

if [ -z "${TWENTY_API_KEY:-}" ]; then
    echo "[ERROR] TWENTY_API_KEY is not set."
    exit 1
fi

echo "[INFO] Configuring Twenty remote..."

yarn twenty remote:add \
    --url "${TWENTY_SERVER_URL}" \
    --api-key "${TWENTY_API_KEY}" \
    --as docker 
    

echo "[OK] Twenty remote configured."

echo "[INFO] Publishing application..."

yarn twenty app:publish \
    --private \
    -r docker

echo "[OK] Application published."

echo "[INFO] Installing application..."

yarn twenty app:install \
    -r docker

echo "[OK] Application installed."

echo "[INFO] Deployment completed successfully."


