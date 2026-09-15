variable "aws_region" {
  description = "AWS region"
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
        "ami-0b6d9d3d33ba97d99",
        "ami-081b0a6eac00b4f53"
      ],
      var.ami_id
    )

    error_message = "ami_id must be one of the approved AMIs."
  }

  default = "ami-0b6d9d3d33ba97d99"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 20
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "twenty-crm-task15"
}

variable "admin_ip" {
  description = "Administrator public IP address"
  type        = string
  default     = "49.206.53.207"
}

variable "twenty_port" {
  description = "Twenty CRM port"
  type        = number
  default     = 2020
}

