variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "devops-crm-project"
}

variable "task" {
  description = "Task name"
  type        = string
  default     = "Task-16"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "test"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Only t3.small is allowed."
  }
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "twenty-crm-server"
}

variable "ami_id" {
  description = "Approved AMI ID"
  type        = string
  default     = "ami-081b0a6eac00b4f53"

  validation {
    condition = contains([
      "ami-081b0a6eac00b4f53",
      "ami-0b6d9d3d33ba97d99"
    ], var.ami_id)
    error_message = "AMI must be one of the two approved AMIs."
  }
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
  default     = "kaushal-task16-key"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_port" {
  description = "Twenty CRM application port"
  type        = number
  default     = 2020
}

variable "twenty_image" {
  description = "Twenty CRM Docker image"
  type        = string
  default     = "twentycrm/twenty-app-dev:v2.35"
}
