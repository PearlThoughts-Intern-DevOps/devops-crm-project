variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  type = string
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

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to access SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_port" {
  description = "Port exposed for Twenty CRM"
  type        = number
  default     = 3000
}

variable "aws_region" {

  type    = string
  default = "us-east-1"

}