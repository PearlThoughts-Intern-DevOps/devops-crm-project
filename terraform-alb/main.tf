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

# --- Data Sources ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Fetch the latest official Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- Security Groups ---
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-ubuntu"
  description = "Allow HTTP traffic to the ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-alb-sg-ubuntu"
  description = "Allow traffic only from the ALB and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 2020
    to_port         = 2020
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# --- EC2 Instance (Ubuntu) ---
resource "aws_instance" "twenty_crm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  key_name               = "twenty-key"
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

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

mkdir -p /home/ubuntu/twenty-crm
cd /home/ubuntu/twenty-crm

cat > docker-compose.yml << 'COMPOSEOF'
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

  redis:
    image: redis:alpine
    restart: unless-stopped

  server:
    image: twentycrm/twenty:latest
    ports:
      - "2020:3000"
    environment:
      SERVER_URL: http://${aws_lb.twenty_crm_alb.dns_name}
      FRONTEND_URL: http://${aws_lb.twenty_crm_alb.dns_name}
      PG_DATABASE_URL: postgres://postgres:postgres@postgres:5432/default
      REDIS_URL: redis://redis:6379
      ENCRYPTION_KEY: 7f2c1a9b8d3e4f5a6b7c8d9e0f1a2b3c
      APP_SECRET: 7f2c1a9b8d3e4f5a6b7c8d9e0f1a2b3c
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
    Name = "Twenty-CRM-ALB-Ubuntu"
  }
}

# --- Application Load Balancer ---
resource "aws_lb" "twenty_crm_alb" {
  name               = "twenty-crm-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

# --- Target Group with Health Check ---
resource "aws_lb_target_group" "twenty_crm_tg" {
  name     = "twenty-crm-tg"
  port     = 2020
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

# --- Register EC2 in Target Group ---
resource "aws_lb_target_group_attachment" "twenty_crm" {
  target_group_arn = aws_lb_target_group.twenty_crm_tg.arn
  target_id        = aws_instance.twenty_crm.id
  port             = 2020
}

# --- ALB Listener ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.twenty_crm_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.twenty_crm_tg.arn
  }
}

# --- Outputs ---
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.twenty_crm_alb.dns_name
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.twenty_crm_tg.arn
}
