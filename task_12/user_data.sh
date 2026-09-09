#!/bin/bash

set -u

exec > >(tee /var/log/twenty-crm-user-data.log | logger -t twenty-crm-user-data -s 2>/dev/console) 2>&1

echo "Starting Twenty CRM EC2 setup..."

REGION="${aws_region}"
ECR_REPOSITORY="${ecr_repository_url}"
IMAGE_TAG="${image_tag}"
IMAGE="${ecr_repository_url}:${image_tag}"

echo "AWS Region: $REGION"
echo "ECR Repository: $ECR_REPOSITORY"
echo "Image: $IMAGE"

dnf update -y

dnf install -y docker awscli

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

echo "Docker installation completed."

echo "Waiting for EC2 IAM credentials..."

for i in {1..30}; do
    if aws sts get-caller-identity --region "$REGION" >/dev/null 2>&1; then
        echo "AWS credentials are available."
        break
    fi

    echo "Waiting for IAM credentials... attempt $i/30"
    sleep 10
done

MAX_RETRIES=60
RETRY_INTERVAL=30

for attempt in $(seq 1 $MAX_RETRIES); do

    echo "=========================================="
    echo "ECR pull attempt $attempt/$MAX_RETRIES"
    echo "=========================================="

    echo "Authenticating with Amazon ECR..."

    if aws ecr get-login-password --region "$REGION" | \
        docker login --username AWS --password-stdin "$ECR_REPOSITORY"; then

        echo "ECR authentication successful."

        echo "Attempting to pull $IMAGE..."

        if docker pull "$IMAGE"; then

            echo "Successfully pulled $IMAGE."

            # Remove old container if it exists
            docker rm -f twenty-crm 2>/dev/null || true

            echo "Starting Twenty CRM..."

            docker run -d \
                --name twenty-crm \
                --restart unless-stopped \
                -p 3000:3000 \
                "$IMAGE"

            echo "Twenty CRM container started."

            sleep 20

            if docker ps --filter "name=twenty-crm" --filter "status=running" | grep -q twenty-crm; then
                echo "Twenty CRM is running successfully."
                exit 0
            else
                echo "Twenty CRM container is not running."
                docker logs twenty-crm || true
            fi

        else
            echo "Image is not available yet."
        fi

    else
        echo "ECR authentication failed."
    fi

    echo "Waiting $RETRY_INTERVAL seconds before retry..."
    sleep "$RETRY_INTERVAL"

done

echo "ERROR: Failed to pull and start Twenty CRM."
exit 1
