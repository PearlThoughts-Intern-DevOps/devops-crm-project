variable "aws_region" {
  description = "AWS region for the deployment"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type (task requires t3.small)"
  type        = string
  default     = "t3.small"

  validation {
    condition     = var.instance_type == "t3.small"
    error_message = "This task requires t3.small."
  }
}

variable "ami_id" {
  description = "AMI ID -- must be one of the two approved AMIs"
  type        = string
  default     = "ami-081b0a6eac00b4f53"

  validation {
    condition = contains([
      "ami-0b6d9d3d33ba97d99",
      "ami-081b0a6eac00b4f53",
    ], var.ami_id)
    error_message = "ami_id must be ami-0b6d9d3d33ba97d99 or ami-081b0a6eac00b4f53."
  }
}

variable "key_name" {
  description = "Existing EC2 key pair name used for the Ansible SSH connection"
  type        = string
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to reach SSH and the app port. Set this to your own IP (x.x.x.x/32) rather than leaving it open to the world."
  type        = string
}

variable "app_port" {
  description = "Port Twenty CRM listens on"
  type        = number
  default     = 3000
}

variable "project_name" {
  description = "Project name used for naming and tags"
  type        = string
  default     = "twenty-crm"
}

variable "owner" {
  description = "Owner tag, identifies whose resources these are in the shared account"
  type        = string
  default     = "netaji"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
