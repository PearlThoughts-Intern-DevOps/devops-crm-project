data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "ec2" {
  source = "./modules/ec2"

  project_name         = var.project_name
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = data.aws_subnets.default.ids[0]
  vpc_id               = data.aws_vpc.default.id
  key_name             = var.key_name
  iam_instance_profile = var.iam_instance_profile
  app_port             = var.app_port
  root_volume_size     = var.root_volume_size

  user_data = <<-EOT
    #!/bin/bash
    set -e

    dnf install -y docker awscli

    systemctl enable docker
    systemctl start docker

    usermod -aG docker ec2-user

    docker pull twentycrm/twenty:latest

    docker run -d \
      --name twenty-crm \
      --restart unless-stopped \
      -p ${var.app_port}:3000 \
      -e NODE_PORT=3000 \
      -e STORAGE_TYPE=S_3 \
      -e STORAGE_S3_REGION=${var.aws_region} \
      -e STORAGE_S3_NAME=${var.s3_bucket_name} \
      twentycrm/twenty:latest
  EOT
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  project_name    = var.project_name
}

module "s3" {
  source = "./modules/s3"

  bucket_name  = var.s3_bucket_name
  project_name = var.project_name
}
