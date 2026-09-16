variable "aws_region" {
  description = "AWS region where resources are created"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Approved Ubuntu AMI ID for the EC2 instance"
  type        = string

  validation {
    condition = contains(
      [
        "ami-081b0a6eac00b4f53",
        "ami-0b6d9d3d33ba97d99"
      ],
      var.ami_id
    )
    error_message = "ami_id must be one of the two approved Task 13 AMIs."
  }

  default = "ami-0b6d9d3d33ba97d99"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Task 13 requires instance_type to be t3.small."
  }

  default = "t3.small"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 20
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "twenty-crm-task13"
}

variable "admin_ip" {
  description = "Administrator public IP address allowed to SSH to EC2"
  type        = string
  default     = "49.206.53.207"
}

variable "twenty_port" {
  description = "Twenty CRM HTTP port"
  type        = number
  default     = 2020
}

variable "s3_bucket_prefix" {
  description = "Prefix used to generate the globally unique S3 bucket name"
  type        = string
  default     = "twenty-crm-task13"
}

variable "image_wait_secs" {
  description = "Seconds to wait between Docker image pull attempts"
  type        = number
  default     = 30
}

variable "max_pull_retries" {
  description = "Maximum number of Docker image pull attempts"
  type        = number
  default     = 20
}

