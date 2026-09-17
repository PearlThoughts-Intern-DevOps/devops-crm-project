variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "abhi-task-17"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "task-17"
}

variable "vpc_id" {
  description = "Existing default VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Existing default VPC subnet ID"
  type        = string
}

variable "ami_id" {
  description = "Approved Amazon Linux 2023 AMI"
  type        = string

  validation {
    condition = contains(
      [
        "ami-0b6d9d3d33ba97d99",
        "ami-081b0a6eac00b4f53"
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
  description = "Existing EC2 key pair"
  type        = string
}
