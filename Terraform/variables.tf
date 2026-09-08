variable "aws_region" {
  description = "AWS region for the Twenty CRM infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "twenty-crm"
}

variable "ec2_ami_id" {
  description = "AMI ID for the Twenty CRM EC2 instance"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ec2_key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "twenty_crm_port" {
  description = "Port used by the Twenty CRM application"
  type        = number
  default     = 2020
}

variable "ecr_repository_name" {
  description = "Amazon ECR repository name"
  type        = string
  default     = "twenty-crm"
}
