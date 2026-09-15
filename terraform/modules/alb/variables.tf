variable "name" {
  description = "Name prefix for ALB resources"
  type        = string
  default     = "twenty-crm-mohit"
}

variable "vpc_id" {
  description = "VPC ID where the ALB and Target Group will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB (at least two across different AZs)"
  type        = list(string)
}

variable "app_port" {
  description = "Port on which the application is listening on EC2 instances"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Health check path for Twenty CRM"
  type        = string
  default     = "/"
}

variable "tags" {
  description = "Tags to assign to the resources"
  type        = map(string)
  default     = {}
}
