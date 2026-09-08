variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "twenty"
}

variable "ec2_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "twenty-crm"
}