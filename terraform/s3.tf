# ============================================================
# s3.tf — S3 bucket as Twenty CRM storage backend
# Idempotent + Dynamic:
#   - random_id suffix makes bucket name globally unique
#   - prevents BucketAlreadyExists on re-apply
#   - force_destroy ensures clean terraform destroy
# ============================================================

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  bucket_name = "${var.s3_bucket_name}-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket" "twenty_crm_storage" {
  bucket        = local.bucket_name
  force_destroy = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-storage"
  })
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

resource "aws_s3_bucket_public_access_block" "twenty_crm_storage" {
  bucket = aws_s3_bucket.twenty_crm_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
