variable "ami_id" {
  description = "Approved EC2 AMI"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet"
  type        = string
}

variable "security_group_id" {
  description = "Existing security group"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair"
  type        = string
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "s3_bucket_name" {
  description = "Terraform-created S3 bucket"
  type        = string
}

variable "twenty_port" {
  description = "Twenty CRM port"
  type        = number
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}
