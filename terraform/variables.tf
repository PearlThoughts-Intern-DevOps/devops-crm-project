variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "twenty-crm"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "twenty-crm"
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

variable "iam_instance_profile_name" {
  description = "Existing IAM instance profile used by EC2 to pull images from ECR"
  type        = string
  default     = "EC2ECRPullRole"
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to SSH into EC2"
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_port" {
  description = "Port exposed by Twenty CRM"
  type        = number
  default     = 3000
}

variable "root_volume_size" {
  description = "EC2 root volume size in GB"
  type        = number
  default     = 20
}

variable "ami_id" {
  description = "Amazon Linux AMI ID"
  type        = string
}