output "bucket_name" {
  description = "Name of the Twenty CRM S3 bucket"
  value       = aws_s3_bucket.twenty_crm_storage.bucket
}

output "bucket_arn" {
  description = "ARN of the Twenty CRM S3 bucket"
  value       = aws_s3_bucket.twenty_crm_storage.arn
}
