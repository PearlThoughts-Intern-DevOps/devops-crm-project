#!/bin/bash

set -u

exec > >(tee /var/log/twenty-crm-user-data.log | logger -t twenty-crm-user-data -s 2>/dev/console) 2>&1

echo "Starting Twenty CRM EC2 setup..."

REGION="${aws_region}"
S3_BUCKET="${s3_bucket_name}"
S3_BUCKET_ARN="${s3_bucket_arn}"
TWENTY_IMAGE="${twenty_image}"

echo "AWS Region: $REGION"
echo "S3 Bucket: $S3_BUCKET"
echo "Twenty CRM Image: $TWENTY_IMAGE"

echo "Updating system packages..."
dnf update -y

echo "Installing Docker and AWS CLI..."
dnf install -y docker awscli

echo "Starting Docker..."
systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

echo "Docker installation completed."

echo "Checking EC2 IAM role credentials..."

for i in {1..30}; do
    if aws sts get-caller-identity --region "$REGION" >/dev/null 2>&1; then
        echo "AWS credentials are available."
        aws sts get-caller-identity --region "$REGION"
        break
    fi

    echo "Waiting for IAM credentials... attempt $i/30"
    sleep 10
done

echo "Testing S3 access..."

if aws s3api head-bucket \
    --bucket "$S3_BUCKET" \
    --region "$REGION"; then
    echo "S3 bucket access confirmed."
else
    echo "WARNING: S3 bucket access test failed."
fi

echo "Pulling Twenty CRM image..."

docker pull "$TWENTY_IMAGE"

echo "Removing existing Twenty CRM container if present..."

docker rm -f twenty-crm 2>/dev/null || true

echo "Starting Twenty CRM..."

docker run -d \
    --name twenty-crm \
    --restart unless-stopped \
    -p 3000:3000 \
    -e STORAGE_TYPE="s3" \
    -e STORAGE_S3_REGION="$REGION" \
    -e STORAGE_S3_NAME="$S3_BUCKET" \
    "$TWENTY_IMAGE"

echo "Twenty CRM container started."

sleep 30

echo "Docker status:"
docker ps

echo "Twenty CRM logs:"
docker logs --tail 50 twenty-crm || true

echo "Testing local Twenty CRM endpoint..."

if curl -f http://localhost:3000 >/dev/null 2>&1; then
    echo "Twenty CRM is responding on port 3000."
else
    echo "Twenty CRM is not responding yet. Check container logs."
fi

echo "Twenty CRM EC2 setup completed."
