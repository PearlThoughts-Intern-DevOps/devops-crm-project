variable "name" {
  description = "Name identifier for the EC2 instance and security group"
  type        = string
  default     = "twenty-crm"
}

variable "ami_id" {
  description = "Approved AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be deployed"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM instance profile to attach to the EC2 instance"
  type        = string
  default     = null
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed for ingress traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "security_group_name" {
  description = "Custom name for the security group. Defaults to var.name-sg if not set."
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance in a VPC"
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Size of the root block device volume in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of the root block device volume"
  type        = string
  default     = "gp3"
}

variable "user_data" {
  description = "User data script to bootstrap the instance"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
