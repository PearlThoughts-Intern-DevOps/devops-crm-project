#!/bin/bash

set -u

exec > >(tee -a /var/log/task12-user-data.log) 2>&1

echo "===== Task 12 User Data Started ====="
date

echo "Updating packages..."
apt-get update -y

echo "Installing Docker and AWS CLI..."
apt-get install -y docker.io awscli

echo "Starting Docker..."
systemctl enable docker
systemctl start docker

REGION="${aws_region}"
ECR_REPOSITORY="${ecr_repository_url}"
IMAGE_TAG="${image_tag}"

IMAGE="$ECR_REPOSITORY:$IMAGE_TAG"

echo "AWS Region: $REGION"
echo "ECR Repository: $ECR_REPOSITORY"
echo "Image: $IMAGE"

echo "Waiting for EC2 IAM role credentials..."

for i in {1..30}; do
    if aws sts get-caller-identity --region "$REGION" >/dev/null 2>&1; then
        echo "AWS credentials available."
        break
    fi

    echo "IAM credentials not available yet. Retrying..."
    sleep 10
done

echo "Authenticating with Amazon ECR..."

aws ecr get-login-password --region "$REGION" \
    | docker login \
        --username AWS \
        --password-stdin "$ECR_REPOSITORY"

MAX_RETRIES=30
RETRY_INTERVAL=20

echo "Waiting for Twenty CRM image in ECR..."

for attempt in $(seq 1 "$MAX_RETRIES"); do

    echo "ECR image pull attempt $attempt/$MAX_RETRIES"

    if docker pull "$IMAGE"; then
        echo "Twenty CRM image pulled successfully."
        break
    fi

    if [ "$attempt" -eq "$MAX_RETRIES" ]; then
        echo "ERROR: Twenty CRM image was not available."
        exit 1
    fi

    echo "Image not available yet."
    echo "Retrying in $RETRY_INTERVAL seconds..."

    sleep "$RETRY_INTERVAL"
done

echo "Starting Twenty CRM..."

docker rm -f twenty-server 2>/dev/null || true

docker run -d \
    --name twenty-server \
    --restart unless-stopped \
    -p 8080:2020 \
    -v twenty-data:/data \
    "$IMAGE"

echo "Twenty CRM container started."

docker ps

echo "===== Task 12 User Data Completed ====="
date
