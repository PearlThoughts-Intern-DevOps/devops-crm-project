variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "Abhi-Task-13"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "task-13"
}

variable "vpc_id" {
  description = "Existing default VPC ID"
  type        = string
  default     = "vpc-0c241509159132524"
}

variable "subnet_id" {
  description = "Existing subnet ID"
  type        = string
  default     = "subnet-078d52bfe579c74f2"
}

variable "ami_id" {
  description = "Approved Amazon Linux 2023 AMI ID"
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
    error_message = "AMI must be one of the two approved AMIs."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Instance type must be t3.small."
  }
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
  default     = "abhi-task7"
}

variable "iam_instance_profile_name" {
  description = "Existing IAM instance profile for S3 access"
  type        = string
  default     = "EC2S3AccessRole"
}

variable "s3_bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "twenty_image" {
  description = "Twenty CRM Docker image"
  type        = string
  default     = "twentycrm/twenty:v2.35.0"
}
