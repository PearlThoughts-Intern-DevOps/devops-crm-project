variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Approved EC2 AMI"
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

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Only t3.small is allowed."
  }
}

variable "key_name" {
  description = "Existing EC2 key pair"
  type        = string
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile"
  type        = string
  default     = "EC2S3AccessRole"
}

variable "subnet_id" {
  description = "Existing default subnet"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "twenty-crm"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "twenty-crm"
}