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

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "shradha-task11-ec2"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "twenty-crm"
}
