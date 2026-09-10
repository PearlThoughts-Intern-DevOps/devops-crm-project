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

# Use the existing/default VPC
data "aws_vpc" "default" {
  default = true
}

# Use an existing/default subnet
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

# Generate an SSH key pair using Terraform
resource "tls_private_key" "task13" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "task13" {
  key_name   = "task13-key"
  public_key = tls_private_key.task13.public_key_openssh
}

resource "local_sensitive_file" "task13_private_key" {
  filename        = "${path.module}/task13-key.pem"
  content         = tls_private_key.task13.private_key_pem
  file_permission = "0600"
}

# Security group for Twenty CRM
resource "aws_security_group" "twenty_prabhas" {
  name        = "task13-twenty-sg-prabhas"
  description = "Security group for Task 13 Twenty CRM EC2"
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
    Name        = "prabhas-task13-twenty-sg"
    Environment = "task13"
  }
}

# S3 bucket for Twenty CRM storage
resource "aws_s3_bucket" "twenty_storage" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name        = "task13-twenty-storage"
    Environment = "task13"
    Purpose     = "Twenty CRM storage"
  }
}

# Enable S3 versioning
resource "aws_s3_bucket_versioning" "twenty_storage" {
  bucket = aws_s3_bucket.twenty_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "twenty_storage" {
  bucket = aws_s3_bucket.twenty_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "twenty_storage" {
  bucket = aws_s3_bucket.twenty_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# EC2 instance
resource "aws_instance" "twenty-prabhas" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = local.subnet_id
  associate_public_ip_address = true

  key_name = aws_key_pair.task13.key_name

  vpc_security_group_ids = [
    aws_security_group.twenty_prabhas.id
  ]

  # Existing IAM instance profile provided for Task 13.
  # No IAM resources are created by Terraform.
  iam_instance_profile = "EC2S3AccessRole"

  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region     = var.aws_region
    s3_bucket_name = aws_s3_bucket.twenty_storage.bucket
    image_tag      = var.image_tag
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name        = "prabhas-task13"
    Environment = "task13"
    Purpose     = "Twenty CRM"
    }
}
