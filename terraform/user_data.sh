#!/bin/bash

set -u

exec > >(tee /var/log/twenty-crm-user-data.log | logger -t twenty-crm-user-data -s 2>/dev/console) 2>&1

echo "========================================"
echo "Starting Twenty CRM EC2 setup"
echo "========================================"

# ----------------------------------------
# Create 2GB swap
# Important for t3.small (~2GB RAM)
# ----------------------------------------

echo "========================================"
echo "Configuring 2GB swap"
echo "========================================"

if [ ! -f /swapfile ]; then
    echo "Creating 2GB swap file..."

    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
else
    echo "Swap file already exists."
fi

# Enable swap if it is not already active
if ! swapon --show | grep -q "/swapfile"; then
    echo "Enabling swap..."
    swapon /swapfile
else
    echo "Swap is already enabled."
fi

# Make swap permanent after reboot
if ! grep -q "^/swapfile " /etc/fstab; then
    echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
fi

echo "Swap configuration:"
free -h

# ----------------------------------------
# Terraform-provided variables
# ----------------------------------------

AWS_REGION="${aws_region}"
ECR_REPOSITORY_URL="${ecr_repository_url}"
IMAGE_TAG="${image_tag}"
CONTAINER_NAME="${container_name}"
APP_PORT="${app_port}"

echo "AWS Region: $AWS_REGION"
echo "ECR Repository: $ECR_REPOSITORY_URL"
echo "Image Tag: $IMAGE_TAG"
echo "Container: $CONTAINER_NAME"
echo "Application Port: $APP_PORT"

# ----------------------------------------
# Update system packages
# ----------------------------------------

echo "Updating system packages..."

dnf update -y

# ----------------------------------------
# Install Docker
# ----------------------------------------

echo "Installing Docker..."

dnf install -y docker

# ----------------------------------------
# Install AWS CLI if required
# ----------------------------------------

if ! command -v aws >/dev/null 2>&1; then
    echo "AWS CLI not found. Installing AWS CLI..."
    dnf install -y awscli
fi

# ----------------------------------------
# Start Docker
# ----------------------------------------

echo "Starting Docker..."

systemctl enable docker
systemctl start docker

# Wait until Docker is ready
until docker info >/dev/null 2>&1; do
    echo "Waiting for Docker to become ready..."
    sleep 5
done

echo "Docker is ready."

# ----------------------------------------
# ECR image pull retry configuration
# ----------------------------------------

MAX_RETRIES=60
RETRY_INTERVAL=30

echo "========================================"
echo "Waiting for Twenty CRM image in ECR"
echo "========================================"

for ((i=1; i<=MAX_RETRIES; i++)); do

    echo "ECR pull attempt $i/$MAX_RETRIES"

    # ------------------------------------
    # Authenticate with Amazon ECR
    # ------------------------------------

    echo "Authenticating with Amazon ECR..."

    if aws ecr get-login-password --region "$AWS_REGION" | \
        docker login \
        --username AWS \
        --password-stdin "$ECR_REPOSITORY_URL"; then

        echo "ECR authentication successful."

    else

        echo "ECR authentication failed."

    fi

    # ------------------------------------
    # Pull Twenty CRM image
    # ------------------------------------

    echo "Attempting to pull:"
    echo "$ECR_REPOSITORY_URL:$IMAGE_TAG"

    if docker pull "$ECR_REPOSITORY_URL:$IMAGE_TAG"; then

        echo "========================================"
        echo "Twenty CRM image successfully pulled!"
        echo "========================================"

        # --------------------------------
        # Remove existing container
        # --------------------------------

        docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

        # --------------------------------
        # Start Twenty CRM
        # --------------------------------

        echo "Starting Twenty CRM container..."

        docker run -d \
            --name "$CONTAINER_NAME" \
            --restart unless-stopped \
            -p "$APP_PORT:$APP_PORT" \
            "$ECR_REPOSITORY_URL:$IMAGE_TAG"

        # --------------------------------
        # Verify container started
        # --------------------------------

        sleep 10

        if docker ps --filter "name=$CONTAINER_NAME" --filter "status=running" | grep -q "$CONTAINER_NAME"; then

            echo "========================================"
            echo "Twenty CRM is running successfully!"
            echo "========================================"

            docker ps

            exit 0

        else

            echo "Twenty CRM container failed to start."
            docker logs "$CONTAINER_NAME" 2>/dev/null || true

            exit 1
        fi

    fi

    echo "Twenty CRM image is not available yet."
    echo "Waiting $RETRY_INTERVAL seconds before retry..."

    sleep "$RETRY_INTERVAL"

done

echo "========================================"
echo "ERROR: Twenty CRM image could not be pulled"
echo "after $MAX_RETRIES attempts."
echo "========================================"

exit 1
