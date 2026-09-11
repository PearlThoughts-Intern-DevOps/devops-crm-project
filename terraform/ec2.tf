# -----------------------------------------------------------------------------
# EC2
#
# Provisions the Twenty CRM host using the existing mentor-provided Ubuntu AMI.
# The security group allows SSH (22) and Twenty CRM (2020).
# User data installs Docker, authenticates with ECR, and runs the application.
# -----------------------------------------------------------------------------

resource "aws_security_group" "twenty_crm" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for the Twenty CRM EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Twenty CRM application access"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_instance" "twenty_crm" {
  # Existing AMI provided by the mentor
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.twenty_crm.id]
  key_name               = var.key_pair_name
  iam_instance_profile   = "EC2ECRPullRole"

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    ecr_repository_url = aws_ecr_repository.twenty_crm.repository_url
    aws_region         = var.aws_region
    app_port           = var.app_port
  })

  user_data_replace_on_change = true

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
  }

  # Ensure ECR exists before EC2 user data tries to pull the image
  depends_on = [aws_ecr_repository.twenty_crm]
}