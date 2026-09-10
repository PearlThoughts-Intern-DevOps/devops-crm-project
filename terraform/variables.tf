variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Approved AMI ID for EC2"
  type        = string

  validation {
    condition = contains(
      [
        "ami-081b0a6eac00b4f53",
        "ami-0b6d9d3d33ba97d99"
      ],
      var.ami_id
    )

    error_message = "AMI must be one of the approved AMIs."
  }
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

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "twenty-crm"
}

variable "twenty_port" {
  description = "Twenty CRM application port"
  type        = number
  default     = 2020
}
