variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment tag (e.g. dev, staging)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Short name used to prefix/tag resources"
  type        = string
  default     = "twenty-crm"
}

# ---------------------------------------------------------------------------
# Networking (existing/default VPC — no new VPC is created)
# ---------------------------------------------------------------------------

variable "use_default_vpc" {
  description = "If true, use the account's default VPC and one of its subnets"
  type        = bool
  default     = true
}

variable "existing_vpc_id" {
  description = "VPC ID to use if use_default_vpc = false. Leave empty to auto-discover the default VPC."
  type        = string
  default     = ""
}

variable "existing_subnet_id" {
  description = "Subnet ID to use if use_default_vpc = false. Leave empty to auto-pick a subnet in the chosen VPC."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# EC2
# ---------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium" # Twenty CRM (server + worker + postgres + redis) needs >1GB RAM
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair to attach for SSH access"
  type        = string
  default     = ""
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to SSH into the instance"
  type        = string
  default     = "0.0.0.0/0" # tighten to your own IP/32 in real use
}

variable "app_port" {
  description = "Port Twenty CRM's front-end serves on"
  type        = number
  default     = 2020
}

variable "root_volume_size" {
  description = "Root EBS volume size (GB)"
  type        = number
  default     = 20
}

# ---------------------------------------------------------------------------
# ECR / Image
# ---------------------------------------------------------------------------

variable "ecr_repository_name" {
  description = "Name of the ECR repository for the Twenty CRM image"
  type        = string
  default     = "twenty-crm"
}

variable "ecr_image_tag" {
  description = "Tag of the image the EC2 instance should pull/run"
  type        = string
  default     = "latest"
}

variable "image_mutability" {
  description = "ECR image tag mutability"
  type        = string
  default     = "MUTABLE"
}

variable "iam_instance_profile_name" {
  description = "Name of an existing IAM instance profile with ECR pull permissions to attach to the EC2 instance (used since this account's IAM users cannot create new roles)"
  type        = string
  default     = "EC2ECRPullRole"
}
variable "ami_id" {
  description = "AMI ID to launch (must be one allowed by the account's EC2 policy)"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}