variable "aws_region" {
  description = "AWS region for the infrastructure. Task 13 requires us-east-1."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "Task 13 requires aws_region to be exactly us-east-1."
  }
}

variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
  default     = "devops-crm"

  validation {
    condition = (
      length(var.project_name) >= 3 &&
      length(var.project_name) <= 24 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project_name))
    )
    error_message = "Project name must be 3-24 lowercase letters, numbers, or hyphens and cannot start or end with a hyphen."
  }
}

variable "environment" {
  description = "Environment name used in resource names and tags."
  type        = string
  default     = "dev"

  validation {
    condition = (
      length(var.environment) >= 2 &&
      length(var.environment) <= 12 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.environment))
    )
    error_message = "Environment must be 2-12 lowercase letters, numbers, or hyphens and cannot start or end with a hyphen."
  }
}

variable "instance_type" {
  description = "EC2 instance type for Twenty CRM. Task 13 requires t3.small."
  type        = string
  default     = "t3.small"

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "Task 13 requires instance_type to be exactly t3.small."
  }
}

variable "ami_id" {
  description = "Approved x86_64 Linux AMI ID for Task 13 in us-east-1."
  type        = string
  default     = "ami-081b0a6eac00b4f53"

  validation {
    condition = contains([
      "ami-081b0a6eac00b4f53",
      "ami-0b6d9d3d33ba97d99",
    ], var.ami_id)
    error_message = "AMI must be one of the two IDs approved for Task 13."
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
  description = "Host TCP port exposed for Twenty CRM; the container listens on port 3000."
  type        = number
  default     = 3000

  validation {
    condition = (
      var.application_port >= 1024 &&
      var.application_port <= 65535 &&
      floor(var.application_port) == var.application_port
    )
    error_message = "Application port must be a whole number between 1024 and 65535."
  }
}

variable "availability_zone" {
  description = "Availability zone containing the existing default subnet to use."
  type        = string
  default     = "us-east-1a"

  validation {
    condition     = can(regex("^us-east-1[a-f]$", var.availability_zone))
    error_message = "Availability zone must be an availability zone in us-east-1."
  }
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
  description = "Name of an existing EC2 key pair in us-east-1."
  type        = string

  validation {
    condition     = length(trimspace(var.key_name)) > 0
    error_message = "Provide an existing EC2 key pair name."
  }
}

variable "iam_instance_profile_name" {
  description = "Exact name of the existing instance profile that contains EC2S3AccessRole. Terraform does not manage it."
  type        = string

  validation {
    condition     = length(trimspace(var.iam_instance_profile_name)) > 0
    error_message = "Provide the existing instance-profile name containing EC2S3AccessRole."
  }
}

variable "twenty_version" {
  description = "Pinned Twenty CRM release tag used by the server and worker containers."
  type        = string
  default     = "v2.38.1"

  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+$", var.twenty_version))
    error_message = "Twenty version must be a complete release tag such as v2.38.1."
  }
}
