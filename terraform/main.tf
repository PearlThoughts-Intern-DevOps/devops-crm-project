data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "twenty_crm" {
  name        = "${var.project_name}-sg"
  description = "Security group for Twenty CRM Task 13"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = "Twenty CRM"
    Task    = "Task 13"
  }
}

resource "aws_s3_bucket" "twenty_storage" {
  bucket = "${var.project_name}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name    = "${var.project_name}-storage"
    Project = "Twenty CRM"
    Task    = "Task 13"
  }
}

resource "aws_s3_bucket_public_access_block" "twenty_storage" {
  bucket = aws_s3_bucket.twenty_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "twenty_storage" {
  bucket = aws_s3_bucket.twenty_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "twenty_storage" {
  bucket = aws_s3_bucket.twenty_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.twenty_crm.id]
  associate_public_ip_address = true

  key_name = "karthikeyan-key"

  iam_instance_profile = var.s3_instance_profile

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e

    exec > >(tee -a /var/log/twenty-crm-task13-init.log | logger -t twenty-crm-init -s 2>/dev/console) 2>&1

    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io awscli

    systemctl enable docker
    systemctl start docker

    until docker info >/dev/null 2>&1; do
      echo "Waiting for Docker..."
      sleep 10
    done

    docker network create twenty-network 2>/dev/null || true

    docker rm -f twenty-postgres twenty-redis twenty-crm 2>/dev/null || true

    docker run -d \
      --name twenty-postgres \
      --network twenty-network \
      -e POSTGRES_USER=twenty \
      -e POSTGRES_PASSWORD=twenty_password \
      -e POSTGRES_DB=twenty \
      --restart unless-stopped \
      postgres:16

    docker run -d \
      --name twenty-redis \
      --network twenty-network \
      --restart unless-stopped \
      redis:7-alpine

    until aws sts get-caller-identity --region ${var.aws_region} >/dev/null 2>&1; do
      echo "Waiting for EC2 IAM role credentials..."
      sleep 15
    done

    until aws s3api head-bucket \
      --bucket ${aws_s3_bucket.twenty_storage.bucket} \
      --region ${var.aws_region} >/dev/null 2>&1; do
      echo "Waiting for S3 bucket access..."
      sleep 15
    done

    docker pull twentycrm/twenty:latest

    until docker exec twenty-postgres pg_isready -U twenty -d twenty >/dev/null 2>&1; do
      echo "Waiting for PostgreSQL..."
      sleep 5
    done

    until docker exec twenty-redis redis-cli ping >/dev/null 2>&1; do
      echo "Waiting for Redis..."
      sleep 5
    done

    ENCRYPTION_KEY=$(openssl rand -hex 32)

    docker run -d \
      --name twenty-crm \
      --network twenty-network \
      -p ${var.app_port}:3000 \
      -e NODE_PORT=3000 \
      -e SERVER_URL=http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):${var.app_port} \
      -e PG_DATABASE_URL=postgresql://twenty:twenty_password@twenty-postgres:5432/twenty \
      -e REDIS_URL=redis://twenty-redis:6379 \
      -e STORAGE_TYPE=S_3 \
      -e STORAGE_S3_REGION=${var.aws_region} \
      -e STORAGE_S3_NAME=${aws_s3_bucket.twenty_storage.bucket} \
      -e ENCRYPTION_KEY="$ENCRYPTION_KEY" \
      --restart unless-stopped \
      twentycrm/twenty:latest

    echo "Twenty CRM Task 13 startup completed."
  EOF

  tags = {
    Name    = "${var.project_name}-ec2"
    Project = "Twenty CRM"
    Task    = "Task 13"
  }
}
