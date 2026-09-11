output "vpc_id" {
  description = "Default VPC ID used by the deployment"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet selected from the default VPC"
  value       = data.aws_subnets.default_vpc.ids[0]
}

output "ec2_instance_id" {
  description = "ID of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty.id
}

output "ec2_public_ip" {
  description = "Public IP address of the Twenty CRM EC2 instance"
  value       = aws_instance.twenty.public_ip
}

output "ec2_iam_instance_profile" {
  description = "Existing IAM instance profile attached to the EC2 instance"
  value       = data.aws_iam_instance_profile.s3_access.name
}

output "s3_bucket_name" {
  description = "S3 bucket used as Twenty CRM storage backend"
  value       = aws_s3_bucket.twenty_storage.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 storage bucket"
  value       = aws_s3_bucket.twenty_storage.arn
}
