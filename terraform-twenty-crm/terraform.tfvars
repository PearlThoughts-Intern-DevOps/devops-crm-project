# Copy this to terraform.tfvars and fill in your own values.
# terraform.tfvars is gitignored — never commit real credentials or
# personal key pair names alongside secrets.

aws_region    = "us-east-1"
project_name  = "twenty-crm-fathima"
environment   = "dev"

use_default_vpc = true

instance_type    = "t3.small"
key_pair_name    = "twenty-crm-key"
ssh_ingress_cidr = "152.58.217.64/32"

app_port      = 2020
ecr_image_tag = "latest"
