variable "aws_region" {
  description = "AWS region for the deployment"
  type        = string
}

variable "ami_id" {
  description = "Approved Ubuntu AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet ID"
  type        = string
}

variable "instance_profile_name" {
  description = "Existing IAM instance profile for EC2"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR allowed for SSH access"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
}