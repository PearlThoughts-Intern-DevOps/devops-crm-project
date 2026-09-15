variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance (Ubuntu, per task allow-list)"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access (optional). Leave blank to skip SSH access."
  type        = string
  default     = ""
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form, allowed to SSH into the instance. e.g. 1.2.3.4/32"
  type        = string
  default     = "0.0.0.0/0"
}

variable "twenty_app_port" {
  description = "Port Twenty CRM listens on inside the instance"
  type        = number
  default     = 3000
}

variable "project_name" {
  description = "Prefix used to name/tag all resources"
  type        = string
  default     = "twenty-crm-task15"
}