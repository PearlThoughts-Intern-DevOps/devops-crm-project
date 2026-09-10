#!/bin/bash

apt-get update -y
apt-get install -y docker.io awscli

systemctl enable docker
systemctl start docker

REGION="${aws_region}"
ECR_REPOSITORY="${ecr_repository_url}"
IMAGE="${ecr_repository_url}:${docker_image_tag}"

until aws ecr get-login-password --region "$REGION" | \
  docker login --username AWS --password-stdin "$ECR_REPOSITORY"
do
  echo "Waiting for ECR authentication..."
  sleep 20
done

until docker pull "$IMAGE"
do
  echo "Image not available yet. Retrying..."
  sleep 20
done

docker rm -f twenty-crm 2>/dev/null || true

docker run -d \
  --name twenty-crm \
  --restart unless-stopped \
  -p 3000:3000 \
  "$IMAGE"

echo "Twenty CRM started."
