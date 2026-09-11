variable "aws_region" {
  description = "AWS region where the infrastructure will be configured"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "twenty-crm"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "vpc_id" {
  description = "ID of the existing/default AWS VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID of the existing subnet in the default VPC"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket used by Twenty CRM"
  type        = string
}