variable "instance_name" {
  description = "Name of the Twenty CRM EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to access SSH"
  type        = string
}

variable "crm_allowed_cidr" {
  description = "CIDR allowed to access Twenty CRM"
  type        = string
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile attached to EC2"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL used by the EC2 instance"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket used by Twenty CRM"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}
