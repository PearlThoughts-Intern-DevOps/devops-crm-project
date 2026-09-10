variable "aws_region" {
  description = "AWS region for the infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
  default     = "devops-crm"
}

variable "environment" {
  description = "Environment name used in resource names and tags."
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type for Twenty CRM."
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "ID of an x86_64 Linux AMI available in the selected AWS region."
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]{17}$", var.ami_id))
    error_message = "Provide an AMI ID with ami- followed by 17 lowercase hexadecimal characters."
  }
}

variable "root_volume_size" {
  description = "Size of the EC2 gp3 root volume in GiB."
  type        = number
  default     = 20

  validation {
    condition = (
      var.root_volume_size >= 20 &&
      floor(var.root_volume_size) == var.root_volume_size
    )
    error_message = "Root volume size must be a whole number of at least 20 GiB."
  }
}

variable "application_port" {
  description = "TCP port exposed for Twenty CRM."
  type        = number
  default     = 2020

  validation {
    condition = (
      var.application_port >= 1 &&
      var.application_port <= 65535 &&
      floor(var.application_port) == var.application_port
    )
    error_message = "Application port must be a whole number between 1 and 65535."
  }
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository for the Twenty CRM container image."
  type        = string
  default     = "twenty-crm"
}

variable "image_tag" {
  description = "ECR image tag that EC2 will pull for Twenty CRM."
  type        = string
  default     = "task12-v1"

  validation {
    condition     = can(regex("^[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}$", var.image_tag))
    error_message = "Provide a valid Docker image tag of 1 to 128 characters."
  }
}

variable "availability_zone" {
  description = "Availability zone containing the default subnet to use."
  type        = string
  default     = "us-east-1a"
}

variable "ssh_allowed_cidr" {
  description = "IPv4 CIDR permitted to connect over SSH, typically your public IP with /32."
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.ssh_allowed_cidr)) &&
      !endswith(var.ssh_allowed_cidr, "/0")
    )
    error_message = "Provide an IPv4 CIDR narrower than /0, preferably your public IP with /32."
  }
}

variable "application_allowed_cidr" {
  description = "IPv4 CIDR permitted to access Twenty CRM."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.application_allowed_cidr))
    error_message = "Provide a valid IPv4 CIDR."
  }
}

variable "key_name" {
  description = "Name of an existing EC2 key pair in the selected AWS region."
  type        = string

  validation {
    condition     = length(trimspace(var.key_name)) > 0
    error_message = "Provide an existing EC2 key pair name."
  }
}
