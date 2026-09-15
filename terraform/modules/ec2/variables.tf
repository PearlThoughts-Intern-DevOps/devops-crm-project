variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}


variable "instance_name" {
  type = string
}

variable "twenty_port" {
  type = number
}

variable "root_volume_size" {
  type = number
}

variable "security_group_id" {
  type = string
}

variable "user_data" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
