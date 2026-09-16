variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the Application Load Balancer"
  type        = list(string)
}

variable "instance_id" {
  description = "EC2 instance ID to register with the target group"
  type        = string
}

variable "app_port" {
  description = "Twenty CRM application port"
  type        = number
}

variable "tags" {
  description = "Tags for ALB resources"
  type        = map(string)
}
