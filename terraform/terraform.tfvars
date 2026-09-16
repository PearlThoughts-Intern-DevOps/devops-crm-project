aws_region    = "us-east-1"
project_name  = "twenty-crm"
instance_type = "t3.small"
vpc_id        = "vpc-0c241509159132524"
subnet_id     = "subnet-078d52bfe579c74f2"

ami_id   = "ami-0b6d9d3d33ba97d99"
key_name = "tannu-task-15-key"

ecr_repository_name = "twenty-crm"

alb_subnet_ids = [
  "subnet-078d52bfe579c74f2",
  "subnet-05defbfbcbbf25e7d"
]