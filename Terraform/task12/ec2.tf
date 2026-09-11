resource "aws_security_group" "twenty_crm_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH and app traffic"
  vpc_id      = local.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  ingress {
    description = "Twenty CRM app port"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_instance_profile" "ecr_pull" {
  name = "EC2ECRPullRole"
}

resource "aws_instance" "twenty_crm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.twenty_crm_sg.id]
  iam_instance_profile   = data.aws_iam_instance_profile.ecr_pull.name

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    aws_region   = var.aws_region
    ecr_repo_url = aws_ecr_repository.twenty_crm.repository_url
    app_port     = var.app_port
  })
}
