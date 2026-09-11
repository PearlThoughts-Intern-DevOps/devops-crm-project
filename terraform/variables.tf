# ============================================================
# variables.tf — All input variables for Task 13
# ============================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix — unique per student"
  type        = string
  default     = "shubham-singh-twenty-crm"
}

variable "ami_id" {
  description = "Approved AMI ID — Ubuntu based"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "instance_type" {
  description = "EC2 instance type — must be t3.small"
  type        = string
  default     = "t3.small"
}

variable "key_pair_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "shubhamsingh-task07"
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed for SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  description = "Port Twenty CRM runs on inside Docker"
  type        = number
  default     = 2020
}

variable "s3_bucket_name" {
  description = "Base name for S3 bucket — random suffix added automatically"
  type        = string
  default     = "shubham-singh-twenty-crm-storage"
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "twenty-crm"
    Environment = "dev"
    ManagedBy   = "terraform"
    Owner       = "shubham-singh"
    Task        = "task-13"
  }
}

variable "twenty_image" {
  description = "Twenty CRM Docker image to deploy"
  type        = string
  default     = "twentycrm/twenty:v2.35.0"
}

variable "pg_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
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

