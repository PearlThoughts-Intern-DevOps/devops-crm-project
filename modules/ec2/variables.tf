variable "name" {
  description = "Name for the EC2 instance and its security group"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to launch"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID the instance and security group are placed in"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID the instance is placed in"
  type        = string
}

variable "iam_instance_profile" {
  description = "Name of an EXISTING IAM instance profile to attach (this module never creates IAM resources)"
  type        = string
  default     = null
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair for SSH access"
  type        = string
  default     = null
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to SSH into the instance"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ingress_ports" {
  description = "List of additional TCP ports to open to the world (besides SSH)"
  type        = list(number)
  default     = []
}

variable "user_data" {
  description = "Rendered user_data script to run on first boot"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the instance and security group"
  type        = map(string)
  default     = {}
}
