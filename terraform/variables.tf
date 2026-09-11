variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "twenty-crm-task12"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID"
  type        = string
  default     = "ami-081b0a6eac00b4f53"
}

variable "app_port" {
  description = "Twenty CRM application port"
  type        = number
  default     = 2020
}

variable "ssh_cidr" {
  description = "CIDR allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}
