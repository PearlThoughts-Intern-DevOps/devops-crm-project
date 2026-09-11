#!/bin/bash

apt-get update -y
apt-get install -y docker.io awscli

systemctl enable docker
systemctl start docker

ECR_REGISTRY=$(echo "${ecr_repository_url}" | cut -d'/' -f1)
IMAGE="${ecr_repository_url}:latest"

aws ecr get-login-password --region ${aws_region} | \
  docker login --username AWS --password-stdin "$ECR_REGISTRY"

MAX_RETRIES=30
RETRY_INTERVAL=30

for ((i=1; i<=MAX_RETRIES; i++)); do
  echo "Attempt $i/$MAX_RETRIES: Pulling $IMAGE"

  if docker pull "$IMAGE"; then
    echo "ECR image pulled successfully."
    break
  fi

  if [ "$i" -eq "$MAX_RETRIES" ]; then
    echo "Failed to pull ECR image after $MAX_RETRIES attempts."
    exit 1
  fi

  echo "Image not available yet. Retrying in $RETRY_INTERVAL seconds..."
  sleep "$RETRY_INTERVAL"
done

docker run -d \
  --name twenty-crm \
  --restart unless-stopped \
  -p ${host_port}:${twenty_container_port} \
  -e STORAGE_TYPE=s3 \
  -e STORAGE_S3_REGION=${aws_region} \
  -e STORAGE_S3_NAME=${s3_bucket_name} \
  "$IMAGE"