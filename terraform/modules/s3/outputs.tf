output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.crm_storage.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.crm_storage.arn
}
