output "bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.twenty_crm.id
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.twenty_crm.bucket
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.twenty_crm.arn
}