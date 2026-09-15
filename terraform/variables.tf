# ============================================================
# variables.tf — Task 15
# ============================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner name for tagging"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "Specific AMI ID as per task requirement"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "key_pair_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "app_port" {
  description = "Port Twenty CRM listens on inside container"
  type        = number
  default     = 2020
}

variable "volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 20
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "twenty_image" {
  description = "Twenty CRM Docker image"
  type        = string
  default     = "twentycrm/twenty:v2.35.0"
}

variable "encryption_key" {
  description = "Twenty CRM encryption key"
  type        = string
  sensitive   = true
}

variable "app_secret" {
  description = "Twenty CRM app secret"
  type        = string
  sensitive   = true
}

variable "pg_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
  default     = ""
}
