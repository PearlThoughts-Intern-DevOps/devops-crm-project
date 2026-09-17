variable "aws_region" {
  description = "AWS region for Task 17."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "Task 17 requires the us-east-1 region."
  }
}

variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "devops-crm"
}

variable "environment" {
  description = "Environment name used for resource naming."
  type        = string
  default     = "dev"
}

variable "ami_id" {
  description = "Approved Amazon Linux 2023 AMI for Task 17."
  type        = string
  default     = "ami-081b0a6eac00b4f53"

  validation {
    condition = contains([
      "ami-081b0a6eac00b4f53",
      "ami-0b6d9d3d33ba97d99",
    ], var.ami_id)
    error_message = "Use one of the two AMIs approved for Task 17."
  }
}

variable "instance_type" {
  description = "EC2 instance type required for Task 17."
  type        = string
  default     = "t3.small"

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Task 17 requires a t3.small instance."
  }
}

variable "key_name" {
  description = "Name of an existing EC2 key pair in us-east-1."
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Public IPv4 CIDR allowed to connect over SSH."
  type        = string

  validation {
    condition = (
      can(cidrhost(var.ssh_allowed_cidr, 0)) &&
      endswith(var.ssh_allowed_cidr, "/32")
    )
    error_message = "Use your public IPv4 address with /32."
  }
}

variable "ssh_user" {
  description = "Default SSH user for the selected Amazon Linux 2023 AMI."
  type        = string
  default     = "ec2-user"

  validation {
    condition     = var.ssh_user == "ec2-user"
    error_message = "The selected Amazon Linux 2023 AMI uses ec2-user."
  }
}

variable "private_key_path" {
  description = "Local path to the existing private key, used only in the SSH output."
  type        = string
}

variable "application_port" {
  description = "Public TCP port for Twenty CRM."
  type        = number
  default     = 2020

  validation {
    condition     = var.application_port == 2020
    error_message = "Task 17 requires application port 2020."
  }
}

variable "root_volume_size" {
  description = "Encrypted EC2 root volume size in GiB."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size >= 20
    error_message = "Use at least 20 GiB for Twenty CRM."
  }
}