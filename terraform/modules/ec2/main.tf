resource "tls_private_key" "crm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "crm_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.crm_key.public_key_openssh
}

resource "local_file" "pem_file" {
  content         = tls_private_key.crm_key.private_key_pem
  filename        = "${path.root}/${var.project_name}.pem"
  file_permission = "0400"
}

resource "aws_security_group" "crm_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH and app traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-sg"
  })
}

resource "aws_instance" "crm_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    aws_security_group.crm_sg.id
  ]

  associate_public_ip_address = true

  iam_instance_profile = var.iam_instance_profile

  key_name = aws_key_pair.crm_key.key_name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    aws_region   = var.aws_region
    repo_url     = var.repo_url
    repo_branch  = var.repo_branch
    bucket_name  = var.bucket_name
    app_port     = var.app_port
    project_name = var.project_name
  })

  user_data_replace_on_change = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2"
  })
}
