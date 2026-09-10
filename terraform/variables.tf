variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
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

variable "ami_id" {
  description = "Approved Amazon Linux AMI"
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

  default = "ami-081b0a6eac00b4f53"
}

variable "iam_role_name" {
  description = "Existing IAM role to attach to EC2"
  type        = string
  default     = "EC2S3AccessRole"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
  default     = "twenty-crm"
}