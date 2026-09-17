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

variable "subnet_id" {
  description = "Default VPC subnet ID"
  type        = string
}

variable "vpc_id" {
  description = "Default VPC ID"
  type        = string
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
}
