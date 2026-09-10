variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "twenty-crm-s3-instance"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Only t3.small is permitted for Task 13."
  }
}

variable "ami_id" {
  description = "Approved Ubuntu AMI"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"

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

variable "key_name" {
  description = "Existing EC2 Key Pair name"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into EC2"
  type        = string
  default     = "0.0.0.0/0"
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile with S3 access"
  type        = string
  default     = "EC2S3AccessRole"
}

variable "s3_bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "docker_image" {
  description = "Twenty CRM Docker image"
  type        = string
  default     = "twentycrm/twenty-app-dev:v2.35"
}