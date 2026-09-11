variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "Approved AMI ID"
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

    error_message = "AMI must be one of the approved AMIs."
  }
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "s3_bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
}
