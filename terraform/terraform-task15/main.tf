data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "ec2" {
  id = "subnet-078d52bfe579c74f2"
}

resource "aws_instance" "twenty_crm" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnet.ec2.id


  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name        = "twenty-crm-task15"
    Project     = var.project_name
    Environment = "production"
  }
}

resource "aws_lb_target_group_attachment" "twenty_crm" {
  target_group_arn = aws_lb_target_group.twenty_crm.arn
  target_id        = aws_instance.twenty_crm.id
  port             = 3000
}