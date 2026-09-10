#!/bin/bash

set -u

exec > >(tee -a /var/log/twenty-user-data.log | logger -t twenty-user-data -s 2>/dev/console) 2>&1

REGION="${aws_region}"
ECR_REPOSITORY="${ecr_repository}"
IMAGE_TAG="${docker_image_tag}"
IMAGE="${ECR_REPOSITORY}:${IMAGE_TAG}"

echo "Starting Twenty CRM EC2 bootstrap..."

dnf update -y
dnf install -y docker

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

echo "Logging in to ECR..."

aws ecr get-login-password --region "${REGION}" \
  | docker login \
      --username AWS \
      --password-stdin "${ECR_REPOSITORY%/*}"

MAX_RETRIES=30
RETRY_INTERVAL=20

for ((i=1; i<=MAX_RETRIES; i++)); do
  echo "Attempt ${i}/${MAX_RETRIES}: pulling ${IMAGE}"

  if docker pull "${IMAGE}"; then
    echo "Image pulled successfully."
    break
  fi

  if [ "$i" -eq "$MAX_RETRIES" ]; then
    echo "Failed to pull image after ${MAX_RETRIES} attempts."
    exit 1
  fi

  echo "Image not available yet. Retrying in ${RETRY_INTERVAL}s..."
  sleep "${RETRY_INTERVAL}"
done

docker rm -f twenty-crm 2>/dev/null || true

docker run -d \
  --name twenty-crm \
  --restart unless-stopped \
  -p 2020:2020 \
  "${IMAGE}"

echo "Twenty CRM container started."

docker ps