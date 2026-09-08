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

variable "ecr_repository_name" {
  description = "Name of the Amazon ECR repository"
  type        = string
  default     = "twenty-crm"
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
