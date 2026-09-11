resource "aws_s3_bucket" "twenty_storage" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-${var.owner}-storage"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
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

    bucket_key_enabled = true
  }
}
