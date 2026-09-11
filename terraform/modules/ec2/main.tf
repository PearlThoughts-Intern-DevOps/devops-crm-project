data "aws_ami" "selected" {
  most_recent = false
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = [var.ami_id]
  }
}

resource "aws_instance" "twenty_crm" {
  ami                    = data.aws_ami.selected.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  iam_instance_profile        = var.iam_instance_profile
  user_data_replace_on_change = true

  user_data = <<-EOF
#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io awscli curl

fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

systemctl enable docker
systemctl start docker

TOKEN=$(curl -sS -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" http://169.254.169.254/latest/api/token)
PUBLIC_IP=$(curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

mkdir -p /opt/twenty

docker pull twentycrm/twenty:latest
docker network create twenty-network || true

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

docker rm -f twenty-redis 2>/dev/null || true
docker run -d \
  --name twenty-redis \
  --network twenty-network \
  --restart unless-stopped \
  redis:7-alpine

until docker exec twenty-postgres pg_isready -U twenty -d default; do
  echo "Waiting for PostgreSQL..."
  sleep 5
done

until docker exec twenty-redis redis-cli ping | grep -q PONG; do
  echo "Waiting for Redis..."
  sleep 5
done

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
  -e STORAGE_TYPE=s3 \
  -e STORAGE_S3_REGION="${var.aws_region}" \
  -e STORAGE_S3_NAME="${var.s3_bucket_name}" \
  -e STORAGE_S3_ENDPOINT="https://s3.${var.aws_region}.amazonaws.com" \
  -e ENCRYPTION_KEY="twenty-ec2-encryption-key-change-me" \
  -e FALLBACK_ENCRYPTION_KEY="twenty-ec2-encryption-key-change-me" \
  -e APP_SECRET="twenty-ec2-app-secret-change-me" \
  -v twenty_data:/app/packages/twenty-server/.local-storage \
  twentycrm/twenty:latest

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
  -e STORAGE_TYPE=s3 \
  -e STORAGE_S3_REGION="${var.aws_region}" \
  -e STORAGE_S3_NAME="${var.s3_bucket_name}" \
  -e STORAGE_S3_ENDPOINT="https://s3.${var.aws_region}.amazonaws.com" \
  -e ENCRYPTION_KEY="twenty-ec2-encryption-key-change-me" \
  -e FALLBACK_ENCRYPTION_KEY="twenty-ec2-encryption-key-change-me" \
  -e APP_SECRET="twenty-ec2-app-secret-change-me" \
  -v twenty_data:/app/packages/twenty-server/.local-storage \
  twentycrm/twenty:latest \
  yarn worker:prod

echo "Twenty CRM deployment completed."
EOF

  tags = {
    Name    = "${var.project_name}-ec2"
    Project = var.project_name
  }
}