############################################
# General
############################################

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix used to identify and tag resources"
  type        = string
  default     = "twenty-crm"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional common tags applied to all resources"
  type        = map(string)
  default     = {}
}

############################################
# EC2
############################################

variable "instance_type" {
  description = "EC2 instance type for the Twenty CRM application server"
  type        = string
  default     = "t3.medium"
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair for SSH access (leave empty to launch without one)"
  type        = string
  default     = ""
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the EC2 instance. Restrict this to your IP in production."
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_port" {
  description = "Port the Twenty CRM application listens on"
  type        = number
  default     = 3000
}

variable "root_volume_size" {
  description = "Size (in GB) of the EC2 instance's root EBS volume"
  type        = number
  default     = 30
}

############################################
# ECR
############################################

variable "ecr_repository_name" {
  description = "Name of the ECR repository that stores the Twenty CRM container image"
  type        = string
  default     = "twenty-crm"
}

variable "ecr_image_tag_mutability" {
  description = "Tag mutability setting for the ECR repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.ecr_image_tag_mutability)
    error_message = "ecr_image_tag_mutability must be either \"MUTABLE\" or \"IMMUTABLE\"."
  }
}

variable "ecr_scan_on_push" {
  description = "Whether ECR should automatically scan images for vulnerabilities on push"
  type        = bool
  default     = true
}

variable "ecr_untagged_expiry_days" {
  description = "Number of days after which untagged ECR images are automatically expired"
  type        = number
  default     = 14
}
