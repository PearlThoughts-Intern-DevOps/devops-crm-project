variable "project_name" {
  description = "Project name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID used for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  type = string
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

variable "application_port" {
  description = "Port used by the Twenty CRM application"
  type        = number
}

variable "ecr_repository_url" {
  type = string
}
variable "iam_instance_profile" {
  type = string
}

variable "aws_region" {
  description = "AWS region used by EC2 and ECR"
  type        = string
}

variable "docker_image_tag" {
  description = "Docker image tag to pull from ECR"
  type        = string
  default     = "latest"
}
