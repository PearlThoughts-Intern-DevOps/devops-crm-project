variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "Approved Ubuntu AMI"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 Key Pair name"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into EC2"
  type        = string
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile with S3 access"
  type        = string
}

variable "s3_bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "docker_image" {
  description = "Twenty CRM Docker image"
  type        = string
}
