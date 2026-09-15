# ============================================================
# modules/ec2/variables.tf — Task 15
# ============================================================

variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ami_id" {
  description = "Specific AMI ID as per task requirement"
  type        = string
}

variable "key_pair_name" {
  type = string
}

variable "iam_instance_profile" {
  type    = string
  default = ""
}

variable "user_data" {
  type    = string
  default = ""
}

variable "volume_size" {
  type    = number
  default = 20
}

variable "volume_type" {
  type    = string
  default = "gp3"
}

variable "ingress_rules" {
  description = "Ingress rules for EC2 own SG"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "extra_sg_ids" {
  description = "Extra Security Group IDs to attach — ALB EC2 SG goes here"
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
