variable "aws_region" {
  default     = "us-east-1"
}


variable "project_name" {
  default     = "twenty-crm"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  default     = "us-east-1a"
}

variable "ami_id" {
  default = "ami-081b0a6eac00b4f53"
}

variable "instance_type" {
  default     = "t3.small"
}

variable "key_name" {
  default = "abhi-task7"
}

variable "ecr_repository_name" {
  default     = "twenty-crm"
}
