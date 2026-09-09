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

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "vasundara-task12"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "twenty-crm"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}
