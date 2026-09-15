# ============================================================
# modules/alb/variables.tf — Task 15
# ============================================================

variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB (min 2 AZs)"
  type        = list(string)
}

variable "instance_id" {
  description = "EC2 instance ID to register in target group"
  type        = string
}

variable "app_port" {
  description = "Port Twenty CRM listens on"
  type        = number
}

variable "alb_sg_id" {
  description = "ALB Security Group ID created in root"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
