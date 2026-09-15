# ============================================================
# variables.tf — Root module variables
# ============================================================

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name — used in all resource names and tags"
  type        = string
  default     = "shubham-singh-twenty-crm"
}

variable "environment" {
  description = "Environment tag (dev / staging / prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner tag for resource identification"
  type        = string
  default     = "shubham-singh"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_pair_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  description = "Port Twenty CRM application listens on"
  type        = number
  default     = 2020
}

variable "volume_size" {
  description = "EC2 root EBS volume size in GB"
  type        = number
  default     = 20
}

variable "twenty_image" {
  description = "Twenty CRM Docker image tag to deploy"
  type        = string
  default     = "twentycrm/twenty:v2.35.0"
}

variable "iam_instance_profile_name" {
  description = "Existing IAM instance profile name to attach to EC2"
  type        = string
  default     = "EC2S3AccessRole"
}

variable "s3_force_destroy" {
  description = "Allow terraform destroy to delete S3 bucket even if it has files"
  type        = bool
  default     = true
}

# ── Sensitive — pass via: export TF_VAR_pg_password=xxx ──────────────────────
variable "pg_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}

variable "encryption_key" {
  description = "Twenty CRM server encryption key (min 32 chars)"
  type        = string
  sensitive   = true
}

variable "app_secret" {
  description = "Twenty CRM application secret"
  type        = string
  sensitive   = true
}
