resource "aws_instance" "twenty" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = data.aws_subnet.selected.id

  key_name = var.key_name

  iam_instance_profile = "EC2ECRPullRole"

  user_data = templatefile("${path.module}/user_data.sh", {
    ecr_repository_url = aws_ecr_repository.twenty.repository_url
    docker_image_tag   = var.docker_image_tag
  })

  tags = {
    Name = "twenty-crm-task12"
  }
}
