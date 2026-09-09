variable "aws_region" {
  description = "AWS region where the infrastructure will be configured"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "twenty-crm"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "twenty-crm"
}

variable "vpc_id" {
  description = "ID of the existing/default AWS VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID of the existing subnet in the default VPC"
  type        = string
}