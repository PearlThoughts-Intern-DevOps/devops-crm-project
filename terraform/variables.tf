variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
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
    error_message = "ami_id must be one of the approved Task 14 AMIs."
  }

  default = "ami-0b6d9d3d33ba97d99"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "instance_type must be t3.small."
  }

  default = "t3.small"
}

variable "root_volume_size" {
  description = "EC2 root volume size in GiB"
  type        = number
  default     = 20
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "twenty-crm-task14"
}

variable "admin_ip" {
  description = "Administrator public IP address"
  type        = string
  default     = "49.206.53.207"
}

variable "twenty_port" {
  description = "Twenty CRM application port"
  type        = number
  default     = 2020
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile to attach to EC2"
  type        = string
  default     = "EC2S3AccessRole"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "twenty-crm-task14"
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "twenty-crm-task14-storage"
}

