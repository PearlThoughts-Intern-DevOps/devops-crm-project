variable "aws_region" {
  description = "AWS region for infrastructure provisioning"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name identifier"
  type        = string
  default     = "twenty-crm-mohit"
}

variable "instance_type" {
  description = "EC2 instance type (must be t3.small)"
  type        = string
  default     = "t3.small"

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Only t3.small instance type is permitted."
  }
}

variable "ami_id" {
  description = "Approved AMI ID for EC2 instance"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"

  validation {
    condition     = contains(["ami-081b0a6eac00b4f53", "ami-0b6d9d3d33ba97d99"], var.ami_id)
    error_message = "Only approved AMIs (ami-081b0a6eac00b4f53 or ami-0b6d9d3d33ba97d99) are permitted."
  }
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "mohit-singh"
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile for S3 and ECR access"
  type        = string
  default     = "EC2S3AccessRole"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Twenty CRM storage"
  type        = string
  default     = "mohit-twenty-crm-task13-storage"
}

variable "ecr_repository_name" {
  description = "Name of the Amazon ECR repository"
  type        = string
  default     = "mohit-twenty-crm"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed for ingress traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "docker_image" {
  description = "Docker image for Twenty CRM"
  type        = string
  default     = "twentycrm/twenty-app-dev:latest"
}
