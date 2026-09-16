variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI"
  type        = string
  default     = "ami-081b0a6eac00b4f53"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "twenty-crm"
}

variable "owner" {
  description = "Resource owner"
  type        = string
  default     = "netaji"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "task16"
}
