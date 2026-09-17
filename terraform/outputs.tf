output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.twenty_crm.public_ip
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.twenty_crm.bucket
}
