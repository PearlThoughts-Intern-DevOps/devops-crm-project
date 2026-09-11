module "ec2" {
  source = "./modules/ec2"

  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  instance_name          = "crm-app-${var.environment}"

  tags = {
    Environment = var.environment
    Project     = "devops-crm-project"
  }
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name

  tags = {
    Environment = var.environment
    Project     = "devops-crm-project"
  }
}

module "s3" {
  source = "./modules/s3"

  bucket_name = var.s3_bucket_name

  tags = {
    Environment = var.environment
    Project     = "devops-crm-project"
  }
}