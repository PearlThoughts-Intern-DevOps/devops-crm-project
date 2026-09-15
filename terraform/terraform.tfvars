# ============================================================
# terraform.tfvars — Task 15
# ============================================================

aws_region                = "us-east-1"
project_name              = "shubham-singh-task15"
environment               = "dev"
owner                     = "shubham-singh"
instance_type             = "t3.small"
ami_id                    = "ami-0b6d9d3d33ba97d99"
key_pair_name             = "shubhamsingh-task15"
allowed_ssh_cidrs         = ["0.0.0.0/0"]
app_port                  = 2020
volume_size               = 20
twenty_image              = "twentycrm/twenty:v2.35.0"
encryption_key            = "d57f323fcca1e87085dd6f9752c97889"
app_secret                = "eacb98863114f57be53e0b99065bfe50379418af3789f660ed1b711017c2ab81"
pg_password               = "8wdFuJOIUzaH1CcEplbk"
