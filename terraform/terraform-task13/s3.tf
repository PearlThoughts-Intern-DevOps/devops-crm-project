resource "aws_s3_bucket" "twenty_crm" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name        = var.bucket_name
    Project     = var.project_name
    Environment = "production"
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