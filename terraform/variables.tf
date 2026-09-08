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
  description = "EC2 instance type for the Twenty CRM host (t3.micro was insufficient in manual testing; t3.small recommended)"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB (8 GiB default proved insufficient in manual testing; 20 GiB recommended)"
  type        = number
  default     = 20
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair to attach for SSH access"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the instance (restrict this in production)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_port" {
  description = "Port that the Twenty CRM application listens on"
  type        = number
  default     = 2020
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository for Twenty CRM Docker images"
  type        = string
  default     = "twenty-crm"
}

variable "ecr_image_tag_mutability" {
  description = "Tag mutability setting for the ECR repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Whether to scan images for vulnerabilities automatically on push"
  type        = bool
  default     = true
}
