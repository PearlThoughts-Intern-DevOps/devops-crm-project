variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "twenty-crm"
}

variable "instance_type" {
  default = "t3.small"
}

variable "ecr_repository_name" {
  default = "twenty-crm"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "IP allowed to SSH"
  type        = string
}

variable "app_port" {
  default = 3000
}

variable "image_tag" {
  default = "latest"
}

variable "container_name" {
  default = "twenty-crm"
}
