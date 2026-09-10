terraform {
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

data "aws_vpc" "default" {
  id = var.vpc_id
}

data "aws_subnet" "public" {
  id = var.subnet_id
}

data "aws_security_group" "twenty_crm" {
  filter {
    name   = "group-name"
    values = ["twenty-crm-sg"]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_iam_instance_profile" "ec2_s3" {
  name = var.iam_instance_profile_name
}

resource "aws_s3_bucket" "twenty_crm" {
  bucket        = var.s3_bucket_name
  force_destroy = true
  tags = {
    Name        = "${var.project_name}-s3"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "twenty_crm" {
  bucket = aws_s3_bucket.twenty_crm.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "twenty_crm" {
  bucket = aws_s3_bucket.twenty_crm.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "twenty_crm" {
  bucket = aws_s3_bucket.twenty_crm.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_instance" "twenty_crm" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = data.aws_subnet.public.id

  key_name                    = var.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    data.aws_security_group.twenty_crm.id
  ]

  iam_instance_profile = data.aws_iam_instance_profile.ec2_s3.name

  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region     = var.aws_region
    s3_bucket_name = aws_s3_bucket.twenty_crm.bucket
    s3_bucket_arn  = aws_s3_bucket.twenty_crm.arn
    twenty_image   = var.twenty_image
  })

  user_data_replace_on_change = true

  tags = {
    Name        = var.project_name
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_s3_bucket.twenty_crm,
    aws_s3_bucket_versioning.twenty_crm,
    aws_s3_bucket_server_side_encryption_configuration.twenty_crm,
    aws_s3_bucket_public_access_block.twenty_crm
  ]
}
