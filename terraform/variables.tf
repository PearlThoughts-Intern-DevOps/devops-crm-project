variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for naming and tagging resources"
  type        = string
  default     = "twenty-crm"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type for the Twenty CRM host"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 20
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair to attach for SSH access"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the instance"
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_port" {
  description = "Port that the Twenty CRM application listens on"
  type        = number
  default     = 2020
}

variable "iam_instance_profile" {
  description = "Existing EC2 IAM instance profile (EC2S3AccessRole) with S3 access"
  type        = string
}