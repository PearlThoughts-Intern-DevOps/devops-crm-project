variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Approved AMI for Twenty CRM EC2"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "twenty-crm-task15"
}