variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "twenty-crm-harish"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type (Free Tier eligible)"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "AMI ID for EC2 (Amazon Linux 2023 Free Tier)"
  type        = string
  default     = "ami-0354c98ae10b02961"  
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 3000
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
  default     = "twenty-crm-harish"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "twenty-crm"
  }
}