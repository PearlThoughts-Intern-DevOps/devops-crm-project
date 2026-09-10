variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "twenty-crm"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
  default     = "bkkrish007-task12"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access SSH"
  type        = string
  default     = "157.51.63.34/32"
}

variable "backend_port" {
  description = "Twenty CRM backend port"
  type        = number
  default     = 2020
}

variable "application_port" {
  description = "Custom CRM application port"
  type        = number
  default     = 3000
}

variable "root_volume_size" {
  description = "EC2 root volume size in GiB"
  type        = number
  default     = 20
}

variable "ecr_repository_name" {
  description = "Amazon ECR repository name"
  type        = string
  default     = "twenty-crm"
}

variable "twenty_api_key" {
  description = "Twenty CRM API key used by the custom application"
  type        = string
  sensitive   = true
}