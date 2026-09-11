resource "aws_security_group" "twenty_crm" {
  name        = "twenty-crm-task14-sg"
  description = "Security group for Twenty CRM EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = 2020
    to_port     = 2020
    protocol    = "tcp"
    cidr_blocks = [var.crm_allowed_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "twenty-crm-task14-sg"
  }
}

resource "aws_instance" "twenty_crm" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  iam_instance_profile = var.iam_instance_profile

  vpc_security_group_ids = [
    aws_security_group.twenty_crm.id
  ]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/user-data.sh", {
    aws_region         = var.aws_region
    ecr_repository_url = var.ecr_repository_url
    s3_bucket_name     = var.s3_bucket_name
  })

  tags = {
    Name = var.instance_name
  }
}
