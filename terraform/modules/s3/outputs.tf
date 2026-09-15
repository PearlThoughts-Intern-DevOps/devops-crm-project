# ============================================================
# modules/s3/outputs.tf
# ============================================================

output "bucket_name" {
  description = "Actual S3 bucket name including random suffix"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.this.arn
}

output "bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.this.id
}

output "bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
