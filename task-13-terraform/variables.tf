variable "aws_region" {
  description = "AWS region for Task 13 resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Name of the Twenty CRM EC2 instance"
  type        = string
  default     = "twenty-crm-s3-ec2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Twenty CRM storage"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to access SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "crm_allowed_cidr" {
  description = "CIDR allowed to access Twenty CRM"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}
