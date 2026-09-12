variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 20
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed for SSH access"
  type        = string
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 2020
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Project name for naming/tagging"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
variable "security_group_name" {
  description = "Override for the Security Group name (defaults to project-environment-sg)"
  type        = string
  default     = null
}