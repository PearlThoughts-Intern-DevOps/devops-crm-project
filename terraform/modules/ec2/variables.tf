variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Existing IAM instance profile name"
  type        = string
}

variable "user_data" {
  description = "EC2 user data script"
  type        = string
}

variable "eip_allocation_id" {
  description = "Allocation ID of the Elastic IP to associate with this instance"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming and tags"
  type        = string
}

variable "owner" {
  description = "Owner tag"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
