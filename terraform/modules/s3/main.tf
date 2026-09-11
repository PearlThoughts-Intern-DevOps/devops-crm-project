resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "crm_storage" {
  bucket        = "${var.project_name}-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = merge(var.tags, {
    Name    = "${var.project_name}-s3"
    Service = "Twenty CRM Storage"
  })
}

resource "aws_s3_bucket_versioning" "crm_storage" {
  bucket = aws_s3_bucket.crm_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "crm_storage" {
  bucket = aws_s3_bucket.crm_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "crm_storage" {
  bucket = aws_s3_bucket.crm_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
