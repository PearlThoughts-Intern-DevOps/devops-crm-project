variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "abhi-task-16"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "task-16"
}

variable "vpc_id" {
  description = "Existing default VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "Approved Amazon Linux 2023 AMI ID"
  type        = string

  validation {
    condition = contains(
      [
        "ami-081b0a6eac00b4f53",
        "ami-0b6d9d3d33ba97d99"
      ],
      var.ami_id
    )

    error_message = "AMI must be one of the two approved AMIs."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Instance type must be t3.small."
  }
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "twenty_image" {
  description = "Twenty CRM Docker image"
  type        = string
  default     = "twentycrm/twenty:v2.35.0"
}
