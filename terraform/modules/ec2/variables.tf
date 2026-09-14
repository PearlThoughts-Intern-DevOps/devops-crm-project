variable "project_name" {
  description = "Project name"
  type        = string
}

variable "ami_id" {
  description = "Approved EC2 AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet ID"
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile"
  type        = string
}

variable "app_port" {
  description = "Twenty CRM application port"
  type        = number
}

variable "root_volume_size" {
  description = "EC2 root volume size in GB"
  type        = number
}

variable "user_data" {
  description = "EC2 user data script"
  type        = string
  default     = ""
}
