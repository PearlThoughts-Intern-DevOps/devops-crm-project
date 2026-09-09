variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project/prefix name for resources"
  type        = string
  default     = "twenty-crm-harish"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
  default     = "twenty-crm-harish"
}

variable "app_port" {
  description = "Port Twenty CRM listens on"
  type        = number
  default     = 2020
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to SSH"
  type        = string
  default     = "0.0.0.0/0"
}
