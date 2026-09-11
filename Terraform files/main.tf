module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  scan_on_push    = true

  tags = {
    Project   = var.project_name
    Owner     = var.owner
    ManagedBy = "terraform"
  }
}

module "s3" {
  source = "./modules/s3"

  bucket_name         = var.s3_bucket_name
  enable_versioning   = true
  sse_algorithm       = "AES256"
  block_public_access = true

  tags = {
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "terraform"
    Environment = "task14"
  }
}

module "ec2" {
  source = "./modules/ec2"

  name                 = "${var.project_name}-ec2"
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  vpc_id               = data.aws_vpc.default.id
  subnet_id            = data.aws_subnet.selected.id
  iam_instance_profile = var.existing_iam_role_name
  key_pair_name        = var.key_pair_name
  ssh_ingress_cidr     = var.ssh_ingress_cidr
  ingress_ports        = [2020, 3000]

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    github_repo_url    = var.github_repo_url
    github_branch      = var.github_branch
    s3_bucket_name     = module.s3.bucket_name
    ecr_repository_url = module.ecr.repository_url
    aws_region         = var.aws_region
  })

  tags = {
    Project   = var.project_name
    Owner     = var.owner
    ManagedBy = "terraform"
  }

  # Ensure S3 and ECR are fully provisioned before the instance boots
  # and tries to use them.
  depends_on = [module.s3, module.ecr]
}
