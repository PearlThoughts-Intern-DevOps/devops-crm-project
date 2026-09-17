variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ami_id" {
  description = "Approved AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "admin_ip" {
  description = "Public IP allowed to access SSH and Twenty CRM"
  type        = string
}
