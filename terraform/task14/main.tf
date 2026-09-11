terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Use the existing default VPC
data "aws_vpc" "default" {
  default = true
}

# Use an existing default subnet
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

locals {
  subnet_id = data.aws_subnets.default.ids[0]
}

# Security group for EC2
resource "aws_security_group" "twenty" {
  name        = "task14-twenty-sg"
  description = "Security group for Task 14 Twenty CRM"
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "task14-twenty-sg"
    Environment = "task14"
  }
}

# S3 Module
module "s3" {
  source = "./modules/s3"

  bucket_name = var.s3_bucket_name
  environment = "task14"
  purpose     = "Twenty CRM storage"
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  repository_name      = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  ami_id               = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = local.subnet_id
  security_group_ids   = [aws_security_group.twenty.id]
  key_name             = "task14-key"
  name                 = "prabhas-task14-twenty"
}
