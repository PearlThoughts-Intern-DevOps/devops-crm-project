variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "EC2 AMI ID"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "twenty_container_port" {
  description = "Twenty CRM container port"
  type        = number
}

variable "host_port" {
  description = "EC2 host port"
  type        = number
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Existing IAM instance profile"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name used by Twenty CRM"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL for Twenty CRM image"
  type        = string
}