variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "twenty-crm"
}

variable "vpc_id" {
  description = "Existing default VPC ID"
  type        = string
  default     = "vpc-0c241509159132524"
}

variable "subnet_id" {
  description = "Existing public subnet ID"
  type        = string
  default     = "subnet-078d52bfe579c74f2"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID"
  type        = string
  default     = "ami-081b0a6eac00b4f53"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "abhi-task7"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "twenty-crm"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}
