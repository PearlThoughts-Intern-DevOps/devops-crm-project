
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Use the existing/default VPC
data "aws_vpc" "default" {
  default = true
}

# Use an existing subnet in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Existing ECR repository
resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.project_name
    Project     = var.project_name
    Environment = "dev"
  }
}

# Security group for Twenty CRM
resource "aws_security_group" "twenty_crm" {
  name        = "twenty-crm-sg"
  description = "Security group for Twenty CRM"
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
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application port 2020"
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

  tags = {
    Name        = "twenty-crm-sg"
    Project     = var.project_name
    Environment = "dev"
  }
}

# EC2 instance for Twenty CRM
resource "aws_instance" "twenty_crm" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.twenty_crm.id]
  key_name               = var.key_name

  # Existing IAM instance profile provided for ECR access
  iam_instance_profile = "EC2ECRPullRole"

  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region     = var.aws_region
    ecr_repository = var.ecr_repository_name
    image_tag      = "latest"
  })

  tags = {
    Name        = "twenty-crm"
    Project     = var.project_name
    Environment = "dev"
  }
}

