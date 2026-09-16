# -------------------------------------------------------------------
# Existing/default VPC and subnet
# -------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

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

# -------------------------------------------------------------------
# Provided IAM instance profile
# -------------------------------------------------------------------
#
# Task 13 requires the provided EC2S3AccessRole and does not allow
# Terraform to create IAM users, roles, or policies.
#
# EC2 requires an instance profile, so this assumes the playground
# provides an instance profile named EC2S3AccessRole.

data "aws_iam_instance_profile" "ec2_s3_access" {
  name = "EC2S3AccessRole"
}

# -------------------------------------------------------------------
# Security group
# -------------------------------------------------------------------

resource "aws_security_group" "twenty_crm" {
  name        = "${var.instance_name}-sg"
  description = "Security group for Twenty CRM Task 13"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from administrator"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_ip}/32"]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = var.twenty_port
    to_port     = var.twenty_port
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
    Name = "${var.instance_name}-sg"
  }
}

# -------------------------------------------------------------------
# Amazon S3 bucket
# -------------------------------------------------------------------

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "twenty_crm" {
  bucket = "${var.s3_bucket_prefix}-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${var.instance_name}-s3"
    Application = "Twenty CRM"
    Task        = "Task 13"
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

# -------------------------------------------------------------------
# EC2 instance
# -------------------------------------------------------------------

resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = "t3.small"
  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.twenty_crm.id
  ]

  iam_instance_profile = data.aws_iam_instance_profile.ec2_s3_access.name

  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region       = var.aws_region
    s3_bucket_name   = aws_s3_bucket.twenty_crm.bucket
    twenty_port      = var.twenty_port
    image_wait_secs  = var.image_wait_secs
    max_pull_retries = var.max_pull_retries
    instance_name    = var.instance_name
  })

  user_data_replace_on_change = true

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = var.instance_name
  }
}

