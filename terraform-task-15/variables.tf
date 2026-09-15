variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "vpc_id" {
  description = "Default VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet for EC2"
  type        = string
}

variable "subnet_id_2" {
}

variable "instance_profile_name" {
  description = "Existing IAM instance profile"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR allowed for SSH"
  type        = string
}