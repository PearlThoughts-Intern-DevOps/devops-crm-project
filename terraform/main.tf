resource "aws_ecr_repository" "twenty" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.ecr_repository_name
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_instance" "twenty" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default_vpc.ids[0]
  vpc_security_group_ids      = [data.aws_security_group.default.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  # Lets the instance authenticate with ECR on its own via temporary,
  # automatically-rotated credentials -- see iam.tf.
  #iam_instance_profile = aws_iam_instance_profile.ec2_ecr_profile.name

  iam_instance_profile = data.aws_iam_instance_profile.ec2_ecr_profile.name

  # Installs Docker, authenticates with ECR, retries the image pull
  # until it's available, then runs the app -- see
  # templates/user_data.sh.tpl for the full script.
  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    aws_region         = var.aws_region
    ecr_repository_url = aws_ecr_repository.twenty.repository_url
    image_tag          = var.image_tag
  })

  # Re-run user_data automatically if its rendered content changes
  # (e.g. a different image_tag), instead of only running once ever.
  user_data_replace_on_change = true

  tags = {
    #Name        = "${var.project_name}-${var.environment}"
    Name        = "netaji-twenty-crm"
    Environment = var.environment
    Project     = var.project_name
  }
}
