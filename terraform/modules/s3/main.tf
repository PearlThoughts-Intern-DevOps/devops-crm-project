# ============================================================
# S3 BUCKET
# ============================================================

resource "aws_s3_bucket" "twenty_crm" {

  bucket = var.bucket_name

  tags = {

    Name = "Twenty CRM Storage"

    Project = var.project_name

    Environment = var.environment

    ManagedBy = "Terraform"
  }
}


# ============================================================
# BLOCK PUBLIC ACCESS
# ============================================================

resource "aws_s3_bucket_public_access_block" "twenty_crm" {

  bucket = aws_s3_bucket.twenty_crm.id

  block_public_acls = true

  block_public_policy = true

  ignore_public_acls = true

  restrict_public_buckets = true
}


# ============================================================
# VERSIONING
# ============================================================

resource "aws_s3_bucket_versioning" "twenty_crm" {

  bucket = aws_s3_bucket.twenty_crm.id

  versioning_configuration {

    status = "Enabled"
  }
}


# ============================================================
# SERVER-SIDE ENCRYPTION
# ============================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "twenty_crm" {

  bucket = aws_s3_bucket.twenty_crm.id

  rule {

    apply_server_side_encryption_by_default {

      sse_algorithm = "AES256"
    }
  }
}
