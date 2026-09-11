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
  name        = "twenty-crm-task12-sg"
  description = "Security group for Twenty CRM EC2 instance"
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
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.project_name
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-ecr"
  }
}

resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = "karthikeyan-key"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.twenty_crm.id]
  associate_public_ip_address = true
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }
  iam_instance_profile = "EC2ECRPullRole"

  user_data = <<-EOF_USERDATA
    #!/bin/bash
    set -e

    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io awscli
    systemctl enable docker
    systemctl start docker

    ECR_REPOSITORY="${aws_ecr_repository.twenty_crm.repository_url}"
    IMAGE="$${ECR_REPOSITORY}:latest"

    mkdir -p /opt/twenty-crm

    docker network create twenty-network 2>/dev/null || true

    docker run -d \
      --name postgres \
      --restart unless-stopped \
      --network twenty-network \
      -e POSTGRES_USER=twenty \
      -e POSTGRES_PASSWORD=twenty_password \
      -e POSTGRES_DB=twenty \
      postgres:16

    docker run -d \
      --name redis \
      --restart unless-stopped \
      --network twenty-network \
      redis:7-alpine

    until aws ecr get-login-password --region "${var.aws_region}" | docker login --username AWS --password-stdin "$${ECR_REPOSITORY}"; do
      sleep 30
    done

    until docker pull "$${IMAGE}"; do
      echo "Waiting for Twenty CRM image..." >> /var/log/twenty-crm-init.log
      sleep 60
    done

    docker rm -f twenty-crm 2>/dev/null || true

    docker run -d \
      --name twenty-crm \
      --restart unless-stopped \
      --network twenty-network \
      -p ${var.app_port}:3000 \
      -e NODE_PORT=3000 \
      -e SERVER_URL=http://localhost:${var.app_port} \
      -e PG_DATABASE_URL=postgresql://twenty:twenty_password@postgres:5432/twenty \
      -e REDIS_URL=redis://redis:6379 \
      -e ENCRYPTION_KEY=03f3262e22d393af76dd43269f3c7d22947f0ac1ea61e9f864955cf3555962ce \
      "$${IMAGE}"

    echo "Twenty CRM startup completed." > /var/log/twenty-crm-init.log
  EOF_USERDATA

  tags = {
    Name = "${var.project_name}-ec2"
  }

  depends_on = [aws_ecr_repository.twenty_crm]
}
