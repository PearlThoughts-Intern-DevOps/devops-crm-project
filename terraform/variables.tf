variable "aws_region" {
  description = "AWS region for infrastructure deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID to deploy resources into (leave null/empty to use default VPC)"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance (leave null to use default subnet)"
  type        = string
  default     = null
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 LTS in us-east-1"
  type        = string
  default     = "ami-0c7217cdde317cfec" 
}

variable "instance_type" {
  description = "EC2 instance type for Twenty CRM"
  type        = string
  default     = "t3.small"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "twenty-crm-server"
}

variable "ecr_repo_name" {
  description = "Name of the Amazon ECR repository for Twenty CRM"
  type        = string
  default     = "twenty-crm-repo"
}