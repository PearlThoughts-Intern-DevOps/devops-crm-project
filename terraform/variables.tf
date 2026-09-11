variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ami_id" {
  description = "Approved Amazon Linux 2023 AMI"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Existing default subnet ID"
  type        = string
}

variable "security_group_id" {
  description = "Existing security group ID"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair"
  type        = string
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile for S3 access"
  type        = string
  default     = "EC2S3AccessRole"
}

variable "s3_bucket_name" {
  description = "Unique S3 bucket name"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "twenty-crm"
}
