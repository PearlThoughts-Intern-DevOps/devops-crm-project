#!/bin/bash

set -e

dnf update -y
dnf install -y docker awscli

systemctl enable docker
systemctl start docker

ECR_REPOSITORY_URL="${ecr_repository_url}"
IMAGE_TAG="${docker_image_tag}"

REGION="us-east-1"

aws ecr get-login-password --region "$REGION" | \
docker login --username AWS --password-stdin "$ECR_REPOSITORY_URL"

IMAGE="$ECR_REPOSITORY_URL:$IMAGE_TAG"

for i in {1..30}; do
    if docker pull "$IMAGE"; then
        docker run -d \
          --name twenty-crm \
          -p 2020:3000 \
          "$IMAGE"

        exit 0
    fi

    echo "Image not available yet. Retrying in 30 seconds..."
    sleep 30
done

echo "Failed to pull Twenty CRM image after retries."
exit 1
