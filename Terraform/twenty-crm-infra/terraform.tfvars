# Copy this file to terraform.tfvars and fill in your own values.
# terraform.tfvars is gitignored so you never commit personal/account values.

aws_region           = "us-east-1"
project_name         = "twenty-crm"
environment          = "dev"
instance_type        = "t3.medium"
key_pair_name        = "vikashtask11"
allowed_ssh_cidr     = "34.207.252.232/32"
app_port             = 3000
root_volume_size     = 20
ecr_repository_name  = "twenty-crm"
ami_id               = "ami-0fc339630ba87993b"

tags = {
  ManagedBy = "Terraform"
  Project   = "twenty-crm"
  Owner     = "vikash-yadav"
}
