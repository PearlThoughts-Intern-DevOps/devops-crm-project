variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "Approved Ubuntu 24.04 AMI ID"
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

variable "s3_bucket_prefix" {
  description = "Prefix for the Twenty CRM S3 bucket"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Existing IAM instance profile for EC2 S3 access"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
}