variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "Approved EC2 AMI ID"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to access SSH"
  type        = string
}

variable "backend_port" {
  description = "Twenty CRM backend port"
  type        = number
}

variable "root_volume_size" {
  description = "EC2 root volume size in GiB"
  type        = number
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile for EC2"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
}
