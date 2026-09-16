# -----------------------------------------------------------------------------
# Data Sources: Existing Default VPC and Subnets
# -----------------------------------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# -----------------------------------------------------------------------------
# Module: Application Load Balancer (ALB)
# -----------------------------------------------------------------------------
module "alb" {
  source = "./modules/alb"

  name              = var.project_name
  vpc_id            = data.aws_vpc.default.id
  subnet_ids        = data.aws_subnets.default.ids
  app_port          = var.app_port
  health_check_path = var.health_check_path

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# Module: Amazon EC2 Instance & Isolated Security Group
# -----------------------------------------------------------------------------
module "ec2" {
  source = "./modules/ec2"

  name                        = "${var.project_name}-ec2"
  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_id                      = data.aws_vpc.default.id
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  allowed_cidr_blocks         = var.allowed_cidr_blocks
  alb_security_group_id       = module.alb.security_group_id
  app_port                    = var.app_port
  security_group_name         = "${var.project_name}-ec2-sg"
  associate_public_ip_address = true
  root_volume_size            = 20
  root_volume_type            = "gp3"
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user-data.sh", {
    app_port = var.app_port
  })

  tags = {
    Name        = "${var.project_name}-ec2"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# Target Group Attachment: Register EC2 Instance to ALB Target Group
# -----------------------------------------------------------------------------
resource "aws_lb_target_group_attachment" "twenty_crm" {
  target_group_arn = module.alb.target_group_arn
  target_id        = module.ec2.instance_id
  port             = var.app_port
}
