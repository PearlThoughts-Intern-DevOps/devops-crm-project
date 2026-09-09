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
  }
}

provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "task12" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "task12" {
  key_name   = "task12-key"
  public_key = tls_private_key.task12.public_key_openssh
}

resource "local_sensitive_file" "task12_private_key" {
  filename        = "${path.module}/task12-key.pem"
  content         = tls_private_key.task12.private_key_pem
  file_permission = "0600"
}

# Get the existing default VPC
data "aws_vpc" "default" {
  default = true
}

# Get the existing default subnet
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# Select the first available default subnet
locals {
  subnet_id = data.aws_subnets.default.ids[0]
}

# Amazon ECR repository for Twenty CRM
resource "aws_ecr_repository" "twenty" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "task12-twenty-crm"
    Environment = "task12"
  }
}


# Security group for Twenty CRM EC2 instance
resource "aws_security_group" "twenty" {
  name        = "task12-twenty-sg"
  description = "Security group for Task 12 Twenty CRM EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "task12-twenty-sg"
    Environment = "task12"
  }
}
resource "aws_instance" "twenty" {
  ami           = var.ami_id
  instance_type = "t3.small"
  key_name      = aws_key_pair.task12.key_name
  subnet_id     = local.subnet_id

  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.twenty.id
  ]

  iam_instance_profile = "EC2ECRPullRole"

  user_data = templatefile("${path.module}/user_data.sh", {
    ecr_repository_url = aws_ecr_repository.twenty.repository_url
    aws_region         = var.aws_region
    image_tag          = var.image_tag
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name        = "prabhas-task12"
    Environment = "task12"
  }
}
