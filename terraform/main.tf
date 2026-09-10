# ============================================================
# Amazon ECR Repository
# ============================================================

resource "aws_ecr_repository" "twenty_crm" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.project_name
    Project     = var.project_name
    Environment = "dev"
  }
}


# ============================================================
# Security Group
# ============================================================

resource "aws_security_group" "twenty_crm" {
  name        = "${var.project_name}-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  # Twenty CRM
  ingress {
    description = "Twenty CRM application"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}


# ============================================================
# EC2 Instance
# ============================================================

resource "aws_instance" "twenty_crm" {
  ami = var.ami_id
  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[0]

  key_name = var.key_name

  vpc_security_group_ids = [
    aws_security_group.twenty_crm.id
  ]

  # Existing IAM instance profile for ECR access
  iam_instance_profile = data.aws_iam_instance_profile.ecr_pull.name

  # Root volume
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  # EC2 startup automation
  user_data = templatefile("${path.module}/user-data.sh", {
    aws_region         = var.aws_region
    ecr_repository_url = aws_ecr_repository.twenty_crm.repository_url
    app_port           = var.app_port
  })

  user_data_replace_on_change = true

  tags = {
    Name        = "${var.project_name}-server"
    Project     = var.project_name
    Environment = "dev"
  }
}