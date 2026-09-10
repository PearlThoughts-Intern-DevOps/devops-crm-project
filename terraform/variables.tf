variable "aws_region" {
  description = "AWS region for Task 13"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Approved Amazon Linux 2023 AMI"
  type        = string
  default     = "ami-081b0a6eac00b4f53"

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
  default     = "t3.small"

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Task 13 requires instance type t3.small."
  }
}

variable "subnet_id" {
  description = "Existing default subnet"
  type        = string
  default     = "subnet-078d52bfe579c74f2"
}

variable "security_group_id" {
  description = "Existing security group for Twenty CRM"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair"
  type        = string
  default     = "vasundara-task12"
}

variable "s3_bucket_name" {
  description = "Unique S3 bucket name for Twenty CRM storage"
  type        = string
}
