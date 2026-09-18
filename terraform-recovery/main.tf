terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "recovery_sg" {
  name        = "recovery-test-sg-ubuntu"
  description = "SSH and app access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "twenty_crm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  key_name               = "twenty-key"
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.recovery_sg.id]

  user_data = <<-USERDATA
#!/bin/bash
set -e
apt-get update -y
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
ENC_KEY=$(openssl rand -hex 16)

mkdir -p /home/ubuntu/twenty-crm
cd /home/ubuntu/twenty-crm

cat > docker-compose.yml << COMPOSEOF
version: "3.8"
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: default
    volumes:
      - pgdata:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 5s
      retries: 3

  redis:
    image: redis:alpine
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 5s
      retries: 3

  server:
    image: twentycrm/twenty:latest
    container_name: twenty-crm
    ports:
      - "2020:3000"
    environment:
      SERVER_URL: http://$PUBLIC_IP:2020
      FRONTEND_URL: http://$PUBLIC_IP:2020
      PG_DATABASE_URL: postgres://postgres:postgres@postgres:5432/default
      REDIS_URL: redis://redis:6379
      ENCRYPTION_KEY: $ENC_KEY
      APP_SECRET: $ENC_KEY
    depends_on:
      - postgres
      - redis
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "node", "-e", "require('http').get('http://localhost:3000/',r=>process.exit(r.statusCode<500?0:1)).on('error',()=>process.exit(1))"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 90s

volumes:
  pgdata:
COMPOSEOF

chown -R ubuntu:ubuntu /home/ubuntu/twenty-crm
docker-compose up -d
USERDATA

  tags = {
    Name = "Twenty-CRM-Recovery-Ubuntu"
  }
}

output "instance_id" {
  value = aws_instance.twenty_crm.id
}

output "public_ip" {
  value = aws_instance.twenty_crm.public_ip
}
