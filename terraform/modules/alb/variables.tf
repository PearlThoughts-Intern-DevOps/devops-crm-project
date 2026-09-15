variable "project_name" {
  description = "Project name for naming/tagging"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the target group"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to attach to the ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB (must span 2+ AZs)"
  type        = list(string)
}

variable "app_port" {
  description = "Port on the EC2 that the ALB forwards to"
  type        = number
  default     = 2020
}

variable "instance_id" {
  description = "EC2 instance ID to register with the target group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}