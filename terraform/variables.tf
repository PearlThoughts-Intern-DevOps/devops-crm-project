variable "aws_region" {
  description = "AWS region for the Terraform deployment"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
  default     = null
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for resource naming and tags"
  type        = string
  default     = "twenty-crm"
}

variable "owner" {
  description = "Owner tag used to identify resources"
  type        = string
  default     = "netaji"
}

variable "ami_id" {
  description = "Mentor-approved Amazon Linux 2023 AMI for us-east-1"
  type        = string
  default     = "ami-081b0a6eac00b4f53"
}

variable "iam_instance_profile_name" {
  description = "Pre-existing IAM instance profile granting EC2 access to S3"
  type        = string
  default     = "EC2S3AccessRole"
}

variable "s3_bucket_name" {
  description = "Globally unique S3 bucket name for Twenty CRM storage"
  type        = string
  default     = "netaji-twenty-crm-storage-2026"
}
