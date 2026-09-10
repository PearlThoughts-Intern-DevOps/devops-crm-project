variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Approved Ubuntu AMI for Task 13"
  type        = string

  validation {
    condition = contains([
      "ami-081b0a6eac00b4f53",
      "ami-0b6d9d3d33ba97d99"
    ], var.ami_id)

    error_message = "AMI must be one of the two approved Task 13 AMIs."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Task 13 requires instance type t3.small."
  }
}

variable "s3_bucket_name" {
  description = "Name of the Terraform-created S3 bucket"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to access SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "image_tag" {
  description = "Twenty CRM Docker image tag"
  type        = string
  default     = "v2.38.1"
}
