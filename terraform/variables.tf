variable "availability_zone" {
  description = "Availability zone for the default subnet"
  type        = string
  default     = "us-east-1a"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "ssh_cidr" {
  description = "IP allowed to SSH"
  type        = string
}