variable "ami_id" {
  description = "AMI ID for the EC2 instance"
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

variable "iam_instance_profile" {
  description = "Existing IAM instance profile to attach to EC2"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "admin_ip" {
  description = "Administrator IP address in CIDR notation"
  type        = string
}

variable "twenty_port" {
  description = "Twenty CRM application port"
  type        = number
  default     = 2020
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 20
}

variable "user_data" {
  description = "EC2 user data script"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to EC2 resources"
  type        = map(string)
  default     = {}
}

