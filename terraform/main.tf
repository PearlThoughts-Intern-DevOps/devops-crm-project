

data "aws_ami" "amazon_linux" {
  most_recent = false
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-0b6d9d3d33ba97d99"]
  }
}

# Security group for Twenty CRM EC2
resource "aws_security_group" "twenty_crm" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH and app traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Twenty CRM app port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

# Amazon ECR repository
resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "twenty-crm"
    Project = "devops-crm-project"
    Task    = "12"
  }
}

# EC2 instance for Twenty CRM
resource "aws_instance" "twenty_crm" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.twenty_crm.id]

  root_block_device {
  volume_size = 20
  volume_type = "gp3"
}

  iam_instance_profile        = "EC2ECRPullRole"
  user_data_replace_on_change = true

  user_data = <<-EOF
#!/bin/bash
set -e

# Install Docker and required packages
apt-get update -y
apt-get install -y docker.io awscli curl

# Create 2 GB swap to provide additional memory
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Start Docker
systemctl enable docker
systemctl start docker

TOKEN=$(curl -sS -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" http://169.254.169.254/latest/api/token)
PUBLIC_IP=$(curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

# Create application directory
mkdir -p /opt/twenty

# Login to Amazon ECR
aws ecr get-login-password --region ${var.aws_region} | \
docker login --username AWS --password-stdin ${aws_ecr_repository.twenty_crm.repository_url}

# Pull the Twenty CRM image.
# Retry because the image may not exist when EC2 starts.
IMAGE_AVAILABLE=false

for attempt in $(seq 1 60); do
  if docker pull ${aws_ecr_repository.twenty_crm.repository_url}:latest; then
    IMAGE_AVAILABLE=true
    break
  fi

  echo "Twenty CRM image not available yet. Retrying in 30 seconds..."
  sleep 30
done

if [ "$IMAGE_AVAILABLE" != "true" ]; then
  echo "Twenty CRM image was not available after multiple attempts."
  exit 1
fi

# Create Docker network
docker network create twenty-network || true

# Start PostgreSQL
docker rm -f twenty-postgres 2>/dev/null || true

docker run -d \
  --name twenty-postgres \
  --network twenty-network \
  --restart unless-stopped \
  -e POSTGRES_USER=twenty \
  -e POSTGRES_PASSWORD=twenty \
  -e POSTGRES_DB=default \
  -v twenty_postgres_data:/var/lib/postgresql/data \
  postgres:16

# Start Redis
docker rm -f twenty-redis 2>/dev/null || true

docker run -d \
  --name twenty-redis \
  --network twenty-network \
  --restart unless-stopped \
  redis:7-alpine

# Wait for PostgreSQL
until docker exec twenty-postgres pg_isready -U twenty -d default; do
  echo "Waiting for PostgreSQL..."
  sleep 5
done

# Wait for Redis
until docker exec twenty-redis redis-cli ping | grep -q PONG; do
  echo "Waiting for Redis..."
  sleep 5
done

# Start Twenty CRM server
docker rm -f twenty-crm 2>/dev/null || true

docker run -d \
  --name twenty-crm \
  --network twenty-network \
  --restart unless-stopped \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e NODE_PORT=3000 \
  -e PG_DATABASE_URL="postgresql://twenty:twenty@twenty-postgres:5432/default" \
  -e REDIS_URL="redis://twenty-redis:6379" \
  -e SERVER_URL="http://$${PUBLIC_IP}:3000" \
  -e DISABLE_CRON_JOBS_REGISTRATION="true" \
  -e STORAGE_TYPE=local \
  -e ENCRYPTION_KEY="twenty-ec2-encryption-key-change-me" \
  -e FALLBACK_ENCRYPTION_KEY="twenty-ec2-encryption-key-change-me" \
  -e APP_SECRET="twenty-ec2-app-secret-change-me" \
  -v twenty_data:/app/packages/twenty-server/.local-storage \
--entrypoint node \
${aws_ecr_repository.twenty_crm.repository_url}:latest \
dist/main

# Start Twenty CRM worker
docker rm -f twenty-worker 2>/dev/null || true

docker run -d \
  --name twenty-worker \
  --network twenty-network \
  --restart unless-stopped \
  -e NODE_ENV=production \
  -e PG_DATABASE_URL="postgresql://twenty:twenty@twenty-postgres:5432/default" \
  -e REDIS_URL="redis://twenty-redis:6379" \
  -e SERVER_URL="http://$${PUBLIC_IP}:3000" \
  -e DISABLE_CRON_JOBS_REGISTRATION="true" \
  -e STORAGE_TYPE=local \
  -e ENCRYPTION_KEY="twenty-ec2-encryption-key-change-me" \
  -e FALLBACK_ENCRYPTION_KEY="twenty-ec2-encryption-key-change-me" \
  -e APP_SECRET="twenty-ec2-app-secret-change-me" \
  -v twenty_data:/app/packages/twenty-server/.local-storage \
  ${aws_ecr_repository.twenty_crm.repository_url}:latest \
  yarn worker:prod

echo "Twenty CRM deployment completed."
EOF

  tags = {
    Name    = "${var.project_name}-ec2"
    Project = var.project_name
  }
}