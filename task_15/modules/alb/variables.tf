variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the target group"
  type        = string
}

variable "alb_subnet_ids" {
  description = "Subnet IDs for the Application Load Balancer"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "ec2_instance_id" {
  description = "EC2 instance ID registered with the target group"
  type        = string
}
