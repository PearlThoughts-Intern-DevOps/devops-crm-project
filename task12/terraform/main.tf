data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}

resource "aws_security_group" "twenty_crm" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Twenty CRM Backend"
    from_port   = var.backend_port
    to_port     = var.backend_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom CRM Application"
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-sg"
    Project     = "devops-crm-project"
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = var.ecr_repository_name
    Project     = "devops-crm-project"
    Task        = "12"
    Environment = var.environment
  }
}

resource "aws_instance" "twenty_crm" {
  ami                         = "ami-0b6d9d3d33ba97d99"
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids      = [aws_security_group.twenty_crm.id]
  associate_public_ip_address = true

  # Existing IAM instance profile provided by mam
  iam_instance_profile = "EC2ECRPullRole"

  user_data = <<-USERDATA
#!/bin/bash
set -eux

exec >> /var/log/twenty-crm-user-data.log 2>&1

apt-get update -y

DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  unzip \
  awscli \
  docker.io \
  docker-compose-v2

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

mkdir -p /opt/twenty-crm
cd /opt/twenty-crm

AWS_REGION="${var.aws_region}"
ECR_REGISTRY="${aws_ecr_repository.twenty_crm.repository_url}"
CUSTOM_IMAGE="$${ECR_REGISTRY}:latest"

cat > /opt/twenty-crm/docker-compose.yml <<COMPOSE
services:
  twenty-server:
    image: twentycrm/twenty-app-dev:latest
    container_name: twenty-server
    ports:
      - "${var.backend_port}:${var.backend_port}"
    environment:
      PORT: "${var.backend_port}"
      SERVER_URL: "http://$$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):${var.backend_port}"
      NODE_ENV: "development"
      STORAGE_TYPE: "local"
      APPLICATION_LOG_DRIVER: "CONSOLE"
    volumes:
      - twenty-dev-data:/data/postgres
      - twenty-dev-storage:/app/packages/twenty-server/.local-storage
    restart: unless-stopped

  crm-app:
    image: "$${CUSTOM_IMAGE}"
    container_name: crm-app
    depends_on:
      - twenty-server
    ports:
      - "${var.application_port}:${var.application_port}"
    environment:
      NODE_ENV: "production"
      PORT: "${var.application_port}"
      TWENTY_API_URL: "http://twenty-server:${var.backend_port}"
      TWENTY_API_KEY: "${var.twenty_api_key}"
    restart: unless-stopped

volumes:
  twenty-dev-data:
  twenty-dev-storage:
COMPOSE

until aws ecr get-login-password \
  --region "$${AWS_REGION}" | docker login \
  --username AWS \
  --password-stdin "$${ECR_REGISTRY%/*}"
do
  sleep 10
done

until docker pull "$${CUSTOM_IMAGE}"
do
  sleep 15
done

docker compose -f /opt/twenty-crm/docker-compose.yml up -d
USERDATA

  # Recreate the EC2 instance whenever User Data changes
  user_data_replace_on_change = true

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
  }

  depends_on = [
    aws_ecr_repository.twenty_crm
  ]
}