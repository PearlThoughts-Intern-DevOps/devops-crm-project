variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Ubuntu 24.04 AMI ID for EC2"
  type        = string
  default     = "ami-025d99823a4caad37"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "terra-key"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "twenty-crm"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "twenty-crm"
}