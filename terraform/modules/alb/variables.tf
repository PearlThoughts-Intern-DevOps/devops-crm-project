variable "name_prefix" {
  description = "Prefix used when naming ALB resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC containing the ALB and target."
  type        = string
}

variable "subnet_ids" {
  description = "Default-VPC subnet IDs used by the ALB."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "An Application Load Balancer requires at least two subnets."
  }
}

variable "security_group_ids" {
  description = "Security group IDs attached to the ALB."
  type        = list(string)
}

variable "target_port" {
  description = "Port on which Twenty CRM listens on the EC2 instance."
  type        = number

  validation {
    condition     = var.target_port >= 1 && var.target_port <= 65535
    error_message = "The target port must be between 1 and 65535."
  }
}

variable "target_id" {
  description = "ID of the EC2 instance registered with the target group."
  type        = string
}

variable "health_check_path" {
  description = "HTTP path used to check Twenty CRM health."
  type        = string
  default     = "/healthz"
}

variable "tags" {
  description = "Tags applied to ALB resources."
  type        = map(string)
  default     = {}
}