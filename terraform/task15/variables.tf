variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "twenty-crm-task15"
}

variable "ami_id" {
  description = "Approved EC2 AMI ID"
  type        = string
  default     = "ami-081b0a6eac00b4f53"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "app_port" {
  description = "Twenty CRM application port"
  type        = number
  default     = 2020
}

variable "root_volume_size" {
  description = "EC2 root volume size in GB"
  type        = number
  default     = 20
}
