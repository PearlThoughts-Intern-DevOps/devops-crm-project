variable "aws_region" {
  description = "AWS region for the deployment"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Approved Ubuntu AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "vpc_id" {
  description = "Existing default VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Existing default subnet ID"
  type        = string
}

variable "instance_profile_name" {
  description = "Existing IAM instance profile for EC2 S3 access"
  type        = string
  default     = "EC2S3AccessRole"
}

variable "project_name" {
  description = "Project name used for resource naming and tags"
  type        = string
  default     = "twenty-crm"
}