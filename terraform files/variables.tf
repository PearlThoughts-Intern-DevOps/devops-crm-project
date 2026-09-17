variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "Approved AMI id (choose one of the two given in the task)"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair in this region (create one first, see guide)"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH in. Restrict this to your own IP/32 if possible."
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_port" {
  description = "Port Twenty CRM listens on"
  type        = number
  default     = 2020
}

variable "name_prefix" {
  description = "Unique prefix for resource names, to avoid collisions in a shared AWS account (e.g. your name)"
  type        = string
}
