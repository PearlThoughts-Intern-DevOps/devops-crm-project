variable "project_name" {
  description = "Project name"
  type        = string
}

variable "alb_name" {
  description = "Application Load Balancer name"
  type        = string
}

variable "target_group_name" {
  description = "Target group name"
  type        = string
}

variable "host_port" {
  description = "EC2 host port"
  type        = number
}

variable "ec2_instance_id" {
  description = "EC2 instance ID to register with the target group"
  type        = string
}