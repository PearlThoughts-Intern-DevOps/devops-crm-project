# -----------------------------------------------------------------------------
# EC2
#
# Provisions the Twenty CRM host: a security group allowing SSH (22) and the
# application port (2020), and an EC2 instance sized based on lessons learned
# during manual deployment (Task 7) - t3.micro / 8GB disk proved insufficient
# for Twenty CRM's setup process (Postgres migrations + data seeding), so this
# defaults to t3.small with a 20 GiB root volume.
# -----------------------------------------------------------------------------

# Latest official Ubuntu 24.04 LTS AMI, matching the AMI used in manual
# deployments so all previously-validated setup commands remain accurate.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

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
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.twenty_crm.id]
  key_name               = var.key_pair_name

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type            = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
  }
}
