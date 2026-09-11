variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Approved Amazon Linux 2023 AMI"
  type        = string
  default     = "ami-081b0a6eac00b4f53"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "TwentyCRM-Task13"
}

variable "root_volume_size" {
  description = "EC2 root volume size in GiB"
  type        = number
  default     = 20
}

variable "s3_bucket_name" {
  description = "Unique S3 bucket name for Twenty CRM"
  type        = string
  default     = "twenty-crm-task13-579138738751"
}

variable "container_port" {
  description = "Twenty CRM port"
  type        = number
  default     = 3000
}
