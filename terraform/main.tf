# ============================================================
# EXISTING DEFAULT VPC
# ============================================================

data "aws_vpc" "default" {
  default = true
}


# ============================================================
# EXISTING SUBNETS IN DEFAULT VPC
# ============================================================

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# ============================================================
# SELECT FIRST EXISTING SUBNET
# ============================================================

data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}


# ============================================================
# EXISTING IAM INSTANCE PROFILE
# ============================================================

data "aws_iam_instance_profile" "ec2_s3" {
  name = var.iam_instance_profile
}


# ============================================================
# RANDOM ID FOR UNIQUE S3 BUCKET
# ============================================================

resource "random_id" "bucket_suffix" {
  byte_length = 4
}


# ============================================================
# S3 BUCKET
# ============================================================

resource "aws_s3_bucket" "crm_storage" {
  bucket        = "${var.project_name}-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = merge(var.tags, {
    Name    = "${var.project_name}-s3"
    Service = "Twenty CRM Storage"
  })
}


# ============================================================
# S3 VERSIONING
# ============================================================

resource "aws_s3_bucket_versioning" "crm_storage" {
  bucket = aws_s3_bucket.crm_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}


# ============================================================
# S3 SERVER-SIDE ENCRYPTION
# ============================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "crm_storage" {
  bucket = aws_s3_bucket.crm_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# ============================================================
# S3 BLOCK PUBLIC ACCESS
# ============================================================

resource "aws_s3_bucket_public_access_block" "crm_storage" {
  bucket = aws_s3_bucket.crm_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# ============================================================
# SSH PRIVATE KEY
# ============================================================

resource "tls_private_key" "crm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


# ============================================================
# AWS KEY PAIR
# ============================================================

resource "aws_key_pair" "crm_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.crm_key.public_key_openssh
}


# ============================================================
# SAVE PEM FILE
# ============================================================

resource "local_file" "pem_file" {
  content         = tls_private_key.crm_key.private_key_pem
  filename        = "${path.module}/${var.project_name}.pem"
  file_permission = "0400"
}


# ============================================================
# SECURITY GROUP
# ============================================================

resource "aws_security_group" "crm_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH and app traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = var.app_port
    to_port     = var.app_port
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

  tags = merge(var.tags, {
    Name = "${var.project_name}-sg"
  })
}


# ============================================================
# EC2 INSTANCE
# ============================================================

resource "aws_instance" "crm_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = data.aws_subnet.selected.id

  vpc_security_group_ids = [
    aws_security_group.crm_sg.id
  ]

  associate_public_ip_address = true

  # Existing mentor-provided IAM instance profile.
  # Terraform does NOT create the IAM role or policy.
  iam_instance_profile = data.aws_iam_instance_profile.ec2_s3.name

  # Terraform-generated AWS key pair.
  key_name = aws_key_pair.crm_key.key_name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region   = var.aws_region
    repo_url     = var.repo_url
    repo_branch  = var.repo_branch
    bucket_name  = aws_s3_bucket.crm_storage.bucket
    app_port     = var.app_port
    project_name = var.project_name
  })

  user_data_replace_on_change = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2"
  })

  depends_on = [
    aws_s3_bucket_versioning.crm_storage,
    aws_s3_bucket_server_side_encryption_configuration.crm_storage,
    aws_s3_bucket_public_access_block.crm_storage
  ]
}