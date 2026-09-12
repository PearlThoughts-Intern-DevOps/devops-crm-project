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


resource "aws_security_group" "this" {
  name        = "${var.project_name}-sg"
  description = "Security group for Twenty CRM"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Twenty CRM"
    from_port   = 3000
    to_port     = 3000
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

  tags = {
    Name      = "${var.project_name}-sg"
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[0]

  key_name = var.key_name

  iam_instance_profile = var.iam_instance_profile

  vpc_security_group_ids = [
    aws_security_group.this.id
  ]

  user_data = templatefile("${path.root}/user_data.sh", {
    s3_bucket  = var.s3_bucket_name
    aws_region = var.aws_region
  })

  user_data_replace_on_change = true

  tags = {
    Name        = "${var.project_name}-server"
    Project     = var.project_name
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}