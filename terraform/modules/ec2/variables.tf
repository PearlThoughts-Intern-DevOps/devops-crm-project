variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "EC2 AMI ID"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "host_port" {
  description = "Twenty CRM host port"
  type        = number
}

variable "project_name" {
  description = "Project name"
  type        = string
}
