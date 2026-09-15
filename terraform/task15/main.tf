terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_password" "encryption_key" {
  length  = 64
  special = false
}

# --------------------------------------------------
# Default VPC
# --------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

# --------------------------------------------------
# Default VPC Subnets
# --------------------------------------------------

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --------------------------------------------------
# Generate SSH Private/Public Key
# --------------------------------------------------

resource "tls_private_key" "prabhas" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# --------------------------------------------------
# Register Public Key in AWS
# --------------------------------------------------

resource "aws_key_pair" "prabhas" {
  key_name   = var.key_name
  public_key = tls_private_key.prabhas.public_key_openssh
}

# --------------------------------------------------
# Save Private Key Locally
# --------------------------------------------------

resource "local_sensitive_file" "prabhas_private_key" {
  filename        = "${path.module}/${var.key_name}.pem"
  content         = tls_private_key.prabhas.private_key_pem
  file_permission = "0600"
}

# --------------------------------------------------
# EC2 Security Group
# --------------------------------------------------

resource "aws_security_group" "prabhas_sg" {
  name        = "task15-twenty-prabhas-sg"
  description = "Security group for Twenty CRM EC2"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  # Twenty CRM traffic only from ALB
  ingress {
    description     = "Twenty CRM from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.prabhas_alb.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "task15-twenty-ec2-sg"
    Environment = "task15"
  }
}

# --------------------------------------------------
# ALB Security Group
# --------------------------------------------------

resource "aws_security_group" "prabhas_alb" {
  name        = "task15-twenty-prabhas-alb-sg"
  description = "Security group for Twenty CRM ALB"
  vpc_id      = data.aws_vpc.default.id

  # Public HTTP
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
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
    Name        = "task15-twenty-alb-sg"
    Environment = "task15"
  }
}

# --------------------------------------------------
# EC2 Instance
# --------------------------------------------------

resource "aws_instance" "prabhas_twenty" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.prabhas_sg.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.prabhas.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    alb_dns_name   = aws_lb.twenty.dns_name
    encryption_key = random_password.encryption_key.result
  })

  tags = {
    Name        = "task15-prabhas-twenty-crm"
    Environment = "task15"
  }

  depends_on = [
    local_sensitive_file.prabhas_private_key
  ]
}

# --------------------------------------------------
# Application Load Balancer
# --------------------------------------------------

resource "aws_lb" "twenty" {
  name               = "task15-twenty-prabhas-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.prabhas_alb.id
  ]

  subnets = data.aws_subnets.default.ids

  tags = {
    Name        = "task15-twenty-alb"
    Environment = "task15"
  }
}

# --------------------------------------------------
# Target Group
# --------------------------------------------------

resource "aws_lb_target_group" "prabhas_twenty" {
  name     = "task15-twenty-prabhas-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "8080"
    path                = "/api/health"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name        = "task15-twenty-tg"
    Environment = "task15"
  }
}

# --------------------------------------------------
# Register EC2 with Target Group
# --------------------------------------------------

resource "aws_lb_target_group_attachment" "twenty" {
  target_group_arn = aws_lb_target_group.prabhas_twenty.arn
  target_id        = aws_instance.prabhas_twenty.id
  port             = 8080
}

# --------------------------------------------------
# ALB Listener
# --------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.twenty.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.prabhas_twenty.arn
  }
}
