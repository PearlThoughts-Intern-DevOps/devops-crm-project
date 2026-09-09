# terraform.tfvars
# actual values for your variables

aws_region         = "us-east-1"
project_name       = "twenty-crm"
environment        = "dev"

# VPC
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
availability_zone  = "us-east-1a"

# EC2
instance_type      = "t3.small"
ami_id             = "ami-0866a3c8686eaeeba"
key_name           = "instance1-key"
root_volume_size   = 20

# ECR
ecr_repo_name         = "twenty-crm"
image_tag_mutability  = "MUTABLE"
