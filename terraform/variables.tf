variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
  default     = null
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
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

variable "ami_id" {
  description = "Approved Amazon Linux 2023 AMI"
  type        = string
  default     = "ami-081b0a6eac00b4f53"
}
