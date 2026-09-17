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
  description = "Approved AMI ID"
  type        = string
  default     = "ami-081b0a6eac00b4f53"
}

variable "s3_bucket_name" {
  description = "S3 Bucket Name (Must be globally unique)"
  type        = string
  default     = "waleed-twenty-crm-s3-13"
}
