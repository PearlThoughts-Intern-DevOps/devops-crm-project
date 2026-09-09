variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "twenty-crm"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "twenty-key"
}
