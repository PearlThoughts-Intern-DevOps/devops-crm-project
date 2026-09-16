# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnet
data "aws_subnet" "default" {
  default_for_az    = true
  availability_zone = var.availability_zone
}

# Security Group
resource "aws_security_group" "twenty_sg" {
  name        = "ak-twenty-crm-sg"
  description = "Security group for Twenty CRM EC2"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  # Twenty CRM
  ingress {
    description = "Twenty CRM"
    from_port   = 3000
    to_port     = 3000
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
}

# EC2 Instance
resource "aws_instance" "twenty" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = data.aws_subnet.default.id

  key_name = var.key_name

  vpc_security_group_ids = [
    aws_security_group.twenty_sg.id
  ]

  tags = {
    Name = "ak-twenty-crm"
  }
}

