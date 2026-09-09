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
  description = "Ubuntu 24.04 AMI ID for EC2"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "Mujtaba-Task-12-Key"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "mujtaba-task-12-twenty-crm"
}

variable "twenty_container_port" {
  description = "Twenty CRM container port"
  type        = number
  default     = 3000
}

variable "host_port" {
  description = "EC2 host port for Twenty CRM"
  type        = number
  default     = 2020
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "Mujtaba-Task-12"
}