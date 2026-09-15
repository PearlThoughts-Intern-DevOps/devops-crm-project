variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Name of the Twenty CRM EC2 instance"
  type        = string
  default     = "twenty-crm-task15"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to access SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "alb_allowed_cidr" {
  description = "CIDR allowed to access the ALB"
  type        = string
  default     = "0.0.0.0/0"
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile"
  type        = string
  default     = "EC2S3AccessRole"
}
