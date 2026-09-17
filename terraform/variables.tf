variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Only t3.small is allowed."
  }
}

variable "ami_id" {
  description = "Approved AMI ID"
  type        = string
  default     = "ami-081b0a6eac00b4f53"

  validation {
    condition = contains([
      "ami-0b6d9d3d33ba97d99",
      "ami-081b0a6eac00b4f53"
    ], var.ami_id)
    error_message = "AMI must be one of the two approved AMIs."
  }
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "twenty-crm-task17"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed for SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "AWS EC2 key pair name"
  type        = string
}
