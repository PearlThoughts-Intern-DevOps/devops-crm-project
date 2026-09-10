# ============================================================
# Task 13 - Twenty CRM + AWS S3 using Terraform
# ============================================================

# ------------------------------------------------------------
# Existing Default VPC
# ------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

# ------------------------------------------------------------
# Existing Default Subnet
# ------------------------------------------------------------

data "aws_subnet" "default" {
  id = var.subnet_id
}

# ------------------------------------------------------------
# Approved AMI
# ------------------------------------------------------------

data "aws_ami" "twenty_crm" {
  most_recent = false
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = [var.ami_id]
  }
}

# ------------------------------------------------------------
# Existing Security Group
# ------------------------------------------------------------

data "aws_security_group" "twenty_crm" {
  id = var.security_group_id
}

# ------------------------------------------------------------
# Existing IAM Instance Profile
# ------------------------------------------------------------

data "aws_iam_instance_profile" "ec2_s3" {
  name = "EC2S3AccessRole"
}

# ============================================================
# S3 Bucket
# ============================================================

resource "aws_s3_bucket" "twenty_storage" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name        = "twenty-crm-storage"
    Environment = "dev"
    Project     = "twenty-crm"
    Task        = "task-13"
  }
}

# ------------------------------------------------------------
# S3 Versioning
# ------------------------------------------------------------

resource "aws_s3_bucket_versioning" "twenty_storage" {
  bucket = aws_s3_bucket.twenty_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ------------------------------------------------------------
# S3 Server-Side Encryption
# ------------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "twenty_storage" {
  bucket = aws_s3_bucket.twenty_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ------------------------------------------------------------
# S3 Block Public Access
# ------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "twenty_storage" {
  bucket = aws_s3_bucket.twenty_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================
# EC2 Instance
# ============================================================

resource "aws_instance" "twenty_crm" {
  ami           = data.aws_ami.twenty_crm.id
  instance_type = var.instance_type

  subnet_id = data.aws_subnet.default.id

  key_name = var.key_name

  vpc_security_group_ids = [
    data.aws_security_group.twenty_crm.id
  ]

  iam_instance_profile = data.aws_iam_instance_profile.ec2_s3.name

  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user_data.sh", {
    s3_bucket_name = aws_s3_bucket.twenty_storage.bucket
    aws_region     = var.aws_region
  })

  tags = {
    Name        = "twenty-crm-server"
    Environment = "dev"
    Project     = "twenty-crm"
    Task        = "task-13"
  }
}
