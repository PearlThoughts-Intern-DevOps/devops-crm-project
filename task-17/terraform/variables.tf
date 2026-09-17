variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance (Ubuntu 26.04 resolute: ami-0b6d9d3d33ba97d99)"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "project_name" {
  description = "Project name prefix for resources and tags"
  type        = string
  default     = "mohit-twenty-crm-task17"
}

variable "key_name" {
  description = "Name of the AWS EC2 Key Pair"
  type        = string
  default     = "mohit-task17-key"
}

variable "public_key_path" {
  description = "Local path to the SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "app_port" {
  description = "Twenty CRM application listening port"
  type        = number
  default     = 2020
}

variable "environment" {
  description = "Environment identifier"
  type        = string
  default     = "dev"
}
