#!/bin/bash

set -e

dnf update -y
dnf install -y docker awscli

systemctl enable --now docker
usermod -aG docker ec2-user

ECR_REGISTRY="${ecr_registry}"
IMAGE_URI="${image_uri}"
CONTAINER_NAME="twenty-crm"
CONTAINER_PORT="${container_port}"

aws ecr get-login-password --region "${aws_region}" \
  | docker login --username AWS --password-stdin "${ecr_registry}"

for attempt in {1..30}; do
  echo "Attempt $${attempt}: Pulling $${IMAGE_URI}"

  if docker pull "$${IMAGE_URI}"; then
    echo "Image pulled successfully."
    break
  fi

  if [ "$${attempt}" -eq 30 ]; then
    echo "Failed to pull image after 30 attempts."
    exit 1
  fi

  sleep 20
done

docker rm -f "$${CONTAINER_NAME}" 2>/dev/null || true

docker run -d \
  --name "$${CONTAINER_NAME}" \
  --restart unless-stopped \
  -p "3000:3000" \
  "$${IMAGE_URI}"

echo "Twenty CRM container started."
