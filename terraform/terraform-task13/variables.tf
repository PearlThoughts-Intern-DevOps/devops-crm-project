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
  description = "Approved Amazon Linux AMI"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "key_name" {
  description = "Existing EC2 key pair"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name for Twenty CRM"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
  default     = "twenty-crm"
}

variable "subnet_id" {
  description = "Existing subnet for Twenty CRM EC2"
  type        = string
}