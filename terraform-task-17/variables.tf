variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "vpc_id" {
  description = "Default VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Default subnet ID"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "twenty-crm-task-17"
}
variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
}