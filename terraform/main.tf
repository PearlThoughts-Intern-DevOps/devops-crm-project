resource "aws_instance" "twenty_crm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.ansible_ec2.id]

  key_name = var.key_name

  tags = {
    Name = var.instance_name
    Task = "Task-17"
  }
}
