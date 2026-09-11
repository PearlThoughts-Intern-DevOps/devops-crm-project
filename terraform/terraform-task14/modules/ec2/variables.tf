variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Existing IAM instance profile"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "ssh_cidr" {
  description = "CIDR allowed to access SSH"
  type        = string
}

variable "crm_cidr" {
  description = "CIDR allowed to access Twenty CRM"
  type        = string
  default     = "0.0.0.0/0"
}