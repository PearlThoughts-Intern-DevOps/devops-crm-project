output "bucket_name" {
  description = "Name of the S3 bucket"
  value = aws_s3_bucket.twenty_crm.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value = aws_s3_bucket.twenty_crm.arn
}
