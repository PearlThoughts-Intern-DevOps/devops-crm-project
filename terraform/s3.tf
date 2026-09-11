 
# -----------------------------------------------------------------------------
# Amazon S3 - Storage backend for Twenty CRM
#
# Block Public Access enabled, versioning enabled, SSE-S3 encryption.
# force_destroy lets terraform destroy remove the bucket even with objects.
# -----------------------------------------------------------------------------

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "twenty_crm" {
  bucket        = "${var.project_name}-${var.environment}-storage-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-storage"
    Project     = var.project_name
    Environment = var.environment
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
    bucket_key_enabled = true
  }
}