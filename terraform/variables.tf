variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "twenty-crm-task13"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Task 13 requires t3.small only."
  }
}

variable "ami_id" {
  description = "Approved EC2 AMI"
  type        = string
  default     = "ami-081b0a6eac00b4f53"

  validation {
    condition = contains([
      "ami-081b0a6eac00b4f53",
      "ami-0b6d9d3d33ba97d99"
    ], var.ami_id)

    error_message = "AMI must be one of the Task 13 approved AMIs."
  }
}

variable "app_port" {
  description = "Twenty CRM application port"
  type        = number
  default     = 2020
}

variable "ssh_cidr" {
  description = "CIDR allowed for SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "s3_instance_profile" {
  description = "Existing IAM instance profile associated with EC2S3AccessRole"
  type        = string
}
