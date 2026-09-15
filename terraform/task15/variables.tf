variable "aws_region" {
  description = "AWS region for Task 15"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Approved Ubuntu AMI ID"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Task 15 requires a t3.small instance."
  }
}

variable "twenty_version" {
  description = "Twenty CRM Docker image version"
  type        = string
  default     = "v2.38.1"
}

variable "key_name" {
  description = "Name of the Terraform-generated EC2 key pair"
  type        = string
  default     = "task15-prabhas-key"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH into EC2"
  type        = string
}
