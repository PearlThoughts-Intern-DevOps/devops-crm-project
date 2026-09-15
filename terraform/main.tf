data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


resource "aws_security_group" "alb" {
  name        = "mohsin-khaled-task15-alb-sg"
  description = "Security group for Twenty CRM ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mohsin-khaled-task15-alb-sg"
    Task = "Task 15"
  }
}

resource "aws_security_group" "ec2" {
  name        = "mohsin-khaled-task15-ec2-sg"
  description = "Security group for Twenty CRM EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_ip}/32"]
  }

  ingress {
    description     = "Twenty CRM from ALB"
    from_port       = var.twenty_port
    to_port         = var.twenty_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mohsin-khaled-task15-ec2-sg"
    Task = "Task 15"
  }
}

module "ec2" {
  source = "./modules/ec2"

  ami_id            = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = "subnet-00df5fa2bef88e251"
  vpc_id            = data.aws_vpc.default.id
  instance_name     = var.instance_name
  twenty_port       = var.twenty_port
  root_volume_size  = var.root_volume_size
  security_group_id = aws_security_group.ec2.id

  user_data = templatefile("${path.module}/user_data.sh", {
    twenty_port   = var.twenty_port
    instance_name = var.instance_name
  })

  tags = {
    Name        = var.instance_name
    Project     = "Twenty CRM"
    Environment = var.environment
    Task        = "Task 15"
  }
}

module "alb" {
  source = "./modules/alb"

  alb_name           = "mohsin-khaled-task15-alb"
  vpc_id             = data.aws_vpc.default.id
  subnet_ids         = slice(sort(data.aws_subnets.default.ids), 0, 2)
  security_group_id  = aws_security_group.alb.id
  target_instance_id = module.ec2.instance_id
  target_port        = var.twenty_port
  health_check_path  = "/healthz"

  tags = {
    Name        = "mohsin-khaled-task15-alb"
    Project     = "Twenty CRM"
    Environment = var.environment
    Task        = "Task 15"
  }
}
