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
  description = "Approved Ubuntu 24.04 AMI ID"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "Mujtaba-Task-13-Key"
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
  default     = "Mujtaba-Task-13"
}

variable "s3_bucket_prefix" {
  description = "Prefix for the Twenty CRM S3 bucket"
  type        = string
  default     = "mujtaba-task-13-twenty-crm-"
}

variable "iam_instance_profile_name" {
  description = "Existing IAM instance profile for EC2 S3 access"
  type        = string
  default     = "EC2S3AccessRole"
}