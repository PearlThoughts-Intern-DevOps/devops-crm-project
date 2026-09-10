# -----------------------------------------------------------------------------
# Data Sources: Existing Default VPC and Subnets
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Resource: S3 Bucket with Versioning, Encryption, and Block Public Access
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "twenty_crm_storage" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name        = var.s3_bucket_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "twenty_crm_storage" {
  bucket = aws_s3_bucket.twenty_crm_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "twenty_crm_storage" {
  bucket = aws_s3_bucket.twenty_crm_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "twenty_crm_storage" {
  bucket = aws_s3_bucket.twenty_crm_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -----------------------------------------------------------------------------
# Resource: Security Group for EC2
# -----------------------------------------------------------------------------
resource "aws_security_group" "twenty_crm" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for Twenty CRM application EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "Twenty CRM Web UI and API (2020)"
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "Twenty CRM Alternate Port (3000)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Resource: EC2 Instance (t3.small with EC2S3AccessRole)
# -----------------------------------------------------------------------------
resource "aws_instance" "twenty_crm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.twenty_crm.id]
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_instance_profile

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/user-data.sh", {
    aws_region     = var.aws_region
    s3_bucket_name = aws_s3_bucket.twenty_crm_storage.bucket
    docker_image   = var.docker_image
  })

  user_data_replace_on_change = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_s3_bucket.twenty_crm_storage,
    aws_s3_bucket_public_access_block.twenty_crm_storage,
    aws_s3_bucket_versioning.twenty_crm_storage,
    aws_s3_bucket_server_side_encryption_configuration.twenty_crm_storage
  ]
}
