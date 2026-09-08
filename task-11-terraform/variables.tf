variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "twenty-crm"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to access EC2 through SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "crm_allowed_cidr" {
  description = "CIDR block allowed to access Twenty CRM"
  type        = string
  default     = "0.0.0.0/0"
}
