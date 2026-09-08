variable "aws_region" {
  description = "AWS region where resources will be managed"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "twenty-crm"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ecr_repository_name" {
  description = "Amazon ECR repository name"
  type        = string
  default     = "twenty-crm"
}
