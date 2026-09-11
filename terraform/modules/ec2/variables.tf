variable "aws_region" {
  description = "AWS region for the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "Approved Amazon Linux 2023 AMI"
  type        = string

  validation {
    condition = contains(
      [
        "ami-081b0a6eac00b4f53",
        "ami-0b6d9d3d33ba97d99"
      ],
      var.ami_id
    )

    error_message = "AMI must be one of the two approved Task 13 AMIs."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "The instance type must be t3.small."
  }
}

variable "subnet_id" {
  description = "Existing default subnet ID"
  type        = string
}

variable "security_group_id" {
  description = "Existing security group ID"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair"
  type        = string
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile for S3 access"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket used by Twenty CRM"
  type        = string
}
