variable "aws_region" {
  description = "AWS region for provisioning resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name identifier for resource naming and tagging"
  type        = string
  default     = "twenty-crm-mohit"
}

variable "instance_type" {
  description = "EC2 instance type for running Twenty CRM"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "mohit-singh"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed for inbound SSH and HTTP/App traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ecr_repository_name" {
  description = "Name of the Amazon ECR repository"
  type        = string
  default     = "mohit-twenty-crm"
}

variable "docker_image_tag" {
  description = "Docker image tag to pull and run on EC2"
  type        = string
  default     = "latest"
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile name for EC2 to pull from ECR"
  type        = string
  default     = "EC2ECRPullRole"
}

variable "app_port" {
  description = "Host port exposed for Twenty CRM application access"
  type        = number
  default     = 2020
}

variable "ami_id" {
  description = "Custom AMI ID for EC2 instance (optional, defaults to latest Amazon Linux 2023)"
  type        = string
  default     = ""
}
