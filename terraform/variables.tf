variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "twenty-crm"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "ami_id" {
  type    = string
  default = "ami-0b6d9d3d33ba97d99"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "root_volume_size" {
  type    = number
  default = 20
}

variable "key_pair_name" {
  type = string
}

variable "allowed_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "app_port" {
  type    = number
  default = 2020
}