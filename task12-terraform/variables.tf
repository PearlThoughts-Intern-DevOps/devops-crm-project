variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_id" {
  default = "vpc-0c241509159132524"
}

variable "subnet_id" {
  default = "subnet-078d52bfe579c74f2"
}

variable "ami_id" {
  default = "ami-081b0a6eac00b4f53"
}

variable "instance_type" {
  default = "t3.small"
}

variable "key_name" {
  default = "shradha-task12-new-key"
}

variable "instance_profile" {
  default = "EC2ECRPullRole"
}

variable "ecr_repository" {
  default = "twenty-crm"
}
