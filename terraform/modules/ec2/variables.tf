variable "ami_id" {
  description = "AMI ID used to launch the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "subnet_id" {
  description = "Subnet in which the EC2 instance is launched."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs attached to the EC2 instance."
  type        = list(string)
}

variable "associate_public_ip_address" {
  description = "Whether the instance receives a public IPv4 address."
  type        = bool
  default     = true
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile attached to EC2."
  type        = string
}

variable "key_name" {
  description = "Name of the existing EC2 key pair."
  type        = string
}

variable "root_volume_size" {
  description = "Size of the encrypted gp3 root volume in GiB."
  type        = number

  validation {
    condition = (
      var.root_volume_size >= 20 &&
      floor(var.root_volume_size) == var.root_volume_size
    )
    error_message = "Root volume size must be a whole number of at least 20 GiB."
  }
}

variable "user_data" {
  description = "Rendered User Data used to configure the EC2 instance."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to the EC2 instance."
  type        = map(string)
  default     = {}
}