variable "ami_id" {
  description = "Approved EC2 AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for EC2"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
}

variable "app_port" {
  description = "Twenty CRM application port"
  type        = number
}

variable "twenty_image" {
  description = "Twenty CRM Docker image"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket used by Twenty CRM"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "task" {
  description = "Task name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
