# variables.tf

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for tagging resources"
  type        = string
  default     = "twenty-crm"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# VPC variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnet"
  type        = string
  default     = "us-east-1a"
}

# EC2 variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance (Ubuntu 22.04 LTS)"
  type        = string
  default     = "ami-0866a3c8686eaeeba"  # Ubuntu 22.04 us-east-1
}

variable "key_name" {
  description = "Name of the existing EC2 key pair"
  type        = string
  default     = "instance1-key"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 20
}

# ECR variables
variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "twenty-crm"
}

variable "image_tag_mutability" {
  description = "Image tag mutability for ECR (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}
