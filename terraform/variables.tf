variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "Approved Ubuntu 24.04 AMI ID"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "host_port" {
  description = "EC2 host port"
  type        = number
}

variable "project_name" {
  description = "Project name"
  type        = string
}