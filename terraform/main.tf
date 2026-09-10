# ============================================================
# S3 Bucket
# ============================================================

resource "aws_s3_bucket" "twenty_storage" {
  bucket = var.bucket_name

  tags = {
    Name        = "${var.project_name}-storage"
    Project     = var.project_name
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "twenty_storage" {
  bucket = aws_s3_bucket.twenty_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "twenty_storage" {
  bucket = aws_s3_bucket.twenty_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "twenty_storage" {
  bucket = aws_s3_bucket.twenty_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ============================================================
# EC2 Instance
# ============================================================


resource "aws_security_group" "twenty" {
  name        = "${var.project_name}-sg"
  description = "Security group for Twenty CRM"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Twenty CRM"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name      = "${var.project_name}-sg"
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

resource "aws_instance" "twenty" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[0]

  key_name = var.key_name

  iam_instance_profile = var.iam_role_name

  vpc_security_group_ids = [
    aws_security_group.twenty.id
  ]

  user_data = templatefile("${path.module}/user_data.sh", {
    s3_bucket  = aws_s3_bucket.twenty_storage.bucket
    aws_region = var.aws_region
  })

  user_data_replace_on_change = true

  tags = {
    Name        = "${var.project_name}-server"
    Project     = var.project_name
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}