variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 20
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "twenty-crm"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "twenty-crm-task11"
}

