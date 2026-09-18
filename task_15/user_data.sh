#!/bin/bash

set -u

exec > >(tee /var/log/twenty-crm-user-data.log | logger -t twenty-crm-user-data -s 2>/dev/console) 2>&1

echo "Starting Twenty CRM EC2 setup..."

TWENTY_IMAGE="${twenty_image}"

echo "Twenty CRM Image: $TWENTY_IMAGE"

echo "Updating system packages..."
dnf update -y

echo "Installing Docker..."
dnf install -y docker

echo "Starting Docker..."
systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

echo "Docker installation completed."

echo "Pulling Twenty CRM image..."
docker pull "$TWENTY_IMAGE"

echo "Removing existing Twenty CRM container if present..."
docker rm -f twenty-crm 2>/dev/null || true

echo "Starting Twenty CRM..."

docker run -d \
    --name twenty-crm \
    --restart unless-stopped \
    -p 3000:3000 \
    "$TWENTY_IMAGE"

echo "Twenty CRM container started."

echo "Waiting for Twenty CRM to start..."
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
