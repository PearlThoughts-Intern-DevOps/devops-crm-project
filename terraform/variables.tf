variable "aws_region" {
  description = "AWS region where resources are created"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 20
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "twenty-crm-task12"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "twenty-crm-task12"
}

variable "admin_ip" {
  description = "Administrator public IP address allowed to SSH to EC2"
  type        = string
  default     = "49.206.53.207"
}

variable "twenty_port" {
  description = "Twenty CRM HTTP port"
  type        = number
  default     = 2020
}

variable "image_tag" {
  description = "Docker image tag stored in ECR"
  type        = string
  default     = "latest"
}

variable "container_name" {
  description = "Docker container name for Twenty CRM"
  type        = string
  default     = "twenty-crm-task12"
}

variable "image_wait_secs" {
  description = "Seconds to wait between ECR image pull attempts"
  type        = number
  default     = 30
}

variable "max_pull_retries" {
  description = "Maximum number of ECR image pull attempts"
  type        = number
  default     = 20
}

