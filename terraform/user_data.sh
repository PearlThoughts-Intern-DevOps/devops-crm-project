#!/bin/bash

set -u

LOG_FILE="/var/log/twenty-task12-user-data.log"
exec > >(tee -a "$LOG_FILE" | logger -t twenty-task12-user-data -s 2>/dev/console) 2>&1

echo "=================================================="
echo "Twenty CRM Task 12 - EC2 User Data"
echo "=================================================="

AWS_REGION="${aws_region}"
ECR_REPOSITORY="${ecr_repository}"
IMAGE_TAG="${image_tag}"
IMAGE_URI="$${ECR_REPOSITORY}:$${IMAGE_TAG}"
CONTAINER_NAME="${container_name}"
HOST_PORT="${host_port}"
CONTAINER_PORT="${container_port}"
RETRY_INTERVAL="${image_wait_secs}"
MAX_RETRIES="${max_pull_retries}"

echo "[INFO] AWS region: $${AWS_REGION}"
echo "[INFO] ECR image: $${IMAGE_URI}"

echo "[INFO] Updating package index..."
apt-get update -y

echo "[INFO] Installing required dependencies..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates \
  curl \
  unzip

echo "[INFO] Installing Docker..."
DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io

systemctl enable docker
systemctl start docker

echo "[INFO] Docker version:"
docker --version

if ! command -v aws >/dev/null 2>&1; then
  echo "[INFO] Installing AWS CLI v2..."

  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o /tmp/awscliv2.zip

  rm -rf /tmp/aws

  unzip -q /tmp/awscliv2.zip -d /tmp

  /tmp/aws/install

  rm -rf /tmp/aws /tmp/awscliv2.zip
fi

echo "[INFO] AWS CLI version:"
aws --version

echo "[INFO] Waiting briefly for the EC2 instance role to become available..."
sleep 10

echo "[INFO] Authenticating Docker with Amazon ECR..."

aws ecr get-login-password --region "$${AWS_REGION}" \
  | docker login \
      --username AWS \
      --password-stdin "$(echo "$${ECR_REPOSITORY}" | cut -d/ -f1)"

if [ "$?" -ne 0 ]; then
  echo "[ERROR] ECR authentication failed."
  exit 1
fi

echo "[OK] ECR authentication successful."

echo "[INFO] Attempting to pull Twenty CRM image..."
echo "[INFO] Maximum retries: $${MAX_RETRIES}"
echo "[INFO] Retry interval: $${RETRY_INTERVAL} seconds"

PULL_SUCCESS=0

for attempt in $(seq 1 "$${MAX_RETRIES}"); do
  echo "[INFO] Image pull attempt $${attempt}/$${MAX_RETRIES}"

  if docker pull "$${IMAGE_URI}"; then
    PULL_SUCCESS=1
    echo "[OK] Twenty CRM image pulled successfully."
    break
  fi

  if [ "$${attempt}" -lt "$${MAX_RETRIES}" ]; then
    echo "[WARN] Image is not available yet. Retrying in $${RETRY_INTERVAL} seconds..."
    sleep "$${RETRY_INTERVAL}"
  fi
done

if [ "$${PULL_SUCCESS}" -ne 1 ]; then
  echo "[ERROR] Failed to pull Twenty CRM image after $${MAX_RETRIES} attempts."
  exit 1
fi

echo "[INFO] Removing any existing container with the same name..."
docker rm -f "$${CONTAINER_NAME}" 2>/dev/null || true

echo "[INFO] Starting Twenty CRM container..."

docker run -d \
  --name "$${CONTAINER_NAME}" \
  --restart unless-stopped \
  -p "$${HOST_PORT}:$${CONTAINER_PORT}" \
  "$${IMAGE_URI}"

if [ "$?" -ne 0 ]; then
  echo "[ERROR] Failed to start Twenty CRM container."
  exit 1
fi

echo "[OK] Twenty CRM container started."

echo "[INFO] Waiting for Twenty CRM HTTP endpoint..."

HEALTH_SUCCESS=0

for attempt in $(seq 1 60); do
  if curl -fsS "http://127.0.0.1:$${HOST_PORT}/healthz" >/dev/null 2>&1; then
    HEALTH_SUCCESS=1
    echo "[OK] Twenty CRM health check passed on port $${HOST_PORT}."
    break
  fi

  echo "[INFO] Twenty CRM is not ready yet. Attempt $${attempt}/60"
  sleep 5
done

if [ "$${HEALTH_SUCCESS}" -ne 1 ]; then
  echo "[ERROR] Twenty CRM did not become ready."
  echo "[INFO] Container status:"
  docker ps -a --filter "name=$${CONTAINER_NAME}"

  echo "[INFO] Twenty CRM container logs:"
  docker logs --tail 200 "$${CONTAINER_NAME}" 2>&1 || true

  exit 1
fi

echo "=================================================="
echo "[OK] Twenty CRM deployment completed successfully."
echo "=================================================="

