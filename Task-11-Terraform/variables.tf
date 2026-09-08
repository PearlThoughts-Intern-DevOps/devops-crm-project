variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
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

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "twenty-crm"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access the EC2 instance through SSH"
  type        = string
  default     = "0.0.0.0/0"
}
