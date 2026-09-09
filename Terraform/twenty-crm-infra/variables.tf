variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix used to identify and tag all resources"
  type        = string
  default     = "twenty-crm"
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

# ---------------------------------------------------------------------------
# EC2
# ---------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type for the Twenty CRM host"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair to allow SSH access to the instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance. Leave empty to auto-select the latest Ubuntu 22.04 LTS AMI"
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 20
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the instance (restrict this to your own IP in real use)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_port" {
  description = "Port on which the Twenty CRM application is exposed"
  type        = number
  default     = 3000
}

# ---------------------------------------------------------------------------
# ECR
# ---------------------------------------------------------------------------

variable "ecr_repository_name" {
  description = "Name of the ECR repository that will store the Twenty CRM image"
  type        = string
  default     = "twenty-crm"
}

variable "ecr_image_tag_mutability" {
  description = "Image tag mutability setting for the ECR repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Whether images should be scanned for vulnerabilities automatically on push"
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Tagging
# ---------------------------------------------------------------------------

variable "tags" {
  description = "Common tags applied to every resource"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}
