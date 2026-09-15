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
  description = "Approved Ubuntu AMI"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "app_port" {
  description = "Twenty CRM application port"
  type        = number
  default     = 2020
}

variable "alb_port" {
  description = "ALB HTTP port"
  type        = number
  default     = 80
}
