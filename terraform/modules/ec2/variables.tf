variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ami_id" {
  description = "EC2 AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}


variable "repo_url" {
  description = "CRM repository URL"
  type        = string
}

variable "repo_branch" {
  description = "Git branch to deploy"
  type        = string
}

variable "app_port" {
  description = "Twenty CRM application port"
  type        = number
}


variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "tags" {
  description = "Tags for EC2 resources"
  type        = map(string)
}

variable "alb_security_group_id" {
  description = "Security group ID of the Application Load Balancer"
  type        = string
}
